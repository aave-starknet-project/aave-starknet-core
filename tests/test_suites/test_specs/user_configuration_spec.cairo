%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from contracts.protocol.libraries.types.data_types import DataTypes
from contracts.protocol.libraries.configuration.user_configuration import UserConfiguration
from contracts.protocol.libraries.configuration.reserve_index_operations import (
    BORROWING_TYPE,
    USING_AS_COLLATERAL_TYPE,
)

const TEST_ADDRESS = 4812950810879290
const TEST_ADDRESS2 = 5832954280734189
const TEST_ADDRESS3 = 2137213721372137
const TEST_ADDRESS4 = 7372187518950897

const TEST_RESERVE_INDEX = 1
const TEST_RESERVE_INDEX_2 = 2
const TEST_RESERVE_INDEX_3 = 3

const TEST_RESERVE_ADDRESS = 47128935710
const TEST_RESERVE_ADDRESS_2 = 30589205810
const TEST_RESERVE_ADDRESS_3 = 35892085093


namespace TestUserConfiguration:
    func test_set_borrowing_and_is_borrowing{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        let TEST_USER_CONFIG = DataTypes.UserConfigurationMap(0, 0)
        let TEST_USER_CONFIG_2 = DataTypes.UserConfigurationMap(0, 0)

        let (TEST_USER_CONFIG) = UserConfiguration.set_borrowing(TEST_ADDRESS, TEST_RESERVE_INDEX, TEST_USER_CONFIG, TRUE)

        let (bor) = UserConfiguration.is_borrowing(TEST_USER_CONFIG)
        assert bor = TRUE

        let (bor) = UserConfiguration.is_borrowing(TEST_USER_CONFIG_2)
        assert bor = FALSE

        return ()
    end

    func test_set_using_as_collateral_and_is_using_as_collateral{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        let TEST_USER_CONFIG = DataTypes.UserConfigurationMap(0, 0)
        let TEST_USER_CONFIG_2 = DataTypes.UserConfigurationMap(0, 0)

        let (TEST_USER_CONFIG) = UserConfiguration.set_using_as_collateral(TEST_ADDRESS, TEST_RESERVE_INDEX, TEST_USER_CONFIG, TRUE)

        let (col) = UserConfiguration.is_using_as_collateral(TEST_USER_CONFIG)
        assert col = TRUE

        let (col) = UserConfiguration.is_using_as_collateral(TEST_USER_CONFIG_2)
        assert col = FALSE

        return ()
    end

    func test_is_using_as_collateral_or_borrowing{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        let TEST_USER_CONFIG = DataTypes.UserConfigurationMap(0, 0)
        let TEST_USER_CONFIG_2 = DataTypes.UserConfigurationMap(0, 0)
        let TEST_USER_CONFIG_3 = DataTypes.UserConfigurationMap(0, 0)
        let TEST_USER_CONFIG_4 = DataTypes.UserConfigurationMap(0, 0)
        # 1
        let (TEST_USER_CONFIG) = UserConfiguration.set_using_as_collateral(TEST_ADDRESS, TEST_RESERVE_INDEX, TEST_USER_CONFIG, TRUE)
        let (TEST_USER_CONFIG) = UserConfiguration.set_borrowing(TEST_ADDRESS, TEST_RESERVE_INDEX, TEST_USER_CONFIG, TRUE)

        let (res) = UserConfiguration.is_using_as_collateral_or_borrowing(
            TEST_USER_CONFIG
        )
        assert res = TRUE

        # 2
        let (TEST_USER_CONFIG_2) = UserConfiguration.set_using_as_collateral(TEST_ADDRESS2, TEST_RESERVE_INDEX, TEST_USER_CONFIG_2, TRUE)
        let (res) = UserConfiguration.is_using_as_collateral_or_borrowing(
            TEST_USER_CONFIG_2
        )
        assert res = TRUE

        # 3
        let (TEST_USER_CONFIG_3) = UserConfiguration.set_borrowing(TEST_ADDRESS3, TEST_RESERVE_INDEX, TEST_USER_CONFIG_3, TRUE)
        let (res) = UserConfiguration.is_using_as_collateral_or_borrowing(
           TEST_USER_CONFIG_3 
        )
        assert res = TRUE

        # 4
        let (res) = UserConfiguration.is_using_as_collateral_or_borrowing(
            TEST_USER_CONFIG_4
        )
        assert res = FALSE

        return ()
    end

    func test_is_using_as_collateral_one{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        let TEST_USER_CONFIG = DataTypes.UserConfigurationMap(0, 0)
        let TEST_USER_CONFIG_2_1 = DataTypes.UserConfigurationMap(0, 0)
        let TEST_USER_CONFIG_2_2 = DataTypes.UserConfigurationMap(0, 0)
        # 1
        let (TEST_USER_CONFIG) = UserConfiguration.set_using_as_collateral(TEST_ADDRESS, TEST_RESERVE_INDEX, TEST_USER_CONFIG, TRUE)

        let (col) = UserConfiguration.is_using_as_collateral_one(TEST_ADDRESS)
        assert col = TRUE

        # 2
        let (TEST_USER_CONFIG_2_1) = UserConfiguration.set_using_as_collateral(TEST_ADDRESS2, TEST_RESERVE_INDEX, TEST_USER_CONFIG_2_1, TRUE)
        let (TEST_USER_CONFIG_2_2) = UserConfiguration.set_using_as_collateral(TEST_ADDRESS2, TEST_RESERVE_INDEX_2, TEST_USER_CONFIG_2_2, TRUE)

        let (col) = UserConfiguration.is_using_as_collateral_one(TEST_ADDRESS2)
        assert col = FALSE

        # 3
        let (col) = UserConfiguration.is_using_as_collateral_one(TEST_ADDRESS3)
        assert col = FALSE

        return ()
    end

    func test_is_using_as_collateral_any{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        let TEST_USER_CONFIG = DataTypes.UserConfigurationMap(0, 0)
        let TEST_USER_CONFIG_2_1 = DataTypes.UserConfigurationMap(0, 0)
        let TEST_USER_CONFIG_2_2 = DataTypes.UserConfigurationMap(0, 0)
        # 1
        let (TEST_USER_CONFIG) = UserConfiguration.set_using_as_collateral(TEST_ADDRESS, TEST_RESERVE_INDEX, TEST_USER_CONFIG, TRUE)

        let (col) = UserConfiguration.is_using_as_collateral_any(TEST_ADDRESS)
        assert col = TRUE

        # 2
        let (TEST_USER_CONFIG_2_1) = UserConfiguration.set_using_as_collateral(TEST_ADDRESS2, TEST_RESERVE_INDEX, TEST_USER_CONFIG_2_1, TRUE)
        let (TEST_USER_CONFIG_2_2) = UserConfiguration.set_using_as_collateral(TEST_ADDRESS2, TEST_RESERVE_INDEX_2, TEST_USER_CONFIG_2_2, TRUE)

        let (col) = UserConfiguration.is_using_as_collateral_any(TEST_ADDRESS2)
        assert col = TRUE

        # 3
        let (col) = UserConfiguration.is_using_as_collateral_any(TEST_ADDRESS3)
        assert col = FALSE

        return ()
    end

    func test_is_borrowing_one{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
        let TEST_USER_CONFIG = DataTypes.UserConfigurationMap(0, 0)
        let TEST_USER_CONFIG_2_1 = DataTypes.UserConfigurationMap(0, 0)
        let TEST_USER_CONFIG_2_2 = DataTypes.UserConfigurationMap(0, 0)
        # 1
        let (TEST_USER_CONFIG) = UserConfiguration.set_borrowing(TEST_ADDRESS, TEST_RESERVE_INDEX, TEST_USER_CONFIG, TRUE)

        let (bor) = UserConfiguration.is_borrowing_one(TEST_ADDRESS)
        assert bor = TRUE

        # 2
        let (TEST_USER_CONFIG_2_1) = UserConfiguration.set_borrowing(TEST_ADDRESS2, TEST_RESERVE_INDEX, TEST_USER_CONFIG_2_1, TRUE)
        let (TEST_USER_CONFIG_2_2) = UserConfiguration.set_borrowing(TEST_ADDRESS2, TEST_RESERVE_INDEX_2, TEST_USER_CONFIG_2_2, TRUE)

        let (bor) = UserConfiguration.is_borrowing_one(TEST_ADDRESS2)
        assert bor = FALSE

        # 3
        let (bor) = UserConfiguration.is_borrowing_one(TEST_ADDRESS3)
        assert bor = FALSE

        return ()
    end

    func test_is_borrowing_any{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
        let TEST_USER_CONFIG = DataTypes.UserConfigurationMap(0, 0)
        let TEST_USER_CONFIG_2_1 = DataTypes.UserConfigurationMap(0, 0)
        let TEST_USER_CONFIG_2_2 = DataTypes.UserConfigurationMap(0, 0)
        # 1
        let (TEST_USER_CONFIG) = UserConfiguration.set_borrowing(TEST_ADDRESS, TEST_RESERVE_INDEX, TEST_USER_CONFIG, TRUE)

        let (col) = UserConfiguration.is_borrowing_any(TEST_ADDRESS)
        assert col = TRUE

        # 2
        let (TEST_USER_CONFIG_2_1) = UserConfiguration.set_borrowing(TEST_ADDRESS2, TEST_RESERVE_INDEX, TEST_USER_CONFIG_2_1, TRUE)
        let (TEST_USER_CONFIG_2_2) = UserConfiguration.set_borrowing(TEST_ADDRESS2, TEST_RESERVE_INDEX_2, TEST_USER_CONFIG_2_2, TRUE)

        let (col) = UserConfiguration.is_borrowing_any(TEST_ADDRESS2)
        assert col = TRUE

        # 3
        let (col) = UserConfiguration.is_borrowing_any(TEST_ADDRESS3)
        assert col = FALSE

        return ()
    end

    func test_is_empty{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
        let TEST_USER_CONFIG = DataTypes.UserConfigurationMap(0, 0)
        # 1
        let (col) = UserConfiguration.is_empty(TEST_ADDRESS)
        assert col = TRUE

        # 2
        let (TEST_USER_CONFIG) = UserConfiguration.set_borrowing(TEST_ADDRESS, TEST_RESERVE_INDEX, TEST_USER_CONFIG, TRUE)

        let (col) = UserConfiguration.is_empty(TEST_ADDRESS)
        assert col = FALSE

        return ()
    end

    func test_get_first_asset_by_type{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        let TEST_USER_CONFIG_1_1 = DataTypes.UserConfigurationMap(0, 0)
        let TEST_USER_CONFIG_1_2 = DataTypes.UserConfigurationMap(0, 0)
        let TEST_USER_CONFIG_2_1 = DataTypes.UserConfigurationMap(0, 0)
        let TEST_USER_CONFIG_2_2 = DataTypes.UserConfigurationMap(0, 0)
        let TEST_USER_CONFIG_2_3 = DataTypes.UserConfigurationMap(0, 0)
        let TEST_USER_CONFIG_2_4 = DataTypes.UserConfigurationMap(0, 0)
        # 1
        let (TEST_USER_CONFIG_1_1) = UserConfiguration.set_borrowing(TEST_ADDRESS, TEST_RESERVE_INDEX, TEST_USER_CONFIG_1_1, TRUE)
        let (TEST_USER_CONFIG_1_2) = UserConfiguration.set_borrowing(TEST_ADDRESS, TEST_RESERVE_INDEX_2, TEST_USER_CONFIG_1_2, TRUE)

        let (ast) = UserConfiguration.get_first_asset_by_type(TEST_ADDRESS, BORROWING_TYPE)

        assert ast = TEST_RESERVE_INDEX

        # 2
        let (TEST_USER_CONFIG_2_1) = UserConfiguration.set_borrowing(TEST_ADDRESS2, TEST_RESERVE_INDEX, TEST_USER_CONFIG_2_1, TRUE)
        let (TEST_USER_CONFIG_2_2) = UserConfiguration.set_borrowing(TEST_ADDRESS2, TEST_RESERVE_INDEX_2, TEST_USER_CONFIG_2_2, TRUE)
        let (TEST_USER_CONFIG_2_3) = UserConfiguration.set_borrowing(TEST_ADDRESS2, TEST_RESERVE_INDEX_3, TEST_USER_CONFIG_2_3, TRUE)
        let (TEST_USER_CONFIG_2_4) = UserConfiguration.set_borrowing(TEST_ADDRESS2, TEST_RESERVE_INDEX, TEST_USER_CONFIG_2_4, FALSE)

        let (ast) = UserConfiguration.get_first_asset_by_type(TEST_ADDRESS2, BORROWING_TYPE)

        assert ast = TEST_RESERVE_INDEX_2

        # 3
        # UserConfiguration.set_using_as_collateral(TEST_ADDRESS3, TEST_RESERVE_INDEX, TRUE)
        # UserConfiguration.set_using_as_collateral(TEST_ADDRESS3, TEST_RESERVE_INDEX_2, TRUE)
        # UserConfiguration.set_using_as_collateral(TEST_ADDRESS3, TEST_RESERVE_INDEX_3, TRUE)
        # UserConfiguration.set_using_as_collateral(TEST_ADDRESS3, TEST_RESERVE_INDEX, FALSE)
        # UserConfiguration.set_using_as_collateral(TEST_ADDRESS3, TEST_RESERVE_INDEX_2, FALSE)
        # UserConfiguration.set_using_as_collateral(TEST_ADDRESS3, TEST_RESERVE_INDEX, TRUE)

        # let (ast) = UserConfiguration.get_first_asset_by_type(
        #     TEST_ADDRESS3, USING_AS_COLLATERAL_TYPE
        # )

        # assert ast = TEST_RESERVE_INDEX

        return ()
    end
end
