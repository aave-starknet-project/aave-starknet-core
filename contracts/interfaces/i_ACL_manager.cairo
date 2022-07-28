%lang starknet

@contract_interface
namespace IACLManager:
    func is_pool_admin(admin : felt) -> (bool : felt):
    end

    func is_emergency_admin(admin : felt) -> (bool : felt):
    end

    func is_asset_listing_admin(admin : felt) -> (bool : felt):
    end

    func is_risk_admin(admin : felt) -> (bool : felt):
    end
end
