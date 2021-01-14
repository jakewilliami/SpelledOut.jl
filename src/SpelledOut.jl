module SpelledOut

using DecFP: Dec64

export spelled_out, Spelled_out, Spelled_Out, SPELLED_OUT

include("en.jl")

"""
```julia
spelled_out(number; lang = :en, dict = :modern)
```

Spells out a number in words, in lowercase, given a specified language.  The `dict` keyword argument only applies to some languages; see "Supported Languages" in the docs for more information.

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
function spelled_out(number::Number; lang::Symbol = :en, dict::Symbol = :modern)
    if lang == :en || lang == :en_US
        return spelled_out_en(number, british = false, dict = dict)
    elseif lang == :en_UK
        return spelled_out_en(number, british = true, dict = dict)
    end
    
    throw(error("We do not support $lang yet.  Please make an issue and someone might be able to help you, or feel free to contribute."))
    
    return nothing
end

end # end module
