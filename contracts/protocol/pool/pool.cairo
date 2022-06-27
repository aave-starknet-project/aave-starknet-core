%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.bool import TRUE

from contracts.protocol.libraries.storage.pool_storages import pool_storages
from contracts.protocol.libraries.logic.pool_logic import PoolLogic
from contracts.protocol.libraries.logic.supply_logic import SupplyLogic
from contracts.protocol.libraries.types.data_types import DataTypes

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
    # TODO user configuration bitmask
    SupplyLogic._execute_supply(
        user_config=DataTypes.UserConfigurationMap(Uint256(0, 0)),
        params=DataTypes.ExecuteSupplyParams(
        asset=asset,
        amount=amount,
        on_behalf_of=on_behalf_of,
        referral_code=referral_code,
        ),
    )
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
    let (reserves_count) = pool_storages.reserves_count_read()
    SupplyLogic._execute_withdraw(
        user_config=DataTypes.UserConfigurationMap(Uint256(0, 0)),
        params=DataTypes.ExecuteWithdrawParams(
        asset=asset,
        amount=amount,
        to=to,
        reserves_count=reserves_count,
        ),
    )

    return ()
end

# @notice Initializes a reserve, activating it, assigning an aToken and debt tokens and an
# interest rate strategy
# @dev Only callable by the PoolConfigurator contract
# @param asset The address of the underlying asset of the reserve
# @param aToken_address The address of the aToken that will be assigned to the reserve
# TODO add the rest of reserves parameters (debt tokens, interest_rate_strategy, etc)
@external
func init_reserve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    asset : felt, aToken_address : felt
):
    alloc_locals
    let (local reserves_count) = pool_storages.reserves_count_read()
    let (appended) = PoolLogic._execute_init_reserve(
        params=DataTypes.InitReserveParams(
        asset=asset,
        aToken_address=aToken_address,
        reserves_count=reserves_count,
        max_number_reserves=128
        ),
    )
    if appended == TRUE:
        pool_storages.reserve_count_write(reserves_count + 1)
        tempvar syscall_ptr=syscall_ptr
        tempvar pedersen_ptr=pedersen_ptr
        tempvar range_check_ptr=range_check_ptr
    else: 
        tempvar syscall_ptr=syscall_ptr
        tempvar pedersen_ptr=pedersen_ptr
        tempvar range_check_ptr=range_check_ptr
    end
    return ()
end

@view
func get_reserve_data{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    asset : felt
) -> (reserve_data : DataTypes.ReserveData):
    let (reserve) = pool_storages.reserves_read(asset)
    return (reserve)
end
