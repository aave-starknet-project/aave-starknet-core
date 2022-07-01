%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.math_cmp import is_not_zero
from starkware.cairo.common.uint256 import Uint256, uint256_eq, uint256_le, uint256_check
from openzeppelin.token.erc20.interfaces.IERC20 import IERC20
from contracts.protocol.libraries.types.data_types import DataTypes
from contracts.protocol.libraries.helpers.helpers import is_zero
from contracts.protocol.libraries.helpers.bool_cmp import BoolCompare
from contracts.protocol.pool.pool_storage import PoolStorage

namespace ValidationLogic:
    # @notice Validates a supply action.
    # @param reserve The data of the reserve
    # @param amount The amount to be supplied
    func validate_supply{range_check_ptr}(reserve : DataTypes.ReserveData, amount : Uint256):
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
    func validate_withdraw{syscall_ptr : felt*, range_check_ptr}(
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
            let (is_le : felt) = uint256_le(amount, user_balance)
            assert is_le = TRUE
        end

        # TODO verify reserve is active and not paused
        return ()
    end

    # @notice Validates a drop reserve action.
    # @param reserve The reserve object
    # @param asset The address of the reserve's underlying asset
    func validate_drop_reserve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve : DataTypes.ReserveData, asset : felt
    ):
        with_attr error_message("Zero address not valid"):
            assert_not_zero(asset)
        end

        with_attr error_message("Asset is not listed"):
            let (is_id_not_zero) = is_not_zero(reserve.id)
            let (reserve_list_first) = PoolStorage.reserves_list_read(0)
            let (is_first_asset) = is_zero(reserve_list_first - asset)

            let (asset_listed) = BoolCompare.either(is_id_not_zero, is_first_asset)
            assert asset_listed = TRUE
        end

        # TODO verify that stable/var debt are zero

        with_attr error_message("AToken supply is not zero"):
            let (a_token_supply) = IERC20.totalSupply(contract_address=reserve.a_token_address)
            assert a_token_supply = Uint256(0, 0)
        end
        return ()
    end
end
