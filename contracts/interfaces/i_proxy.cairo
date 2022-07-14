%lang starknet

@contract_interface
namespace IProxy:
    func initialize(proxy_admin : felt):
    end

    func upgrade(new_implementation : felt):
    end

    func get_implementation() -> (implementation : felt):
    end

    func get_admin() -> (admin : felt):
    end

    func set_admin(new_admin : felt) -> ():
    end
end
