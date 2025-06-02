function spelled_out_ru(number::Number)
    

end

# Fallback method if we do not know how to handle the input
function spelled_out_ru(number)
    throw(error("Cannot parse type $(typeof(number)).  Please make an issue."))
end
