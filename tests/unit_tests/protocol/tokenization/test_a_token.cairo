%lang starknet

from starkware.cairo.common.bool import FALSE
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256

from contracts.interfaces.i_a_token import IAToken
from contracts.protocol.libraries.math.wad_ray_math import RAY
from contracts.protocol.tokenization.a_token_library import AToken

const PRANK_USER_1 = 111
const PRANK_USER_2 = 222
const NAME = 123
const SYMBOL = 456
const DECIMALS = 18
const INITIAL_SUPPLY_LOW = 1000
const INITIAL_SUPPLY_HIGH = 0
const RECIPIENT = 11
const UNDERLYING_ASSET = 22
const POOL = 33
const TREASURY = 44
const INCENTIVES_CONTROLLER = 55

@view
func test_initializer{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    let (asset_before) = AToken.UNDERLYING_ASSET_ADDRESS()
    assert asset_before = 0
    let (pool_before) = AToken.POOL()
    assert pool_before = 0

    AToken.initializer(
        POOL, TREASURY, UNDERLYING_ASSET, INCENTIVES_CONTROLLER, DECIMALS, NAME, SYMBOL
    )

    let (asset_after) = AToken.UNDERLYING_ASSET_ADDRESS()
    assert asset_after = UNDERLYING_ASSET
    let (pool_after) = AToken.POOL()
    assert pool_after = POOL
    return ()
end

@view
func test_constructor{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    AToken.initializer(
        POOL, TREASURY, UNDERLYING_ASSET, INCENTIVES_CONTROLLER, DECIMALS, NAME, SYMBOL
    )
    let (asset_after) = AToken.UNDERLYING_ASSET_ADDRESS()
    assert asset_after = UNDERLYING_ASSET
    let (pool_after) = AToken.POOL()
    assert pool_after = POOL
    return ()
end

@view
func test_balance_of{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    AToken.initializer(
        POOL, TREASURY, UNDERLYING_ASSET, INCENTIVES_CONTROLLER, DECIMALS, NAME, SYMBOL
    )
    # Prank get_caller_address to have the pool as caller then mint for USER_1
    %{ stop_prank_pool = start_prank(ids.POOL) %}
    AToken.mint(0, PRANK_USER_1, Uint256(100, 0), Uint256(RAY, 0))

    # Transfer from User_1 to User_2  and check the balances of each one
    %{ stop_mock = mock_call(ids.POOL, "get_reserve_normalized_income", [ids.RAY, 0]) %}
    let (balance_user_1) = AToken.balance_of(PRANK_USER_1)
    assert balance_user_1 = Uint256(100, 0)
    %{ stop_mock() %}

    # Close prank pool
    %{ stop_prank_pool() %}
    return ()
end

@view
func test_transfer_base{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    AToken.initializer(
        POOL, TREASURY, UNDERLYING_ASSET, INCENTIVES_CONTROLLER, DECIMALS, NAME, SYMBOL
    )
    # Prank get_caller_address to have the pool as caller then mint for USER_1
    %{ stop_prank_pool = start_prank(ids.POOL) %}
    AToken.mint(0, PRANK_USER_1, Uint256(100, 0), Uint256(RAY, 0))

    # Transfer from User_1 to User_2  and check the balances of each one
    %{ stop_mock = mock_call(ids.POOL, "get_reserve_normalized_income", [ids.RAY, 0]) %}
    AToken._transfer_base(PRANK_USER_1, PRANK_USER_2, Uint256(60, 0), FALSE)
    let (balance_user_1) = AToken.balance_of(PRANK_USER_1)
    assert balance_user_1 = Uint256(40, 0)
    let (balance_user_2) = AToken.balance_of(PRANK_USER_2)
    assert balance_user_2 = Uint256(60, 0)
    %{ stop_mock() %}

    # Close prank pool
    %{ stop_prank_pool() %}

    return ()
end
