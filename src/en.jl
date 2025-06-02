# dictionaries
include(joinpath(@__DIR__, "en", "standard_dictionary_numbers_extended.jl"))
include(joinpath(@__DIR__, "en", "large_standard_dictionary_numbers_extended.jl"))
include(joinpath(@__DIR__, "en", "ordinal_dictionaries.jl"))

# utils
include(joinpath(@__DIR__, "en", "utils.jl"))
    
# convert a value < 100 to English.
function _small_convert_en!(io::IOBuffer, number::Integer)
    if number < 20
        print(io, _small_numbers[number + 1])
        return io
    end
    
    m = mod(number, 10)
    
    for (v, d̂) in enumerate(_tens)
        d = 20 + 10 * (v - 1)
        
        if d + 10 > number
            if m ≠ 0
                n = _small_numbers[m + 1]
                print(io, d̂, '-', n)
                return io
            end
            print(io, d̂)
            return io
        end
    end
    
    return io
end

function small_convert_en(number::Integer)
    word_buf = IOBuffer()
    _small_convert_en!(word_buf, number)
    return String(take!(word_buf))
end

# convert a value < 1000 to english, special cased because it is the level that excludes
# the < 100 special case.  The rest are more general.  This also allows you to get
# strings in the form of "forty-five hundred" if called directly.
function _large_convert_en!(io::IOBuffer, number::Integer; british::Bool = false)
    divisor = div(number, 100)
    modulus = mod(number, 100)
    
    if divisor > 0
        print(io, _small_numbers[divisor + 1], " hundred")
        if modulus > 0
            print(io, ' ')
        end
    end

    if british
        if !iszero(divisor) && !iszero(modulus)
            print(io, "and ")
        end
    end
    
    if modulus > 0
        _small_convert_en!(io, modulus)
    end
    
    return io
end

function large_convert_en(number::Integer; british::Bool = false)
    word_buf = IOBuffer()
    _large_convert_en!(word_buf, number; british = british)
    return String(take!(word_buf))
end

function _spelled_out_en!(io::IOBuffer, number_norm::Integer; british::Bool = false, dict::Symbol = :modern)
    scale_numbers = _scale_modern # default to :modern
    if isequal(dict, :british)
        scale_numbers = _scale_traditional_british
    elseif isequal(dict, :european)
        scale_numbers = _scale_traditional_european
    elseif isequal(dict, :modern)
        # This is the default condition
    else
        error("Unrecognized dict value: $dict")
    end
    
    if number_norm < 0
        # In "Merriam-Webster's Guide to Everyday Math: A Home and Business Reference"
        # by Brian Burrell (1998), the adjective "negative" over "minus" is used for
        # negative numbers.
        #
        # See #40: SpelledOut.jl/issues/40
        print(io, "negative ")
        number_norm = abs(number_norm)
    end
	
    if number_norm > limit - 1
        error("""SpelledOut.jl does not support numbers larger than $(limit_str * " - 1").  Sorry about that!""")
    end
    
    
    if number_norm < 100
        _small_convert_en!(io, number_norm)
        return io
    end
    
    if number_norm < 1000
        _large_convert_en!(io, number_norm, british = british)
        return io
    end
    
    number = abs(number_norm)
    
    for v in 0:length(scale_numbers)
        d_idx = v
        d_number = round(big(1000)^v)
        
        if d_number > number
            modulus = big(1000)^(d_idx - 1)
            l, r = divrem(number, modulus)
            
            _large_convert_en!(io, l, british = british)
            print(io, " ", scale_numbers[d_idx - 1])   
            if r > 0
                print(io, ", ")
                _spelled_out_en!(io, r, british = british, dict = dict)
            end
            
            return io
        end
    end
    
    error("Unreachable")
end

function spelled_out_en(number_orig::Integer; british::Bool = false, dict::Symbol = :modern)
    word_buf = IOBuffer()
    _spelled_out_en!(word_buf, number_orig; british = british, dict = dict)
    return String(take!(word_buf))
end

