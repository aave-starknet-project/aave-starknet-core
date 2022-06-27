%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import storage_read, storage_write, get_caller_address
from contracts.protocol.libraries.types.DataTypes import DataTypes
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_add,
    uint256_check,
    uint256_sub,
    uint256_lt,
)

from contracts.protocol.libraries.storage.pool_storages import pool_storages


namespace ReserveLogic:
    # @notice Initializes a reserve.
    # @param reserve The reserve object
    # @param aTokenAddress The address of the overlying atoken contract
    func _init{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve : DataTypes.ReserveData, aToken_address : felt
    ) -> (reserve : DataTypes.ReserveData):
        with_attr error_message("Reserve already initialized"):
            assert reserve.aToken_address = 0
        end

        # Write aToken_address in reserve
        let new_reserve = DataTypes.ReserveData(id=reserve.id, aToken_address = aToken_address, liquidity_index = 1 * 10 ** 27)
        pool_storages.reserves_write(aToken_address, new_reserve)
        # TODO add other params such as liq index, debt tokens addresses, use RayMath library
        return (new_reserve)
    end
end
