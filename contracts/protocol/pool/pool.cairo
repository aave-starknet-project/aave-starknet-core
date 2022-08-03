%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.bool import TRUE
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.math_cmp import is_not_zero
from starkware.starknet.common.syscalls import get_caller_address

from contracts.protocol.libraries.helpers.bool_cmp import BoolCompare
from contracts.protocol.libraries.logic.pool_logic import PoolLogic
from contracts.protocol.libraries.logic.reserve_configuration import ReserveConfiguration
from contracts.protocol.libraries.logic.supply_logic import SupplyLogic
from contracts.protocol.libraries.types.data_types import DataTypes
from contracts.protocol.pool.pool_library import Pool
from contracts.protocol.pool.pool_storage import PoolStorage

func assert_only_pool_configurator{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    let (caller_address) = get_caller_address()
    let (addresses_provider) = PoolStorage.addresses_provider_read()
    # TODO Check pool_provider address stored in address_provider contract
    with_attr error_message("The caller of the function is not the pool configurator"):
        # assert caller_address == pool_configurator
    end
    return ()
end

func assert_only_pool_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (caller_address) = get_caller_address()
    let (addresses_provider) = PoolStorage.addresses_provider_read()
    # TODO Check pool_admin address stored in address_provider contract
    with_attr error_message("The caller of the function is not the pool configurator"):
        # assert caller_address == pool_admin
    end
    return ()
end

@view
func get_pool_revision{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    revision : felt
):
    let (revision) = PoolStorage.pool_revision_read()
    return (revision)
end

# @dev Constructor.
# @param provider The address of the PoolAddressesProvider contract
@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    provider : felt
):
    PoolStorage.addresses_provider_write(provider)
    return ()
end

# @notice Initializes the Pool.
# @dev Function is invoked by the proxy contract when the Pool contract is added to the
# PoolAddressesProvider of the market.
# @param provider The address of the PoolAddressesProvider
@external
func initialize{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(provider : felt):
    let (addresses_provider) = PoolStorage.addresses_provider_read()
    with_attr error_message("The address of the pool addresses provider is invalid"):
        assert provider = addresses_provider
    end
    PoolStorage.max_stable_rate_borrow_size_percent_write(25 * 10 ** 2)  # 0.25e4 bps
    PoolStorage.flash_loan_premium_total_write(9)  # 9bps
    PoolStorage.flash_loan_premium_to_protocol_write(0)
    return ()
end

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
    SupplyLogic.execute_supply(
        user_config=DataTypes.UserConfigurationMap(0, 0),
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
    let (reserves_count) = PoolStorage.reserves_count_read()
    SupplyLogic.execute_withdraw(
        user_config=DataTypes.UserConfigurationMap(0, 0),
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
# @param a_token_address The address of the aToken that will be assigned to the reserve
# TODO add the rest of reserves parameters (debt tokens, interest_rate_strategy, etc)
@external
func init_reserve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    asset : felt,
    a_token_address : felt,
    stable_debt_token_address : felt,
    variable_debt_token_address : felt,
):
    alloc_locals
    assert_only_pool_configurator()
    let (local reserves_count) = PoolStorage.reserves_count_read()
    let (appended) = PoolLogic.execute_init_reserve(
        params=DataTypes.InitReserveParams(
        asset=asset,
        a_token_address=a_token_address,
        stable_debt_token_address=stable_debt_token_address,
        variable_debt_token_address=variable_debt_token_address,
        reserves_count=reserves_count,
        max_number_reserves=128
        ),
    )
    if appended == TRUE:
        PoolStorage.reserve_count_write(reserves_count + 1)
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    else:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    end
    return ()
end

# @notice Drop a reserve
# @dev Only callable by the PoolConfigurator contract
# @param asset The address of the underlying asset of the reserve
@external
func drop_reserve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(asset : felt):
    PoolLogic.execute_drop_reserve(asset)
    return ()
end

# @notice Set pool configuration
# @dev Only callable by the PoolConfigurator contract
# @param asset The address of the underlying asset of the reserve
# @param configuration The configuration to set for the reserve
@external
func set_configuration{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    asset : felt, configuration : DataTypes.ReserveConfigurationMap
):
    alloc_locals
    assert_only_pool_configurator()
    with_attr error_message("Zero address is not valid"):
        assert_not_zero(asset)
    end
    let (reserve) = PoolStorage.reserves_read(asset)
    let (is_id_not_zero) = is_not_zero(reserve.id)
    let (first_asset) = Pool.get_reserve_address_by_id(0)
    let (are_assets_equal) = BoolCompare.eq(first_asset, asset)
    let (is_asset_listed) = BoolCompare.either(is_id_not_zero, are_assets_equal)
    with_attr error_message("Asset is not listed"):
        assert_not_zero(is_asset_listed)
    end
    assert reserve.configuration = configuration
    PoolStorage.reserves_write(asset, reserve)
    return ()
end

@view
func get_addresses_provider{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ) -> (provider : felt):
    let (provider) = PoolStorage.addresses_provider_read()
    return (provider)
end

@view
func get_reserve_data{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    asset : felt
) -> (reserve_data : DataTypes.ReserveData):
    let (reserve) = PoolStorage.reserves_read(asset)
    return (reserve)
end

# @view
# func get_configuration{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
#     asset : felt
# ) -> (config : DataTypes.ReserveConfigurationMap):
#     let (reserve) = PoolStorage.reserves_read(asset)
#     let (config) = reserve.configuration
#     return (config)
# end

@view
func get_reserves_list{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    assets_len : felt, assets : felt*
):
    let (assets, assets_len) = Pool.get_reserves_list()
    return (assets, assets_len)
end

@view
func get_reserve_address_by_id{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    reserve_id : felt
) -> (address : felt):
    let (address : felt) = Pool.get_reserve_address_by_id(reserve_id)
    return (address)
end

@view
func MAX_NUMBER_RESERVES{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    max_number : felt
):
    let max_number = ReserveConfiguration.MAX_RESERVES_COUNT
    return (max_number)
end
