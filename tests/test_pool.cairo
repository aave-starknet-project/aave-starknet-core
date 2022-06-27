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

        #PRANK_USER receives 1000 test_token
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

func _init_reserve{syscall_ptr : felt*, range_check_ptr}(
    pool : felt, test_token : felt, aToken : felt
):
    IPool.init_reserve(pool, test_token, aToken)
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

@view
func test_init_reserve{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals
    let (local pool, local test_token, local aToken) = get_contract_addresses()
    let (reserve) = IPool.get_reserve_data(pool, test_token)
    assert reserve.aToken_address = aToken
    return ()
end

@view
func test_supply{syscall_ptr : felt*, range_check_ptr}():
    # PRANK_USER supplies 100 test_token to the protocol

    alloc_locals
    let (local pool, local test_token, local aToken) = get_contract_addresses()
    _supply(pool, test_token, aToken)
    let (user_tokens) = IERC20.balanceOf(test_token, PRANK_USER)
    assert user_tokens = Uint256(900, 0)

    let (user_aTokens) = IAToken.balanceOf(aToken, PRANK_USER)
    assert user_aTokens = Uint256(100, 0)

    let (pool_collat) = IERC20.balanceOf(test_token, aToken)
    assert pool_collat = Uint256(100, 0)
    return ()
end

func _supply{syscall_ptr : felt*, range_check_ptr}(pool : felt, test_token : felt, aToken : felt):
    %{ stop_prank_token = start_prank(ids.PRANK_USER, target_contract_address=ids.test_token) %}
    IERC20.approve(test_token, pool, Uint256(100, 0))

    %{
        stop_prank_pool = start_prank(ids.PRANK_USER, target_contract_address=ids.pool)
        stop_prank_token()
    %}
    IPool.supply(pool, test_token, Uint256(100, 0), PRANK_USER, 0)
    %{ stop_prank_pool() %}
    return ()
end

@view
func test_withdraw_fail_amount_too_high{syscall_ptr : felt*, range_check_ptr}():
    # PRANK_USER tries to withdraw tokens from the pool but the amount is higher than his balance

    alloc_locals
    let (local pool, local test_token, local aToken) = get_contract_addresses()
    # Prank pool so that inside the contract, caller() is PRANK_USER
    %{ stop_prank_pool= start_prank(ids.PRANK_USER, target_contract_address=ids.pool) %}
    %{ expect_revert() %}
    IPool.withdraw(pool, test_token, Uint256(50, 0), PRANK_USER)
    %{ stop_prank_pool() %}
    return ()
end

@view
func test_withdraw{syscall_ptr : felt*, range_check_ptr}():
    # PRANK_USER tries to withdraws 50 tokens out of the 100 he supplied

    alloc_locals
    let (local pool, local test_token, local aToken) = get_contract_addresses()
    _supply(pool, test_token, aToken)

    %{ stop_prank_pool= start_prank(ids.PRANK_USER, target_contract_address=ids.pool) %}
    IPool.withdraw(pool, test_token, Uint256(50, 0), PRANK_USER)

    %{ stop_prank_pool() %}

    let (user_tokens) = IERC20.balanceOf(test_token, PRANK_USER)
    assert user_tokens = Uint256(950, 0)

    let (user_aTokens) = IAToken.balanceOf(aToken, PRANK_USER)
    assert user_aTokens = Uint256(50, 0)

    let (pool_collat) = IERC20.balanceOf(test_token, aToken)
    assert pool_collat = Uint256(50, 0)

    return ()
end
