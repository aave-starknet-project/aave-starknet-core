%lang starknet
from starkware.starknet.common.syscalls import get_contract_address
from starkware.cairo.common.cairo_builtins import HashBuiltin

from contracts.interfaces.i_pool import IPool

from tests.test_suites.test_specs.pool_drop_spec import TestPoolDropDeployed
from tests.test_suites.test_specs.pool_get_reserve_address_by_id_spec import (
    TestPoolGetReserveAddressByIdDeployed,
)
from tests.test_suites.test_specs.pool_supply_withdraw_spec import TestPoolSupplyWithdrawDeployed

# @notice setup hook for the test execution. It deploys the contracts
# saves the Starknet state at the end of this function. All test cases will be executed
# from this saved state.
@external
func __setup__{syscall_ptr : felt*, range_check_ptr}():
    let (deployer) = get_contract_address()
    %{
        def str_to_felt(text):
            MAX_LEN_FELT = 31
            if len(text) > MAX_LEN_FELT:
                raise Exception("Text length too long to convert to felt.")

            return int.from_bytes(text.encode(), "big")
            
        context.pool = deploy_contract("./contracts/protocol/pool/pool.cairo",{"provider":0}).contract_address

        #deploy DAI/DAI, owner is deployer, supply is 0
        context.dai = deploy_contract("./lib/cairo_contracts/src/openzeppelin/token/erc20/ERC20_Mintable.cairo",
         {"name":str_to_felt("DAI"),"symbol":str_to_felt("DAI"),"decimals":18,"initial_supply":{"low":0,"high":0},"recipient":ids.deployer,"owner": ids.deployer}).contract_address 

        #deploy WETH/WETH, owner is deployer, supply is 0
        context.weth = deploy_contract("./lib/cairo_contracts/src/openzeppelin/token/erc20/ERC20_Mintable.cairo",  {"name":str_to_felt("WETH"),"symbol":str_to_felt("WETH"),"decimals":18,"initial_supply":{"low":0,"high":0},"recipient":ids.deployer,"owner": ids.deployer}).contract_address 

         #deploy aDai/aDAI, owner is pool, supply is 0
        context.aDAI = deploy_contract("./contracts/protocol/tokenization/a_token.cairo", {"pool":context.pool,"treasury":1631863113,"underlying_asset":context.dai,"incentives_controller":43232, "a_token_decimals":18,"a_token_name":str_to_felt("aDAI"),"a_token_symbol":str_to_felt("aDAI")}).contract_address

         #deploy aWETH/aWETH, owner is pool, supply is 0
        context.aWETH = deploy_contract("./contracts/protocol/tokenization/a_token.cairo", {"pool":context.pool,"treasury":1631863113,"underlying_asset":context.weth,"incentives_controller":43232, "a_token_decimals":18,"a_token_name":str_to_felt("aWETH"),"a_token_symbol":str_to_felt("aWETH")}).contract_address

        context.deployer = ids.deployer
    %}
    tempvar pool
    tempvar dai
    tempvar weth
    tempvar aDAI
    tempvar aWETH
    %{ ids.pool = context.pool %}
    %{ ids.dai = context.dai %}
    %{ ids.weth= context.weth %}
    %{ ids.aDAI = context.aDAI %}
    %{ ids.aWETH = context.aWETH %}

    IPool.init_reserve(pool, dai, aDAI)
    IPool.init_reserve(pool, weth, aWETH)
    return ()
end

#
# Test cases imported from test specifications
#

# Test fails because AToken.balanceOf is not implemented
# @external
# func test_user_1_deposits_DAI_user_2_borrow_DAI_stable_and_variable_should_fail_to_drop_DAI_reserve{
#     syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
# }():
#     TestPoolDropDeployed.test_user_1_deposits_DAI_user_2_borrow_DAI_stable_and_variable_should_fail_to_drop_DAI_reserve(
#         )
#     return ()
# end

@external
func test_user_2_repays_debts_drop_DAI_reserve_should_fail{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestPoolDropDeployed.test_user_2_repays_debts_drop_DAI_reserve_should_fail()
    return ()
end

# test_pool_drop_3
@external
func test_user_1_withdraw_DAI_drop_DAI_reserve_should_succeed{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestPoolDropDeployed.test_user_1_withdraw_DAI_drop_DAI_reserve_should_succeed()
    return ()
end

@external
func test_drop_an_asset_that_is_not_a_listed_reserve_should_fail{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestPoolDropDeployed.test_drop_an_asset_that_is_not_a_listed_reserve_should_fail()
    return ()
end

@external
func test_dropping_zero_address_should_fail{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestPoolDropDeployed.test_dropping_zero_address_should_fail()
    return ()
end

@external
func test_get_address_of_reserve_by_id{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestPoolGetReserveAddressByIdDeployed.test_get_address_of_reserve_by_id()
    return ()
end

@external
func test_get_max_number_reserves{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestPoolGetReserveAddressByIdDeployed.test_get_address_of_reserve_by_id()
    return ()
end

@external
func test_pool_supply_withdraw_1{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ):
    TestPoolSupplyWithdrawDeployed.test_pool_supply_withdraw_spec_1()
    return ()
end

@external
func test_pool_supply_withdraw_2{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ):
    TestPoolSupplyWithdrawDeployed.test_pool_supply_withdraw_spec_2()
    return ()
end

@external
func test_pool_supply_withdraw_3{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ):
    TestPoolSupplyWithdrawDeployed.test_pool_supply_withdraw_spec_3()
    return ()
end

@external
func test_pool_supply_withdraw_4{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ):
    TestPoolSupplyWithdrawDeployed.test_pool_supply_withdraw_spec_4()
    return ()
end
