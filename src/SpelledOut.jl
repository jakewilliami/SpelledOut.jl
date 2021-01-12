module SpelledOut

using DecFP: Dec64

export spelled_out, Spelled_out, Spelled_Out, SPELLED_OUT

include("en.jl")

@doc raw"""
```julia
spelled_out(number; lang = :en, british = false, dict = :modern)
```

Spells out a number in words, in lowercase, given a specified language.  Current languages to choose from are:
  - `:en`
"""
function spelled_out(number::Number; lang::Symbol = :en, british::Bool = false, dict::Symbol = :modern)
    if lang == :en
        return spelled_out_en(number, british = british, dict = dict)
    end
    
    throw(error("We do not support $lang yet.  Please make an issue and someone might be able to help you, or feel free to contribute."))
    
    return nothing
end

@doc raw""""
```julia
Spelled_out(number; lang = :en, british = false, dict = :modern)
```

Spells out a number in words, starting with a capital letter, given a specified language.  Current languages to choose from are:
  - `:en`
"""
Spelled_out(number::Number; lang::Symbol = :en, british::Bool = false, dict::Symbol = :modern) =
    uppercasefirst(spelled_out(number, british=british, dict=dict))

@doc raw""""
```julia
Spelled_Out(number; lang = :en, british = false, dict = :modern)
```

Spells out a number in words, in title-case, given a specified language.  Current languages to choose from are:
  - `:en`
"""
Spelled_Out(number::Number; lang::Symbol = :en, british::Bool = false, dict::Symbol = :modern) =
    titlecase(spelled_out(number, british=british, dict=dict))

@doc raw""""
```julia
SPELLED_OUT(number; lang = :en, british = false, dict = :modern)
```

Spells out a number in words, in uppercase, given a specified language.  Current languages to choose from are:
  - `:en`
"""
SPELLED_OUT(number::Number; lang::Symbol = :en, british::Bool = false, dict::Symbol = :modern) =
    uppercase(spelled_out(number, british=british, dict=dict))

end # end module
