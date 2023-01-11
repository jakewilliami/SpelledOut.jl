function write_dot!(io::IO, cycle::Vector{Dict{Char, Int}})
    uint_to_hex_str(n::UInt) = "0x" * string(n, pad = sizeof(n)<<1, base = 16)

    io′ = IOBuffer()

    nodes = Dict{UInt64, String}(hash(d) => uint_to_hex_str(hash(d)) for d in cycle)
    countmaps = Dict{UInt64, UInt64}(hash(d) => hash(countmap(filter(∈(ALPHABET), construct_pangram(io′, d)))) for d in cycle)

    println(io, "digraph G {")
    #println(io, "rankdir=RL")
    #println(io, "node [width=0.1, shape=point]")

    for n₁ in cycle, n₂ in cycle
        h₁, h₂ = hash(n₁), hash(n₂)
        h₁ == h₂ && continue
        if h₁ == countmaps[h₂]
            m₁, m₂ = nodes[h₁], nodes[h₂]
            println(io, "\"$m₁\" -> \"$m₂\"")
        end
    end

    println(io, "}")

    return io
end

open("test.dot") do io
    write_dot!(io, cycle)
end
