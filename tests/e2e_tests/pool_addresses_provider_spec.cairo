%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_equal
from starkware.starknet.common.syscalls import get_contract_address
from contracts.interfaces.i_pool_addresses_provider import IPoolAddressesProvider
from contracts.interfaces.i_proxy import IProxy
from tests.utils.constants import USER_1, USER_2, MOCK_CONTRACT_ADDRESS
from tests.interfaces.i_basic_proxy_impl import IBasicProxyImpl

const convertible_address_id = 'CONVERTIBLE_ADDRESS'
const convertible_2_address_id = 'CONVERTIBLE_2_ADDRESS'
const pool_id = 'POOL'
const new_registered_contract_id = 'NEW_REGISTERED_CONTRACT'

namespace PoolAddressesProviderSpec:
    # Owner adds a new address as proxy
    func test_owner_adds_a_new_address_as_proxy{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        let (pool_addresses_provider, implementation_hash) = before_each()
        IPoolAddressesProvider.transfer_ownership(pool_addresses_provider, USER_1)
        %{
            # Mock caller_address as USER_1 (proxy admin & pool_addresses_provider owner)
            stop_prank_provider = start_prank(ids.USER_1,target_contract_address=ids.pool_addresses_provider) 

            expect_events({"name": "ProxyCreated"})
            expect_events({"name": "AddressSetAsProxy"})
        %}
        IPoolAddressesProvider.set_address_as_proxy(
            pool_addresses_provider, 'RANDOM_PROXIED', implementation_hash
        )
        %{ stop_prank_provider() %}
        return ()
    end

    # Owner adds a new address with no proxy and turns it into a proxy - stops after expect_revert
    func test_owner_adds_a_new_address_with_no_proxy_and_turns_it_into_a_proxy_1{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        let (pool_addresses_provider, implementation_hash) = before_each()
        IPoolAddressesProvider.transfer_ownership(pool_addresses_provider, USER_1)

        # add address as non proxy
        add_non_proxy_address(convertible_address_id)
        %{ expect_revert() %}
        IProxy.get_implementation(MOCK_CONTRACT_ADDRESS)
        return ()
    end

    # Owner adds a new address with no proxy and turns it into a proxy
    func test_owner_adds_a_new_address_with_no_proxy_and_turns_it_into_a_proxy_2{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        let (pool_addresses_provider, implementation_hash) = before_each()
        IPoolAddressesProvider.transfer_ownership(pool_addresses_provider, USER_1)

        add_non_proxy_address(convertible_address_id)
        unregister_address(convertible_address_id)  # Unregister address as non proxy
        add_proxy_address(convertible_address_id)  # Add address as proxy
        let (proxy_address) = IPoolAddressesProvider.get_address(
            pool_addresses_provider, convertible_address_id
        )
        let (implementation) = IProxy.get_implementation(proxy_address)
        assert implementation = implementation_hash
        return ()
    end

    # Unregister a proxy address
    func test_unregister_a_proxy_address{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        let (pool_addresses_provider, implementation_hash) = before_each()
        IPoolAddressesProvider.transfer_ownership(pool_addresses_provider, USER_1)

        add_proxy_address(convertible_address_id)
        unregister_address(convertible_address_id)
        let (proxy_address) = IPoolAddressesProvider.get_address(
            pool_addresses_provider, convertible_address_id
        )
        %{ expect_revert() %}
        IProxy.get_implementation(proxy_address)
        return ()
    end

    # Owner adds a new address with proxy and turns it into no a proxy
    func test_owner_adds_a_new_address_with_proxy_and_turns_it_into_a_no_proxy{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        let (pool_addresses_provider, implementation_hash) = before_each()
        IPoolAddressesProvider.transfer_ownership(pool_addresses_provider, USER_1)
        let (current_address) = IPoolAddressesProvider.get_address(
            pool_addresses_provider, convertible_2_address_id
        )
        assert current_address = 0
        add_proxy_address(convertible_2_address_id)  # Add address as proxy
        let (proxy_address) = IPoolAddressesProvider.get_address(
            pool_addresses_provider, convertible_2_address_id
        )
        let (proxy_implementation) = IProxy.get_implementation(proxy_address)
        assert proxy_implementation = implementation_hash
        unregister_address(convertible_2_address_id)  # Unregister address as proxy
        add_non_proxy_address(convertible_2_address_id)  # Add address as non proxy
        %{ expect_revert() %}
        IProxy.get_implementation(MOCK_CONTRACT_ADDRESS)
        return ()
    end

    # Unregister a no proxy address
    func test_unregister_a_no_proxy_address{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        let (pool_addresses_provider, implementation_hash) = before_each()
        IPoolAddressesProvider.transfer_ownership(pool_addresses_provider, USER_1)

        add_non_proxy_address(convertible_2_address_id)
        let (registered_address) = IPoolAddressesProvider.get_address(
            pool_addresses_provider, convertible_2_address_id
        )
        unregister_address(convertible_2_address_id)
        let (registered_after) = IPoolAddressesProvider.get_address(
            pool_addresses_provider, convertible_2_address_id
        )
        assert registered_after = 0
        assert_not_equal(registered_address, registered_after)
        %{ expect_revert() %}
        IProxy.get_implementation(registered_after)
        return ()
    end

    # Owner registers an existing contract (with proxy) and upgrade it
    # TODO test this with a proxified periphery contract instead of the basic_proxy_impl
    func test_owner_registers_an_existing_contract_with_proxy_and_upgrade_it{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        let (pool_addresses_provider, implementation_hash) = before_each()
        IPoolAddressesProvider.transfer_ownership(pool_addresses_provider, USER_1)
        %{ stop_prank_provider = start_prank(ids.USER_1,target_contract_address=ids.pool_addresses_provider) %}

        local new_proxy : felt
        # deploy a new proxy whose implementation is basic_proxy_impl v1.
        %{ ids.new_proxy = deploy_contract("./lib/cairo_contracts/src/openzeppelin/upgrades/Proxy.cairo",{"implementation_hash":context.implementation_hash}).contract_address %}

        # Initialize proxy w/ USER_2 as admin
        IProxy.initialize(new_proxy, USER_2)
        let (proxy_admin) = IProxy.get_admin(new_proxy)
        let (version) = IBasicProxyImpl.get_version(new_proxy)
        assert proxy_admin = USER_2
        assert version = 1

        # Register basic_proxy_impl contract in PoolAddressesProvider
        %{ stop_prank_proxy= start_prank(ids.USER_2,target_contract_address=ids.new_proxy) %}
        IProxy.set_admin(new_proxy, pool_addresses_provider)
        %{ stop_prank_proxy() %}
        IPoolAddressesProvider.set_address(
            pool_addresses_provider, new_registered_contract_id, new_proxy
        )
        let (expected_address) = IPoolAddressesProvider.get_address(
            pool_addresses_provider, new_registered_contract_id
        )
        assert expected_address = new_proxy

        #
        # Upgrade proxy implementation to basic_proxy_impl_v2
        #
        local new_implementation
        # declare implementation of basic_proxy_impl_v2
        %{ ids.new_implementation = declare("./tests/contracts/basic_proxy_impl_v2.cairo").class_hash %}
        # Replaces proxy implementation (currently basic_proxy_impl) with basic_proxy_impl_v2
        IPoolAddressesProvider.set_address_as_proxy(
            pool_addresses_provider, new_registered_contract_id, new_implementation
        )
        let (version) = IBasicProxyImpl.get_version(new_proxy)
        assert version = 2
        %{ stop_prank_provider() %}
        return ()
    end

    # Owner updates the implementation of a proxy which is already initialized
    func test_owner_updates_the_implementation_of_a_proxy_which_is_already_initialized{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        let (pool_addresses_provider, implementation_hash) = before_each()
        IPoolAddressesProvider.transfer_ownership(pool_addresses_provider, USER_1)
        add_proxy_address(pool_id)  # Deploy proxy for pool
        let (proxy_address) = IPoolAddressesProvider.get_address(pool_addresses_provider, pool_id)
        let (pool_implementation) = IProxy.get_implementation(proxy_address)
        %{
            expect_events({"name": "PoolUpdated","data":[ids.pool_implementation,ids.pool_implementation]}) 
            stop_prank_provider = start_prank(ids.USER_1,target_contract_address=ids.pool_addresses_provider)
        %}
        # Update the pool proxy
        IPoolAddressesProvider.set_pool_impl(pool_addresses_provider, implementation_hash)
        let (new_pool_impl) = IProxy.get_implementation(proxy_address)

        # pool implementation should not change
        assert pool_implementation = new_pool_impl
        %{ stop_prank_provider() %}
        return ()
    end
end

# Before each test_case, pool_addresses_owner is USER_1.
func before_each{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    pool_addresses_provider : felt, implementation_hash : felt
):
    alloc_locals
    local implementation_hash
    local pool_addresses_provider
    %{
        ids.implementation_hash = context.implementation_hash # basic_proxy_impl class hash
        ids.pool_addresses_provider = context.pool_addresses_provider
    %}
    return (pool_addresses_provider, implementation_hash)
end

# Owner adds a new address with no proxy and turns it into a proxy
func add_non_proxy_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    id : felt
):
    alloc_locals
    let (pool_addresses_provider, implementation_hash) = before_each()
    local pool_addresses_provider
    %{ ids.pool_addresses_provider = context.pool_addresses_provider %}
    tempvar temp_id = id
    %{
        # Mock caller_address as USER_1 (proxy admin & pool_addresses_provider owner)
        stop_prank_provider = start_prank(ids.USER_1,target_contract_address=ids.pool_addresses_provider) 

        expect_events({"name": "AddressSet","data":[ids.id, 0,ids.MOCK_CONTRACT_ADDRESS]})
    %}

    let (old_non_proxied_address) = IPoolAddressesProvider.get_address(pool_addresses_provider, id)
    assert old_non_proxied_address = 0
    IPoolAddressesProvider.set_address(pool_addresses_provider, id, MOCK_CONTRACT_ADDRESS)
    %{ stop_prank_provider() %}

    let (registered_address) = IPoolAddressesProvider.get_address(pool_addresses_provider, id)
    assert registered_address = MOCK_CONTRACT_ADDRESS
    return ()
end

func unregister_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    id : felt
):
    alloc_locals
    let (pool_addresses_provider, implementation_hash) = before_each()
    local pool_addresses_provider
    %{
        ids.pool_addresses_provider = context.pool_addresses_provider
        expect_events({"name": "AddressSet","data":[ids.id, ids.MOCK_CONTRACT_ADDRESS,0]})
        # expect_events({"name": "AddressSet","data":{"id":ids.id,"old_address":ids.MOCK_CONTRACT_ADDRESS,"new_address":0}})
        stop_prank_provider = start_prank(ids.USER_1,target_contract_address=ids.pool_addresses_provider)
    %}
    IPoolAddressesProvider.set_address(pool_addresses_provider, id, 0)
    %{ stop_prank_provider() %}
    return ()
end

func add_proxy_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    id : felt
):
    alloc_locals
    let (pool_addresses_provider, implementation_hash) = before_each()

    local pool_addresses_provider
    local mock_implementation_hash
    %{
        ids.pool_addresses_provider = context.pool_addresses_provider
        ids.mock_implementation_hash = context.implementation_hash
    %}
    %{
        expect_events({"name": "ProxyCreated"})
        expect_events({"name": "AddressSetAsProxy"})
        stop_prank_provider = start_prank(ids.USER_1,target_contract_address=ids.pool_addresses_provider)
    %}
    IPoolAddressesProvider.set_address_as_proxy(
        pool_addresses_provider, id, mock_implementation_hash
    )

    let (proxy_address) = IPoolAddressesProvider.get_address(pool_addresses_provider, id)
    let (implementation_hash) = IProxy.get_implementation(proxy_address)
    assert implementation_hash = mock_implementation_hash
    %{ stop_prank_provider() %}
    return ()
end
