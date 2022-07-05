%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin

@storage_var
func ltv() -> (value : felt):
end

@storage_var
func liquidation_threshold() -> (value : felt):
end

@storage_var
func liquidation_bonus() -> (value : felt):
end

@storage_var
func decimals() -> (value : felt):
end

@storage_var
func reserve_active() -> (boolean : felt):
end

@storage_var
func reserve_frozen() -> (boolean : felt):
end

@storage_var
func borrowing_enabled() -> (boolean : felt):
end

@storage_var
func stable_rate_enabled() -> (boolean : felt):
end

@storage_var
func asset_paused() -> (boolean : felt):
end

@storage_var
func isolation_mode_enabled() -> (boolean : felt):
end

# @storage_var
# func reserved()->(value:felt):
# end

@storage_var
func reserve_factor() -> (boolean : felt):
end

@storage_var
func borrow_cap() -> (value : felt):
end

@storage_var
func supply_cap() -> (value : felt):
end

@storage_var
func liquidation_protocol_fee() -> (value : felt):
end

@storage_var
func eMode_category() -> (value : felt):
end

@storage_var
func unbacked_mint_cap() -> (value : felt):
end

@storage_var
func debt_ceiling_cap() -> (value : felt):
end

namespace ReserveConfiguration:
    const MAX_RESERVES_COUNT = 128

    func set_ltv{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(value : felt):
        ltv.write(value)
        return ()
    end

    func set_liquidation_threshold{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(value : felt):
        liquidation_threshold.write(value)
        return ()
    end

    func set_liquidation_bonus{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        value : felt
    ):
        liquidation_bonus.write(value)
        return ()
    end

    func get_ltv{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        value : felt
    ):
        let (res) = ltv.read()
        return (res)
    end

    func get_flags{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        reserve_active : felt,
        reserve_frozen : felt,
        borrowing_enabled : felt,
        stable_rate_enabled : felt,
        asset_paused : felt,
    ):
        let (active) = reserve_active.read()
        let (frozen) = reserve_frozen.read()
        let (b_enabled) = borrowing_enabled.read()
        let (s_rate_enabled) = stable_rate_enabled.read()
        let (a_paused) = asset_paused.read()

        return (active, frozen, b_enabled, s_rate_enabled, a_paused)
    end
end
