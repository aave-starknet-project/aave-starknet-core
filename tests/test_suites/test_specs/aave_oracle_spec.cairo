%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero
from starkware.starknet.common.syscalls import get_contract_address

from contracts.interfaces.i_aave_oracle import IAaveOracle
from contracts.misc.aave_oracle_library import AaveOracle

from tests.utils.constants import USER_1

const MOCK_STORK_ORACLE = 1248760124
const MOCK_POOL_ADDRESSES_PROVIDER = 7698124
const MOCK_ACL_MANAGER = 78039852
const MOCK_ERC20 = 098798235
const ERC20_TICKER = 'ERC20/USD'
const ERC20_PRICE = 1000

func before_each{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    oracle_address : felt, erc20_address : felt
):
    let (contract_address) = get_contract_address()
    %{ store(ids.contract_address, "AaveOracle_oracle_address",[ids.MOCK_STORK_ORACLE]) %}
    %{ store(ids.contract_address, "AaveOracle_addresses_provider",[ids.MOCK_POOL_ADDRESSES_PROVIDER]) %}
    return (MOCK_STORK_ORACLE, MOCK_ERC20)
end

func mock_owner{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    %{
        stop_mock_1 = mock_call(ids.MOCK_POOL_ADDRESSES_PROVIDER,"get_ACL_manager",[ids.MOCK_ACL_MANAGER])
        stop_mock_2 = mock_call(ids.MOCK_ACL_MANAGER,"is_pool_admin",[1])
        stop_mock_3 = mock_call(ids.MOCK_ACL_MANAGER,"is_asset_listing_admin",[0])
    %}
    return ()
end

namespace TestAaveOracle:
    func test_owner_set_a_new_asset_source{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        let (contract_address) = get_contract_address()
        let (oracle_address, erc20_address) = before_each()
        mock_owner()
        local stored_address
        %{
            stored_address = load(ids.contract_address,"AaveOracle_oracle_address", "felt") 
            ids.stored_address = stored_address[0]
        %}
        assert stored_address = MOCK_STORK_ORACLE

        # Verify asset is not registered
        %{ stop_mock_get_value = mock_call(ids.MOCK_STORK_ORACLE, "get_value",[0,0,0,0,0]) %}
        let (prior_ticker) = AaveOracle.get_ticker_of_asset(erc20_address)
        let (prior_asset_price) = AaveOracle.get_asset_price(erc20_address)
        let (prior_assets_prices_len, prior_assets_prices) = AaveOracle.get_assets_prices(
            1, new (erc20_address)
        )
        assert prior_ticker = 0
        assert prior_asset_price = 0
        assert [prior_assets_prices] = 0
        %{ stop_mock_get_value() %}

        # Register asset ticker§
        %{ expect_events({"name":"AssetSourceUpdated","data":[ids.erc20_address,ids.ERC20_TICKER]}) %}
        AaveOracle.set_assets_tickers(1, new (erc20_address), 1, new (ERC20_TICKER))

        # Verify asset is registered and price is returned
        let (asset_ticker) = AaveOracle.get_ticker_of_asset(erc20_address)
        %{ stop_mock_get_value = mock_call(ids.MOCK_STORK_ORACLE, "get_value",[0,ids.ERC20_PRICE,0,0,0]) %}
        let (asset_price) = AaveOracle.get_asset_price(erc20_address)
        let (assets_prices_len, assets_prices) = AaveOracle.get_assets_prices(
            1, new (erc20_address)
        )
        assert asset_ticker = ERC20_TICKER
        assert asset_price = ERC20_PRICE
        assert [assets_prices] = ERC20_PRICE
        %{ stop_mock_get_value() %}

        return ()
    end

    func test_owner_updates_asset_source{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        let (oracle_address, erc20_address) = before_each()
        mock_owner()
        AaveOracle.set_assets_tickers(1, new (erc20_address), 1, new (ERC20_TICKER))

        # Asset is registered, update its ticker
        let (prior_ticker) = AaveOracle.get_ticker_of_asset(erc20_address)
        assert_not_zero(prior_ticker)
        %{ expect_events({"name":"AssetSourceUpdated","data":[ids.erc20_address,ids.ERC20_TICKER]}) %}
        AaveOracle.set_assets_tickers(1, new (erc20_address), 1, new (ERC20_TICKER))

        # Verify update
        %{ stop_mock_get_value = mock_call(ids.MOCK_STORK_ORACLE, "get_value",[0,ids.ERC20_PRICE,0,0,0]) %}
        let (asset_ticker) = AaveOracle.get_ticker_of_asset(erc20_address)
        let (asset_price) = AaveOracle.get_asset_price(erc20_address)
        assert asset_ticker = ERC20_TICKER
        assert asset_price = ERC20_PRICE
        %{ stop_mock_get_value() %}
        return ()
    end

    func test_owner_tries_to_set_new_asset_source_with_wrong_input_params{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        let (oracle_address, erc20_address) = before_each()
        mock_owner()
        %{ expect_revert(error_message="Array parameters that should be equal length are not") %}
        AaveOracle.set_assets_tickers(1, new (erc20_address), 0, new ())
        return ()
    end

    func test_get_price_of_BASE_CURRENCY_asset{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        let (oracle_address, erc20_address) = before_each()
        let (contract_address) = get_contract_address()
        %{ store(ids.contract_address, "AaveOracle_base_currency",[ids.erc20_address]) %}
        %{ store(ids.contract_address, "AaveOracle_base_currency_unit",[10]) %}
        let (base_currency) = AaveOracle.BASE_CURRENCY()
        let (base_currency_unit) = AaveOracle.BASE_CURRENCY_UNIT()
        # Check returns the fixed price BASE_CURRENCY_UNIT
        let (price) = AaveOracle.get_asset_price(base_currency)
        assert price = base_currency_unit
        return ()
    end

    func test_non_owner_sets_ticker{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        # TODO (depends on ACL Manager)
        alloc_locals
        let (oracle_address, erc20_address) = before_each()
        %{
            stop_mock_1 = mock_call(ids.MOCK_POOL_ADDRESSES_PROVIDER,"get_ACL_manager",[ids.MOCK_ACL_MANAGER])
            stop_mock_2 = mock_call(ids.MOCK_ACL_MANAGER,"is_pool_admin",[0])
            stop_mock_3 = mock_call(ids.MOCK_ACL_MANAGER,"is_asset_listing_admin",[0])
            expect_revert(error_message="The caller of the function is not an asset listing or pool admin")
        %}
        AaveOracle.set_assets_tickers(1, new (erc20_address), 0, new ())
        return ()
    end

    func test_get_price_of_BASE_CURRENCY_asset_with_registered_ticker{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        let (local oracle_address, local erc20_address) = before_each()
        let (local contract_address) = get_contract_address()
        mock_owner()
        # Add asset source for BASE_CURRENCY address
        AaveOracle.set_assets_tickers(1, new (erc20_address), 1, new (ERC20_TICKER))
        %{ store(ids.contract_address, "AaveOracle_base_currency",[ids.erc20_address]) %}
        %{ store(ids.contract_address, "AaveOracle_base_currency_unit",[10]) %}
        let (base_currency) = AaveOracle.BASE_CURRENCY()
        # Check returns the fixed price BASE_CURRENCY_UNIT
        let (base_currency_unit) = AaveOracle.BASE_CURRENCY_UNIT()
        let (price) = AaveOracle.get_asset_price(base_currency)
        assert price = base_currency_unit
        return ()
    end

    func test_get_price_of_asset_with_no_ticker{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        let (oracle_address, erc20_address) = before_each()
        let (asset_ticker) = AaveOracle.get_ticker_of_asset(erc20_address)
        assert asset_ticker = 0
        let (price) = AaveOracle.get_asset_price(erc20_address)
        assert price = 0
        return ()
    end

    # Rest of the tests involve a fallback oracle so not implemented
end
