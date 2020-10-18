# module SpelledOut
#
# export spelled_out

const _small_numbers = String[
    "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten",
    "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"]
const _tens = String[
    "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"]
const _scale_numbers = String[ "",
    "thousand",     "million",         "billion",       "trillion",       "quadrillion",
    "quintillion",  "sextillion",      "septillion",    "octillion",      "nonillion",
    "decillion",    "undecillion",     "duodecillion",  "tredecillion",   "quattuordecillion",
    "sexdecillion", "septendecillion", "octodecillion", "novemdecillion", "vigintillion"]
    
# convert a value < 100 to English.
function __small_convert(number::Integer)::String
    isnegative = false
    if number < 0
        isnegative = true
    end
    
    number = abs(number)
    
    if number < 20
        word = _small_numbers[number + 1]
        if isnegative
            word = "negative " * word
        end
        
        return word
    end
    
    v = 1
    while v ≤ length(_tens)
        d_cap = _tens[v]
        d_number = Int(20 + 10 * v)
        
        if d_number + 10 > number
            if mod(number, 10) ≠ 0
                word = d_cap * "-" * _small_numbers[mod(number, 10) + 1]
                
                if isnegative
                    word = "negative " * word
                end
                return word
            end
            
            if isnegative
                d_cap = "negative " * d_cap
            end
            
            return d_cap
        end
        v += 1
    end
end

# convert a value < 1000 to english, special cased because it is the level that excludes
# the < 100 special case.  The rest are more general.  This also allows you to get
# strings in the form of "forty-five hundred" if called directly.
function __big_convert(number::Integer)::String
    isnegative = false
    if number < 0
        isnegative = true
    end
    
    number = abs(number)
    
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
        word = word * __small_convert(modulus)
    end
    
    if isnegative
        word = "negative " * word
    end
    
    return word
end

function spelled_out(number::Integer)::String
    if number < 100
        return __small_convert(number)
    end
    
    if number < 1000
        return __big_convert(number)
    end
    
    v = 0
    while v ≤ length(_scale_numbers)
        d_idx = v - 1
        d_number = Int(round(big(1000)^v))
        
        if d_number > number
            mod = Int(big(1000)^d_idx)
            # l = Int(round(number / mod))
            # r = Int(round(number - (l * mod)))
            l, r = divrem(number, mod)
            ret = __big_convert(l) * " " * _scale_numbers[d_idx]
            
            if r > 0
                ret = ret * ", " * spelled_out(r)
            end
            
            return ret
        end
        
        v += 1
    end
end

# end # end module
