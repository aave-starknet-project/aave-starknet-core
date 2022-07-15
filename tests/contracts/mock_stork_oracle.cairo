%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from contracts.dependencies.stork.data_types import PriceTick

# Required for deployed tests - but for now we can use mock_call from protostar.
# To be removed if deemed unnecessary

@storage_var
func StorkOracle_asset_ticker(asset : felt) -> (ticker : felt):
end

@storage_var
func StorkOracle_ticker_value(ticker : felt) -> (price_tick : PriceTick):
end

@external
func add_asset{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    asset : felt, ticker : felt
):
    StorkOracle_asset_ticker.write(asset, ticker)
    return ()
end

@view
func get_value{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ticker : felt
) -> (price_tick : PriceTick):
    let (price_tick) = StorkOracle_ticker_value.read(ticker)
    return (price_tick)
end
