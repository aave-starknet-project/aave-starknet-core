%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from contracts.interfaces.IPool import IPool
from contracts.protocol.libraries.types.DataTypes import DataTypes
from openzeppelin.token.erc20.interfaces.IERC20 import IERC20
from starkware.cairo.common.uint256 import Uint256
from contracts.interfaces.IAtoken import IAToken
from starkware.cairo.common.math import assert_not_equal, assert_not_zero

const PRANK_USER = 123

# Setup a test with an active reserve for test_token
@view
func __setup__{syscall_ptr : felt*, range_check_ptr}():
    %{
        context.pool = deploy_contract("./contracts/protocol/pool/Pool.cairo").contract_address

        context.test_token = deploy_contract("./tests/contracts/ERC20.cairo", [1415934836,5526356,18,1000,0,ids.PRANK_USER]).contract_address 

        context.aToken = deploy_contract("./contracts/protocol/tokenization/AToken.cairo", [418027762548,1632916308,18,0,0,context.pool,context.pool,context.test_token]).contract_address
    %}
    tempvar pool
    tempvar test_token
    tempvar aToken
    %{ ids.pool = context.pool %}
    %{ ids.test_token = context.test_token %}
    %{ ids.aToken = context.aToken %}
    _init_reserve(pool, test_token, aToken)
    return ()
end

func get_contract_addresses() -> (
    contract_address : felt, test_token_address : felt, aToken_address : felt
):
    tempvar pool
    tempvar test_token
    tempvar aToken
    %{ ids.pool = context.pool %}
    %{ ids.test_token = context.test_token %}
    %{ ids.aToken = context.aToken %}
    return (pool, test_token, aToken)
end

# Verify that reserve was initialized correctly in __setup__ hook
@external
func test_init_reserve{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals
    let (local pool, local test_token, local aToken) = get_contract_addresses()
    let (reserve) = IPool.get_reserve_data(pool, test_token)
    assert reserve.aToken_address = aToken
    return ()
end

func _init_reserve{syscall_ptr : felt*, range_check_ptr}(
    pool : felt, test_token : felt, aToken : felt
):
    IPool.init_reserve(pool, test_token, aToken)
    return ()
end
