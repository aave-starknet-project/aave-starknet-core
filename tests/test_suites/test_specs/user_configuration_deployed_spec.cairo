%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.alloc import alloc
from contracts.protocol.libraries.configuration.reserve_index_operations import (
    BORROWING_TYPE,
    USING_AS_COLLATERAL_TYPE,
)
from contracts.interfaces.i_pool import IPool
# from contracts.protocol.libraries.configuration.user_configuration import UserConfiguration
# from contracts.protocol.libraries.configuration.reserve_configuration import ReserveConfiguration

# from contracts.protocol.libraries.configuration.reserve_configuration import ReserveConfiguration
# from contracts.protocol.pool.pool_storage import PoolStorage

const TEST_ADDRESS = 34123589120

namespace TestUserConfigurationDeployed:
    func test_get_siloed_borrowing_state{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        local pool
        local dai
        %{
            ids.pool = context.pool
            ids.dai = context.dai
        %}
        # let (reserve) = IPool.get_reserve_data(pool, dai)
        UserConfiguration.set_borrowing(TEST_ADDRESS, 1, TRUE)
        let (local reserves_list : felt*) = alloc()
        let (reserves_list_len, reserves_list) = IPool.get_reserves_list(pool)
        let reserve = [reserves_list]
        %{ print(ids.reserve) %}
        let (res) = UserConfiguration.get_siloed_borrowing_state(TEST_ADDRESS)
        return ()
    end
end
