%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

@storage_var
func ADDRESSES_PROVIDER() -> (address : felt):
end

@view
func get_addresses_provider{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ) -> (res : felt):
    let (res) = ADDRESSES_PROVIDER.read()
    return (res)
end
