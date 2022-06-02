function lastsplit(predicate, s::S) where {S <: AbstractString}
    i = findlast(predicate, s)
    return isnothing(i) ? SubString(s) : SubString(s, nextind(s, i))
end

Base.findall(c::Char, s::S) where {S <: AbstractString} =
    Int[only(i) for i in findall(string(c), s)]

function ithsplit(predicate, s::S, i::Int) where {S <: AbstractString}
    j = 1 # firstindex(s)
    for _ in 1:i
        k = findnext(predicate, s, j)
        if isnothing(k)
            break
        else
            j = k
        end
    end
    return SubString()
end


split(s, _lastsplit, limit = 2)[end]
