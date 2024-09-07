module SpelledOut

using DecFP: Dec64, Dec128
using Format: format

export spelled_out, Spelled_out, Spelled_Out, SPELLED_OUT

include("en.jl")
include("es.jl")
include("pt.jl")

"""
```julia
function spelled_out(
    number::Number;
    lang::Symbol = <locale language>,
    dict::Symbol = :modern
)
```

Spells out a number in words, in lowercase, given a specified language.  The default language is the one used on your system.  The `dict` keyword argument only applies to some languages; see "Supported Languages" in the docs for more information.

---

### Examples

```julia
julia> spelled_out(12, lang = :en)
"twelve"

julia> spelled_out(112, lang = :en)
"one hundred twelve"

julia> spelled_out(112, lang = :en_GB)
"one hundred and twelve"

julia> spelled_out(112, lang = :en, dict = :european)
"one hundred twelve"

julia> spelled_out(112, lang = :es)
"ciento doce"

julia> spelled_out(19, lang = :pt_BR)
"dezenove"

julia> spelled_out(19, lang = :pt)
"dezanove"
```
"""
function spelled_out(
    number::Number;
    lang::Symbol = Symbol(ENV["LANG"][1:(findfirst(==('.'), ENV["LANG"]) - 1)]), # Symbol(first(split(ENV["LANG"], '.')))
    dict::Symbol = :modern
)

    if lang ∈ (:en, :en_US)
        return spelled_out_en(number, british = false, dict = dict)
    elseif lang ∈ (:en_UK, :en_GB, :en_NZ, :en_AU)
        return spelled_out_en(number, british = true, dict = dict)
    elseif lang ∈ (:es,)
        return spelled_out_es(number; dict = dict)
    elseif lang ∈ (:pt_BR,)
        return spelled_out_pt(number; portugal = false, dict = dict)
    elseif lang ∈ (:pt,)
        return spelled_out_pt(number; portugal = true, dict = dict)
    end

    throw(error("We do not support $lang yet.  Please make an issue and someone might be able to help you, or feel free to contribute."))

    return nothing
end

end # end module
