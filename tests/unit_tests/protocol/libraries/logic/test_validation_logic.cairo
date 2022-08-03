%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256

from contracts.protocol.libraries.logic.validation_logic import ValidationLogic
from contracts.protocol.libraries.types.data_types import DataTypes

from tests.utils.constants import MOCK_A_TOKEN_1, MOCK_TOKEN_1, MOCK_TOKEN_2, BASE_LIQUIDITY_INDEX

# TODO update test once reserves have active/frozen attributes
@view
func test_validate_supply{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    tempvar reserve = DataTypes.ReserveData(0, MOCK_A_TOKEN_1, MOCK_TOKEN_1, MOCK_TOKEN_2, BASE_LIQUIDITY_INDEX, DataTypes.ReserveConfigurationMap(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
    ValidationLogic.validate_supply(reserve, Uint256(100, 0))
    return ()
end

@view
func test_validate_supply_amount_null{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    tempvar reserve = DataTypes.ReserveData(0, MOCK_A_TOKEN_1, MOCK_TOKEN_1, MOCK_TOKEN_2, BASE_LIQUIDITY_INDEX, DataTypes.ReserveConfigurationMap(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
    %{ expect_revert() %}
    ValidationLogic.validate_supply(reserve, Uint256(0, 0))
    return ()
end

@view
func test_validate_withdraw{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    tempvar reserve = DataTypes.ReserveData(0, MOCK_A_TOKEN_1, MOCK_TOKEN_1, MOCK_TOKEN_2, BASE_LIQUIDITY_INDEX, DataTypes.ReserveConfigurationMap(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
    ValidationLogic.validate_withdraw(reserve, Uint256(100, 0), Uint256(1000, 0))
    return ()
end

@view
func test_validate_withdraw_amount_null{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    tempvar reserve = DataTypes.ReserveData(0, MOCK_A_TOKEN_1, MOCK_TOKEN_1, MOCK_TOKEN_2, BASE_LIQUIDITY_INDEX, DataTypes.ReserveConfigurationMap(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
    %{ expect_revert() %}
    ValidationLogic.validate_withdraw(reserve, Uint256(100, 0), Uint256(0, 0))

    return ()
end

@view
func test_validate_withdraw_amount_greater_than_balance{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    tempvar reserve = DataTypes.ReserveData(0, MOCK_A_TOKEN_1, MOCK_TOKEN_1, MOCK_TOKEN_2, BASE_LIQUIDITY_INDEX, DataTypes.ReserveConfigurationMap(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
    %{ expect_revert() %}
    ValidationLogic.validate_withdraw(reserve, Uint256(1000, 0), Uint256(100, 0))

    return ()
end

# TODO test_validate_drop_reserve once storage cheatcode is available
