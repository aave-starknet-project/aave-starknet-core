%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_contract_address, get_caller_address
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.bool import TRUE, FALSE

from contracts.protocol.libraries.math.wad_ray_math import RAY
from contracts.interfaces.i_pool import IPool
from contracts.interfaces.i_a_token import IAToken

from tests.utils.constants import UNDEPLOYED_RESERVE, USER_1, USER_2

func get_contract_addresses() -> (
    pool_address : felt, token_address : felt, a_token_address : felt
):
    tempvar pool
    tempvar token
    tempvar a_token
    %{ ids.pool = context.pool %}
    %{ ids.token = context.dai %}
    %{ ids.a_token = context.aDAI %}
    return (pool, token, a_token)
end

namespace ATokenModifier:
    func test_mint_wrong_pool{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
        alloc_locals
        %{ print("ATokenModifier : Test user tries to mint whith wrong POOL") %}
        let (local pool, _, local a_token) = get_contract_addresses()

        %{ stop_prank_pool = start_prank(ids.pool, target_contract_address = ids.a_token) %}
        let (minted_true) = IAToken.mint(a_token, pool, USER_1, Uint256(1, 0), Uint256(1, 0))
        %{ stop_prank_pool() %}
        assert minted_true = TRUE
        %{ expect_revert(error_message="Caller address should be {pool}") %}
        IAToken.mint(a_token, USER_1, USER_1, Uint256(1, 0), Uint256(1, 0))
        return ()
    end

    func test_burn_wrong_pool{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
        alloc_locals
        %{ print("ATokenModifier : User tries to mint whith wrong POOL") %}
        let (_, _, local a_token) = get_contract_addresses()
        %{ expect_revert(error_message="Caller address should be {pool}") %}
        IAToken.burn(a_token, USER_1, USER_1, Uint256(50, 0), Uint256(1, 0))
        return ()
    end

    func test_transfer_on_liquidation_wrong_pool{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        %{ print("transfer_on_liquidation : User tries to transfer_on_liquidation whith wrong POOL") %}
        let (_, _, local a_token) = get_contract_addresses()
        %{ expect_revert(error_message="Caller address should be {pool}") %}
        IAToken.transfer_on_liquidation(a_token, USER_1, USER_2, Uint256(10, 0))
        return ()
    end

    func test_transfer_underlying_wrong_pool{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        %{ print("transfer_underlying_to : User tries to transfer_on_liquidation whith wrong POOL") %}
        let (_, _, local a_token) = get_contract_addresses()
        %{ expect_revert(error_message="Caller address should be {pool}") %}
        IAToken.transfer_underlying_to(a_token, USER_1, Uint256(10, 0))
        return ()
    end
end
