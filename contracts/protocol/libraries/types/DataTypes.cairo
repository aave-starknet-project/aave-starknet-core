%lang starknet

namespace DataTypes:
    struct ReserveData:
        member id : felt
        member aToken_address : felt
        member liquidity_index : felt
        # TODO add the rest of the fields
    end

    struct InitReserveParams:
        member asset : felt
        member aToken_address : felt
        member reserves_count : felt
        member max_number_reserves : felt
        # TODO add the rest of the fields
    end
end
