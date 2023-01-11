### Imports

include(joinpath(dirname(@__DIR__), "src", "SpelledOut.jl"))
using .SpelledOut

using Base: nothing_sentinel, current_logger

using JSON
using ProgressMeter
using StatsBase


### Constants

const ALPHABET = 'a':'z'

const STARTING_STR = "Only a fool would check that this pangram contains "
const ENDING_STR = ", and last but not least, exactly one !"
# const STARTING_STR = "This sentence contains "
# const ENDING_STR = "."
const MIDDLE_STR, MIDDLE_STR_OXFORD = ", ", ", and "
const PLURAL_STR = "s"

const MAX_PATH_LEN = 500


### Helper functions

# Given a count map (i.e., Dict('a' => 3, 'b' => 1, ...)), construct the autogram ("This
# sentence contains n 'a's. n 'b's, ...")
function construct_pangram(
    io::IO,
    cm::Dict{Char, Int};
    alphabet = ALPHABET,
    lang = :en,
    use_alt_connector::Bool = false,
)
    alphabet_len = length(alphabet)
    print(io, STARTING_STR)

    for (i, c) in enumerate(alphabet)
        n = get(cm, c, 0)
        print(io, spelled_out(n, lang = lang), " '", c)

        # Optionally pluralise the word
        n == 1 ? print(io, '\'') : print(io, '\'', PLURAL_STR)

        # Optionally print connectors between words, such as commas or "and"
        i >= (alphabet_len - 1) || print(io, MIDDLE_STR)
        i == (alphabet_len - 1) &&
            print(io, use_alt_connector ? MIDDLE_STR_OXFORD : MIDDLE_STR)
    end

    print(io, ENDING_STR)

    return Char.(take!(io))
end


### Main

function construct_autogram(; use_alt_connector::Bool = false)
    D = Vector{Dict{Char, Int}}()
    io = IOBuffer()
    prev_cm = Dict{Char, Int}()
    i = 1  # TODO: potentially change back to 0

    while true
        # Construct the sentence from the previoud count map and calculate the current count
        # map from that sentence
        sentence = construct_pangram(io, prev_cm; use_alt_connector = use_alt_connector)
        curr_cm = countmap(filter(∈(ALPHABET), sentence))
        push!(D, curr_cm)

        length(D) > MAX_PATH_LEN && return String(sentence), i, D  # TODO: potentially remove if I want real answers

        # Return the solution (and the iteration at wich we found it) f one is found (which
        # is to say, if the current count map has not changed since the last time we wrote
        # out the sentence)
        prev_cm == curr_cm && return String(sentence), i, D
        i += 1

        # We need to reset the previous counts with the current count map, ± δ, a random
        # integer within a reasonable range (which must be random to avoid cycles)
        diffs! = mergewith!() do a, b
            δ = b - a
            rand(δ < 0 ? (δ:0) : (0:δ)) + a
        end
        diffs!(prev_cm, curr_cm)
    end

    error("unreachable")
end

uint_to_hex_str(n::UInt) = "0x" * string(n, pad = sizeof(n)<<1, base = 16)

function write_dot!(io::IO, path::Vector{Dict{Char, Int}})
    io′ = IOBuffer()
    # println(path)
    nodes = Dict{UInt64, String}(hash(d) => uint_to_hex_str(hash(d)) for d in path)
    countmaps = Dict{UInt64, UInt64}(hash(d) => hash(countmap(filter(∈(ALPHABET), construct_pangram(io′, d)))) for d in path)

    println(io, "digraph G {")
    #println(io, "rankdir=RL")
    #println(io, "node [width=0.1, shape=point]")

    # @showprogress for i₁ in 1:length(path), i₂ in (i₁ + 1):length(path)
    @showprogress for i₁ in 1:length(path), i₂ in 1:length(path)
        n₁, n₂ = path[[i₁, i₂]]
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


function main_write(; use_alt_connector::Bool = false, sample_size::Int = 500, num_sample::Int = 2)
    sentence, i = construct_autogram(use_alt_connector = use_alt_connector)
    println("Found the following sentence in $i iterations:")
    println("    ", sentence)

    ten_smallest = Vector{Vector{Dict{Char, Int}}}()
    max_smallest_len =  typemax(Int)

    i = 0
    p = Progress(sample_size, 1)
    while i <= sample_size
        _, n, V = construct_autogram(use_alt_connector = use_alt_connector)
        n > MAX_PATH_LEN && continue
        if length(ten_smallest) == num_sample && n < max_smallest_len
            j = findfirst(d -> length(d) == max_smallest_len, ten_smallest)
            ten_smallest[j] = V
        elseif length(ten_smallest) < num_sample
            push!(ten_smallest, V)
        else
            continue
        end

        i += 1
        next!(p)

        max_smallest_len = maximum(length, ten_smallest)
    end

    # Serialise data in case I want it
    open("data/graphs/data.json", "w") do io
        JSON.print(io, ten_smallest)
    end

    # Write GraphViz files
    for (i, V) in enumerate(ten_smallest)
        println("$(i): Writing path with length $(length(V))...")
        open("data/graphs/converging-path-$(length(V)).dot", "w") do io
            write_dot!(io, V)
        end
    end
end


main_write(use_alt_connector = false, sample_size = 10, num_sample = 10)
