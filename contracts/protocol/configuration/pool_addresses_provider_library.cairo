%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from openzeppelin.access.ownable import Ownable
from contracts.interfaces.i_proxy import IProxy

const POOL = 'POOL'
const POOL_CONFIGURATOR = 'POOL_CONFIGURATOR'
const PRICE_ORACLE = 'PRICE_ORACLE'
const ACL_MANAGER = 'ACL_MANAGER'
const ACL_ADMIN = 'ACL_ADMIN'
const PRICE_ORACLE_SENTINEL = 'PRICE_ORACLE_SENTINEL'
const DATA_PROVIDER = 'DATA_PROVIDER'

# Storage variables

@storage_var
func PoolAddressesProvider_market_id() -> (id : felt):
end

@storage_var
func PoolAddressesProvider_addresses(identifier : felt) -> (registered_address : felt):
end

# Events

@event
func MarketIdSet(old_market_id, new_market_id):
end

@event
func PoolUpdated(old_implementation, new_implementation):
end

@event
func PoolConfiguratorUpdated(old_implementation, new_implementation):
end

@event
func PriceOracleUpdated(old_implementation, new_implementation):
end

@event
func ACLManagerUpdated(old_address, new_address):
end

@event
func ACLAdminUpdated(old_address, new_address):
end

@event
func PriceOracleSentinelUpdated(old_address, new_address):
end

@event
func PoolDataProviderUpdated(old_address, new_address):
end

# Doesn't exist yet in cairo
# @event
# func ProxyCreated(identifier, old_impl, new_impl):
# end

@event
func AddressSet(id : felt, old_address : felt, new_address : felt):
end

@event
func AddressSetAsProxy(
    id : felt, proxyAddress : felt, oldImplementationAddress : felt, newImplementationAddress : felt
):
end

