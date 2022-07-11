%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_lt, uint256_sub
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.bool import TRUE
from contracts.interfaces.i_pool import IPool
from contracts.protocol.pool.pool_storage import PoolStorage
from starkware.cairo.common.math import assert_le_felt, assert_nn, assert_not_zero
from openzeppelin.security.safemath import SafeUint256
from contracts.protocol.libraries.math.uint_128 import Uint128
from contracts.protocol.tokenization.base.incentivized_erc20_library import IncentivizedERC20
from contracts.protocol.libraries.types.data_types import DataTypes
from contracts.protocol.libraries.math.wad_ray_math import Ray, ray_sub, ray_mul, ray_div
# @event
# func Transfer(from : felt, to : felt,  amount_to_mint : Uint256):
# end

# @event
# func Mint( from : felt, to : felt, balance_increase : felt, index : Uint256):
# end

namespace ScaledBalanceToken:
    #
    # @notice Implements the basic logic to mint a scaled balance token.
    # @param caller The address performing the mint
    # @param onBehalfOf The address of the user that will receive the scaled tokens
    # @param amount The amount of tokens getting minted
    # @param index The next liquidity index of the reserve
    # @return `true` if the the previous balance of the user was 0

    func _mint_scaled{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        caller : felt, onBehalfOf : felt, amount : Uint256, index : Uint256
    ):
        let (amount_ray) = Ray(amount)
        let (index_ray) = Ray(index)
        let (amount_scaled) = ray_div(amount_ray, index_ray)
        let (scaled_balance) = IncentivizedERC20.balance_of(onBehalfOf)
        let (scaled_balance_ray) = Ray(scaled_balance)
        let (current_user_state) = IncentivizedERC20.get_user_state(onBehalfOf)
        let (additionalData_ray) = Ray(current_user_state.additionalData)
        let (balance_increase) = ray_sub(
            ray_mul(scaled_balance_ray, index_ray), ray_mul(scaled_balance_ray, additionalData_ray)
        )

        IncentivizedERC20.set_user_state(
            onBehalfOf, DataTypes.UserState(current_user_state.balance, index.low)
        )

        with_attr error_message("invalid mint amount"):
            assert_not_zero(amount_scaled)
        end

        IncentivizedERC20._mint(onBehalfOf, amount_scaled.ray.low)
        # TODO: emit transfer and mint events below

        if scaled_balance == 0:
            return (TRUE)
        end
        return ()
    end

    # @notice Implements the basic logic to burn a scaled balance token.
    #  @dev In some instances, a burn transaction will emit a mint event
    #  if the amount to burn is less than the interest that the user accrued
    #  @param user The user which debt is burnt
    # @param target The address that will receive the underlying, if any
    # @param amount The amount getting burned
    # @param index The variable debt index of the reserve

    func _burn_scaled{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user : felt, target : felt, amount : Uint256, index : Uint256
    ):
        let (amount_ray) = Ray(amount)
        let (index_ray) = Ray(index)
        let (amount_scaled) = ray_div(amount_ray, index_ray)
        let (scaled_balance) = IncentivizedERC20.balance_of(user)
        let (current_user_state) = IncentivizedERC20.get_user_state(user)
        let (scaled_balance_ray) = Ray(scaled_balance)
        let (additionalData_ray) = Ray(current_user_state.additionalData)
        let (balance_increase) = ray_sub(
            ray_mul(scaled_balance_ray, index_ray), ray_mul(scaled_balance_ray, additionalData_ray)
        )

        IncentivizedERC20.set_user_state(
            user, DataTypes.UserState(current_user_state.balance, index.low)
        )

        with_attr error_message("invalid mint amount"):
            assert_not_zero(amount_scaled)
        end

        IncentivizedERC20._burn(user, amount_scaled.ray.low)
        # emit transfer and mint events below
        let (amount_is_lt_balance_increase) = uint256_lt(amount, balance_increase.ray)
        if amount_is_lt_balance_increase == 1:
            let (amount_to_mint) = uint256_sub(balance_increase, amount)
            # TODO: emit events
        else:
            let (amount_to_burn) = uint256_sub(amount, balance_increase)
            # TODO: emit events
        end
        return ()
    end
end
