from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.math import assert_250_bit, assert_not_zero, abs_value, split_felt

# Takes Uint256 as input and returns a felt
func to_felt{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    value : Uint256
) -> (res : felt):
    let res = value.low + value.high * (2 ** 128)

    with_attr error_message("to_felt: Value doesn't fit in a felt"):
        assert_250_bit(res)
    end

    return (res)
end

# Takes felt of any size and turns it into uint256
func to_uint_256{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    value : felt
) -> (res : Uint256):
    alloc_locals

    # with_attr error_message("to_uint_256: Not a positive value or overflown"):
    #     assert_nn_large(value)
    # end

    with_attr error_message("to_uint_256: invalid uint"):
        let (local high, local low) = split_felt(value)
    end

    let res = Uint256(low, high)
    return (res)
end
