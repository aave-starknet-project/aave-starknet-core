%lang starknet
from starkware.starknet.common.syscalls import get_contract_address
from starkware.cairo.common.cairo_builtins import HashBuiltin
from tests.utils.constants import USER_1, USER_2
from starkware.cairo.common.alloc import alloc

from starkware.starknet.common.syscalls import get_block_timestamp
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_add,
    uint256_sub,
    uint256_mul,
    uint256_unsigned_div_rem,
)

from contracts.protocol.libraries.math.wad_ray_math import Ray, ray_add, RAY

namespace MathUtils:
    const SECONDS_PER_YEAR = 365 * 24 * 3600

    # had to import the library to test it with a non null timestamp value

    func calculate_linear_interest{range_check_ptr, syscall_ptr : felt*}(
        rate : Uint256, lastUpdateTimestamp : Uint256
    ) -> (interest : Uint256):
        alloc_locals
        let hard_coded_timestamp : Uint256 = Uint256(301, 0)

        let (time_delta) = uint256_sub(hard_coded_timestamp, lastUpdateTimestamp)
        let (temp_result, _) = uint256_mul(rate, time_delta)

        let (result, _) = uint256_unsigned_div_rem(temp_result, Uint256(SECONDS_PER_YEAR, 0))

        let (interest, _) = ray_add(Ray(Uint256(RAY, 0)), Ray(result))

        return (interest.ray)
    end
end

@external
func test_calculate_linear_interest{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    alloc_locals

    const rate_in_ray = 34000000000000000000000000000
    const last_time_stamp = 300

    let (res : Uint256) = MathUtils.calculate_linear_interest(
        Uint256(rate_in_ray, 0), Uint256(last_time_stamp, 0)
    )

    # expected value with a time delta of 1 : (34*10**27)/(365*24*3600) + 10**27
    assert res.low = 1000001078132927447995941146
    return ()
end
