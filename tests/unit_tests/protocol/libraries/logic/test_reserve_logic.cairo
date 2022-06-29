%lang starknet

from starkware.cairo.common.bool import TRUE, FALSE
from contracts.protocol.pool.pool_storage import PoolStorage
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_contract_address

from contracts.protocol.libraries.logic.reserve_logic import ReserveLogic
from contracts.protocol.libraries.types.data_types import DataTypes
# Setup a test with an active reserve for test_token

const MOCK_A_TOKEN_1 = 12345
const LIQUIDITY_INDEX = 1 * 10 ** 27

@view
func test_init{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (new_reserve) = ReserveLogic.init(DataTypes.ReserveData(0, 0, 0), MOCK_A_TOKEN_1)
    assert new_reserve = DataTypes.ReserveData(0, MOCK_A_TOKEN_1, LIQUIDITY_INDEX)
    return ()
end

@view
func test_init_already_initialized{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    %{ expect_revert() %}
    let (new_reserve) = ReserveLogic.init(DataTypes.ReserveData(0, 10, 0), MOCK_A_TOKEN_1)
    return ()
end
