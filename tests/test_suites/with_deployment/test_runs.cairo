%lang starknet
from starkware.starknet.common.syscalls import get_contract_address
from starkware.cairo.common.cairo_builtins import HashBuiltin

from contracts.interfaces.i_pool import IPool

from tests.test_suites.test_specs.pool_drop_spec import TestPoolDropDeployed
from tests.test_suites.test_specs.pool_get_reserve_address_by_id_spec import (
    TestPoolGetReserveAddressByIdDeployed,
)
from tests.test_suites.test_specs.pool_supply_withdraw_spec import TestPoolSupplyWithdrawDeployed
from tests.test_suites.test_specs.pool_addresses_provider_spec import (
    TestPoolAddressesProviderDeployed,
)
from tests.test_suites.test_specs.atoken_modifiers import ATokenModifier

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


        #declare class implementation of basic_proxy_impl
        # TODO delete this once pool is a proxy-compatible contract, then we'll use pool
        context.implementation_hash = declare("./tests/contracts/basic_proxy_impl.cairo").class_hash

        # declare proxy_class_hash so that starknet knows about it. It's required to deploy proxies from PoolAddressesProvider
        declared_proxy = declare("./lib/cairo_contracts/src/openzeppelin/upgrades/Proxy.cairo")
        context.proxy_class_hash = declared_proxy.class_hash
        # deploy OZ proxy contract, admin is deployer. Implementation hash is basic_proxy_impl upon deployment.
        prepared_proxy = prepare(declared_proxy,{"implementation_hash":context.implementation_hash})
        context.proxy = deploy(prepared_proxy).contract_address

        # deploy poolAddressesProvider, market_id = 1, prank get_caller_address so that it returns deployer and we can set deployer as the owner.
        # We have proxy_class_hash as an argument because we store it to be able to deploy proxies from the pool_addresses_provider
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

@external
func test_owner_adds_a_new_address_as_proxy{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestPoolAddressesProviderDeployed.test_owner_adds_a_new_address_as_proxy()
    return ()
end

@external
func test_owner_adds_a_new_address_with_no_proxy_and_turns_it_into_a_proxy_1{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestPoolAddressesProviderDeployed.test_owner_adds_a_new_address_with_no_proxy_and_turns_it_into_a_proxy_1(
        )
    return ()
end

@external
func test_owner_adds_a_new_address_with_no_proxy_and_turns_it_into_a_proxy_2{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestPoolAddressesProviderDeployed.test_owner_adds_a_new_address_with_no_proxy_and_turns_it_into_a_proxy_2(
        )
    return ()
end

@external
func test_unregister_a_proxy_address{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestPoolAddressesProviderDeployed.test_unregister_a_proxy_address()
    return ()
end

@external
func test_owner_adds_a_new_address_with_proxy_and_turns_it_into_a_no_proxy{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestPoolAddressesProviderDeployed.test_owner_adds_a_new_address_with_proxy_and_turns_it_into_a_no_proxy(
        )
    return ()
end

@external
func test_unregister_a_no_proxy_address{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestPoolAddressesProviderDeployed.test_unregister_a_no_proxy_address()
    return ()
end

@external
func test_owner_registers_an_existing_contract_with_proxy_and_upgrade_it{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestPoolAddressesProviderDeployed.test_owner_registers_an_existing_contract_with_proxy_and_upgrade_it(
        )
    return ()
end

@external
func test_owner_updates_the_implementation_of_a_proxy_which_is_already_initialized{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestPoolAddressesProviderDeployed.test_owner_updates_the_implementation_of_a_proxy_which_is_already_initialized(
        )
    return ()
end

@external
func test_owner_updates_the_pool_configurator{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    TestPoolAddressesProviderDeployed.test_owner_updates_the_pool_configurator()
    return ()
end

@external
func test_burn_wrong_pool{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    ATokenModifier.test_burn_wrong_pool()
    return ()
end

@external
func test_transfer_on_liquidation_wrong_pool{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    ATokenModifier.test_transfer_on_liquidation_wrong_pool()
    return ()
end

@external
func test_transfer_underlying_wrong_pool{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    ATokenModifier.test_transfer_underlying_wrong_pool()
    return ()
end
