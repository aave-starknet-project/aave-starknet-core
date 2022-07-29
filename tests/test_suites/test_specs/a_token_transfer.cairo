%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_contract_address, get_caller_address
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.bool import TRUE, FALSE

from contracts.protocol.libraries.math.wad_ray_math import RAY
from contracts.interfaces.i_pool import IPool
from contracts.interfaces.i_a_token import IAToken
from contracts.protocol.tokenization.base.incentivized_erc20_library import (
    incentivized_erc20_user_state,
)

from tests.utils.constants import UNDEPLOYED_RESERVE, USER_1, USER_2
from tests.interfaces.IERC20_Mintable import IERC20_Mintable

func get_contract_addresses() -> (
    pool_address : felt,
    token_address : felt,
    a_token_address : felt,
    deployer_address : felt,
    weth_address : felt,
    a_weth_address : felt,
):
    tempvar pool
    tempvar token
    tempvar a_token
    tempvar deployer
    tempvar weth
    tempvar a_weth

    %{ ids.pool = context.pool %}
    %{ ids.token = context.dai %}
    %{ ids.a_token = context.aDAI %}
    %{ ids.deployer = context.deployer %}
    %{ ids.weth = context.weth %}
    %{ ids.a_weth = context.aWETH %}
    return (pool, token, a_token, deployer, weth, a_weth)
end

