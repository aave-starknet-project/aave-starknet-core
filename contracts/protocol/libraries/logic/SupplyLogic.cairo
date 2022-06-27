%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import storage_read, storage_write, get_caller_address
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.uint256 import Uint256, uint256_check, uint256_eq, uint256_le
from starkware.cairo.common.bool import TRUE, FALSE

from openzeppelin.security.safemath import SafeUint256
from openzeppelin.token.erc20.interfaces.IERC20 import IERC20

from contracts.protocol.libraries.types.DataTypes import DataTypes
from contracts.interfaces.IAToken import IAToken
from contracts.protocol.libraries.storage.pool_storages import pool_storages

from contracts.protocol.libraries.logic.ValidationLogic import ValidationLogic
# from contracts.protocol.pool.Pool import withdraw

@event
func withdraw_event(reserve : felt, user : felt, to : felt, amount : Uint256):
end

@event
func supply_event(
    reserve : felt, user : felt, on_behalf_of : felt, amount : Uint256, referral_code : felt
):
end

namespace SupplyLogic:
    func _execute_supply{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user_config : DataTypes.UserConfigurationMap, params : DataTypes.ExecuteSupplyParams
    ):
        alloc_locals
        # amount must be valid
        let (reserve) = pool_storages.reserves_read(params.asset)

        ValidationLogic._validate_supply(reserve, params.amount)

        # TODO update reserve interest rates

        let (caller_address) = get_caller_address()

        # Transfer underlying from caller to aToken_address
        IERC20.transferFrom(
            contract_address=params.asset,
            sender=caller_address,
            recipient=reserve.aToken_address,
            amount=params.amount,
        )

        # TODO boolean to check if it is first supply
        # Mint aToken to on_behalf_of address
        IAToken.mint(
            contract_address=reserve.aToken_address, to=params.on_behalf_of, amount=params.amount
        )

        supply_event.emit(
            params.asset, caller_address, params.on_behalf_of, params.amount, params.referral_code
        )

        return ()
    end

    func _execute_withdraw{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user_config : DataTypes.UserConfigurationMap, params : DataTypes.ExecuteWithdrawParams
    ) -> (amount_to_withdraw : Uint256):
        alloc_locals

        uint256_check(params.amount)
        let (caller_address) = get_caller_address()
        let (reserve) = pool_storages.reserves_read(params.asset)

        tempvar amount_to_withdraw : Uint256 = params.amount

        # aToken balance of caller
        # TODO integration with scaled_balance_of and liquidity_index
        let (local user_balance) = IAToken.balanceOf(reserve.aToken_address, caller_address)

        ValidationLogic._validate_withdraw(reserve, params.amount, user_balance)

        # TODO update interest_rates post-withdraw
        # for now, simple implementation, burns coins and returns underlying
        IAToken.burn(
            contract_address=reserve.aToken_address,
            account=caller_address,
            recipient=params.to,
            amount=params.amount,
        )

        # TODO validate health_factor

        withdraw_event.emit(
            reserve=params.asset, user=caller_address, to=params.to, amount=amount_to_withdraw
        )
        return (amount_to_withdraw)
    end
end
