%lang starknet

from starkware.cairo.common.pow import pow
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.cairo_builtins import HashBuiltin
from openzeppelin.security.safemath import SafeUint256

namespace Utils:
    func parse_units{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        amount : felt, decimals : felt
    ) -> (res : Uint256):
        let (power) = pow(10, decimals)
        let (res) = SafeUint256.mul(Uint256(amount, 0), Uint256(power, 0))
        return (amount * power)
    end

    func parse_ether{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        amount : felt
    ) -> (res : Uint256):
        let (power) = pow(10, 18)
        let (res) = SafeUint256.mul(Uint256(amount, 0), Uint256(power, 0))
        return (res)
    end

    func array_includes{range_check_ptr}(array_len : felt, array : felt*, value : felt) -> (
        res : felt
    ):
        return _array_includes(array_len, array, value)
    end
end

func _array_includes{range_check_ptr}(array_len : felt, array : felt*, value : felt) -> (
    res : felt
):
    if array_len == 0:
        return (FALSE)
    end

    if [array] == value:
        return (TRUE)
    end

    return _array_includes(array_len - 1, array + 1, value)
end
