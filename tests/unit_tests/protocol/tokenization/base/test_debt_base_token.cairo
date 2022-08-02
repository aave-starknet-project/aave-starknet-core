%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.uint256 import Uint256

from contracts.protocol.tokenization.base.debt_token_base_library import DebtTokenBase
from tests.utils.constants import USER_1

@external
func test_underlying_asset{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (underlying) = DebtTokenBase.get_underlying_asset()
    assert underlying = 0
    DebtTokenBase.set_underlying_asset(10)
    let (underlying) = DebtTokenBase.get_underlying_asset()
    assert underlying = 10
    return ()
end

@external
func test_allowances{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (local caller) = get_caller_address()

    # Initial allowance is 0
    let (allowance) = DebtTokenBase.borrow_allowance(caller, USER_1)
    assert allowance = Uint256(0, 0)
    # Allowance increased to 10
    DebtTokenBase.approve_delegation(USER_1, Uint256(10, 0))
    let (allowance) = DebtTokenBase.borrow_allowance(caller, USER_1)
    assert allowance = Uint256(10, 0)
    # Allowance decreased to 0
    DebtTokenBase.decrease_borrow_allowance(caller, USER_1, Uint256(10, 0))
    let (allowance) = DebtTokenBase.borrow_allowance(caller, USER_1)
    assert allowance = Uint256(0, 0)
    return ()
end
