%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math_cmp import is_not_zero
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import assert_lt, assert_not_zero
from contracts.protocol.libraries.configuration.reserve_index_operations import ReserveIndex

@external
func test_set_reserve_index_borrowing{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    # slot: 1, value: 10
    ReserveIndex.add_reserve_index(1, 123456, 10)

    let (res) = ReserveIndex.get_reserve_index(1, 1, 123456)

    assert res = 10

    # slot: 2, value: 20
    ReserveIndex.add_reserve_index(1, 123456, 20)

    let (res) = ReserveIndex.get_reserve_index(1, 2, 123456)

    assert res = 20

    # slot: 3, value: 30
    ReserveIndex.add_reserve_index(1, 123456, 30)

    let (res) = ReserveIndex.get_reserve_index(1, 3, 123456)

    assert res = 30

    # remove index 20
    ReserveIndex.remove_reserve_index(1, 123456, 20)

    let (res) = ReserveIndex.get_reserve_index(1, 3, 123456)

    assert res = 0

    let (res) = ReserveIndex.get_reserve_index(1, 2, 123456)

    assert res = 30

    return ()
end
