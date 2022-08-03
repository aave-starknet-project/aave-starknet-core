%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE
from starkware.cairo.common.cairo_builtins import HashBuiltin

from contracts.protocol.libraries.logic.configurator_logic import ConfiguratorLogic
from contracts.protocol.libraries.types.configurator_input_types import ConfiguratorInputTypes

const POOL = 123

@view
func test_execute_init_reserve{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    %{
        stop_mock_1 = mock_call(ids.POOL, "init_reserve", [])
        stop_mock_2 = mock_call(ids.POOL, "set_configuration", [])
    %}
    let (local input : ConfiguratorInputTypes.InitReserveInput*) = alloc()
    assert input[0] = ConfiguratorInputTypes.InitReserveInput(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1)
    ConfiguratorLogic.execute_init_reserve(POOL, [input])
    %{
        stop_mock_2()
        stop_mock_1()
    %}
    return ()
end

# @view
# func test_execute_update_a_token{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
#     return ()
# end

# @view
# func test_execute_update_stable_debt_token{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
#     return ()
# end

# @view
# func test_execute_update_variable_debt_token{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
#     return ()
# end

# @view
# func test__init_token_with_proxy{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
#     return ()
# end

# @view
# func test__upgrade_token_implementation{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
#     return ()
# end
