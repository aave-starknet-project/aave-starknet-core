%lang starknet
from contracts.protocol.libraries.logic.reserve_configuration_bitmask import (
    ReserveConfigurationBitmask,
)
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin

@external
func test_set_LTV{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, bitwise_ptr : BitwiseBuiltin*, range_check_ptr
}():
    let (bitmap) = ReserveConfigurationBitmask.get_bitmap()
    let (bitmap) = ReserveConfigurationBitmask.set_ltv(bitmap, 10)
    ReserveConfigurationBitmask.set_bitmap(bitmap)
    return ()
end

@external
func test_multiple_storage_write{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, bitwise_ptr : BitwiseBuiltin*, range_check_ptr
}():
    let (bitmap) = ReserveConfigurationBitmask.get_bitmap()
    let (bitmap) = ReserveConfigurationBitmask.set_ltv(bitmap, 10)
    let (bitmap) = ReserveConfigurationBitmask.set_liquidation_threshold(bitmap, 20)
    let (bitmap) = ReserveConfigurationBitmask.set_liquidation_bonus(bitmap, 30)
    ReserveConfigurationBitmask.set_bitmap(bitmap)
    return ()
end

@external
func test_multiple_storage_read{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, bitwise_ptr : BitwiseBuiltin*, range_check_ptr
}():
    let (bitmap) = ReserveConfigurationBitmask.get_bitmap()
    let (
        reserve_active, reserve_frozen, borrowing_enabled, stable_rate_enabled, asset_paused
    ) = ReserveConfigurationBitmask.get_flags(bitmap)
    return ()
end

@external
func test_get_LTV{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, bitwise_ptr : BitwiseBuiltin*, range_check_ptr
}():
    let (bitmap) = ReserveConfigurationBitmask.get_bitmap()
    let (ltv) = ReserveConfigurationBitmask.get_ltv(bitmap)
    return ()
end
