%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_eq, uint256_add
from starkware.cairo.common.bool import TRUE
from starkware.starknet.common.syscalls import get_contract_address

from openzeppelin.security.safemath import SafeUint256

from contracts.protocol.tokenization.base.incentivized_erc20_library import IncentivizedERC20
from contracts.protocol.libraries.types.data_types import DataTypes
from contracts.protocol.libraries.math.helpers import to_uint_256

const PRANK_USER1 = 123
const PRANK_USER2 = 456
const PRANK_USER3 = 789
const AMOUNT = 100

@external
func test_balance_of{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (local contract_address) = get_contract_address()
    # Mock balance
    tempvar user_state = DataTypes.UserState(balance=AMOUNT, additional_data=0)
    %{ store(ids.contract_address, "incentivized_erc20_user_state", [ids.user_state.balance, ids.user_state.additional_data], key=[ids.PRANK_USER1]) %}

    let (balance) = IncentivizedERC20.balance_of(PRANK_USER1)
    assert balance = AMOUNT

    return ()
end

@external
func test_transfer{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (local contract_address) = get_contract_address()
    let (local amount256) = to_uint_256(AMOUNT)

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
func test_transfer_from{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (local contract_address) = get_contract_address()

    # Set balances and allowances
    tempvar user_state = DataTypes.UserState(balance=AMOUNT, additional_data=0)
    %{ store(ids.contract_address, "incentivized_erc20_user_state", [ids.user_state.balance, ids.user_state.additional_data], key=[ids.PRANK_USER2]) %}
    let (local amount256) = to_uint_256(AMOUNT)

    %{ store(ids.contract_address, "incentivized_erc20_allowances", [ids.amount256.low, ids.amount256.high], key=[ids.PRANK_USER2, ids.PRANK_USER1]) %}

    # Amount sent
    %{ stop_prank_callable = start_prank(ids.PRANK_USER1) %}
    %{ expect_events({"name": "Transfer", "data": [ids.PRANK_USER2, ids.PRANK_USER3, ids.amount256.low, ids.amount256.high]}) %}
    IncentivizedERC20.transfer_from(PRANK_USER2, PRANK_USER3, amount256)
    %{ stop_prank_callable() %}

    # Check amount was received
    tempvar receiver_user_state : DataTypes.UserState
    %{ (ids.receiver_user_state.balance, ids.receiver_user_state.additional_data) = load(ids.contract_address, "incentivized_erc20_user_state", "UserState", key=[ids.PRANK_USER3]) %}
    assert receiver_user_state.balance = AMOUNT

    # Check sender balance
    tempvar after_send_user_state : DataTypes.UserState
    %{ (ids.after_send_user_state.balance, ids.after_send_user_state.additional_data) = load(ids.contract_address, "incentivized_erc20_user_state", "UserState", key=[ids.PRANK_USER2]) %}
    assert after_send_user_state.balance = 0

    # Do not let transfer more than balance
    %{ stop_prank_callable = start_prank(ids.PRANK_USER1) %}
    %{ expect_revert() %}
    IncentivizedERC20.transfer_from(PRANK_USER2, PRANK_USER2, amount256)
    %{ stop_prank_callable() %}

    return ()
end

@external
func test_approve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (local contract_address) = get_contract_address()
    let (local amount256) = to_uint_256(AMOUNT)

    # Approve an ammount
    %{ stop_prank_callable = start_prank(ids.PRANK_USER1) %}
    %{ expect_events({"name": "Approval", "data": [ids.PRANK_USER1, ids.PRANK_USER2, ids.amount256.low, ids.amount256.high]}) %}
    IncentivizedERC20.approve(PRANK_USER2, amount256)
    %{ stop_prank_callable() %}

    # Verify ammount was approved
    local allowance : Uint256
    %{ (ids.allowance.low, ids.allowance.high) = load(ids.contract_address, "incentivized_erc20_allowances", "Uint256", key=[ids.PRANK_USER1, ids.PRANK_USER2]) %}
    let (is_the_allowance_expected) = uint256_eq(amount256, allowance)
    assert is_the_allowance_expected = TRUE

    return ()
end

@external
func test_allowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (local contract_address) = get_contract_address()

    # Set allowance
    let (local amount256) = to_uint_256(AMOUNT)
    %{ store(ids.contract_address, "incentivized_erc20_allowances", [ids.amount256.low, ids.amount256.high], key=[ids.PRANK_USER1, ids.PRANK_USER2]) %}

    # Check allowance is correct
    let (allowance) = IncentivizedERC20.allowance(PRANK_USER1, PRANK_USER2)
    let (is_the_allowance_expected) = uint256_eq(amount256, allowance)
    assert is_the_allowance_expected = TRUE

    return ()
end

@external
func test_increase_allowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (local contract_address) = get_contract_address()

    # Set an allowance
    let (local amount256) = to_uint_256(AMOUNT)
    %{ store(ids.contract_address, "incentivized_erc20_allowances", [ids.amount256.low, ids.amount256.high], key=[ids.PRANK_USER1, ids.PRANK_USER2]) %}

    let (new_allowance) = SafeUint256.add(amount256, amount256)

    # Increase it AMMOUNT
    %{ stop_prank_callable = start_prank(ids.PRANK_USER1) %}
    %{ expect_events({"name": "Approval", "data": [ids.PRANK_USER1, ids.PRANK_USER2, ids.new_allowance.low, ids.new_allowance.high]}) %}
    IncentivizedERC20.increase_allowance(PRANK_USER2, amount256)
    %{ stop_prank_callable() %}

    # Check allowance
    let (allowance) = IncentivizedERC20.allowance(PRANK_USER1, PRANK_USER2)
    let (is_the_allowance_expected) = uint256_eq(new_allowance, allowance)
    assert is_the_allowance_expected = TRUE

    return ()
end

@external
func test_decrease_allowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (local contract_address) = get_contract_address()

    # Set an allowance
    let (local amount256) = to_uint_256(AMOUNT)
    %{ store(ids.contract_address, "incentivized_erc20_allowances", [ids.amount256.low, ids.amount256.high], key=[ids.PRANK_USER1, ids.PRANK_USER2]) %}

    # Zero
    let new_allowance : Uint256 = SafeUint256.sub_le(amount256, amount256)

    # Decrease it AMMOUNT
    %{ stop_prank_callable = start_prank(ids.PRANK_USER1) %}
    %{ expect_events({"name": "Approval", "data": [ids.PRANK_USER1, ids.PRANK_USER2, ids.new_allowance.low, ids.new_allowance.high]}) %}
    IncentivizedERC20.decrease_allowance(PRANK_USER2, amount256)
    %{ stop_prank_callable() %}

    # Check allowance
    let (allowance) = IncentivizedERC20.allowance(PRANK_USER1, PRANK_USER2)
    let (is_the_allowance_expected) = uint256_eq(new_allowance, allowance)
    assert is_the_allowance_expected = TRUE

    return ()
end
