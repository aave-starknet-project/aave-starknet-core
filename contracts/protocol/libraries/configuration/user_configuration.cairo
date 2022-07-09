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
from contracts.protocol.libraries.configuration.reserve_configuration import ReserveConfiguration
from starkware.cairo.common.math import (
    assert_lt,
    assert_not_zero,
    assert_in_range,
    assert_not_equal,
)
from contracts.protocol.libraries.helpers.helpers import is_zero
# @notice Stores which reserves user is borrowing
# @dev using prefix UserConfiguration to prevent storage variable clashing
@storage_var
func UserConfiguration_borrowing(user_address : felt, reserve_id : felt) -> (res : felt):
end
# @notice Stores which reserves user is using as collateral
# @dev using prefix UserConfiguration to prevent storage variable clashing
@storage_var
func UserConfiguration_using_as_collateral(user_address : felt, reserve_id : felt) -> (res : felt):
end

namespace UserConfiguration:
    # @notice Sets if the user is borrowing the reserve identified by reserve_index
    # @dev uses ReserveIndex to store reserve indices in a packed list
    # @param user_address The address of a user
    # @param reserve_index The index of the reserve object
    # @param borrowing TRUE if user is borrowing the reserve, FALSE otherwise
    func set_borrowing{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user_address : felt, reserve_index : felt, borrowing : felt
    ):
        alloc_locals

        assert_not_zero(reserve_index)
        assert_lt(borrowing, 2)  # only TURE=1/FALSE=0 values

        let (current_borrowing) = UserConfiguration_borrowing.read(user_address, reserve_index)

        if borrowing == TRUE:
            with_attr error_message("Reserve asset already flaged as borrowing"):
                assert_not_equal(current_borrowing, TRUE)
            end

            ReserveIndex.add_reserve_index(BORROWING_TYPE, user_address, reserve_index)
        else:
            with_attr error_message("Reserve asset is not flaged as borrowing"):
                assert_not_equal(current_borrowing, FALSE)
            end
            ReserveIndex.remove_reserve_index(BORROWING_TYPE, user_address, reserve_index)
        end

        UserConfiguration_borrowing.write(user_address, reserve_index, borrowing)

        return ()
    end
    # @notice Sets if the user is using as collateral the reserve identified by reserve_index
    # @dev uses ReserveIndex to store reserve indices in a packed list
    # @param user_address The address of a user
    # @param reserve_index The index of the reserve object
    # @param using_as_collateral TRUE if user is using the reserve as collateral, FALSE otherwise
    func set_using_as_collateral{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user_address : felt, reserve_index : felt, using_as_collateral : felt
    ):
        alloc_locals

        assert_not_zero(reserve_index)
        assert_lt(using_as_collateral, 2)  # only TURE=1/FALSE=0 values

        let (current_using_as_collateral) = UserConfiguration_using_as_collateral.read(
            user_address, reserve_index
        )

        if using_as_collateral == TRUE:
            with_attr error_message("Reserve asset already flaged: 'using as collateral'"):
                assert_not_equal(current_using_as_collateral, TRUE)
            end

            ReserveIndex.add_reserve_index(USING_AS_COLLATERAL_TYPE, user_address, reserve_index)
        else:
            with_attr error_message("Reserve asset is not flaged as borrowing"):
                assert_not_equal(current_using_as_collateral, FALSE)
            end
            ReserveIndex.remove_reserve_index(USING_AS_COLLATERAL_TYPE, user_address, reserve_index)
        end

        UserConfiguration_using_as_collateral.write(
            user_address, reserve_index, using_as_collateral
        )

        return ()
    end
    # @notice Returns if a user has been using the reserve for borrowing or as collateral
    # @param user_address The address of a user
    # @param reserve_index The index of the reserve object
    # @return TRUE if the user has been using a reserve for borrowing or as collateral, FALSE otherwise
    func is_using_as_collateral_or_borrowing{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(user_address : felt, reserve_index : felt) -> (res : felt):
        let (res_col) = UserConfiguration_using_as_collateral.read(user_address, reserve_index)
        let (is_not_zero_col) = is_not_zero(res_col)
        if is_not_zero_col == TRUE:
            return (TRUE)
        end

        let (res_bor) = UserConfiguration_borrowing.read(user_address, reserve_index)
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
        user_address : felt, reserve_index : felt
    ) -> (res : felt):
        let (res) = UserConfiguration_borrowing.read(user_address, reserve_index)
        return (res)
    end
    # @notice Validate a user has been using the reserve as collateral
    # @param user_address The address of a user
    # @param reserve_index The index of the reserve object
    # @return TRUE if the user has been using a reserve as collateral, FALSE otherwise
    func is_using_as_collateral{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user_address : felt, reserve_index : felt
    ) -> (res : felt):
        let (res) = UserConfiguration_using_as_collateral.read(user_address, reserve_index)
        return (res)
    end
    # @notice Checks if a user has been supplying only one reserve as collateral
    # @param user_address The address of a user
    # @return TRUE if the user has been supplying as collateral one reserve, FALSE otherwise
    func is_using_as_collateral_one{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(user_address : felt) -> (res : felt):
        alloc_locals

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
        if is_collateral_list_empty == 1:
            return (FALSE)
        else:
            return (TRUE)
        end
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
        if is_borrowing_list_empty == 1:
            return (FALSE)
        else:
            return (TRUE)
        end
    end
    # @notice Checks if a user has not been using any reserve for borrowing or supply
    # @param user_address The address of a user
    # @return TRUE if the user has not been borrowing or supplying any reserve, FALSE otherwise
    func is_empty{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user_address : felt
    ) -> (res : felt):
        alloc_locals

        let (is_borrowing_list_empty) = ReserveIndex.is_list_empty(BORROWING_TYPE, user_address)
        let (is_using_collateral_list_empty) = ReserveIndex.is_list_empty(
            USING_AS_COLLATERAL_TYPE, user_address
        )

        let bool_res = is_borrowing_list_empty + is_using_collateral_list_empty
        if bool_res == 2:
            return (TRUE)
        else:
            return (FALSE)
        end
    end
    # TODO: TESTING OF get_isolation_mode_state and get_siloed_borrowing_state
    # @notice Returns the Isolation Mode state of the user
    # @param user_address The address of a user
    # @return TRUE if the user is in isolation mode, FALSE otherwise
    # @return The address of the only asset used as collateral
    # @return The debt ceiling of the reserve
    func get_isolation_mode_sate{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user_address : felt
    ) -> (bool : felt, asset_address : felt, ceilling : felt):
        alloc_locals

        let (is_one) = is_using_as_collateral_one(user_address)
        if is_one == FALSE:
            return (FALSE, 0, 0)
        end

        let (asset_index) = get_first_asset_by_type(USING_AS_COLLATERAL_TYPE, user_address)
        let (asset_address) = PoolStorage.reserves_list_read(asset_index)
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
    }(user_address : felt) -> (bool : felt, asset_address : felt):
        let (is_one) = is_borrowing_one(user_address)
        if is_one == FALSE:
            return (FALSE, 0)
        end

        let (asset_index) = get_first_asset_by_type(USING_AS_COLLATERAL_TYPE, user_address)
        let (asset_address) = PoolStorage.reserves_list_read(asset_index)
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
        alloc_locals

        let (res) = ReserveIndex.get_lowest_reserve_index(type, user_address)
        return (res)
    end
end
