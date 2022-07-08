%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math_cmp import is_not_zero
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import (
    assert_lt,
    assert_not_zero,
    assert_in_range,
    assert_not_equal,
)

namespace ReserveIndex:
    func add_reserve_index{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        type : felt, user_address : felt, index : felt
    ):
        alloc_locals

        assert_in_range(type, 0, 2)
        assert_not_zero(user_address)
        assert_not_zero(index)

        add_reserve_index_internal(type, 1, user_address, index)

        return ()
    end

    func add_reserve_index_internal{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(type : felt, id : felt, user_address : felt, index : felt):
        alloc_locals

        let (current_index) = get_reserve_index(type, id, user_address)

        let (is_current_index_not_zero) = is_not_zero(current_index)

        if is_current_index_not_zero == FALSE:
            # with_attr error_message("Invalid index: doubling index for the same type of reserve."):
            #     assert_not_equal(current_index, index)
            # end

            ReserveIndex_index.write(type, id, user_address, index)

            return ()
        else:
            add_reserve_index_internal(type, id + 1, user_address, index)
        end

        return ()
    end

    # @dev no possible infinite recursion, since existance of given reserve index is checked before - in UserConfiguration::set_borrowing or UserConfiguration::set_using_as_collateral
    func remove_reserve_index{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        type : felt, user_address : felt, index : felt
    ):
        alloc_locals

        assert_in_range(type, 0, 2)
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
end

# type = 1 -> borrowing
# type = 2 -> collateral
@storage_var
func ReserveIndex_index(type : felt, id : felt, user_address : felt) -> (index : felt):
end
