# dictionaries
include(joinpath(@__DIR__, "en", "standard_dictionary_numbers_extended.jl"))
include(joinpath(@__DIR__, "en", "large_standard_dictionary_numbers_extended.jl"))
include(joinpath(@__DIR__, "en", "ordinal_dictionaries.jl"))

# utils
include(joinpath(@__DIR__, "en", "utils.jl"))
    
# convert a value < 100 to English.
function small_convert_en(number::Integer; british::Bool = false, dict::Symbol = :modern)
    scale_numbers = _scale_modern # define scale type
    if number < 20
        return _small_numbers[number + 1]
    end
    
    for (v, d_cap) in enumerate(_tens)
        d_number = BigInt(20 + 10 * (v - 1))
        
        if d_number + 10 > number
            if mod(number, 10) ≠ 0
                return d_cap * "-" * _small_numbers[mod(number, 10) + 1]
            end
            return d_cap
        end
    end
    
    return nothing
end

# convert a value < 1000 to english, special cased because it is the level that excludes
# the < 100 special case.  The rest are more general.  This also allows you to get
# strings in the form of "forty-five hundred" if called directly.
function large_convert_en(number::Integer; british::Bool = false, dict::Symbol = :modern)
    scale_numbers = _scale_modern # define scale type
    word_buf = IOBuffer()
    divisor = div(number, 100)
    modulus = mod(number, 100)
    
    if divisor > 0
        print(word_buf, _small_numbers[divisor + 1], " hundred")
        if modulus > 0
            print(word_buf, ' ')
        end
    end

    if british
        if ! iszero(divisor) && ! iszero(modulus)
            print(word_buf, "and ")
        end
    end
    
    if modulus > 0
        print(word_buf, small_convert_en(modulus, british=british, dict=dict))
    end
    
    return String(take!(word_buf))
end

function spelled_out_en(number_orig::Integer; british::Bool = false, dict::Symbol = :modern)
    scale_numbers = _scale_modern # default to :modern
    if isequal(dict, :british)
        scale_numbers = _scale_traditional_british
    elseif isequal(dict, :european)
        scale_numbers = _scale_traditional_european
    elseif isequal(dict, :modern)
    else
        error("Unrecognized dict value: $dict")
    end
    
    word_buf = IOBuffer()
    if number_orig < 0
        print(word_buf, "negative ")
    end
    
    number = big(number_orig)
    number = abs(number)
	
    if number > limit - 1
        error("""SpelledOut.jl does not support numbers larger than $(limit_str * " - 1").  Sorry about that!""")
    end
    
    
    if number < 100
        word = small_convert_en(number, british=british, dict=dict)
        print(word_buf, word)
        return String(take!(word_buf))
    end
    
    if number < 1000
        word = large_convert_en(number, british=british, dict=dict)
        print(word_buf, word)
        return String(take!(word_buf))
    end
    
    tmp_word_buf = IOBuffer()
    
    for v in 0:length(scale_numbers)
        d_idx = v
        d_number = BigInt(round(big(1000)^v))
        
        if d_number > number
            modulus = BigInt(big(1000)^(d_idx - 1))
            l, r = divrem(number, modulus)
            
            word = large_convert_en(l, british=british, dict=dict)
            print(word_buf, word, " ", scale_numbers[d_idx - 1])            
            r > 0 && print(word_buf, ", ", spelled_out_en(r, british=british, dict=dict))
            
            return String(take!(word_buf))
        end
    end
    
    error("Unreachable")
end

# Need to print ordinal numbers for the irrational printing
function spell_ordinal_en(number::Integer; british::Bool = false, dict::Symbol = :modern)
    s = spelled_out_en(number, british = british, dict = dict)
	
	lastword = lastsplit(isspace, s)
	redolast = lastsplit('-', lastword)

    if redolast != lastword
        _lastsplit = '-'
        word = redolast
    else
        _lastsplit = ' '
        word = lastword
    end
    
    word_buf = IOBuffer()
    firstpart = reverse(last(split(reverse(s), _lastsplit, limit = 2)))
    if firstpart != word
        print(word_buf, firstpart, _lastsplit)
    end
    
    if haskey(irregular, word)
        print(word_buf, irregular[word])
    elseif word[end] == 'y'
        print(word_buf, word[1:end-1], ysuffix)
    else
        print(word_buf, word, suffix)
    end
    
    return String(take!(word_buf))
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
