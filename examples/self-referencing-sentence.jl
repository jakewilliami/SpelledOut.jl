include(joinpath(dirname(@__DIR__), "src", "SpelledOut.jl"))
using .SpelledOut

using StatsBase

struct SentenceCountMap
    countmap::Dict{Char, Int}
end

Base.get(d::SentenceCountMap, k::Char) = get(d.countmap, k, 0)
Base.setindex!(d::SentenceCountMap, v::Int, k::Char) = setindex!(d.countmap, v, k)

SentenceCountMap() = 
    SentenceCountMap(Dict{Char, Int}(c => 0 for c in 'a':'z'))
SentenceCountMap(s::String) = 
    SentenceCountMap(countmap(filter(∈('a':'z'), lowercase(s))))

function construct_sentence()
    # Create initial state
    io = IOBuffer()
    print(io, "this sentence has ")
    for (i, c) in enumerate('a':'z')
        print(io, "{{$i}} '$c's")
        c == 'z' || print(io, " and ")
    end
    s = String(take!(io))
    
    # Construct initial count map and adjust sentence accordingly
    counts = SentenceCountMap(s)
    
    # TODO: complete example
    
    return counts
end

println(construct_sentence())

