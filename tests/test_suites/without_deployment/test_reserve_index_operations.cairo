%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from tests.test_suites.test_specs.reserve_index_operations_spec import TestReserveIndexOperations

@external
func test_is_empty_list{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    TestReserveIndexOperations.test_is_empty_list()
    return ()
end

@external
func test_is_only_one_element{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    TestReserveIndexOperations.test_is_only_one_element()
    return ()
end

@external
func test_add_remove_reserve_index_borrowing{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestReserveIndexOperations.test_add_remove_reserve_index_borrowing()
    return ()
end

@external
func test_add_remove_reserve_index_using_as_collateral{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestReserveIndexOperations.test_add_remove_reserve_index_using_as_collateral()
    return ()
end

@external
func test_get_lowest_reserve_index{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestReserveIndexOperations.test_get_lowest_reserve_index()
    return ()
end
