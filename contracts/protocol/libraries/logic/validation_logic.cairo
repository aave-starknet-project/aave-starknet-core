%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import storage_read, storage_write, get_caller_address
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import assert_not_equal, assert_not_zero
from starkware.cairo.common.uint256 import Uint256, uint256_eq, uint256_le, uint256_check
from openzeppelin.security.safemath import SafeUint256
from openzeppelin.token.erc20.interfaces.IERC20 import IERC20
from contracts.protocol.libraries.types.data_types import DataTypes
from contracts.interfaces.i_a_token import IAToken

namespace ValidationLogic:
    # @notice Validates a supply action.
    # @param reserve The data of the reserve
    # @param amount The amount to be supplied
    func _validate_supply{range_check_ptr}(reserve : DataTypes.ReserveData, amount : Uint256):
        uint256_check(amount)

        with_attr error_message("Amount must be greater than 0"):
            let (is_zero) = uint256_eq(amount, Uint256(0, 0))
            assert is_zero = FALSE
        end

        # Todo validate active/frozen/paused reserves

        # TODO supply cap

        return ()
    end

    # @notice Validates a withdraw action.
    # @param reserve the data of the reserve
    # @param amount The amount to be withdrawn
    # @param user_balance The balance of the user
    func _validate_withdraw{syscall_ptr : felt*, range_check_ptr}(
        reserve : DataTypes.ReserveData, amount : Uint256, user_balance : Uint256
    ):
        alloc_locals
        uint256_check(amount)

        with_attr error_message("Amount must be greater than 0"):
            let (is_zero) = uint256_eq(amount, Uint256(0, 0))
            assert is_zero = FALSE
        end

        # Revert if withdrawing too much. Verify that amount<=balance
        with_attr error_message("User cannot withdraw more than the available balance"):
            let (is_lt : felt) = uint256_le(amount, user_balance)
            assert is_lt = TRUE
        end

        # TODO verify reserve is active and not paused
        return ()
    end
end