namespace ATestTokenTransfer:
    func test_transfer_to_itself{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ):
        alloc_locals
        let token_amount_to_mint = Uint256(1000, 0)
        let token_amount_to_supply = Uint256(100, 0)
        let (local pool, local token, local a_token, local deployer, _, _) = get_contract_addresses(
            )

        # Mint Token
        IERC20_Mintable.mint(token, USER_1, token_amount_to_mint)

        # Supply underliying and get a_token in return
        %{ stop_mock = mock_call(ids.pool, "get_reserve_normalized_income", [ids.RAY, 0]) %}
        let (balance_user_1_token) = IERC20_Mintable.balanceOf(token, USER_1)
        assert balance_user_1_token = token_amount_to_mint

        %{ stop_prank_USER_1 = start_prank(ids.USER_1, target_contract_address = ids.token) %}
        IERC20_Mintable.approve(token, pool, token_amount_to_supply)
        %{ stop_prank_USER_1() %}

        %{ stop_prank_pool = start_prank(ids.USER_1, target_contract_address = ids.pool) %}
        IPool.supply(pool, token, token_amount_to_supply, USER_1, 0)
        %{ stop_prank_pool() %}

        # Check a_token balance
        let (balance_user_1_a_token) = IAToken.balanceOf(a_token, USER_1)
        assert balance_user_1_a_token = token_amount_to_supply

        # check user state
        let (state) = incentivized_erc20_user_state.read(USER_1)
        assert state.additionalData = 0

        # Auto transfer
        %{ stop_prank_USER_1 = start_prank(ids.USER_1, target_contract_address = ids.a_token) %}
        IAToken.transfer(a_token, USER_1, token_amount_to_supply)
        %{ stop_prank_USER_1() %}

        # Check Balance
        let (balance_user_1_after) = IAToken.balanceOf(a_token, USER_1)
        assert balance_user_1_after = token_amount_to_supply

        %{ stop_mock() %}
        return ()
    end

    # To be implemented later
    func test_transfer_without_collateral{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        return ()
    end

    func test_multiple_transfer{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ):
        alloc_locals
        let token_amount_to_supply = Uint256(1000, 0)
        let token_amount_to_transfer = Uint256(5, 0)
        let (local pool, local token, local a_token, local deployer, _, _) = get_contract_addresses(
            )

        # Mint Token
        IERC20_Mintable.mint(token, USER_1, token_amount_to_supply)

        # Supply underliying and get a_token in return
        %{ stop_mock = mock_call(ids.pool, "get_reserve_normalized_income", [ids.RAY, 0]) %}
        let (balance_user_1_token) = IERC20_Mintable.balanceOf(token, USER_1)

        %{ stop_prank_USER_1 = start_prank(ids.USER_1, target_contract_address = ids.token) %}
        IERC20_Mintable.approve(token, pool, token_amount_to_supply)
        %{ stop_prank_USER_1() %}

        %{ stop_prank_pool = start_prank(ids.USER_1, target_contract_address = ids.pool) %}
        IPool.supply(pool, token, token_amount_to_supply, USER_1, 0)
        %{ stop_prank_pool() %}

        # ADD expect name

        # First Transfer
        %{ stop_prank_USER_1 = start_prank(ids.USER_1, target_contract_address = ids.a_token) %}
        IAToken.transfer(a_token, USER_2, token_amount_to_transfer)
        %{ stop_prank_USER_1() %}

        let (balance_user_1_after) = IAToken.balanceOf(a_token, USER_1)
        assert balance_user_1_after = Uint256(995, 0)
        let (balance_user_2_after) = IAToken.balanceOf(a_token, USER_2)
        assert balance_user_2_after = Uint256(5, 0)

        # Second Transfer
        %{ stop_prank_USER_1 = start_prank(ids.USER_1, target_contract_address = ids.a_token) %}
        IAToken.transfer(a_token, USER_2, token_amount_to_transfer)
        %{ stop_prank_USER_1() %}

        let (balance_user_1_after) = IAToken.balanceOf(a_token, USER_1)
        assert balance_user_1_after = Uint256(990, 0)
        let (balance_user_2_after) = IAToken.balanceOf(a_token, USER_2)
        assert balance_user_2_after = Uint256(10, 0)

        # Third Transfer
        %{ stop_prank_USER_1 = start_prank(ids.USER_1, target_contract_address = ids.a_token) %}
        IAToken.transfer(a_token, USER_2, Uint256(0, 0))
        %{ stop_prank_USER_1() %}

        let (balance_user_1_after) = IAToken.balanceOf(a_token, USER_1)
        assert balance_user_1_after = Uint256(990, 0)
        let (balance_user_2_after) = IAToken.balanceOf(a_token, USER_2)
        assert balance_user_2_after = Uint256(10, 0)

        %{ stop_mock() %}
        return ()
    end

    func test_transfer_all{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
        alloc_locals
        let token_amount_to_supply = Uint256(1000, 0)
        let (local pool, local token, local a_token, local deployer, _, _) = get_contract_addresses(
            )

        # Mint Token
        IERC20_Mintable.mint(token, USER_1, token_amount_to_supply)

        # Supply underliying and get a_token in return
        %{ stop_mock = mock_call(ids.pool, "get_reserve_normalized_income", [ids.RAY, 0]) %}
        let (balance_user_1_token) = IERC20_Mintable.balanceOf(token, USER_1)

        %{ stop_prank_USER_1 = start_prank(ids.USER_1, target_contract_address = ids.token) %}
        IERC20_Mintable.approve(token, pool, token_amount_to_supply)
        %{ stop_prank_USER_1() %}

        %{ stop_prank_pool = start_prank(ids.USER_1, target_contract_address = ids.pool) %}
        IPool.supply(pool, token, token_amount_to_supply, USER_1, 0)
        %{ stop_prank_pool() %}

        # Transfer All
        %{ stop_prank_USER_1 = start_prank(ids.USER_1, target_contract_address = ids.a_token) %}
        IAToken.transfer(a_token, USER_2, token_amount_to_supply)
        %{ stop_prank_USER_1() %}

        let (balance_user_1_after) = IAToken.balanceOf(a_token, USER_1)
        assert balance_user_1_after = Uint256(0, 0)
        let (balance_user_2_after) = IAToken.balanceOf(a_token, USER_2)
        assert balance_user_2_after = token_amount_to_supply

        %{ stop_mock() %}
        return ()
    end

    func test_borrow_weth{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
        alloc_locals
        let weth_amount_to_supply = Uint256(10, 0)
        let weth_amount_to_borrow = Uint256(1, 0)
        let token_amount_to_supply = Uint256(1000, 0)

        let (
            local pool, local token, local a_token, local deployer, local weth, local a_weth
        ) = get_contract_addresses()

        # Mint Token and transfer it to user 2
        IERC20_Mintable.mint(token, USER_1, token_amount_to_supply)
        %{ stop_prank_USER_1 = start_prank(ids.USER_1, target_contract_address = ids.token) %}
        IERC20_Mintable.approve(token, pool, token_amount_to_supply)
        %{ stop_prank_USER_1() %}
        %{ stop_prank_pool = start_prank(ids.USER_1, target_contract_address = ids.pool) %}
        IPool.supply(pool, token, token_amount_to_supply, USER_1, 0)  # TODO explain 0 at the end
        %{ stop_prank_pool() %}
        %{ stop_prank_USER_1 = start_prank(ids.USER_1, target_contract_address = ids.a_token) %}
        IAToken.transfer(a_token, USER_2, token_amount_to_supply)
        %{ stop_prank_USER_1() %}

        # Mint weth
        IERC20_Mintable.mint(weth, USER_2, weth_amount_to_supply)

        # Supply underliying and get a_token in return
        %{ stop_mock = mock_call(ids.pool, "get_reserve_normalized_income", [ids.RAY, 0]) %}
        let (balance_user_2_weth) = IERC20_Mintable.balanceOf(weth, USER_2)
        assert balance_user_2_weth = weth_amount_to_supply

        %{ stop_prank_USER_2 = start_prank(ids.USER_2, target_contract_address = ids.weth) %}
        IERC20_Mintable.approve(weth, pool, weth_amount_to_supply)
        %{ stop_prank_USER_2() %}

        %{ stop_prank_pool = start_prank(ids.USER_2, target_contract_address = ids.pool) %}
        IPool.supply(pool, weth, weth_amount_to_supply, USER_2, 0)  # TODO explain 0 at the end
        %{ stop_prank_pool() %}

        let (balance_user_2_after) = IAToken.balanceOf(a_weth, USER_2)
        assert balance_user_2_after = weth_amount_to_supply

        %{ stop_mock() %}
        return ()
    end

    func test_transfer_after_borrow{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        return ()
    end

    func test_transfer_back_all_after_borrow{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        return ()
    end

    func test_transfer_back_small_after_borrow{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        return ()
    end
end
