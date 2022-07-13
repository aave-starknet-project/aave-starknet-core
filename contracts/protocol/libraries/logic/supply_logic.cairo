%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.uint256 import Uint256, uint256_eq
from starkware.cairo.common.bool import TRUE

from openzeppelin.token.erc20.interfaces.IERC20 import IERC20

from contracts.protocol.libraries.types.data_types import DataTypes
from contracts.interfaces.i_a_token import IAToken
from contracts.protocol.pool.pool_storage import PoolStorage
from contracts.protocol.libraries.logic.validation_logic import ValidationLogic
from contracts.protocol.libraries.helpers.constants import Generics

@event
func withdraw_event(reserve : felt, user : felt, to : felt, amount : Uint256):
end

@event
func supply_event(
    reserve : felt, user : felt, on_behalf_of : felt, amount : Uint256, referral_code : felt
):
end

namespace SupplyLogic:
    # @notice Implements the supply feature. Through `supply()`, users supply assets to the Aave protocol.
    # @dev Emits the `supply_event()` event.
    # @param user_config The user configuration mapping that tracks the supplied/borrowed assets
    # @param params The additional parameters needed to execute the supply function
    func execute_supply{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user_config : DataTypes.UserConfigurationMap, params : DataTypes.ExecuteSupplyParams
    ):
        alloc_locals
        let (reserve) = PoolStorage.reserves_read(params.asset)
        let (caller_address) = get_caller_address()

        ValidationLogic.validate_supply(reserve, params.amount)

        # TODO update reserve interest rates

        # Transfer underlying from caller to a_token_address
        IERC20.transferFrom(
            contract_address=params.asset,
            sender=caller_address,
            recipient=reserve.a_token_address,
            amount=params.amount,
        )

        # TODO boolean to check if it is first supply

        # TODO: liquidity_index should be Uint256
        IAToken.mint(
            contract_address=reserve.a_token_address,
            caller=caller_address,
            on_behalf_of=params.on_behalf_of,
            amount=params.amount,
            index=Uint256(reserve.liquidity_index, 0),
        )

        supply_event.emit(
            params.asset, caller_address, params.on_behalf_of, params.amount, params.referral_code
        )

        return ()
    end

    # @notice Implements the withdraw feature. Through `withdraw()`, users redeem their aTokens for the underlying asset
    # previously supplied in the Aave protocol.
    # @dev Emits the `withdraw_event()` event.
    # @param userConfig The user configuration mapping that tracks the supplied/borrowed assets
    # @param params The additional parameters needed to execute the withdraw function
    # @return The actual amount withdrawn
    func execute_withdraw{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user_config : DataTypes.UserConfigurationMap, params : DataTypes.ExecuteWithdrawParams
    ) -> (amount_to_withdraw : Uint256):
        alloc_locals

        let (caller_address) = get_caller_address()
        let (reserve) = PoolStorage.reserves_read(params.asset)

        # TODO integration with scaled_balance_of and liquidity_index
        let (local user_balance) = IAToken.balanceOf(reserve.a_token_address, caller_address)

        tempvar uint256_max : Uint256 = Uint256(Generics.UINT128_MAX, Generics.UINT128_MAX)
        let (is_amount_max) = uint256_eq(params.amount, uint256_max)
        local amount_to_withdraw : Uint256

        if is_amount_max == TRUE:
            assert amount_to_withdraw = user_balance
        else:
            assert amount_to_withdraw = params.amount
        end

        ValidationLogic.validate_withdraw(reserve, amount_to_withdraw, user_balance)

        # TODO update interest_rates post-withdraw

        IAToken.burn(
            contract_address=reserve.a_token_address,
            from_=caller_address,
            receiver_or_underlying=params.to,
            amount=amount_to_withdraw,
            index=Uint256(reserve.liquidity_index, 0),
        )

        # TODO validate health_factor

        withdraw_event.emit(
            reserve=params.asset, user=caller_address, to=params.to, amount=amount_to_withdraw
        )
        return (amount_to_withdraw)
    end
end
