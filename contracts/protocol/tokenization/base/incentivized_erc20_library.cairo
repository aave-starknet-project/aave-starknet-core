%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.bool import TRUE
from contracts.interfaces.i_pool import IPool
from contracts.protocol.pool.pool_storage import PoolStorage
from starkware.cairo.common.math import assert_le_felt, assert_nn
from openzeppelin.security.safemath import SafeUint256
<<<<<<< HEAD
from contracts.protocol.libraries.math.uint_128 import Uint128
from contracts.protocol.libraries.helpers.values import Generics
=======
from contracts.protocol.libraries.helpers.uint_128 import Uint128
>>>>>>> 50ee405 (remove test functions)

# @dev UserState - additionalData is a flexible field.
# ATokens and VariableDebtTokens use this field store the index of the user's last supply/withdrawal/borrow/repayment.
# StableDebtTokens use this field to store the user's stable rate.
struct UserState:
    member balance : felt
    member additionalData : felt
end

<<<<<<< HEAD
=======
const MAX_UINT128 = 2 ** 128 - 1

>>>>>>> 50ee405 (remove test functions)
@storage_var
func incentivized_erc20_user_state(address : felt) -> (state : UserState):
end

@storage_var
func incentivized_erc20_allowances(delegator : felt, delegatee : felt) -> (allowance : felt):
end

@storage_var
func incentivized_erc20_total_supply() -> (total_supply : Uint256):
end

@storage_var
func incentivized_erc20_name() -> (name : felt):
end

@storage_var
func incentivized_erc20_symbol() -> (symbol : felt):
end

@storage_var
func incentivized_erc20_decimals() -> (decimals : felt):
end

@storage_var
func incentivized_erc20_incentives_controller() -> (address : felt):
end

# addresses provider address
@storage_var
func incentivized_erc20_addresses_provider() -> (addressesProvider : felt):
end

# using pool address instead of interface
@storage_var
func incentivized_erc20_pool() -> (pool : felt):
end

@storage_var
func incentivized_erc20_owner() -> (incentivized_erc20_owner : felt):
end

# Internal functions- not to be imported

# @dev the amount should be passed as uint128
func _transfer{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    sender : felt, recipient : felt, amount : felt
) -> ():
    alloc_locals

    let (old_sender_state) = incentivized_erc20_user_state.read(sender)

    with_attr error_message("Not enough balance"):
        assert_le_felt(amount, old_sender_state.balance)
    end

    let new_sender_balance = old_sender_state.balance - amount
    let new_sender_state = UserState(new_sender_balance, old_sender_state.additionalData)
    incentivized_erc20_user_state.write(sender, new_sender_state)

    let (old_recipient_state) = incentivized_erc20_user_state.read(recipient)
    let new_recipient_balance = old_recipient_state.balance + amount
    let new_recipient_state = UserState(new_recipient_balance, old_recipient_state.additionalData)
    incentivized_erc20_user_state.write(recipient, new_recipient_state)

    # @TODO: import incentives_controller & handle action

    return ()
end

func _approve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    incentivized_erc20_owner : felt, spender : felt, amount : felt
) -> ():
    incentivized_erc20_allowances.write(incentivized_erc20_owner, spender, amount)
    return ()
end

