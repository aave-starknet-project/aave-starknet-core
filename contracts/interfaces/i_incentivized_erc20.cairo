%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IIncentivizedERC20:
    func constructor(pool : felt, name : felt, symbol : felt, decimals : felt):
    end

    func symbol() -> (symbol : felt):
    end

    func name() -> (name : felt):
    end

    func decimals() -> (decimals : felt):
    end

    func increase_balance(address : felt, amount : felt):
    end

    func decrease_balance(address : felt, amount : felt):
    end

    func balanceOf(account : felt) -> (balance : felt):
    end

    func totalSupply() -> (totalSupply : Uint256):
    end

    func allowance(owner : felt, spender : felt) -> (remaining : felt):
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
<<<<<<< HEAD
=======

    func mint(address : felt, amount : felt):
    end

    func burn(address : felt, amount : felt):
    end
>>>>>>> 50ee405 (remove test functions)
end
