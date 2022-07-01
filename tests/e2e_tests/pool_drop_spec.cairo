%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.starknet.common.syscalls import get_contract_address
from tests.contracts.IERC20_Mintable import IERC20_Mintable
# importing this will execute all test cases in that file.
from tests.utils.utils import Utils

from contracts.interfaces.i_pool import IPool
# TODO test should integrate pool_configurator when implemented

const UNDEPLOYED_RESERVE = 29871350785143987
const USER_1 = 011235813
const USER_2 = 314159265

const UINT128_MAX = 2 ** 128 - 1

namespace PoolDropSpec:
    # 'User 1 deposits DAI, User 2 borrow DAI stable and variable, should fail to drop DAI reserve'
    @external
    func test_fail_1{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
        alloc_locals
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

    # 'User 2 repays debts, drop DAI reserve should fail'
    func fail_2{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
        alloc_locals
        local dai
        local weth
        local pool
        %{
            ids.dai = context.dai
            ids.weth = context.weth
            ids.pool = context.pool
        %}
        return ()
        # TODO once borrowing/lending is implemented
    end

    # 'User 1 withdraw DAI, drop DAI reserve should succeed'
    @external
    func test_success{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
        alloc_locals
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
        IPool.withdraw(pool, dai, Uint256(UINT128_MAX, UINT128_MAX), deployer)
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
    func test_fail_3{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
        alloc_locals
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

    # 'Drop an asset that is not a listed reserve should fail'
    @external
    func test_fail_4{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
        alloc_locals
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

    func deposit_funds_and_borrow{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(dai : felt, weth : felt, pool : felt):
        alloc_locals
        local deployer
        %{ ids.deployer = context.deployer %}

        let (local deposited_amount) = Utils.parse_ether(1000)
        let (local borrowed_amount) = Utils.parse_ether(100)

        IERC20_Mintable.mint(dai, deployer, Uint256(deposited_amount, 0))
        IERC20_Mintable.approve(dai, pool, Uint256(deposited_amount, 0))

        IERC20_Mintable.mint(dai, USER_1, Uint256(deposited_amount, 0))
        %{ stop_prank_dai = start_prank(ids.USER_1, target_contract_address=ids.dai) %}
        IERC20_Mintable.approve(dai, pool, Uint256(deposited_amount, 0))
        %{ stop_prank_dai() %}

        IERC20_Mintable.mint(weth, USER_1, Uint256(deposited_amount, 0))
        %{ stop_prank_weth = start_prank(ids.USER_1, target_contract_address=ids.weth) %}
        IERC20_Mintable.approve(weth, pool, Uint256(deposited_amount, 0))
        %{ stop_prank_weth() %}

        IPool.supply(pool, dai, Uint256(deposited_amount, 0), deployer, 0)

        return ()
    end
end
