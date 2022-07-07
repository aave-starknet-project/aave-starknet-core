%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_le

from contracts.protocol.libraries.helpers.bool_cmp import BoolCompare

@storage_var
func ltv(reserve_asset : felt) -> (value : felt):
end

@storage_var
func liquidation_threshold(reserve_asset : felt) -> (value : felt):
end

@storage_var
func liquidation_bonus(reserve_asset : felt) -> (value : felt):
end

@storage_var
func decimals(reserve_asset : felt) -> (value : felt):
end

@storage_var
func reserve_active(reserve_asset : felt) -> (boolean : felt):
end

@storage_var
func reserve_frozen(reserve_asset : felt) -> (boolean : felt):
end

@storage_var
func borrowing_enabled(reserve_asset : felt) -> (boolean : felt):
end

@storage_var
func stable_rate_borrowing_enabled(reserve_asset : felt) -> (boolean : felt):
end

@storage_var
func asset_paused(reserve_asset : felt) -> (boolean : felt):
end

@storage_var
func borrowable_in_isolation(reserve_asset : felt) -> (boolean : felt):
end

@storage_var
func siloed_borrowing(reserve_asset : felt) -> (boolean : felt):
end

@storage_var
func reserve_factor(reserve_asset : felt) -> (boolean : felt):
end

@storage_var
func borrow_cap(reserve_asset : felt) -> (value : felt):
end

@storage_var
func supply_cap(reserve_asset : felt) -> (value : felt):
end

@storage_var
func liquidation_protocol_fee(reserve_asset : felt) -> (value : felt):
end

@storage_var
func eMode_category(reserve_asset : felt) -> (value : felt):
end

@storage_var
func unbacked_mint_cap(reserve_asset : felt) -> (value : felt):
end

