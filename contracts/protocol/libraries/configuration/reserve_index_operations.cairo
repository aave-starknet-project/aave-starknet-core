%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math_cmp import is_not_zero, is_le
from starkware.cairo.common.bool import TRUE, FALSE
from contracts.protocol.libraries.helpers.bool_cmp import BoolCompare
from starkware.cairo.common.math import (
    assert_lt,
    assert_not_zero,
    assert_in_range,
    assert_not_equal,
    assert_le,
)

# type = 1 -> borrowing
# type = 2 -> collateral
# @notice Stores indices of reserve assets in a packed list
# @dev using prefix UserConfiguration to prevent storage variable clashing
@storage_var
func ReserveIndex_index(type : felt, slot : felt, user_address : felt) -> (index : felt):
end

const BORROWING_TYPE = 1
const USING_AS_COLLATERAL_TYPE = 2
# @notice Packed list to store reserve indices in slots represented as 'id'
namespace ReserveIndex:
    const MAX_RESERVES_COUNT = 128
    # @notice Adds reserve index at the end of the list in ReserveIndex_index
    # @dev Elements in list can reoccur, but it is prohibited in user_configuration
    # @param  type Type of reserve asset: BORROWING_TYPE or USING_AS_COLLATERAL_TYPE
    func add_reserve_index{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        type : felt, user_address : felt, index : felt
    ):
        alloc_locals

        let (last_element_slot, last_index) = get_last_slot(type, 0, user_address)

        if last_index == 0:
            ReserveIndex_index.write(type, 0, user_address, index)
        else:
            ReserveIndex_index.write(type, last_element_slot + 1, user_address, index)
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
        type : felt, slot : felt, user_address : felt, index : felt
    ):
        alloc_locals

        let (current_index) = get_reserve_index(type, slot, user_address)
        # if list is empty do nothing
        if current_index == 0:
            return ()
        end

        let (last_element_slot, last_index) = get_last_slot(type, 0, user_address)

        if current_index == index:
            ReserveIndex_index.write(type, slot, user_address, last_index)
            ReserveIndex_index.write(type, last_element_slot, user_address, 0)
            return ()
        else:
            remove_reserve_index(type, slot + 1, user_address, index)
        end

        return ()
    end
    # @notice Returns reserve index of given type, slot and user address
    # @param  type Type of reserve asset: BORROWING_TYPE or USING_AS_COLLATERAL_TYPE
    # @param slot Number representing slot in the list
    # @param user_address The address of a user
    # @return index Reserve index of given type, slot and user address
    func get_reserve_index{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        type : felt, slot : felt, user_address : felt
    ) -> (index : felt):
        let (index : felt) = ReserveIndex_index.read(type, slot, user_address)

        return (index)
    end
    # @notice Checks is list of given slot and user address is empty
    # @param  type Type of reserve asset: BORROWING_TYPE or USING_AS_COLLATERAL_TYPE
    # @param user_address The address of a user
    # @return res TRUE if list is empty, FALSE otherwise
    func is_list_empty{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        type : felt, user_address : felt
    ) -> (res : felt):
        let (index) = get_reserve_index(type, 0, user_address)

        if index == 0:
            return (TRUE)
        else:
            return (FALSE)
        end
    end
    # @notice Checks if list of given slot and user address has only one element
    # @param  type Type of reserve asset: BORROWING_TYPE or USING_AS_COLLATERAL_TYPE
    # @param user_address The address of a user
    # @return res TRUE if list has only one element, FALSE otherwise
    func is_only_one_element{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        type : felt, user_address : felt
    ) -> (res : felt):
        alloc_locals

        let (first_index) = get_reserve_index(type, 0, user_address)

        if first_index == 0:
            return (FALSE)
        end

        let (last_slot, last_index) = get_last_slot(type, 0, user_address)

        if first_index == last_index:
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

        let (first_index) = get_reserve_index(type, 0, user_address)

        let (lowest_index) = get_lowest_reserve_index_internal(type, 1, user_address, first_index)

        return (lowest_index)
    end
    # @notice Internal recursive function to get_lowest_reserve_index
    # @dev there can't be draw, because no two same indexes can't be added - unique values restricted in user_configuration
    # @param  type Type of reserve asset: BORROWING_TYPE or USING_AS_COLLATERAL_TYPE
    # @param slot Number representing slot in the list
    # @param user_address The address of a user
    # @param last_lowest_index Last lowest reserve index
    # @return index Reserve index with the lowest value
    func get_lowest_reserve_index_internal{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(type : felt, slot : felt, user_address : felt, last_lowest_index : felt) -> (
        lowest_index : felt
    ):
        alloc_locals

        local index_to_next_function

        let (current_index) = get_reserve_index(type, slot, user_address)

        if current_index == 0:
            return (last_lowest_index)
        end

        let (last_is_smaller) = is_le(last_lowest_index, current_index)
        if last_is_smaller == TRUE:
            index_to_next_function = last_lowest_index
        else:
            index_to_next_function = current_index
        end

        let (lowest_index) = get_lowest_reserve_index_internal(
            type, slot + 1, user_address, index_to_next_function
        )

        return (lowest_index)
    end

    func get_last_slot{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        type : felt, slot : felt, user_address : felt
    ) -> (slot : felt, index : felt):
        alloc_locals

        let (current_index) = get_reserve_index(type, slot, user_address)

        let (next_index) = get_reserve_index(type, slot + 1, user_address)

        if next_index == 0:
            return (slot, current_index)
        end

        let (res_slot, res_index) = get_last_slot(type, slot + 1, user_address)

        return (res_slot, res_index)
    end
end
