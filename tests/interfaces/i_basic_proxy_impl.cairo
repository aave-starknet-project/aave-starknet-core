# SPDX-License-Identifier: MIT

%lang starknet

@contract_interface
namespace IBasicProxyImpl:
    func get_version() -> (val : felt):
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
