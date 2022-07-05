%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

@storage_var
func iterable_1() -> (res : felt):
end

@storage_var
func indexed(i : felt) -> (res : felt):
end

@external
func test_iterable{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    res : felt
):
    iterable_1.write(1)
    let (res) = iterable_1.read()
    return (res)
end

@external
func test_indexed{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    res : felt
):
    indexed.write(1, 1)
    let (res) = indexed.read(1)
    return (res)
end
