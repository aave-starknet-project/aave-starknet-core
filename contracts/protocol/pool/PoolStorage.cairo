%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin

from contracts.protocol.libraries.types.DataTypes import DataTypes

@storage_var
func _reserves(asset : felt) -> (reserve_data : DataTypes.ReserveData):
end

@storage_var
func _reserves_count() -> (count : felt):
end

@storage_var
func _reserves_list(reserve_id : felt) -> (address : felt):
end

namespace pool_storages:
    #
    # Reads
    #

    func reserves_read{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        address : felt
    ) -> (reserve_data : DataTypes.ReserveData):
        let (reserve) = _reserves.read(address)
        return (reserve)
    end

    func reserves_count_read{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ) -> (count : felt):
        let (count) = _reserves_count.read()
        return (count)
    end

    func reserves_list_read{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_id : felt
    ) -> (address : felt):
        let (address) = _reserves_list.read(reserve_id)
        return (address)
    end

    #
    # Writes
    #

    func reserves_write{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        asset : felt, reserve_data : DataTypes.ReserveData
    ):
        _reserves.write(asset, reserve_data)
        return ()
    end

    func reserve_count_write{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        count : felt
    ):
        _reserves_count.write(count)
        return ()
    end

    func reserves_list_write{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_id : felt, address : felt
    ):
        _reserves_list.write(reserve_id, address)
        return ()
    end
end
