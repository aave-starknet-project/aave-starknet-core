%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256

# @dev UserState - additionalData is a flexible field.
# ATokens and VariableDebtTokens use this field store the index of the user's last supply/withdrawal/borrow/repayment.
# StableDebtTokens use this field to store the user's stable rate.
struct UserState:
    member balance : felt
    member additionalData : felt
end

@storage_var
func _userState(address : felt) -> (state : UserState):
end

@storage_var
func _allowances(delegator : felt, delegatee : felt) -> (allowance : felt):
end

@storage_var
func _totalSupply() -> (totalSupply : Uint256):
end

@storage_var
func _name() -> (name : felt):
end

@storage_var
func _symbol() -> (symbol : felt):
end

@storage_var
func _decimals() -> (decimals : felt):
end

@storage_var
func _incentivesController() -> (address : felt):
end

# addresses provider address
@storage_var
func _addressesProvider() -> (addressesProvider : felt):
end

# using pool address instead of interface
@storage_var
func POOL() -> (pool : felt):
end

@storage_var
func owner() -> (owner : felt):
end

namespace IncentivizedERC20Storage:
    # getters
    @view
    func incentivized_erc20_pool{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ) -> (res : felt):
        let (res) = POOL.read()
        return (res)
    end

    @view
    func incentivized_erc20_UserState{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(user : felt) -> (res : UserState):
        let (res) = _userState.read(user)
        return (res)
    end

    # returns the address of the IncentivesController
    @view
    func incentivized_erc20_IncentivesController{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }() -> (incentives_controller : felt):
        let (incentives_controller) = _incentivesController.read()
        return (incentives_controller)
    end

    @view
    func incentivized_erc20_name{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ) -> (name : felt):
        let (name) = _name.read()
        return (name)
    end

    @view
    func incentivized_erc20_symbol{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }() -> (symbol : felt):
        let (symbol) = _symbol.read()
        return (symbol)
    end

    @view
    func incentivized_erc20_totalSupply{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }() -> (totalSupply : Uint256):
        let (totalSupply : Uint256) = _totalSupply.read()
        return (totalSupply)
    end

    @view
    func incentivized_erc20_decimals{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }() -> (decimals : felt):
        let (decimals) = _decimals.read()
        return (decimals)
    end

    @view
    func incentivized_erc20_balanceOf{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(account : felt) -> (balance : felt):
        let (state : UserState) = _userState.read(account)
        return (state.balance)
    end

    @view
    func incentivized_erc20_allowance{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(owner : felt, spender : felt) -> (remaining : felt):
        let (remaining) = _allowances.read(owner, spender)
        return (remaining)
    end

    # setters

    func incentivized_erc20_set_name{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(name : felt):
        _name.write(name)
        return ()
    end

    func incentivized_erc20_set_symbol{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(symbol : felt):
        _symbol.write(symbol)
        return ()
    end

    func incentivized_erc20_set_decimals{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(decimals : felt):
        _decimals.write(decimals)
        return ()
    end

    # @TODO: set onlyPoolAdmin modifier
    func incentivized_erc20_set_incentives_controller{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(IAaveIncentivesController : felt):
        _incentivesController.write(IAaveIncentivesController)
        return ()
    end

    func incentivized_erc20_set_addresses_provider{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(provider : felt):
        _addressesProvider.write(provider)
        return ()
    end

    func incentivized_erc20_set_pool{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(pool : felt):
        POOL.write(pool)
        return ()
    end

    func incentivized_erc20_set_UserState{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(address : felt, state : UserState):
        _userState.write(address, state)
        return ()
    end

    func incentivized_erc20_set_allowance{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(delegator : felt, delegatee : felt, allowance : felt):
        _allowances.write(delegator, delegatee, allowance)
        return ()
    end
end
