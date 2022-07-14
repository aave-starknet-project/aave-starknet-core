%lang starknet

from starkware.starknet.common.syscalls import get_caller_address, get_contract_address
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import assert_not_equal
from starkware.cairo.common.uint256 import Uint256

from openzeppelin.token.erc20.library import ERC20
from openzeppelin.token.erc20.interfaces.IERC20 import IERC20

from contracts.interfaces.i_ACL_manager import IACLManager
from contracts.interfaces.i_pool import IPool
from contracts.interfaces.i_pool_addresses_provider import IPoolAddressesProvider
from contracts.protocol.libraries.helpers.bool_cmp import BoolCompare
from contracts.protocol.libraries.logic.configurator_logic import ConfiguratorLogic
from contracts.protocol.libraries.types.configurator_input_types import ConfiguratorInputTypes

#
# Events
#

@event
func ReserveDropped(asset : felt):
end

#
# Storage
#

@storage_var
func PoolConfigurator_pool() -> (res : felt):
end

@storage_var
func PoolConfigurator_addresses_provider() -> (res : felt):
end

#
# Namespace
#

namespace PoolConfigurator:
    # Constants

    const CONFIGURATOR_REVISION = 1

    # Authorization

    func assert_only_pool_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ):
        alloc_locals
        let (caller_address) = get_caller_address()
        let (addresses_provider) = PoolConfigurator_addresses_provider.read()
        let (acl_manager) = IPoolAddressesProvider.get_ACL_manager(addresses_provider)

        with_attr error_message("Caller is not pool admin."):
            assert IACLManager.is_pool_admin(acl_manager, caller_address) = TRUE
        end

        return ()
    end

    func assert_only_emergency_admin{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        let (caller_address) = get_caller_address()
        let (addresses_provider) = PoolConfigurator_addresses_provider.read()
        let (acl_manager) = IPoolAddressesProvider.get_ACL_manager(addresses_provider)

        with_attr error_message("Caller is not emergency admin."):
            assert IACLManager.is_emergency_admin(acl_manager, caller_address) = TRUE
        end

        return ()
    end

    func assert_only_pool_or_emergency_admin{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        let (caller_address) = get_caller_address()
        let (addresses_provider) = PoolConfigurator_addresses_provider.read()
        let (acl_manager) = IPoolAddressesProvider.get_ACL_manager(addresses_provider)

        let (is_pool_or_emergency_admin) = BoolCompare.either(
            IACLManager.is_pool_admin(acl_manager, caller_address),
            IACLManager.is_emergency_admin(acl_manager, caller_address),
        )
        with_attr error_message("Caller is not emergency or pool admin."):
            assert is_pool_or_emergency_admin = TRUE
        end

        return ()
    end

    func assert_only_asset_listing_or_pool_admins{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        let (caller_address) = get_caller_address()
        let (addresses_provider) = PoolConfigurator_addresses_provider.read()
        let (acl_manager) = IPoolAddressesProvider.get_ACL_manager(addresses_provider)

        let (is_asset_listing_or_pool_admin) = BoolCompare.either(
            IACLManager.is_pool_admin(acl_manager, caller_address),
            IACLManager.is_asset_listing_admin(acl_manager, caller_address),
        )
        with_attr error_message("Caller is not asset listing or pool admin."):
            assert is_asset_listing_or_pool_admin = TRUE
        end

        return ()
    end

    func assert_only_risk_or_pool_admins{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        let (caller_address) = get_caller_address()
        let (addresses_provider) = PoolConfigurator_addresses_provider.read()
        let (acl_manager) = IPoolAddressesProvider.get_ACL_manager(addresses_provider)

        let (is_risk_or_pool_admin) = BoolCompare.either(
            IACLManager.is_pool_admin(acl_manager, caller_address),
            IACLManager.is_risk_admin(acl_manager, caller_address),
        )
        with_attr error_message("Caller is not risk or pool admin."):
            assert is_risk_or_pool_admin = TRUE
        end

        return ()
    end

    # Externals

    func initialize{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        provider : felt
    ):
        PoolConfigurator_addresses_provider.write(provider)
        let (pool) = IPoolAddressesProvider.get_pool(provider)
        PoolConfigurator_pool.write(pool)
        return ()
    end

    func init_reserves{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        input_len : felt, input : ConfiguratorInputTypes.InitReserveInput*
    ):
        assert_only_asset_listing_or_pool_admins()
        let (pool) = PoolConfigurator_pool.read()
        _init_reserves_inner(pool, input_len, input)
        return ()
    end

    func drop_reserve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        asset : felt
    ):
        assert_only_pool_admin()
        let (pool) = PoolConfigurator_pool.read()
        IPool.drop_reserve(pool, asset)
        ReserveDropped.emit(asset)
        return ()
    end

    func update_a_token{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        input : ConfiguratorInputTypes.UpdateATokenInput
    ):
        assert_only_pool_admin()
        let (pool) = PoolConfigurator_pool.read()
        ConfiguratorLogic.execute_update_a_token(pool, input)
        return ()
    end

    func update_stable_debt_token{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(input : ConfiguratorInputTypes.UpdateATokenInput):
        assert_only_pool_admin()
        let (pool) = PoolConfigurator_pool.read()
        ConfiguratorLogic.execute_update_stable_debt_token(pool, input)
        return ()
    end

    func update_variable_debt_token{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(input : ConfiguratorInputTypes.UpdateATokenInput):
        assert_only_pool_admin()
        let (pool) = PoolConfigurator_pool.read()
        ConfiguratorLogic.execute_update_variable_debt_token(pool, input)
        return ()
    end

    func _init_reserves_inner{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        pool : felt, input_len : felt, input : ConfiguratorInputTypes.InitReserveInput*
    ):
        if input_len == 0:
            return ()
        end
        ConfiguratorLogic.execute_init_reserve(pool, [input])
        _init_reserves_inner(
            pool, input_len - 1, input + ConfiguratorInputTypes.InitReserveInput.SIZE
        )
        return ()
    end
end
