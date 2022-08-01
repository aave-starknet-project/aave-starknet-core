%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_eq
from starkware.cairo.common.bool import TRUE
from starkware.starknet.common.syscalls import get_contract_address

from contracts.protocol.tokenization.base.incentivized_erc20_library import IncentivizedERC20
from contracts.protocol.libraries.types.data_types import DataTypes

const PRANK_USER1 = 123
const PRANK_USER2 = 456
const AMOUNT = 100

# Should test for:
# Event
# Stored value.
@external
func test_transfer{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (local contract_address) = get_contract_address()
    local amount256 : Uint256 = Uint256(AMOUNT, 0)

    tempvar user_state = DataTypes.UserState(balance=AMOUNT, additional_data=0)

    %{ store(ids.contract_address, "incentivized_erc20_user_state", [ids.user_state.balance, ids.user_state.additional_data], key=[ids.PRANK_USER1]) %}

    # Amount sent
    %{ stop_prank_callable = start_prank(ids.PRANK_USER1) %}
    %{ expect_events({"name": "Transfer", "data": [ids.PRANK_USER1, ids.PRANK_USER2, ids.amount256.low, ids.amount256.high]}) %}
    IncentivizedERC20.transfer(PRANK_USER2, amount256)
    %{ stop_prank_callable() %}

    # Check amount was received
    tempvar receiver_user_state : DataTypes.UserState
    %{ (ids.receiver_user_state.balance, ids.receiver_user_state.additional_data) = load(ids.contract_address, "incentivized_erc20_user_state", "UserState", key=[ids.PRANK_USER2]) %}
    assert receiver_user_state.balance = AMOUNT

    # Check sender balance
    tempvar after_send_user_state : DataTypes.UserState
    %{ (ids.after_send_user_state.balance, ids.after_send_user_state.additional_data) = load(ids.contract_address, "incentivized_erc20_user_state", "UserState", key=[ids.PRANK_USER1]) %}
    assert after_send_user_state.balance = 0

    # Do not let transfer more than balance
    %{ stop_prank_callable = start_prank(ids.PRANK_USER1) %}
    %{ expect_revert(error_message="IncentivizedERC20: transfer amount exceeds balance") %}
    IncentivizedERC20.transfer(PRANK_USER2, amount256)
    %{ stop_prank_callable() %}

    return ()
end

@external
func test_approve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (local contract_address) = get_contract_address()
    local amount256 : Uint256 = Uint256(AMOUNT, 0)

    # Approve an ammount
    %{ stop_prank_callable = start_prank(ids.PRANK_USER1) %}
    %{ expect_events({"name": "Approval", "data": [ids.PRANK_USER1, ids.PRANK_USER2, ids.amount256.low, ids.amount256.high]}) %}
    IncentivizedERC20.approve(PRANK_USER2, amount256)
    %{ stop_prank_callable() %}

    # Verify ammount was approved
    local allowance : Uint256
    # # TODO: Change when Data Transformer is supported: https://docs.swmansion.com/protostar/docs/tutorials/guides/testing#load
    %{ (ids.allowance.low, ids.allowance.high) = load(ids.contract_address, "incentivized_erc20_allowances", "Uint256", key=[ids.PRANK_USER1, ids.PRANK_USER2]) %}
    let (is_the_allowance_expected) = uint256_eq(amount256, allowance)
    assert is_the_allowance_expected = TRUE

    return ()
end

@external
func test_allowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (local contract_address) = get_contract_address()

    local amount256 : Uint256 = Uint256(AMOUNT, 0)
    # # TODO: Change when Data Transformer is supported: https://docs.swmansion.com/protostar/docs/tutorials/guides/testing#store
    %{ store(ids.contract_address, "incentivized_erc20_allowances", [ids.amount256.low, ids.amount256.high], key=[ids.PRANK_USER1, ids.PRANK_USER2]) %}

    let (allowance) = IncentivizedERC20.allowance(PRANK_USER1, PRANK_USER2)

    let (is_the_allowance_expected) = uint256_eq(amount256, allowance)
    assert is_the_allowance_expected = TRUE

    return ()
end
