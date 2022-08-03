%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math_cmp import is_not_zero, is_le
from starkware.cairo.common.bool import TRUE, FALSE
from contracts.protocol.libraries.configuration.reserve_index_operations import (
    ReserveIndex,
    BORROWING_TYPE,
    USING_AS_COLLATERAL_TYPE,
)
from contracts.protocol.pool.pool_storage import PoolStorage
from contracts.protocol.libraries.types.data_types import DataTypes
from contracts.protocol.libraries.configuration.reserve_configuration import ReserveConfiguration
from starkware.cairo.common.math import (
    assert_lt,
    assert_not_zero,
    assert_in_range,
    assert_not_equal,
    assert_le,
)
from contracts.protocol.libraries.helpers.helpers import is_zero
from contracts.protocol.libraries.helpers.bool_cmp import BoolCompare

namespace UserConfiguration:
    const MAX_RESERVES_COUNT = 128
    # @notice Sets if the user is borrowing the reserve identified by reserve_index
    # @dev uses ReserveIndex to store reserve indices in a packed list
    # @param user_address The address of a user
    # @param reserve_index The index of the reserve object
    # @param borrowing TRUE if user is borrowing the reserve, FALSE otherwise
    func set_borrowing{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user_address : felt, reserve_index : felt, current_user_config : DataTypes.UserConfigurationMap, borrowing : felt
    ) -> (res : DataTypes.UserConfigurationMap):
        alloc_locals

        assert_lt(borrowing, 2)  # only TURE=1/FALSE=0 values
        assert_le(reserve_index, MAX_RESERVES_COUNT)
        assert_not_zero(user_address)

        # let (current_user_config) = PoolStorage.users_config_read(user_address, reserve_index)

        let new_user_config = DataTypes.UserConfigurationMap(
            borrowing=borrowing, using_as_collateral=current_user_config.using_as_collateral
        )

        # PoolStorage.users_config_write(user_address, reserve_index, new_user_config)

        if borrowing == TRUE:
            ReserveIndex.add_reserve_index(BORROWING_TYPE, user_address, reserve_index)
        else:
            ReserveIndex.remove_reserve_index(BORROWING_TYPE, user_address, reserve_index)
        end

        return (new_user_config)
    end
    # @notice Sets if the user is using as collateral the reserve identified by reserve_index
    # @dev uses ReserveIndex to store reserve indices in a packed list
    # @param user_address The address of a user
    # @param reserve_index The index of the reserve object
    # @param using_as_collateral TRUE if user is using the reserve as collateral, FALSE otherwise
    func set_using_as_collateral{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user_address : felt, reserve_index : felt, current_user_config : DataTypes.UserConfigurationMap, using_as_collateral : felt
    ) -> (res : DataTypes.UserConfigurationMap):
        assert_lt(using_as_collateral, 2)  # only TURE=1/FALSE=0 values
        assert_le(reserve_index, MAX_RESERVES_COUNT)
        assert_not_zero(user_address)

        # let (current_user_config) = PoolStorage.users_config_read(user_address, reserve_index)

        let new_user_config = DataTypes.UserConfigurationMap(
            borrowing=current_user_config.borrowing, using_as_collateral=using_as_collateral
        )

        # PoolStorage.users_config_write(user_address, reserve_index, new_user_config)

        if using_as_collateral == TRUE:
            ReserveIndex.add_reserve_index(USING_AS_COLLATERAL_TYPE, user_address, reserve_index)
        else:
            ReserveIndex.remove_reserve_index(USING_AS_COLLATERAL_TYPE, user_address, reserve_index)
        end

        return (new_user_config)
    end
    # @notice Returns if a user has been using the reserve for borrowing or as collateral
    # @param user_address The address of a user
    # @param reserve_index The index of the reserve object
    # @return TRUE if the user has been using a reserve for borrowing or as collateral, FALSE otherwise
    func is_using_as_collateral_or_borrowing{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(user_config : DataTypes.UserConfigurationMap) -> (res : felt):
        # assert_not_zero(user_address)
        # assert_le(reserve_index, MAX_RESERVES_COUNT)

        # let (user_config) = PoolStorage.users_config_read(user_address, reserve_index)
        let res_col = user_config.using_as_collateral

        let (is_not_zero_col) = is_not_zero(res_col)

        if is_not_zero_col == TRUE:
            return (TRUE)
        end

        let res_bor = user_config.borrowing

        let (is_not_zero_bor) = is_not_zero(res_bor)

        if is_not_zero_bor == TRUE:
            return (TRUE)
        end

        return (FALSE)
    end
    # @notice Validate a user has been using the reserve for borrowing
    # @param user_address The address of a user
    # @param reserve_index The index of the reserve object
    # @return TRUE if the user has been using a reserve for borrowing, FALSE otherwise
    func is_borrowing{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user_config : DataTypes.UserConfigurationMap
    ) -> (res : felt):
        # assert_not_zero(user_address)
        # assert_le(reserve_index, MAX_RESERVES_COUNT)

        # let (user_config) = PoolStorage.users_config_read(user_address, reserve_index)

        let res = user_config.borrowing

        return (res)
    end
    # @notice Validate a user has been using the reserve as collateral
    # @param user_address The address of a user
    # @param reserve_index The index of the reserve object
    # @return TRUE if the user has been using a reserve as collateral, FALSE otherwise
    func is_using_as_collateral{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user_config : DataTypes.UserConfigurationMap
    ) -> (res : felt):
        # assert_not_zero(user_address)
        # assert_le(reserve_index, MAX_RESERVES_COUNT)

        # let (user_config) = PoolStorage.users_config_read(user_address, reserve_index)

        let res = user_config.using_as_collateral

        return (res)
    end
    # @notice Checks if a user has been supplying only one reserve as collateral
    # @param user_address The address of a user
    # @return TRUE if the user has been supplying as collateral one reserve, FALSE otherwise
    func is_using_as_collateral_one{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(user_address : felt) -> (res : felt):
        assert_not_zero(user_address)

        let (res) = ReserveIndex.is_only_one_element(USING_AS_COLLATERAL_TYPE, user_address)

        return (res)
    end
    # @notice Checks if a user has been supplying any reserve as collateral
    # @param user_address The address of a user
    # @return TRUE if the user has been supplying as collateral any reserve, FALSE otherwise
    func is_using_as_collateral_any{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(user_address : felt) -> (res : felt):
        assert_not_zero(user_address)

        let (is_collateral_list_empty) = ReserveIndex.is_list_empty(
            USING_AS_COLLATERAL_TYPE, user_address
        )
        if is_collateral_list_empty == TRUE:
            return (FALSE)
        end
        return (TRUE)
    end
    # @notice Checks if a user has been borrowing only one asset
    # @param user_address The address of a user
    # @return TRUE if the user has been borrowing only one asset, FALSE otherwise
    func is_borrowing_one{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user_address : felt
    ) -> (res : felt):
        alloc_locals

        assert_not_zero(user_address)

        let (res) = ReserveIndex.is_only_one_element(BORROWING_TYPE, user_address)
        return (res)
    end
    # @notice Checks if a user has been borrowing from any reserve
    # @param user_address The address of a user
    # @return TRUE if the user has been borrowing any reserve, FALSE otherwise
    func is_borrowing_any{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user_address : felt
    ) -> (res : felt):
        assert_not_zero(user_address)

        let (is_borrowing_list_empty) = ReserveIndex.is_list_empty(BORROWING_TYPE, user_address)

        if is_borrowing_list_empty == TRUE:
            return (FALSE)
        end
        return (TRUE)
    end
    # @notice Checks if a user has not been using any reserve for borrowing or supply
    # @param user_address The address of a user
    # @return TRUE if the user has not been borrowing or supplying any reserve, FALSE otherwise
    func is_empty{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user_address : felt
    ) -> (res : felt):
        assert_not_zero(user_address)

        let (is_borrowing_list_empty) = ReserveIndex.is_list_empty(BORROWING_TYPE, user_address)

        let (is_using_collateral_list_empty) = ReserveIndex.is_list_empty(
            USING_AS_COLLATERAL_TYPE, user_address
        )

        let (res) = BoolCompare.both(is_borrowing_list_empty, is_using_collateral_list_empty)

        return (res)
    end
    # TODO: TESTING OF get_isolation_mode_state and get_siloed_borrowing_state
    # @notice Returns the Isolation Mode state of the user
    # @param user_address The address of a user
    # @return TRUE if the user is in isolation mode, FALSE otherwise
    # @return The address of the only asset used as collateral
    # @return The debt ceiling of the reserve
    func get_isolation_mode_sate{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user_address : felt, reserves_list : felt*
    ) -> (bool : felt, asset_address : felt, ceilling : felt):
        assert_not_zero(user_address)

        let (is_one) = is_using_as_collateral_one(user_address)

        if is_one == FALSE:
            return (FALSE, 0, 0)
        end

        let (asset_index) = get_first_asset_by_type(USING_AS_COLLATERAL_TYPE, user_address)
        let asset_address = [reserves_list + asset_index]
        # let (asset_address) = PoolStorage.reserves_list_read(asset_index)
        let (ceilling) = ReserveConfiguration.get_debt_ceiling(asset_address)
        let (is_ceilling_not_zero) = is_not_zero(ceilling)

        if is_ceilling_not_zero == TRUE:
            return (TRUE, asset_address, ceilling)
        end

        return (FALSE, 0, 0)
    end
    # @notice Returns the siloed borrowing state for the user
    # @param user_address The address of a user
    # @return TRUE if the user has borrowed a siloed asset, FALSE otherwise
    # @return The address of the only borrowed asset
    func get_siloed_borrowing_state{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(user_address : felt, reserves_list : felt*) -> (bool : felt, asset_address : felt):
        assert_not_zero(user_address)

        let (is_one) = is_borrowing_one(user_address)

        if is_one == FALSE:
            return (FALSE, 0)
        end

        let (asset_index) = get_first_asset_by_type(BORROWING_TYPE, user_address)
        let asset_address = [reserves_list + asset_index]
        let (siloed_borrowing) = ReserveConfiguration.get_siloed_borrowing(asset_address)
        let (is_siloed_borrowing_not_zero) = is_not_zero(siloed_borrowing)

        if is_siloed_borrowing_not_zero == TRUE:
            return (TRUE, asset_address)
        end

        return (FALSE, 0)
    end
    # @notice Returns the address of the first asset (lowest index) flagged given the corresponding type (borrowing/using as collateral)
    # @param user_address The address of a user
    # @param type The type of asset: BORROWING_TYPE or USING_AS_COLLATERAL_TYPE
    # @return res Address of the first asset flagged (lowest index)
    func get_first_asset_by_type{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user_address : felt, type : felt
    ) -> (res : felt):
        assert_not_zero(user_address)

        let (res) = ReserveIndex.get_lowest_reserve_index(type, user_address)

        return (res)
    end
end
