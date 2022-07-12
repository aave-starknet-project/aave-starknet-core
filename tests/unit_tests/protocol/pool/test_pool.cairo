%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.math import assert_not_equal, assert_not_zero

from openzeppelin.token.erc20.interfaces.IERC20 import IERC20

from contracts.interfaces.i_a_token import IAToken
from contracts.interfaces.i_pool import IPool
from contracts.protocol.libraries.math.wad_ray_math import RAY
from contracts.protocol.libraries.types.data_types import DataTypes

const PRANK_USER = 123

# Setup a test with an active reserve for test_token
@view
func __setup__{syscall_ptr : felt*, range_check_ptr}():
    %{
        # Deploy pool, pool configurator is not active yet
        context.pool = deploy_contract("./contracts/protocol/pool/pool.cairo",[0]).contract_address

        # Deploy Test - TST - 18 decimals - 1000 supply sent to PRANK_USER
        context.test_token = deploy_contract("./tests/contracts/ERC20.cairo", [1415934836,5526356,18,1000,0,ids.PRANK_USER]).contract_address 

        # Deploy aTest - aTST - 18 decimals - 0 supply - Owner is pool - underlying is test_token
        context.a_token = deploy_contract("./contracts/protocol/tokenization/a_token.cairo", [context.pool,1632916308,context.test_token,43232,18,1,2]).contract_address
    %}
    tempvar pool
    tempvar test_token
    tempvar a_token
    %{ ids.pool = context.pool %}
    %{ ids.test_token = context.test_token %}
    %{ ids.a_token = context.a_token %}
    _init_reserve(pool, test_token, a_token)
    return ()
end

func _init_reserve{syscall_ptr : felt*, range_check_ptr}(
    pool : felt, test_token : felt, a_token : felt
):
    IPool.init_reserve(pool, test_token, a_token)
    return ()
end

func get_contract_addresses() -> (
    contract_address : felt, test_token_address : felt, a_token_address : felt
):
    tempvar pool
    tempvar test_token
    tempvar a_token
    %{ ids.pool = context.pool %}
    %{ ids.test_token = context.test_token %}
    %{ ids.a_token = context.a_token %}
    return (pool, test_token, a_token)
end

@view
func test_init_reserve{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals
    let (local pool, local test_token, local a_token) = get_contract_addresses()
    let (reserve) = IPool.get_reserve_data(pool, test_token)
    assert reserve.a_token_address = a_token
    return ()
end

@view
func test_supply{syscall_ptr : felt*, range_check_ptr}():
    # PRANK_USER supplies 100 test_token to the protocol

    alloc_locals
    let (local pool, local test_token, local a_token) = get_contract_addresses()
    _supply(pool, test_token, a_token)
    let (user_tokens) = IERC20.balanceOf(test_token, PRANK_USER)
    assert user_tokens = Uint256(900, 0)

    %{ stop_mock = mock_call(ids.pool, "get_reserve_normalized_income", [ids.RAY, 0]) %}
    let (user_a_tokens) = IAToken.balanceOf(a_token, PRANK_USER)
    assert user_a_tokens = Uint256(100, 0)
    %{ stop_mock() %}

    let (pool_collat) = IERC20.balanceOf(test_token, a_token)
    assert pool_collat = Uint256(100, 0)
    return ()
end

func _supply{syscall_ptr : felt*, range_check_ptr}(pool : felt, test_token : felt, a_token : felt):
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
    let (local pool, local test_token, local a_token) = get_contract_addresses()
    # Prank pool so that inside the contract, caller() is PRANK_USER
    %{ stop_prank_pool = start_prank(ids.PRANK_USER, target_contract_address=ids.pool) %}
    %{ expect_revert() %}
    IPool.withdraw(pool, test_token, Uint256(50, 0), PRANK_USER)
    %{ stop_prank_pool() %}
    return ()
end

@view
func test_withdraw{syscall_ptr : felt*, range_check_ptr}():
    # PRANK_USER tries to withdraws 50 tokens out of the 100 he supplied

    alloc_locals
    let (local pool, local test_token, local a_token) = get_contract_addresses()
    _supply(pool, test_token, a_token)

    %{
        stop_mock = mock_call(ids.pool, "get_reserve_normalized_income", [ids.RAY, 0])
        stop_prank_pool = start_prank(ids.PRANK_USER, target_contract_address=ids.pool)
    %}
    IPool.withdraw(pool, test_token, Uint256(50, 0), PRANK_USER)
    %{
        stop_prank_pool()
        stop_mock()
    %}

    let (user_tokens) = IERC20.balanceOf(test_token, PRANK_USER)
    assert user_tokens = Uint256(950, 0)

    %{ stop_mock = mock_call(ids.pool, "get_reserve_normalized_income", [ids.RAY, 0]) %}
    let (user_a_tokens) = IAToken.balanceOf(a_token, PRANK_USER)
    assert user_a_tokens = Uint256(50, 0)
    %{ stop_mock() %}

    let (pool_collat) = IERC20.balanceOf(test_token, a_token)
    assert pool_collat = Uint256(50, 0)

    return ()
end
