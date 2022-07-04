%lang starknet

@contract_interface
namespace Ibits_manipulation:
    func actual_get_element_at(input : felt, at : felt, number_of_bits : felt) -> (response : felt):
    end
    func actual_set_element_at(input : felt, at : felt, number_of_bits : felt, element : felt) -> (
        response : felt
    ):
    end
end
