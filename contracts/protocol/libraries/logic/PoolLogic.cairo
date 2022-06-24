%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import storage_read, storage_write, get_caller_address
from contracts.protocol.libraries.types.DataTypes import DataTypes
from openzeppelin.security.safemath import SafeUint256
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.math_cmp import is_not_zero
from starkware.cairo.common.math import assert_lt
from starkware.cairo.common.bool import TRUE, FALSE
from contracts.protocol.libraries.helpers.Helpers import is_zero
from contracts.protocol.pool.PoolStorage import pool_storages
from contracts.protocol.libraries.logic.ReserveLogic import ReserveLogic

namespace PoolLogic:
    func execute_init_reserve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        params : DataTypes.InitReserveParams
    ) -> (appended : felt):
        alloc_locals
        let (reserve) = pool_storages.reserves_read(params.asset)

        let (local reserve : DataTypes.ReserveData) = ReserveLogic.init(
            reserve, params.aToken_address
        )

        # TODO initialize reserves with debtTokens interestRateStrategy

        let (is_id_not_zero) = is_not_zero(reserve.id)
        let (first_listed_asset) = pool_storages.reserves_list_read(0)
        let (is_asset_first) = is_zero(first_listed_asset - params.asset)

        with_attr error_message("Reserve already added"):
            assert is_id_not_zero + is_asset_first = 0
        end

        let (appended) = _init_reserve_append(params.asset, reserve, params.reserves_count, 0)

        if appended == FALSE:
            return (FALSE)
        end

        with_attr error_message("No more reserves allowed"):
            assert_lt(params.reserves_count, params.max_number_reserves)
        end

        reserve.id = params.reserves_count
        pool_storages.reserves_write(params.asset, reserve)
        pool_storages.reserves_list_write(params.reserves_count, params.asset)
        return (TRUE)
    end

    func _init_reserve_append{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        asset : felt, reserve : DataTypes.ReserveData, reserves_count : felt, index : felt
    ) -> (appended : felt):
        if reserves_count == 0:
            return (TRUE)
        end

        let (reserve_address) = pool_storages.reserves_list_read(index)
        let (is_address_zero) = is_zero(reserve_address)

        if is_address_zero == TRUE:
            reserve.id = index
            pool_storages.reserves_write(asset, reserve)
            pool_storages.reserves_list_write(index, asset)
            return (FALSE)
        end

        return _init_reserve_append(asset, reserve, reserves_count - 1, index + 1)
    end
end
