%lang starknet

from starkware.cairo.common.bool import FALSE, TRUE
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_eq, uint256_add
from starkware.starknet.common.syscalls import get_contract_address

from openzeppelin.security.safemath import SafeUint256

from contracts.protocol.libraries.math.helpers import to_uint_256
from contracts.protocol.libraries.types.data_types import DataTypes
from contracts.protocol.tokenization.base.incentivized_erc20_library import IncentivizedERC20
from tests.utils.constants import (
    ACL_MANAGER,
    AMOUNT_1,
    INCENTIVES_CONTROLLER,
    POOL,
    POOL_ADDRESSES_PROVIDER,
    USER_1,
    USER_2,
    USER_3,
)

func store_external_contracts{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (contract_address) = get_contract_address()
    %{
        store(ids.contract_address, "incentivized_erc20_pool",[ids.POOL]) 
        store(ids.contract_address, "incentivized_erc20_incentives_controller",[ids.INCENTIVES_CONTROLLER]) 
        store(ids.contract_address, "incentivized_erc20_addresses_provider",[ids.POOL_ADDRESSES_PROVIDER])
    %}
    return ()
end

func mock_is_pool_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    %{
        stop_mock_1 = mock_call(ids.POOL_ADDRESSES_PROVIDER, "get_ACL_manager", [ids.ACL_MANAGER])
        stop_mock_2 = mock_call(ids.ACL_MANAGER, "is_pool_admin", [ids.TRUE])
    %}
    return ()
end

func mock_is_not_pool_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    %{
        stop_mock_1 = mock_call(ids.POOL_ADDRESSES_PROVIDER, "get_ACL_manager", [ids.ACL_MANAGER])
        stop_mock_2 = mock_call(ids.ACL_MANAGER, "is_pool_admin", [ids.FALSE])
    %}
    return ()
end

@external
func test_balance_of{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (local contract_address) = get_contract_address()

    # Mock balance
    tempvar user_state = DataTypes.UserState(balance=AMOUNT_1, additional_data=0)
    %{ store(ids.contract_address, "incentivized_erc20_user_state", [ids.user_state.balance, ids.user_state.additional_data], key=[ids.USER_1]) %}

    let (balance) = IncentivizedERC20.balance_of(USER_1)
    assert balance = AMOUNT_1

    return ()
end

@external
func test_transfer{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (local contract_address) = get_contract_address()
    let (local amount256) = to_uint_256(AMOUNT_1)

    tempvar user_state = DataTypes.UserState(balance=AMOUNT_1, additional_data=0)
    %{ store(ids.contract_address, "incentivized_erc20_user_state", [ids.user_state.balance, ids.user_state.additional_data], key=[ids.USER_1]) %}

    # Amount sent
    %{ stop_prank_callable = start_prank(ids.USER_1) %}
    %{ expect_events({"name": "Transfer", "data": [ids.USER_1, ids.USER_2, ids.amount256.low, ids.amount256.high]}) %}
    IncentivizedERC20.transfer(USER_2, amount256)
    %{ stop_prank_callable() %}

    # Check amount was received
    tempvar receiver_user_state : DataTypes.UserState
    %{ (ids.receiver_user_state.balance, ids.receiver_user_state.additional_data) = load(ids.contract_address, "incentivized_erc20_user_state", "UserState", key=[ids.USER_2]) %}
    assert receiver_user_state.balance = AMOUNT_1

    # Check sender balance
    tempvar after_send_user_state : DataTypes.UserState
    %{ (ids.after_send_user_state.balance, ids.after_send_user_state.additional_data) = load(ids.contract_address, "incentivized_erc20_user_state", "UserState", key=[ids.USER_1]) %}
    assert after_send_user_state.balance = 0

    # Do not let transfer more than balance
    %{ stop_prank_callable = start_prank(ids.USER_1) %}
    %{ expect_revert(error_message="IncentivizedERC20: transfer amount exceeds balance") %}
    IncentivizedERC20.transfer(USER_2, amount256)
    %{ stop_prank_callable() %}

    return ()
end

@external
func test_transfer_from{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (local contract_address) = get_contract_address()

    # Set balances and allowances
    tempvar user_state = DataTypes.UserState(balance=AMOUNT_1, additional_data=0)
    %{ store(ids.contract_address, "incentivized_erc20_user_state", [ids.user_state.balance, ids.user_state.additional_data], key=[ids.USER_2]) %}
    let (local amount256) = to_uint_256(AMOUNT_1)

    %{ store(ids.contract_address, "incentivized_erc20_allowances", [ids.amount256.low, ids.amount256.high], key=[ids.USER_2, ids.USER_1]) %}

    # Amount sent
    %{ stop_prank_callable = start_prank(ids.USER_1) %}
    %{ expect_events({"name": "Transfer", "data": [ids.USER_2, ids.USER_3, ids.amount256.low, ids.amount256.high]}) %}
    IncentivizedERC20.transfer_from(USER_2, USER_3, amount256)
    %{ stop_prank_callable() %}

    # Check amount was received
    tempvar receiver_user_state : DataTypes.UserState
    %{ (ids.receiver_user_state.balance, ids.receiver_user_state.additional_data) = load(ids.contract_address, "incentivized_erc20_user_state", "UserState", key=[ids.USER_3]) %}
    assert receiver_user_state.balance = AMOUNT_1

    # Check sender balance
    tempvar after_send_user_state : DataTypes.UserState
    %{ (ids.after_send_user_state.balance, ids.after_send_user_state.additional_data) = load(ids.contract_address, "incentivized_erc20_user_state", "UserState", key=[ids.USER_2]) %}
    assert after_send_user_state.balance = 0

    # Do not let transfer more than balance
    %{ stop_prank_callable = start_prank(ids.USER_1) %}
    %{ expect_revert() %}
    IncentivizedERC20.transfer_from(USER_2, USER_2, amount256)
    %{ stop_prank_callable() %}

    return ()
end

@external
func test_approve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (local contract_address) = get_contract_address()
    let (local amount256) = to_uint_256(AMOUNT_1)

    # Approve an ammount
    %{ stop_prank_callable = start_prank(ids.USER_1) %}
    %{ expect_events({"name": "Approval", "data": [ids.USER_1, ids.USER_2, ids.amount256.low, ids.amount256.high]}) %}
    IncentivizedERC20.approve(USER_2, amount256)
    %{ stop_prank_callable() %}

    # Verify ammount was approved
    local allowance : Uint256
    %{ (ids.allowance.low, ids.allowance.high) = load(ids.contract_address, "incentivized_erc20_allowances", "Uint256", key=[ids.USER_1, ids.USER_2]) %}
    let (is_the_allowance_expected) = uint256_eq(amount256, allowance)
    assert is_the_allowance_expected = TRUE

    return ()
end

@external
func test_allowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (local contract_address) = get_contract_address()

    # Set allowance
    let (local amount256) = to_uint_256(AMOUNT_1)
    %{ store(ids.contract_address, "incentivized_erc20_allowances", [ids.amount256.low, ids.amount256.high], key=[ids.USER_1, ids.USER_2]) %}

    # Check allowance is correct
    let (allowance) = IncentivizedERC20.allowance(USER_1, USER_2)
    let (is_the_allowance_expected) = uint256_eq(amount256, allowance)
    assert is_the_allowance_expected = TRUE

    return ()
end

@external
func test_set_incentives_controller{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    alloc_locals
    let (local contract_address) = get_contract_address()
    store_external_contracts()

    # Test failure if not pool_admin
    %{ expect_revert() %}
    mock_is_not_pool_admin()
    IncentivizedERC20.set_incentives_controller(INCENTIVES_CONTROLLER)

    # Test success
    mock_is_pool_admin()
    IncentivizedERC20.set_incentives_controller(INCENTIVES_CONTROLLER)
    let (incentives_controller) = IncentivizedERC20.get_incentives_controller()
    assert INCENTIVES_CONTROLLER = incentives_controller

    return ()
end

@external
func test_increase_allowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (local contract_address) = get_contract_address()

    # Set an allowance
    let (local amount256) = to_uint_256(AMOUNT_1)
    %{ store(ids.contract_address, "incentivized_erc20_allowances", [ids.amount256.low, ids.amount256.high], key=[ids.USER_1, ids.USER_2]) %}

    let (new_allowance) = SafeUint256.add(amount256, amount256)

    # Increase it AMMOUNT
    %{ stop_prank_callable = start_prank(ids.USER_1) %}
    %{ expect_events({"name": "Approval", "data": [ids.USER_1, ids.USER_2, ids.new_allowance.low, ids.new_allowance.high]}) %}
    let (is_allowance_increased) = IncentivizedERC20.increase_allowance(USER_2, amount256)
    %{ stop_prank_callable() %}
    assert is_allowance_increased = TRUE

    # Check allowance
    let (allowance) = IncentivizedERC20.allowance(USER_1, USER_2)
    let (is_the_allowance_expected) = uint256_eq(new_allowance, allowance)
    assert is_the_allowance_expected = TRUE

    return ()
end

@external
func test_decrease_allowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (local contract_address) = get_contract_address()

    # Set an allowance
    let (local amount256) = to_uint_256(AMOUNT_1)
    %{ store(ids.contract_address, "incentivized_erc20_allowances", [ids.amount256.low, ids.amount256.high], key=[ids.USER_1, ids.USER_2]) %}

    # Zero
    let new_allowance : Uint256 = SafeUint256.sub_le(amount256, amount256)

    # Decrease it AMMOUNT
    %{ stop_prank_callable = start_prank(ids.USER_1) %}
    %{ expect_events({"name": "Approval", "data": [ids.USER_1, ids.USER_2, ids.new_allowance.low, ids.new_allowance.high]}) %}
    let (is_allowance_decreased) = IncentivizedERC20.decrease_allowance(USER_2, amount256)
    %{ stop_prank_callable() %}
    assert is_allowance_decreased = TRUE

    # Check allowance
    let (allowance) = IncentivizedERC20.allowance(USER_1, USER_2)
    let (is_the_allowance_expected) = uint256_eq(new_allowance, allowance)
    assert is_the_allowance_expected = TRUE

    return ()
end
