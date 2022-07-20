%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_le

from contracts.protocol.libraries.helpers.bool_cmp import BoolCompare
from contracts.protocol.pool.pool_storage import PoolStorage
from contracts.protocol.libraries.helpers.helpers import update_struct
from contracts.protocol.libraries.types.data_types import DataTypes

from starkware.cairo.common.registers import get_fp_and_pc
from starkware.cairo.common.alloc import alloc

# @storage_var
# func ReserveConfiguration_ltv(reserve_asset : felt) -> (value : felt):
# end

# @storage_var
# func ReserveConfiguration_liquidation_threshold(reserve_asset : felt) -> (value : felt):
# end

# @storage_var
# func ReserveConfiguration_liquidation_bonus(reserve_asset : felt) -> (value : felt):
# end

# @storage_var
# func ReserveConfiguration_decimals(reserve_asset : felt) -> (value : felt):
# end

# @storage_var
# func ReserveConfiguration_reserve_active(reserve_asset : felt) -> (boolean : felt):
# end

# @storage_var
# func ReserveConfiguration_reserve_frozen(reserve_asset : felt) -> (boolean : felt):
# end

# @storage_var
# func ReserveConfiguration_borrowing_enabled(reserve_asset : felt) -> (boolean : felt):
# end

# @storage_var
# func ReserveConfiguration_stable_rate_borrowing_enabled(reserve_asset : felt) -> (boolean : felt):
# end

# @storage_var
# func ReserveConfiguration_asset_paused(reserve_asset : felt) -> (boolean : felt):
# end

# @storage_var
# func ReserveConfiguration_borrowable_in_isolation(reserve_asset : felt) -> (boolean : felt):
# end

# @storage_var
# func ReserveConfiguration_siloed_borrowing(reserve_asset : felt) -> (boolean : felt):
# end

# @storage_var
# func ReserveConfiguration_reserve_factor(reserve_asset : felt) -> (boolean : felt):
# end

# @storage_var
# func ReserveConfiguration_borrow_cap(reserve_asset : felt) -> (value : felt):
# end

# @storage_var
# func ReserveConfiguration_supply_cap(reserve_asset : felt) -> (value : felt):
# end

# @storage_var
# func ReserveConfiguration_liquidation_protocol_fee(reserve_asset : felt) -> (value : felt):
# end

# @storage_var
# func ReserveConfiguration_eMode_category(reserve_asset : felt) -> (value : felt):
# end

# @storage_var
# func ReserveConfiguration_unbacked_mint_cap(reserve_asset : felt) -> (value : felt):
# end

# @storage_var
# func ReserveConfiguration_debt_ceiling(reserve_asset : felt) -> (value : felt):
# end


const MAX_VALID_LTV = 65535
const MAX_VALID_LIQUIDATION_THRESHOLD = 65535
const MAX_VALID_LIQUIDATION_BONUS = 65535
const MAX_VALID_DECIMALS = 255
const MAX_VALID_RESERVE_FACTOR = 65535
const MAX_VALID_BORROW_CAP = 68719476735
const MAX_VALID_SUPPLY_CAP = 68719476735
const MAX_VALID_LIQUIDATION_PROTOCOL_FEE = 65535
const MAX_VALID_EMODE_CATEGORY = 255
const MAX_VALID_UNBACKED_MINT_CAP = 68719476735
const MAX_VALID_DEBT_CEILING = 1099511627775

