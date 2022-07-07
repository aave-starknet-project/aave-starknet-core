%lang starknet


from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_le_felt
from contracts.protocol.libraries.helpers.values import Generics

namespace Uint128:
    # Takes Uint256 as input and returns a felt that fits in 128 bits
    func to_uint_128{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        amount : Uint256
    ) -> (res : felt):
        alloc_locals
        let res = amount.low

        with_attr error_message("value doesn't fit in 128 bits"):
            assert_le_felt(res, Generics.UINT128_MAX)
        end

        return (res)
    end



    func to_uint_256{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        amount : felt
    ) -> (res : Uint256):
        let res = Uint256(amount,0)
        return (res)
    end


end
