%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256

from contracts.protocol.libraries.types.configurator_input_types import ConfiguratorInputTypes

@contract_interface
namespace IPoolConfigurator:
    func init_reserves(input_len : felt, input : ConfiguratorInputTypes.InitReserveInput*):
    end

    func update_a_token(input : ConfiguratorInputTypes.UpdateATokenInput):
    end

    func update_stable_debt_token(input : ConfiguratorInputTypes.UpdateDebtTokenInput):
    end

    func update_variable_debt_token(input : ConfiguratorInputTypes.UpdateDebtTokenInput):
    end

    func set_reserve_borrowing(asset : felt, enabled : felt):
    end

    func configure_reserve_as_collateral(
        asset : felt, ltv : Uint256, liquidation_threshold : Uint256, liquidation_bonus : Uint256
    ):
    end

    func set_reserve_stable_rate_borrowing(asset : felt, enabled : felt):
    end

    func set_reserve_active(asset : felt, active : felt):
    end

    func set_reserve_freeze(asset : felt, freeze : felt):
    end

    func set_borrowable_in_isolation(asset : felt, borrowable : felt):
    end

    func set_reserve_pause(asset : felt, paused : felt):
    end

    func set_reserve_factor(asset : felt, new_reserve_factor : Uint256):
    end

    func set_reserve_interest_rate_strategy_address(asset : felt, new_rate_strategy_address : felt):
    end

    func set_pool_pause(paused : felt):
    end

    func set_borrow_cap(asset : felt, new_borrow_cap : Uint256):
    end

    func set_supply_cap(asset : felt, new_supply_cap : Uint256):
    end

    func set_liquidation_protocol_fee(asset : felt, new_fee : Uint256):
    end

    func set_unbacked_mint_cap(asset : felt, new_unbacked_mint_cap : Uint256):
    end

    func set_asset_e_mode_category(asset : felt, new_category_id : felt):
    end

    func set_e_mode_category(
        category_id : felt,
        ltv : felt,
        liquidation_threshold : felt,
        liquidation_bonus : felt,
        oracle : felt,
        label : felt,
    ):
    end

    func drop_reserve(asset : felt):
    end

    func update_bridge_protocol_fee(new_bridge_protocol_fee : Uint256):
    end

    func update_flashloan_premium_total(new_flashloan_premium_total : felt):
    end

    func update_flashloan_premium_to_protocol(new_flashloan_premium_to_protocol : felt):
    end

    func set_debt_ceiling(asset : felt, new_debt_ceiling : Uint256):
    end

    func set_siloed_borrowing(asset : felt, siloed : felt):
    end
end
