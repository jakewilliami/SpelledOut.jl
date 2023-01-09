# note solution may not converge
# note that while there are certain characters that are static as they are not used in spelling out words, it does not prove beneficial (actually, the opposite) to try to be clever and account for these (see commit 13f2a62)
# "This sentence has three 'a's, one 'b, two 'c's, two 'd's, thirty-three 'e's, six 'f's, one 'g, seven 'h's, nine 'i's, one 'j, one 'k, one 'l, one 'm, twenty-two 'n's, fifteen 'o's, one 'p, one 'q, seven 'r's, twenty-seven 's's, sixteen 't's, three 'u's, five 'v's, six 'w's, four 'x's, four 'y's, and one 'z."


### Imports

include(joinpath(dirname(@__DIR__), "src", "SpelledOut.jl"))
using .SpelledOut

using Base: nothing_sentinel, current_logger

using StatsBase: countmap, mean


### Constants

const ALPHABET = 'a':'z'

# This sentence has n 'a's, n 'b's, ..., and n 'z's.
# const STARTING_STR, ENDING_STR = "This pangram contains ", "."
# const STARTING_STR, ENDING_STR = "This sentence contains ", "."
# const STARTING_STR, ENDING_STR = "Only a fool would check that this sentence contains ", "."
# const STARTING_STR, ENDING_STR = "Only a fool would check that this pangram contains ", "."
const STARTING_STR, ENDING_STR = "Only a fool would check that this pangram contains ", ", and last but not least, exactly one !"
const MIDDLE_STR, MIDDLE_STR_OXFORD = ", ", ", and "
# const MIDDLE_STR, MIDDLE_STR_OXFORD = ", ", ", and last but not something, exactly"
const PLURAL_STR = "s"


### Helper functions


# Given a count map (i.e., Dict('a' => 3, 'b' => 1, ...)), construct the pangram ("This sentence contains n 'a's. n 'b's, ...")
function construct_pangram(io::IO, cm, alphabet = ALPHABET, lang = :en, use_alt_connector::Bool = false)
    alphabet_len = length(alphabet)
    # io = IOBuffer()
    print(io, STARTING_STR)
    for (i, c) in enumerate(alphabet)
        n = get(cm, c, 0)
        print(io, spelled_out(n, lang = lang))
        print(io, " '", c)
        n == 1 ? print(io, '\'') : print(io, '\'', PLURAL_STR)
        i >= (alphabet_len - 1) || print(io, MIDDLE_STR)
        i == (alphabet_len - 1) && print(io, use_alt_connector ? MIDDLE_STR_OXFORD : MIDDLE_STR)
    end
    print(io, ENDING_STR)

    return Char.(take!(io))
end


# There may occur some cycles of count maps that mean this programme never terminates.  As a result, we calculae the difference between
function rand_cm!(prev_cm, curr_cm)
    diffs! = mergewith!() do a, b
        δ = b - a
        rand(δ < 0 ? (δ:0) : (0:δ)) + a
    end
    diffs!(prev_cm, curr_cm)
    return prev_cm
end


### Main

function construct_true_pangram()
    io = IOBuffer()
    prev_cm = Dict{Char, Int}()
    i = 0
    while true
        # iszero(mod(i, 100_000)) && print(" $(i)th iteration; ")
        sentence = construct_pangram(io, prev_cm)
        curr_cm = countmap(filter(∈(ALPHABET), sentence))
        # prev_cm == curr_cm && (println(); return String(sentence), i)
        prev_cm == curr_cm && return String(sentence), i
        i += 1
        rand_cm!(prev_cm, curr_cm)
    end
    error("unreachable")
end


function main()
    sentence, i = construct_true_pangram()
    println("Found the following sentence in $i iterations:")
    println("    ", sentence)
    S = Int[]
    for _ in 1:3
        S′ = Int[last(construct_true_pangram()) for _ in 1:10]
        println("(min, max) = ", extrema(S′))
        println("average = ", mean(S′))
        append!(S, S′)
    end
    println()
    println("(min, max) = ", extrema(S))
    println("average = ", mean(S))
end

# main()
