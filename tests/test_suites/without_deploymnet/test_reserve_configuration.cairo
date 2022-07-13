%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from tests.test_suites.test_specs.reserve_configuration_spec import TestReserveConfiguration

@external
func test_ltv{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    TestReserveConfiguration.test_ltv()
    return ()
end

@external
func test_liquidation_threshold{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ):
    TestReserveConfiguration.test_liquidation_threshold()
    return ()
end

@external
func test_liquidation_bonus{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    TestReserveConfiguration.test_liquidation_bonus()
    return ()
end

@external
func test_decimals{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    TestReserveConfiguration.test_decimals()
    return ()
end

@external
func test_active{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    TestReserveConfiguration.test_active()
    return ()
end

@external
func test_frozen{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    TestReserveConfiguration.test_frozen()
    return ()
end

@external
func test_paused{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    TestReserveConfiguration.test_paused()
    return ()
end

@external
func test_borrowable_in_isolation{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestReserveConfiguration.test_borrowable_in_isolation()
    return ()
end

@external
func test_siloed_borrowing{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    TestReserveConfiguration.test_siloed_borrowing()
    return ()
end

@external
func test_borrow_cap{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    TestReserveConfiguration.test_borrow_cap()
    return ()
end

@external
func test_supply_cap{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    TestReserveConfiguration.test_supply_cap()
    return ()
end

@external
func test_debt_ceiling{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    TestReserveConfiguration.test_debt_ceiling()
    return ()
end

@external
func test_liquidation_protocol_fee{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestReserveConfiguration.test_liquidation_protocol_fee()
    return ()
end

@external
func test_unbacked_mint_cap{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    TestReserveConfiguration.test_unbacked_mint_cap()
    return ()
end

@external
func test_eMode_category{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    TestReserveConfiguration.test_eMode_category()
    return ()
end

@external
func test_get_flags{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    TestReserveConfiguration.test_get_flags()
    return ()
end

@external
func test_params{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    TestReserveConfiguration.test_params()
    return ()
end

@external
func test_caps{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    TestReserveConfiguration.test_caps()
    return ()
end
