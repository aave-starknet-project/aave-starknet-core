%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.bool import TRUE
from contracts.protocol.interfaces.i_pool import IPOOL
# from openzeppelin.security.safemath import SafeUint256
from starkware.cairo.common.math import assert_le_felt
from contracts.protocol.tokenization.base.incentivized_erc20_storage import (
    IncentivizedERC20Storage,
    UserState,
)

const MAX_UINT128 = 2 ** 128

# modifiers

# @TODO: set onlyPool modifier
func incentivized_erc20_only_pool{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    alloc_locals
    let (caller_address) = get_caller_address()
    let (pool_) = IncentivizedERC20Storage.incentivized_erc20_pool()
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
    IncentivizedERC20Storage.incentivized_erc20_set_addresses_provider(addresses_provider)
    IncentivizedERC20Storage.incentivized_erc20_set_name(name)
    IncentivizedERC20Storage.incentivized_erc20_set_symbol(symbol)
    IncentivizedERC20Storage.incentivized_erc20_set_decimals(decimals)
    IncentivizedERC20Storage.incentivized_erc20_set_pool(pool)
    return ()
end

# @TODO:set a modifier
@external
func incentivized_erc20_increase_balance{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(address : felt, amount : felt):
    let (oldState) = IncentivizedERC20Storage.incentivized_erc20_UserState(address)

    with_attr error_message("value doesn't fit in 128 bits"):
        assert_le_felt(amount, MAX_UINT128)
    end

    let newBalance = oldState.balance + amount

    # @TODO: should there be more checks?
    with_attr error_message("result doesn't fit in 128 bits"):
        assert_le_felt(newBalance, MAX_UINT128)
    end

    let newState = UserState(newBalance, oldState.additionalData)
    IncentivizedERC20Storage.incentivized_erc20_set_UserState(address, newState)
    return ()
end

# @TODO:set a modifier
@external
func incentivized_erc20_decrease_balance{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(address : felt, amount : felt):
    let (oldState) = IncentivizedERC20Storage.incentivized_erc20_UserState(address)

    with_attr error_message("value doesn't fit in 128 bits"):
        assert_le_felt(amount, MAX_UINT128)
    end

    let newBalance = oldState.balance - amount

    with_attr error_message("result doesn't fit in 128 bits"):
        assert_le_felt(newBalance, MAX_UINT128)
    end

    let newState = UserState(newBalance, oldState.additionalData)
    IncentivizedERC20Storage.incentivized_erc20_set_UserState(address, newState)
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

    let (oldSenderState) = IncentivizedERC20Storage.incentivized_erc20_UserState(sender)
    let (oldRecipientState) = IncentivizedERC20Storage.incentivized_erc20_UserState(recipient)

    with_attr error_message("Not enough balance"):
        assert_le_felt(amount, oldSenderState.balance)
    end

    let newSenderBalance = oldSenderState.balance - amount
    let newSenderState = UserState(newSenderBalance, oldSenderState.additionalData)

    IncentivizedERC20Storage.incentivized_erc20_set_UserState(sender, newSenderState)

    let newRecipientBalance = oldRecipientState.balance + amount
    let newRecipientState = UserState(newRecipientBalance, oldRecipientState.additionalData)
    IncentivizedERC20Storage.incentivized_erc20_set_UserState(recipient, newRecipientState)

    # @TODO: import incentives_controller & handle action

    return ()
end

# Amount is passed as Uint256 but only Uint256.low used
@external
func transferFrom{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    sender : felt, recipient : felt, amount : Uint256
) -> (success : felt):
    let (caller_address) = get_caller_address()
    let (allowance) = IncentivizedERC20Storage.incentivized_erc20_allowance(sender, caller_address)

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

func _approve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    owner : felt, spender : felt, amount : felt
) -> ():
    IncentivizedERC20Storage.incentivized_erc20_set_allowance(owner, spender, amount)
    return ()
end

@external
func increaseAllowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    spender : felt, amount : Uint256
) -> (success : felt):
    alloc_locals
    let (caller_address) = get_caller_address()
    let (oldAllowance) = IncentivizedERC20Storage.incentivized_erc20_allowance(
        caller_address, spender
    )

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
    let (oldAllowance) = IncentivizedERC20Storage.incentivized_erc20_allowance(
        caller_address, spender
    )

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
func create_state{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    address : felt, amount : felt, index : felt
):
    let state = UserState(amount, index)
    IncentivizedERC20Storage.incentivized_erc20_set_UserState(address, state)
    return ()
end
