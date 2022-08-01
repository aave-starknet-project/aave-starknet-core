%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_eq
from starkware.cairo.common.bool import TRUE

from contracts.protocol.libraries.helpers.constants import UINT128_MAX
from contracts.protocol.libraries.math.uint_250 import Uint250

const HIGH = 21
const LOW = 37
const VALUE = 7145929705339707732730866756067132440613

@view
func test_to_felt{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let uint_256 = Uint256(LOW, HIGH)
    let (felt_250) = Uint250.to_felt(uint_256)

    assert felt_250 = VALUE

    return ()
end

@view
func test_to_uint_256{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let uint_256_constructed = Uint256(LOW, HIGH)
    let (uint_256_from_library) = Uint250.to_uint_256(VALUE)

    let (are_equal) = uint256_eq(uint_256_from_library, uint_256_constructed)
    assert are_equal = TRUE

    return ()
end

@view
func test_failure_to_felt{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let uint_256 = Uint256(UINT128_MAX, UINT128_MAX)
    %{ expect_revert(error_message="Uint250: Value doesn't fit in a felt") %}
    let (felt_250) = Uint250.to_felt(uint_256)

    return ()
end