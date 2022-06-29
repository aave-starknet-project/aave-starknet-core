%lang starknet

from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.lang.compiler.lib.registers import get_fp_and_pc

from contracts.protocol.libraries.helpers.helpers import is_zero, modify_struct

struct MyStruct:
    member a : felt
    member b : felt
    member c : felt
end

@view
func test_is_zero():
    let (true) = is_zero(0)
    let (false) = is_zero(1)
    assert true = TRUE
    assert false = FALSE
    return ()
end

@view
func test_modify_struct{range_check_ptr}():
    alloc_locals
    let (__fp__, _) = get_fp_and_pc()
    local my_struct : MyStruct = MyStruct(1, 2, 3)
    let (modified_struct_ptr : MyStruct*) = modify_struct(&my_struct, MyStruct.SIZE, 100, 1)
    let modified_struct : MyStruct = [modified_struct_ptr]

    assert modified_struct = MyStruct(1, 100, 3)
    return ()
end

@view
func test_modify_struct_out_of_range{range_check_ptr}():
    alloc_locals
    let (__fp__, _) = get_fp_and_pc()
    local my_struct : MyStruct = MyStruct(1, 2, 3)
    %{ expect_revert() %}
    let (modified_struct_ptr : MyStruct*) = modify_struct(&my_struct, MyStruct.SIZE, 100, 10)
    return ()
end
