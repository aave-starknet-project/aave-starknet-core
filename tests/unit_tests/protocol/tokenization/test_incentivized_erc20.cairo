%lang starknet
from contracts.interfaces.i_incentivized_erc20 import IIncentivizedERC20

const PRANK_USER1 = 123
const PRANK_USER2 = 456

@view
func __setup__():
    # deploy pool contract first
    %{ context.pool = deploy_contract("./contracts/protocol/pool/pool.cairo",{"provider":0}).contract_address %}
    %{ context.name= 1 %}
    %{ context.symbol= 2 %}
    %{ context.decimals= 3 %}
    %{
        context.incentivized_erc_20=deploy_contract("./contracts/protocol/tokenization/base/incentivized_erc20.cairo", 
           {"pool":context.pool,"name": context.name, "symbol":context.symbol, "decimals":context.decimals}).contract_address
    %}

    return ()
end

@external
func test_incentivizedERC20_initialization{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals

    local incentivized_erc20_address : felt
    local name : felt
    local symbol : felt
    local decimals : felt

    %{
        ids.incentivized_erc20_address = context.incentivized_erc_20
        ids.name=context.name
        ids.symbol=context.symbol
        ids.decimals=context.decimals
    %}

    let (res_name) = IIncentivizedERC20.name(contract_address=incentivized_erc20_address)
    assert res_name = name

    let (res_symbol) = IIncentivizedERC20.symbol(contract_address=incentivized_erc20_address)
    assert res_symbol = symbol

    let (res_decimals) = IIncentivizedERC20.decimals(contract_address=incentivized_erc20_address)
    assert res_decimals = decimals

    return ()
end