namespace PoolAddressesProvider:
    func initializer{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        market_id : felt, owner : felt
    ):
        _set_market_id(market_id)
        Ownable.transfer_ownership(owner)
        return ()
    end

    func transfer_ownership{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        new_owner : felt
    ):
        Ownable.transfer_ownership(new_owner)
        return ()
    end

    func get_market_id{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        market_id : felt
    ):
        let (market_id) = PoolAddressesProvider_market_id.read()
        return (market_id)
    end

    func set_market_id{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        market_id : felt
    ):
        Ownable.assert_only_owner()
        _set_market_id(market_id)
        return ()
    end

    func get_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        identifier : felt
    ) -> (address : felt):
        let (registered_address) = PoolAddressesProvider_addresses.read(identifier)
        return (registered_address)
    end

    func set_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        identifier : felt, new_address : felt
    ):
        Ownable.assert_only_owner()
        let (old_address) = PoolAddressesProvider_addresses.read(identifier)
        PoolAddressesProvider_addresses.write(identifier, new_address)
        AddressSet.emit(identifier, old_address, new_address)
        return ()
    end

    func set_address_as_proxy{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        identifier : felt, new_implementation : felt
    ):
        alloc_locals
        Ownable.assert_only_owner()
        let (proxy_address) = PoolAddressesProvider_addresses.read(identifier)
        let (old_implementation) = get_proxy_implementation(identifier)
        update_impl(identifier, new_implementation)
        AddressSetAsProxy.emit(identifier, proxy_address, old_implementation, new_implementation)
        return ()
    end

    func get_pool{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        pool : felt
    ):
        let (res) = PoolAddressesProvider_addresses.read(POOL)
        return (res)
    end

    func set_pool_impl{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        new_implementation : felt
    ):
        alloc_locals
        Ownable.assert_only_owner()
        let (old_implementation) = get_proxy_implementation(POOL)
        update_impl(POOL, new_implementation)
        PoolUpdated.emit(old_implementation, new_implementation)
        return ()
    end

    func get_pool_configurator{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ) -> (pool_configurator : felt):
        let (res) = PoolAddressesProvider_addresses.read(POOL_CONFIGURATOR)
        return (res)
    end

    func set_pool_configurator_impl{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(new_implementation : felt):
        alloc_locals
        Ownable.assert_only_owner()
        let (old_implementation) = get_proxy_implementation(POOL_CONFIGURATOR)
        update_impl(POOL_CONFIGURATOR, new_implementation)
        PoolConfiguratorUpdated.emit(old_implementation, new_implementation)
        return ()
    end

    func get_price_oracle{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        price_oracle : felt
    ):
        let (res) = PoolAddressesProvider_addresses.read(PRICE_ORACLE)
        return (res)
    end

    func set_price_oracle{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        new_address : felt
    ):
        Ownable.assert_only_owner()
        let (old_address) = PoolAddressesProvider_addresses.read(PRICE_ORACLE)
        PoolAddressesProvider_addresses.write(PRICE_ORACLE, new_address)
        PriceOracleUpdated.emit(old_address, new_address)
        return ()
    end

    func get_ACL_manager{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        ACL_manager : felt
    ):
        let (res) = PoolAddressesProvider_addresses.read(ACL_MANAGER)
        return (res)
    end

    func set_ACL_manager{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        new_address : felt
    ):
        Ownable.assert_only_owner()
        let (old_address) = PoolAddressesProvider_addresses.read(ACL_MANAGER)
        PoolAddressesProvider_addresses.write(ACL_MANAGER, new_address)
        ACLManagerUpdated.emit(old_address, new_address)
        return ()
    end

    func get_ACL_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        ACL_admin : felt
    ):
        let (res) = PoolAddressesProvider_addresses.read(ACL_ADMIN)
        return (res)
    end

    func set_ACL_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        new_address : felt
    ):
        Ownable.assert_only_owner()
        let (old_address) = PoolAddressesProvider_addresses.read(ACL_ADMIN)
        PoolAddressesProvider_addresses.write(ACL_ADMIN, new_address)
        ACLAdminUpdated.emit(old_address, new_address)
        return ()
    end

    func get_price_oracle_sentinel{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }() -> (price_oracle_sentinel : felt):
        let (res) = PoolAddressesProvider_addresses.read(PRICE_ORACLE_SENTINEL)
        return (res)
    end

    func set_price_oracle_sentinel{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(new_address : felt):
        Ownable.assert_only_owner()
        let (old_address) = PoolAddressesProvider_addresses.read(PRICE_ORACLE_SENTINEL)
        PoolAddressesProvider_addresses.write(PRICE_ORACLE_SENTINEL, new_address)
        PriceOracleSentinelUpdated.emit(old_address, new_address)
        return ()
    end

    func get_pool_data_provider{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ) -> (pool_data_provider : felt):
        let (res) = PoolAddressesProvider_addresses.read(DATA_PROVIDER)
        return (res)
    end

    func set_pool_data_provider{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        new_address : felt
    ):
        Ownable.assert_only_owner()
        let (old_address) = PoolAddressesProvider_addresses.read(DATA_PROVIDER)
        PoolAddressesProvider_addresses.write(DATA_PROVIDER, new_address)
        PoolDataProviderUpdated.emit(old_address, new_address)
        return ()
    end
end

func _set_market_id{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    new_market_id : felt
):
    let (old_market_id) = PoolAddressesProvider_market_id.read()
    PoolAddressesProvider_market_id.write(new_market_id)
    MarketIdSet.emit(old_market_id, new_market_id)
    return ()
end

# @notice Internal function to update the implementation of a specific proxied component of the protocol.
# @dev If there is no proxy registered with the given identifier, it fails because deployments in contracts are not supported.
# @param id The id of the proxy to be updated
# @param new_address The class_hash of the new implementation
func update_impl{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    identifier : felt, new_implementation : felt
):
    let (proxy_address) = PoolAddressesProvider.get_address(identifier)
    if proxy_address == 0:
        # For now, it's not possible to deploy a contract from a contract in starknet.
        # Update this once it's possible, but we need to make sure each proxy is deployed
        # by the deployer
        with_attr error_message("Proxy is not deployed for {identifier}"):
            assert 0 = 1
        end
        return ()
    else:
        IProxy.upgrade(proxy_address, new_implementation)
        return ()
    end
end

func get_proxy_implementation{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    identifier : felt
) -> (implementation : felt):
    let (proxy_address) = PoolAddressesProvider_addresses.read(identifier)
    let (implementation) = IProxy.get_implementation(proxy_address)
    return (implementation)
end
