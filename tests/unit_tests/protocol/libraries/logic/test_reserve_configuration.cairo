%lang starknet
from contracts.protocol.libraries.logic.reserve_configuration import ReserveConfiguration
from starkware.cairo.common.cairo_builtins import HashBuiltin

@external
func test_set_LTV{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    ReserveConfiguration.set_ltv(10)
    let (ltv) = ReserveConfiguration.get_ltv()
    assert ltv = 10
    return ()
end
