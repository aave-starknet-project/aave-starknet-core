%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.bool import TRUE
from contracts.interfaces.i_pool import IPool
from contracts.protocol.pool.pool_storage import PoolStorage
from starkware.cairo.common.math import assert_le_felt, assert_nn
from openzeppelin.security.safemath import SafeUint256
from contracts.protocol.libraries.math.uint_128 import Uint128
from contracts.protocol.libraries.helpers.values import Generics

from contracts.protocol.libraries.types.data_types import DataTypes

@storage_var
func incentivized_erc20_user_state(address : felt) -> (state : DataTypes.UserState):
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
    let new_sender_state = DataTypes.UserState(new_sender_balance, old_sender_state.additionalData)
    incentivized_erc20_user_state.write(sender, new_sender_state)

    let (old_recipient_state) = incentivized_erc20_user_state.read(recipient)
    let new_recipient_balance = old_recipient_state.balance + amount
    let new_recipient_state = DataTypes.UserState(
        new_recipient_balance, old_recipient_state.additionalData
    )
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

        let (amount_256) = Uint128.to_uint_256(amount)

        # use SafeMath
        let (new_total_supply) = SafeUint256.add(old_total_supply, amount_256)
        incentivized_erc20_total_supply.write(new_total_supply)

        let old_account_balance = old_user_state.balance
        let new_account_balance = old_account_balance + amount
        let new_user_state = DataTypes.UserState(new_account_balance, old_user_state.additionalData)

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

        let (amount_256) = Uint128.to_uint_256(amount)

        # use SafeMath
        let (new_total_supply) = SafeUint256.sub_le(old_total_supply, amount_256)
        incentivized_erc20_total_supply.write(new_total_supply)

        let old_account_balance = old_user_state.balance
        let new_account_balance = old_account_balance - amount
        let new_user_state = DataTypes.UserState(new_account_balance, old_user_state.additionalData)

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
        with_attr error_message("Caller must be pool"):
            assert caller_address = pool_
        end
        return ()
    end

    func assert_only_pool_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ):
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
        let (state : DataTypes.UserState) = incentivized_erc20_user_state.read(account)
        return (state.balance)
    end

    func allowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        owner : felt, spender : felt
    ) -> (remaining : felt):
        let (remaining) = incentivized_erc20_allowances.read(owner, spender)
        return (remaining)
    end

    func get_user_state{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user : felt
    ) -> (res : DataTypes.UserState):
        let (state) = incentivized_erc20_user_state.read(user)
        return (state)
    end

    func get_pool{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }()->(pool : felt):
        let (pool)= incentivized_erc20_pool.read()
        return (pool)
    end

    # SETTERS

    func set_user_state{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user : felt, state : DataTypes.UserState
    ):
        incentivized_erc20_user_state.write(user, state)
        return ()
    end

    func set_name{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(name : felt):
        incentivized_erc20_name.write(name)
        return ()
    end

    func set_symbol{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        symbol : felt
    ):
        incentivized_erc20_symbol.write(symbol)
        return ()
    end

    func set_decimals{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        decimals : felt
    ):
        incentivized_erc20_decimals.write(decimals)
        return ()
    end

    func set_incentives_controller{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(IAaveIncentivesController : felt):
        assert_only_pool()
        incentivized_erc20_incentives_controller.write(IAaveIncentivesController)
        return ()
    end

    func initialize{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        pool : felt, name : felt, symbol : felt, decimals : felt
    ):
        let (addresses_provider) = IPool.get_addresses_provider(contract_address=pool)
        incentivized_erc20_addresses_provider.write(addresses_provider)
        incentivized_erc20_name.write(name)
        incentivized_erc20_symbol.write(symbol)
        incentivized_erc20_decimals.write(decimals)
        incentivized_erc20_pool.write(pool)
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
        let (allowance) = incentivized_erc20_allowances.read(sender, caller_address)
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

        let new_allowance = old_allowance + amount_128

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
            assert_nn(new_allowance)
        end

        with_attr error_message("result doesn't fit in 128 bits"):
            assert_le_felt(new_allowance, Generics.UINT128_MAX)
        end

        _approve(caller_address, spender, new_allowance)

        return ()
    end
end
