%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from contracts.protocol.libraries.configuration.user_configuration import UserConfiguration

const TEST_ADDRESS = 4812950810879290
const TEST_ADDRESS2 = 5832954280734189
const TEST_ADDRESS3 = 2137213721372137
const TEST_ADDRESS4 = 7372187518950897

@external
func test_set_borrowing_and_is_borrowing{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    UserConfiguration.set_borrowing(TEST_ADDRESS, 1, TRUE)

    let (bor) = UserConfiguration.is_borrowing(TEST_ADDRESS, 1)
    assert bor = TRUE

    let (bor) = UserConfiguration.is_borrowing(TEST_ADDRESS, 2)
    assert bor = FALSE

    let (bor) = UserConfiguration.is_borrowing(TEST_ADDRESS2, 1)
    assert bor = FALSE

    return ()
end

@external
func test_set_using_as_collateral_and_is_using_as_collateral{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    UserConfiguration.set_using_as_collateral(TEST_ADDRESS, 1, TRUE)

    let (col) = UserConfiguration.is_using_as_collateral(TEST_ADDRESS, 1)
    assert col = TRUE

    let (col) = UserConfiguration.is_using_as_collateral(TEST_ADDRESS, 2)
    assert col = FALSE

    let (col) = UserConfiguration.is_using_as_collateral(TEST_ADDRESS2, 1)
    assert col = FALSE

    return ()
end

@external
func test_is_using_as_collateral_or_borrowing{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    # 1
    UserConfiguration.set_using_as_collateral(TEST_ADDRESS, 1, TRUE)
    UserConfiguration.set_borrowing(TEST_ADDRESS, 1, TRUE)

    let (res) = UserConfiguration.is_using_as_collateral_or_borrowing(TEST_ADDRESS, 1)
    assert res = TRUE

    # 2
    UserConfiguration.set_using_as_collateral(TEST_ADDRESS2, 1, TRUE)
    let (res) = UserConfiguration.is_using_as_collateral_or_borrowing(TEST_ADDRESS2, 1)
    assert res = TRUE

    # 3
    UserConfiguration.set_borrowing(TEST_ADDRESS3, 1, TRUE)
    let (res) = UserConfiguration.is_using_as_collateral_or_borrowing(TEST_ADDRESS3, 1)
    assert res = TRUE

    # 4
    let (res) = UserConfiguration.is_using_as_collateral_or_borrowing(TEST_ADDRESS4, 1)
    assert res = FALSE

    return ()
end

@external
func test_is_using_as_collateral_one{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    # 1
    UserConfiguration.set_using_as_collateral(TEST_ADDRESS, 1, TRUE)

    let (col) = UserConfiguration.is_using_as_collateral_one(TEST_ADDRESS)
    assert col = TRUE

    # 2
    UserConfiguration.set_using_as_collateral(TEST_ADDRESS2, 1, TRUE)
    UserConfiguration.set_using_as_collateral(TEST_ADDRESS2, 2, TRUE)

    let (col) = UserConfiguration.is_using_as_collateral_one(TEST_ADDRESS2)
    assert col = FALSE

    # 3
    let (col) = UserConfiguration.is_using_as_collateral_one(TEST_ADDRESS3)
    assert col = FALSE

    return ()
end

@external
func test_is_using_as_collateral_any{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    # 1
    UserConfiguration.set_using_as_collateral(TEST_ADDRESS, 1, TRUE)

    let (col) = UserConfiguration.is_using_as_collateral_any(TEST_ADDRESS)
    assert col = TRUE

    # 2
    UserConfiguration.set_using_as_collateral(TEST_ADDRESS2, 1, TRUE)
    UserConfiguration.set_using_as_collateral(TEST_ADDRESS2, 2, TRUE)

    let (col) = UserConfiguration.is_using_as_collateral_any(TEST_ADDRESS2)
    assert col = TRUE

    # 3
    let (col) = UserConfiguration.is_using_as_collateral_any(TEST_ADDRESS3)
    assert col = FALSE

    return ()
end

@external
func test_is_borrowing_one{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # 1
    UserConfiguration.set_borrowing(TEST_ADDRESS, 1, TRUE)

    let (bor) = UserConfiguration.is_borrowing_one(TEST_ADDRESS)
    assert bor = TRUE

    # 2
    UserConfiguration.set_borrowing(TEST_ADDRESS2, 1, TRUE)
    UserConfiguration.set_borrowing(TEST_ADDRESS2, 2, TRUE)

    let (bor) = UserConfiguration.is_borrowing_one(TEST_ADDRESS2)
    assert bor = FALSE

    # 3
    let (bor) = UserConfiguration.is_borrowing_one(TEST_ADDRESS3)
    assert bor = FALSE

    return ()
end

@external
func test_is_borrowing_any{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # 1
    UserConfiguration.set_borrowing(TEST_ADDRESS, 1, TRUE)

    let (col) = UserConfiguration.is_borrowing_any(TEST_ADDRESS)
    assert col = TRUE

    # 2
    UserConfiguration.set_borrowing(TEST_ADDRESS2, 1, TRUE)
    UserConfiguration.set_borrowing(TEST_ADDRESS2, 2, TRUE)

    let (col) = UserConfiguration.is_borrowing_any(TEST_ADDRESS2)
    assert col = TRUE

    # 3
    let (col) = UserConfiguration.is_borrowing_any(TEST_ADDRESS3)
    assert col = FALSE

    return ()
end

@external
func test_is_empty{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # 1
    let (col) = UserConfiguration.is_empty(TEST_ADDRESS)
    assert col = TRUE

    # 2
    UserConfiguration.set_borrowing(TEST_ADDRESS, 1, TRUE)

    let (col) = UserConfiguration.is_empty(TEST_ADDRESS)
    assert col = FALSE

    return ()
end
