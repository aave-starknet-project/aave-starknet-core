%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from tests.test_suites.test_specs.user_configuration_spec import TestUserConfiguration

@external
func test_set_borrowing_and_is_borrowing{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestUserConfiguration.test_set_borrowing_and_is_borrowing()
    return ()
end

@external
func test_set_using_as_collateral_and_is_using_as_collateral{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestUserConfiguration.test_set_using_as_collateral_and_is_using_as_collateral()
    return ()
end

@external
func test_is_using_as_collateral_or_borrowing{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestUserConfiguration.test_is_using_as_collateral_or_borrowing()
    return ()
end

@external
func test_is_using_as_collateral_one{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestUserConfiguration.test_is_using_as_collateral_one()
    return ()
end

@external
func test_is_using_as_collateral_any{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestUserConfiguration.test_is_using_as_collateral_any()
    return ()
end

@external
func test_is_borrowing_one{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    TestUserConfiguration.test_is_borrowing_one()
    return ()
end

@external
func test_is_borrowing_any{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    TestUserConfiguration.test_is_borrowing_any()
    return ()
end

@external
func test_is_empty{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    TestUserConfiguration.test_is_empty()
    return ()
end

@external
func test_get_first_asset_by_type{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestUserConfiguration.test_get_first_asset_by_type()
    return ()
end
