%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_eq
from starkware.cairo.common.bool import TRUE

from contracts.protocol.libraries.helpers.constants import UINT128_MAX
from contracts.protocol.libraries.math.helpers import to_felt, to_uint_256

# Values chosen randomly where: Uint(LOW, HIGH) = VALUE
const HIGH_LARGE = 21
const LOW_LARGE = 37
const VALUE_LARGE = 7145929705339707732730866756067132440613

const HIGH_SMALL = 0
const LOW_SMALL = 2 ** 127 + 1
const VALUE_SMALL = LOW_SMALL

# Largest Uint256 possible, will not fit felt
const VALUE_NEGATIVE = -1

@view
func test_to_felt{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let uint_256 = Uint256(LOW_LARGE, HIGH_LARGE)
    let (value_felt) = to_felt(uint_256)

    assert value_felt = VALUE_LARGE

    return ()
end

@view
func test_to_uint_256{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let uint_256_constructed = Uint256(LOW_SMALL, HIGH_SMALL)
    let (uint_256_from_library) = to_uint_256(VALUE_SMALL)

    let (are_equal) = uint256_eq(uint_256_from_library, uint_256_constructed)
    assert are_equal = TRUE

    return ()
end

@view
func test_failure_to_felt{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let uint_256 = Uint256(UINT128_MAX, UINT128_MAX)
    %{ expect_revert() %}
    let (value_felt) = to_felt(uint_256)

    return ()
end

# TODO: research more as to range_checks, it might make sense to stick to uint_128
# Right now, it will convert negative valued felts to Uint_256
@view
func test_failure_to_uint_256{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    %{ expect_revert() %}
    let (value_felt) = to_uint_256(VALUE_NEGATIVE)
    return ()
end
