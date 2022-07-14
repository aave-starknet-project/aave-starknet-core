%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from tests.test_suites.test_specs.pool_addresses_provider_spec import TestPoolAddressesProvider

const MOCKED_PROXY_ADDRESS = 8930645
const MOCKED_IMPLEMENTATION_HASH = 192083
const MOCKED_CONTRACT_ADDRESS = 349678

@external
func __setup__{syscall_ptr : felt*, range_check_ptr}():
    %{
        def str_to_felt(text):
            MAX_LEN_FELT = 31
            if len(text) > MAX_LEN_FELT:
                raise Exception("Text length too long to convert to felt.")

            return int.from_bytes(text.encode(), "big")

        context.RANDOM_NON_PROXIED = str_to_felt("RANDOM_NON_PROXIED")
        context.NEW_MARKET_ID = str_to_felt("NEW_MARKET_ID")
    %}
    return ()
end

#
# Function guards tests
#

@external
func test_only_owner_set_market_id{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestPoolAddressesProvider.test_only_owner_set_market_id()
    return ()
end

@external
func test_only_owner_set_pool_impl{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestPoolAddressesProvider.test_only_owner_set_pool_impl()
    return ()
end

@external
func test_only_owner_set_pool_configurator_impl{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestPoolAddressesProvider.test_only_owner_set_pool_configurator_impl()
    return ()
end

@external
func test_only_owner_set_price_oracle{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestPoolAddressesProvider.test_only_owner_set_price_oracle()
    return ()
end

@external
func test_only_owner_set_ACL_admin{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestPoolAddressesProvider.test_only_owner_set_ACL_admin()
    return ()
end

@external
func test_only_owner_set_ACL_manager{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestPoolAddressesProvider.test_only_owner_set_ACL_manager()
    return ()
end

@external
func test_only_owner_set_price_oracle_sentinel{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestPoolAddressesProvider.test_only_owner_set_price_oracle_sentinel()
    return ()
end

@external
func test_only_owner_set_pool_data_provider{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestPoolAddressesProvider.test_only_owner_set_pool_data_provider()
    return ()
end

@external
func test_only_owner_set_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ):
    TestPoolAddressesProvider.test_only_owner_set_address()
    return ()
end

@external
func test_only_owner_set_address_as_proxy{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestPoolAddressesProvider.test_only_owner_set_address_as_proxy()
    return ()
end

#
# Getters / Setters tests
#

# Owner adds a new address with no proxy
@external
func test_owner_adds_new_address_with_no_proxy{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestPoolAddressesProvider.test_owner_adds_new_address_with_no_proxy()
    return ()
end

# Owner updates the MarketId
@external
func test_owner_updates_market_id{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestPoolAddressesProvider.test_owner_updates_market_id()
    return ()
end

# Owner updates the PriceOracle
@external
func test_owner_updates_price_oracle{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestPoolAddressesProvider.test_owner_updates_price_oracle()
    return ()
end

# Owner updates the ACL manager
@external
func test_owner_updates_ACL_manager{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestPoolAddressesProvider.test_owner_updates_ACL_manager()
    return ()
end

# Owner updates the ACL admin
@external
func test_owner_updates_ACL_admin{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestPoolAddressesProvider.test_owner_updates_ACL_admin()
    return ()
end

# Owner updates the DataProvider
@external
func test_owner_updates_price_oracle_sentinel{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestPoolAddressesProvider.test_owner_updates_price_oracle_sentinel()
    return ()
end

# Owner updates the DataProvider
@external
func test_owner_updates_pool_data_provider{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestPoolAddressesProvider.test_owner_updates_pool_data_provider()
    return ()
end
