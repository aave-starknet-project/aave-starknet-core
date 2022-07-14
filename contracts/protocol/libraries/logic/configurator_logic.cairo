%lang starknet

from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import deploy, get_contract_address

from contracts.interfaces.i_pool import IPool
from contracts.protocol.libraries.helpers.bool_cmp import BoolCompare
from contracts.protocol.libraries.logic.reserve_logic import ReserveLogic
from contracts.protocol.libraries.logic.validation_logic import ValidationLogic
from contracts.protocol.libraries.types.configurator_input_types import ConfiguratorInputTypes
from contracts.protocol.libraries.types.data_types import DataTypes

#
# Struct
#

struct ProxyInitParams:
    member selector : felt
    member pool : felt
    member treasury : felt
    member underlying_asset : felt
    member incentives_controller : felt
    member underlying_asset_decimals : felt
    member token_name : felt
    member token_symbol : felt
    member params : felt
    member proxy_class_hash : felt
    member salt : felt
end

struct ProxyCallParams:
    member selector : felt
    member pool : felt
    member underlying_asset : felt
    member incentives_controller : felt
    member underlying_asset_decimals : felt
    member token_name : felt
    member token_symbol : felt
    member params : felt
end

#
# Events
#

@event
func ReserveInitialized(
    asset : felt,
    a_token : felt,
    stable_debt_token : felt,
    variable_debt_token : felt,
    interest_rate_strategy_address : felt,
):
end

@event
func ATokenUpgraded(asset : felt, proxy : felt, implementation : felt):
end

@event
func StableDebtTokenUpgraded(asset : felt, proxy : felt, implementation : felt):
end

@event
func VariableDebtTokenUpgraded(asset : felt, proxy : felt, implementation : felt):
end

#
# Namespace
#

namespace ConfiguratorLogic:
    func execute_init_reserve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        pool : felt, input : ConfiguratorInputTypes.InitReserveInput
    ):
        let (selector) = 111

        let (a_token_proxy_address) = _init_token_with_proxy(
            input.a_token_impl,
            ProxyInitParams(selector, pool, input.treasury, input.underlying_asset, input.incentives_controller, input.underlying_asset_decimals, input.a_token_name, input.a_token_symbol, input.params, input.proxy_class_hash, input.salt),
        )

        let (stable_debt_token_proxy_address) = _init_token_with_proxy(
            input.stable_debt_token_impl,
            ProxyInitParams(selector, pool, input.treasury, input.underlying_asset, input.incentives_controller, input.underlying_asset_decimals, input.a_token_name, input.a_token_symbol, input.params, input.proxy_class_hash, input.salt),
        )

        let (variable_debt_token_proxy_address) = _init_token_with_proxy(
            input.variable_debt_token_impl,
            ProxyInitParams(selector, pool, input.treasury, input.underlying_asset, input.incentives_controller, input.underlying_asset_decimals, input.variable_debt_token_name, input.variable_debt_token_symbol, input.params, input.proxy_class_hash, input.salt),
        )

        # IPool.init_reserve(pool, input.underlying_asset, a_token_proxy_address, stable_debt_token_proxy_address, variable_debt_token_proxy_address, input.interest_rate_strategy)
        IPool.init_reserve(
            pool,
            input.underlying_asset,
            a_token_proxy_address,
            stable_debt_token_proxy_address,
            variable_debt_token_proxy_address,
        )

        let (config) = DataTypes.ReserveConfigurationMap(
            0, 0, 0, input.underlying_asset_decimals, TRUE, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        )

        IPool.set_configuration(pool, input.underlying_asset, config)

        ReserveInitialized.emit(
            input.underlying_asset,
            a_token_proxy_address,
            stable_debt_token_proxy_address,
            variable_debt_token_proxy_address,
            input.interest_rate_strategy,
        )
    end

    func execute_update_a_token{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        pool : felt, input : ConfiguratorInputTypes.UpdateATokenInput
    ):
        let (selector) = 111

        let (reserve) = IPool.get_reserve_data(pool, input.underlying_asset)

        let (decimals) = IPool.get_configuration(pool, input.underlying_asset).decimals

        let (encoded_call) = ProxyCallParams(
            selector,
            pool,
            input.asset,
            input.incentives_controller,
            decimals,
            input.name,
            input.symbol,
            input.params,
        )

        _upgrade_token_implementation(reserve.a_token_address, input.implementation, encoded_call)

        ATokenUpgraded.emit(input.asset, reserve.a_token_address, input.implementation)
    end

    func execute_update_stable_debt_token{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(pool : felt, input : ConfiguratorInputTypes.UpdateDebtTokenInput):
        let (selector) = 111

        let (reserve) = IPool.get_reserve_data(pool, input.underlying_asset)

        let (decimals) = IPool.get_configuration(pool, input.underlying_asset).decimals

        let (encoded_call) = ProxyCallParams(
            selector,
            pool,
            input.asset,
            input.incentives_controller,
            decimals,
            input.name,
            input.symbol,
            input.params,
        )

        _upgrade_token_implementation(
            reserve.stable_debt_token_address, input.implementation, encoded_call
        )

        StableDebtTokenUpgraded.emit(
            input.asset, reserve.stable_debt_token_address, input.implementation
        )
    end

    func execute_update_variable_debt_token{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(pool : felt, input : ConfiguratorInputTypes.UpdateDebtTokenInput):
        let (selector) = 111

        let (reserve) = IPool.get_reserve_data(pool, input.underlying_asset)

        let (decimals) = IPool.get_configuration(pool, input.underlying_asset).decimals

        let (encoded_call) = ProxyCallParams(
            selector,
            pool,
            input.asset,
            input.incentives_controller,
            decimals,
            input.name,
            input.symbol,
            input.params,
        )

        _upgrade_token_implementation(
            reserve.variable_debt_token_address, input.implementation, encoded_call
        )

        VariableDebtTokenUpgraded.emit(
            input.asset, reserve.variable_debt_token_address, input.implementation
        )
    end

    func _init_token_with_proxy{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        implementation : felt, init_params : ProxyInitParams
    ):
        let (proxy) = deploy(
            class_hash=init_params.proxy_class_hash,
            contract_address_salt=init_params.salt,
            constructor_calldata_size=1,
            constructor_calldata=cast(new (implementation), felt*),
        )
        # IProxy.initialize_params(proxy, init_params)
    end

    func _upgrade_token_implementation{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(proxy_address : felt, implementation : felt, init_params : ProxyInitParams):
        # IProxy.upgrade_to_and_call(proxy_address, implementation, init_params)
    end
end
