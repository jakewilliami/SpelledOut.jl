# dictionaries
include(joinpath(@__DIR__, "en", "standard_dictionary_numbers_extended.jl"))
include(joinpath(@__DIR__, "en", "large_standard_dictionary_numbers_extended.jl"))
include(joinpath(@__DIR__, "en", "ordinal_dictionaries.jl"))

# utils
include(joinpath(@__DIR__, "en", "utils.jl"))
    
# convert a value < 100 to English.
function _small_convert_en!(io::IOBuffer, number::Integer; british::Bool = false, dict::Symbol = :modern)
    scale_numbers = _scale_modern # define scale type
    if number < 20
        write(io, _small_numbers[number + 1])
        return io
    end
    
    for (v, d̂) in enumerate(_tens)
        d_number = BigInt(20 + 10 * (v - 1))
        
        if d_number + 10 > number
            if mod(number, 10) ≠ 0
                write(io, d̂, '-', _small_numbers[mod(number, 10) + 1])
                return io
            end
            write(io, d̂)
            return io
        end
    end
    
    return io
end

function small_convert_en(number::Integer; british::Bool = false, dict::Symbol = :modern)
    word_buf = IOBuffer()
    _small_convert_en!(word_buf, number; british=british, dict=dict)
    return String(take!(word_buf))
end

# convert a value < 1000 to english, special cased because it is the level that excludes
# the < 100 special case.  The rest are more general.  This also allows you to get
# strings in the form of "forty-five hundred" if called directly.
function _large_convert_en!(io::IOBuffer, number::Integer; british::Bool = false, dict::Symbol = :modern)
    scale_numbers = _scale_modern # define scale type
    divisor = div(number, 100)
    modulus = mod(number, 100)
    
    if divisor > 0
        write(io, _small_numbers[divisor + 1], " hundred")
        if modulus > 0
            write(io, ' ')
        end
    end

    if british
        if !iszero(divisor) && !iszero(modulus)
            write(io, "and ")
        end
    end
    
    if modulus > 0
        _small_convert_en!(io, modulus, british=british, dict=dict)
    end
    
    return io
end

function large_convert_en(number::Integer; british::Bool = false, dict::Symbol = :modern)
    word_buf = IOBuffer()
    _large_convert_en!(word_buf, number; british=british, dict=dict)
    return String(take!(word_buf))
end

function _spelled_out_en!(io::IOBuffer, number_orig::Integer; british::Bool = false, dict::Symbol = :modern)
    scale_numbers = _scale_modern # default to :modern
    if isequal(dict, :british)
        scale_numbers = _scale_traditional_british
    elseif isequal(dict, :european)
        scale_numbers = _scale_traditional_european
    elseif isequal(dict, :modern)
    else
        error("Unrecognized dict value: $dict")
    end
    
    if number_orig < 0
        write(io, "negative ")
    end
    
    number = big(number_orig)
    number = abs(number)
	
    if number > limit - 1
        error("""SpelledOut.jl does not support numbers larger than $(limit_str * " - 1").  Sorry about that!""")
    end
    
    
    if number < 100
        _small_convert_en!(io, number, british=british, dict=dict)
        return io
    end
    
    if number < 1000
        _large_convert_en!(io, number, british=british, dict=dict)
        return io
    end
    
    for v in 0:length(scale_numbers)
        d_idx = v
        d_number = BigInt(round(big(1000)^v))
        
        if d_number > number
            modulus = BigInt(big(1000)^(d_idx - 1))
            l, r = divrem(number, modulus)
            
            _large_convert_en!(io, l, british=british, dict=dict)
            write(io, " ", scale_numbers[d_idx - 1])   
            if r > 0
                write(io, ", ")
                _spelled_out_en!(io, r, british=british, dict=dict)
            end
            
            return io
        end
    end
    
    error("Unreachable")
end

function spelled_out_en(number_orig::Integer; british::Bool = false, dict::Symbol = :modern)
    word_buf = IOBuffer()
    _spelled_out_en!(word_buf, number_orig; british=british, dict=dict)
    return String(take!(word_buf))
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
        write(word_buf, firstpart, _lastsplit)
    end
    
    if haskey(irregular, word)
        write(word_buf, irregular[word])
    elseif word[end] == 'y'
        write(word_buf, word[1:end-1], ysuffix)
    else
        write(word_buf, word, suffix)
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
