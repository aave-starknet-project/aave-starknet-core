from starkware.cairo.common.uint256 import Uint256

namespace DataTypes:
    struct ReserveData:
        member id : felt
        member a_token_address : felt
        member liquidity_index : felt
        # TODO add the rest of the fields
    end

    struct ReserveConfigurationMap:
        member ltv : felt
        member liquidation_threshold : felt
        member liquidation_bonus : felt
        member decimals : felt
        member reserve_active : felt
        member reserve_frozen : felt
        member borrowing_enabled : felt
        member stable_rate_borrowing_enabled : felt
        member asset_paused : felt
        member borrowable_in_isolation : felt
        member siloed_borrowing : felt
        member reserve_factor : felt
        member borrow_cap : felt
        member supply_cap : felt
        member liquidation_protocol_fee : felt
        member eMode_category : felt
        member unbacked_mint_cap : felt
        member debt_ceiling : felt
    end

    struct InitReserveParams:
        member asset : felt
        member a_token_address : felt
        member reserves_count : felt
        member max_number_reserves : felt
        # TODO add the rest of the fields
    end

    struct UserConfigurationMap:
        member borrowing : felt
        member using_as_collateral : felt
    end

    struct ExecuteSupplyParams:
        member asset : felt
        member amount : Uint256
        member on_behalf_of : felt
        member referral_code : felt
    end

    struct ExecuteWithdrawParams:
        member asset : felt
        member amount : Uint256
        member to : felt
        member reserves_count : felt
        # TODO add the rest of the fields
        # member oracle : felt
        # member user_eMode_category : felt
    end

    # @dev UserState - additionalData is a flexible field.
    # ATokens and VariableDebtTokens use this field store the index of the user's last supply/withdrawal/borrow/repayment.
    # StableDebtTokens use this field to store the user's stable rate.
    struct UserState:
        member balance : felt
        member additional_data : felt
    end
end
