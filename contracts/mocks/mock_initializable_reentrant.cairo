%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math_cmp import is_le

from contracts.mocks.mock_initializable_implementation_library import (
    MockInitializableReentrant,
    MockInitializableImplementation,
)

@external
func initialize{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(val : felt):
    MockInitializableReentrant.initialize(val)
    return ()
end

@view
func get_revision{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    revision : felt
):
    return MockInitializableReentrant.get_revision()
end
