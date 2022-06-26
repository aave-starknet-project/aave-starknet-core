%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.bool import TRUE
from contracts.protocol.interfaces.IPool import IPOOL
# from openzeppelin.security.safemath import SafeUint256
from starkware.cairo.common.math import assert_le_felt

const MAX_UINT128 = 2 ** 128

# @dev UserState - additionalData is a flexible field.
# ATokens and VariableDebtTokens use this field store the index of the user's last supply/withdrawal/borrow/repayment.
# StableDebtTokens use this field to store the user's stable rate.
# instead of using a struct we will be relying on a Uint256 where
# low: balance
# high: additionalData
@storage_var
func _userState(address : felt) -> (state : Uint256):
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

# @param pool The reference to the main Pool contract
# @param name The name of the token
# @param symbol The symbol of the token
# @param decimals The number of decimals of the token

@external
func incentivized_erc20_initialize{
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
}(user : felt) -> (res : Uint256):
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
func incentivized_erc20_symbol{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ) -> (symbol : felt):
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
func incentivized_erc20_decimals{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ) -> (decimals : felt):
    let (decimals) = _decimals.read()
    return (decimals)
end

@view
func incentivized_erc20_balanceOf{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(account : felt) -> (balance : felt):
    let (state : Uint256) = _userState.read(account)
    return (state.low)
end

@view
func incentivized_erc20_allowance{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(owner : felt, spender : felt) -> (remaining : felt):
    let (remaining) = _allowances.read(owner, spender)
    return (remaining)
end

# setters
func incentivized_erc20_set_name{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    name : felt
):
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
func incentivized_erc20_set_IncentivesController{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(IAaveIncentivesController : felt):
    _incentivesController.write(IAaveIncentivesController)
    return ()
end

# @TODO:set a modifier
@external
func incentivized_erc20_increase_balance{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(address : felt, amount : felt):
    let (oldState) = _userState.read(address)

    with_attr error_message("value doesn't fit in 128 bits"):
        assert_le_felt(amount, MAX_UINT128)
    end

    let newBalance = oldState.low + amount

    # @TODO: should there be more checks?
    with_attr error_message("result doesn't fit in 128 bits"):
        assert_le_felt(newBalance, MAX_UINT128)
    end

    let newState = Uint256(newBalance, oldState.high)
    _userState.write(address, newState)
    return ()
end

# @TODO:set a modifier
@external
func incentivized_erc20_decrease_balance{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(address : felt, amount : felt):
    let (oldState) = _userState.read(address)

    with_attr error_message("value doesn't fit in 128 bits"):
        assert_le_felt(amount, MAX_UINT128)
    end

    let newBalance = oldState.low - amount

    with_attr error_message("result doesn't fit in 128 bits"):
        assert_le_felt(newBalance, MAX_UINT128)
    end

    let newState = Uint256(newBalance, oldState.high)
    _userState.write(address, newState)
    return ()
end

# Amount is passed as Uint256 but only Uint256.low is passed to _transfer
@external
func transfer{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    recipient : felt, amount : Uint256
) -> (success : felt):
    let (caller_address) = get_caller_address()

    _transfer(caller_address, recipient, amount.low)

    return (TRUE)
end

# @dev the amount should be passed as uint128
func _transfer{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    sender : felt, recipient : felt, amount : felt
) -> ():
    alloc_locals

    with_attr error_message("value doesn't fit in 128 bits"):
        assert_le_felt(amount, MAX_UINT128)
    end

    let (oldSenderState) = _userState.read(sender)
    let (oldRecipientState) = _userState.read(recipient)

    with_attr error_message("Not enough balance"):
        assert_le_felt(amount, oldSenderState.low)
    end

    let newSenderBalance = oldSenderState.low - amount
    let newSenderState = Uint256(newSenderBalance, oldSenderState.high)

    _userState.write(sender, newSenderState)

    let newRecipientBalance = oldRecipientState.low + amount
    let newRecipientState = Uint256(newRecipientBalance, oldRecipientState.high)
    _userState.write(recipient, newRecipientState)

    # @TODO: import incentives_controller & handle action

    return ()
end

# Amount is passed as Uint256 but only Uint256.low used
@external
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
@external
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

# Amount takes a uint128 or Uint256.low
func _approve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    owner : felt, spender : felt, amount : felt
) -> ():
    _allowances.write(owner, spender, amount)
    return ()
end

#
@external
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

@external
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
@external
func createState{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    address : felt, amount : felt, index : felt
):
    let state = Uint256(amount, index)
    _userState.write(address, state)
    return ()
end
