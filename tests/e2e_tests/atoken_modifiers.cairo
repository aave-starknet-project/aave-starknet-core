%lang starknet


from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_contract_address, get_caller_address
from contracts.interfaces.i_pool import IPool
from contracts.interfaces.i_a_token import IAToken
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.bool import TRUE, FALSE
from tests.utils.constants import UNDEPLOYED_RESERVE, USER_1, USER_2
from contracts.protocol.libraries.math.wad_ray_math import RAY



# const PRANK_USER_1 = 111
# const PRANK_USER_2 = 222
# const NAME = 123
# const SYMBOL = 456
# const DECIMALS = 18
# const INITIAL_SUPPLY_LOW = 1000
# const INITIAL_SUPPLY_HIGH = 0
# const RECIPIENT = 11
# const UNDERLYING_ASSET = 22
# const POOL = 33
# const TREASURY = 44
# const INCENTIVES_CONTROLLER = 55

func get_contract_addresses() -> (
    pool_address : felt, token_address : felt, a_token_address : felt
):
    tempvar pool
    tempvar token
    tempvar a_token
    %{ ids.pool = context.pool %}
    %{ ids.token = context.dai %}
    %{ ids.a_token = context.aDAI %}
    return (pool, token, a_token)
end


namespace ATokenModifier : 

    func test_mint_wrong_pool{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
        alloc_locals
        %{ print("ATokenModifier : User tries to mint whith wrong POOL") %}
        let (_, _,local a_token) = get_contract_addresses()
        let (local_pool)  =  IAToken.POOL(a_token)
        
        
        # Right Pool calls mint
        # let (minted)      =  IAToken.mint(a_token, local_pool, USER_1, Uint256(1,0), Uint256(1,0))
        # assert minted  =  TRUE
        # %{ print("ATokenModifier : minted = " + str(ids.minted)) %}
        

        # Wrong Pool calls mint 
        let (local_caller)  =  get_caller_address()
        #%{ expect_revert(error_message="wrong caller") %}
        %{ print("ATokenModifier : a_token = " + str(ids.a_token)) %}
        %{ print("ATokenModifier : USER_1 = " + str(ids.USER_1)) %}
        %{ print("ATokenModifier : local_pool = " + str(ids.local_pool)) %}
        

        %{ stop_prank_pool = start_prank(ids.local_pool, target_contract_address = ids.a_token) %}
        let (minted_true) = IAToken.mint(a_token, local_pool, USER_1, Uint256(1,0), Uint256(1,0))
        %{ stop_prank_pool() %}
        assert minted_true  =  TRUE
        %{ print("ATokenModifier : minted = " + str(ids.minted_true)) %}
       
        %{ expect_revert(error_message="wrong caller") %}
            IAToken.mint(a_token, USER_1, USER_1, Uint256(1,0), Uint256(1,0))
        
        return()
    end

#   it('Tries to invoke burn not being the Pool (revert expected)', async () => {
#     const { deployer, aDai } = testEnv;
#     await expect(aDai.burn(deployer.address, deployer.address, '1', '1')).to.be.revertedWith(
#       CALLER_MUST_BE_POOL
#     );
#   });

func test_burn_wrong_pool{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    %{ print("ATokenModifier : User tries to mint whith wrong POOL") %}
    let (_, local token,local a_token) = get_contract_addresses()
    let (local_pool)  =  IAToken.POOL(a_token)

    # Mint so User_1 has positive balance  
    %{ print("ATokenModifier : local_pool = " + str(ids.local_pool)) %}
    %{ stop_prank_pool = start_prank(ids.local_pool, target_contract_address = ids.a_token) %}
    let (minted_true) = IAToken.mint(a_token, local_pool, USER_1,  Uint256(100, 0), Uint256(RAY, 0))
    %{ stop_prank_pool() %}
    
    #Check Balance 
    %{ stop_mock = mock_call(ids.local_pool, "get_reserve_normalized_income", [ids.RAY, 0]) %}
    let (balance_user_1) = IAToken.balanceOf(a_token, USER_1)
    assert balance_user_1 = Uint256(100, 0)
    %{ print("ATokenModifier : balance_user_1 = " + str(ids.balance_user_1)) %}
    

    # burn token with wrong pool caller

    # %{ expect_revert(error_message="wrong caller") %}
    #     IAToken.mint(a_token, USER_1, USER_1, Uint256(1,0), Uint256(1,0))
    # %{ stop_prank_pool = start_prank(ids.local_pool, target_contract_address = ids.a_token) %}
   #%{ stop_mock1 = mock_call(ids.a_token, "UNDERLYING_ASSET_ADDRESS", ids.token) %}
     %{ expect_revert(error_message="wrong caller") %}
     IAToken.burn(a_token, USER_1, USER_1, Uint256(50, 0), Uint256(1, 0))
    # %{ stop_mock1() %}
    # %{ stop_prank_pool() %}
    
    #Check Balance 
    let (balance_user_1_2) = IAToken.balanceOf(a_token, USER_1)
    assert balance_user_1_2 = Uint256(0, 0)
    %{ print("ATokenModifier : balance_user_1_2 = " + str(ids.balance_user_1_2)) %}
     %{ stop_mock() %}

    return()
end


func test_transfer_on_liquidation_wrong_pool{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    %{ print("transfer_on_liquidation : User tries to transfer_on_liquidation whith wrong POOL") %}
    let (_, _,local a_token) = get_contract_addresses()
    %{ expect_revert(error_message="wrong caller") %}
        IAToken.transfer_on_liquidation(a_token, USER_1, USER_2, Uint256(10,0))
    return()
end

func test_transfer_underlying_wrong_pool{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    %{ print("transfer_underlying_to : User tries to transfer_on_liquidation whith wrong POOL") %}
    let (_, _,local a_token) = get_contract_addresses()
    %{ expect_revert(error_message="wrong caller") %}
        IAToken.transfer_underlying_to(a_token, USER_1, Uint256(10,0))
    return()
end
#   it('Tries to invoke transferUnderlyingTo not being the Pool (revert expected)', async () => {
#     const { deployer, aDai } = testEnv;
#     await expect(aDai.transferUnderlyingTo(deployer.address, '1')).to.be.revertedWith(
#       CALLER_MUST_BE_POOL
#     );
#   });
# });

    # func test_burn_wrong_pool{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    #     alloc_locals
    #     %{ print("ATokenModifier : User tries to burn whith wrong POOL") %}
    #     local aDAI
    #     local aDAI_1
    #     local deployer 
    #     %{
    #         ids.aDAI = context.aDAI
    #         ids.aDAI_1 = context.aDAI_1
    #         ids.deployer = context.deployer
    #    %}
    #     %{ expect_revert(error_message="wron caller") %}
    #     IAToken.burn(aDAI_1, deployer, deployer, Uint256(1,0), Uint256(1,0))
       
    #    let (finalTrue) = IAToken.burn(aDAI, deployer, deployer, Uint256(1,0), Uint256(1,0))
    #    assert finalTrue = TRUE
    #    return()
    # end
end




