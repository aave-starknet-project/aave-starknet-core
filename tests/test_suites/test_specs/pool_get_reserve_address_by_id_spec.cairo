%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from contracts.interfaces.i_pool import IPool

namespace TestPoolGetReserveAddressByIdDeployed:
    # 'User gets address of reserve by id'
    func test_get_address_of_reserve_by_id{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        local dai
        local pool
        %{
            ids.dai = context.dai
            ids.pool = context.pool
        %}

        let (reserve_data) = IPool.get_reserve_data(pool, dai)

        let (reserve_address) = IPool.get_reserve_address_by_id(pool, reserve_data.id)

        assert reserve_address = dai

        return ()
    end

    # 'User calls `get_reserve_address_by_id` with a wrong id (id > reserves_count)'
    func test_get_max_number_reserves{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        local pool
        %{ ids.pool = context.pool %}

        let (max_number_of_reserves) = IPool.MAX_NUMBER_RESERVES(pool)

        let (reserve_address) = IPool.get_reserve_address_by_id(pool, max_number_of_reserves + 1)

        assert reserve_address = 0

        return ()
    end
end
