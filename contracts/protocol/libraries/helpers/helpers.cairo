from starkware.cairo.common.math_cmp import is_not_zero
from starkware.cairo.common.memcpy import memcpy
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math import assert_lt
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_sub, uint256_lt, uint256_check
# Returns 0 if value != 0. Returns 1 otherwise.
func is_zero(value) -> (res : felt):
    let (res) = is_not_zero(value)
    return (1 - res)
end

# @notice Modifies a struct by replacing a member with the specified value.
# @param struct_fields a pointer to the original struct struc
# @param struct_size size of the struct
# @param member_value value of the member to be replaced
# @param member_index index of the member to be replaced
func update_struct{range_check_ptr}(
    struct_fields : felt*, struct_size : felt, member_value_ptr : felt*, member_index : felt
) -> (modified_struct : felt*):
    alloc_locals
    assert_lt(member_index, struct_size)
    let (local res : felt*) = alloc()

    memcpy(res, struct_fields, member_index)  # copy member_index elems from struct_fields to res
    memcpy(res + member_index, member_value_ptr, 1)  # store member_value at memory cell [res+member_index]
    memcpy(res + member_index + 1, struct_fields + member_index + 1, struct_size - member_index - 1)  # copy the rest of the struct_fields to res

    # _modify_struct(struct_fields, struct_size, member_value, member_index, res, 0)
    return (res)
end

func uint256_checked_sub_return_zero_when_lt{
    range_check_ptr
}(a : Uint256, b : Uint256) -> (c : Uint256):
    alloc_locals
    uint256_check(a)
    uint256_check(b)

    let (is_lt) = uint256_lt(a, b)
    if is_lt == 1:
        return (Uint256(0, 0))
    end
    let (c : Uint256) = uint256_sub(a, b)
    return (c)
end
