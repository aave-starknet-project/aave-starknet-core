from starkware.cairo.common.uint256 import Uint256

namespace DataTypes:
    struct ReserveData:
        member id : felt
        member a_token_address : felt
        member liquidity_index : felt
        # TODO add the rest of the fields
    end

    struct InitReserveParams:
        member asset : felt
        member a_token_address : felt
        member reserves_count : felt
        member max_number_reserves : felt
        # TODO add the rest of the fields
    end

    struct UserConfigurationMap:
        member data : Uint256
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
end
