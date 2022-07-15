%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from contracts.misc.aave_oracle_library import AaveOracle
@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    provider : felt,
    oracle_address : felt,
    assets_len : felt,
    assets : felt*,
    tickers_len : felt,
    tickers : felt*,
    fallback_oracle : felt,
    base_currency : felt,
    base_currency_unit : felt,
):
    AaveOracle.initializer(
        provider,
        oracle_address,
        assets_len,
        assets,
        tickers_len,
        tickers,
        fallback_oracle,
        base_currency,
        base_currency_unit,
    )
    return ()
end

@view
func ADDRESSES_PROVIDER{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    provider : felt
):
    return AaveOracle.ADDRESSES_PROVIDER()
end

@view
func BASE_CURRENCY{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    base_currency : felt
):
    return AaveOracle.BASE_CURRENCY()
end

@view
func BASE_CURRENCY_UNIT{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    base_currency_unit : felt
):
    return AaveOracle.BASE_CURRENCY_UNIT()
end

@external
func set_assets_tickers{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    assets_len : felt, assets : felt*, tickers_len : felt, tickers : felt*
):
    AaveOracle.set_assets_tickers(assets_len, assets, tickers_len, tickers)
    return ()
end

@external
func set_fallback_oracle{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    fallback_oracle : felt
):
    AaveOracle.set_fallback_oracle(fallback_oracle)
    return ()
end

@view
func get_asset_price{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    asset : felt
) -> (price : felt):
    return AaveOracle.get_asset_price(asset)
end

@view
func get_assets_prices{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    assets_len : felt, assets : felt*
) -> (prices_len : felt, prices : felt*):
    return AaveOracle.get_assets_prices(assets_len, assets)
end

@view
func get_ticker_of_asset{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    asset : felt
) -> (ticker : felt):
    return AaveOracle.get_ticker_of_asset(asset)
end

@view
func get_fallback_oracle{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    fallback_oracle : felt
):
    return AaveOracle.get_fallback_oracle()
end
