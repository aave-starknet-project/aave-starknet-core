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
        ) -> (is_top_level_call : felt):
        alloc_locals
        let (last_revision) = VersionedInitializable_last_initialized_revision.read()
        let (current_revision) = get_revision()
        let (initializing) = VersionedInitializable_initializing.read()
        # TODO find a way to detect its usage in a constructor
        let constructor = FALSE
        let (is_current_gt_last) = is_le(last_revision, current_revision - 1)  # is_le(a,b-1) <=> is_lt(a,b)

        with_attr error_message("Contract instance has already been initialized"):
            let (requirement_1) = BoolCompare.either(initializing, constructor)
            let (requirement_2) = BoolCompare.either(initializing, is_current_gt_last)
            let (requirement_final) = BoolCompare.either(requirement_1, requirement_2)
            assert requirement_final = TRUE
        end

        let (is_top_level_call) = BoolCompare.not(initializing)

        if is_top_level_call == TRUE:
            VersionedInitializable_initializing.write(TRUE)
            VersionedInitializable_last_initialized_revision.write(current_revision)
            tempvar syscall_ptr = syscall_ptr
            tempvar pedersen_ptr = pedersen_ptr
            tempvar range_check_ptr = range_check_ptr
        else:
            tempvar syscall_ptr = syscall_ptr
            tempvar pedersen_ptr = pedersen_ptr
            tempvar range_check_ptr = range_check_ptr
        end
        return (is_top_level_call)
    end

    func _after_initialize{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        is_top_level_call : felt
    ) -> ():
        if is_top_level_call == TRUE:
            VersionedInitializable_initializing.write(FALSE)
            return ()
        end
        return ()
    end

    func get_revision{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        revision : felt
    ):
        return (1)
    end

    func is_constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        is_constructor : felt
    ):
        return (0)
    end
end
