%lang starknet

@contract_interface
namespace IncentivizedERC20:
    func get_pool() -> (res : felt):
    end
end

@view
func __setup__():
    # deploy pool contarct first
    %{ context.pool = deploy_contract("./contracts/protocol/pool/Pool.cairo").contract_address %}
    return ()
end
@external
func test_incentivizedERC20_contract{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals

    local IncentivizedERC20_address : felt
    local pool_address : felt

    %{
        ids.IncentivizedERC20_address = deploy_contract("./contracts/protocol/tokenization/base/incentivizedERC20.cairo", [context.pool , 2, 3,4]).contract_address
        ids.pool_address=context.pool
    %}

    let (res) = IncentivizedERC20.get_pool(contract_address=IncentivizedERC20_address)
    assert res = pool_address

    return ()
end
