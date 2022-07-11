%lang starknet
from starkware.starknet.common.syscalls import get_contract_address
from starkware.cairo.common.cairo_builtins import HashBuiltin
from contracts.interfaces.i_pool import IPool
from contracts.interfaces.i_proxy import IProxy
# importing this will execute all test cases in that file.
from tests.e2e_tests.pool_drop_spec import PoolDropSpec
from tests.e2e_tests.pool_get_reserve_address_by_id import PoolGetReserveAddressByIdSpec
from tests.e2e_tests.pool_supply_withdraw_spec import PoolSupplyWithdrawSpec
from tests.e2e_tests.pool_addresses_provider_spec import PoolAddressesProviderSpec
from tests.utils.constants import USER_1

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


        #declare class implementation of basic_proxy_impl
        # TODO delete this once pool is a proxy-compatible contract, then we'll use pool
        context.implementation_hash = declare("./tests/contracts/basic_proxy_impl.cairo").class_hash

        # declare proxy_class_hash so that starknet knows about it. It's required to deploy proxies from PoolAddressesProvider
        declared_proxy = declare("./lib/cairo_contracts/src/openzeppelin/upgrades/Proxy.cairo")
        context.proxy_class_hash = declared_proxy.class_hash

        # deploy OZ proxy contract, owner is deployer. Implementation hash is basic_proxy_impl upon deployment.
        prepared_proxy = prepare(declared_proxy,{"implementation_hash":context.implementation_hash})
        context.proxy = deploy(prepared_proxy).contract_address

        # deploy poolAddressesProvider, market_id = 1, prank get_caller_address so that it returns deployer
        # We need a cheatcode to mock the deployer address, so we declare->prepare->mock_caller->deploy
        declared_pool_addresses_provider = declare("./contracts/protocol/configuration/pool_addresses_provider.cairo")
        prepared_pool_addresses_provider = prepare(declared_pool_addresses_provider, {"market_id":1,"owner":ids.deployer,"proxy_class_hash":context.proxy_class_hash})
        stop_prank = start_prank(0, target_contract_address=prepared_pool_addresses_provider.contract_address)
        context.pool_addresses_provider = deploy(prepared_pool_addresses_provider).contract_address
        stop_prank()

        context.deployer = ids.deployer
    %}

    tempvar pool
    tempvar dai
    tempvar weth
    tempvar aDAI
    tempvar aWETH
    tempvar proxy
    %{ ids.pool = context.pool %}
    %{ ids.dai = context.dai %}
    %{ ids.weth= context.weth %}
    %{ ids.aDAI = context.aDAI %}
    %{ ids.aWETH = context.aWETH %}
    %{ ids.proxy = context.proxy %}

    # Initializes a proxy with user 1 as admin
    IProxy.initialize(proxy, USER_1)

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

@external
func test_owner_adds_a_new_address_as_proxy{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    PoolAddressesProviderSpec.test_owner_adds_a_new_address_as_proxy()
    return ()
end
