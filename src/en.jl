include(joinpath(@__DIR__, "en", "standard_dictionary_numbers_extended.jl"))
include(joinpath(@__DIR__, "en", "large_standard_dictionary_numbers_extended.jl"))
    
# convert a value < 100 to English.
function small_convert_en(number::Integer; british::Bool = false, dict::Symbol = :modern)
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
function large_convert_en(number::Integer; british::Bool = false, dict::Symbol = :modern)
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
        word = word * small_convert_en(modulus, british=british, dict=dict)
    end
    
    return word
end

function spelled_out_en(number::Integer; british::Bool = false, dict::Symbol = :modern)
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
        throw(error("""SpelledOut.jl does not support numbers larger than $(limit_str * " - 1").  Sorry about that!"""))
    end
    
    if number < 100
        word = small_convert_en(number, british=british, dict=dict)
        
        if isnegative
            word = "negative " * word
        end
        
        return word
    end
    
    if number < 1000
        word = large_convert_en(number, british=british, dict=dict)
        
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
            word = large_convert_en(l, british=british, dict=dict) * " " * scale_numbers[d_idx - 1]
            
            if r > 0
                word = word * ", " * spelled_out_en(r, british=british, dict=dict)
            end
            
            if isnegative
                word = "negative " * word
            end
            
            return word
        end
        
        v += 1
    end
end

# This method is an internal method used for spelling out floats
function decimal_convert_en(number::AbstractString; british::Bool = false, dict::Symbol = :modern)
    # decimal, whole = modf(number)
    # whole = round(BigInt, whole)
    whole, decimal = split(number, ".")
    word = spelled_out_en(parse(BigInt, whole), british=british, dict=dict) * string(" point")
    # word = spelled_out_en(whole, british=british, dict=dict) * string(" point")
    
    for i in decimal
        word = word * " " * _small_number_dictionary[i]
    end
    
    return word
end

function decimal_convert_en(number::AbstractFloat; british::Bool = false, dict::Symbol = :modern)
    #=# decimal, whole = modf(number)
    # whole = round(BigInt, whole)
    whole, decimal = split(string(number), ".")
    word = spelled_out_en(parse(BigInt, whole), british=british, dict=dict) * string(" point")
    # word = spelled_out_en(whole, british=british, dict=dict) * string(" point")
    
    for i in decimal
        word = word * " " * _small_number_dictionary[i]
    end
    
    return word=#
    return decimal_convert_en(format(number), british = british, dict = dict)
end

function spelled_out_en(number::AbstractFloat; british::Bool = false, dict::Symbol = :modern)
    str_number = format(number)
    if occursin('.', str_number)
    # if ! isinteger(number)
        _decimal, _ = modf(Dec64(number))
        # println(_decimal)
        _length_of_presicion = length(string(_decimal)) - 2 # (ndigits(_whole) + 1)
        # println(split(str_number, '.'))
        # _length_of_presicion = length(last(split(str_number, '.')))
        # println(format(number, precision = _length_of_presicion))
        # number = parse(Dec128, format(number, precision = _length_of_presicion)) # convert 1.01e10 to 10100000000
        # println(_length_of_presicion)
        number = format(number, precision = _length_of_presicion)
        # println(number)
        # println(number)
    else
        # It is an integer is scientific notation, treat normally without decimal precision considerations
        number = parse(BigFloat, str_number)
    end
    
    # println(number)
    if isa(number, AbstractString)
        # if the number is a string then it is a decimal, which is formatted precisely
        # for correct precision with decimal places
        return decimal_convert_en(number, british = british, dict = dict)
        # println(DecFP.Dec64(number))
        # return decimal_convert_en(Dec128(number), british = british, dict = dict)
    elseif isinteger(number)
        # otherwise, it is an integer
        return spelled_out_en(BigInt(number), british = british, dict = dict)
    else
        throw(error("Cannot parse type $(typeof(number)).  Please make an issue."))
    end
    
    # try
    #     return spelled_out_en(parse(BigInt, number), british = british, dict = dict)
    # catch
    #     return decimal_convert_en(parse(Dec128, number), british = british, dict = dict)
    # end
    
    return nothing
end

function spelled_out_en(number::Complex; british::Bool = false, dict::Symbol = :modern)
    return spelled_out_en(real(number), british = british, dict = dict) * " and " * spelled_out_en(imag(number), british = british, dict=dict) * " imaginaries"
end
