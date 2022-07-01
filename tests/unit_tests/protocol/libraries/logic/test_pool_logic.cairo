%lang starknet

from starkware.cairo.common.bool import TRUE, FALSE

from contracts.protocol.pool.pool_storage import PoolStorage
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_contract_address

# TODO : Requires a cheatcode to mock storage for unit testing (expected protostar v0.2.5)
