%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256

from contracts.protocol.pool.PoolStorage import _reserves, _reserves_count

# Supplies an `amount` of underlying asset into the reserve, receiving in return overlying aTokens.
# - E.g. User supplies 100 USDC and gets in return 100 aUSDC
# @param asset The address of the underlying asset to supply
# @param amount The amount to be supplied
# @param on_behalf_of The address that will receive the aTokens, same as caller_address if the user
# wants to receive them on his own wallet, or a different address if the beneficiary of aTokens
# is a different wallet.
# @param referral_code Code used to register the integrator originating the operation, for potential rewards.
# 0 if the action is executed directly by the user, without any middle-man.
@external
func supply{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    asset : felt, amount : Uint256, on_behalf_of : felt, referral_code : felt
):
    # insert logic here
    return ()
end

# @notice Withdraws an `amount` of underlying asset from the reserve, burning the equivalent aTokens owned
# E.g. User has 100 aUSDC, calls withdraw() and receives 100 USDC, burning the 100 aUSDC
# @param asset The address of the underlying asset to withdraw
# @param amount The underlying amount to be withdrawn
#   - Send the value type(uint256).max in order to withdraw the whole aToken balance
# @param to The address that will receive the underlying, same as msg.sender if the user
#   wants to receive it on his own wallet, or a different address if the beneficiary is a
#   different wallet
# @return The final amount withdrawn
@external
func withdraw{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    asset : felt, amount : Uint256, to : felt
):
    # TODO insert logic here
    return ()
end

# @notice Initializes a reserve, activating it, assigning an aToken and debt tokens and an
# interest rate strategy
# @dev Only callable by the PoolConfigurator contract
# @param asset The address of the underlying asset of the reserve
# @param aTokenAddress The address of the aToken that will be assigned to the reserve
# @param stableDebtAddress The address of the StableDebtToken that will be assigned to the reserve
# @param variableDebtAddress The address of the VariableDebtToken that will be assigned to the reserve
# @param interestRateStrategyAddress The address of the interest rate strategy contract
func init_reserve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    asset : felt, aToken_address : felt
):
    # TODO insert logic here
    return ()
end
