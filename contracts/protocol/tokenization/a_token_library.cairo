%lang starknet

from starkware.starknet.common.syscalls import get_caller_address, get_contract_address
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import assert_not_equal
from starkware.cairo.common.uint256 import Uint256

from openzeppelin.token.erc20.library import ERC20
from openzeppelin.token.erc20.interfaces.IERC20 import IERC20

from contracts.interfaces.i_pool import IPool
from contracts.protocol.libraries.helpers.bool_cmp import BoolCompare
from contracts.protocol.libraries.math.wad_ray_math import ray_mul, ray_div, Ray
# from contracts.protocol.tokenization.base.incentivized_erc20 import IncentivizedERC20
# from contracts.protocol.tokenization.base.scaled_balance_token_base import ScaledBalanceTokenBase

#
# Events
#

@event
func Transfer(from_ : felt, to : felt, value : Uint256):
end

@event
func BalanceTransfer(from_ : felt, to : felt, amount : Uint256, index : Uint256):
end

@event
func Initialized(
    underlying_asset : felt,
    pool : felt,
    treasury : felt,
    incentives_controller : felt,
    a_token_decimals : felt,
    a_token_name : felt,
    a_token_symbol : felt,
):
end

#
# Storage
#

@storage_var
func _treasury() -> (res : felt):
end

@storage_var
func _underlying_asset() -> (res : felt):
end

# should be defined in IncentivizedERC20
@storage_var
func _pool() -> (res : felt):
end

# should be defined in IncentivizedERC20
@storage_var
func _incentives_controller() -> (res : felt):
end

