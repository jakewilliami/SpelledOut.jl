# Jake Ireland (June, 2022–April, 2023)

include(joinpath(@__DIR__, "mi", "standard_dictionary_numbers_mi.jl"))

# TODO: kotahi vs tahi (https://animations.tewhanake.maori.nz/te-kakano/te-wahanga-tuatahi/30)
# TODO: KOTAHI WITH MACRON?
# TODO: Ordinal numbers (https://omniglot.com/language/numbers/maori.htm)
# TODO: negatives
# TODO: kotahi or kotahi rau?
# TODO: implement missing/nothing??
# TODO: implement float etc?

_fn_bounds_err_msg(n::I, bounds::String, fname::Symbol) where {I <: Integer} =
    "The internal function \"$fname\" should only be used for numbers $bounds; number provided: $n"
# _fn_bounds_err_msg(, Base.StackTraces.stacktrace()[1].func)  # Get current function name using metaprogramming

function _ones_convert_mi(n::I) where {I <: Integer}
    @assert(n ≤ 10, _fn_bounds_err_msg(n, "≤ 10", Base.StackTraces.stacktrace()[1].func))
    return _mi_small_numbers[n + 1]
end

function _teens_convert_mi(n::I) where {I <: Integer}
    @assert(10 < n < 20, _fn_bounds_err_msg(n, "10 < n < 20", Base.StackTraces.stacktrace()[1].func))
    return "$_mi_ten $_mi_ma $(_ones_convert_mi(n - 10))"
end

function _tens_convert_mi(n::I) where {I <: Integer}
    @assert(20 ≤ n < 100, _fn_bounds_err_msg(n, "20 ≤ n < 100", Base.StackTraces.stacktrace()[1].func))
    d, r = divrem(n, 10)
    s = _ones_convert_mi(d) * " " * _mi_ten
    if !iszero(r)
        s *= " " * _mi_ma * " " * _ones_convert_mi(r)
    end
    return s
end

function _hundreds_convert_mi(n::I) where {I <: Integer}
    @assert(100 ≤ n < 1000, _fn_bounds_err_msg(n, "100 ≤ n < 1000", Base.StackTraces.stacktrace()[1].func))
    d, r = divrem(n, 100)
    s = isone(d) ? _mi_kotahi : _spelled_out_mi(d)
    s *= " "* _mi_100
    if !iszero(r)
        s *= " " * _spelled_out_mi(r)
    end
    return s
end

function _large_convert_mi(n::I) where {I <: Integer}
    # TODO: might not be used
    s = isone(mod(n, 10)) ? _mi_kotahi : _ones_convert_mi(n)
    return "$s $_mi_100 $(_spelled_out_mi(mod(n, 10)))"
    # @assert(10 < n < 20, _fn_bounds_err_msg(n, "", Base.StackTraces.stacktrace()[1].func))
    d, r = divrem(n, 100)
    m = floor(Int, log10(n))
    s = isone(d) || isone(div(n, 1000)) ? _mi_100 : _spelled_out_mi(div(n, 10^m))
    # println(n, " ", m, " ", divrem(n, 100))
    s *= " " * _mi_scale[m]
    if !iszero(r)
        s *= " " * _spelled_out_mi(r)
    end
    return s
end

function _spelled_out_mi(n::I) where {I <: Integer}
    n ≤ 10   && return _ones_convert_mi(n)      # 1, 2, ..., 10
    n < 20   && return _teens_convert_mi(n)     # 11, 12, ..., 19
    n < 100  && return _tens_convert_mi(n)      # 20, 21, ..., 99
    n < 1000 && return _hundreds_convert_mi(n)  # 101, 102, ..., 999

    # 1000, 1001, ...
    n′ = abs(n)  # TODO: negatives
    s = ""

    for v in 0:length(_mi_scale_large)
        d_number = round(big(1000)^v)
        # println("    skipping $v")

        if d_number > n′
            modulus = big(1000)^(v - 1)
            l, r = divrem(n′, modulus)
            # println("modulus=$modulus, n=$(n′), l=$l, l′=$(mod(l, 100)), r=$r, v=$v, d_number=$d_number, s=\"$s\"")

            l′ = mod(l, 100)

            # if isone(l′)
                # s *= _mi_kotahi
            # elseif isone(mod(l, 10))
                # s *=
            # else
                # s *= _spelled_out_mi(l′)
            # end
            s *= isone(l′) ? _mi_kotahi : _spelled_out_mi(l)
            r′ = div(l, 100)
            if isone(l′) && !iszero(r′)
                s *= _spelled_out_mi(r′)
            end
            # s *= _spelled_out_mi(mod(l, 1000))
            s *= " " * _mi_scale_large[v - 1]
            # s *= " " * (l > 1000 ? _mi_scale_large[v - 1] : _mi_scale[v - 1])

            if r > 0
                s *= ", " * _spelled_out_mi(r)
            end

            return s
        end
    end

    error("Unreachable")
end

function spelled_out_mi(n::I) where {I <: Integer}
    return _spelled_out_mi(n)
end