# Need to print ordinal numbers for the irrational printing
function spell_ordinal_en(number::Integer; british::Bool = false, dict::Symbol = :modern)
    word_buf = IOBuffer()
    _spelled_out_en!(word_buf, number, british = british, dict = dict)
    s = String(take!(word_buf))
	
	lastword = lastsplit(isspace, s)
	redolast = lastsplit('-', lastword)

    if redolast != lastword
        _lastsplit = '-'
        word = redolast
    else
        _lastsplit = ' '
        word = lastword
    end
    
    firstpart = firstlastsplit(_lastsplit, s)

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
    word_buf = IOBuffer()
    _spelled_out_en!(word_buf, parse(BigInt, whole), british = british, dict = dict)
    print(word_buf, " point")
    
    for i in decimal
        print(word_buf, ' ', _small_number_dictionary[i])
    end
    
    return String(take!(word_buf))
end

function spelled_out_en(number::AbstractFloat; british::Bool = false, dict::Symbol = :modern)
    str_number = format(number)
    if occursin('.', str_number)
        _decimal, _ = modf(Dec64(number))
        _length_of_presicion = length(string(_decimal)) - 2 # (ndigits(_whole) + 1)
        number = format(number, precision = _length_of_presicion)
    else
        # It is an integer is scientific notation, treat normally without decimal precision
        # considerations.  E.g., 1e10 should be parsed as an integer (as should 1.0e10).
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

function _spelled_out_with_unit_en(io::IOBuffer, number::Integer, unit::String; british::Bool = false, dict::Symbol = :modern)
    if isone(abs(number))
        # Special case for handling a single unit.
        #
        # We say "x," not "one x"
        number < 0 && print(io, "negative ")
        print(io, unit)
    else
        _spelled_out_en!(io, number, british = british, dict = dict)
        print(io, ' ', unit)
    end

    return io
end

# Spell out complex numbers
function spelled_out_en(number::Complex; british::Bool = false, dict::Symbol = :modern)
    # Trivial case: both parts are zero, so the number is zero
    iszero(number) && return spelled_out_en(0, british = british, dict = dict)

    # Complex numbers are normally given in their standard form, a + bi; real part a is
    # first, followed by the imaginary part second, so we will print them as such.
    re, i = real(number), imag(number)
    io = IOBuffer()

    # Special case for handling a single imaginary unit.
    if iszero(re) && isone(abs(i))
        _spelled_out_with_unit_en(io, i, "i", british = british, dict = dict)
        return String(take!(io))
    end

    # We only report on the non-zero parts
    if !iszero(re)
        _spelled_out_en!(io, re, british = british, dict = dict)
    end

    if !iszero(i)
        # Handle negative imaginary component; if it is negative, we don't say
        # "plus negative x" (even though this is mathematically accurate because
        # addition is commutitive).  Rather, we say "minus x."
        #
        # Note that we only have special handling for the delimiting word and
        # negative imaginary part if there is a non-zero real part.  Otherwise,
        # we can just print the number normally, followed by the imaginary unit i.
        if !iszero(re)
            if i < 0
                print(io, " minus ")
                i = abs(i)
            else
                print(io, " plus ")
            end
        end

        # Use unit printing for the imaginary part, as the imaginary unit can be treated
        # as a unit, like in measurement.
        #
        # Print the imaginary unit, denoted by i (often in italic).  Even when spelled
        # out, we say "i", rather than "x imaginaries" or "x parts imaginary."
        #
        # The imaginary unit i is pronounced like the letter "I" (/aɪ/).
        #
        # Note that in some contexts, especially electrical engineering, the symbol j
        # is used instead of i.
        _spelled_out_with_unit_en(io, i, "i", british = british, dict = dict)
    end

    return String(take!(io))
end

function spelled_out_en(number::Rational; british::Bool = false, dict::Symbol = :modern)
	_num, _den = number.num, number.den
    
    # return the number itself if the denomimator is one
	isone(_den) && return spelled_out_en(_num, british = british, dict = dict)
    
	word = spelled_out_en(_num, british = british, dict = dict) * " " * spell_ordinal_en(_den, british = british, dict = dict)
    
    # account for pluralisation
    return isone(abs(_num)) ? word : word * "s"
end

function spelled_out_en(number::AbstractIrrational; british::Bool = false, dict::Symbol = :modern)
    throw(error("Please round the input number, as we support floating point printing but cannot support irrational printing."))
end

# Fallback method if we do not know how to handle the input
function spelled_out_en(number; british::Bool = false, dict::Symbol = :modern)
    throw(error("Cannot parse type $(typeof(number)).  Please make an issue."))
end
