module SpelledOut

using DecFP: Dec64

export spelled_out, Spelled_out, Spelled_Out, SPELLED_OUT

include("en.jl")

"""
```julia
spelled_out(number; lang = :en, british = false, dict = :modern)
```

Spells out a number in words, in lowercase, given a specified language.

---

### Examples

```julia
julia> spelled_out(12, lang = :en)
"twelve"

julia> spelled_out(112, lang = :en)
"one hundred twelve"

julia> spelled_out(112, lang = :en, british = true)
"one hundred and twelve"

julia> spelled_out(112, lang = :en, dict = :european)
"one hundred twelve"
```
"""
function spelled_out(number::Number; lang::Symbol = :en, british::Bool = false, dict::Symbol = :modern)
    if lang == :en
        return spelled_out_en(number, british = british, dict = dict)
    end
    
    throw(error("We do not support $lang yet.  Please make an issue and someone might be able to help you, or feel free to contribute."))
    
    return nothing
end

"""
```julia
Spelled_out(number; lang = :en, british = false, dict = :modern)
```

A wrapper for `spelled_out`.  Spells out a number in words, starting with a capital letter, given a specified language.
"""
Spelled_out(number::Number; lang::Symbol = :en, british::Bool = false, dict::Symbol = :modern) =
    uppercasefirst(spelled_out(number, lang = lang, british = british, dict = dict))

"""
```julia
Spelled_Out(number; lang = :en, british = false, dict = :modern)
```

A wrapper for `spelled_out`.  Spells out a number in words, in title-case, given a specified language.
"""
Spelled_Out(number::Number; lang::Symbol = :en, british::Bool = false, dict::Symbol = :modern) =
    titlecase(spelled_out(number, lang = lang, british = british, dict = dict))

"""
```julia
SPELLED_OUT(number; lang = :en, british = false, dict = :modern)
```

A wrapper for `spelled_out`.  Spells out a number in words, in uppercase, given a specified language.
"""
SPELLED_OUT(number::Number; lang::Symbol = :en, british::Bool = false, dict::Symbol = :modern) =
    uppercase(spelled_out(number, lang = lang, british = british, dict = dict))

end # end module
