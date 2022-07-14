%lang starknet

from contracts.dependencies.stork.data_types import PriceTick, PriceAggregate

@contract_interface
namespace IOracleProxy:
    func submit_multiple(prices_len : felt, prices : PriceTick*):
    end

    func submit_single(price : PriceTick):
    end

    func submit_multiple_aggregate(publisher : felt, prices_len : felt, prices : PriceAggregate*):
    end

    func submit_single_aggregate(publisher : felt, price : PriceTick):
    end

    func add_asset(asset_name : felt):
    end

    func update_implementation(new_address : felt):
    end

    func update_publisher_proxy(new_address : felt):
    end

    func get_value(asset : felt) -> (price : PriceTick):
    end

    func get_publisher_value(asset : felt, publisher : felt) -> (price : PriceTick):
    end

    func get_values(asset : felt) -> (prices_len : felt, prices : PriceTick*):
    end

    func get_price_bundle(asset : felt) -> (price : PriceAggregate):
    end

    func get_caller() -> (caller : felt):
    end

    func get_owner() -> (caller : felt):
    end
end
