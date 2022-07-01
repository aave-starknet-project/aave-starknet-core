from starkware.cairo.common.pow import pow
from starkware.cairo.common.bool import TRUE, FALSE
namespace Utils:
    func parse_units{range_check_ptr}(amount : felt, decimals : felt) -> (res : felt):
        let (x) = pow(10, decimals)
        return (amount * x)
    end

    func parse_ether{range_check_ptr}(amount : felt) -> (res : felt):
        let (x) = pow(10, 18)
        return (amount * x)
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
