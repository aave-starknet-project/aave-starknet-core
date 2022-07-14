%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import deploy, get_contract_address
from openzeppelin.access.ownable import Ownable
from contracts.interfaces.i_proxy import IProxy

#
# Identifiers
#
const POOL = 'POOL'
const POOL_CONFIGURATOR = 'POOL_CONFIGURATOR'
const PRICE_ORACLE = 'PRICE_ORACLE'
const ACL_MANAGER = 'ACL_MANAGER'
const ACL_ADMIN = 'ACL_ADMIN'
const PRICE_ORACLE_SENTINEL = 'PRICE_ORACLE_SENTINEL'
const DATA_PROVIDER = 'DATA_PROVIDER'

#
# Storage
#
@storage_var
func PoolAddressesProvider_market_id() -> (id : felt):
end

# @notice Maps an identifier to its address
@storage_var
func PoolAddressesProvider_addresses(id : felt) -> (registered_address : felt):
end

# @notice Stores the class_hash of a proxy contract.
# @dev Proxy class_hash needs to be set before deploying proxies from PoolAddressesProvider.
# @dev The class hash must have been declared before deploying this contract.
@storage_var
func PoolAddressesProvider_proxy_class_hash() -> (salt : felt):
end

#
# Events
#

# @dev Emitted when the market identifier is updated.
# @param old_market_id The old id of the market
# @param new_market_id The new id of the market
@event
func MarketIdSet(old_market_id, new_market_id):
end

# @dev Emitted when the pool is updated.
# @param old_implementation The old implementation of the Pool
# @param new_implementation The new implementation of the Pool
@event
func PoolUpdated(old_implementation, new_implementation):
end

# @dev Emitted when the pool configurator is updated.
# @param old_implementation The old implementation of the PoolConfigurator
# @param new_implementation The new implementation of the PoolConfigurator
@event
func PoolConfiguratorUpdated(old_implementation, new_implementation):
end

# @dev Emitted when the price oracle is updated.
# @param old_address The old address of the PriceOracle
# @param new_implementation The new address of the PriceOracle
@event
func PriceOracleUpdated(old_implementation, new_implementation):
end

# @dev Emitted when the ACL manager is updated.
# @param old_address The old address of the ACLManager
# @param new_address The new address of the ACLManager
@event
func ACLManagerUpdated(old_address, new_address):
end

# @dev Emitted when the ACL admin is updated.
# @param old_address The old address of the ACLAdmin
# @param new_address The new address of the ACLAdmin
@event
func ACLAdminUpdated(old_address, new_address):
end

# @dev Emitted when the price oracle sentinel is updated.
# @param old_address The old address of the PriceOracleSentinel
# @param new_address The new address of the PriceOracleSentinel
@event
func PriceOracleSentinelUpdated(old_address, new_address):
end

# @dev Emitted when the pool data provider is updated.
# @param old_address The old address of the PoolDataProvider
# @param new_address The new address of the PoolDataProvider
@event
func PoolDataProviderUpdated(old_address, new_address):
end

# @dev Emitted when a new proxy is created.
# @param id The identifier of the proxy
# @param proxy_address The address of the created proxy contract
# @param implementation_hash The address of the implementation contract
@event
func ProxyCreated(id, proxy_address, implementation_hash):
end

# @dev Emitted when a new non-proxied contract address is registered.
# @param id The identifier of the contract
# @param old_address The address of the old contract
# @param new_address The address of the new contract
@event
func AddressSet(id : felt, old_address : felt, new_address : felt):
end

# @dev Emitted when the implementation of the proxy registered with id is updated
# @param id The identifier of the contract
# @param proxy_address The address of the proxy contract
# @param old_implementation_hash The old implementation hash
# @param new_implementation_hash The new implementation hash
@event
func AddressSetAsProxy(
    id : felt, proxy_address : felt, old_implementation_hash : felt, new_implementation_hash : felt
):
end

