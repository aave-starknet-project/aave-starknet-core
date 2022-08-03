from starkware.starknet.common.syscalls import get_block_timestamp
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_add,
    uint256_sub,
    uint256_mul,
    uint256_unsigned_div_rem,
    uint256_eq,
)

from contracts.protocol.libraries.math.wad_ray_math import Ray, ray_add, RAY, ray_mul
from contracts.protocol.libraries.helpers.helpers import uint256_checked_sub_return_zero_when_lt

namespace MathUtils:
    const SECONDS_PER_YEAR = 365 * 24 * 3600

    # @dev Function to calculate the interest accumulated using a linear interest rate formula
    # @param rate The interest rate, in ray
    # @param last_update_timestamp The timestamp of the last update of the interest
    # @return The interest rate linearly accumulated during the timeDelta, in ray

    func calculate_linear_interest{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(rate : Uint256, last_update_timestamp : Uint256) -> (interest : Uint256):
        alloc_locals

        let (current_time_stamp) = get_block_timestamp()
        let (time_delta) = uint256_sub(Uint256(current_time_stamp, 0), last_update_timestamp)
        let (temp_result, _) = uint256_mul(rate, time_delta)

        let (result, _) = uint256_unsigned_div_rem(temp_result, Uint256(SECONDS_PER_YEAR, 0))

        let (interest, _) = ray_add(Ray(Uint256(RAY, 0)), Ray(result))

        return (interest.ray)
    end
    # @dev Calculates the compounded interest between the timestamp of the last update and the current block timestamp
    # @param rate The interest rate (in ray)
    # @param last_update_timestamp The timestamp from which the interest accumulation needs to be calculated
    # @return The interest rate compounded between lastUpdateTimestamp and current block times
    func calculate_compounded_interest{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(rate : Uint256, last_update_time_stamp : Uint256) -> (interest : Uint256):
        let (current_time_stamp) = get_block_timestamp()
        let (interest) = _calculate_compounded_interest(
            rate, last_update_time_stamp, Uint256(current_time_stamp, 0)
        )

        return (interest)
    end

    # @dev Function to calculate the interest using a compounded interest rate formula
    # To avoid expensive exponentiation, the calculation is performed using a binomial approximation:
    #
    #  (1+x)^n = 1+n*x+[n/2*(n-1)]*x^2+[n/6*(n-1)*(n-2)*x^3...
    #
    # The approximation slightly underpays liquidity providers and undercharges borrowers, with the advantage of great
    # gas cost reductions. The whitepaper contains reference to the approximation and a table showing the margin of
    # error per different time periods
    #
    # @param rate The interest rate, in ray
    # @param lastUpdateTimestamp The timestamp of the last update of the interest
    # @return The interest rate compounded during the timeDelta, in ray

    func _calculate_compounded_interest{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(rate : Uint256, last_update_time_stamp : Uint256, current_time_stamp : Uint256) -> (
        interest : Uint256
    ):
        alloc_locals
        let (exp) = uint256_sub(current_time_stamp, last_update_time_stamp)

        let (is_exp_zero) = uint256_eq(exp, Uint256(0, 0))
        if is_exp_zero == 1:
            return (Uint256(RAY, 0))
        end

        let (exp_minus_one) = uint256_sub(exp, Uint256(1, 0))

        let (exp_minus_two) = uint256_checked_sub_return_zero_when_lt(exp, Uint256(2, 0))

        let (rate_square) = ray_mul(Ray(rate), Ray(rate))
        let (period_square, _) = uint256_mul(
            Uint256(SECONDS_PER_YEAR, 0), Uint256(SECONDS_PER_YEAR, 0)
        )
        let (base_power_two, _) = uint256_unsigned_div_rem(rate_square.ray, period_square)

        let (base_power_two_multiplied_by_rate) = ray_mul(Ray(base_power_two), Ray(rate))

        let (base_power_three, _) = uint256_unsigned_div_rem(
            base_power_two_multiplied_by_rate.ray, Uint256(SECONDS_PER_YEAR, 0)
        )

        let (temp_second_term, _) = uint256_mul(exp, exp_minus_one)
        let (second_term, _) = uint256_mul(temp_second_term, base_power_two)

        let (second_term, _) = uint256_unsigned_div_rem(second_term, Uint256(2, 0))
        let (first_part_third_term, _) = uint256_mul(exp, exp_minus_one)
        let (second_part_third_term, _) = uint256_mul(exp_minus_two, base_power_three)
        let (third_term_, _) = uint256_mul(first_part_third_term, second_part_third_term)

        let (third_term, _) = uint256_unsigned_div_rem(third_term_, Uint256(6, 0))

        let (rate_mul_exp, _) = uint256_mul(rate, exp)
        let (rate_mul_exp_div_period, _) = uint256_unsigned_div_rem(
            rate_mul_exp, Uint256(SECONDS_PER_YEAR, 0)
        )
        let (first_part_rate, _) = uint256_add(Uint256(RAY, 0), rate_mul_exp_div_period)
        let (second_plus_third_term, _) = uint256_add(second_term, third_term)

        let (compounded_interest, _) = uint256_add(first_part_rate, second_plus_third_term)

        return (compounded_interest)
    end
end
