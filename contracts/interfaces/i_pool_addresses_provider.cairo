%lang starknet

@contract_interface
namespace IAddressesProvider:
    func get_market_id() -> (market_id : felt):
    end

    func set_market_id(market_id : felt):
    end

    func get_address(identifier : felt) -> (address : felt):
    end

    func set_address(identifier : felt, new_address : felt):
    end

    func get_pool() -> (pool : felt):
    end

    func set_pool_impl(new_implementation : felt):
    end

    func get_pool_configurator() -> (pool_configurator : felt):
    end

    func set_pool_configurator_impl(new_implementation : felt):
    end

    func get_price_oracle() -> (price_oracle : felt):
    end

    func set_price_oracle(new_address : felt):
    end

    func get_ACL_manager() -> (ACL_manager : felt):
    end

    func set_ACL_manager(new_address : felt):
    end

    func get_ACL_admin() -> (ACL_admin : felt):
    end

    func set_ACL_admin(new_address : felt):
    end

    func get_price_oracle_sentinel() -> (price_oracle_sentinel : felt):
    end

    func set_price_oracle_sentinel(new_address : felt):
    end

    func get_pool_data_provider() -> (get_pool_data_provider : felt):
    end

    func set_pool_data_provider(new_address : felt):
    end
end
