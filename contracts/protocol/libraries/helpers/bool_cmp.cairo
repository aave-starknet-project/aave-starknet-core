%lang starknet

namespace BoolCompare:
    func is_valid(a : felt):
        with_attr error_message("Value should be either 0 or 1. Current value: {a}"):
            assert a * a = a
        end
        return ()
    end

    func eq(a : felt, b : felt) -> (res : felt):
        if a == b:
            return (res=1)
        else:
            return (res=0)
        end
    end

    func either(x : felt, y : felt) -> (res : felt):
        assert x * x = x
        assert y * y = y
        let (res) = eq((x - 1) * (y - 1), 0)
        return (res=res)
    end

    func both(x : felt, y : felt) -> (res : felt):
        assert x * x = x
        assert y * y = y
        let (res) = eq((x + y), 2)
        return (res=res)
    end
end
