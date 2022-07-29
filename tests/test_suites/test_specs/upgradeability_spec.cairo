%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

from contracts.mocks.i_mock_initializable_implementation import (
    IMockInitializableImplementation,
    IMockInitializableReentrantImplementation,
)
from contracts.mocks.mock_initializable_implementation_library import (
    MockInitializableImplementation,
)
from tests.interfaces.i_mock_aave_upgradeable_proxy import IMockAaveUpgradeableProxy
from tests.utils.constants import USER_1

const INIT_VALUE = 10
const INIT_TEXT = 'text'

#
# VersionedInitializable tests
#

namespace TestVersionedInitializable:
    func test_initialize_when_already_initialized{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        MockInitializableImplementation.initialize(INIT_VALUE, INIT_TEXT)
        %{ expect_revert(error_message="Contract instance has already been initialized") %}
        MockInitializableImplementation.initialize(INIT_VALUE, INIT_TEXT)
        return ()
    end
end

#
# InitializableImmutableAdminUpgradeabilityProxy tests
#
namespace TestInitializableImmutableAdminUpgradeabilityProxy:
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

    func test_initialize_from_non_admin_when_already_initialized{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        local impl_address
        %{
            ids.impl_address = context.proxy
            start_prank = start_prank(ids.USER_1,target_contract_address=context.proxy) )
            expect_revert(error_message="Contract instance has already been initialized")
        %}
        IMockInitializableImplementation.initialize(impl_address, INIT_VALUE, INIT_TEXT)
        return ()
    end

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
        IMockAaveUpgradeableProxy.upgrade(proxy_address, new_impl)
        let (value) = IMockInitializableImplementation.get_value(proxy_address)
        assert value = 10  # Verify that stored value hasn't changed

        # Initialize implementation v2 should suceed with new values
        IMockInitializableImplementation.initialize(proxy_address, 20, 'new text')
        let (value) = IMockInitializableImplementation.get_value(proxy_address)
        let (text) = IMockInitializableImplementation.get_text(proxy_address)
        assert value = 20
        assert text = 'new text'

        # This initialize fail because we already initialized v2
        IMockAaveUpgradeableProxy.upgrade(proxy_address, new_impl)
        %{ expect_revert(error_message="Contract instance has already been initialized") %}
        IMockInitializableImplementation.initialize(proxy_address, 30, 100)
        return ()
    end

    # TODO further testing is required when InitializableImmutableAdminUpgradeabilityProxy is implemented
end
