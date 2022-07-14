%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math_cmp import is_nn
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.bool import TRUE
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math import split_felt
from contracts.dependencies.stork.i_oracle_proxy import IOracleProxy
from contracts.interfaces.i_pool_addresses_provider import IPoolAddressesProvider
from contracts.protocol.libraries.helpers.bool_cmp import BoolCompare
from contracts.protocol.libraries.helpers.helpers import is_zero

@storage_var
func AaveOracle_addresses_provider() -> (addresses_provider : felt):
end

@storage_var
func AaveOracle_asset_tickers(asset : felt) -> (ticker : felt):
end

@storage_var
func AaveOracle_oracle_address() -> (oracle_address : felt):
end

@storage_var
func AaveOracle_fallback_oracle() -> (fallback_oracle : felt):
end

@storage_var
func AaveOracle_base_currency() -> (base_currency : felt):
end

@storage_var
func AaveOracle_base_currency_unit() -> (base_currency_unit : felt):
end

# @dev Emitted after the base currency is set
# @param base_currency The base currency of used for price quotes
# @param base_currency_unit The unit of the base currency
@event
func BaseCurrencySet(base_currency : felt, base_currency_unit : felt):
end

# @dev Emitted after the ticker of an asset is updated
# @param asset The address of the asset
# @param ticker The price ticker of the asset
@event
func AssetSourceUpdated(asset : felt, ticker : felt):
end

# @dev Emitted after the address of fallback oracle is updated
# @param fallback_oracle The address of the fallback oracle
@event
func FallbackOracleUpdated(fallback_oracle : felt):
end