@storage_var
func debt_ceiling(reserve_asset : felt) -> (value : felt):
end

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
    # @param value The new ltv
    func set_ltv{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt, value : felt
    ):
        with_attr error_message("Invalid ltv parameter for the reserve"):
            assert_le(value, MAX_VALID_LTV)
        end
        ltv.write(reserve_asset, value)
        return ()
    end

    # @notice Gets the Loan to Value of the reserve
    # @return The loan to value
    func get_ltv{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt
    ) -> (value : felt):
        let (res) = ltv.read(reserve_asset)
        return (res)
    end

    # @notice Sets the liquidation threshold of the reserve
    # @param value The new liquidation threshold
    func set_liquidation_threshold{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(reserve_asset : felt, value : felt):
        with_attr error_message("Invalid liquidity threshold parameter for the reserve"):
            assert_le(value, MAX_VALID_LIQUIDATION_THRESHOLD)
        end
        liquidation_threshold.write(reserve_asset, value)
        return ()
    end

    # @notice Gets the liquidation threshold of the reserve
    # @return The liquidation threshold
    func get_liquidation_threshold{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(reserve_asset : felt) -> (value : felt):
        let (res) = liquidation_threshold.read(reserve_asset)
        return (res)
    end

    # @notice Sets the liquidation bonus of the reserve
    # @param value The new liquidation bonus
    func set_liquidation_bonus{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt, value : felt
    ):
        with_attr error_message("Invalid liquidity bonus parameter for the reserve"):
            assert_le(value, MAX_VALID_LIQUIDATION_BONUS)
        end
        liquidation_bonus.write(reserve_asset, value)
        return ()
    end

    # @notice Gets the liquidation bonus of the reserve
    # @return The liquidation bonus
    func get_liquidation_bonus{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt
    ) -> (value : felt):
        let (res) = liquidation_bonus.read(reserve_asset)
        return (res)
    end

    # @notice Sets the decimals of the underlying asset of the reserve
    # @param value The decimals
    func set_decimals{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt, value : felt
    ):
        with_attr error_message(
                "Invalid decimals parameter of the underlying asset of the reserve"):
            assert_le(value, MAX_VALID_DECIMALS)
        end
        decimals.write(reserve_asset, value)
        return ()
    end

    # @notice Gets the decimals of the underlying asset of the reserve
    # @return The decimals of the asset
    func get_decimals{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt
    ) -> (value : felt):
        let (res) = decimals.read(reserve_asset)
        return (res)
    end

    # @notice Sets the active state of the reserve
    # @param active The active state
    func set_active{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt, active : felt
    ):
        BoolCompare.is_valid(active)
        reserve_active.write(reserve_asset, active)
        return ()
    end

    # @notice Gets the active state of the reserve
    # @return The active state
    func get_active{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt
    ) -> (value : felt):
        let (res) = reserve_active.read(reserve_asset)
        return (res)
    end

    # @notice Sets the frozen state of the reserve
    # @param frozen The frozen state
    func set_frozen{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt, frozen : felt
    ):
        BoolCompare.is_valid(frozen)
        reserve_frozen.write(reserve_asset, frozen)
        return ()
    end

    # @notice Gets the frozen state of the reserve
    # @return The frozen state
    func get_frozen{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt
    ) -> (value : felt):
        let (res) = reserve_frozen.read(reserve_asset)
        return (res)
    end

    # @notice Sets the paused state of the reserve
    # @param value The paused state
    func set_paused{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt, paused : felt
    ):
        BoolCompare.is_valid(paused)
        asset_paused.write(reserve_asset, paused)
        return ()
    end

    # @notice Gets the paused state of the reserve
    # @return The paused state
    func get_paused{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt
    ) -> (value : felt):
        let (res) = asset_paused.read(reserve_asset)
        return (res)
    end

    # @notice Sets the borrowable in isolation flag for the reserve.
    # @dev When this flag is set to true, the asset will be borrowable against isolated collaterals and the borrowed
    # amount will be accumulated in the isolated collateral's total debt exposure.
    # @dev Only assets of the same family (eg USD stablecoins) should be borrowable in isolation mode to keep
    # consistency in the debt ceiling calculations.
    # @param borrowable True if the asset is borrowable
    func set_borrowable_in_isolation{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(reserve_asset : felt, borrowable : felt):
        BoolCompare.is_valid(borrowable)
        borrowable_in_isolation.write(reserve_asset, borrowable)
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
        let (res) = borrowable_in_isolation.read(reserve_asset)
        return (res)
    end

    # @notice Sets the siloed borrowing flag for the reserve.
    # @dev When this flag is set to true, users borrowing this asset will not be allowed to borrow any other asset.
    # @param siloed True if the asset is siloed
    func set_siloed_borrowing{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt, siloed : felt
    ):
        BoolCompare.is_valid(siloed)
        siloed_borrowing.write(reserve_asset, siloed)
        return ()
    end

    # @notice Gets the siloed borrowing flag for the reserve.
    # @dev When this flag is set to true, users borrowing this asset will not be allowed to borrow any other asset.
    # @return The siloed borrowing flag
    func get_siloed_borrowing{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt
    ) -> (value : felt):
        let (res) = siloed_borrowing.read(reserve_asset)
        return (res)
    end

    # @notice Enables or disables borrowing on the reserve
    # @param enabled True if the borrowing needs to be enabled, false otherwise
    func set_borrowing_enabled{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt, enabled : felt
    ):
        BoolCompare.is_valid(enabled)
        borrowing_enabled.write(reserve_asset, enabled)
        return ()
    end

    # @notice Gets the borrowing state of the reserve
    # @return The borrowing state
    func get_borrowing_enabled{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt
    ) -> (value : felt):
        let (res) = borrowing_enabled.read(reserve_asset)
        return (res)
    end

    # @notice Enables or disables stable rate borrowing on the reserve
    # @param enabled True if the stable rate borrowing needs to be enabled, false otherwise
    func set_stable_rate_borrowing_enabled{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(reserve_asset : felt, enabled : felt):
        BoolCompare.is_valid(enabled)
        stable_rate_borrowing_enabled.write(reserve_asset, enabled)
        return ()
    end

    # @notice Gets the stable rate borrowing state of the reserve
    # @return The stable rate borrowing state
    func get_stable_rate_borrowing_enabled{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(reserve_asset : felt) -> (value : felt):
        let (res) = stable_rate_borrowing_enabled.read(reserve_asset)
        return (res)
    end

    # @notice Sets the reserve factor of the reserve
    # @param reserveFactor The reserve factor
    func set_reserve_factor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt, value : felt
    ):
        with_attr error_message("Invalid reserve factor parameter for the reserve"):
            assert_le(value, MAX_VALID_RESERVE_FACTOR)
        end
        reserve_factor.write(reserve_asset, value)
        return ()
    end

    # @notice Gets the reserve factor of the reserve
    # @return The reserve factor
    func get_reserve_factor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt
    ) -> (value : felt):
        let (res) = reserve_factor.read(reserve_asset)
        return (res)
    end

    # @notice Sets the borrow cap of the reserve
    # @param borrowCap The borrow cap

    func set_borrow_cap{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt, value : felt
    ):
        with_attr error_message("Invalid borrow cap for the reserve"):
            assert_le(value, MAX_VALID_BORROW_CAP)
        end
        borrow_cap.write(reserve_asset, value)
        return ()
    end

    # @notice Gets the borrow cap of the reserve
    # @return The borrow cap

    func get_borrow_cap{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt
    ) -> (value : felt):
        let (res) = borrow_cap.read(reserve_asset)
        return (res)
    end

    # @notice Sets the supply cap of the reserve
    # @param supplyCap The supply cap

    func set_supply_cap{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt, value : felt
    ):
        with_attr error_message("Invalid supply cap for the reserve"):
            assert_le(value, MAX_VALID_SUPPLY_CAP)
        end
        supply_cap.write(reserve_asset, value)
        return ()
    end

    # @notice Gets the supply cap of the reserve
    # @return The supply cap

    func get_supply_cap{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt
    ) -> (value : felt):
        let (res) = supply_cap.read(reserve_asset)
        return (res)
    end

    # @notice Sets the debt ceiling in isolation mode for the asset
    # @param ceiling The maximum debt ceiling for the asset
    func set_debt_ceiling{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt, ceiling : felt
    ):
        with_attr error_message("Invalid debt ceiling for the reserve"):
            assert_le(ceiling, MAX_VALID_DEBT_CEILING)
        end
        debt_ceiling.write(reserve_asset, ceiling)
        return ()
    end

    # @notice Gets the debt ceiling for the asset if the asset is in isolation mode
    # @return The debt ceiling (0 = isolation mode disabled)
    func get_debt_ceiling{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt
    ) -> (value : felt):
        let (res) = debt_ceiling.read(reserve_asset)
        return (res)
    end

    # @notice Sets the liquidation protocol fee of the reserve
    # @param value The liquidation protocol fee
    func set_liquidation_protocol_fee{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(reserve_asset : felt, value : felt):
        with_attr error_message("Invalid liquidation protocol fee for the reserve"):
            assert_le(value, MAX_VALID_LIQUIDATION_PROTOCOL_FEE)
        end
        liquidation_protocol_fee.write(reserve_asset, value)
        return ()
    end

    # @dev Gets the liquidation protocol fee
    # @return The liquidation protocol fee
    func get_liquidation_protocol_fee{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(reserve_asset : felt) -> (value : felt):
        let (res) = liquidation_protocol_fee.read(reserve_asset)
        return (res)
    end

    # @notice Sets the unbacked mint cap of the reserve
    # @param value The unbacked mint cap
    func set_unbacked_mint_cap{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt, value : felt
    ):
        with_attr error_message("Invalid unbacked mint cap for the reserve"):
            assert_le(value, MAX_VALID_UNBACKED_MINT_CAP)
        end
        unbacked_mint_cap.write(reserve_asset, value)
        return ()
    end

    # @dev Gets the unbacked mint cap of the reserve
    # @return The unbacked mint cap
    func get_unbacked_mint_cap{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt
    ) -> (value : felt):
        let (res) = unbacked_mint_cap.read(reserve_asset)
        return (res)
    end

    # @notice Sets the eMode asset category
    # @param category The asset category when the user selects the eMode
    func set_eMode_category{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt, category : felt
    ):
        with_attr error_message("Invalid eMode category for the reserve"):
            assert_le(category, MAX_VALID_EMODE_CATEGORY)
        end
        eMode_category.write(reserve_asset, category)
        return ()
    end

    # @dev Gets the eMode asset category
    # @return The eMode category for the asset
    func get_eMode_category{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_asset : felt
    ) -> (value : felt):
        let (res) = eMode_category.read(reserve_asset)
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
        let (is_active) = reserve_active.read(reserve_asset)
        let (is_frozen) = reserve_frozen.read(reserve_asset)
        let (is_borrowing_enabled) = borrowing_enabled.read(reserve_asset)
        let (is_stable_rate_borrowing_enabled) = stable_rate_borrowing_enabled.read(reserve_asset)
        let (is_paused) = asset_paused.read(reserve_asset)

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
        let (ltv_value) = ltv.read(reserve_asset)
        let (liquidation_threshold_value) = liquidation_threshold.read(reserve_asset)
        let (liquidation_bonus_value) = liquidation_bonus.read(reserve_asset)
        let (decimals_value) = decimals.read(reserve_asset)
        let (reserve_factor_value) = reserve_factor.read(reserve_asset)
        let (eMode_category_value) = eMode_category.read(reserve_asset)
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
        let (borrow_cap_value) = borrow_cap.read(reserve_asset)
        let (supply_cap_value) = supply_cap.read(reserve_asset)
        return (borrow_cap_value, supply_cap_value)
    end
end
