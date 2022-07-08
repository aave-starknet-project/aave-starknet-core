%lang starknet

@contract_interface
namespace IProxy:
    func upgrade(new_implementation : felt):
    end

    func get_implementation() -> (implementation : felt):
    end
end
