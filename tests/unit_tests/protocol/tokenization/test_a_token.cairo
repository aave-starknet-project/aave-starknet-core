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
func __setup__{syscall_ptr : felt*, range_check_ptr}():
    %{
        context.pool = deploy_contract("./contracts/protocol/pool/pool.cairo", {"provider":0}).contract_address
        context.token = deploy_contract("./lib/cairo_contracts/src/openzeppelin/token/erc20/ERC20.cairo", {"name":ids.NAME,"symbol": ids.SYMBOL,"decimals": ids.DECIMALS,"initial_supply":{"low": 1000,"high": 0}, "recipient":ids.PRANK_USER_1}).contract_address

        context.a_token = deploy_contract("./contracts/protocol/tokenization/a_token.cairo", {"pool":ids.POOL,"treasury":ids.TREASURY,"underlying_asset":ids.UNDERLYING_ASSET,"incentives_controller":ids.INCENTIVES_CONTROLLER, "a_token_decimals":ids.DECIMALS,"a_token_name":ids.NAME+1,"a_token_symbol":ids.SYMBOL+1}).contract_address
    %}
    return ()
end

func get_contract_addresses() -> (
    pool_address : felt, token_address : felt, a_token_address : felt
):
    tempvar pool
    tempvar token
    tempvar a_token
    %{ ids.pool = context.pool %}
    %{ ids.token = context.token %}
    %{ ids.a_token = context.a_token %}
    return (pool, token, a_token)
end

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
    alloc_locals
    let (local pool, local token, local a_token) = get_contract_addresses()

    let (asset_after) = IAToken.UNDERLYING_ASSET_ADDRESS(a_token)
    assert asset_after = UNDERLYING_ASSET
    let (pool_after) = IAToken.POOL(a_token)
    assert pool_after = POOL
    return ()
end

@view
func test_balance_of{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    let (local pool, local token, local a_token) = get_contract_addresses()

    AToken.initializer(pool, TREASURY, token, INCENTIVES_CONTROLLER, DECIMALS, NAME, SYMBOL)

    AToken.mint(0, PRANK_USER_1, Uint256(100, 0), Uint256(RAY, 0))

    %{ stop_mock = mock_call(ids.pool, "get_reserve_normalized_income", [ids.RAY, 0]) %}
    let (balance_prank_user_1) = AToken.balance_of(PRANK_USER_1)
    assert balance_prank_user_1 = Uint256(100, 0)
    %{ stop_mock() %}

    %{ stop_mock = mock_call(ids.pool, "get_reserve_normalized_income", [2 * ids.RAY, 0]) %}
    let (balance_prank_user_1) = AToken.balance_of(PRANK_USER_1)
    assert balance_prank_user_1 = Uint256(200, 0)
    %{ stop_mock() %}

    return ()
end

@view
func test_transfer_base{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    let (local pool, local token, local a_token) = get_contract_addresses()

    AToken.initializer(pool, TREASURY, token, INCENTIVES_CONTROLLER, DECIMALS, NAME, SYMBOL)

    AToken.mint(0, PRANK_USER_1, Uint256(100, 0), Uint256(RAY, 0))

    %{ stop_mock = mock_call(ids.pool, "get_reserve_normalized_income", [2 * ids.RAY, 0]) %}

    let (balance_prank_user_1) = AToken.balance_of(PRANK_USER_1)
    assert balance_prank_user_1 = Uint256(200, 0)

    AToken._transfer_base(PRANK_USER_1, PRANK_USER_2, Uint256(50, 0), FALSE)

    let (balance_prank_user_1) = AToken.balance_of(PRANK_USER_1)
    let (balance_prank_user_2) = AToken.balance_of(PRANK_USER_2)
    assert balance_prank_user_1 = Uint256(150, 0)
    assert balance_prank_user_2 = Uint256(50, 0)

    %{ stop_mock() %}

    return ()
end
