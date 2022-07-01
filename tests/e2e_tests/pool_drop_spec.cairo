%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.starknet.common.syscalls import get_contract_address
from contracts.interfaces.i_pool import IPool
from contracts.protocol.libraries.helpers.values import Generics
from tests.contracts.IERC20_Mintable import IERC20_Mintable
from tests.utils.utils import Utils
from tests.utils.addresses import UNDEPLOYED_RESERVE, USER_1, USER_2

# TODO test should integrate pool_configurator when implemented

namespace PoolDropSpec:
    # User 1 deposits DAI, User 2 borrow DAI stable and variable, should fail to drop DAI reserve
    @external
    func test_pool_drop_spec_1{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
        alloc_locals
        %{ print("PoolDropSpec : User 1 deposits DAI, User 2 borrow DAI stable and variable, should fail to drop DAI reserve") %}
        local dai
        local weth
        local pool
        %{
            ids.dai = context.dai
            ids.weth = context.weth
            ids.pool = context.pool
        %}

        deposit_funds_and_borrow(dai, weth, pool)
        %{ expect_revert(error_message="AToken supply is not zero") %}
        IPool.drop_reserve(pool, dai)

        # TODO Tests should implement drop_reserves while borrowing verification when implemented

        return ()
    end

    # TODO once borrowing/lending is implemented
    # 'User 2 repays debts, drop DAI reserve should fail'
    func test_pool_drop_spec_2{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
        %{ print("PoolDropSpec : User 2 repays debts, drop DAI reserve should fail") %}
    end

    # 'User 1 withdraw DAI, drop DAI reserve should succeed'
    @external
    func test_pool_drop_spec_3{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
        alloc_locals
        %{ print("PoolDropSpec : User 1 withdraw DAI, drop DAI reserve should succeed") %}
        local dai
        local weth
        local pool
        local deployer
        %{
            ids.dai = context.dai
            ids.weth = context.weth
            ids.pool = context.pool
            ids.deployer = context.deployer
        %}

        deposit_funds_and_borrow(dai, weth, pool)
        IPool.withdraw(pool, dai, Uint256(Generics.UINT128_MAX, Generics.UINT128_MAX), deployer)
        let (reserves_count, reserves_list) = IPool.get_reserves_list(pool)
        IPool.drop_reserve(pool, dai)
        let (new_count, new_reserves) = IPool.get_reserves_list(pool)
        assert new_count = reserves_count - 1
        let (is_dai_in_array) = Utils.array_includes(new_count, new_reserves, dai)
        assert is_dai_in_array = 0
        # TODO once reserve pause/active/freezing is implemented

        return ()
    end

    # 'Drop an asset that is not a listed reserve should fail'
    @external
    func test_pool_drop_spec_4{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
        alloc_locals
        %{ print("PoolDropSpec : Drop an asset that is not a listed reserve should fail") %}
        local dai
        local weth
        local pool
        %{
            ids.dai = context.dai
            ids.weth = context.weth
            ids.pool = context.pool
        %}
        %{ expect_revert(error_message="Asset is not listed") %}
        IPool.drop_reserve(pool, UNDEPLOYED_RESERVE)

        return ()
    end

    # 'Dropping zero address should fail'
    @external
    func test_pool_drop_spec_5{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
        alloc_locals
        %{ print("PoolDropSpec : Dropping zero address should fail") %}
        local dai
        local weth
        local pool
        %{
            ids.dai = context.dai
            ids.weth = context.weth
            ids.pool = context.pool
        %}
        %{ expect_revert(error_message="Zero address not valid") %}
        IPool.drop_reserve(pool, 0)

        return ()
    end
end

func deposit_funds_and_borrow{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    dai : felt, weth : felt, pool : felt
):
    alloc_locals
    local deployer
    %{ ids.deployer = context.deployer %}

    let (local deposited_amount : Uint256) = Utils.parse_ether(1000)
    let (local borrowed_amount : Uint256) = Utils.parse_ether(100)

    IERC20_Mintable.mint(dai, deployer, deposited_amount)
    IERC20_Mintable.approve(dai, pool, deposited_amount)

    IERC20_Mintable.mint(dai, USER_1, deposited_amount)
    %{ stop_prank_dai = start_prank(ids.USER_1, target_contract_address=ids.dai) %}
    IERC20_Mintable.approve(dai, pool, deposited_amount)
    %{ stop_prank_dai() %}

    IERC20_Mintable.mint(weth, USER_1, deposited_amount)
    %{ stop_prank_weth = start_prank(ids.USER_1, target_contract_address=ids.weth) %}
    IERC20_Mintable.approve(weth, pool, deposited_amount)
    %{ stop_prank_weth() %}

    IPool.supply(pool, dai, deposited_amount, deployer, 0)

    return ()
end
