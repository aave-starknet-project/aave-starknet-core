%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from tests.test_suites.test_specs.aave_oracle_spec import TestAaveOracle

@external
func test_owner_set_a_new_asset_source{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestAaveOracle.test_owner_set_a_new_asset_source()
    return ()
end

@external
func test_owner_updates_asset_source{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestAaveOracle.test_owner_updates_asset_source()
    return ()
end

@external
func test_owner_tries_to_set_new_asset_source_with_wrong_input_params{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestAaveOracle.test_owner_tries_to_set_new_asset_source_with_wrong_input_params()
    return ()
end

@external
func test_get_price_of_BASE_CURRENCY_asset{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestAaveOracle.test_owner_updates_asset_source()
    return ()
end

@external
func test_non_owner_sets_ticker{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ):
    TestAaveOracle.test_non_owner_sets_ticker()
    return ()
end

@external
func test_get_price_of_BASE_CURRENCY_asset_with_registered_ticker{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestAaveOracle.test_get_price_of_BASE_CURRENCY_asset_with_registered_ticker()
    return ()
end

@external
func test_get_price_of_asset_with_no_ticker{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestAaveOracle.test_get_price_of_asset_with_no_ticker()
    return ()
end
