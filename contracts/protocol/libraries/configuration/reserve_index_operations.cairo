%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math_cmp import is_not_zero, is_le
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import (
    assert_lt,
    assert_not_zero,
    assert_in_range,
    assert_not_equal,
)

# type = 1 -> borrowing
# type = 2 -> collateral
@storage_var
func ReserveIndex_index(type : felt, id : felt, user_address : felt) -> (index : felt):
end

const BORROWING_TYPE = 1
const USING_AS_COLLATERAL_TYPE = 2

namespace ReserveIndex:
    func add_reserve_index{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        type : felt, user_address : felt, index : felt
    ):
        alloc_locals

        assert_in_range(type, 1, 3)
        assert_not_zero(user_address)
        assert_not_zero(index)

        add_reserve_index_internal(type, 1, user_address, index)

        return ()
    end
    # TODO: check if index is already in list, to make list unique
    func add_reserve_index_internal{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(type : felt, id : felt, user_address : felt, index : felt):
        alloc_locals

        # assert_index_not_exists(type, id, user_address, index)

        let (current_index) = get_reserve_index(type, id, user_address)

        let (is_current_index_not_zero) = is_not_zero(current_index)

        if is_current_index_not_zero == FALSE:
            ReserveIndex_index.write(type, id, user_address, index)
            return ()
        else:
            add_reserve_index_internal(type, id + 1, user_address, index)
        end

        return ()
    end

    # func assert_index_not_exists{
    #     syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    # }(type : felt, id : felt, user_address : felt, index : felt):

    # let (next_index) = get_reserve_index(type, id + 1, user_address)

    # with_attr error_message("Invalid index: doubling index for the same type of reserve."):
    #         assert_not_equal(index, next_index)
    #     end

    # if next_index == 0:
    #         return ()
    #     end

    # assert_index_not_exists(type, id + 1, user_address, index)

    # return ()
    # end

    # @dev no possible infinite recursion, since existance of given reserve index is checked before - in UserConfiguration::set_borrowing or UserConfiguration::set_using_as_collateral
    func remove_reserve_index{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        type : felt, user_address : felt, index : felt
    ):
        alloc_locals

        assert_in_range(type, 1, 3)
        assert_not_zero(user_address)
        assert_not_zero(index)

        remove_reserve_index_internal(type, 1, user_address, index)

        return ()
    end

    func remove_reserve_index_internal{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(type : felt, id : felt, user_address : felt, index : felt):
        alloc_locals

        let (current_index) = get_reserve_index(type, id, user_address)

        if current_index == 0:
            return ()
        end

        if current_index == index:
            ReserveIndex_index.write(type, id, user_address, 0)
            after_remove_reserve_index(type, id, user_address)
            return ()
        else:
            remove_reserve_index_internal(type, id + 1, user_address, index)
        end

        return ()
    end

    func after_remove_reserve_index{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(type : felt, id : felt, user_address : felt):
        alloc_locals

        let next_id = id + 1

        let (current_index) = get_reserve_index(type, next_id, user_address)

        let (is_current_index_not_zero) = is_not_zero(current_index)

        if is_current_index_not_zero == FALSE:
            # it is last element of a list, so return
            return ()
        else:
            after_remove_reserve_index_internal(type, id, next_id, user_address)
        end

        return ()
    end

    func after_remove_reserve_index_internal{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(type : felt, origin_id : felt, id : felt, user_address : felt):
        alloc_locals

        let (current_index) = get_reserve_index(type, id, user_address)

        let (next_index) = get_reserve_index(type, id + 1, user_address)

        let (is_next_index_not_zero) = is_not_zero(next_index)

        if is_next_index_not_zero == FALSE:
            # it is the last element of a list, so we copy current element into the orign_id
            ReserveIndex_index.write(type, origin_id, user_address, current_index)
            ReserveIndex_index.write(type, id, user_address, 0)
            return ()
        else:
            after_remove_reserve_index_internal(type, origin_id, id + 1, user_address)
        end

        return ()
    end

    func get_reserve_index{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        type : felt, id : felt, user_address : felt
    ) -> (index : felt):
        let (index : felt) = ReserveIndex_index.read(type, id, user_address)
        return (index)
    end

    # TODO: _one, _any, smallest, is_it_last_index
    func is_list_empty{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        type : felt, user_address : felt
    ) -> (res : felt):
        assert_in_range(type, 1, 3)
        assert_not_zero(user_address)

        let (index) = get_reserve_index(type, 1, user_address)

        if index == 0:
            return (TRUE)
        else:
            return (FALSE)
        end
    end

    func is_only_one_element{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        type : felt, user_address : felt
    ) -> (res : felt):
        alloc_locals

        assert_in_range(type, 1, 3)
        assert_not_zero(user_address)

        let (index) = get_reserve_index(type, 1, user_address)
        let (is_index_not_zero) = is_not_zero(index)

        let (next_index) = get_reserve_index(type, 2, user_address)
        let (is_next_index_not_zero) = is_not_zero(next_index)

        let bool_res = is_index_not_zero + is_next_index_not_zero
        if bool_res == 1:
            return (TRUE)
        else:
            return (FALSE)
        end
    end

    # @dev If list is empty returns 0
    func get_smallest_reserve_index{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(type : felt, user_address : felt) -> (smallest_index : felt):
        alloc_locals

        assert_in_range(type, 1, 3)
        assert_not_zero(user_address)

        let (first_index) = get_reserve_index(type, 1, user_address)

        let (smallest_index) = get_smallest_reserve_index_internal(
            type, 2, user_address, first_index
        )

        return (smallest_index)
    end

    # @dev there can't be draw, because no two same indexes can't be added
    func get_smallest_reserve_index_internal{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(type : felt, id : felt, user_address : felt, last_smallest_index : felt) -> (index : felt):
        alloc_locals

        local index_to_next_function

        let (current_index) = get_reserve_index(type, id, user_address)
        let (is_current_index_not_zero) = is_not_zero(current_index)
        if is_current_index_not_zero == FALSE:
            return (last_smallest_index)
        end

        let (last_is_smaller) = is_le(last_smallest_index, current_index)
        if last_is_smaller == 1:
            index_to_next_function = last_smallest_index
        else:
            index_to_next_function = current_index
        end

        let (smallest_index) = get_smallest_reserve_index_internal(
            type, id + 1, user_address, index_to_next_function
        )

        return (smallest_index)
    end
end
