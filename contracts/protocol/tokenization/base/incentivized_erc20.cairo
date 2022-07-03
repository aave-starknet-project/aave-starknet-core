%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.bool import TRUE
from contracts.protocol.tokenization.base.incentivized_erc20_library import IncentivizedERC20Library

# @param pool The reference to the main Pool contract
# @param name The name of the token
# @param symbol The symbol of the token
# @param decimals The number of decimals of the token

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    pool : felt, name : felt, symbol : felt, decimals : felt
):
    IncentivizedERC20Library.initialize(pool, name, symbol, decimals)
    return ()
end

# getters

@view
func name{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (name : felt):
    let (name) = IncentivizedERC20Library.name()
    return (name)
end

@view
func symbol{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (symbol : felt):
    let (symbol) = IncentivizedERC20Library.symbol()
    return (symbol)
end

@view
func decimals{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    decimals : felt
):
    let (decimals) = IncentivizedERC20Library.decimals()
    return (decimals)
end

@view
func totalSupply{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    totalSupply : Uint256
):
    let (totalSupply : Uint256) = IncentivizedERC20Library.totalSupply()
    return (totalSupply)
end

@view
func balanceOf{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    account : felt
) -> (balance : felt):
    let (balance) = IncentivizedERC20Library.balanceOf(account)
    return (balance)
end

# returns the address of the IncentivesController
@view
func getIncentivesController{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ) -> (incentives_controller : felt):
    let (incentives_controller) = IncentivizedERC20Library.getIncentivesController()
    return (incentives_controller)
end

@view
func allowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    owner : felt, spender : felt
) -> (remaining : felt):
    let (remaining) = IncentivizedERC20Library.allowance(owner, spender)
    return (remaining)
end

# setters

@external
func set_name{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(name : felt):
    IncentivizedERC20Library.set_name(name)
    return ()
end

@external
func set_symbol{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(symbol : felt):
    IncentivizedERC20Library.set_symbol(symbol)
    return ()
end

@external
func set_decimals{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    decimals : felt
):
    IncentivizedERC20Library.set_decimals(decimals)
    return ()
end

# @TODO: set onlyPoolAdmin modifier
@external
func set_incentives_controller{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    IAaveIncentivesController : felt
):
    IncentivizedERC20Library.set_incentives_controller(IAaveIncentivesController)
    return ()
end

# @TODO:set a modifier
@external
func increase_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    address : felt, amount : felt
):
    IncentivizedERC20Library.increase_balance(address, amount)
    return ()
end

# @TODO:set a modifier
@external
func decrease_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    address : felt, amount : felt
):
    IncentivizedERC20Library.decrease_balance(address, amount)
    return ()
end

# Amount is passed as Uint256 but only Uint256.low is passed to _transfer
@external
func transfer{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    recipient : felt, amount : Uint256
) -> (success : felt):
    IncentivizedERC20Library.transfer(recipient, amount)
    return (TRUE)
end

# Amount is passed as Uint256 but only Uint256.low used
@external
func transferFrom{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    sender : felt, recipient : felt, amount : Uint256
) -> (success : felt):
    IncentivizedERC20Library.transferFrom(sender, recipient, amount)
    return (TRUE)
end

# Amount is passed as Uint256 but only .low is used
@external
func approve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    spender : felt, amount : Uint256
) -> ():
    IncentivizedERC20Library.approve(spender, amount)
    return ()
end

@external
func increaseAllowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    spender : felt, amount : Uint256
) -> (success : felt):
    IncentivizedERC20Library.increaseAllowance(spender, amount)
    return (TRUE)
end

@external
func decreaseAllowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    spender : felt, amount : Uint256
) -> (success : felt):
    IncentivizedERC20Library.decreaseAllowance(spender, amount)
    return (TRUE)
end

# Test function to be removed
@external
func create_state{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    address : felt, amount : felt, index : felt
):
    IncentivizedERC20Library.create_state(address, amount, index)
    return ()
end
