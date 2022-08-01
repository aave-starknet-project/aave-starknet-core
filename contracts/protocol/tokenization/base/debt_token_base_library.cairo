%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_caller_address

from openzeppelin.security.safemath import SafeUint256

@storage_var
func DebtTokenBase_borrow_allowances(delegator : felt, delegatee : felt) -> (allowance : Uint256):
end

@storage_var
func DebtTokenBase_underlying_asset() -> (asset : felt):
end

# @dev Emitted on `approve_delegation` and `borrow_allowance`
# @param from_user The address of the delegator
# @param to_user The address of the delegatee
# @param asset The address of the delegated asset
# @param amount The amount being delegated
@event
func BorrowAllowanceDelegated(from_user : felt, to_user : felt, asset : felt, amount : Uint256):
end

namespace DebtTokenBase:
    # @notice Returns the underlying asset of the debt token
    # @return The underlying asset of the debt token
    func get_underlying_asset{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ) -> (underlying : felt):
        let (underlying) = DebtTokenBase_underlying_asset.read()
        return (underlying)
    end

    # @notice Sets the underlying asset of the debt token
    # @param underlying The underlying asset of the debt token
    func set_underlying_asset(underlying : felt):
        DebtTokenBase_underlying_asset.write(underlying)
    end

    # @notice Delegates borrowing power to a user on the specific debt token.
    # Delegation will still respect the liquidation constraints (even if delegated, a
    # delegatee cannot force a delegator HF to go below 1)
    # @param delegatee The address receiving the delegated borrowing power
    # @param amount The maximum amount being delegated.
    func approve_delegation(delegatee : felt, amount : Uint256):
        let (caller) = get_caller_address()
        _approve_delegation(caller, delegatee, amount)
    end

    # @notice Returns the borrow allowance of the user
    # @param from_user The user to giving allowance
    # @param to_user The user to give allowance to
    # @return The current allowance of `toUser`
    func borrow_allowance(from_user : felt, to_user : felt):
        let (allowance) = DebtTokenBase_borrow_allowances.read(from_user, to_user)
        return (allowance)
    end

    # @notice Decreases the borrow allowance of a user on the specific debt token.
    # @param delegator The address delegating the borrowing power
    # @param delegatee The address receiving the delegated borrowing power
    # @param amount The amount to subtract from the current allowance
    func decrease_borrow_allowance{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(delegator : felt, delegatee : felt, amount : Uint256):
        let (prev_allowance) = DebtTokenBase_borrow_allowances.read(delegator, delegatee)
        let (new_allowance) = SafeUint256.sub_le(prev_allowance, amount)
        DebtTokenBase_borrow_allowances.write(delegator, delegatee, new_allowance)
        let (underlying) = DebtTokenBase_underlying_asset.read()
        BorrowAllowanceDelegated.emit(delegator, delegatee, underlying, new_allowance)

        return ()
    end
end

# @notice Updates the borrow allowance of a user on the specific debt token.
# @param delegator The address delegating the borrowing power
# @param delegatee The address receiving the delegated borrowing power
# @param amount The allowance amount being delegated.
func _approve_delegation{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    delegator : felt, delegatee : felt, amount : Uint256
):
    DebtTokenBase_borrow_allowances.write(delegator, delegatee, amount)
    let (underlying) = DebtTokenBase_underlying_asset.read()
    BorrowAllowanceDelegated.emit(delegator, delegatee, underlying, amount)
    return ()
end