func assert_only_asset_listing_or_pool_admin{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    # let (pool_addresses_provider) = AaveOracle_addresses_provider.read()
    # let (ACL_manager_address) = IPoolAddressesProvider.get_ACL_manager(pool_addresses_provider)
    # let (caller) = get_caller_address()
    # let (is_asset_listing_admin) = IACLManager.is_asset_listing_admin(caller)
    # let (is_pool_admin) = IACLManager.is_pool_admin(caller)
    # let (either) = BoolCompare.either(is_asset_listing_admin, is_pool_admin)
    # with_attr error_message("The caller of the function is not an asset listing or pool admin"):
    #     assert either = TRUE
    # end
    return ()
end

namespace AaveOracle:
    # @notice Initializer
    # @param provider The address of the new PoolAddressesProvider
    # @param oracle_address The address of the oracle
    # @param assets_len Length of the assets array
    # @param assets The addresses of the assets
    # @param tickers_len Length of the tickers array
    # @param tickers The tickers of each asset
    # @param fallback_oracle The address of the fallback oracle to use if the data of an
    #        aggregator is not consistent
    # @param base_currency The base currency used for the price quotes. If USD is used, base currency is 0
    # @param base_currency_unit The unit of the base currency
    func initializer{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
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
        AaveOracle_addresses_provider.write(provider)
        AaveOracle_oracle_address.write(oracle_address)
        AaveOracle_base_currency.write(base_currency)
        AaveOracle_base_currency_unit.write(base_currency_unit)
        _set_assets_tickers(assets_len, assets, tickers_len, tickers)
        BaseCurrencySet.emit(base_currency, base_currency_unit)
        return ()
    end

    # @notice Returns the PoolAddressesProvider
    # @return The address of the PoolAddressesProvider contract
    func ADDRESSES_PROVIDER{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ) -> (provider : felt):
        let (pool_addresses_provider) = AaveOracle_addresses_provider.read()
        return (pool_addresses_provider)
    end

    # @notice Sets or replaces price tickers of assets
    # @param assets The addresses of the assets
    # @param tickers The addresses of the price tickers
    func set_assets_tickers{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        assets_len : felt, assets : felt*, tickers_len : felt, tickers : felt*
    ):
        assert_only_asset_listing_or_pool_admin()
        _set_assets_tickers(assets_len, assets, tickers_len, tickers)
        return ()
    end

    # @notice Sets the fallback oracle
    # @param fallback_oracle The address of the fallback oracle
    func set_fallback_oracle{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        fallback_oracle : felt
    ):
        assert_only_asset_listing_or_pool_admin()
        _set_fallback_oracle(fallback_oracle)
        return ()
    end

    # @notice Returns the asset price in the base currency
    # @param asset The address of the asset
    # @return The price of the asset
    func get_asset_price{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        asset : felt
    ) -> (price : felt):
        let (ticker) = AaveOracle_asset_tickers.read(asset)
        let (base_currency) = AaveOracle_base_currency.read()
        let (base_currency_unit) = AaveOracle_base_currency_unit.read()

        if asset == base_currency:
            return (base_currency_unit)
        end

        if ticker == 0:
            # TODO rely on fallback oracle
            with_attr error_message("No price ticker for asset"):
                assert 1 = 0
            end
            return (0)
        else:
            return _read_price_from_oracle(ticker)
        end
    end

    # @notice Returns a list of prices from a list of assets addresses
    # @param assets The list of assets addresses
    # @return The prices of the given assets
    func get_assets_prices{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        assets_len : felt, assets : felt*
    ) -> (prices_len : felt, prices : felt*):
        alloc_locals
        let (local prices : felt*) = alloc()
        let (prices_len) = _get_assets_prices(assets_len, assets, 0, prices)
        return (prices_len, prices)
    end

    # @notice Returns the address of the ticker for an asset address
    # @param asset The address of the asset
    # @return The ticker of the ticker
    func get_ticker_of_asset{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        asset : felt
    ) -> (ticker : felt):
        let (ticker) = AaveOracle_asset_tickers.read(asset)
        return (ticker)
    end

    # @notice Returns the address of the fallback oracle
    # @return The address of the fallback oracle
    func get_fallback_oracle{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}()->(fallback_oracle : felt):
        let (fallback_oracle) = AaveOracle_fallback_oracle.read()
        return (fallback_oracle)
    end
end

# @notice Internal function to set the tickers for each asset
# @param assets_len Length of the assets array
# @param assets The addresses of the assets
# @param tickers_len Length of the tickers array
# @param tickers The address of the ticker of each asset
func _set_assets_tickers{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    assets_len : felt, assets : felt*, tickers_len : felt, tickers : felt*
):
    with_attr error_message("Array parameters that should be equal length are not"):
        assert assets_len = tickers_len
    end
    if assets_len == 0:
        return ()
    end

    AaveOracle_asset_tickers.write([assets], [tickers])
    AssetSourceUpdated.emit([assets], [tickers])
    return _set_assets_tickers(assets_len - 1, assets + 1, tickers_len - 1, tickers + 1)
end

# @notice Internal function to set the fallback oracle
# @param fallback_oracle The address of the fallback oracle
func _set_fallback_oracle{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    fallback_oracle : felt
):
    AaveOracle_fallback_oracle.write(fallback_oracle)
    FallbackOracleUpdated.emit(fallback_oracle)
    return ()
end

func _get_assets_prices{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    assets_len : felt, assets : felt*, prices_len : felt, prices : felt*
) -> (prices_len : felt):
    if assets_len == 0:
        return (prices_len)
    end
    let (asset_price) = AaveOracle.get_asset_price([assets])
    assert [prices] = asset_price
    return _get_assets_prices(assets_len - 1, assets + 1, prices_len + 1, prices + 1)
end

# @notice Internal function to read an asset price from the oracle.
# @param ticker The ticker of the asset
func _read_price_from_oracle{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ticker
) -> (price : felt):
    alloc_locals
    let (oracle_address) = AaveOracle_oracle_address.read()
    let (price_tick) = IOracleProxy.get_value(oracle_address, ticker)
    local price = price_tick.value
    let (price_above_zero) = is_nn(price)
    let (price_is_zero) = is_zero(price)
    let (either) = BoolCompare.either(price_above_zero, price_is_zero)
    if either == TRUE:
        return (price)
    else:
        # TODO fallback oracle
        assert 1 = 0
        return (0)
    end
end
