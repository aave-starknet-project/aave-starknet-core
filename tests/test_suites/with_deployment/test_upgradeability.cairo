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

        #declare class implementation of basic_proxy_impl
        context.mock_initializable_v1 = declare("./contracts/mocks/mock_initializable_implementation.cairo").class_hash
        context.mock_initializable_v2 = declare("./contracts/mocks/mock_initializable_implementation_v2.cairo").class_hash
        # context.mock_initializable_constructor = declare("./contracts/mocks/mock_initializable_from_constructor.cairo").class_hash
        context.mock_initializable_reentrant = declare("./contracts/mocks/mock_initializable_reentrant.cairo").class_hash

        # declare proxy_class_hash so that starknet knows about it. It's required to deploy proxies from PoolAddressesProvider
        # declared_proxy = declare("./lib/cairo_contracts/src/openzeppelin/upgrades/Proxy.cairo")
        # context.proxy_class_hash = declared_proxy.class_hash
        # deploy OZ proxy contract, admin is deployer. Implementation hash is basic_proxy_impl upon deployment.
        # prepared_proxy = prepare(declared_proxy,{"implementation_hash":context.mock_initializable_v1})
        context.proxy = deploy_contract("./tests/contracts/basic_proxy_impl.cairo",{"proxy_admin":ids.deployer,"implementation_hash":context.mock_initializable_v1}).contract_address

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
func test_upgrade_from_non_admin_when_already_initialized{
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
