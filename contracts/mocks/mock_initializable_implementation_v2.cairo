%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

from contracts.protocol.libraries.aave_upgradeability.versioned_initializable_library import (
    VersionedInitializable,
)

const REVISION = 1

@storage_var
func value() -> (val : felt):
end

@storage_var
func text() -> (txt : felt):
end

@storage_var
func values(index : felt) -> (val : felt):
end

@view
func get_revision{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    revision : felt
):
    return VersionedInitializable.get_revision()
end

@view
func get_value{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    value : felt
):
    let (val) = value.read()
    return (val)
end

@view
func get_text{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (text : felt):
    let (txt) = text.read()
    return (txt)
end

@external
func initialize{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    val : felt, txt : felt
):
    VersionedInitializable.set_revision(REVISION)
    let (is_top_level_call) = VersionedInitializable._before_initialize()
    value.write(val)
    text.write(txt)
    VersionedInitializable._after_initialize(is_top_level_call)
    return ()
end

@external
func set_value{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(new_value : felt):
    value.write(new_value)
    return ()
end

@external
func set_value_via_proxy{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    new_value : felt
):
    value.write(new_value)
    return ()
end
