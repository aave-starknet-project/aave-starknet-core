%lang starknet

from starkware.starknet.common.syscalls import get_contract_address
from starkware.cairo.common.cairo_builtins import HashBuiltin

from contracts.mocks.i_mock_initializable_implementation import (
    IMockInitializableImplementation,
    IMockInitializableReentrantImplementation,
)
from contracts.mocks.mock_initializable_implementation_library import (
    MockInitializableImplementation,
    MockInitializableReentrant,
    MockInitializableImplementationV2,
)
from tests.interfaces.i_basic_proxy_impl import IBasicProxyImpl

const INIT_VALUE = 10
const INIT_TEXT = 'text'

@external
func __setup__{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals
    let (deployer) = get_contract_address()
    local proxy_address
    %{
        def str_to_felt(text):
            MAX_LEN_FELT = 31
            if len(text) > MAX_LEN_FELT:
                raise Exception("Text length too long to convert to felt.")

            return int.from_bytes(text.encode(), "big")

        # Declare the 3 mock initializable implementations
        context.mock_initializable_v1 = declare("./contracts/mocks/mock_initializable_implementation.cairo").class_hash
        context.mock_initializable_v2 = declare("./contracts/mocks/mock_initializable_implementation_v2.cairo").class_hash
        context.mock_initializable_reentrant = declare("./contracts/mocks/mock_initializable_reentrant.cairo").class_hash

        # Deploy proxy with initializable_v1 as implementation
        # TODO use InitializableImmutableAdminUpgradeabilityProxy when implemented
        context.proxy = deploy_contract("./tests/contracts/mock_aave_upgradeable_proxy.cairo",{"proxy_admin":ids.deployer,"implementation_hash":context.mock_initializable_v1}).contract_address

        context.deployer = ids.deployer
        ids.proxy_address = context.proxy
    %}
    IMockInitializableImplementation.initialize(proxy_address, INIT_VALUE, INIT_TEXT)
    return ()
end

#
# VersionedInitializable tests
#

@external
func test_reentrant{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    const init_value = 1
    const final_value = 2
    MockInitializableReentrant.initialize(init_value)
    let (value) = MockInitializableImplementation.get_value()
    with_attr error_message("value is not {final_value}"):
        assert value = final_value
    end
    return ()
end

@external
func test_initialize_when_already_initialized{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    MockInitializableImplementation.initialize(INIT_VALUE, INIT_TEXT)
    %{ expect_revert(error_message="Contract instance has already been initialized") %}
    MockInitializableImplementation.initialize(INIT_VALUE, INIT_TEXT)
    return ()
end

#
# InitializableImmutableAdminUpgradeabilityProxy tests
#

@external
func test_initialize_impl_version_is_correct{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    alloc_locals
    local impl_address
    %{ ids.impl_address = context.proxy %}
    let (revision) = IMockInitializableImplementation.get_revision(impl_address)
    assert revision = 1
    return ()
end

@external
func test_initialize_impl_initialization_is_correct{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    alloc_locals
    local impl_address
    %{ ids.impl_address = context.proxy %}
    let (value) = IMockInitializableImplementation.get_value(impl_address)
    let (text) = IMockInitializableImplementation.get_text(impl_address)

    assert value = INIT_VALUE
    assert text = INIT_TEXT
    return ()
end

@external
func test_initialize_from_non_admin_when_already_initialized{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    alloc_locals
    local impl_address
    %{
        ids.impl_address = context.proxy 
        expect_revert(error_message="Contract instance has already been initialized")
    %}
    IMockInitializableImplementation.initialize(impl_address, INIT_VALUE, INIT_TEXT)
    return ()
end

@external
func test_upgrade_to_new_impl_from_admin{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    alloc_locals
    local proxy_address
    local new_impl
    %{
        ids.proxy_address = context.proxy
        ids.new_impl = context.mock_initializable_v2
    %}

    # Upgrade from v1 to v2
    IBasicProxyImpl.upgrade(proxy_address, new_impl)
    IMockInitializableImplementation.initialize(proxy_address, 20, 100)
    let (value) = IMockInitializableImplementation.get_value(proxy_address)
    let (text) = IMockInitializableImplementation.get_text(proxy_address)
    assert value = 20
    assert text = 100

    # Should fail because we already initialized v2
    IBasicProxyImpl.upgrade(proxy_address, new_impl)
    %{ expect_revert(error_message="Contract instance has already been initialized") %}
    IMockInitializableImplementation.initialize(proxy_address, 30, 100)
    return ()
end
