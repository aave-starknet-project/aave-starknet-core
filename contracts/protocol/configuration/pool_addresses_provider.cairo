%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin

from contracts.protocol.configuration.pool_addresses_provider_library import PoolAddressesProvider

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    market_id : felt, owner : felt, proxy_class_hash : felt
):
    PoolAddressesProvider.initializer(market_id, owner, proxy_class_hash)
    return ()
end

@external
func transfer_ownership{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    new_owner : felt
):
    PoolAddressesProvider.transfer_ownership(new_owner)
    return ()
end

@view
func get_market_id{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    market_id : felt
):
    let (market_id) = PoolAddressesProvider.get_market_id()
    return (market_id)
end

@external
func set_market_id{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    market_id : felt
):
    PoolAddressesProvider.set_market_id(market_id)
    return ()
end

@view
func get_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(id : felt) -> (
    address : felt
):
    let (registered_address) = PoolAddressesProvider.get_address(id)
    return (registered_address)
end

@external
func set_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    id : felt, new_address : felt
):
    PoolAddressesProvider.set_address(id, new_address)
    return ()
end

@external
func set_address_as_proxy{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    id : felt, implementation : felt, salt : felt
):
    PoolAddressesProvider.set_address_as_proxy(id, implementation, salt)
    return ()
end

@view
func get_pool{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (pool : felt):
    let (res) = PoolAddressesProvider.get_pool()
    return (res)
end

@external
func set_pool_impl{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    new_implementation : felt, salt : felt
):
    PoolAddressesProvider.set_pool_impl(new_implementation, salt)
    return ()
end

@view
func get_pool_configurator{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    pool_configurator : felt
):
    let (res) = PoolAddressesProvider.get_pool_configurator()
    return (res)
end

@external
func set_pool_configurator_impl{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    new_implementation : felt, salt : felt
):
    PoolAddressesProvider.set_pool_configurator_impl(new_implementation, salt)
    return ()
end

@view
func get_price_oracle{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    price_oracle : felt
):
    let (res) = PoolAddressesProvider.get_price_oracle()
    return (res)
end

@external
func set_price_oracle{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    new_address : felt
):
    PoolAddressesProvider.set_price_oracle(new_address)
    return ()
end

@view
func get_ACL_manager{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    ACL_manager : felt
):
    let (res) = PoolAddressesProvider.get_ACL_manager()
    return (res)
end

@external
func set_ACL_manager{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    new_address : felt
):
    PoolAddressesProvider.set_ACL_manager(new_address)
    return ()
end

@view
func get_ACL_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    ACL_admin : felt
):
    let (res) = PoolAddressesProvider.get_ACL_admin()
    return (res)
end

@external
func set_ACL_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    new_address : felt
):
    PoolAddressesProvider.set_ACL_admin(new_address)
    return ()
end

@view
func get_price_oracle_sentinel{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ) -> (price_oracle_sentinel : felt):
    let (res) = PoolAddressesProvider.get_price_oracle_sentinel()
    return (res)
end

@external
func set_price_oracle_sentinel{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    new_address : felt
):
    PoolAddressesProvider.set_price_oracle_sentinel(new_address)
    return ()
end

@view
func get_pool_data_provider{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ) -> (get_pool_data_provider : felt):
    let (res) = PoolAddressesProvider.get_pool_data_provider()
    return (res)
end

@external
func set_pool_data_provider{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    new_address : felt
):
    PoolAddressesProvider.set_pool_data_provider(new_address)
    return ()
end
