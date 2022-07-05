%lang starknet

from contracts.protocol.libraries.helpers.felt_packaging.bits_manipulation import (
    external as bits_manipulation,
)
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin

const LTV_BEGIN = 0
const LTV_SIZE = 16  # 0-15
const LIQ_THRESHOLD_BEGIN = LTV_BEGIN + LTV_SIZE
const LIQ_THRESHOLD_SIZE = 16  # 16-31
const LIQ_BONUS_BEGIN = LIQ_THRESHOLD_BEGIN + LIQ_THRESHOLD_SIZE
const LIQ_BONUS_SIZE = 16  # 32-47
const DECIMALS_BEGIN = LIQ_BONUS_BEGIN + LIQ_BONUS_SIZE
const DECIMALS_SIZE = 8  # 48-55

# Flags
const RESERVE_ACTIVE_BEGIN = DECIMALS_BEGIN + DECIMALS_SIZE
const RESERVE_ACTIVE_SIZE = 1  # 56-56
const RESERVE_FROZEN_BEGIN = RESERVE_ACTIVE_BEGIN + RESERVE_ACTIVE_SIZE
const RESERVE_FROZEN_SIZE = 1  # 57-57
const BORROWING_ENABLED_BEGIN = RESERVE_FROZEN_BEGIN + RESERVE_FROZEN_SIZE
const BORROWING_ENABLED_SIZE = 1  # 58-58
const STABLE_RATE_ENABLED_BEGIN = BORROWING_ENABLED_BEGIN + BORROWING_ENABLED_SIZE
const STABLE_RATE_ENABLED_SIZE = 1  # 59-59
const ASSET_PAUSED_BEGIN = STABLE_RATE_ENABLED_BEGIN + STABLE_RATE_ENABLED_SIZE
const ASSET_PAUSED_SIZE = 1  # 60-60
const ISOLATION_MODE_ENABLED_BEGIN = ASSET_PAUSED_BEGIN + ASSET_PAUSED_SIZE
const ISOLATION_MODE_ENABLED_SIZE = 1  # 61-61
const RESERVED_BIT_BEGIN = ISOLATION_MODE_ENABLED_BEGIN + ISOLATION_MODE_ENABLED_SIZE
const RESERVED_BIT_SIZE = 2  # 62-63

const RESERVE_FACTOR_BEGIN = RESERVED_BIT_BEGIN + RESERVED_BIT_SIZE
const RESERVE_FACTOR_SIZE = 16  # 64-79
const BORROW_CAP_BEGIN = RESERVE_FACTOR_BEGIN + RESERVE_FACTOR_SIZE
const BORROW_CAP_SIZE = 36  # 80-115
const SUPPLY_CAP_BEGIN = BORROW_CAP_BEGIN + BORROW_CAP_SIZE
const SUPPLY_CAP_SIZE = 36  # 116-151
const LIQUIDATION_PROTOCOL_FEE_BEGIN = SUPPLY_CAP_BEGIN + SUPPLY_CAP_SIZE
const LIQUIDATION_PROTOCOL_FEE_SIZE = 16  # 152-167
const EMODE_CATEGORY_BEGIN = LIQUIDATION_PROTOCOL_FEE_BEGIN + LIQUIDATION_PROTOCOL_FEE_SIZE
const EMODE_CATEGORY_SIZE = 8  # 168-175
const UNBACKED_MINT_CAP_BEGIN = EMODE_CATEGORY_BEGIN + EMODE_CATEGORY_SIZE
const UNBACKED_MINT_CAP_SIZE = 36  # 176-211
const DEBT_CEILING_CAP_BEGIN = UNBACKED_MINT_CAP_BEGIN + UNBACKED_MINT_CAP_SIZE
const DEBT_CEILING_CAP_SIZE = 40  # 212-251

@storage_var
func bitmap() -> (value : felt):
end

