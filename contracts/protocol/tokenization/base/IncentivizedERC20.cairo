%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.uint256 import Uint256, uint256_add, uint256_sub
from starkware.cairo.common.bool import TRUE
# from lib.cairo_contracts.src.openzeppelin.security.safemath import (
# uint256_checked_add, uint256_checked_sub_le)
# from openzeppelin.token.erc20.library import ERC20
from contracts.protocol.interfaces.IPool import IPOOL

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
func incentivized_erc20_only_Pool{
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
func incentivized_erc20_only_PoolAdmin{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (caller_address) = get_caller_address()

    # @TODO: get pool admin from IACLManager
    return ()
end

# getters

@view
func get_pool{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (res : felt):
    let (res) = POOL.read()
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