namespace AToken:
    # Authorization

    func assert_only_pool{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
        alloc_locals
        let (caller_address) = get_caller_address()
        let (pool) = POOL()
        with_attr error_message("Caller address should be {pool}"):
            assert caller_address = pool
        end
        return ()
    end

    func assert_only_pool_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ):
        assert TRUE = FALSE
        return ()
    end

    # Externals

    func initializer{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        pool : felt,
        treasury : felt,
        underlying_asset : felt,
        incentives_controller : felt,
        a_token_decimals : felt,
        a_token_name : felt,
        a_token_symbol : felt,
    ):
        # IncentivizedERC20.initializer(...)
        # assert pool = IncentivizedERC20.POOL()

        ERC20.initializer(a_token_name, a_token_symbol, a_token_decimals)

        _treasury.write(treasury)
        _underlying_asset.write(underlying_asset)
        _incentives_controller.write(incentives_controller)
        _pool.write(pool)

        Initialized.emit(
            underlying_asset,
            pool,
            treasury,
            incentives_controller,
            a_token_decimals,
            a_token_name,
            a_token_symbol,
        )
        return ()
    end

    # func mint{
    #         syscall_ptr : felt*,
    #         pedersen_ptr : HashBuiltin*,
    #         range_check_ptr
    #     }(caller : felt, on_behalf_of : felt, amount : Uint256, index : Uint256) -> (success: felt):
    #     assert_only_pool()
    #     ScaledBalanceTokenBase._mint_scaled(caller, on_behalf_of, amount, index);
    #     return ()
    # end

    # func burn{
    #         syscall_ptr : felt*,
    #         pedersen_ptr : HashBuiltin*,
    #         range_check_ptr
    #     }(from_ : felt, receiver_or_underlying : felt, amount : Uint256, index : Uint256) -> (success: felt):
    #     assert_only_pool()
    #     ScaledBalanceTokenBase._burn_scaled(from_, receiver_or_underlying, amount, index);
    #     let (contract_address) = get_contract_address()
    #     if (receiver_or_underlying != contract_address):
    #         IERC20.transfer(_underlying_asset.read(), receiver_or_underlying, amount)
    #     end
    #     return ()
    # end

    # func mint_to_treasury(amount : Uint256, index : Uint256) {
    #     assert_only_pool()
    #     if (amount == 0):
    #         return ()
    #     end
    #     ScaledBalanceTokenBase._mint_scaled(_POOL.read(), _treasury, amount, index)
    # end

    func transfer_on_liquidation{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        from_ : felt, to : felt, value : Uint256
    ):
        alloc_locals
        assert_only_pool()
        _transfer_base(from_, to, value, FALSE)
        Transfer.emit(from_, to, value)
        return ()
    end

    func balance_of{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user : felt
    ) -> (balance : Uint256):
        alloc_locals
        let (balance_scaled) = ERC20.balance_of(user)
        let (pool) = POOL()
        let (underlying) = UNDERLYING_ASSET_ADDRESS()
        let (liquidity_index) = IPool.get_reserve_normalized_income(pool, underlying)
        let (balance) = ray_mul(Ray(balance_scaled), Ray(liquidity_index))
        return (balance.ray)
    end

    # func total_supply{
    #     syscall_ptr : felt*,
    #     pedersen_ptr : HashBuiltin*,
    #     range_check_ptr
    # }() -> (supply : felt):
    #     let (current_supply_scaled) = IncentivizedERC20.total_supply()
    #     if current_supply_scaled == 0:
    #         return (supply=0)
    #     end
    #     let (supply) = ray_mul(current_supply_scaled, IPool.get_reserve_normalized_income(_pool.read(), _underlying_asset.read()))
    #     return (supply)
    # end

    func transfer_underlying_to{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        target : felt, amount : Uint256
    ):
        alloc_locals
        assert_only_pool()
        let (underlying) = UNDERLYING_ASSET_ADDRESS()
        IERC20.transfer(contract_address=underlying, recipient=target, amount=amount)
        return ()
    end

    # func handle_repayment{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    #     assert_only_pool()
    #     return ()
    # end

    # func permit{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # end

    func rescue_tokens{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        token : felt, to : felt, amount : Uint256
    ):
        alloc_locals
        assert_only_pool_admin()
        let (underlying) = UNDERLYING_ASSET_ADDRESS()
        with_attr error_message("Token {token} should be different from underlying {underlying}."):
            assert_not_equal(token, underlying)
        end
        IERC20.transfer(contract_address=token, recipient=to, amount=amount)
        return ()
    end

    # Getters

    func RESERVE_TREASURY_ADDRESS{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }() -> (res : felt):
        let (res) = _treasury.read()
        return (res)
    end

    func UNDERLYING_ASSET_ADDRESS{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }() -> (res : felt):
        let (res) = _underlying_asset.read()
        return (res)
    end

    func POOL{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (res : felt):
        let (res) = _pool.read()
        return (res)
    end

    # func DOMAIN_SEPARATOR{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # end

    # func nonces{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # end

    # func _EIP712BaseId{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # end

    # Internals

    func _transfer_base{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        from_ : felt, to : felt, amount : Uint256, validate : felt
    ):
        alloc_locals

        BoolCompare.is_valid(validate)

        let (pool) = POOL()
        let (underlying_asset) = UNDERLYING_ASSET_ADDRESS()
        let (index) = IPool.get_reserve_normalized_income(pool, underlying_asset)

        let (from_scaledbalance_before) = ERC20.balance_of(from_)
        let (from_balance_before) = ray_mul(Ray(from_scaledbalance_before), Ray(index))
        let (to_scaledbalance_before) = ERC20.balance_of(to)
        let (to_balance_before) = ray_mul(Ray(to_scaledbalance_before), Ray(index))

        let (amount_over_index) = ray_div(Ray(amount), Ray(index))
        ERC20._transfer(from_, to, amount_over_index.ray)

        # if validate == TRUE:
        #     IPool.finalize_transfer(
        #         pool,
        #         underlying_asset,
        #         from_,
        #         to,
        #         amount,
        #         from_balance_before.ray,
        #         to_balance_before.ray,
        #     )
        # end

        BalanceTransfer.emit(from_, to, amount, index)
        return ()
    end

    func _transfer{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        from_ : felt, to : felt, amount : Uint256
    ):
        _transfer_base(from_, to, amount, TRUE)
        return ()
    end
end
