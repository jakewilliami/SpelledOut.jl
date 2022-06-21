include(joinpath(@__DIR__, "mi", "standard_dictionary_numbers_mi.jl"))

function ones_convert_mi(n::I) where {I <: Integer}
    @assert(n ≤ 10, "The internal function \"ones_convert_mi\" should only be used for numbers ≤ 10; number provided: $n")
    return _mi_small_numbers[n + 1]
end

function tens_convert_mi(n::I) where {I <: Integer}
    @assert(10 < n < 20, "The internal function \"tens_convert_mi\" should only be used for numbers 10 < n < 20; number provided: $n")
    return "$_mi_ten $_mi_ma $(ones_convert_mi(n - 10))"
end

function small_convert_mi(n::I) where {I <: Integer}
    @assert(n < 1000, "The internal function \"small_convert_mi\" should only be used for numbers < 1000; number provided: $n")
    # 11, 12, ..., 19
    n < 20 && return tens_convert_mi(n)
    # 10, 20, ..., 90
    s = "$(ones_convert_mi(fld(n, 10))) $(_mi_scale[1])"
    if iszero(mod(n, 10)) && n < 100
        return s
    end
    
    s *= " $_mi_ma "
    # n′ = fld(n, 10)
    n′ = mod(n, 10)
    # while !iszero(n)
    while (n - rem(n, n′)) != n′
        s += " $(ones_convert_mi(n))"
        n′ = mod(n′, 10)
        # s += " $(small_convert_mi(n))"
        # _mi_ma
        # ones_convert_mi(fld(n, 10)), _mi_scale[1]
        # m = mod(n, 10v)
        # return s * small_convert_mi(m)
    end
    return s
end

function spelled_out_mi(n::I) where {I <: Integer}
    # 1, 2, ..., 10
    n ≤ 10 && return ones_convert_mi(n)
    # 11, 12, ..., 999
    n < 1000 && return small_convert_mi(n)
    # 1000, ...
    error("not yet implemented")
end
