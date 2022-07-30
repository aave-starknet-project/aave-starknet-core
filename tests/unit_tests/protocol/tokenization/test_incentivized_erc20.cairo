%lang starknet
from contracts.interfaces.i_incentivized_erc20 import IIncentivizedERC20

const PRANK_USER1 = 123
const PRANK_USER2 = 456

@external
func test_assert_only_pool_admin{syscall_ptr : felt*, range_check_ptr}():
    return ()
end
