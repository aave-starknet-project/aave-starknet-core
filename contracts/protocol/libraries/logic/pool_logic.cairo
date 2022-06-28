%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import storage_read, storage_write, get_caller_address
from contracts.protocol.libraries.types.data_types import DataTypes
from openzeppelin.security.safemath import SafeUint256
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.math_cmp import is_not_zero
from starkware.cairo.common.math import assert_lt
from starkware.cairo.common.bool import TRUE, FALSE
from contracts.protocol.libraries.helpers.helpers import is_zero
from contracts.protocol.pool.pool_storage import PoolStorage
from contracts.protocol.libraries.logic.reserve_logic import ReserveLogic
from contracts.protocol.libraries.helpers.bool_cmp import BoolCompare

namespace PoolLogic:
    # @notice Initialize an asset reserve and add the reserve to the list of reserves
    # @param params parameters needed for initiation
    # @return true if appended, false if inserted at existing empty spot
    func _execute_init_reserve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        params : DataTypes.InitReserveParams
    ) -> (appended : felt):
        alloc_locals
        let (initial_reserve) = PoolStorage.reserves_read(params.asset)

        let (local reserve : DataTypes.ReserveData) = ReserveLogic._init(
            initial_reserve, params.a_token_address
        )
        # TODO initialize reserves with debtTokens interestRateStrategy

        let (is_id_not_zero) = is_not_zero(reserve.id)
        let (first_listed_asset) = PoolStorage.reserves_list_read(0)
        let (is_asset_first) = is_zero(first_listed_asset - params.asset)

        with_attr error_message("Reserve has already been added to reserve list"):
            let (reserve_already_added) = BoolCompare.either(is_id_not_zero, is_asset_first)
            assert reserve_already_added = FALSE
        end

        let (appended) = init_reserve_append(params.asset, reserve, params.reserves_count, 0)

        if appended == FALSE:
            return (FALSE)
        end

        with_attr error_message("Maximum amount of reserves in the pool reached"):
            assert_lt(params.reserves_count, params.max_number_reserves)
        end

        reserve.id = params.reserves_count
        PoolStorage.reserves_write(params.asset, reserve)
        PoolStorage.reserves_list_write(params.reserves_count, params.asset)
        return (TRUE)
    end
end

# @notice Recursive function trying to add the reserve to the existing list of reserves
# @param asset asset to be initialized
# @param reserve reserve to be initialized
# @param reserves_count number of reserves in the list
# @param current index of the list
# @return false if reserve has been added to the list, true otherwise
func init_reserve_append{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    asset : felt, reserve : DataTypes.ReserveData, reserves_count : felt, index : felt
) -> (appended : felt):
    if reserves_count == 0:
        return (TRUE)
    end

    let (reserve_address) = PoolStorage.reserves_list_read(index)
    let (is_address_zero) = is_zero(reserve_address)

    if is_address_zero == TRUE:
        reserve.id = index
        PoolStorage.reserves_write(asset, reserve)
        PoolStorage.reserves_list_write(index, asset)
        return (FALSE)
    end

    return init_reserve_append(asset, reserve, reserves_count - 1, index + 1)
end
