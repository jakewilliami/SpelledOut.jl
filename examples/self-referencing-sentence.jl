# note solution may not converge
# "This sentence has three 'a's, one 'b, two 'c's, two 'd's, thirty-three 'e's, six 'f's, one 'g, seven 'h's, nine 'i's, one 'j, one 'k, one 'l, one 'm, twenty-two 'n's, fifteen 'o's, one 'p, one 'q, seven 'r's, twenty-seven 's's, sixteen 't's, three 'u's, five 'v's, six 'w's, four 'x's, four 'y's, and one 'z."

include(joinpath(dirname(@__DIR__), "src", "SpelledOut.jl"))
using .SpelledOut

using Base: nothing_sentinel, current_logger

using StatsBase: countmap, mean


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


# there are some letters which never occur in low-valued cardiinals: A,B,C,D,j,K,M,P,Q,Z, so
# they can be filled in from the initial text directly
# No letter should have more than fourty occurences of it
function find_rule_out_chars(alphabet = ALPHABET, upper::Int = 40, lang::Symbol = :en)
    S = Set{Char}()
    for n in 1:upper
        s = spelled_out(n, lang = lang)
        for c in s
            push!(S, c)
        end
    end
    return setdiff(alphabet, S)
end


# Given a count map (i.e., Dict('a' => 3, 'b' => 1, ...)), construct the pangram
# TODO: Ignore if zero?  NO!  Because then it wouldn't be a pangram
function construct_pangram(cm, alphabet = ALPHABET, lang = :en)
    io = IOBuffer()
    print(io, STARTING_STR)
    for c in alphabet
        n = get(cm, c, 0)
        print(io, spelled_out(n, lang = lang))
        print(io, " '", c)
        n == 1 ? print(io, '\'') : print(io, '\'', PLURAL_STR)
        c ∈ ('y', 'z') || print(io, MIDDLE_STR)  # TODO: use last and secondtolast here
        # c == 'y' && print(io, MIDDLE_STR_OXFORD)
        c == 'y' && print(io, MIDDLE_STR)
    end
    print(io, ENDING_STR)

    return Char.(take!(io))
end


# Construct an initial sentence and set the
# TODO: rename
function get_static_counts(alphabet = ALPHABET, upper::Int = 40, lang::Symbol = :en)
    # Construct initial sentence with no values
    sentence = construct_pangram(Dict{Char, Int}(c => 1 for c in ALPHABET))
    cm = countmap(sentence)

    # Add constant characters to initial sentence
    static_chars = find_rule_out_chars(alphabet, upper, lang)
    cm′ = Dict{Char, Int}(c => (c ∈ static_chars ? cm[c] : 1) for c in ALPHABET)
    sentence′ = construct_pangram(cm′)

    # println(repr(String(copy(sentence′))))
    return sentence′
end

function construct_true_pangram()
    # prev_cm = get_static_counts(STARTING_STR, ENDING_STR, MIDDLE_STR, PLURAL_STR)  # TODO: make get_static_counts use construct_pangram
    prev_cm = get_static_counts()
    prev_cm = Dict{Char, Int}()
    i = 0
    while true
        # iszero(mod(i, 100_000)) && print(" $(i)th iteration; ")
        sentence = construct_pangram(prev_cm)
        curr_cm = countmap(filter(∈(ALPHABET), sentence))
        # prev_cm == curr_cm && (println(); return String(sentence), i)
        prev_cm == curr_cm && return String(sentence), i
        i += 1
        # prev_cm = rand_cm(prev_cm, curr_cm, mod(i, 100) == 0)
        prev_cm = rand_cm(prev_cm, curr_cm)
    end
    error("unreachable")
end


# There may occur some cycles of count maps that mean this programme never terminates.  As a result, we calculae the difference between
function rand_cm!(prev_cm, curr_cm, alphabet = ALPHABET)
    ans = Dict{Char, Int}()
    # diffs = cm_diffs(prev_cm, curr_cm)

    diffs = mergewith(-, curr_cm, prev_cm)
    for c in alphabet
        δ = diffs[c]
        # δ = get(diffs, c, 0)
        # change = rand(0:δ)
        change = rand(δ < 0 ? (δ:0) : (0:δ))
        # change = rand(0:abs(δ)) * sign(δ)
        ans[c] = change + get(prev_cm, c, 0)
    end
    return ans
end

# Main function: construct true pangram!!
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
