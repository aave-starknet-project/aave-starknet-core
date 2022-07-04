%lang starknet
from starkware.cairo.common.uint256 import Uint256
<<<<<<< HEAD
from contracts.interfaces.i_incentivized_erc20 import IIncentivizedERC20
=======
from contracts.interfaces.i_incentivized_erc20 import IncentivizedERC20
>>>>>>> 50ee405 (remove test functions)

const PRANK_USER1 = 123
const PRANK_USER2 = 456

@view
func __setup__():
    # deploy pool contract first
    %{ context.pool = deploy_contract("./contracts/protocol/pool/pool.cairo",[0]).contract_address %}
    %{ context.name= 1 %}
    %{ context.symbol= 2 %}
    %{ context.decimals= 3 %}
    %{
        context.incentivized_erc_20=deploy_contract("./contracts/protocol/tokenization/base/incentivized_erc20.cairo", 
           [context.pool, context.name, context.symbol, context.decimals]).contract_address
    %}

    return ()
end

@external
func test_incentivizedERC20_initialization{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals

<<<<<<< HEAD
    local incentivized_erc20_address : felt
=======
    local IncentivizedERC20_address : felt
>>>>>>> 50ee405 (remove test functions)
    local name : felt
    local symbol : felt
    local decimals : felt

    %{
<<<<<<< HEAD
        ids.incentivized_erc20_address = context.incentivized_erc_20
=======
        ids.IncentivizedERC20_address = context.incentivized_erc_20
>>>>>>> 50ee405 (remove test functions)
        ids.name=context.name
        ids.symbol=context.symbol
        ids.decimals=context.decimals
    %}

<<<<<<< HEAD
    let (res_name) = IIncentivizedERC20.name(contract_address=incentivized_erc20_address)
    assert res_name = name

    let (res_symbol) = IIncentivizedERC20.symbol(contract_address=incentivized_erc20_address)
    assert res_symbol = symbol

    let (res_decimals) = IIncentivizedERC20.decimals(contract_address=incentivized_erc20_address)
=======
    let (res_name) = IncentivizedERC20.name(contract_address=IncentivizedERC20_address)
    assert res_name = name

    let (res_symbol) = IncentivizedERC20.symbol(contract_address=IncentivizedERC20_address)
    assert res_symbol = symbol

    let (res_decimals) = IncentivizedERC20.decimals(contract_address=IncentivizedERC20_address)
>>>>>>> 50ee405 (remove test functions)
    assert res_decimals = decimals

    return ()
end
<<<<<<< HEAD
=======

@external
func test_incentivizedERC20_setters{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals

    local IncentivizedERC20_address : felt

    %{ ids.IncentivizedERC20_address = context.incentivized_erc_20 %}

    IncentivizedERC20.set_name(contract_address=IncentivizedERC20_address, name=5)
    IncentivizedERC20.set_symbol(contract_address=IncentivizedERC20_address, symbol=6)
    IncentivizedERC20.set_decimals(contract_address=IncentivizedERC20_address, decimals=7)

    let (res_name) = IncentivizedERC20.name(contract_address=IncentivizedERC20_address)
    assert res_name = 5

    let (res_symbol) = IncentivizedERC20.symbol(contract_address=IncentivizedERC20_address)
    assert res_symbol = 6

    let (res_decimals) = IncentivizedERC20.decimals(contract_address=IncentivizedERC20_address)
    assert res_decimals = 7

    return ()
end



>>>>>>> 50ee405 (remove test functions)
