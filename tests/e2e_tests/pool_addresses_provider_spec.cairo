%lang starknet

namespace PoolAddressesProviderSpec:
    # Owner adds a new address as proxy
    # TODO when pool contract is proxyfied
    # func test_owner_adds_new_address_as_proxy{
    #     syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    # }():
    #     let (pool_address_provider) = get_pool_address_provider()
    #     IAddressProvider.transfer_ownership(USER_1)
    #     %{ stop_prank_provider = stark_prank(ids.USER_1,target_contract_address=ids.pool_address_provider) %}
    #     IAddressProvider.set_address_as_proxy(pool_address_provider, MOCK_ADDRESS)
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

func get_pool_address_provider() -> (address : felt):
    alloc_locals
    local address
    %{ ids.address = context.address %}
    return (address)
end
