%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

from contracts.protocol.pool.pool_configurator_library import PoolConfigurator

#
# Constructor
#

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    provider : felt
):
    PoolConfigurator.initialize(provider)
    return ()
end
