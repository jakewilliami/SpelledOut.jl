include(joinpath(@__DIR__, "en", "standard_dictionary_numbers_extended.jl"))
include(joinpath(@__DIR__, "en", "large_standard_dictionary_numbers_extended.jl"))
include(joinpath(@__DIR__, "en", "ordinal_dictionaries.jl"))
    
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
    elseif isequal(dict, :modern)
    else
        throw(error("unrecognized dict value: $dict"))
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

# Need to print ordinal numbers for the irrational printing
function spell_ordinal_en(number::Integer; british::Bool = false, dict::Symbol = :modern)
    s = spelled_out_en(number, british = british, dict = dict)

    lastword = split(s)[end]
    redolast = split(lastword, "-")[end]

    if redolast != lastword
        lastsplit = "-"
        word = redolast
    else
        lastsplit = " "
        word = lastword
    end

    firstpart = reverse(split(reverse(s), lastsplit, limit = 2)[end])
    firstpart = (firstpart == word) ? string() : firstpart * lastsplit

    if haskey(irregular, word)
        word = irregular[word]
    elseif word[end] == 'y'
        word = word[1:end-1] * ysuffix
    else
        word = word * suffix
    end

    return firstpart * word
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

function spelled_out_en(number::AbstractFloat; british::Bool = false, dict::Symbol = :modern)
    str_number = format(number)
    if occursin('.', str_number)
        _decimal, _ = modf(Dec64(number))
        _length_of_presicion = length(string(_decimal)) - 2 # (ndigits(_whole) + 1)
        number = format(number, precision = _length_of_presicion)
    else
        # It is an integer is scientific notation, treat normally without decimal precision considerations
        # E.g., 1e10 should be parsed as an integer (as should 1.0e10)
        number = parse(BigInt, str_number)
    end
    
    if isa(number, AbstractString)
        # if the number is a string then it is a decimal, which is formatted precisely
        # for correct precision with decimal places
        return decimal_convert_en(number, british = british, dict = dict)
    elseif isinteger(number)
        # otherwise, it is an integer
        return spelled_out_en(number, british = british, dict = dict)
    else
        throw(error("Cannot parse type $(typeof(number)).  Please make an issue."))
    end
    
    # should never get here
    return nothing
end

# Spell out complex numbers
function spelled_out_en(number::Complex; british::Bool = false, dict::Symbol = :modern)
    return spelled_out_en(real(number), british = british, dict = dict) * " and " * spelled_out_en(imag(number), british = british, dict=dict) * " imaginaries"
end

function spelled_out_en(number::Rational; british::Bool = false, dict::Symbol = :modern)
		_num, _den = number.num, number.den
        
        # return the number itself if the denomimator is one
		isone(_den) && return spelled_out_en(_num, british = british, dict = dict)
        
		word = spelled_out_en(_num, british = british, dict = dict) * " " * spell_ordinal_en(_den, british = british, dict = dict)
        
        # account for pluralisation
		return isone(_num) ? word : word * "s"
end

function spelled_out_en(number::AbstractIrrational; british::Bool = false, dict::Symbol = :modern)
    throw(error("Please round the input number, as we support floating point printing but cannot support irrational printing."))
end

# Fallback method if we do not know how to handle the input
function spelled_out_en(number; british::Bool = false, dict::Symbol = :modern)
    throw(error("Cannot parse type $(typeof(number)).  Please make an issue."))
end
