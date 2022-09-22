include(joinpath(dirname(@__DIR__), "src", "SpelledOut.jl"))
using .SpelledOut

using StatsBase

struct SentenceCountMap
    countmap::Dict{Char, Int}
    s::String
end

Base.getindex(d::SentenceCountMap, k::Char) = get(d.countmap, k, 0)
Base.setindex!(d::SentenceCountMap, v::Int, k::Char) = setindex!(d.countmap, v, k)
Base.values(d::SentenceCountMap) = values(d.countmap)
# Base.iterate(d::SentenceCountMap) = iterate(d.countmap)
# Base.iterate(d::SentenceCountMap, i::Int) = iterate(d.countmap, i)

SentenceCountMap() = 
    SentenceCountMap(Dict{Char, Int}(c => 0 for c in 'a':'z'), "")
SentenceCountMap(s::String) = 
    SentenceCountMap(countmap(filter(∈('a':'z'), lowercase(s))), s)

function construct_sentence(cm::SentenceCountMap)
    io = IOBuffer()
    print(io, "this sentence has ")
    for c in 'a':'z'
        w = spelled_out(cm[c])
        print(io, "$w '$c's")
        c == 'z' || print(io, " and ")
    end
    return String(take!(io))
end

function construct_final_sentence_doov()
    cm = SentenceCountMap()
    prev = nothing
    curr = construct_sentence(cm)
    
    while true
        cm = SentenceCountMap(curr)
        prev = curr
        curr = construct_sentence(cm)
        prev == curr && return prev
    end
    
    error("unreachable")
end

function construct_final_sentence_bonk()
    # Create initial state
    io = IOBuffer()
    print(io, "this sentence has ")
    for (i, c) in enumerate('a':'z')
        print(io, "{{$i}} '$c's")
        c == 'z' || print(io, " and ")
    end
    s = String(take!(io))
    
    # Construct initial count map and adjust sentence accordingly
    cm = SentenceCountMap(s)
    
    function update!(d::SentenceCountMap, g::Dict{Char, Int})
        # TODO: this function will only ever _add_ n to the count map,
        # which is not accurate.  We do still need to account for if, 
        # for example, 
        error("not yet implemented")
        for (c, n) in g
            d[c] += n
        end
        return d
    end
    
    # Update counts
    # TODO: do this until stabilised
    curr = copy(cm)
    for n in values(curr)
        w = spelled_out(n)
        update!(cm, countmap(w))
    end
    
    return cm
end

# println(construct_sentence())

