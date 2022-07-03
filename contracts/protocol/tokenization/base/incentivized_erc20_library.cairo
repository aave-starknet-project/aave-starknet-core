%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.bool import TRUE
from contracts.interfaces.i_pool import IPOOL
from starkware.cairo.common.math import assert_le_felt


# @dev UserState - additionalData is a flexible field.
# ATokens and VariableDebtTokens use this field store the index of the user's last supply/withdrawal/borrow/repayment.
# StableDebtTokens use this field to store the user's stable rate.
struct UserState:
    member balance : felt
    member additionalData : felt
end

const MAX_UINT128 = 2 ** 128

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



# modifiers

# @TODO: set onlyPool modifier
func incentivized_erc20_only_pool{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    alloc_locals
    let (caller_address) = get_caller_address()
    let (pool_) = POOL.read()
    with_attr error_message("Caller address should be bridge: {l2_bridge_}"):
        assert caller_address = pool_
    end
    return ()
end

# @TODO: set onlyPoolAdmin modifier
func incentivized_erc20_only_pool_admin{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    # let (caller_address) = get_caller_address()

    # @TODO: get pool admin from IACLManager
    return ()
end



#Internal functions- not to be imported

# @dev the amount should be passed as uint128
func _transfer{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    sender : felt, recipient : felt, amount : felt
) -> ():
    alloc_locals

    with_attr error_message("value doesn't fit in 128 bits"):
        assert_le_felt(amount, MAX_UINT128)
    end

    let (oldSenderState) = _userState.read(sender)

    with_attr error_message("Not enough balance"):
        assert_le_felt(amount, oldSenderState.balance)
    end

    let newSenderBalance = oldSenderState.balance - amount
    let newSenderState = UserState(newSenderBalance, oldSenderState.additionalData)
    _userState.write(sender, newSenderState)

    let (oldRecipientState) = _userState.read(recipient)
    let newRecipientBalance = oldRecipientState.balance + amount
    let newRecipientState = UserState(newRecipientBalance, oldRecipientState.additionalData)
    _userState.write(recipient, newRecipientState)

    # @TODO: import incentives_controller & handle action

    return ()
end


func _approve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    owner : felt, spender : felt, amount : felt
) -> ():
    _allowances.write(owner, spender, amount)
    return ()
end



namespace IncentivizedERC20Library:


    # GETTERS

    # returns the address of the IncentivesController
    # @view
    func getIncentivesController{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }() -> (incentives_controller : felt):
        let (incentives_controller) = _incentivesController.read()
        return (incentives_controller)
    end

    # @view
    func name{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ) -> (name : felt):
        let (name) = _name.read()
        return (name)
    end

    # @view
    func symbol{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }() -> (symbol : felt):
        let (symbol) = _symbol.read()
        return (symbol)
    end

    # @view
    func totalSupply{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }() -> (totalSupply : Uint256):
        let (totalSupply : Uint256) = _totalSupply.read()
        return (totalSupply)
    end

    # @view
    func decimals{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }() -> (decimals : felt):
        let (decimals) = _decimals.read()
        return (decimals)
    end

    # @view
    func balanceOf{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(account : felt) -> (balance : felt):
        let (state : UserState) = _userState.read(account)
        return (state.balance)
    end

    # @view
    func allowance{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(owner : felt, spender : felt) -> (remaining : felt):
        let (remaining) = _allowances.read(owner, spender)
        return (remaining)
    end


    #SETTERS

    func set_name{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(name : felt):
        _name.write(name)
        return ()
    end

    func set_symbol{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(symbol : felt):
        _symbol.write(symbol)
        return ()
    end

    func set_decimals{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(decimals : felt):
        _decimals.write(decimals)
        return ()
    end


    # @TODO: set onlyPoolAdmin modifier
    func set_incentives_controller{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(IAaveIncentivesController : felt):
        _incentivesController.write(IAaveIncentivesController)
        return ()
    end



    func initialize{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(pool : felt, name : felt, symbol : felt, decimals : felt):
        alloc_locals
        let (addresses_provider) = IPOOL.get_addresses_provider(contract_address=pool)
        _addressesProvider.write(addresses_provider)
        _name.write(name)
        _symbol.write(symbol)
        _decimals.write(decimals)
        POOL.write(pool)
        return ()
    end


    # @TODO:set a modifier
    func increase_balance{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(address : felt, amount : felt):
        let (oldState) = _userState.read(address)

        with_attr error_message("value doesn't fit in 128 bits"):
            assert_le_felt(amount, MAX_UINT128)
        end

        let newBalance = oldState.balance + amount

        # @TODO: should there be more checks?
        with_attr error_message("result doesn't fit in 128 bits"):
            assert_le_felt(newBalance, MAX_UINT128)
        end

        let newState = UserState(newBalance, oldState.additionalData)
        _userState.write(address, newState)
        return ()
    end


    # @TODO:set a modifier
    func decrease_balance{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(address : felt, amount : felt):
        let (oldState) = _userState.read(address)

        with_attr error_message("value doesn't fit in 128 bits"):
            assert_le_felt(amount, MAX_UINT128)
        end

        let newBalance = oldState.balance - amount

        with_attr error_message("result doesn't fit in 128 bits"):
            assert_le_felt(newBalance, MAX_UINT128)
        end

        let newState = UserState(newBalance, oldState.additionalData)
        _userState.write(address, newState)
        return ()
    end


    func transfer{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        recipient : felt, amount : Uint256
    ) -> (success : felt):
        let (caller_address) = get_caller_address()

        _transfer(caller_address, recipient, amount.low)

        return (TRUE)
    end


    func transferFrom{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        sender : felt, recipient : felt, amount : Uint256
    ) -> (success : felt):
        let (caller_address) = get_caller_address()
        let (allowance) = _allowances.read(sender, caller_address)

        with_attr error_message("amount doesn't fit in 128 bits"):
            assert_le_felt(amount.low, MAX_UINT128)
        end

        let new_allowance = allowance - amount.low

        with_attr error_message("result doesn't fit in 128 bits"):
            assert_le_felt(new_allowance, MAX_UINT128)
        end

        _approve(sender, caller_address, new_allowance)
        _transfer(sender, recipient, amount.low)

        return (TRUE)
    end


    # Amount is passed as Uint256 but only .low is used
    func approve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        spender : felt, amount : Uint256
    ) -> ():
        let (caller_address) = get_caller_address()

        with_attr error_message("amount doesn't fit in 128 bits"):
            assert_le_felt(amount.low, MAX_UINT128)
        end

        _approve(caller_address, spender, amount.low)
        return ()
    end


    func increaseAllowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        spender : felt, amount : Uint256
    ) -> (success : felt):
        alloc_locals
        let (caller_address) = get_caller_address()
        let (oldAllowance) = _allowances.read(caller_address, spender)

        with_attr error_message("amount doesn't fit in 128 bits"):
            assert_le_felt(amount.low, MAX_UINT128)
        end

        let newAllowance = oldAllowance + amount.low

        with_attr error_message("result doesn't fit in 128 bits"):
            assert_le_felt(newAllowance, MAX_UINT128)
        end

        _approve(caller_address, spender, newAllowance)

        return (TRUE)
    end


    func decreaseAllowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        spender : felt, amount : Uint256
    ) -> (success : felt):
        alloc_locals
        let (caller_address) = get_caller_address()
        let (oldAllowance) = _allowances.read(caller_address, spender)

        with_attr error_message("amount doesn't fit in 128 bits"):
            assert_le_felt(amount.low, MAX_UINT128)
        end

        let newAllowance = oldAllowance - amount.low

        with_attr error_message("result doesn't fit in 128 bits"):
            assert_le_felt(newAllowance, MAX_UINT128)
        end

        _approve(caller_address, spender, newAllowance)

        return (TRUE)
    end


    # Test function to be removed
    func create_state{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        address : felt, amount : felt, index : felt
    ):
        let state = UserState(amount, index)
        _userState.write(address, state)
        return ()
    end
end
