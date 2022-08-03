%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE

from contracts.protocol.libraries.helpers.helpers import is_zero
from contracts.protocol.pool.pool_storage import PoolStorage

namespace Pool:
    func get_reserves_list{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        assets_len : felt, assets : felt*
    ):
        alloc_locals
        let (reserves_count) = PoolStorage.reserves_count_read()
        let (local assets : felt*) = alloc()
        let (assets_len) = read_reserves(assets, 0, reserves_count, 0)
        return (assets_len, assets)
    end

    func get_reserve_address_by_id{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(reserve_id : felt) -> (address : felt):
        let (address : felt) = PoolStorage.reserves_list_read(reserve_id)
        return (address)
    end
end

func read_reserves{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    result : felt*, index : felt, reserves_count : felt, dropped_reserves_count : felt
) -> (assets_len : felt):
    if index == reserves_count:
        tempvar assets_len = reserves_count - dropped_reserves_count
        return (assets_len)
    end
    let (current_asset) = PoolStorage.reserves_list_read(index)
    let (is_current_zero) = is_zero(current_asset)
    if is_current_zero == TRUE:
        return read_reserves(result, index + 1, reserves_count, dropped_reserves_count + 1)
    else:
        assert [result] = current_asset
        return read_reserves(result + 1, index + 1, reserves_count, dropped_reserves_count)
    end
end