<<<<<<< HEAD
namespace MintableIncentivizedERC20:
    func _mint{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        address : felt, amount : felt
    ):
        alloc_locals

        let (old_user_state) = incentivized_erc20_user_state.read(address)
        let (old_total_supply) = incentivized_erc20_total_supply.read()

        with_attr error_message("amount doesn't fit in 128 bits"):
            assert_le_felt(amount, Generics.UINT128_MAX)
        end

        let amount_256 = Uint128.to_uint_256(amount)

        # use SafeMath
        let (new_total_supply) = SafeUint256.add(old_total_supply, amount_256)
        incentivized_erc20_total_supply.write(new_total_supply)

        let old_account_balance = old_user_state.balance
        let new_account_balance = old_account_balance + amount
        let new_user_state = UserState(new_account_balance, old_user_state.additionalData)

        incentivized_erc20_user_state.write(address, new_user_state)

        # @Todo: Incentives controller logic here

        return ()
    end

    func _burn{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        address : felt, amount : felt
    ):
        alloc_locals
        let (old_user_state) = incentivized_erc20_user_state.read(address)
        let (old_total_supply) = incentivized_erc20_total_supply.read()

        with_attr error_message("amount doesn't fit in 128 bits"):
            assert_le_felt(amount, Generics.UINT128_MAX)
        end

        let amount_256 = Uint128.to_uint_256(amount)

        # use SafeMath
        let (new_total_supply) = SafeUint256.sub_le(old_total_supply, amount_256)
        incentivized_erc20_total_supply.write(new_total_supply)

        let old_account_balance = old_user_state.balance
        let new_account_balance = old_account_balance - amount
        let new_user_state = UserState(new_account_balance, old_user_state.additionalData)

        incentivized_erc20_user_state.write(address, new_user_state)

        # @Todo: Incentives controller logic here

        return ()
    end
end

