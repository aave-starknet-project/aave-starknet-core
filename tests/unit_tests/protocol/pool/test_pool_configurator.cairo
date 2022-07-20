%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE
from starkware.cairo.common.cairo_builtins import HashBuiltin

from contracts.protocol.pool.pool_configurator_library import PoolConfigurator
from contracts.protocol.libraries.types.configurator_input_types import ConfiguratorInputTypes

const POOL = 123
const ADDRESSES_PROVIDER = 456
const ACL_MANAGER = 789

@view
func test_initializer{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    let (pool_before) = PoolConfigurator.get_pool()
    assert pool_before = 0
    let (addresses_provider_before) = PoolConfigurator.get_addresses_provider()
    assert addresses_provider_before = 0

    %{ stop_mock = mock_call(ids.ADDRESSES_PROVIDER, "get_pool", [ids.POOL]) %}
    PoolConfigurator.initialize(ADDRESSES_PROVIDER)
    %{ stop_mock() %}

    let (pool_after) = PoolConfigurator.get_pool()
    assert pool_after = POOL
    let (addresses_provider_after) = PoolConfigurator.get_addresses_provider()
    assert addresses_provider_after = ADDRESSES_PROVIDER
    return ()
end

@view
func test_init_reserves{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    %{ stop_mock = mock_call(ids.ADDRESSES_PROVIDER, "get_pool", [ids.POOL]) %}
    PoolConfigurator.initialize(ADDRESSES_PROVIDER)
    %{ stop_mock() %}

    %{
        stop_mock_1 = mock_call(ids.ADDRESSES_PROVIDER, "get_ACL_manager", [ids.ACL_MANAGER])
        stop_mock_2 = mock_call(ids.ACL_MANAGER, "is_pool_admin", [ids.TRUE])
        stop_mock_3 = mock_call(ids.ACL_MANAGER, "is_asset_listing_admin", [ids.TRUE])
        stop_mock_4 = mock_call(ids.POOL, "init_reserve", [])
        stop_mock_5 = mock_call(ids.POOL, "set_configuration", [])
    %}
    let (local input : ConfiguratorInputTypes.InitReserveInput*) = alloc()
    assert input[0] = ConfiguratorInputTypes.InitReserveInput(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1)
    assert input[1] = ConfiguratorInputTypes.InitReserveInput(2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2)
    PoolConfigurator.init_reserves(2, input)
    %{
        stop_mock_5()
        stop_mock_4()
        stop_mock_3()
        stop_mock_2()
        stop_mock_1()
    %}
    return ()
end

@view
func test_drop_reserve{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    %{ stop_mock = mock_call(ids.ADDRESSES_PROVIDER, "get_pool", [ids.POOL]) %}
    PoolConfigurator.initialize(ADDRESSES_PROVIDER)
    %{ stop_mock() %}

    %{
        stop_mock_1 = mock_call(ids.ADDRESSES_PROVIDER, "get_ACL_manager", [ids.ACL_MANAGER])
        stop_mock_2 = mock_call(ids.ACL_MANAGER, "is_pool_admin", [ids.TRUE])
        stop_mock_3 = mock_call(ids.POOL, "drop_reserve", [])
    %}
    PoolConfigurator.drop_reserve(1)
    %{
        stop_mock_3()
        stop_mock_2()
        stop_mock_1()
    %}
    return ()
end

# @view
# func test_update_a_token{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
#     return ()
# end

# @view
# func test_update_stable_debt_token{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
#     return ()
# end

# @view
# func test_update_variable_debt_token{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
#     return ()
# end
