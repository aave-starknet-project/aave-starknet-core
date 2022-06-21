%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.uint256 import Uint256, uint256_add, uint256_sub
from starkware.cairo.common.bool import TRUE
from openzeppelin.token.erc20.library import ERC20
from contracts.protocol.interfaces.IPool import IPOOL
from openzeppelin.security.safemath import SafeUint256
# @dev UserState - additionalData is a flexible field.
# ATokens and VariableDebtTokens use this field store the index of the user's last supply/withdrawal/borrow/repayment.
# StableDebtTokens use this field to store the user's stable rate.
struct UserState:
    member balance : Uint256
    member additionalData : Uint256
end

@storage_var
func _userState(address : felt) -> (state : UserState):
end

@storage_var
func _allowances(delegator : felt, delegatee : felt) -> (allowance : Uint256):
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

# onlyPool modifier
func incentivized_erc20_only_pool{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (caller_address) = get_caller_address()
    let (pool_) = POOL.read()
    with_attr error_message("Caller address should be bridge: {l2_bridge_}"):
        assert caller_address = pool_
    end
    return ()
end

# onlyPoolAdmin modifier
func incentivized_erc20_only_pool_admin{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (caller_address) = get_caller_address()

    # @TODO: get pool admin from IACLManager
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
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(user : felt) -> (
        res : UserState):
    let (res) = _userState.read(user)
    return (res)
end

# @param pool The reference to the main Pool contract
# @param name The name of the token
# @param symbol The symbol of the token
# @param decimals The number of decimals of the token

@external
func incentivized_erc20_initialize{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        pool : felt, name : felt, symbol : felt, decimals : felt):
    alloc_locals
    let (addresses_provider) = IPOOL.get_addresses_provider(contract_address=pool)
    _addressesProvider.write(addresses_provider)
    _name.write(name)
    _symbol.write(symbol)
    _decimals.write(decimals)
    POOL.write(pool)
    return ()
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
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        totalSupply : Uint256):
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
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(account : felt) -> (
        balance : Uint256):
    let (state : UserState) = _userState.read(account)
    return (state.balance)
end

@view
func incentivized_erc20_allowance{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        owner : felt, spender : felt) -> (remaining : Uint256):
    let (remaining : Uint256) = _allowances.read(owner, spender)
    return (remaining)
end

# @dev the amount should be passed as uint128
func _transfer{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        sender : felt, recipient : felt, amount : Uint256) -> ():
    alloc_locals
    let (oldSenderState) = _userState.read(sender)
    let (oldRecipientState) = _userState.read(recipient)

    let (newSenderBalance) = SafeUint256.sub_le(oldSenderState.balance, amount)
    let newSenderState = UserState(newSenderBalance, oldSenderState.additionalData)

    _userState.write(sender, newSenderState)

    let (newRecipientBalance) = SafeUint256.add(oldRecipientState.balance, amount)
    let newRecipientState = UserState(newRecipientBalance, oldRecipientState.additionalData)
    _userState.write(recipient, newRecipientState)

    # @TODO: import incentives_controller & handle action

    return ()
end

func _approve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        owner : felt, spender : felt, amount : Uint256) -> ():
    alloc_locals
    _allowances.write(owner, spender, amount)
    return ()
end
