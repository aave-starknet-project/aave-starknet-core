%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from contracts.interfaces.i_pool import IPool

const PRANK_USER = 123
const MOCK_ASSET_1 = 12345
const MOCK_A_TOKEN_1 = 54321
const MOCK_ASSET_2 = 67890
const MOCK_A_TOKEN_2 = 09876

# Setup a test with an active reserve for test_token
@view
func __setup__{syscall_ptr : felt*, range_check_ptr}():
    %{
        context.pool = deploy_contract("./contracts/protocol/pool/pool.cairo",[0]).contract_address

        #PRANK_USER receives 1000 test_token
        context.test_token = deploy_contract("./tests/contracts/ERC20.cairo", [1415934836,5526356,18,1000,0,ids.PRANK_USER]).contract_address 

        context.a_token = deploy_contract("./contracts/protocol/tokenization/a_token.cairo", [418027762548,1632916308,18,0,0,context.pool,context.pool,context.test_token]).contract_address
    %}
    tempvar pool
    tempvar test_token
    tempvar a_token
    %{ ids.pool = context.pool %}
    %{ ids.test_token = context.test_token %}
    %{ ids.a_token = context.a_token %}
    _init_reserve(pool, test_token, a_token)
    return ()
end

func get_contract_addresses() -> (
    contract_address : felt, test_token_address : felt, a_token_address : felt
):
    tempvar pool
    tempvar test_token
    tempvar a_token
    %{ ids.pool = context.pool %}
    %{ ids.test_token = context.test_token %}
    %{ ids.a_token = context.a_token %}
    return (pool, test_token, a_token)
end

@view
func test_init_reserve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (local pool, local test_token, local a_token) = get_contract_addresses()
    _init_reserve(pool, MOCK_ASSET_1, MOCK_A_TOKEN_1)
    let (reserve) = IPool.get_reserve_data(pool, MOCK_ASSET_1)

    assert reserve.id = 1
    assert reserve.a_token_address = MOCK_A_TOKEN_1
    assert reserve.liquidity_index = 1 * 10 ** 27

    let (assets_len, assets) = IPool.get_reserves_list(pool)
    assert assets_len = 2
    assert assets[0] = test_token
    assert assets[1] = MOCK_ASSET_1

    return ()
end

# Tests when a reserve is initialized but not appended to the list
@view
func test_init_reserve_insert{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (local pool, local test_token, local a_token) = get_contract_addresses()

    # initialize first reserve with id = 1
    _init_reserve(pool, MOCK_ASSET_1, MOCK_A_TOKEN_1)
    let (reserve) = IPool.get_reserve_data(pool, MOCK_ASSET_1)
    assert reserve.id = 1
    assert reserve.a_token_address = MOCK_A_TOKEN_1
    # Drop the first reserve
    %{ stop_mock = mock_call(ids.a_token, "totalSupply", [0,0]) %}
    _drop_reserve(pool, test_token, a_token)
    %{ stop_mock() %}

    let (assets_len, assets) = IPool.get_reserves_list(pool)
    assert assets_len = 1
    assert assets[0] = MOCK_ASSET_1

    # Initialize second reserve, id must be 0 since reserve with id = 0 was dropped
    # New reserve's position in list must be 0 since it was inserted and not appended
    # And reserves_count is still 2
    _init_reserve(pool, MOCK_ASSET_2, MOCK_A_TOKEN_2)
    let (reserve) = IPool.get_reserve_data(pool, MOCK_ASSET_2)
    assert reserve.id = 0
    assert reserve.a_token_address = MOCK_A_TOKEN_2

    let (assets_len, assets) = IPool.get_reserves_list(pool)
    assert assets_len = 2
    assert assets[0] = MOCK_ASSET_2
    assert assets[1] = MOCK_ASSET_1

    return ()
end

@view
func test_reserve_already_added{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ):
    alloc_locals
    let (local pool, local test_token, local a_token) = get_contract_addresses()
    %{ expect_revert(error_message="Reserve already initialized") %}
    _init_reserve(pool, test_token, a_token)
    return ()
end

@view
func test_drop_reserve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (local pool, local test_token, local a_token) = get_contract_addresses()
    _drop_reserve(pool, test_token, a_token)

    let (reserve) = IPool.get_reserve_data(pool, test_token)

    assert reserve.id = 0
    assert reserve.a_token_address = 0
    assert reserve.liquidity_index = 0

    return ()
end

@view
func test_drop_reserve_not_listed{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    alloc_locals
    let (local pool, _, _) = get_contract_addresses()

    %{ expect_revert(error_message="Asset is not listed") %}
    _drop_reserve(pool, MOCK_ASSET_1, MOCK_A_TOKEN_1)
    return ()
end

@view
func test_drop_reserve_a_token_not_zero{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    alloc_locals
    let (local pool, local test_token, local a_token) = get_contract_addresses()

    %{ stop_mock = mock_call(ids.a_token, "totalSupply", [100,0]) %}
    %{ expect_revert(error_message="AToken supply is not zero") %}
    _drop_reserve(pool, test_token, a_token)
    %{ stop_mock() %}
    return ()
end

func _init_reserve{syscall_ptr : felt*, range_check_ptr}(
    pool : felt, test_token : felt, a_token : felt
):
    IPool.init_reserve(pool, test_token, a_token)
    return ()
end

func _drop_reserve{syscall_ptr : felt*, range_check_ptr}(
    pool : felt, test_token : felt, a_token : felt
):
    IPool.drop_reserve(pool, test_token)

    return ()
end
