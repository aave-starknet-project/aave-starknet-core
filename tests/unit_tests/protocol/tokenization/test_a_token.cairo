%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256

from contracts.protocol.tokenization.a_token_library import AToken

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

# @view
# func test_deployment{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
#     alloc_locals
#     local contract_address : felt
#     # We deploy contract and put its address into a local variable. Second argument is calldata array
#     %{ ids.contract_address = deploy_contract("./contracts/protocol/tokenization/a_token.cairo", [ids.POOL, ids.TREASURY, ids.UNDERLYING_ASSET, ids.INCENTIVES_CONTROLLER, ids.DECIMALS, ids.NAME, ids.SYMBOL]).contract_address %}

# let (asset_after) = AToken.UNDERLYING_ASSET_ADDRESS()
#     assert asset_after = UNDERLYING_ASSET
#     let (pool_after) = AToken.POOL()
#     assert pool_after = POOL
#     return ()
# end
