%lang starknet

from starkware.cairo.common.bool import TRUE, FALSE

from contracts.protocol.libraries.helpers.bool_cmp import BoolCompare

@external
func test_is_valid{range_check_ptr}():
    BoolCompare.is_valid(0)
    BoolCompare.is_valid(1)
    %{ expect_revert(error_message="Value should be either 0 or 1. Current value: 2") %}
    BoolCompare.is_valid(2)
    return ()
end

@external
func test_eq{range_check_ptr}():
    let (true) = BoolCompare.eq(0, 0)
    let (false) = BoolCompare.eq(1, 0)
    assert true = TRUE
    assert false = FALSE
    return ()
end

@external
func test_either{range_check_ptr}():
    let (false) = BoolCompare.either(0, 0)
    let (true_1) = BoolCompare.either(1, 1)
    let (true_2) = BoolCompare.either(1, 0)
    assert true_1 = TRUE
    assert true_2 = TRUE
    assert false = FALSE
    return ()
end

@external
func test_both{range_check_ptr}():
    let (true) = BoolCompare.both(1, 1)
    let (false_1) = BoolCompare.both(1, 0)
    let (false_2) = BoolCompare.both(0, 1)
    let (false_3) = BoolCompare.both(0, 0)
    assert true = TRUE
    assert false_1 = FALSE
    assert false_2 = FALSE
    assert false_3 = FALSE
    return ()
end
