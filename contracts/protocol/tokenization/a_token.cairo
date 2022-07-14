%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE
from starkware.cairo.common.uint256 import Uint256

from openzeppelin.token.erc20.interfaces.IERC20 import IERC20
from openzeppelin.token.erc20.library import ERC20
from contracts.protocol.tokenization.base.incentivized_erc20_library import IncentivizedERC20, MintableIncentivizedERC20
from contracts.protocol.tokenization.base.scaled_balance_token_library import ScaledBalanceTokenBase
from contracts.protocol.tokenization.a_token_library import AToken

#
# Constructor
#

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    pool : felt,
    treasury : felt,
    underlying_asset : felt,
    incentives_controller : felt,
    a_token_decimals : felt,
    a_token_name : felt,
    a_token_symbol : felt,
):
    AToken.initializer(
        pool,
        treasury,
        underlying_asset,
        incentives_controller,
        a_token_decimals,
        a_token_name,
        a_token_symbol,
    )
    return ()
end

#
# Getters
#

@view
func name{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (name : felt):
    let (name) = IncentivizedERC20.name()
    return (name)
end

@view
func symbol{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (symbol : felt):
    let (symbol) = IncentivizedERC20.symbol()
    return (symbol)
end

@view
func totalSupply{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    totalSupply : Uint256
):
    let (totalSupply : Uint256) = IncentivizedERC20.total_supply()
    return (totalSupply)
end

@view
func decimals{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    decimals : felt
):
    let (decimals) = IncentivizedERC20.decimals()
    return (decimals)
end

# @view
# func balanceOf{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
#     account : felt
# ) -> (balance : Uint256):
#     let (balance) = IncentivizedERC20.balance_of(account)
#     return (balance)
# end


# @view
# func allowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
#     owner : felt, spender : felt
# ) -> (remaining : Uint256):
#     let (remaining : Uint256) = IncentivizedERC20.allowance(owner, spender)
#     return (remaining)
# end


#Return felt
@view
func balanceOf{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    account : felt
) -> (balance : felt):
    let (balance) = IncentivizedERC20.balance_of(account)
    return (balance)
end

#Return felt
@view
func allowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    owner : felt, spender : felt
) -> (remaining : felt):
    let (remaining) = IncentivizedERC20.allowance(owner, spender)
    return (remaining)
end



@view
func RESERVE_TREASURY_ADDRESS{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ) -> (res : felt):
    let (res) = AToken.RESERVE_TREASURY_ADDRESS()
    return (res)
end




@view
func UNDERLYING_ASSET_ADDRESS{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ) -> (res : felt):
    let (res) = AToken.UNDERLYING_ASSET_ADDRESS()
    return (res)
end


@view
func POOL{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (res : felt):
    let (res) = AToken.POOL()
    return (res)
end

#
# Externals
#

@external
func transfer{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    recipient : felt, amount : Uint256
) -> (success : felt):
    IncentivizedERC20.transfer(recipient, amount)
    return (TRUE)
end

@external
func transferFrom{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    sender : felt, recipient : felt, amount : Uint256
) -> (success : felt):
    IncentivizedERC20.transfer_from(sender, recipient, amount)
    return (TRUE)
end

@external
func approve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    spender : felt, amount : Uint256
) -> (success : felt):
    IncentivizedERC20.approve(spender, amount)
    return (TRUE)
end

@external
func increaseAllowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    spender : felt, added_value : Uint256
) -> (success : felt):
    IncentivizedERC20.increase_allowance(spender, added_value)
    return (TRUE)
end

@external
func decreaseAllowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    spender : felt, subtracted_value : Uint256
) -> (success : felt):
    IncentivizedERC20.decrease_allowance(spender, subtracted_value)
    return (TRUE)
end

@external
func mint{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt, on_behalf_of : felt, amount : Uint256, index : Uint256
) -> (success : felt):
    AToken.mint(caller, on_behalf_of, amount, index)
    return (TRUE)
end

@external
func burn{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(from_ : felt, receiver_or_underlying : felt, amount : Uint256, index : Uint256) -> (success: felt):
    AToken.burn(from_, receiver_or_underlying, amount, index)
    return (TRUE)
end



# TODO: remove this once AToken.burn works
# @external
# func burn{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
#     from_ : felt, receiver_or_underlying : felt, amount : Uint256, index : Uint256
# ) -> (success : felt):
#     alloc_locals
#     let (local underlying) = AToken.UNDERLYING_ASSET_ADDRESS()
#     ERC20._burn(from_, amount)
#     IERC20.transfer(underlying, receiver_or_underlying, amount)
#     return (TRUE)
# end



@external
func mint_to_treasury{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(amount : Uint256, index : Uint256) -> (success: felt):
    AToken.mint_to_treasury(amount, index)
    return (TRUE)
end

@external
func transfer_on_liquidation{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    from_ : felt, to : felt, value : Uint256
):
    AToken.transfer_on_liquidation(from_, to, value)
    return ()
end

@external
func transfer_underlying_to{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    target : felt, amount : Uint256
):
    AToken.transfer_underlying_to(target, amount)
    return ()
end

# @external
# func handle_repayment{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(token : felt, to : felt, amount : Uint256):
#     AToken.handle_repayment(token, to, amount)
#     return ()
# end

# @external
# func permit{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(token : felt, to : felt, amount : Uint256):
#     AToken.permit(token, to, amount)
#     return ()
# end

@external
func rescue_tokens{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token : felt, to : felt, amount : Uint256
):
    AToken.rescue_tokens(token, to, amount)
    return ()
end
