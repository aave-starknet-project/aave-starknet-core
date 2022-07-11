%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from contracts.interfaces.i_pool_addresses_provider import IPoolAddressesProvider
from tests.utils.constants import USER_1
namespace PoolAddressesProviderSpec:
    # Owner adds a new address as proxy
    func test_owner_adds_a_new_address_as_proxy{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        local implementation_hash
        local pool_addresses_provider
        %{
            ids.implementation_hash = context.implementation_hash
            ids.pool_addresses_provider = context.pool_addresses_provider
        %}
        IPoolAddressesProvider.transfer_ownership(pool_addresses_provider, USER_1)
        %{
            def str_to_felt(text):
                MAX_LEN_FELT = 31
                if len(text) > MAX_LEN_FELT:
                    raise Exception("Text length too long to convert to felt.")

                return int.from_bytes(text.encode(), "big")

            # Mock caller_address as USER_1 (proxy admin & pool_addresses_provider owner)
            stop_prank_provider = start_prank(ids.USER_1,target_contract_address=ids.pool_addresses_provider) 

            expect_events({"name": "ProxyCreated"})
            expect_events({"name": "AddressSetAsProxy"})
        %}
        IPoolAddressesProvider.set_address_as_proxy(
            pool_addresses_provider, 'RANDOM_PROXIED', implementation_hash
        )
        return ()
    end

    # # Owner adds a new address as proxy
    # func test_owner_adds_changes_proxy_implementation{
    #     syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    # }():
    #     alloc_locals
    #     local proxy_addressa
    #     local implementation_hash
    #     local pool_addresses_provider
    #     %{
    #         ids.proxy_address = context.proxy
    #         ids.implementation_hash = context.implementation_hash
    #         ids.pool_addresses_provider = context.pool_addresses_provider
    #     %}
    #     IPoolAddressesProvider.transfer_ownership(pool_addresses_provider, USER_1)
    #     %{
    #         def str_to_felt(text):
    #             MAX_LEN_FELT = 31
    #             if len(text) > MAX_LEN_FELT:
    #                 raise Exception("Text length too long to convert to felt.")

    # return int.from_bytes(text.encode(), "big")

    # # Mock caller_address as USER_1 (proxy admin & pool_addresses_provider owner)
    #         stop_prank_provider = start_prank(ids.USER_1,target_contract_address=ids.pool_addresses_provider)
    #         stop_prank_proxy = start_prank(ids.USER_1,target_contract_address=ids.proxy_address)

    # expect_events({"name": "AddressSetAsProxy", "data": [str_to_felt("RANDOM_PROXIED"),context.proxy,context.implementation_hash,context.implementation_hash]})
    #     %}
    #     IPoolAddressesProvider.set_address_as_proxy(
    #         pool_addresses_provider, 'RANDOM_PROXIED', proxy_address, implementation_hash
    #     )
    #     return ()
    # end

    # Owner adds a new address with no proxy and turns it into a proxy
    # TODO when pool contract is proxyfied
    # func test_owner_adds_a_new_address_with_no_proxy_and_turns_it_into_a_proxy{
    #     syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    # }():
    #     return ()
    # end

    # Unregister a proxy address
    #  func test_unregister_a_proxy_address{
    #     syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    # }():
    #     return ()
    # end

    # Owner adds a new address with proxy and turns it into no a proxy
    # TODO when pool contract is proxyfied
    # func test_owner_adds_a_new_address_with_proxy_and_turns_it_into_a_no_proxy{
    #     syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    # }():
    #     return ()
    # end

    # Unregister a no proxy address
    #  func test_unregister_a_no_proxy_address{
    #     syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    # }():
    #     return ()
    # end

    # Owner registers an existing contract (with proxy) and upgrade it
    # func test_owner_registers_an_existing_contract_with_proxy_and_upgrade_it{
    #     syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    # }():
    #     return ()
    # end

    # Owner updates the implementation of a proxy which is already initialized
    # func test_owner_updates_the_implementation_of_a_proxy_which_is_already_initialized{
    #     syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    # }():
    #     return ()
    # end

    # Owner updates the PoolConfigurator
    # @external
    # func test_owner_updates_the_pool_configurator{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    #     %{ expect_events({"name": "PoolConfiguratorUpdated", "data": [0,ids.MOCKED_IMPLEMENTATION_HASH]}) %}
    #     %{
    #         stop_mock_implementation =  mock_call(ids.MOCKED_PROXY_ADDRESS,"get_implementation",[0])
    #         stop_mock_implementation =  mock_call(ids.MOCKED_PROXY_ADDRESS,"upgrade",[])
    #     %}
    #     PoolAddressesProvider.set_address('POOL_CONFIGURATOR', MOCKED_PROXY_ADDRESS)
    #     PoolAddressesProvider.set_pool_configurator_impl(MOCKED_IMPLEMENTATION_HASH)
    #     return ()
    # end
end

func get_pool_addresses_provider() -> (address : felt):
    alloc_locals
    local address
    %{ ids.address = context.address %}
    return (address)
end
