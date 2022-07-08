%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

from starkware.starknet.common.syscalls import get_contract_address
from contracts.protocol.configuration.pool_addresses_provider_library import PoolAddressesProvider

const MOCKED_PROXY_ADDRESS = 8930645
const MOCKED_IMPLEMENTATION_HASH = 192083

@external
func __setup__{syscall_ptr : felt*, range_check_ptr}():
    let (address) = get_contract_address()

    %{
        def str_to_felt(text):
            MAX_LEN_FELT = 31
            if len(text) > MAX_LEN_FELT:
                raise Exception("Text length too long to convert to felt.")

            return int.from_bytes(text.encode(), "big")

        context.POOL = str_to_felt("POOL")
        context.POOL_CONFIGURATOR = str_to_felt("POOL_CONFIGURATOR")
        context.PRICE_ORACLE = str_to_felt("PRICE_ORACLE")
        context.ACL_MANAGER = str_to_felt("ACL_MANAGER")
        context.ACL_ADMIN = str_to_felt("ACL_ADMIN")
        context.PRICE_ORACLE_SENTINEL = str_to_felt("PRICE_ORACLE_SENTINEL")
        context.DATA_PROVIDER = str_to_felt("DATA_PROVIDER")
        context.address = ids.address
    %}
    return ()
end

@external
func test_market_id{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    %{ expect_events({"name": "MarketIdSet", "data": [0,1]}) %}
    PoolAddressesProvider.set_market_id(1)
    let (market_id) = PoolAddressesProvider.get_market_id()
    assert market_id = 1
    return ()
end

@external
func test_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    %{ expect_events({"name": "AddressSet", "data": [context.POOL,0,10]}) %}
    PoolAddressesProvider.set_address('POOL', 10)
    let (address) = PoolAddressesProvider.get_address('POOL')
    assert address = 10
    return ()
end

@external
func test_address_as_proxy{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    %{ expect_events({"name": "AddressSetAsProxy", "data": [context.POOL,0,0,123456789]}) %}
    %{ mock_call(0,"get_implementation",[0]) %}
    PoolAddressesProvider.set_address_as_proxy('POOL', 123456789)
    return ()
end

@external
func test_pool{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    %{ expect_events({"name": "PoolUpdated", "data": [0,ids.MOCKED_IMPLEMENTATION_HASH]}) %}
    %{
        stop_mock_implementation =  mock_call(ids.MOCKED_PROXY_ADDRESS,"get_implementation",[0])
        stop_mock_implementation =  mock_call(ids.MOCKED_PROXY_ADDRESS,"upgrade",[])
    %}
    PoolAddressesProvider.set_address('POOL', MOCKED_PROXY_ADDRESS)
    PoolAddressesProvider.set_pool_configurator_impl(MOCKED_IMPLEMENTATION_HASH)
    return ()
end

@external
func test_pool_configurator{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    %{ expect_events({"name": "PoolConfiguratorUpdated", "data": [0,ids.MOCKED_IMPLEMENTATION_HASH]}) %}
    %{
        stop_mock_implementation =  mock_call(ids.MOCKED_PROXY_ADDRESS,"get_implementation",[0])
        stop_mock_implementation =  mock_call(ids.MOCKED_PROXY_ADDRESS,"upgrade",[])
    %}
    PoolAddressesProvider.set_address('POOL_CONFIGURATOR', MOCKED_PROXY_ADDRESS)
    PoolAddressesProvider.set_pool_configurator_impl(MOCKED_IMPLEMENTATION_HASH)
    return ()
end

@external
func test_price_oracle{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    %{ expect_events({"name": "PriceOracleUpdated", "data": [0,10]}) %}
    PoolAddressesProvider.set_price_oracle(10)
    let (price_oracle) = PoolAddressesProvider.get_price_oracle()
    assert price_oracle = 10
    return ()
end

@external
func test_ACL_manager{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    %{ expect_events({"name": "ACLManagerUpdated", "data": [0,10]}) %}
    PoolAddressesProvider.set_ACL_manager(10)
    let (ACL_manager) = PoolAddressesProvider.get_ACL_manager()
    assert ACL_manager = 10
    return ()
end

@external
func test_ACL_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    %{ expect_events({"name": "ACLAdminUpdated", "data": [0,10]}) %}
    PoolAddressesProvider.set_ACL_admin(10)
    let (ACL_admin) = PoolAddressesProvider.get_ACL_admin()
    assert ACL_admin = 10
    return ()
end

@external
func test_price_oracle_sentinel{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ):
    %{ expect_events({"name": "PriceOracleSentinelUpdated", "data": [0,10]}) %}
    PoolAddressesProvider.set_price_oracle_sentinel(10)
    let (price_oracle_sentinel) = PoolAddressesProvider.get_price_oracle_sentinel()
    assert price_oracle_sentinel = 10
    return ()
end

@external
func test_pool_data_provider{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    %{ expect_events({"name": "PoolDataProviderUpdated", "data": [0,10]}) %}
    PoolAddressesProvider.set_pool_data_provider(10)
    let (pool_data_provider) = PoolAddressesProvider.get_pool_data_provider()
    assert pool_data_provider = 10
    return ()
end
