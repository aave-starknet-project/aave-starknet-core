%lang starknet

# Returns 0 if value != 0. Returns 1 otherwise.
func is_zero(value) -> (res : felt):
    if value == 0:
        return (res=1)
    end

    return (res=0)
end
