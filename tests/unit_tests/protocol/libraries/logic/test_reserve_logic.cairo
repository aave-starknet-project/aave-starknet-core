%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

from contracts.protocol.libraries.logic.reserve_logic import ReserveLogic
from contracts.protocol.libraries.types.data_types import DataTypes

from tests.utils.constants import MOCK_A_TOKEN_1, MOCK_TOKEN_1, MOCK_TOKEN_2, BASE_LIQUIDITY_INDEX

@view
func test_init{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (new_reserve) = ReserveLogic.init(
        DataTypes.ReserveData(0, 0, 0, 0, 0), MOCK_A_TOKEN_1, MOCK_TOKEN_1, MOCK_TOKEN_2
    )
    assert new_reserve = DataTypes.ReserveData(0, MOCK_A_TOKEN_1, MOCK_TOKEN_1, MOCK_TOKEN_2, BASE_LIQUIDITY_INDEX)
    return ()
end

@view
func test_init_already_initialized{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    %{ expect_revert() %}
    let (new_reserve) = ReserveLogic.init(DataTypes.ReserveData(0, 10, 11, 12, 0), MOCK_A_TOKEN_1)
    return ()
end
