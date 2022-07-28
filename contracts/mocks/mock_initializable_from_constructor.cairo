%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

from contracts.protocol.libraries.aave_upgradeability.versioned_initializable_library import (
    VersionedInitializable,
)

const REVISION = 2

@storage_var
func value() -> (val : felt):
end

@constructor
func constructor():
    # TODO
    return ()
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

@external
func initialize{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    val : felt, txt : felt
):
    VersionedInitializable.set_revision(REVISION)
    let (is_top_level_call) = VersionedInitializable._before_initialize()
    value.write(val)
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
