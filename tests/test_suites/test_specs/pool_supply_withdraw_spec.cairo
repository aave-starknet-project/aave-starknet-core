%lang starknet
from starkware.cairo.common.uint256 import Uint256
from openzeppelin.token.erc20.interfaces.IERC20 import IERC20
from contracts.interfaces.i_pool import IPool
from contracts.interfaces.i_a_token import IAToken
from contracts.protocol.libraries.math.wad_ray_math import RAY
from tests.utils.constants import USER_1
from tests.interfaces.IERC20_Mintable import IERC20_Mintable

# @notice this test spec is not in Aave's codebase but we keep it until we can adapt their pool tests
namespace TestPoolSupplyWithdrawDeployed:
    # DAI Reserve a_token_address correctly initialized
    func test_pool_supply_withdraw_spec_1{syscall_ptr : felt*, range_check_ptr}():
        alloc_locals
        local pool
        local dai
        local aDAI
        %{
            ids.pool = context.pool
            ids.dai = context.dai
            ids.aDAI = context.aDAI
        %}
        let (reserve) = IPool.get_reserve_data(pool, dai)
        assert reserve.a_token_address = aDAI
        return ()
    end

    # USER_1 supplies 100 test_token to the protocol
    func test_pool_supply_withdraw_spec_2{syscall_ptr : felt*, range_check_ptr}():
        alloc_locals
        let (local pool, local test_token, local a_token) = get_contract_addresses()
        _supply(pool, test_token)
        let (user_tokens) = IERC20.balanceOf(test_token, USER_1)
        assert user_tokens = Uint256(900, 0)

        %{ stop_mock = mock_call(ids.pool, "get_reserve_normalized_income", [ids.RAY, 0]) %}
        let (user_a_tokens) = IAToken.balanceOf(a_token, USER_1)
        assert user_a_tokens = Uint256(100, 0)
        %{ stop_mock() %}

        let (pool_collat) = IERC20.balanceOf(test_token, a_token)
        assert pool_collat = Uint256(100, 0)
        return ()
    end

    # USER_1 tries to withdraw tokens from the pool but the amount is higher than his balance
    func test_pool_supply_withdraw_spec_3{syscall_ptr : felt*, range_check_ptr}():
        alloc_locals
        let (local pool, local test_token, local a_token) = get_contract_addresses()
        # Prank pool so that inside the contract, caller() is USER_1
        %{
            stop_mock = mock_call(ids.pool, "get_reserve_normalized_income", [ids.RAY, 0])
            stop_prank_pool= start_prank(ids.USER_1, target_contract_address=ids.pool)
        %}
        %{ expect_revert(error_message="User cannot withdraw more than the available balance") %}
        IPool.withdraw(pool, test_token, Uint256(50, 0), USER_1)
        %{
            stop_prank_pool()
            stop_mock()
        %}
        return ()
    end

    # USER_1 withdraws 50 tokens out of the 100 he supplied
    func test_pool_supply_withdraw_spec_4{syscall_ptr : felt*, range_check_ptr}():
        alloc_locals
        let (local pool, local dai, local aDAI) = get_contract_addresses()
        _supply(pool, dai)

        %{
            stop_mock = mock_call(ids.pool, "get_reserve_normalized_income", [ids.RAY, 0])
            stop_prank_pool= start_prank(ids.USER_1, target_contract_address=ids.pool)
        %}
        IPool.withdraw(pool, dai, Uint256(50, 0), USER_1)

        %{
            stop_prank_pool()
            stop_mock()
        %}

        let (user_tokens) = IERC20.balanceOf(dai, USER_1)
        assert user_tokens = Uint256(950, 0)

        %{ stop_mock = mock_call(ids.pool, "get_reserve_normalized_income", [ids.RAY, 0]) %}
        let (user_a_tokens) = IAToken.balanceOf(aDAI, USER_1)
        assert user_a_tokens = Uint256(50, 0)
        %{ stop_mock() %}

        let (pool_collat) = IERC20.balanceOf(dai, aDAI)
        assert pool_collat = Uint256(50, 0)

        return ()
    end
end

func _supply{syscall_ptr : felt*, range_check_ptr}(pool : felt, token : felt):
    let minted_amount = Uint256(1000, 0)
    let deposited_amount = Uint256(100, 0)
    IERC20_Mintable.mint(token, USER_1, minted_amount)

    %{ stop_prank_token = start_prank(ids.USER_1, target_contract_address=ids.token) %}
    IERC20_Mintable.approve(token, pool, deposited_amount)
    %{
        stop_prank_pool = start_prank(ids.USER_1, target_contract_address=ids.pool)
        stop_prank_token()
    %}
    IPool.supply(pool, token, deposited_amount, USER_1, 0)
    %{ stop_prank_pool() %}
    return ()
end

func get_contract_addresses() -> (pool : felt, dai : felt, aDAI : felt):
    tempvar pool
    tempvar dai
    tempvar aDAI
    %{ ids.pool = context.pool %}
    %{ ids.dai = context.dai %}
    %{ ids.aDAI = context.aDAI %}
    return (pool, dai, aDAI)
end
