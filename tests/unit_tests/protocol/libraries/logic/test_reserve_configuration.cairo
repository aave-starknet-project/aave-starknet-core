%lang starknet
from contracts.protocol.libraries.logic.reserve_configuration import ReserveConfiguration
from starkware.cairo.common.cairo_builtins import HashBuiltin

@external
func test_set_LTV{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    ReserveConfiguration.set_ltv(10)
    return ()
end

@external
func test_multiple_storage_write{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ):
    ReserveConfiguration.set_ltv(10)
    ReserveConfiguration.set_liquidation_threshold(20)
    ReserveConfiguration.set_liquidation_bonus(30)
    return ()
end

@external
func test_multiple_storage_read{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ):
    let (
        reserve_active, reserve_frozen, borrowing_enabled, stable_rate_enabled, asset_paused
    ) = ReserveConfiguration.get_flags()
    return ()
end

@external
func test_get_LTV{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (ltv) = ReserveConfiguration.get_ltv()
    return ()
end
