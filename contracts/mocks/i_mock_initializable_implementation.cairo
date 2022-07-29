%lang starknet

@contract_interface
namespace IMockInitializableImplementation:
    func initialize(val : felt, txt : felt):
    end

    func get_revision() -> (revision : felt):
    end

    func get_value() -> (value : felt):
    end

    func get_text() -> (text : felt):
    end
end

@contract_interface
namespace IMockInitializableReentrantImplementation:
    func initialize(val : felt):
    end

    func get_value() -> (value : felt):
    end

    func get_text() -> (text : felt):
    end
end
