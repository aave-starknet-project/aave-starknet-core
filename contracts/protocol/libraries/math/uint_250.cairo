from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_250_bit, split_felt

from contracts.protocol.libraries.helpers.constants import UINT128_MAX

namespace Uint250:
    # Takes Uint256 as input and returns a felt
    func to_felt{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        amount : Uint256
    ) -> (res : felt):
        alloc_locals
        let res = amount.low + amount.high * (UINT128_MAX + 1)

        with_attr error_message("Uint250: Value doesn't fit in a felt"):
            assert_250_bit(res)
        end

        return (res)
    end

    # Takes felt of any size and turns it into uint256
    func to_uint_256{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        amount : felt
    ) -> (res : Uint256):
        alloc_locals
        let (local high, local low) = split_felt(amount)
        let res = Uint256(low, high)
        return (res)
    end
end
