### Imports

include(joinpath(dirname(@__DIR__), "src", "SpelledOut.jl"))
using .SpelledOut

using Base: nothing_sentinel, current_logger

using JSON
using ProgressMeter: @showprogress
using StatsBase


### Constants

const ALPHABET = 'a':'z'

const STARTING_STR = "Only a fool would check that this pangram contains "
const ENDING_STR = ", and last but not least, exactly one !"
# const STARTING_STR = "This sentence contains "
# const ENDING_STR = "."
const MIDDLE_STR, MIDDLE_STR_OXFORD = ", ", ", and "
const PLURAL_STR = "s"


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
    io = IOBuffer()
    prev_cm = Dict{Char, Int}(c => rand(1:40) for c in ALPHABET)  # Random initial state
    # prev_cm = Dict{Char, Int}()
    seen = Set{UInt}()
    i = 0
    cycle = Vector{Dict{Char, Int}}()
    cycle_marker = nothing
    in_cycle = false

    while true
        # Construct the sentence from the previoud count map and calculate the current count
        # map from that sentence
        sentence = construct_pangram(io, prev_cm; use_alt_connector = use_alt_connector)
        curr_cm = countmap(filter(∈(ALPHABET), sentence))

        h = hash(curr_cm)
        # println(h)

        if in_cycle || h ∈ seen
            if !in_cycle
                # then we have just started a cycle
                cycle_marker = h
                in_cycle = true
            else
                in_cycle = !(h == cycle_marker)
            end
            in_cycle || return i, cycle
            in_cycle && push!(cycle, curr_cm)
        else
            push!(seen, h)
        end

        # Return the solution (and the iteration at wich we found it) f one is found (which
        # is to say, if the current count map has not changed since the last time we wrote
        # out the sentence)
        (!in_cycle && !isempty(cycle)) && return i, cycle
        # prev_cm == curr_cm && return String(sentence), i, cycle
        i += 1
        i > 3_000_000 && error("Too high ($(length(cycle)), $in_cycle, $cycle_marker)")

        # We need to reset the previous counts with the current count map, ± δ, a random
        # integer within a reasonable range (which must be random to avoid cycles)
        prev_cm = curr_cm

        #=diffs! = mergewith!() do a, b
            δ = b - a
            rand(δ < 0 ? (δ:0) : (0:δ)) + a
        end
        diffs!(prev_cm, curr_cm)=#
    end

    error("unreachable")
end


function main(; use_alt_connector::Bool = false, sample_size::Int = 500)
    i, cycle = construct_autogram(use_alt_connector = use_alt_connector)
    println("Found a cycle of length $(length(cycle)) in $i iterations")

    println("\nSampling cycles...")
    # A = Vector{Vector{Dict{Char, Int}}}(undef, sample_size)
    A = Vector{Vector{Dict{Char, Int}}}()
    @showprogress for i in 1:sample_size
        cycle = last(construct_autogram(use_alt_connector = use_alt_connector))
        # A[i] = cycle
        length(cycle) ∈ (2, 8, 13, 52, 988) || push!(A, cycle)
    end

    open("data/cycles-rare-100000-rand-1-to-40.json", "w") do io
        JSON.print(io, A)
    end

    println(summarystats(length.(A)))
end


main(use_alt_connector = false, sample_size = 100_000)
