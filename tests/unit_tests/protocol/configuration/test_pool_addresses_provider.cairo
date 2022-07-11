%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

from starkware.starknet.common.syscalls import get_contract_address
from contracts.protocol.configuration.pool_addresses_provider_library import PoolAddressesProvider
from tests.utils.constants import USER_1

const MOCKED_PROXY_ADDRESS = 8930645
const MOCKED_IMPLEMENTATION_HASH = 192083
const MOCKED_CONTRACT_ADDRESS = 349678

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
        context.RANDOM_NON_PROXIED = str_to_felt("RANDOM_NON_PROXIED")
        context.NEW_MARKET_ID = str_to_felt("NEW_MARKET_ID")
        context.address = ids.address
    %}
    return ()
end

# Test the only_owner accessibility of the PoolAddressesProvider
@external
func test_only_owner_set_market_id{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    # Transfer ownership to user_1
    PoolAddressesProvider.transfer_ownership(USER_1)

    # Try to access it (using the 0 address in protostar)
    %{ expect_revert(error_message="Ownable: caller is not the owner") %}
    PoolAddressesProvider.set_market_id(1)
    return ()
end

@external
func test_only_owner_set_pool_impl{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    PoolAddressesProvider.transfer_ownership(USER_1)
    %{ expect_revert(error_message="Ownable: caller is not the owner") %}
    PoolAddressesProvider.set_pool_impl(MOCKED_IMPLEMENTATION_HASH)
    return ()
end

@external
func test_only_owner_set_pool_configurator_impl{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    PoolAddressesProvider.transfer_ownership(USER_1)
    %{ expect_revert(error_message="Ownable: caller is not the owner") %}
    PoolAddressesProvider.set_pool_configurator_impl(MOCKED_IMPLEMENTATION_HASH)
    return ()
end

@external
func test_only_owner_set_price_oracle{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    PoolAddressesProvider.transfer_ownership(USER_1)
    %{ expect_revert(error_message="Ownable: caller is not the owner") %}
    PoolAddressesProvider.set_price_oracle(MOCKED_CONTRACT_ADDRESS)
    return ()
end

@external
func test_only_owner_set_ACL_admin{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    PoolAddressesProvider.transfer_ownership(USER_1)
    %{ expect_revert(error_message="Ownable: caller is not the owner") %}
    PoolAddressesProvider.set_ACL_admin(MOCKED_CONTRACT_ADDRESS)
    return ()
end

@external
func test_only_owner_set_ACL_manager{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    PoolAddressesProvider.transfer_ownership(USER_1)
    %{ expect_revert(error_message="Ownable: caller is not the owner") %}
    PoolAddressesProvider.set_ACL_manager(MOCKED_CONTRACT_ADDRESS)
    return ()
end

@external
func test_only_owner_set_price_oracle_sentinel{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    PoolAddressesProvider.transfer_ownership(USER_1)
    %{ expect_revert(error_message="Ownable: caller is not the owner") %}
    PoolAddressesProvider.set_price_oracle_sentinel(MOCKED_CONTRACT_ADDRESS)
    return ()
end

@external
func test_only_owner_set_pool_data_provider{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    PoolAddressesProvider.transfer_ownership(USER_1)
    %{ expect_revert(error_message="Ownable: caller is not the owner") %}
    PoolAddressesProvider.set_pool_data_provider(MOCKED_CONTRACT_ADDRESS)
    return ()
end

@external
func test_only_owner_set_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ):
    PoolAddressesProvider.transfer_ownership(USER_1)
    %{ expect_revert(error_message="Ownable: caller is not the owner") %}
    PoolAddressesProvider.set_address('RANDOM_ID', MOCKED_CONTRACT_ADDRESS)
    return ()
end

@external
func test_only_owner_set_address_as_proxy{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    PoolAddressesProvider.transfer_ownership(USER_1)
    %{ expect_revert(error_message="Ownable: caller is not the owner") %}
    PoolAddressesProvider.set_address_as_proxy('RANDOM_ID', MOCKED_IMPLEMENTATION_HASH)
    return ()
end

# Owner adds a new address with no proxy
@external
func test_owner_adds_new_address_with_no_proxy{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    %{ expect_events({"name": "AddressSet", "data": [context.RANDOM_NON_PROXIED,0,ids.MOCKED_CONTRACT_ADDRESS]}) %}
    let (contract_address) = get_contract_address()
    let non_proxied_address_id = 'RANDOM_NON_PROXIED'
    PoolAddressesProvider.set_address(non_proxied_address_id, MOCKED_CONTRACT_ADDRESS)
    let (address) = PoolAddressesProvider.get_address(non_proxied_address_id)
    assert address = MOCKED_CONTRACT_ADDRESS
    return ()
end

# Owner updates the MarketId
@external
func test_owner_updates_market_id{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    let (contract_address) = get_contract_address()
    let (old_market_id) = PoolAddressesProvider.get_market_id()
    %{ expect_events({"name": "MarketIdSet", "data": [ids.old_market_id,context.NEW_MARKET_ID]}) %}
    PoolAddressesProvider.set_market_id('NEW_MARKET_ID')
    let (new_market_id) = PoolAddressesProvider.get_market_id()
    assert new_market_id = 'NEW_MARKET_ID'
    return ()
end

# Owner updates the PriceOracle
@external
func test_owner_updates_price_oracle{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    %{ expect_events({"name": "PriceOracleUpdated", "data": [0,10]}) %}
    let (old_price_oracle) = PoolAddressesProvider.get_price_oracle()
    assert old_price_oracle = 0
    PoolAddressesProvider.set_price_oracle(10)
    let (new_price_oracle) = PoolAddressesProvider.get_price_oracle()
    assert new_price_oracle = 10
    return ()
end

# Owner updates the ACL manager
@external
func test_owner_updates_ACL_manager{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    %{ expect_events({"name": "ACLManagerUpdated", "data": [0,10]}) %}
    let (old_ACL_manager) = PoolAddressesProvider.get_ACL_manager()
    assert old_ACL_manager = 0
    PoolAddressesProvider.set_ACL_manager(10)
    let (new_ACL_manager) = PoolAddressesProvider.get_ACL_manager()
    assert new_ACL_manager = 10
    return ()
end

# Owner updates the ACL admin
@external
func test_owner_updates_ACL_admin{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    %{ expect_events({"name": "ACLAdminUpdated", "data": [0,10]}) %}
    let (old_ACL_admin) = PoolAddressesProvider.get_ACL_admin()
    assert old_ACL_admin = 0
    PoolAddressesProvider.set_ACL_admin(10)
    let (new_ACL_admin) = PoolAddressesProvider.get_ACL_admin()
    assert new_ACL_admin = 10
    return ()
end

# Owner updates the DataProvider
@external
func test_owner_updates_price_oracle_sentinel{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    %{ expect_events({"name": "PriceOracleSentinelUpdated", "data": [0,10]}) %}
    let (old_price_oracle_sentinel) = PoolAddressesProvider.get_price_oracle_sentinel()
    assert old_price_oracle_sentinel = 0
    PoolAddressesProvider.set_price_oracle_sentinel(10)
    let (price_oracle_sentinel) = PoolAddressesProvider.get_price_oracle_sentinel()
    assert price_oracle_sentinel = 10
    return ()
end

# Owner updates the DataProvider
@external
func test_owner_updates_pool_data_provider{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    %{ expect_events({"name": "PoolDataProviderUpdated", "data": [0,10]}) %}
    let (old_pool_data_provider) = PoolAddressesProvider.get_pool_data_provider()
    assert old_pool_data_provider = 0
    PoolAddressesProvider.set_pool_data_provider(10)
    let (pool_data_provider) = PoolAddressesProvider.get_pool_data_provider()
    assert pool_data_provider = 10
    return ()
end
