include(joinpath(@__DIR__, "mi", "standard_dictionary_numbers_mi.jl"))

_fn_bounds_err_msg(n::I, bounds::String, fname::Symbol) where {I <: Integer} = 
    "The internal function \"$fname\" should only be used for numbers $bounds; number provided: $n"
# _fn_bounds_err_msg(, Base.StackTraces.stacktrace()[1].func)  # Get current function name using metaprogramming

function ones_convert_mi(n::I) where {I <: Integer}
    @assert(n ≤ 10, _fn_bounds_err_msg(n, "≤ 10", Base.StackTraces.stacktrace()[1].func))
    return _mi_small_numbers[n + 1]
end

function tens_convert_mi(n::I) where {I <: Integer}
    @assert(10 < n < 20, _fn_bounds_err_msg(n, "10 < n < 20", Base.StackTraces.stacktrace()[1].func))
    return "$_mi_ten $_mi_ma $(ones_convert_mi(n - 10))"
end

function spelled_out_mi(n::I) where {I <: Integer}
    # 1, 2, ..., 10
    n ≤ 10 && return ones_convert_mi(n)
    # 11, 12, ..., 999
    # return small_convert_mi(n)
    # n < 1000 && return small_convert_mi(n)
    # 1000, ...

    n < 20 && return tens_convert_mi(n)
    
    # 20, 21, ..., 99
    if n < 100
        d, r = divrem(n, 10)
        s = ones_convert_mi(d) * " " * _mi_ten
        if !iszero(r)
            s *= " " * _mi_ma * " " * ones_convert_mi(r)
        end
        return s
    end
    
    # 100, 101, ..., 999
    d, r = divrem(n, 100)
    m = floor(Int, log10(n))
    s = isone(d) || isone(div(n, 1000)) ? _mi_100 : spelled_out_mi(div(n, 10^m))
    s *= " " * _mi_scale[m]
    if !iszero(r)
        s *= " " * spelled_out_mi(r)
    end
    return s
end
