%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.bool import TRUE
from contracts.interfaces.i_pool import IPool
from contracts.protocol.pool.pool_storage import PoolStorage
from starkware.cairo.common.math import assert_le_felt, assert_nn
from openzeppelin.security.safemath import SafeUint256
from contracts.protocol.libraries.helpers.uint_128 import Uint128

# @dev UserState - additionalData is a flexible field.
# ATokens and VariableDebtTokens use this field store the index of the user's last supply/withdrawal/borrow/repayment.
# StableDebtTokens use this field to store the user's stable rate.
struct UserState:
    member balance : felt
    member additionalData : felt
end

const MAX_UINT128 = 2 ** 128 - 1

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

# Internal functions- not to be imported

# @dev the amount should be passed as uint128
func _transfer{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    sender : felt, recipient : felt, amount : felt
) -> ():
    alloc_locals

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

namespace IncentivizedERC20:
    # modifiers
    func incentivized_erc20_only_pool{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        let (caller_address) = get_caller_address()
        let (pool_) = POOL.read()
        with_attr error_message("Caller must be pool"):
            assert caller_address = pool_
        end
        return ()
    end

    func incentivized_erc20_only_pool_admin{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        # let (caller_address) = get_caller_address()

        # @TODO: get pool admin from IACLManager
        return ()
    end

    # GETTERS

    # returns the address of the IncentivesController
    # @view
    func get_incentives_controller{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }() -> (incentives_controller : felt):
        let (incentives_controller) = _incentivesController.read()
        return (incentives_controller)
    end

    # @view
    func name{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (name : felt):
        let (name) = _name.read()
        return (name)
    end

    # @view
    func symbol{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        symbol : felt
    ):
        let (symbol) = _symbol.read()
        return (symbol)
    end

    # @view
    func total_supply{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        totalSupply : Uint256
    ):
        let (totalSupply : Uint256) = _totalSupply.read()
        return (totalSupply)
    end

    # @view
    func decimals{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        decimals : felt
    ):
        let (decimals) = _decimals.read()
        return (decimals)
    end

    # @view
    func balance_of{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        account : felt
    ) -> (balance : felt):
        let (state : UserState) = _userState.read(account)
        return (state.balance)
    end

    # @view
    func allowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        owner : felt, spender : felt
    ) -> (remaining : felt):
        let (remaining) = _allowances.read(owner, spender)
        return (remaining)
    end

    # SETTERS

    func set_name{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(name : felt):
        _name.write(name)
        return ()
    end

    func set_symbol{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        symbol : felt
    ):
        _symbol.write(symbol)
        return ()
    end

    func set_decimals{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        decimals : felt
    ):
        _decimals.write(decimals)
        return ()
    end

    func set_incentives_controller{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(IAaveIncentivesController : felt):
        _incentivesController.write(IAaveIncentivesController)
        return ()
    end

    func initialize{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        pool : felt, name : felt, symbol : felt, decimals : felt
    ):
        let (addresses_provider) = IPool.get_addresses_provider(contract_address=pool)
        _addressesProvider.write(addresses_provider)
        _name.write(name)
        _symbol.write(symbol)
        _decimals.write(decimals)
        POOL.write(pool)
        return ()
    end

    func transfer{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        recipient : felt, amount : Uint256
    ) -> (success : felt):
        let (caller_address) = get_caller_address()
        let (amount_128) = Uint128.to_uint_128(amount)

        _transfer(caller_address, recipient, amount_128)

        return (TRUE)
    end

    func transfer_from{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        sender : felt, recipient : felt, amount : Uint256
    ) -> (success : felt):
        let (caller_address) = get_caller_address()
        let (allowance) = _allowances.read(sender, caller_address)
        let (amount_128) = Uint128.to_uint_128(amount)

        let new_allowance = allowance - amount_128

        with_attr error_message("result doesn't fit in 128 bits"):
            assert_le_felt(new_allowance, MAX_UINT128)
        end

        _approve(sender, caller_address, new_allowance)
        _transfer(sender, recipient, amount_128)

        return (TRUE)
    end

    # Amount is passed as Uint256 but only .low is used
    func approve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        spender : felt, amount : Uint256
    ) -> ():
        let (caller_address) = get_caller_address()

        let (amount_128) = Uint128.to_uint_128(amount)

        _approve(caller_address, spender, amount_128)
        return ()
    end

    func increase_allowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        spender : felt, amount : Uint256
    ) -> (success : felt):
        alloc_locals
        let (caller_address) = get_caller_address()
        let (oldAllowance) = _allowances.read(caller_address, spender)

        let (amount_128) = Uint128.to_uint_128(amount)

        let newAllowance = oldAllowance + amount_128

        with_attr error_message("result doesn't fit in 128 bits"):
            assert_le_felt(newAllowance, MAX_UINT128)
        end

        _approve(caller_address, spender, newAllowance)

        return (TRUE)
    end

    func decrease_allowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        spender : felt, amount : Uint256
    ) -> (success : felt):
        alloc_locals
        let (caller_address) = get_caller_address()
        let (oldAllowance) = _allowances.read(caller_address, spender)

        let (amount_128) = Uint128.to_uint_128(amount)

        let newAllowance = oldAllowance - amount_128

        with_attr error_message("allowance cannot be negative"):
            assert_nn(newAllowance)
        end

        with_attr error_message("result doesn't fit in 128 bits"):
            assert_le_felt(newAllowance, MAX_UINT128)
        end

        _approve(caller_address, spender, newAllowance)

        return (TRUE)
    end

    # Function wa originally in MintableIncentivizedERC20 contract in Solidity
    # but was combined with IncentivizedERC20 for ease of access to IncentivizedERC20's
    # storage variables without exposing them through an external functions
    func _mint{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        address : felt, amount : felt
    ):
        alloc_locals

        let (oldUserState) = _userState.read(address)
        let (oldTotalSupply) = _totalSupply.read()

        with_attr error_message("amount doesn't fit in 128 bits"):
            assert_le_felt(amount, MAX_UINT128)
        end

        let amount_256 = Uint256(amount, 0)

        # use SafeMath
        let (newTotalSupply) = SafeUint256.add(oldTotalSupply, amount_256)
        _totalSupply.write(newTotalSupply)

        let oldAccountBalance = oldUserState.balance
        let newAccountBalance = oldAccountBalance + amount
        let newUserState = UserState(newAccountBalance, oldUserState.additionalData)

        _userState.write(address, newUserState)

        # @Todo: Incentives controller logic here

        return ()
    end

    # Function wa originally in MintableIncentivizedERC20 contract in Solidity
    # but was combined with IncentivizedERC20 for ease of access to IncentivizedERC20's
    # storage variables without exposing them through an external functions
    func _burn{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        address : felt, amount : felt
    ):
        alloc_locals
        let (oldUserState) = _userState.read(address)
        let (oldTotalSupply) = _totalSupply.read()

        with_attr error_message("amount doesn't fit in 128 bits"):
            assert_le_felt(amount, MAX_UINT128)
        end

        let amount_256 = Uint256(amount, 0)

        # use SafeMath
        let (newTotalSupply) = SafeUint256.sub_le(oldTotalSupply, amount_256)
        _totalSupply.write(newTotalSupply)

        let oldAccountBalance = oldUserState.balance
        let newAccountBalance = oldAccountBalance - amount
        let newUserState = UserState(newAccountBalance, oldUserState.additionalData)

        _userState.write(address, newUserState)

        # @Todo: Incentives controller logic here

        return ()
    end
end
