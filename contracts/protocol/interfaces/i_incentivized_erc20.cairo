%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IncentivizedERC20:
    func incentivized_erc20_pool() -> (res : felt):
    end
    func incentivized_erc20_initialize(pool : felt, name : felt, symbol : felt, decimals : felt):
    end

    func incentivized_erc20_symbol() -> (symbol : felt):
    end

    func incentivized_erc20_name() -> (name : felt):
    end

    func incentivized_erc20_decimals() -> (decimals : felt):
    end

    func incentivized_erc20_set_name(name : felt):
    end

    func incentivized_erc20_set_symbol(symbol : felt):
    end

    func incentivized_erc20_set_decimals(decimals : felt):
    end

    # temporary
    func create_state(address : felt, amount : felt, index : felt):
    end

    func incentivized_erc20_increase_balance(address : felt, amount : felt):
    end

    func incentivized_erc20_decrease_balance(address : felt, amount : felt):
    end

    func incentivized_erc20_balanceOf(account : felt) -> (balance : felt):
    end

    func incentivized_erc20_allowance(owner : felt, spender : felt) -> (remaining : felt):
    end

    func transfer(recipient : felt, amount : Uint256):
    end

    func increaseAllowance(spender : felt, amount : Uint256) -> (success : felt):
    end

    func decreaseAllowance(spender : felt, amount : Uint256) -> (success : felt):
    end

    func approve(spender : felt, amount : Uint256):
    end

    func transferFrom(sender : felt, recipient : felt, amount : Uint256) -> (success : felt):
    end
end
