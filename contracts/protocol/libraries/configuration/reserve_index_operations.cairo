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
# @notice Stores indices of reserve assets in a packed list
# @dev using prefix UserConfiguration to prevent storage variable clashing
@storage_var
func ReserveIndex_index(type : felt, id : felt, user_address : felt) -> (index : felt):
end

const BORROWING_TYPE = 1
const USING_AS_COLLATERAL_TYPE = 2
# @notice Packed list to store reserve indices in slots represented as 'id'
namespace ReserveIndex:
    # @notice Adds reserve index at the end of the list in ReserveIndex_index
    # @dev Elements in list can reoccur, but it is prohibited in user_configuration
    # @param  type Type of reserve asset: BORROWING_TYPE or USING_AS_COLLATERAL_TYPE
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
    # @notice Internal recursive function to add_reserve_index
    # @param  type Type of reserve asset: BORROWING_TYPE or USING_AS_COLLATERAL_TYPE
    # @param id Number representing slot in the list
    # @param user_address The address of a user
    # @param index The index of the reserve object
    func add_reserve_index_internal{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(type : felt, id : felt, user_address : felt, index : felt):
        alloc_locals

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
    # @notice Removes reserve index the list in ReserveIndex_index, by reserve index not by slot number
    # @dev Moves last element in list to the slot that was removed
    # @dev Not possible infinite recursion of remove_reserve_index, since existance of given reserve index is checked before - in UserConfiguration::set_borrowing or UserConfiguration::set_using_as_collateral
    # @param  type Type of reserve asset: BORROWING_TYPE or USING_AS_COLLATERAL_TYPE
    # @param user_address The address of a user
    # @param index The index of the reserve object
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
    # @notice Internal recursive function to remove_reserve_index
    # @param  type Type of reserve asset: BORROWING_TYPE or USING_AS_COLLATERAL_TYPE
    # @param id Number representing slot in the list
    # @param user_address The address of a user
    # @param index The index of the reserve object
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
    # @notice Moves last element of the list to the slot of removed reserve index
    # @param  type Type of reserve asset: BORROWING_TYPE or USING_AS_COLLATERAL_TYPE
    # @param id Number representing slot in the list
    # @param user_address The address of a user
    func after_remove_reserve_index{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(type : felt, id : felt, user_address : felt):
        alloc_locals

        let next_id = id + 1

        let (current_index) = get_reserve_index(type, next_id, user_address)

        let (is_current_index_not_zero) = is_not_zero(current_index)

        if is_current_index_not_zero == FALSE:
            # it is last element of a list, so do nothing
            return ()
        else:
            after_remove_reserve_index_internal(type, id, next_id, user_address)
        end

        return ()
    end
    # @notice Internal recursive function to after_remove_reserve_index
    # @param  type Type of reserve asset: BORROWING_TYPE or USING_AS_COLLATERAL_TYPE
    # @param origin_id Number representing slot in the list that the value was removed from
    # @param id Number representing current slot in the list
    # @param user_address The address of a user
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
    # @notice Returns reserve index of given type, id and user address
    # @param  type Type of reserve asset: BORROWING_TYPE or USING_AS_COLLATERAL_TYPE
    # @param id Number representing slot in the list
    # @param user_address The address of a user
    # @return index Reserve index of given type, id and user address
    func get_reserve_index{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        type : felt, id : felt, user_address : felt
    ) -> (index : felt):
        let (index : felt) = ReserveIndex_index.read(type, id, user_address)
        return (index)
    end
    # @notice Checks is list of given id and user address is empty
    # @param  type Type of reserve asset: BORROWING_TYPE or USING_AS_COLLATERAL_TYPE
    # @param user_address The address of a user
    # @return res TRUE if list is empty, FALSE otherwise
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
    # @notice Checks if list of given id and user address has only one element
    # @param  type Type of reserve asset: BORROWING_TYPE or USING_AS_COLLATERAL_TYPE
    # @param user_address The address of a user
    # @return res TRUE if list has only one element, FALSE otherwise
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
    # @notice Returns reserve index with the lowest value
    # @dev If list is empty returns 0
    # @param  type Type of reserve asset: BORROWING_TYPE or USING_AS_COLLATERAL_TYPE
    # @param user_address The address of a user
    # @return lowest_index Reserve index with the lowest value
    func get_lowest_reserve_index{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(type : felt, user_address : felt) -> (lowest_index : felt):
        alloc_locals

        assert_in_range(type, 1, 3)
        assert_not_zero(user_address)

        let (first_index) = get_reserve_index(type, 1, user_address)

        let (lowest_index) = get_lowest_reserve_index_internal(type, 2, user_address, first_index)

        return (lowest_index)
    end
    # @notice Internal recursive function to get_lowest_reserve_index
    # @dev there can't be draw, because no two same indexes can't be added - unique values restricted in user_configuration
    # @param  type Type of reserve asset: BORROWING_TYPE or USING_AS_COLLATERAL_TYPE
    # @param id Number representing slot in the list
    # @param user_address The address of a user
    # @param last_lowest_index Last lowest reserve index
    # @return index Reserve index with the lowest value
    func get_lowest_reserve_index_internal{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(type : felt, id : felt, user_address : felt, last_lowest_index : felt) -> (index : felt):
        alloc_locals

        local index_to_next_function

        let (current_index) = get_reserve_index(type, id, user_address)
        let (is_current_index_not_zero) = is_not_zero(current_index)
        if is_current_index_not_zero == FALSE:
            return (last_lowest_index)
        end

        let (last_is_smaller) = is_le(last_lowest_index, current_index)
        if last_is_smaller == 1:
            index_to_next_function = last_lowest_index
        else:
            index_to_next_function = current_index
        end

        let (lowest_index) = get_lowest_reserve_index_internal(
            type, id + 1, user_address, index_to_next_function
        )

        return (lowest_index)
    end
end
