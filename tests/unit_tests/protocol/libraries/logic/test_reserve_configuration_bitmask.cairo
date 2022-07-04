%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from contracts.protocol.libraries.logic.reserve_configuration_bitmask import (
    ReserveConfigurationBitmask,
)

@external
func test_set_LTV{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, bitwise_ptr : BitwiseBuiltin*, range_check_ptr
}():
    ReserveConfigurationBitmask.set_ltv(10)
    let (ltv_value) = ReserveConfigurationBitmask.get_bitmap()
    assert ltv_value = 10
    return ()
end