namespace ReserveConfiguration:
    const DEBT_CEILING_DECIMALS = 2
    const MAX_RESERVES_COUNT = 128

    # @notice Sets the Loan to Value of the reserve
    # @param reserve_asset underlying asset of the reserve
    # @param value The new ltv
    func set_ltv{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt, value : felt
    ):
        alloc_locals

        with_attr error_message("Invalid ltv parameter for the reserve"):
            assert_le(value, MAX_VALID_LTV)
        end

        let (__fp__, _) = get_fp_and_pc()

        let (local current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let (local updated_reserves_config : DataTypes.ReserveConfigurationMap*) = update_struct(
            &current_reserves_config,
            DataTypes.ReserveConfigurationMap.SIZE,
            &value,
            DataTypes.ReserveConfigurationMap.ltv,
        )

        PoolStorage.reserves_config_write(reserve_asset, [updated_reserves_config])

        # ReserveConfiguration_ltv.write(reserve_asset, value)

        return ()
    end

    # @notice Gets the Loan to Value of the reserve
    # @return The loan to value
    func get_ltv{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt
    ) -> (value : felt):
        let (current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let res = current_reserves_config.ltv

        return (res)
    end

    # @notice Sets the liquidation threshold of the reserve
    # @param value The new liquidation threshold
    func set_liquidation_threshold{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(reserve_asset : felt, value : felt):
        alloc_locals

        with_attr error_message("Invalid liquidity threshold parameter for the reserve"):
            assert_le(value, MAX_VALID_LIQUIDATION_THRESHOLD)
        end

        let (__fp__, _) = get_fp_and_pc()

        let (local current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let (local updated_reserves_config : DataTypes.ReserveConfigurationMap*) = update_struct(
            &current_reserves_config,
            DataTypes.ReserveConfigurationMap.SIZE,
            &value,
            DataTypes.ReserveConfigurationMap.liquidation_threshold,
        )

        PoolStorage.reserves_config_write(reserve_asset, [updated_reserves_config])

        return ()
    end

    # @notice Gets the liquidation threshold of the reserve
    # @return The liquidation threshold
    func get_liquidation_threshold{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(reserve_asset : felt) -> (value : felt):
        let (current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let res = current_reserves_config.liquidation_threshold

        return (res)
    end

    # @notice Sets the liquidation bonus of the reserve
    # @param value The new liquidation bonus
    func set_liquidation_bonus{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt, value : felt
    ):
        alloc_locals

        with_attr error_message("Invalid liquidity bonus parameter for the reserve"):
            assert_le(value, MAX_VALID_LIQUIDATION_BONUS)
        end

        let (__fp__, _) = get_fp_and_pc()

        let (local current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let (local updated_reserves_config : DataTypes.ReserveConfigurationMap*) = update_struct(
            &current_reserves_config,
            DataTypes.ReserveConfigurationMap.SIZE,
            &value,
            DataTypes.ReserveConfigurationMap.liquidation_bonus,
        )

        PoolStorage.reserves_config_write(reserve_asset, [updated_reserves_config])

        # ReserveConfiguration_liquidation_bonus.write(reserve_asset, value)

        return ()
    end

    # @notice Gets the liquidation bonus of the reserve
    # @return The liquidation bonus
    func get_liquidation_bonus{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt
    ) -> (value : felt):
        # let (res) = ReserveConfiguration_liquidation_bonus.read(reserve_asset)

        let (current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let res = current_reserves_config.liquidation_bonus

        return (res)
    end

    # @notice Sets the decimals of the underlying asset of the reserve
    # @param value The decimals
    func set_decimals{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt, value : felt
    ):
        alloc_locals

        with_attr error_message(
                "Invalid decimals parameter of the underlying asset of the reserve"):
            assert_le(value, MAX_VALID_DECIMALS)
        end

        let (__fp__, _) = get_fp_and_pc()

        let (local current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let (local updated_reserves_config : DataTypes.ReserveConfigurationMap*) = update_struct(
            &current_reserves_config,
            DataTypes.ReserveConfigurationMap.SIZE,
            &value,
            DataTypes.ReserveConfigurationMap.decimals,
        )

        PoolStorage.reserves_config_write(reserve_asset, [updated_reserves_config])
        # ReserveConfiguration_decimals.write(reserve_asset, value)

        return ()
    end

    # @notice Gets the decimals of the underlying asset of the reserve
    # @return The decimals of the asset
    func get_decimals{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt
    ) -> (value : felt):
        # let (res) = ReserveConfiguration_decimals.read(reserve_asset)

        let (current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let res = current_reserves_config.decimals


        return (res)
    end

    # @notice Sets the active state of the reserve
    # @param active The active state
    func set_active{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt, active : felt
    ):
        alloc_locals

        BoolCompare.is_valid(active)

        let (__fp__, _) = get_fp_and_pc()

        let (local current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let (local updated_reserves_config : DataTypes.ReserveConfigurationMap*) = update_struct(
            &current_reserves_config,
            DataTypes.ReserveConfigurationMap.SIZE,
            &active,
            DataTypes.ReserveConfigurationMap.reserve_active,
        )

        PoolStorage.reserves_config_write(reserve_asset, [updated_reserves_config])

        # ReserveConfiguration_reserve_active.write(reserve_asset, active)

        return ()
    end

    # @notice Gets the active state of the reserve
    # @return The active state
    func get_active{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt
    ) -> (value : felt):
        # let (res) = ReserveConfiguration_reserve_active.read(reserve_asset)

        let (current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let res = current_reserves_config.reserve_active

        return (res)
    end

    # @notice Sets the frozen state of the reserve
    # @param frozen The frozen state
    func set_frozen{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt, frozen : felt
    ):
        alloc_locals

        BoolCompare.is_valid(frozen)

        let (__fp__, _) = get_fp_and_pc()

        let (local current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let (local updated_reserves_config : DataTypes.ReserveConfigurationMap*) = update_struct(
            &current_reserves_config,
            DataTypes.ReserveConfigurationMap.SIZE,
            &frozen,
            DataTypes.ReserveConfigurationMap.reserve_frozen,
        )

        PoolStorage.reserves_config_write(reserve_asset, [updated_reserves_config])

        # ReserveConfiguration_reserve_frozen.write(reserve_asset, frozen)

        return ()
    end

    # @notice Gets the frozen state of the reserve
    # @return The frozen state
    func get_frozen{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt
    ) -> (value : felt):
        # let (res) = ReserveConfiguration_reserve_frozen.read(reserve_asset)

        let (current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let res = current_reserves_config.reserve_frozen

        return (res)
    end

    # @notice Sets the paused state of the reserve
    # @param value The paused state
    func set_paused{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt, paused : felt
    ):
        alloc_locals

        BoolCompare.is_valid(paused)

        let (__fp__, _) = get_fp_and_pc()

        let (local current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let (local updated_reserves_config : DataTypes.ReserveConfigurationMap*) = update_struct(
            &current_reserves_config,
            DataTypes.ReserveConfigurationMap.SIZE,
            &paused,
            DataTypes.ReserveConfigurationMap.asset_paused,
        )

        PoolStorage.reserves_config_write(reserve_asset, [updated_reserves_config])

        # ReserveConfiguration_asset_paused.write(reserve_asset, paused)

        return ()
    end

    # @notice Gets the paused state of the reserve
    # @return The paused state
    func get_paused{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt
    ) -> (value : felt):
        # let (res) = ReserveConfiguration_asset_paused.read(reserve_asset)

        let (current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let res = current_reserves_config.asset_paused

        return (res)
    end

    # @notice Sets the borrowable in isolation flag for the reserve
    # @dev When this flag is set to true, the asset will be borrowable against isolated collaterals and the borrowed
    # amount will be accumulated in the isolated collateral's total debt exposure.
    # @dev Only assets of the same family (eg USD stablecoins) should be borrowable in isolation mode to keep
    # consistency in the debt ceiling calculations.
    # @param borrowable True if the asset is borrowable
    func set_borrowable_in_isolation{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(reserve_asset : felt, borrowable : felt):
        alloc_locals

        BoolCompare.is_valid(borrowable)

        let (__fp__, _) = get_fp_and_pc()

        let (local current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let (local updated_reserves_config : DataTypes.ReserveConfigurationMap*) = update_struct(
            &current_reserves_config,
            DataTypes.ReserveConfigurationMap.SIZE,
            &borrowable,
            DataTypes.ReserveConfigurationMap.borrowable_in_isolation,
        )

        PoolStorage.reserves_config_write(reserve_asset, [updated_reserves_config])

        # ReserveConfiguration_borrowable_in_isolation.write(reserve_asset, borrowable)

        return ()
    end

    # @notice Gets the borrowable in isolation flag for the reserve.
    # @dev If the returned flag is true, the asset is borrowable against isolated collateral. Assets borrowed with
    # isolated collateral is accounted for in the isolated collateral's total debt exposure.
    # @dev Only assets of the same family (eg USD stablecoins) should be borrowable in isolation mode to keep
    # consistency in the debt ceiling calculations.
    # @return The borrowable in isolation flag
    func get_borrowable_in_isolation{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(reserve_asset : felt) -> (value : felt):
        # let (res) = ReserveConfiguration_borrowable_in_isolation.read(reserve_asset)

        let (current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let res = current_reserves_config.borrowable_in_isolation

        return (res)
    end

    # @notice Sets the siloed borrowing flag for the reserve.
    # @dev When this flag is set to true, users borrowing this asset will not be allowed to borrow any other asset.
    # @param siloed True if the asset is siloed
    func set_siloed_borrowing{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt, siloed : felt
    ):
        alloc_locals

        BoolCompare.is_valid(siloed)

        let (__fp__, _) = get_fp_and_pc()

        let (local current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let (local updated_reserves_config : DataTypes.ReserveConfigurationMap*) = update_struct(
            &current_reserves_config,
            DataTypes.ReserveConfigurationMap.SIZE,
            &siloed,
            DataTypes.ReserveConfigurationMap.siloed_borrowing,
        )

        PoolStorage.reserves_config_write(reserve_asset, [updated_reserves_config])

        # ReserveConfiguration_siloed_borrowing.write(reserve_asset, siloed)

        return ()
    end

    # @notice Gets the siloed borrowing flag for the reserve.
    # @dev When this flag is set to true, users borrowing this asset will not be allowed to borrow any other asset.
    # @return The siloed borrowing flag
    func get_siloed_borrowing{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt
    ) -> (value : felt):
        # let (res) = ReserveConfiguration_siloed_borrowing.read(reserve_asset)

        let (current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let res = current_reserves_config.siloed_borrowing

        return (res)
    end

    # @notice Enables or disables borrowing on the reserve
    # @param enabled True if the borrowing needs to be enabled, false otherwise
    func set_borrowing_enabled{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt, enabled : felt
    ):
        alloc_locals

        BoolCompare.is_valid(enabled)

        let (__fp__, _) = get_fp_and_pc()

        let (local current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let (local updated_reserves_config : DataTypes.ReserveConfigurationMap*) = update_struct(
            &current_reserves_config,
            DataTypes.ReserveConfigurationMap.SIZE,
            &enabled,
            DataTypes.ReserveConfigurationMap.borrowing_enabled,
        )

        PoolStorage.reserves_config_write(reserve_asset, [updated_reserves_config])

        # ReserveConfiguration_borrowing_enabled.write(reserve_asset, enabled)

        return ()
    end

    # @notice Gets the borrowing state of the reserve
    # @return The borrowing state
    func get_borrowing_enabled{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt
    ) -> (value : felt):
        # let (res) = ReserveConfiguration_borrowing_enabled.read(reserve_asset)

        let (current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let res = current_reserves_config.borrowing_enabled

        return (res)
    end

    # @notice Enables or disables stable rate borrowing on the reserve
    # @param enabled True if the stable rate borrowing needs to be enabled, false otherwise
    func set_stable_rate_borrowing_enabled{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(reserve_asset : felt, enabled : felt):
        alloc_locals

        BoolCompare.is_valid(enabled)

        let (__fp__, _) = get_fp_and_pc()

        let (local current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let (local updated_reserves_config : DataTypes.ReserveConfigurationMap*) = update_struct(
            &current_reserves_config,
            DataTypes.ReserveConfigurationMap.SIZE,
            &enabled,
            DataTypes.ReserveConfigurationMap.stable_rate_borrowing_enabled,
        )

        PoolStorage.reserves_config_write(reserve_asset, [updated_reserves_config])

        # ReserveConfiguration_stable_rate_borrowing_enabled.write(reserve_asset, enabled)

        return ()
    end

    # @notice Gets the stable rate borrowing state of the reserve
    # @return The stable rate borrowing state
    func get_stable_rate_borrowing_enabled{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(reserve_asset : felt) -> (value : felt):
        # let (res) = ReserveConfiguration_stable_rate_borrowing_enabled.read(reserve_asset)

        let (current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let res = current_reserves_config.stable_rate_borrowing_enabled

        return (res)
    end

    # @notice Sets the reserve factor of the reserve
    # @param reserveFactor The reserve factor
    func set_reserve_factor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt, value : felt
    ):
        alloc_locals

        with_attr error_message("Invalid reserve factor parameter for the reserve"):
            assert_le(value, MAX_VALID_RESERVE_FACTOR)
        end

        let (__fp__, _) = get_fp_and_pc()

        let (local current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let (local updated_reserves_config : DataTypes.ReserveConfigurationMap*) = update_struct(
            &current_reserves_config,
            DataTypes.ReserveConfigurationMap.SIZE,
            &value,
            DataTypes.ReserveConfigurationMap.reserve_factor,
        )

        PoolStorage.reserves_config_write(reserve_asset, [updated_reserves_config])

        # ReserveConfiguration_reserve_factor.write(reserve_asset, value)

        return ()
    end

    # @notice Gets the reserve factor of the reserve
    # @return The reserve factor
    func get_reserve_factor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt
    ) -> (value : felt):
        # let (res) = ReserveConfiguration_reserve_factor.read(reserve_asset)

        let (current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let res = current_reserves_config.reserve_factor

        return (res)
    end

    # @notice Sets the borrow cap of the reserve
    # @param borrowCap The borrow cap

    func set_borrow_cap{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt, value : felt
    ):
        alloc_locals

        with_attr error_message("Invalid borrow cap for the reserve"):
            assert_le(value, MAX_VALID_BORROW_CAP)
        end

        let (__fp__, _) = get_fp_and_pc()

        let (local current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let (local updated_reserves_config : DataTypes.ReserveConfigurationMap*) = update_struct(
            &current_reserves_config,
            DataTypes.ReserveConfigurationMap.SIZE,
            &value,
            DataTypes.ReserveConfigurationMap.borrow_cap,
        )

        PoolStorage.reserves_config_write(reserve_asset, [updated_reserves_config])

        # ReserveConfiguration_borrow_cap.write(reserve_asset, value)

        return ()
    end

    # @notice Gets the borrow cap of the reserve
    # @return The borrow cap

    func get_borrow_cap{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt
    ) -> (value : felt):
        # let (res) = ReserveConfiguration_borrow_cap.read(reserve_asset)

        let (current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let res = current_reserves_config.borrow_cap

        return (res)
    end

    # @notice Sets the supply cap of the reserve
    # @param supplyCap The supply cap

    func set_supply_cap{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt, value : felt
    ):
        alloc_locals

        with_attr error_message("Invalid supply cap for the reserve"):
            assert_le(value, MAX_VALID_SUPPLY_CAP)
        end

        let (__fp__, _) = get_fp_and_pc()

        let (local current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let (local updated_reserves_config : DataTypes.ReserveConfigurationMap*) = update_struct(
            &current_reserves_config,
            DataTypes.ReserveConfigurationMap.SIZE,
            &value,
            DataTypes.ReserveConfigurationMap.supply_cap,
        )

        PoolStorage.reserves_config_write(reserve_asset, [updated_reserves_config])

        # ReserveConfiguration_supply_cap.write(reserve_asset, value)

        return ()
    end

    # @notice Gets the supply cap of the reserve
    # @return The supply cap

    func get_supply_cap{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt
    ) -> (value : felt):
        # let (res) = ReserveConfiguration_supply_cap.read(reserve_asset)

        let (current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let res = current_reserves_config.supply_cap

        return (res)
    end

    # @notice Sets the debt ceiling in isolation mode for the asset
    # @param ceiling The maximum debt ceiling for the asset
    func set_debt_ceiling{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt, ceiling : felt
    ):
        alloc_locals

        with_attr error_message("Invalid debt ceiling for the reserve"):
            assert_le(ceiling, MAX_VALID_DEBT_CEILING)
        end

        let (__fp__, _) = get_fp_and_pc()

        let (local current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let (local updated_reserves_config : DataTypes.ReserveConfigurationMap*) = update_struct(
            &current_reserves_config,
            DataTypes.ReserveConfigurationMap.SIZE,
            &ceiling,
            DataTypes.ReserveConfigurationMap.debt_ceiling,
        )

        PoolStorage.reserves_config_write(reserve_asset, [updated_reserves_config])

        # ReserveConfiguration_debt_ceiling.write(reserve_asset, ceiling)

        return ()
    end

    # @notice Gets the debt ceiling for the asset if the asset is in isolation mode
    # @return The debt ceiling (0 = isolation mode disabled)
    func get_debt_ceiling{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt
    ) -> (value : felt):
        # let (res) = ReserveConfiguration_debt_ceiling.read(reserve_asset)

        let (current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let res = current_reserves_config.debt_ceiling

        return (res)
    end

    # @notice Sets the liquidation protocol fee of the reserve
    # @param value The liquidation protocol fee
    func set_liquidation_protocol_fee{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(reserve_asset : felt, value : felt):
        alloc_locals

        with_attr error_message("Invalid liquidation protocol fee for the reserve"):
            assert_le(value, MAX_VALID_LIQUIDATION_PROTOCOL_FEE)
        end

        let (__fp__, _) = get_fp_and_pc()

        let (local current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let (local updated_reserves_config : DataTypes.ReserveConfigurationMap*) = update_struct(
            &current_reserves_config,
            DataTypes.ReserveConfigurationMap.SIZE,
            &value,
            DataTypes.ReserveConfigurationMap.liquidation_protocol_fee,
        )

        PoolStorage.reserves_config_write(reserve_asset, [updated_reserves_config])

        # ReserveConfiguration_liquidation_protocol_fee.write(reserve_asset, value)

        return ()
    end

    # @dev Gets the liquidation protocol fee
    # @return The liquidation protocol fee
    func get_liquidation_protocol_fee{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(reserve_asset : felt) -> (value : felt):
        # let (res) = ReserveConfiguration_liquidation_protocol_fee.read(reserve_asset)

        let (current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let res = current_reserves_config.liquidation_protocol_fee

        return (res)
    end

    # @notice Sets the unbacked mint cap of the reserve
    # @param value The unbacked mint cap
    func set_unbacked_mint_cap{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt, value : felt
    ):
        alloc_locals

        with_attr error_message("Invalid unbacked mint cap for the reserve"):
            assert_le(value, MAX_VALID_UNBACKED_MINT_CAP)
        end

        let (__fp__, _) = get_fp_and_pc()

        let (local current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let (local updated_reserves_config : DataTypes.ReserveConfigurationMap*) = update_struct(
            &current_reserves_config,
            DataTypes.ReserveConfigurationMap.SIZE,
            &value,
            DataTypes.ReserveConfigurationMap.unbacked_mint_cap,
        )

        PoolStorage.reserves_config_write(reserve_asset, [updated_reserves_config])

        # ReserveConfiguration_unbacked_mint_cap.write(reserve_asset, value)

        return ()
    end

    # @dev Gets the unbacked mint cap of the reserve
    # @return The unbacked mint cap
    func get_unbacked_mint_cap{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt
    ) -> (value : felt):
        # let (res) = ReserveConfiguration_unbacked_mint_cap.read(reserve_asset)

        let (current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let res = current_reserves_config.unbacked_mint_cap

        return (res)
    end

    # @notice Sets the eMode asset category
    # @param category The asset category when the user selects the eMode
    func set_eMode_category{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt, category : felt
    ):
        alloc_locals

        with_attr error_message("Invalid eMode category for the reserve"):
            assert_le(category, MAX_VALID_EMODE_CATEGORY)
        end

        let (__fp__, _) = get_fp_and_pc()

        let (local current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let (local updated_reserves_config : DataTypes.ReserveConfigurationMap*) = update_struct(
            &current_reserves_config,
            DataTypes.ReserveConfigurationMap.SIZE,
            &category,
            DataTypes.ReserveConfigurationMap.eMode_category,
        )

        PoolStorage.reserves_config_write(reserve_asset, [updated_reserves_config])

        # ReserveConfiguration_eMode_category.write(reserve_asset, category)

        return ()
    end

    # @dev Gets the eMode asset category
    # @return The eMode category for the asset
    func get_eMode_category{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt
    ) -> (value : felt):
        # let (res) = ReserveConfiguration_eMode_category.read(reserve_asset)

        let (current_reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let res = current_reserves_config.eMode_category

        return (res)
    end

    # @notice Gets the configuration flags of the reserve
    # @return The state flag representing active
    # @return The state flag representing frozen
    # @return The state flag representing borrowing enabled
    # @return The state flag representing stableRateBorrowing enabled
    # @return The state flag representing paused
    func get_flags{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt
    ) -> (
        is_active : felt,
        is_frozen : felt,
        is_borrowing_enabled : felt,
        is_stable_rate_borrowing_enabled : felt,
        is_paused : felt,
    ):
        let (reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let is_active = reserves_config.reserve_active
        let is_frozen = reserves_config.reserve_frozen
        let is_borrowing_enabled = reserves_config.borrowing_enabled
        let is_stable_rate_borrowing_enabled = reserves_config.stable_rate_borrowing_enabled
        let is_paused = reserves_config.asset_paused


        return (
            is_active, is_frozen, is_borrowing_enabled, is_stable_rate_borrowing_enabled, is_paused
        )
    end

    # @notice Gets the configuration parameters of the reserve from storage
    # @return The state param representing ltv
    # @return The state param representing liquidation threshold
    # @return The state param representing liquidation bonus
    # @return The state param representing reserve decimals
    # @return The state param representing reserve factor
    # @return The state param representing eMode category
    func get_params{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt
    ) -> (
        ltv_value : felt,
        liquidation_threshold_value : felt,
        liquidation_bonus_value : felt,
        decimals_value : felt,
        reserve_factor_value : felt,
        eMode_category_value : felt,
    ):
        let (reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let ltv_value = reserves_config.ltv
        let liquidation_threshold_value = reserves_config.liquidation_threshold
        let liquidation_bonus_value = reserves_config.liquidation_bonus
        let decimals_value = reserves_config.decimals
        let reserve_factor_value = reserves_config.reserve_factor
        let eMode_category_value = reserves_config.eMode_category

        return (
            ltv_value,
            liquidation_threshold_value,
            liquidation_bonus_value,
            decimals_value,
            reserve_factor_value,
            eMode_category_value,
        )
    end

    # @notice Gets the caps parameters of the reserve from storage
    # @return The state param representing borrow cap
    # @return The state param representing supply cap.
    func get_caps{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt
    ) -> (borrow_cap : felt, supply_cap : felt):
        let (reserves_config) = PoolStorage.reserves_config_read(reserve_asset)

        let borrow_cap_value = reserves_config.borrow_cap
        let supply_cap_value = reserves_config.supply_cap

        return (borrow_cap_value, supply_cap_value)
    end
end
