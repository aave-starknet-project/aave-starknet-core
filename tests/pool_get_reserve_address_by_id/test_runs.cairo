%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from contracts.interfaces.i_pool import IPool
from starkware.starknet.common.syscalls import get_contract_address
# importing this will execute all test cases in that file.
from tests.pool_get_reserve_address_by_id.pool_get_reserve_address_by_id import PoolGetReserveAddressById


@external
func __setup__{syscall_ptr : felt*, range_check_ptr}():
    let (deployer) = get_contract_address()
    %{
        context.pool = deploy_contract("./contracts/protocol/pool/pool.cairo",[0]).contract_address

        #deploy USDC, owner is deployer, supply is 0
        context.usdc = deploy_contract("./tests/contracts/ERC20_Mintable.cairo", 
            {
                "name": "USDC",
                "symbol": "USDC",
                "decimals": 18,
                "initial_supply": 0,
                "recipient": ids.deployer,
                "owner": ids.deployer
            }
        ).contract_address 

        #deploy aUSDC, owner is pool, supply is 0
        context.aUSDC = deploy_contract("./tests/contracts/ERC20_Mintable.cairo", 
            {
                "name": "aUSDC",
                "symbol": "aUSDC",
                "decimals": 18,
                "initial_supply": 0,
                "recipient": ids.deployer,
                "owner": context.pool
            }
        ).contract_address 

        context.deployer = ids.deployer
    %}
    tempvar pool
    tempvar usdc
    tempvar aUSDC
    %{ 
        ids.pool = context.pool
        ids.usdc = context.usdc
        ids.aUSDC = context.aUSDC
    %}

    IPool.init_reserve(pool, usdc, aUSDC)
    return ()
end
