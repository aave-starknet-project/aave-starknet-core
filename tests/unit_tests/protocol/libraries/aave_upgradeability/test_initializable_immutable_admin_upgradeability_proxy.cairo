%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_contract_address

from tests.utils.constants import USER_1, USER_2

@contract_interface
namespace IProxy:
    func initialize(impl_hash : felt, calldata_len : felt, calldata : felt*) -> (
        retdata_len : felt, retdata : felt*
    ):
    end

    func upgrade_to_and_call(
        impl_hash : felt, selector : felt, calldata_len : felt, calldata : felt*
    ) -> (retdata_len : felt, retdata : felt*):
    end

    func upgrade_to(impl_hash : felt):
    end

    func get_implementation() -> (implementation : felt):
    end
end

@contract_interface
namespace IToken:
    func get_name() -> (name : felt):
    end

    func get_total_supply() -> (supply : felt):
    end
end

@external
func __setup__{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (deployer) = get_contract_address()
    %{
        context.proxy_address = deploy_contract("./contracts/protocol/libraries/aave_upgradeability/initializable_immutable_admin_upgradeability_proxy.cairo", {"proxy_admin": ids.deployer}).contract_address
        context.implementation_hash = declare("./tests/contracts/mock_token.cairo").class_hash
        context.initialize_selector=215307247182100370520050591091822763712463273430149262739280891880522753123
    %}

    tempvar proxy
    tempvar implementation_hash
    tempvar selector

    %{
        ids.proxy = context.proxy_address 
        ids.implementation_hash=context.implementation_hash
        ids.selector=context.initialize_selector
    %}
    let (calldata : felt*) = alloc()

    assert calldata[0] = 345
    assert calldata[1] = 900
    IProxy.initialize(proxy, implementation_hash, 2, calldata)

    return ()
end

@external
func test_initialize{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    tempvar proxy

    %{ ids.proxy = context.proxy_address %}
    %{ stop_prank_non_admin = start_prank(ids.USER_1,target_contract_address=context.proxy_address) %}
    let (name) = IToken.get_name(proxy)
    let (supply) = IToken.get_total_supply(proxy)
    %{ stop_prank_non_admin() %}
    assert name = 345
    assert supply = 900
    return ()
end

@external
func test_initialize_when_already_initialized{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    alloc_locals
    local proxy
    local implementation_hash
    local selector

    %{
        ids.proxy = context.proxy_address 
        ids.implementation_hash=context.implementation_hash
        ids.selector=context.initialize_selector
    %}

    let (calldata : felt*) = alloc()

    assert calldata[0] = 33
    assert calldata[1] = 33
    %{ expect_revert(error_message="Already initialized") %}
    IProxy.initialize(proxy, implementation_hash, 2, calldata)

    return ()
end

@external
func test_update_to_and_call{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    local proxy
    local implementation_hash
    local selector

    %{
        ids.proxy = context.proxy_address 
        ids.implementation_hash=context.implementation_hash
        ids.selector=context.initialize_selector
    %}

    let (calldata : felt*) = alloc()

    assert calldata[0] = 400
    assert calldata[1] = 500
    # no need to change the implementation hash as long as we verify that the init values were updated
    IProxy.upgrade_to_and_call(proxy, implementation_hash, selector, 2, calldata)
    %{ stop_prank_non_admin = start_prank(ids.USER_1,target_contract_address=context.proxy_address) %}
    let (name) = IToken.get_name(proxy)
    let (supply) = IToken.get_total_supply(proxy)
    %{ stop_prank_non_admin() %}
    assert name = 400
    assert supply = 500
    return ()
end

@external
func test_upgrade_to{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    local proxy

    %{ ids.proxy = context.proxy_address %}

    let new_implementation_hash = 34004

    IProxy.upgrade_to(proxy, new_implementation_hash)

    let (current_implementation) = IProxy.get_implementation(proxy)

    assert current_implementation = new_implementation_hash

    return ()
end

@external
func test_proxy_admin_calls_fall_back_function{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    alloc_locals
    local proxy

    %{ ids.proxy = context.proxy_address %}

    %{ expect_revert(error_message="Proxy: caller is admin") %}
    let (name) = IToken.get_name(proxy)

    return ()
end
