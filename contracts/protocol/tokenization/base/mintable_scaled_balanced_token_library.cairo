# TODO remove unnecesary imports
# TODO import incentivized

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.math import assert_le_felt, assert_nn
from starkware.starknet.common.syscalls import get_caller_address
from starkware.starknet.common.bool import TRUE

from openzeppelin.security.safemath import SafeUint256

from contracts.protocol.libraries.helpers.constants import UINT128_MAX
from contracts.protocol.libraries.math.uint_128 import Uint128
from contracts.protocol.libraries.types.data_types import DataTypes

namespace MintableIncentivizedERC20:
    #
    # @notice Mints tokens to an account and apply incentives if defined
    # @param account The address receiving tokens
    # @param amount The amount of tokens to mint
    #
    func _mint{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        address : felt, amount : felt
    ):
        alloc_locals

        let (old_user_state) = incentivized_erc20_user_state.read(address)
        let (old_total_supply) = incentivized_erc20_total_supply.read()

        with_attr error_message("amount doesn't fit in 128 bits"):
            assert_le_felt(amount, UINT128_MAX)
        end

        let amount_256 = Uint128.to_uint_256(amount)

        # use SafeMath
        let (new_total_supply) = SafeUint256.add(old_total_supply, amount_256)
        incentivized_erc20_total_supply.write(new_total_supply)

        let old_account_balance = old_user_state.balance
        let new_account_balance = old_account_balance + amount
        let new_user_state = UserState(new_account_balance, old_user_state.additionalData)

        incentivized_erc20_user_state.write(address, new_user_state)

        # @Todo: Incentives controller logic here

        return ()
    end

    func _burn{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        address : felt, amount : felt
    ):
        alloc_locals
        let (old_user_state) = incentivized_erc20_user_state.read(address)
        let (old_total_supply) = incentivized_erc20_total_supply.read()

        with_attr error_message("amount doesn't fit in 128 bits"):
            assert_le_felt(amount, UINT128_MAX)
        end

        let amount_256 = Uint128.to_uint_256(amount)

        # use SafeMath
        let (new_total_supply) = SafeUint256.sub_le(old_total_supply, amount_256)
        incentivized_erc20_total_supply.write(new_total_supply)

        let old_account_balance = old_user_state.balance
        let new_account_balance = old_account_balance - amount
        let new_user_state = UserState(new_account_balance, old_user_state.additionalData)

        incentivized_erc20_user_state.write(address, new_user_state)

        # @Todo: Incentives controller logic here

        return ()
    end
end
