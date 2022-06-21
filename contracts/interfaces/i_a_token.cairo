%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IAToken:
    func name() -> (name : felt):
    end

    func symbol() -> (symbol : felt):
    end

    func totalSupply() -> (totalSupply : Uint256):
    end

    func decimals() -> (decimals : felt):
    end

    func balanceOf(account : felt) -> (balance : Uint256):
    end

    func allowance(owner : felt, spender : felt) -> (remaining : Uint256):
    end

    func RESERVE_TREASURY_ADDRESS() -> (res : felt):
    end

    func UNDERLYING_ASSET_ADDRESS() -> (res : felt):
    end

    func POOL() -> (res : felt):
    end

    func transfer(recipient : felt, amount : Uint256) -> (success : felt):
    end

    func transferFrom(sender : felt, recipient : felt, amount : Uint256) -> (success : felt):
    end

    func approve(spender : felt, amount : Uint256) -> (success : felt):
    end

    func increaseAllowance(spender : felt, added_value : Uint256) -> (success : felt):
    end

    func decreaseAllowance(spender : felt, subtracted_value : Uint256) -> (success : felt):
    end

    func mint(caller : felt, on_behalf_of : felt, amount : Uint256, index : Uint256) -> (
        success : felt
    ):
    end

    func burn(from_ : felt, receiver_or_underlying : felt, amount : Uint256, index : Uint256) -> (
        success : felt
    ):
    end

    func mint_to_treasury(amount : Uint256, index : Uint256) -> (success : felt):
    end

    func transfer_on_liquidation(from_ : felt, to : felt, value : Uint256):
    end

    func transfer_underlying_to(target : felt, amount : Uint256):
    end

    func handle_repayment(token : felt, to : felt, amount : Uint256):
    end

    func permit(token : felt, to : felt, amount : Uint256):
    end

    func rescue_tokens(token : felt, to : felt, amount : Uint256):
    end
end
