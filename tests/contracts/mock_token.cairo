# SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

@storage_var
func _name() -> (name : felt):
end

@storage_var
func _total_supply() -> (supply : felt):
end

@external
func initialize{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    name : felt, totalSupply : felt
):
    _name.write(name)
    _total_supply.write(totalSupply)

    return ()
end

@view
func get_name{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (name : felt):
    let (name) = _name.read()
    return (name)
end

@view
func get_total_supply{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    supply : felt
):
    let (supply) = _total_supply.read()
    return (supply)
end
