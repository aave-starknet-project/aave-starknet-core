%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.bool import TRUE, FALSE

from contracts.protocol.libraries.helpers.bool_cmp import BoolCompare

@storage_var
func VersionedInitializable_last_initialized_revision() -> (revision : felt):
end

@storage_var
func VersionedInitializable_initializing() -> (boolean : felt):
end

namespace VersionedInitializable:
    func _before_initialize{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        current_revision
    ) -> (is_top_level_call : felt):
        alloc_locals
        let (last_revision) = VersionedInitializable_last_initialized_revision.read()
        let (initializing) = VersionedInitializable_initializing.read()
        let (is_current_revision_gt_last) = is_le(last_revision, current_revision - 1)

        with_attr error_message("Contract instance has already been initialized"):
            let (initializing_or_revision_gt_last) = BoolCompare.either(
                initializing, is_current_revision_gt_last
            )
            assert initializing_or_revision_gt_last = TRUE
        end

        let (is_top_level_call) = BoolCompare.not(initializing)

        if is_top_level_call == TRUE:
            VersionedInitializable_initializing.write(TRUE)
            VersionedInitializable_last_initialized_revision.write(current_revision)
            return (is_top_level_call)
        end

        return (is_top_level_call)
    end

    func _after_initialize{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        is_top_level_call : felt
    ) -> ():
        BoolCompare.is_valid(is_top_level_call)
        if is_top_level_call == TRUE:
            VersionedInitializable_initializing.write(FALSE)
            return ()
        end
        return ()
    end
end
