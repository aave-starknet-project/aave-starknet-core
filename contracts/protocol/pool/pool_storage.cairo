%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin

from contracts.protocol.libraries.types.data_types import DataTypes

@storage_var
func addresses_provider() -> (address : felt):
end

@storage_var
func pool_revision() -> (address : felt):
end

# Map of reserves and their data (underlyind_asset => reserve_data)
@storage_var
func reserves(asset : felt) -> (reserve_data : DataTypes.ReserveData):
end

@storage_var
func reserves_config(asset : felt) -> (res_config : DataTypes.ReserveConfigurationMap):
end

# Map of users address and their configuration data (user_address=> userConfiguration)
@storage_var
func users_config(user_address : felt, reserve_index : felt) -> (
    user_config : DataTypes.UserConfigurationMap
):
end

# List of reserves as a map (reserve_id => address).
@storage_var
func reserves_list(reserve_id : felt) -> (address : felt):
end

# TODO List of eMode_categories

# Map of users address and their eMode category (userAddress => eModeCategoryId)
@storage_var
func users_eMode_category(address : felt) -> (category_id : felt):
end

# Fee of the protocol bridge, expressed in bps
@storage_var
func bridge_protocol_fee() -> (bps : felt):
end

# Total FlashLoan Premium, expressed in bps
@storage_var
func flash_loan_premium_total() -> (bps : felt):
end

# FlashLoan premium paid to protocol treasury, expressed in bps
@storage_var
func flash_loan_premium_to_protocol() -> (bps : felt):
end

# Available liquidity that can be borrowed at once at stable rate, expressed in bps
@storage_var
func max_stable_rate_borrow_size_percent() -> (bps : felt):
end

# Maximum number of active reserves there have been in the protocol. It is the upper bound of the reserves list
@storage_var
func reserves_count() -> (count : felt):
end

namespace PoolStorage:
    #
    # Reads
    #

    func addresses_provider_read{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ) -> (address : felt):
        let (address) = addresses_provider.read()
        return (address)
    end

    func pool_revision_read{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ) -> (revision : felt):
        let (revision) = pool_revision.read()
        return (revision)
    end

    func reserves_read{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        address : felt
    ) -> (reserve_data : DataTypes.ReserveData):
        let (reserve_data) = reserves.read(address)
        return (reserve_data)
    end

    func reserves_config_read{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        address : felt
    ) -> (res_config : DataTypes.ReserveConfigurationMap):
        let (res) = reserves_config.read(address)
        return (res)
    end

    func users_config_read{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user_address : felt, reserve_index : felt
    ) -> (user_config : DataTypes.UserConfigurationMap):
        let (user_config) = users_config.read(user_address, reserve_index)
        return (user_config)
    end

    func reserves_list_read{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_id : felt
    ) -> (address : felt):
        let (address) = reserves_list.read(reserve_id)
        return (address)
    end

    func users_eMode_category_read{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(address : felt) -> (category_id : felt):
        let (category_id) = users_eMode_category.read(address)
        return (category_id)
    end

    func bridge_protocol_fee_read{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }() -> (bps : felt):
        let (bps) = bridge_protocol_fee.read()
        return (bps)
    end

    func flash_loan_premium_total_read{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }() -> (bps : felt):
        let (bps) = flash_loan_premium_total.read()
        return (bps)
    end

    func flash_loan_premium_to_protocol_read{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }() -> (bps : felt):
        let (bps) = flash_loan_premium_to_protocol.read()
        return (bps)
    end

    func max_stable_rate_borrow_size_percent_read{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }() -> (bps : felt):
        let (bps) = max_stable_rate_borrow_size_percent.read()
        return (bps)
    end

    func reserves_count_read{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ) -> (count : felt):
        let (count) = reserves_count.read()
        return (count)
    end

    #
    # Writes
    #

    func addresses_provider_write{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(address : felt):
        addresses_provider.write(address)
        return ()
    end

    func pool_revision_write{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        revision : felt
    ):
        pool_revision.write(revision)
        return ()
    end

    func reserves_write{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        asset : felt, reserve_data : DataTypes.ReserveData
    ):
        reserves.write(asset, reserve_data)
        return ()
    end

    func reserves_config_write{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        address : felt, res_config : DataTypes.ReserveConfigurationMap
    ):
        reserves_config.write(address, res_config)
        return ()
    end

    func users_config_write{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user_address : felt, reserve_index : felt, user_config : DataTypes.UserConfigurationMap
    ):
        users_config.write(user_address, reserve_index, user_config)
        return ()
    end

    func reserves_list_write{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve_id : felt, address : felt
    ):
        reserves_list.write(reserve_id, address)
        return ()
    end

    func users_eMode_category_write{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(address : felt, category_id : felt):
        users_eMode_category.write(address, category_id)
        return ()
    end

    func bridge_protocol_fee_write{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(bps : felt):
        bridge_protocol_fee.write(bps)
        return ()
    end

    func flash_loan_premium_total_write{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(bps : felt):
        flash_loan_premium_total.write(bps)
        return ()
    end

    func flash_loan_premium_to_protocol_write{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(bps : felt):
        flash_loan_premium_to_protocol.write(bps)
        return ()
    end

    func max_stable_rate_borrow_size_percent_write{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(bps : felt):
        max_stable_rate_borrow_size_percent.write(bps)
        return ()
    end

    func reserve_count_write{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        count : felt
    ):
        reserves_count.write(count)
        return ()
    end
end
