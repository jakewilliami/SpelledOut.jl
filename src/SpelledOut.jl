module SpelledOut

export spelled_out

const _small_numbers = String[
    "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten",
    "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"]
const _tens = String[
    "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"]
const _scale_numbers = String[
    "thousand",     "million",         "billion",       "trillion",       "quadrillion",
    "quintillion",  "sextillion",      "septillion",    "octillion",      "nonillion",
    "decillion",    "undecillion",     "duodecillion",  "tredecillion",   "quattuordecillion",
    "sexdecillion", "septendecillion", "octodecillion", "novemdecillion", "vigintillion"]
    
# convert a value < 100 to English.
function __small_convert(number::Integer; british::Bool=false)::String
    if number < 20
        word = _small_numbers[number + 1]
        
        return word
    end
    
    v = 1
    while v ≤ length(_tens)
        d_cap = _tens[v]
        d_number = BigInt(20 + 10 * v)
        
        if d_number + 10 > number
            if mod(number, 10) ≠ 0
                word = d_cap * "-" * _small_numbers[mod(number, 10) + 1]
                if british
                    word = "and " * word
                end
                
                return word
            end
            
            if british
                d_cap = "and " * d_cap
            end
            return d_cap
        end
        v += 1
    end
end

# convert a value < 1000 to english, special cased because it is the level that excludes
# the < 100 special case.  The rest are more general.  This also allows you to get
# strings in the form of "forty-five hundred" if called directly.
function __big_convert(number::Integer; british::Bool=false)::String
    word = string() # initiate empty string
    divisor = div(number, 100)
    modulus = mod(number, 100)
    
    if divisor > 0
        word = _small_numbers[divisor + 1] * " hundred"
        if modulus > 0
            word = word * " "
        end
    end
    
    if modulus > 0
        word = word * __small_convert(modulus, british=british)
    end
    
    return word
end

function spelled_out(number::Integer; british::Bool=false)::String
    number = big(number)
    isnegative = false
    if number < 0
        isnegative = true
    end
    number = abs(number)
    if number > big(1000000000000000000000000000000000000000000000000000000000000) - 1
        throw(error("SpelledOut.jl does not support numbers larger than $(spelled_out(1000000000000000000000000000000000000000000000000000000000000 - 1)).  Sorry about that!"))
    end
    
    if number < 100
        word = __small_convert(number, british=british)
        
        if isnegative
            word = "negative " * word
        end
        
        return word
    end
    
    if number < 1000
        word = __big_convert(number, british=british)
        
        if isnegative
            word = "negative " * word
        end
        
        return word
    end
    
    v = 0
    while v ≤ length(_scale_numbers)
        d_idx = v
        d_number = BigInt(round(big(1000)^v))
        
        if d_number > number
            modulus = BigInt(big(1000)^(d_idx - 1))
            # l = BigInt(round(number / mod))
            # r = BigInt(round(number - (l * mod)))
            l, r = divrem(number, modulus)
            word = __big_convert(l, british=british) * " " * _scale_numbers[d_idx - 1]
            
            if r > 0
                word = word * ", " * spelled_out(r)
            end
            
            if isnegative
                word = "negative " * word
            end
            
            return word
        end
        
        v += 1
    end
end

end # end module
