from starkware.starknet.common.syscalls import get_block_timestamp
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_add,
    uint256_sub,
    uint256_mul,
    uint256_unsigned_div_rem,
    uint256_le,
)

from contracts.protocol.libraries.math.wad_ray_math import Ray, ray_add, RAY

namespace MathUtils:
    const SECONDS_PER_YEAR = 365 * 24 * 3600

    # @dev Function to calculate the interest accumulated using a linear interest rate formula
    # @param rate The interest rate, in ray
    # @param lastUpdateTimestamp The timestamp of the last update of the interest
    # @return The interest rate linearly accumulated during the timeDelta, in ray

    func calculate_linear_interest{range_check_ptr}(
        rate : Uint256, lastUpdateTimestamp : Uint256
    ) -> (interest : Uint256):
        alloc_locals

        let (current_timestamp) = get_block_timestamp()
        let (time_delta) = uint256_sub(Uint256(current_timestamp, 0), lastUpdateTimestamp)
        let (temp_result, _) = uint256_mul(rate, time_delta)

        let (result, _) = uint256_unsigned_div_rem(temp_result, Uint256(SECONDS_PER_YEAR, 0))

        let (interest, _) = ray_add(Ray(Uint256(RAY, 0)), Ray(result))

        return (interest.ray)
    end
end
