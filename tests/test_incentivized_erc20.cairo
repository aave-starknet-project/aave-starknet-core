%lang starknet

@contract_interface
namespace IncentivizedERC20:
    func incentivized_erc20_pool() -> (res : felt):
    end
    func incentivized_erc20_initialize(pool : felt, name : felt, symbol : felt, decimals : felt):
    end
end

@view
func __setup__():
    # deploy pool contract first
    %{ context.pool = deploy_contract("./contracts/protocol/pool/Pool.cairo").contract_address %}
    return ()
end
@external
func test_incentivizedERC20_contract{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals

    local IncentivizedERC20_address : felt
    local pool_address : felt

    %{
        ids.IncentivizedERC20_address = deploy_contract("./contracts/protocol/tokenization/base/incentivized_erc20.cairo").contract_address
        ids.pool_address=context.pool
    %}
    IncentivizedERC20.incentivized_erc20_initialize(
        IncentivizedERC20_address, pool_address, 2, 3, 4)
    let (res) = IncentivizedERC20.incentivized_erc20_pool(
        contract_address=IncentivizedERC20_address)
    assert res = pool_address

    return ()
end
