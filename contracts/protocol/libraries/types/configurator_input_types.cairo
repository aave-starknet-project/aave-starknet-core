%lang starknet

namespace ConfiguratorInputTypes:
    struct InitReserveInput:
        member a_token_impl : felt
        member stable_debt_token_impl : felt
        member variable_debt_token_impl : felt
        member underlying_asset_decimals : felt
        member interest_rate_strategy_address : felt
        member underlying_asset : felt
        member treasury : felt
        member incentives_controller : felt
        member a_token_name : felt
        member a_token_symbol : felt
        member variable_debt_token_name : felt
        member variable_debt_token_symbol : felt
        member stable_debt_token_name : felt
        member stable_debt_token_symbol : felt
        member params : felt
        member proxy_class_hash : felt
        member salt : felt
    end

    struct UpdateATokenInput:
        member asset : felt
        member treasury : felt
        member incentives_controller : felt
        member name : felt
        member symbol : felt
        member implementation : felt
        member params : felt
    end

    struct UpdateDebtTokenInput:
        member asset : felt
        member incentives_controller : felt
        member name : felt
        member symbol : felt
        member implementation : felt
        member params : felt
    end
end
