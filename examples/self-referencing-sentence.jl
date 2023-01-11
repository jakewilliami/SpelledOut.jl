# An autogram is a sentence describing itself.  The autograms generated in the present
# programme describe its component letters with their frequencies written out in full.
#
# The idea of this came to me from a mathematician colleague who taught me during my
# undergrad.  Upon further research, I discovered the concept dates back to 1982, where the
# first autogram of this nature what published in Scientific American, and written by Lee
# Sallows, an English electronics engineer.
#
# The logic is simple: construct a sentence whose frequency/character map ("count map") are
# all zero.  Write the sentence out in full, and repeat until the sentence is true.  My
# initial solution (6aa61f9) implements this, however it did not finish.  Initially I
# thought this was due to performance problems, however I later learned (from Sallows' 1985
# piece on the Pangram Machine) that using this method, you can enter into cycles, in which
# you are constantly re-evaluating the same count-maps.  (The lengths of these cycles may
# vary, and I am yet to perform analyses on them.)  The solution here is to introduce some
# randomness: for each iteration i, find the difference for each frequency from the
# (i − 1)th  iteration, and take a random value in the range of this difference.  Doing so
# will avoid any cycles you may encounter, while still (potentially) converging to a
# solution.
#
# I say _potentially_ converging to a solution, as there may not be one.  I am unsure which
# sentences converge and why.  Further analysis of this would be required.  How can one even
# tell if a solution is present?
#
# There are certain characters that are "static" in that they are not used in the spelling
# of any reasonably small numbers, however trying to be clever and account for these in the
# iniitial state doesn't seem to do much (13f2a62).
#
# An example of the programme's output:
#     Only a fool would check that this pangram contains ten 'a's, two 'b's, five 'c's,
#     three 'd's, thirty-two 'e's, five 'f's, three 'g's, eleven 'h's, twelve 'i's, one 'j',
#     two 'k's, nine 'l's, two 'm's, twenty-two 'n's, eighteen 'o's, two 'p's, one 'q', nine
#     'r's, thirty 's's, thirty-one 't's, four 'u's, six 'v's, ten 'w's, three 'x's, seven
#     'y's, one 'z', and last but not least, exactly one !
#
# References:
#   - Hofstadter, D. Scientific American, Jan. 1982, pp 12-17.
#   - Dewdney, A.K. Scientific American, Oct. 1984, pp 18-22.
#   - Sallows, L.C.F. Abacus, Vol.2, No.3, Spring 1985, pp 22-40.
#   - ibid., Word Ways, Feb. & May 1992
#   - Autograms: https://en.wikipedia.org/wiki/Autogram
#   - Gary Doran's 'Seppy': https://github.com/garydoranjr/seppy


### Imports

include(joinpath(dirname(@__DIR__), "src", "SpelledOut.jl"))
using .SpelledOut

using Base: nothing_sentinel, current_logger

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
    prev_cm = Dict{Char, Int}()
    i = 0

    while true
        # Construct the sentence from the previoud count map and calculate the current count
        # map from that sentence
        sentence = construct_pangram(io, prev_cm; use_alt_connector = use_alt_connector)
        curr_cm = countmap(filter(∈(ALPHABET), sentence))

        # Return the solution (and the iteration at wich we found it) f one is found (which
        # is to say, if the current count map has not changed since the last time we wrote
        # out the sentence)
        prev_cm == curr_cm && return String(sentence), i
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


function main(; use_alt_connector::Bool = false, get_statistics::Bool = false, num_iterations::Int = 500)
    sentence, i = construct_autogram(use_alt_connector = use_alt_connector)
    println("Found the following sentence in $i iterations:")
    println("    ", sentence)

    if get_statistics
        println("\nCalculating iteration statistics...")
        A = Vector{Int}(undef, num_iterations)
        @showprogress for i in 1:num_iterations
            A[i] = last(construct_autogram(use_alt_connector = use_alt_connector))
        end
        open("iterations.dat", "w") do io
            for a in A
                println(io, a)
            end
        end
        println(summarystats(A))
    end
end


main(use_alt_connector = false, get_statistics = true, num_iterations = 3000)

#=
"The following sentence contains ..." (1,000 iterations)
Mean:           246,032.861
Minimum:        303
1st Quartile:   70,808.5
Median:         166,773
3rd Quartile:   352,997.25
Maximum:        1,613,014

"Only a fool would check that this pangram contains ... and last but not least, exactly
one !" (1,000 iterations)
Mean:           210,850.495
Minimum:        156
1st Quartile:   58,423.5
Median:         141,135
3rd Quartile:   297,830.5
Maximum:        1,255,652

"Only a fool would check that this pangram contains ... and last but not least, exactly
one !" (3,000 iterations)
Mean:           206,901.754333
Minimum:        98
1st Quartile:   55,599.25
Median:         139,265
3rd Quartile:   289,539.25
Maximum:        2,318,343
=#
