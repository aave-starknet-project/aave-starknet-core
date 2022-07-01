%lang starknet

from starkware.cairo.common.bool import TRUE, FALSE
from contracts.protocol.pool.pool_storage import PoolStorage
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_contract_address

from contracts.protocol.libraries.logic.validation_logic import ValidationLogic
from contracts.protocol.libraries.types.data_types import DataTypes
# Setup a test with an active reserve for test_token

const MOCK_A_TOKEN_1 = 12345
const LIQUIDITY_INDEX = 1 * 10 ** 27

# TODO update test once reserves have active/frozen attributes
@view
func test_validate_supply{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    tempvar reserve = DataTypes.ReserveData(0, MOCK_A_TOKEN_1, LIQUIDITY_INDEX)
    ValidationLogic.validate_supply(reserve, Uint256(100, 0))
    return ()
end

@view
func test_validate_supply_amount_null{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    tempvar reserve = DataTypes.ReserveData(0, MOCK_A_TOKEN_1, LIQUIDITY_INDEX)
    %{ expect_revert() %}
    ValidationLogic.validate_supply(reserve, Uint256(0, 0))
    return ()
end

@view
func test_validate_withdraw{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    tempvar reserve = DataTypes.ReserveData(0, MOCK_A_TOKEN_1, LIQUIDITY_INDEX)
    ValidationLogic.validate_withdraw(reserve, Uint256(100, 0), Uint256(1000, 0))
    return ()
end

@view
func test_validate_withdraw_amount_null{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    tempvar reserve = DataTypes.ReserveData(0, MOCK_A_TOKEN_1, LIQUIDITY_INDEX)
    %{ expect_revert() %}
    ValidationLogic.validate_withdraw(reserve, Uint256(100, 0), Uint256(0, 0))

    return ()
end

@view
func test_validate_withdraw_amount_greater_than_balance{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    tempvar reserve = DataTypes.ReserveData(0, MOCK_A_TOKEN_1, LIQUIDITY_INDEX)
    %{ expect_revert() %}
    ValidationLogic.validate_withdraw(reserve, Uint256(1000, 0), Uint256(100, 0))

    return ()
end

# TODO test_validate_drop_reserve once storage cheatcode is available
