module SpelledOut

export spelled_out, Spelled_out, Spelled_Out, SPELLED_OUT

include(joinpath(dirname(@__FILE__), "standard_dictionary_numbers_extended.jl"))
include(joinpath(dirname(@__FILE__), "large_standard_dictionary_numbers_extended.jl"))
    
# convert a value < 100 to English.
function small_convert(number::Integer; british::Bool=false, dict::Symbol=:modern)::String
    scale_numbers = _scale_modern # define scale type
    if number < 20
        word = _small_numbers[number + 1]
        
        return word
    end
    
    v = 0
    while v < length(_tens)
        d_cap = _tens[v + 1]
        d_number = BigInt(20 + 10 * v)
        
        if d_number + 10 > number
            if mod(number, 10) ≠ 0
                word = d_cap * "-" * _small_numbers[mod(number, 10) + 1]
                
                return word
            end

            return d_cap
        end
        v += 1
    end
end

# convert a value < 1000 to english, special cased because it is the level that excludes
# the < 100 special case.  The rest are more general.  This also allows you to get
# strings in the form of "forty-five hundred" if called directly.
function large_convert(number::Integer; british::Bool=false, dict::Symbol=:modern)::String
    scale_numbers = _scale_modern # define scale type
    word = string() # initiate empty string
    divisor = div(number, 100)
    modulus = mod(number, 100)
    
    if divisor > 0
        word = _small_numbers[divisor + 1] * " hundred"
        if modulus > 0
            word = word * " "
        end
    end

    if british
        if ! iszero(divisor) && ! iszero(modulus)
            word = word * "and "
        end
    end
    
    if modulus > 0
        word = word * small_convert(modulus, british=british, dict=dict)
    end
    
    return word
end

function spelled_out(number::Integer; british::Bool=false, dict::Symbol=:modern)::String
    scale_numbers = _scale_modern # default to :modern
    if isequal(dict, :british)
        scale_numbers = _scale_traditional_british
    elseif isequal(dict, :european)
        scale_numbers = _scale_traditional_european
    end
    
    number = big(number)
    isnegative = false
    if number < 0
        isnegative = true
    end
    
    number = abs(number)
    if number > limit - 1
        throw(error("SpelledOut.jl does not support numbers larger than $(spelled_out(limit - 1, british=true)).  Sorry about that!"))
    end
    
    if number < 100
        word = small_convert(number, british=british, dict=dict)
        
        if isnegative
            word = "negative " * word
        end
        
        return word
    end
    
    if number < 1000
        word = large_convert(number, british=british, dict=dict)
        
        if isnegative
            word = "negative " * word
        end
        
        return word
    end
    
    v = 0
    while v ≤ length(scale_numbers)
        d_idx = v
        d_number = BigInt(round(big(1000)^v))
        
        if d_number > number
            modulus = BigInt(big(1000)^(d_idx - 1))
            l, r = divrem(number, modulus)
            word = large_convert(l, british=british, dict=dict) * " " * scale_numbers[d_idx - 1]
            
            if r > 0
                word = word * ", " * spelled_out(r, british=british, dict=dict)
            end
            
            if isnegative
                word = "negative " * word
            end
            
            return word
        end
        
        v += 1
    end
end

function spelled_out(number::AbstractFloat; british::Bool=false, dict::Symbol=:modern)::String
    type = typeof(number)
    number = big(number)
    
    try
        number = BigInt(number)
    catch
        throw(error("Cannot parse an object of type `$(type)` into the required integer type."))
    end
    
    return spelled_out(number, british=british, dict=dict)
end

Spelled_out(number::Real; british::Bool=false, dict::Symbol=:modern)::String = uppercasefirst(spelled_out(number, british=british, dict=dict))
Spelled_Out(number::Real; british::Bool=false, dict::Symbol=:modern)::String = titlecase(spelled_out(number, british=british, dict=dict))
SPELLED_OUT(number::Real; british::Bool=false, dict::Symbol=:modern)::String = uppercase(spelled_out(number, british=british, dict=dict))

end # end module
