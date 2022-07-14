struct PriceTick:
    member asset : felt
    member value : felt
    member timestamp : felt
    member publisher : felt
    member type : felt
end
struct PriceAggregate:
    member asset : felt
    member median : felt
    member variance : felt
    member quorum : felt
    member liquidity : felt
    member timestamp : felt
end