namespace PoolAddressesProvider:
    #
    # Initializer
    #

    func initializer{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        market_id : felt, owner : felt, proxy_class_hash : felt
    ):
        _set_market_id(market_id)
        Ownable.transfer_ownership(owner)
        PoolAddressesProvider_proxy_class_hash.write(proxy_class_hash)
        return ()
    end

    #
    # Ownable functions
    #

    func transfer_ownership{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        new_owner : felt
    ):
        Ownable.transfer_ownership(new_owner)
        return ()
    end

    #
    # Getters and setters
    #

    # @notice Returns the id of the Aave market to which this contract points to.
    # @return The market id
    func get_market_id{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        market_id : felt
    ):
        let (market_id) = PoolAddressesProvider_market_id.read()
        return (market_id)
    end

    # @notice Associates an id with a specific PoolAddressesProvider.
    # @dev This can be used to create an onchain registry of PoolAddressesProviders to
    # identify and validate multiple Aave markets.
    # @param new_market_id The market id
    func set_market_id{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        new_market_id : felt
    ):
        Ownable.assert_only_owner()
        _set_market_id(new_market_id)
        return ()
    end

    # @notice Returns an address by its identifier.
    # @dev The returned address is a contract, potentially proxied
    # @dev It returns ZERO if there is no registered address with the given id
    # @param id The id
    # @return The address of the contract registered for the specified id
    func get_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        id : felt
    ) -> (address : felt):
        let (registered_address) = PoolAddressesProvider_addresses.read(id)
        return (registered_address)
    end

    # @notice General function to update the implementation of a proxy registered with
    # certain `id`. If there is no proxy registered, it will instantiate one and
    # set as implementation the `new_implementation`.
    # @dev IMPORTANT Use this function carefully, only for ids that don't have an explicit
    # setter function, in order to avoid unexpected consequences
    # @param id The id
    # @param salt random number required to deploy a proxy
    # @param new_implementation The hash of the new implementation
    func set_address_as_proxy{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        id : felt, new_implementation : felt, salt : felt
    ):
        alloc_locals
        Ownable.assert_only_owner()
        let (proxy_address) = PoolAddressesProvider_addresses.read(id)
        let (old_implementation) = get_proxy_implementation(id)
        update_impl(id, new_implementation, salt)
        AddressSetAsProxy.emit(id, proxy_address, old_implementation, new_implementation)
        return ()
    end

    # @notice Sets an address for an id replacing the address saved in the addresses map.
    # @dev IMPORTANT Use this function carefully, as it will do a hard replacement
    # @param id The id
    # @param new_address The address to set
    func set_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        id : felt, new_address : felt
    ):
        Ownable.assert_only_owner()
        let (old_address) = PoolAddressesProvider_addresses.read(id)
        PoolAddressesProvider_addresses.write(id, new_address)
        AddressSet.emit(id, old_address, new_address)
        return ()
    end

    # @notice Returns the address of the Pool proxy.
    # @return The Pool proxy address
    func get_pool{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        pool : felt
    ):
        let (res) = PoolAddressesProvider_addresses.read(POOL)
        return (res)
    end

    # @notice Updates the implementation of the Pool, or creates a proxy
    # setting the new `pool` implementation when the function is called for the first time.
    # @param new_pool_impl The new Pool implementation
    # @param salt random number required to deploy a proxy
    func set_pool_impl{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        new_pool_impl : felt, salt : felt
    ):
        alloc_locals
        Ownable.assert_only_owner()
        let (old_implementation) = get_proxy_implementation(POOL)
        update_impl(POOL, new_pool_impl, salt)
        PoolUpdated.emit(old_implementation, new_pool_impl)
        return ()
    end

    # @notice Returns the address of the PoolConfigurator proxy.
    # @return The PoolConfigurator proxy address
    func get_pool_configurator{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ) -> (pool_configurator : felt):
        let (res) = PoolAddressesProvider_addresses.read(POOL_CONFIGURATOR)
        return (res)
    end

    # @notice Updates the implementation of the PoolConfigurator, or creates a proxy
    # setting the new `PoolConfigurator` implementation when the function is called for the first time.
    # @param new_pool_configurator_impl The new PoolConfigurator implementation
    # @param salt random number required to deploy a proxy
    func set_pool_configurator_impl{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(new_pool_configurator_impl : felt, salt : felt):
        alloc_locals
        Ownable.assert_only_owner()
        let (old_implementation) = get_proxy_implementation(POOL_CONFIGURATOR)
        update_impl(POOL_CONFIGURATOR, new_pool_configurator_impl, salt)
        PoolConfiguratorUpdated.emit(old_implementation, new_pool_configurator_impl)
        return ()
    end

    # @notice Returns the address of the price oracle.
    # @return The address of the PriceOracle
    func get_price_oracle{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        price_oracle : felt
    ):
        let (res) = PoolAddressesProvider_addresses.read(PRICE_ORACLE)
        return (res)
    end

    # @notice Updates the address of the price oracle.
    # @param new_price_oracle The address of the new PriceOracle
    func set_price_oracle{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        new_price_oracle : felt
    ):
        Ownable.assert_only_owner()
        let (old_address) = PoolAddressesProvider_addresses.read(PRICE_ORACLE)
        PoolAddressesProvider_addresses.write(PRICE_ORACLE, new_price_oracle)
        PriceOracleUpdated.emit(old_address, new_price_oracle)
        return ()
    end

    # @notice Returns the address of the ACL manager.
    # @return The address of the ACLManager
    func get_ACL_manager{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        ACL_manager : felt
    ):
        let (res) = PoolAddressesProvider_addresses.read(ACL_MANAGER)
        return (res)
    end

    # @notice Updates the address of the ACL manager.
    # @param new_acl_manager The address of the new ACLManager
    func set_ACL_manager{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        new_acl_manager : felt
    ):
        Ownable.assert_only_owner()
        let (old_address) = PoolAddressesProvider_addresses.read(ACL_MANAGER)
        PoolAddressesProvider_addresses.write(ACL_MANAGER, new_acl_manager)
        ACLManagerUpdated.emit(old_address, new_acl_manager)
        return ()
    end

    # @notice Returns the address of the ACL admin.
    # @return The address of the ACL admin
    func get_ACL_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        ACL_admin : felt
    ):
        let (res) = PoolAddressesProvider_addresses.read(ACL_ADMIN)
        return (res)
    end

    # @notice Updates the address of the ACL admin.
    # @param new_acl_admin The address of the new ACL admin
    func set_ACL_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        new_acl_admin : felt
    ):
        Ownable.assert_only_owner()
        let (old_address) = PoolAddressesProvider_addresses.read(ACL_ADMIN)
        PoolAddressesProvider_addresses.write(ACL_ADMIN, new_acl_admin)
        ACLAdminUpdated.emit(old_address, new_acl_admin)
        return ()
    end

    # @notice Returns the address of the price oracle sentinel.
    # @return The address of the PriceOracleSentinel
    func get_price_oracle_sentinel{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }() -> (price_oracle_sentinel : felt):
        let (res) = PoolAddressesProvider_addresses.read(PRICE_ORACLE_SENTINEL)
        return (res)
    end

    # @notice Updates the address of the price oracle sentinel.
    # @param new_price_oracle_sentinel The address of the new PriceOracleSentinel
    func set_price_oracle_sentinel{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(new_price_oracle_sentinel : felt):
        Ownable.assert_only_owner()
        let (old_address) = PoolAddressesProvider_addresses.read(PRICE_ORACLE_SENTINEL)
        PoolAddressesProvider_addresses.write(PRICE_ORACLE_SENTINEL, new_price_oracle_sentinel)
        PriceOracleSentinelUpdated.emit(old_address, new_price_oracle_sentinel)
        return ()
    end

    # @notice Returns the address of the data provider.
    # @return The address of the DataProvider
    func get_pool_data_provider{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ) -> (pool_data_provider : felt):
        let (res) = PoolAddressesProvider_addresses.read(DATA_PROVIDER)
        return (res)
    end

    # @notice Updates the address of the data provider.
    # @param new_data_provider The address of the new DataProvider
    func set_pool_data_provider{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        new_data_provider : felt
    ):
        Ownable.assert_only_owner()
        let (old_address) = PoolAddressesProvider_addresses.read(DATA_PROVIDER)
        PoolAddressesProvider_addresses.write(DATA_PROVIDER, new_data_provider)
        PoolDataProviderUpdated.emit(old_address, new_data_provider)
        return ()
    end
end

# @notice Internal function to update the identifier of the Aave market.
# @param new_market_id The new id of the market
func _set_market_id{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    new_market_id : felt
):
    let (old_market_id) = PoolAddressesProvider_market_id.read()
    PoolAddressesProvider_market_id.write(new_market_id)
    MarketIdSet.emit(old_market_id, new_market_id)
    return ()
end

# @notice Internal function to update the implementation of a specific proxied component of the protocol.
# @dev If there is no proxy registered with the given identifier, it creates the proxy setting `new_implementation`
#   as implementation and calls the initialize() function on the proxy
# @dev If there is already a proxy registered, it just updates the implementation to `new_implementation` and
#   via IProxy.upgrade()
# @param id The id of the proxy to be updated
# @param new_implementation The hash of the new implementation class
# @param salt random number required to deploy a proxy
func update_impl{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    id : felt, new_implementation : felt, salt : felt
):
    let (proxy_address) = PoolAddressesProvider.get_address(id)
    if proxy_address == 0:
        let (proxy_admin) = get_contract_address()
        let (proxy_class_hash) = PoolAddressesProvider_proxy_class_hash.read()
        let (contract_address) = deploy(
            class_hash=proxy_class_hash,
            contract_address_salt=salt,
            constructor_calldata_size=1,
            constructor_calldata=cast(new (new_implementation), felt*),
        )
        IProxy.initialize(contract_address, proxy_admin)
        PoolAddressesProvider_addresses.write(id, contract_address)
        ProxyCreated.emit(id, proxy_address, new_implementation)
        return ()
    else:
        IProxy.upgrade(proxy_address, new_implementation)
        return ()
    end
end

# @notice Returns the the implementation contract of the proxy contract by its identifier.
# @dev It returns ZERO if there is no registered address with the given id
# @dev It reverts if the registered address does not implement `IProxy get_implementation`.
# @param id The id
# @return The hash of the implementation class
func get_proxy_implementation{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    id : felt
) -> (implementation : felt):
    let (proxy_address) = PoolAddressesProvider_addresses.read(id)
    if proxy_address == 0:
        return (0)
    end
    let (implementation) = IProxy.get_implementation(proxy_address)
    return (implementation)
end
