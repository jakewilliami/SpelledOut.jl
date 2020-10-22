module SpelledOut

export spelled_out, Spelled_out, Spelled_Out, SPELLED_OUT

const _small_numbers = String[
    "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten",
    "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"]
const _tens = String[
    "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"]
# The scale_numbers are US, Canada and modern British (short scale)
const _scale_modern = String[
    "thousand",             "million",              "billion",                "trillion",               "quadrillion",
    "quintillion",          "sextillion",           "septillion",             "octillion",              "nonillion",
    "decillion",            "undecillion",          "duodecillion",           "tredecillion",           "quattuordecillion",
    "sexdecillion",         "septendecillion",      "octodecillion",          "novemdecillion",         "vigintillion",
    "unvigintillion",       "duovigintillion",      "tresvigintillion",       "quattuorvigintillion",   "quinvigintillion",
    "sesvigintillion",      "septemvigintillion",   "octovigintillion",       "novemvigintillion",      "trigintillion",
    "untrigintillion",      "duotrigintillion",     "trestrigintillion",      "quattuortrigintillion",  "quintrigintillion",
    "sestrigintillion",     "septentrigintillion",  "octotrigintillion",      "noventrigintillion",     "quadragintillion"]
const _scale_traditional_british = String[
    "million",               "thousand million",     "billion",                   "thousand billion",        "trillion",
    "thousand trillion",     "quadrillion",          "thousand quadrillion",      "quintillion",             "thousand quintillion",
    "sextillion",            "thousand sextillion",  "septillion",                "thousand septillion",     "octillion",
    "thousand octillion",    "nonillion",            "thousand nonillion",        "decillion",               "thousand decillion",
    "undecillion",           "thousand undecillion", "duodecillion",              "thousand duodecillion",   "tredecillion",
    "thousand tredecillion", "quattuordecillion",    "thousand quattuordecillion","quindecillion",           "thousand quindecillion",
    "sedecillion",           "thousand sedecillion", "septendecillion",           "thousand septendecillion","octodecillion",
    "thousand octodecillion","novendecillion",       "thousand novendecillion",   "vigintillion",            "thousand vigintillion"]
const _scale_traditional_european = String[
    "million",               "milliard",              "billion",           "billiard",             "trillion",
    "trilliard",             "quadrillion",           "quadrilliard",      "quintillion",          "quintilliard",
    "sextillion",            "sextilliard",           "septillion",        "septilliard",          "octillion",
    "octilliard",            "nonillion",             "nonilliard",        "decillion",            "decilliard",
    "undecillion",           "undecilliard",          "duodecillion",      "duodecilliard",        "tredecillion",
    "tredecilliard",         "quattuordecillion",     "quattuordecilliard","quindecillion",        "quindecilliard",
    "sedecillion",           "sedecilliard",          "septendecillion",   "septendecilliard",     "octodecillion",
    "octodecilliard",        "novendecillion",        "novendecilliard",   "vigintillion",         "vigintilliard"]
# the following large scale terms have not been implemented, as their increases are not linear.  See here: https://www.wikiwand.com/en/Names_of_large_numbers#/Extensions_of_the_standard_dictionary_numbers
const _large_scale_modern = String[
"quinquagintillion",    "sexagintillion",       "septuagintillion",       "octogintillion",         "nonagintillion",
"centillion",           "uncentillion",         "decicentillion",         "undecicentillion",       "viginticentillion",
"unviginticentillion",  "trigintacentillion",   "quadragintacentillion",  "quinquagintacentillion", "sexagintacentillion",
"septuagintacentillion","octogintacentillion",  "onagintacentillion",     "ducentillion",           "trecentillion",
"quadringentillion",    "quingentillion",       "sescentillion",          "septingentillion",       "octingentillion",
"nongentillion",        "millinillion"]
const _large_scale_traditional_british = String[]
const _large_scale_traditional_european = String[]
const limit = BigInt(big(10)^120)
    
# convert a value < 100 to English.
function __small_convert(number::Integer; british::Bool=false)::String
    scale_numbers = _scale_modern # define scale type
    if number < 20
        word = _small_numbers[number + 1]
        
        return word
    end
    
    v = 1
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
function __big_convert(number::Integer; british::Bool=false)::String
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
        word = word * __small_convert(modulus, british=british)
    end
    
    return word
end

function spelled_out(number::Integer; british::Bool=false)::String
    scale_numbers = _scale_modern # define scale type
    number = big(number)
    isnegative = false
    if number < 0
        isnegative = true
    end
    number = abs(number)
    if number > limit - 1
        throw(error("SpelledOut.jl does not support numbers larger than $(spelled_out(limit - 1)).  Sorry about that!"))
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
    while v ≤ length(scale_numbers)
        d_idx = v
        d_number = BigInt(round(big(1000)^v))
        
        if d_number > number
            modulus = BigInt(big(1000)^(d_idx - 1))
            l, r = divrem(number, modulus)
            word = __big_convert(l, british=british) * " " * scale_numbers[d_idx - 1]
            
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

function spelled_out(number::AbstractFloat; british::Bool=false)::String
    type = typeof(number)
    number = big(number)
    
    try
        number = BigInt(number)
    catch
        throw(error("Cannot parse an object of type `$(type)` into the required integer type."))
    end
    
    return spelled_out(number, british=british)
end

Spelled_out(number::Real; british::Bool=false)::String = uppercasefirst(spelled_out(number, british=british))
Spelled_Out(number::Real; british::Bool=false)::String = titlecase(spelled_out(number, british=british))
SPELLED_OUT(number::Real; british::Bool=false)::String = uppercase(spelled_out(number, british=british))

end # end module
