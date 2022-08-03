%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from contracts.misc.aave_oracle_library import AaveOracle

@contract_interface
namespace IAaveIncentivesController:
    func get_asset_data() -> (asset : felt):
    end

    func set_claimer(claimer : felt) -> ():
    end

    func get_claimer() -> (claimer : felt):
    end

    func configure_assets(
        assets_len : felt,
        assets : felt*,
        emissions_per_second_len : felt,
        emissions_per_second : felt*,
    ) -> ():
    end

    func handle_action(asset : felt, user_balance : felt, total_supply : felt) -> (rewards : felt):
    end

    func get_rewards_balance(assets_len : felt, assets : felt*, user : felt):
    end

    func claim_rewards(assets_len : felt, assets : felt*, amount : felt, to : felt) -> (
        rewards : felt
    ):
    end

    func claim_rewards_on_behalf(
        assets_len : felt, assets : felt*, amount : felt, user : felt, to : felt
    ) -> (rewards : felt):
    end

    func get_user_unclaimed_rewards(user : felt) -> (rewards : felt):
    end

    func get_user_asset_data(user : felt, asset : felt) -> (index : felt):
    end

    func REWARD_TOKEN() -> (address : felt):
    end

    func DISTRIBUTION_END() -> (address : felt):
    end
end
