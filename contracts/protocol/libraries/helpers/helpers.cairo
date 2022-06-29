%lang starknet
from starkware.cairo.common.math_cmp import is_not_zero

# Returns 0 if value != 0. Returns 1 otherwise.
func is_zero(value) -> (res : felt):
    let (res) = is_not_zero(value)
    return (1 - res)
end
