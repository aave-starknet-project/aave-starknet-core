%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from contracts.protocol.libraries.configuration.reserve_index_operations import ReserveIndex

const USER_ADDRESS = 123456
const BORROWING_TYPE = 1
const USING_AS_COLLATERAL_TYPE = 2

namespace TestReserveIndexOperations:
    func test_is_empty_list{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
        # 1
        let (res) = ReserveIndex.is_list_empty(BORROWING_TYPE, USER_ADDRESS)
        assert res = TRUE

        # 2
        ReserveIndex.add_reserve_index(BORROWING_TYPE, USER_ADDRESS, 10)
        let (res) = ReserveIndex.is_list_empty(BORROWING_TYPE, USER_ADDRESS)
        assert res = FALSE

        # 2
        ReserveIndex.add_reserve_index(USING_AS_COLLATERAL_TYPE, USER_ADDRESS, 10)
        let (res) = ReserveIndex.is_list_empty(USING_AS_COLLATERAL_TYPE, USER_ADDRESS)
        assert res = FALSE

        return ()
    end

    func test_is_only_one_element{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        # 1
        let (res) = ReserveIndex.is_only_one_element(BORROWING_TYPE, USER_ADDRESS)
        assert res = FALSE

        # 2
        ReserveIndex.add_reserve_index(BORROWING_TYPE, USER_ADDRESS, 10)
        let (res) = ReserveIndex.is_only_one_element(BORROWING_TYPE, USER_ADDRESS)
        assert res = TRUE

        # 3
        ReserveIndex.add_reserve_index(BORROWING_TYPE, USER_ADDRESS, 20)
        let (res) = ReserveIndex.is_only_one_element(BORROWING_TYPE, USER_ADDRESS)
        assert res = FALSE

        # 3
        ReserveIndex.add_reserve_index(USING_AS_COLLATERAL_TYPE, USER_ADDRESS, 20)
        let (res) = ReserveIndex.is_only_one_element(USING_AS_COLLATERAL_TYPE, USER_ADDRESS)
        assert res = TRUE

        return ()
    end

    func test_add_remove_reserve_index_borrowing{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        # slot: 0, value: 10
        ReserveIndex.add_reserve_index(BORROWING_TYPE, USER_ADDRESS, 10)

        let (res) = ReserveIndex.get_reserve_index(BORROWING_TYPE, 0, USER_ADDRESS)

        assert res = 10

        # slot: 1, value: 20
        ReserveIndex.add_reserve_index(BORROWING_TYPE, USER_ADDRESS, 20)

        let (res) = ReserveIndex.get_reserve_index(BORROWING_TYPE, 1, USER_ADDRESS)

        assert res = 20

        # slot: 2, value: 30
        ReserveIndex.add_reserve_index(BORROWING_TYPE, USER_ADDRESS, 30)

        let (res) = ReserveIndex.get_reserve_index(BORROWING_TYPE, 2, USER_ADDRESS)

        assert res = 30

        # slot: 3, value: 40
        ReserveIndex.add_reserve_index(BORROWING_TYPE, USER_ADDRESS, 40)

        let (res) = ReserveIndex.get_reserve_index(BORROWING_TYPE, 3, USER_ADDRESS)

        assert res = 40

        # remove index 20
        # -> copy value from the last slot to the one we are removing value from
        # -> remove value of last slot
        ReserveIndex.remove_reserve_index(BORROWING_TYPE, USER_ADDRESS, 20)

        let (res) = ReserveIndex.get_reserve_index(BORROWING_TYPE, 3, USER_ADDRESS)

        assert res = 0

        let (res) = ReserveIndex.get_reserve_index(BORROWING_TYPE, 1, USER_ADDRESS)

        assert res = 40

        let (res) = ReserveIndex.get_reserve_index(BORROWING_TYPE, 2, USER_ADDRESS)

        assert res = 30

        # remove non-existing index 2137
        # -> should not go into infinite recursion
        # -> should return after traversing every slot and not finding 2137
        # -> should leave all slots as they were
        ReserveIndex.remove_reserve_index(BORROWING_TYPE, USER_ADDRESS, 2137)

        let (res) = ReserveIndex.get_reserve_index(BORROWING_TYPE, 0, USER_ADDRESS)

        assert res = 10

        let (res) = ReserveIndex.get_reserve_index(BORROWING_TYPE, 1, USER_ADDRESS)

        assert res = 40

        let (res) = ReserveIndex.get_reserve_index(BORROWING_TYPE, 2, USER_ADDRESS)

        assert res = 30

        let (res) = ReserveIndex.get_reserve_index(BORROWING_TYPE, 3, USER_ADDRESS)

        assert res = 0

        return ()
    end

    func test_add_remove_reserve_index_using_as_collateral{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        # slot: 0, value: 10
        ReserveIndex.add_reserve_index(USING_AS_COLLATERAL_TYPE, USER_ADDRESS, 10)

        let (res) = ReserveIndex.get_reserve_index(USING_AS_COLLATERAL_TYPE, 0, USER_ADDRESS)

        assert res = 10

        # slot: 1, value: 20
        ReserveIndex.add_reserve_index(USING_AS_COLLATERAL_TYPE, USER_ADDRESS, 20)

        let (res) = ReserveIndex.get_reserve_index(USING_AS_COLLATERAL_TYPE, 1, USER_ADDRESS)

        assert res = 20

        # slot: 2, value: 30
        ReserveIndex.add_reserve_index(USING_AS_COLLATERAL_TYPE, USER_ADDRESS, 30)

        let (res) = ReserveIndex.get_reserve_index(USING_AS_COLLATERAL_TYPE, 2, USER_ADDRESS)

        assert res = 30

        # slot: 3, value: 40
        ReserveIndex.add_reserve_index(USING_AS_COLLATERAL_TYPE, USER_ADDRESS, 40)

        let (res) = ReserveIndex.get_reserve_index(USING_AS_COLLATERAL_TYPE, 3, USER_ADDRESS)

        assert res = 40

        # remove index 20
        # -> copy value from the last slot to the one we are removing value from
        # -> remove value of last slot
        ReserveIndex.remove_reserve_index(USING_AS_COLLATERAL_TYPE, USER_ADDRESS, 20)

        let (res) = ReserveIndex.get_reserve_index(USING_AS_COLLATERAL_TYPE, 3, USER_ADDRESS)

        assert res = 0

        let (res) = ReserveIndex.get_reserve_index(USING_AS_COLLATERAL_TYPE, 1, USER_ADDRESS)

        assert res = 40

        let (res) = ReserveIndex.get_reserve_index(USING_AS_COLLATERAL_TYPE, 2, USER_ADDRESS)

        assert res = 30

        # remove non-existing index 2137
        # -> should not go into infinite recursion
        # -> should return after traversing every slot and not finding 2137
        # -> should leave all slots as they were
        ReserveIndex.remove_reserve_index(USING_AS_COLLATERAL_TYPE, USER_ADDRESS, 2137)

        let (res) = ReserveIndex.get_reserve_index(USING_AS_COLLATERAL_TYPE, 0, USER_ADDRESS)

        assert res = 10

        let (res) = ReserveIndex.get_reserve_index(USING_AS_COLLATERAL_TYPE, 1, USER_ADDRESS)

        assert res = 40

        let (res) = ReserveIndex.get_reserve_index(USING_AS_COLLATERAL_TYPE, 2, USER_ADDRESS)

        assert res = 30

        let (res) = ReserveIndex.get_reserve_index(USING_AS_COLLATERAL_TYPE, 3, USER_ADDRESS)

        assert res = 0

        return ()
    end

    func test_get_lowest_reserve_index{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        # Borrowing
        # 1
        ReserveIndex.add_reserve_index(BORROWING_TYPE, USER_ADDRESS, 10)
        ReserveIndex.add_reserve_index(BORROWING_TYPE, USER_ADDRESS, 20)
        ReserveIndex.add_reserve_index(BORROWING_TYPE, USER_ADDRESS, 30)

        let (res) = ReserveIndex.get_lowest_reserve_index(BORROWING_TYPE, USER_ADDRESS)
        assert res = 10

        # 2
        ReserveIndex.add_reserve_index(BORROWING_TYPE, USER_ADDRESS, 5)

        let (res) = ReserveIndex.get_lowest_reserve_index(BORROWING_TYPE, USER_ADDRESS)
        assert res = 5

        # 3
        ReserveIndex.remove_reserve_index(BORROWING_TYPE, USER_ADDRESS, 5)

        let (res) = ReserveIndex.get_lowest_reserve_index(BORROWING_TYPE, USER_ADDRESS)
        assert res = 10

        # Using as collateral
        # 1
        ReserveIndex.add_reserve_index(USING_AS_COLLATERAL_TYPE, USER_ADDRESS, 10)
        ReserveIndex.add_reserve_index(USING_AS_COLLATERAL_TYPE, USER_ADDRESS, 20)
        ReserveIndex.add_reserve_index(USING_AS_COLLATERAL_TYPE, USER_ADDRESS, 30)

        let (res) = ReserveIndex.get_lowest_reserve_index(USING_AS_COLLATERAL_TYPE, USER_ADDRESS)
        assert res = 10

        # 2
        ReserveIndex.add_reserve_index(USING_AS_COLLATERAL_TYPE, USER_ADDRESS, 5)

        let (res) = ReserveIndex.get_lowest_reserve_index(USING_AS_COLLATERAL_TYPE, USER_ADDRESS)
        assert res = 5

        # 3
        ReserveIndex.remove_reserve_index(USING_AS_COLLATERAL_TYPE, USER_ADDRESS, 5)

        let (res) = ReserveIndex.get_lowest_reserve_index(USING_AS_COLLATERAL_TYPE, USER_ADDRESS)
        assert res = 10

        return ()
    end
end
