%lang starknet

namespace ReserveConfiguration:
    const MAX_RESERVES_COUNT = 128

    func GET_MAX_RESERVES_COUNT{syscall_ptr : felt*, range_check_ptr}() -> (
        count : felt
    ):
        return (MAX_RESERVES_COUNT)
    end
end