%lang starknet
from contracts.protocol.libraries.logic.reserve_configuration_bitmask import (
    ReserveConfigurationBitmask,
)
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin

@external
func test_set_LTV{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, bitwise_ptr : BitwiseBuiltin*, range_check_ptr
}():
    ReserveConfigurationBitmask.set_ltv(10)
    return ()
end

@external
func test_multiple_storage_write{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, bitwise_ptr : BitwiseBuiltin*, range_check_ptr
}():
    ReserveConfigurationBitmask.set_ltv(10)
    ReserveConfigurationBitmask.set_liquidation_threshold(20)
    ReserveConfigurationBitmask.set_liquidation_bonus(30)
    return ()
end

@external
func test_multiple_storage_read{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, bitwise_ptr : BitwiseBuiltin*, range_check_ptr
}():
    let (
        reserve_active, reserve_frozen, borrowing_enabled, stable_rate_enabled, asset_paused
    ) = ReserveConfigurationBitmask.get_flags()
    return ()
end

@external
func test_get_LTV{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, bitwise_ptr : BitwiseBuiltin*, range_check_ptr
}():
    let (ltv) = ReserveConfigurationBitmask.get_ltv()
    return ()
end
