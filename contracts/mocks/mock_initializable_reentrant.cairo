%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math_cmp import is_le
from contracts.protocol.libraries.aave_upgradeability.versioned_initializable_library import (
    VersionedInitializable,
)

const REVISION = 2

@storage_var
func value() -> (val : felt):
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
func initialize{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(val : felt):
    alloc_locals
    VersionedInitializable.set_revision(REVISION)
    let (is_top_level_call) = VersionedInitializable._before_initialize()
    value.write(val)
    let (is_value_gt_2) = is_le(3, val)
    if is_value_gt_2 == 1:
        initialize(val + 1)
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    else:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    end
    VersionedInitializable._after_initialize(is_top_level_call)
    return ()
end