namespace IncentivizedERC20:
    # modifiers
    func assert_only_pool{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
        alloc_locals
        let (caller_address) = get_caller_address()
        let (pool_) = incentivized_erc20_pool.read()
=======
namespace IncentivizedERC20:
    # modifiers
    func incentivized_erc20_only_pool{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        let (caller_address) = get_caller_address()
        let (pool_) = POOL.read()
>>>>>>> 50ee405 (remove test functions)
        with_attr error_message("Caller must be pool"):
            assert caller_address = pool_
        end
        return ()
    end

<<<<<<< HEAD
    func assert_only_pool_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ):
=======
    func incentivized_erc20_only_pool_admin{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
>>>>>>> 50ee405 (remove test functions)
        # let (caller_address) = get_caller_address()

        # @TODO: get pool admin from IACLManager
        return ()
    end

    # GETTERS

    # returns the address of the IncentivesController
    func get_incentives_controller{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }() -> (incentives_controller : felt):
        let (incentives_controller) = incentivized_erc20_incentives_controller.read()
        return (incentives_controller)
    end

    func name{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (name : felt):
        let (name) = incentivized_erc20_name.read()
        return (name)
    end

    func symbol{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        symbol : felt
    ):
        let (symbol) = incentivized_erc20_symbol.read()
        return (symbol)
    end

    func total_supply{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        total_supply : Uint256
    ):
        let (total_supply : Uint256) = incentivized_erc20_total_supply.read()
        return (total_supply)
    end

    func decimals{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        decimals : felt
    ):
        let (decimals) = incentivized_erc20_decimals.read()
        return (decimals)
    end

    func balance_of{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        account : felt
    ) -> (balance : felt):
        let (state : UserState) = incentivized_erc20_user_state.read(account)
        return (state.balance)
    end

    func allowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        owner : felt, spender : felt
    ) -> (remaining : felt):
        let (remaining) = incentivized_erc20_allowances.read(owner, spender)
        return (remaining)
    end

    # SETTERS

    func set_name{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(name : felt):
<<<<<<< HEAD
        incentivized_erc20_name.write(name)
=======
        _name.write(name)
>>>>>>> 50ee405 (remove test functions)
        return ()
    end

    func set_symbol{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        symbol : felt
    ):
<<<<<<< HEAD
        incentivized_erc20_symbol.write(symbol)
=======
        _symbol.write(symbol)
>>>>>>> 50ee405 (remove test functions)
        return ()
    end

    func set_decimals{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        decimals : felt
    ):
<<<<<<< HEAD
        incentivized_erc20_decimals.write(decimals)
=======
        _decimals.write(decimals)
>>>>>>> 50ee405 (remove test functions)
        return ()
    end

    func set_incentives_controller{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(IAaveIncentivesController : felt):
<<<<<<< HEAD
        assert_only_pool()
        incentivized_erc20_incentives_controller.write(IAaveIncentivesController)
=======
        _incentivesController.write(IAaveIncentivesController)
>>>>>>> 50ee405 (remove test functions)
        return ()
    end

    func initialize{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        pool : felt, name : felt, symbol : felt, decimals : felt
    ):
        let (addresses_provider) = IPool.get_addresses_provider(contract_address=pool)
<<<<<<< HEAD
        incentivized_erc20_addresses_provider.write(addresses_provider)
        incentivized_erc20_name.write(name)
        incentivized_erc20_symbol.write(symbol)
        incentivized_erc20_decimals.write(decimals)
        incentivized_erc20_pool.write(pool)
=======
        _addressesProvider.write(addresses_provider)
        _name.write(name)
        _symbol.write(symbol)
        _decimals.write(decimals)
        POOL.write(pool)
>>>>>>> 50ee405 (remove test functions)
        return ()
    end

    func transfer{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        recipient : felt, amount : Uint256
    ):
        let (caller_address) = get_caller_address()
        let (amount_128) = Uint128.to_uint_128(amount)

        _transfer(caller_address, recipient, amount_128)

        return ()
    end

    func transfer_from{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        sender : felt, recipient : felt, amount : Uint256
    ):
        let (caller_address) = get_caller_address()
<<<<<<< HEAD
        let (allowance) = incentivized_erc20_allowances.read(sender, caller_address)
=======
        let (allowance) = _allowances.read(sender, caller_address)
>>>>>>> 50ee405 (remove test functions)
        let (amount_128) = Uint128.to_uint_128(amount)

        let new_allowance = allowance - amount_128

        with_attr error_message("result does not fit in 128 bits"):
            assert_le_felt(new_allowance, Generics.UINT128_MAX)
        end

        _approve(sender, caller_address, new_allowance)
        _transfer(sender, recipient, amount_128)

        return ()
    end

    # Amount is passed as Uint256 but only .low is used
    func approve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        spender : felt, amount : Uint256
    ):
        let (caller_address) = get_caller_address()

        let (amount_128) = Uint128.to_uint_128(amount)

        _approve(caller_address, spender, amount_128)
        return ()
    end

    func increase_allowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        spender : felt, amount : Uint256
    ):
        alloc_locals
        let (caller_address) = get_caller_address()
        let (old_allowance) = incentivized_erc20_allowances.read(caller_address, spender)

        let (amount_128) = Uint128.to_uint_128(amount)

<<<<<<< HEAD
        let new_allowance = old_allowance + amount_128
=======
        let newAllowance = oldAllowance + amount_128
>>>>>>> 50ee405 (remove test functions)

        with_attr error_message("result doesn't fit in 128 bits"):
            assert_le_felt(new_allowance, Generics.UINT128_MAX)
        end

        _approve(caller_address, spender, new_allowance)

        return ()
    end

    func decrease_allowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        spender : felt, amount : Uint256
    ):
        alloc_locals
        let (caller_address) = get_caller_address()
        let (old_allowance) = incentivized_erc20_allowances.read(caller_address, spender)

        let (amount_128) = Uint128.to_uint_128(amount)

        let new_allowance = old_allowance - amount_128

        with_attr error_message("allowance cannot be negative"):
<<<<<<< HEAD
            assert_nn(new_allowance)
=======
            assert_nn(newAllowance)
        end

        with_attr error_message("result doesn't fit in 128 bits"):
            assert_le_felt(newAllowance, MAX_UINT128)
>>>>>>> 50ee405 (remove test functions)
        end

        with_attr error_message("result doesn't fit in 128 bits"):
            assert_le_felt(new_allowance, Generics.UINT128_MAX)
        end

        _approve(caller_address, spender, new_allowance)

<<<<<<< HEAD
        return ()
    end
=======
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
>>>>>>> 50ee405 (remove test functions)
end
