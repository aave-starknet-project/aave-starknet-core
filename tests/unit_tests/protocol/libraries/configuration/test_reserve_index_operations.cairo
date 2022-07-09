%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math_cmp import is_not_zero
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import assert_lt, assert_not_zero
from contracts.protocol.libraries.configuration.reserve_index_operations import ReserveIndex

const USER_ADDRESS = 123456

@external
func test_is_empty_list{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # 1
    let (res) = ReserveIndex.is_list_empty(1, USER_ADDRESS)
    assert res = TRUE

    # 2
    ReserveIndex.add_reserve_index(1, USER_ADDRESS, 10)
    let (res) = ReserveIndex.is_list_empty(1, USER_ADDRESS)
    assert res = FALSE

    # 2
    ReserveIndex.add_reserve_index(2, USER_ADDRESS, 10)
    let (res) = ReserveIndex.is_list_empty(2, USER_ADDRESS)
    assert res = FALSE

    return ()
end

@external
func test_is_only_one_element{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # 1
    let (res) = ReserveIndex.is_only_one_element(1, USER_ADDRESS)
    assert res = FALSE

    # 2
    ReserveIndex.add_reserve_index(1, USER_ADDRESS, 10)
    let (res) = ReserveIndex.is_only_one_element(1, USER_ADDRESS)
    assert res = TRUE

    # 3
    ReserveIndex.add_reserve_index(1, USER_ADDRESS, 20)
    let (res) = ReserveIndex.is_only_one_element(1, USER_ADDRESS)
    assert res = FALSE

    # 3
    ReserveIndex.add_reserve_index(2, USER_ADDRESS, 20)
    let (res) = ReserveIndex.is_only_one_element(2, USER_ADDRESS)
    assert res = TRUE

    return ()
end

@external
func test_set_reserve_index_borrowing{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    # slot: 1, value: 10
    ReserveIndex.add_reserve_index(1, USER_ADDRESS, 10)

    let (res) = ReserveIndex.get_reserve_index(1, 1, USER_ADDRESS)

    assert res = 10

    # slot: 2, value: 20
    ReserveIndex.add_reserve_index(1, USER_ADDRESS, 20)

    let (res) = ReserveIndex.get_reserve_index(1, 2, USER_ADDRESS)

    assert res = 20

    # slot: 3, value: 30
    ReserveIndex.add_reserve_index(1, USER_ADDRESS, 30)

    let (res) = ReserveIndex.get_reserve_index(1, 3, USER_ADDRESS)

    assert res = 30

    # slot: 4, value: 40
    ReserveIndex.add_reserve_index(1, USER_ADDRESS, 40)

    let (res) = ReserveIndex.get_reserve_index(1, 4, USER_ADDRESS)

    assert res = 40

    # remove index 20
    # -> copy value from the last slot to the one we are removing value from
    # -> remove value of last slot
    ReserveIndex.remove_reserve_index(1, USER_ADDRESS, 20)

    let (res) = ReserveIndex.get_reserve_index(1, 4, USER_ADDRESS)

    assert res = 0

    let (res) = ReserveIndex.get_reserve_index(1, 2, USER_ADDRESS)

    assert res = 40

    let (res) = ReserveIndex.get_reserve_index(1, 3, USER_ADDRESS)

    assert res = 30

    # remove non-existing index 2137
    # -> should not go into infinite recursion
    # -> should return after traversing every slot and not finding 2137
    # -> should leave all slots as they were
    ReserveIndex.remove_reserve_index(1, USER_ADDRESS, 2137)

    let (res) = ReserveIndex.get_reserve_index(1, 1, USER_ADDRESS)

    assert res = 10

    let (res) = ReserveIndex.get_reserve_index(1, 2, USER_ADDRESS)

    assert res = 40

    let (res) = ReserveIndex.get_reserve_index(1, 3, USER_ADDRESS)

    assert res = 30

    let (res) = ReserveIndex.get_reserve_index(1, 4, USER_ADDRESS)

    assert res = 0

    return ()
end

@external
func test_get_lowest_reserve_index{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    # 1
    ReserveIndex.add_reserve_index(1, USER_ADDRESS, 10)
    ReserveIndex.add_reserve_index(1, USER_ADDRESS, 20)
    ReserveIndex.add_reserve_index(1, USER_ADDRESS, 30)

    let (res) = ReserveIndex.get_lowest_reserve_index(1, USER_ADDRESS)
    assert res = 10

    # 2
    ReserveIndex.add_reserve_index(1, USER_ADDRESS, 5)

    let (res) = ReserveIndex.get_lowest_reserve_index(1, USER_ADDRESS)
    assert res = 5

    return ()
end
