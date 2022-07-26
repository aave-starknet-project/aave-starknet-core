%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero
from starkware.starknet.common.syscalls import library_call_l1_handler, library_call
from starkware.cairo.common.bool import TRUE, FALSE

from contracts.protocol.libraries.aave_upgradeability.proxy_library import Proxy

#
# Constructor
#

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    proxy_admin : felt
):
    with_attr error_message("Proxy: proxy admin address should be non zero."):
        assert_not_zero(proxy_admin)
    end
    Proxy._set_admin(proxy_admin)
    return ()
end

@external
func initialize{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    class_hash : felt, selector : felt, calldata_len : felt, calldata : felt*
) -> (retdata_len : felt, retdata : felt*):
    Proxy.assert_only_admin()
    let (is_initialized) = Proxy.is_initialized()

    with_attr error_message("Already initialized"):
        assert is_initialized = FALSE
    end
    Proxy._set_is_initialized(TRUE)
    # set implementation
    Proxy._set_implementation_hash(class_hash)

    let (retdata_len : felt, retdata : felt*) = library_call(
        class_hash=class_hash,
        function_selector=selector,
        calldata_size=calldata_len,
        calldata=calldata,
    )

    return (retdata_len=retdata_len, retdata=retdata)
end

@external
func upgrade_to_and_call{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    class_hash : felt, selector : felt, calldata_len : felt, calldata : felt*
) -> (retdata_len : felt, retdata : felt*):
    Proxy.assert_only_admin()
    # set implementation
    Proxy._set_implementation_hash(class_hash)

    # library_call
    let (retdata_len : felt, retdata : felt*) = library_call(
        class_hash=class_hash,
        function_selector=selector,
        calldata_size=calldata_len,
        calldata=calldata,
    )

    return (retdata_len=retdata_len, retdata=retdata)
end

#
# Getters
#

@view
func get_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    admin : felt
):
    let (admin) = Proxy.get_admin()
    return (admin)
end

@view
func get_implementation{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    implementation : felt
):
    let (implementation) = Proxy.get_implementation_hash()
    return (implementation)
end

#
# Setters
#

@external
func change_proxy_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    new_admin : felt
):
    Proxy.assert_only_admin()
    with_attr error_message("Proxy: new admin address should be non zero."):
        assert_not_zero(new_admin)
    end

    Proxy._set_admin(new_admin)

    return ()
end

#
# Fallback functions
#

@external
@raw_input
@raw_output
func __default__{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    selector : felt, calldata_size : felt, calldata : felt*
) -> (retdata_size : felt, retdata : felt*):
    let (class_hash) = Proxy.get_implementation_hash()
    with_attr error_message("Proxy: does not have a class hash."):
        assert_not_zero(class_hash)
    end

    let (retdata_size : felt, retdata : felt*) = library_call(
        class_hash=class_hash,
        function_selector=selector,
        calldata_size=calldata_size,
        calldata=calldata,
    )

    return (retdata_size=retdata_size, retdata=retdata)
end

@l1_handler
@raw_input
func __l1_default__{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    selector : felt, calldata_size : felt, calldata : felt*
):
    let (class_hash) = Proxy.get_implementation_hash()
    with_attr error_message("Proxy: does not have a class hash."):
        assert_not_zero(class_hash)
    end

    library_call_l1_handler(
        class_hash=class_hash,
        function_selector=selector,
        calldata_size=calldata_size,
        calldata=calldata,
    )

    return ()
end
