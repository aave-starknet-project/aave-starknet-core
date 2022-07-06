%lang starknet
from starkware.starknet.common.syscalls import get_contract_address
from starkware.cairo.common.cairo_builtins import HashBuiltin
from contracts.interfaces.i_pool import IPool
# importing this will execute all test cases in that file.
from tests.e2e_tests.pool_drop_spec import PoolDropSpec
from tests.e2e_tests.pool_get_reserve_address_by_id import PoolGetReserveAddressByIdSpec
from tests.e2e_tests.pool_supply_withdraw_spec import PoolSupplyWithdrawSpec

const DAI_STRING = 4473161
const aDAI_STRING = 1631863113
const WETH_STRING = 1464161352
const aWETH_STRING = 418075989064
@external
func __setup__{syscall_ptr : felt*, range_check_ptr}():
    let (deployer) = get_contract_address()
    %{
        context.pool = deploy_contract("./contracts/protocol/pool/pool.cairo",[0]).contract_address

        #deploy DAI/DAI, owner is deployer, supply is 0
        context.dai = deploy_contract("./lib/cairo_contracts/src/openzeppelin/token/erc20/ERC20_Mintable.cairo", [ids.DAI_STRING,ids.DAI_STRING,18,0,0,ids.deployer, ids.deployer]).contract_address 

        #deploy WETH/WETH, owner is deployer, supply is 0
        context.weth = deploy_contract("./lib/cairo_contracts/src/openzeppelin/token/erc20/ERC20_Mintable.cairo", [ids.WETH_STRING,ids.WETH_STRING,18,0,0,ids.deployer, ids.deployer]).contract_address

         #deploy aDai/aDAI, owner is pool, supply is 0
        context.aDAI = deploy_contract("./contracts/protocol/tokenization/a_token.cairo", [context.pool,1631863113,context.dai,43232,18,ids.aDAI_STRING,ids.aDAI_STRING]).contract_address

         #deploy aWETH/aWETH, owner is pool, supply is 0
        context.aWETH = deploy_contract("./contracts/protocol/tokenization/a_token.cairo", [context.pool,1631863113,context.dai,43232,18,ids.aWETH_STRING,ids.aWETH_STRING]).contract_address

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

@external
func test_pool_drop_1{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    PoolDropSpec.test_pool_drop_spec_1()
    return ()
end

@external
func test_pool_drop_2{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    PoolDropSpec.test_pool_drop_spec_2()
    return ()
end

# test_pool_drop_3
@external
func test_pool_drop_3{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    PoolDropSpec.test_pool_drop_spec_3()
    return ()
end

@external
func test_pool_drop_4{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    PoolDropSpec.test_pool_drop_spec_4()
    return ()
end

@external
func test_pool_drop_5{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    PoolDropSpec.test_pool_drop_spec_5()
    return ()
end

@external
func test_get_address_of_reserve_by_id{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    PoolGetReserveAddressByIdSpec.test_get_address_of_reserve_by_id()
    return ()
end

@external
func test_get_max_number_reserves{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    PoolGetReserveAddressByIdSpec.test_get_address_of_reserve_by_id()
    return ()
end

@external
func test_pool_supply_withdraw_1{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ):
    PoolSupplyWithdrawSpec.test_pool_supply_withdraw_spec_1()
    return ()
end

@external
func test_pool_supply_withdraw_2{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ):
    PoolSupplyWithdrawSpec.test_pool_supply_withdraw_spec_2()
    return ()
end

@external
func test_pool_supply_withdraw_3{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ):
    PoolSupplyWithdrawSpec.test_pool_supply_withdraw_spec_3()
    return ()
end

@external
func test_pool_supply_withdraw_4{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ):
    PoolSupplyWithdrawSpec.test_pool_supply_withdraw_spec_4()
    return ()
end
