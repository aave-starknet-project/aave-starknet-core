%lang starknet
from starkware.starknet.common.syscalls import get_contract_address
from contracts.interfaces.i_pool import IPool
# importing this will execute all test cases in that file.
from tests.e2e_tests.pool_drop_spec import PoolDropSpec
from tests.e2e_tests.pool_get_reserve_address_by_id import PoolGetReserveAddressById
from tests.e2e_tests.pool_supply_withdraw_spec import PoolSupplyWithdrawSpec

@external
func __setup__{syscall_ptr : felt*, range_check_ptr}():
    let (deployer) = get_contract_address()
    %{
        context.pool = deploy_contract("./contracts/protocol/pool/pool.cairo",[0]).contract_address

        #deploy DAI/DAI, owner is deployer, supply is 0
        context.dai = deploy_contract("./lib/cairo_contracts/src/openzeppelin/token/erc20/ERC20_Mintable.cairo", [4473161,4473161,18,0,0,ids.deployer, ids.deployer]).contract_address 

        #deploy WETH/WETH, owner is deployer, supply is 0
        context.weth = deploy_contract("./lib/cairo_contracts/src/openzeppelin/token/erc20/ERC20_Mintable.cairo", [1464161352,1464161352,18,0,0,ids.deployer, ids.deployer]).contract_address

         #deploy aDai/aDAI, owner is pool, supply is 0
        context.aDAI = deploy_contract("./contracts/protocol/tokenization/a_token.cairo", [1631863113,1631863113,18,0,0,ids.deployer, context.pool, context.dai]).contract_address

         #deploy aWETH/aWETH, owner is pool, supply is 0
        context.aWETH = deploy_contract("./contracts/protocol/tokenization/a_token.cairo", [418075989064,418075989064,18,0,0,context.pool, ids.deployer, context.weth]).contract_address

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