namespace ReserveConfigurationBitmask:
    const MAX_RESERVES_COUNT = 128

    func get_bitmap{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        bitwise_ptr : BitwiseBuiltin*,
        range_check_ptr,
    }() -> (value : felt):
        let (current_value) = bitmap.read()
        return (current_value)
    end

    func get_ltv{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        bitwise_ptr : BitwiseBuiltin*,
        range_check_ptr,
    }() -> (value : felt):
        let (bitmap_value) = bitmap.read()
        let (res) = bits_manipulation.actual_get_element_at(bitmap_value, LTV_BEGIN, LTV_SIZE)
        return (res)
    end

    func get_reserve_active{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        bitwise_ptr : BitwiseBuiltin*,
        range_check_ptr,
    }() -> (value : felt):
        let (bitmap_value) = bitmap.read()
        let (res) = bits_manipulation.actual_get_element_at(
            bitmap_value, RESERVE_ACTIVE_BEGIN, RESERVE_ACTIVE_SIZE
        )
        return (res)
    end

    func get_reserve_frozen{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        bitwise_ptr : BitwiseBuiltin*,
        range_check_ptr,
    }() -> (value : felt):
        let (bitmap_value) = bitmap.read()
        let (res) = bits_manipulation.actual_get_element_at(
            bitmap_value, RESERVE_FROZEN_BEGIN, RESERVE_FROZEN_SIZE
        )
        return (res)
    end

    func get_borrowing_enabled{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        bitwise_ptr : BitwiseBuiltin*,
        range_check_ptr,
    }() -> (value : felt):
        let (bitmap_value) = bitmap.read()
        let (res) = bits_manipulation.actual_get_element_at(
            bitmap_value, BORROWING_ENABLED_BEGIN, BORROWING_ENABLED_SIZE
        )
        return (res)
    end

    func get_stable_rate_enabled{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        bitwise_ptr : BitwiseBuiltin*,
        range_check_ptr,
    }() -> (value : felt):
        let (bitmap_value) = bitmap.read()
        let (res) = bits_manipulation.actual_get_element_at(
            bitmap_value, STABLE_RATE_ENABLED_BEGIN, STABLE_RATE_ENABLED_SIZE
        )
        return (res)
    end

    func get_asset_paused{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        bitwise_ptr : BitwiseBuiltin*,
        range_check_ptr,
    }() -> (value : felt):
        let (bitmap_value) = bitmap.read()
        let (res) = bits_manipulation.actual_get_element_at(
            bitmap_value, ASSET_PAUSED_BEGIN, ASSET_PAUSED_SIZE
        )
        return (res)
    end

    func set_ltv{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        bitwise_ptr : BitwiseBuiltin*,
        range_check_ptr,
    }(value : felt) -> ():
        let (current_value) = bitmap.read()
        let (new_value) = bits_manipulation.actual_set_element_at(
            current_value, LTV_BEGIN, LTV_SIZE, value
        )
        bitmap.write(new_value)
        return ()
    end

    func set_liquidation_threshold{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        bitwise_ptr : BitwiseBuiltin*,
        range_check_ptr,
    }(value : felt):
        let (current_value) = bitmap.read()
        let (new_value) = bits_manipulation.actual_set_element_at(
            current_value, LIQ_THRESHOLD_BEGIN, LIQ_THRESHOLD_SIZE, value
        )
        bitmap.write(new_value)
        return ()
    end

    func set_liquidation_bonus{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        bitwise_ptr : BitwiseBuiltin*,
        range_check_ptr,
    }(value : felt):
        let (current_value) = bitmap.read()
        let (new_value) = bits_manipulation.actual_set_element_at(
            current_value, LIQ_BONUS_BEGIN, LIQ_BONUS_SIZE, value
        )
        bitmap.write(new_value)
        return ()
    end

    func get_flags{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        bitwise_ptr : BitwiseBuiltin*,
        range_check_ptr,
    }() -> (
        reserve_active : felt,
        reserve_frozen : felt,
        borrowing_enabled : felt,
        stable_rate_enabled : felt,
        asset_paused : felt,
    ):
        alloc_locals
        let (local active) = get_reserve_active()
        let (frozen) = get_reserve_frozen()
        let (borrowing_enabled) = get_borrowing_enabled()
        let (stable_rate_enabled) = get_stable_rate_enabled()
        let (asset_paused) = get_asset_paused()

        return (active, frozen, borrowing_enabled, stable_rate_enabled, asset_paused)
    end
end

# total bits used: 4 + 8 + 20 + 16 + 8 + 8 = 64
