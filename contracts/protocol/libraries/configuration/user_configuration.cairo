%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
# from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.math import assert_lt, assert_not_zero
from starkware.cairo.common.math_cmp import is_not_zero, is_le
from starkware.cairo.common.bool import TRUE, FALSE

from contracts.protocol.pool.pool_storage import PoolStorage

namespace UserConfiguration:
    # @notice Sets if the user is borrowing the reserve identified by reserveIndex
    func set_borrowing{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user_address : felt, reserve_index : felt, borrowing : felt
    ):
        alloc_locals

        assert_not_zero(reserve_index)
        assert_lt(borrowing, 2)  # only TURE/FALSE values

        let (local current) = UserConfiguration_borrowing_counter.read(user_address)

        if borrowing == TRUE:
            UserConfiguration_borrowing_counter.write(user_address, current + 1)
        else:
            assert_not_zero(current)
            UserConfiguration_borrowing_counter.write(user_address, current - 1)
        end

        UserConfiguration_borrowing.write(user_address, reserve_index, borrowing)

        return ()
    end

    func set_using_as_collateral{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user_address : felt, reserve_index : felt, using_as_collateral : felt
    ):
        alloc_locals

        assert_not_zero(reserve_index)
        assert_lt(using_as_collateral, 2)  # only TURE/FALSE values

        let (local current) = UserConfiguration_collateral_counter.read(user_address)

        if using_as_collateral == TRUE:
            UserConfiguration_collateral_counter.write(user_address, current + 1)
        else:
            assert_not_zero(current)
            UserConfiguration_collateral_counter.write(user_address, current - 1)
        end

        UserConfiguration_using_as_collateral.write(
            user_address, reserve_index, using_as_collateral
        )

        return ()
    end

    func is_borrowing{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user_address : felt, reserve_index : felt
    ) -> (res : felt):
        let (res) = UserConfiguration_borrowing.read(user_address, reserve_index)
        return (res)
    end

    func is_using_as_collateral{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user_address : felt, reserve_index : felt
    ) -> (res : felt):
        let (res) = UserConfiguration_using_as_collateral.read(user_address, reserve_index)
        return (res)
    end

    func is_using_as_collateral_or_borrowing{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(user_address : felt, reserve_index : felt) -> (res : felt):
        let (res_col) = UserConfiguration_using_as_collateral.read(user_address, reserve_index)
        let (is_not_zero_col) = is_not_zero(res_col)
        if is_not_zero_col == TRUE:
            return (TRUE)
        end

        let (res_bor) = UserConfiguration_borrowing.read(user_address, reserve_index)
        let (is_not_zero_bor) = is_not_zero(res_bor)
        if is_not_zero_bor == TRUE:
            return (TRUE)
        end

        return (FALSE)
    end

    # TODO: GOT ERROR  Cannot unpack not_zero + less_than_2. let (cmp_res) = not_zero + less_than_2
    # func is_using_as_collateral_one{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    #     user_address : felt
    # ) -> (res : felt):

    # let (col) = UserConfiguration_collateral_counter.read(user_address)
    #     let (not_zero) = is_not_zero(col)
    #     let (less_than_2) = is_le(col, 1)
    #     let (cmp_res) = not_zero + less_than_2

    # if cmp_res == 2:
    #         return(TRUE)
    #     else:
    #         return(FALSE)
    #     end
    # end

    # func is_using_as_collateral_any{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    #     user_address : felt
    # ) -> (res : felt):
    #     let (col) = UserConfiguration_collateral_counter.read(user_address)
    #     let (not_zero) = is_not_zero(col)

    # if not_zero == TRUE:
    #         return(TRUE)
    #     else:
    #         return(FALSE)
    #     end
    # end

    func is_borrowing_one{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user_address : felt
    ) -> (res : felt):
        let (bor) = UserConfiguration_borrowing_counter.read(user_address)
        let (not_zero) = is_not_zero(bor)
        let (less_than_2) = is_le(bor, 1)
        let (cmp_res) = not_zero + less_than_2

        if cmp_res == 2:
            return (TRUE)
        else:
            return (FALSE)
        end
    end

    func is_borrowing_any{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user_address : felt
    ) -> (res : felt):
        let (bor) = UserConfiguration_borrowing_counter.read(user_address)
        let (not_zero) = is_not_zero(bor)

        if not_zero == TRUE:
            return (TRUE)
        else:
            return (FALSE)
        end
    end

    # TODO
    # func is_empty{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    #     user_address : felt
    # ) -> (res : felt):

    # let (bor) = is_borrowing_one(user_address)

    # let (col) = is_using_as_collateral_one(user_address)

    # let (is_it_empty) = bor + col

    # if is_it_empty == 0:
    #         return(TRUE)
    #     else:
    #         return(FALSE)
    #     end
    # end
end

# @note using prefix UserConfiguration to prevent storage variable clashing
@storage_var
func UserConfiguration_borrowing(user_address : felt, reserve_id : felt) -> (res : felt):
end

@storage_var
func UserConfiguration_using_as_collateral(user_address : felt, reserve_id : felt) -> (res : felt):
end

@storage_var
func UserConfiguration_borrowing_counter(user_address : felt) -> (res : felt):
end

@storage_var
func UserConfiguration_collateral_counter(user_address : felt) -> (res : felt):
end
