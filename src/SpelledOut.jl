module SpelledOut

using DecFP: Dec64

export spelled_out, Spelled_out, Spelled_Out, SPELLED_OUT

include("en.jl")

function spelled_out(number::Number; lang::Symbol = :en, british::Bool = false, dict::Symbol = :modern)
    if lang == :en
        return spelled_out_en(number, british = british, dict = dict)
    end
    
    throw(error("We do not support $lang yet.  Please make an issue and someone might be able to help you, or feel free to contribute."))
    
    return nothing
end

Spelled_out(number::Number; lang::Symbol = :en, british::Bool = false, dict::Symbol = :modern) =
    uppercasefirst(spelled_out(number, british=british, dict=dict))
Spelled_Out(number::Number; lang::Symbol = :en, british::Bool = false, dict::Symbol = :modern) =
    titlecase(spelled_out(number, british=british, dict=dict))
SPELLED_OUT(number::Number; lang::Symbol = :en, british::Bool = false, dict::Symbol = :modern) =
    uppercase(spelled_out(number, british=british, dict=dict))

end # end module
