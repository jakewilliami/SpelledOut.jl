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
    D = Vector{Dict{Char, Int}}()
    io = IOBuffer()
    prev_cm = Dict{Char, Int}()
    i = 0

    while true
        # Construct the sentence from the previoud count map and calculate the current count
        # map from that sentence
        sentence = construct_pangram(io, prev_cm; use_alt_connector = use_alt_connector)
        curr_cm = countmap(filter(∈(ALPHABET), sentence))
        push!(D, curr_cm)

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

using Luxor, Colors, Cairo


function main_write(; use_alt_connector::Bool = false, get_statistics::Bool = false, sample_size::Int = 500)
    sentence, i = construct_autogram(use_alt_connector = use_alt_connector)
    println("Found the following sentence in $i iterations:")
    println("    ", sentence)

    if get_statistics
        println("\nCalculating iteration statistics...")
        A = Vector{Vector{Dict{Char, Int}}}(undef, sample_size)
        I = Vector{Int}(undef, sample_size)


	    golden_angle = 137.5
	    angle = golden_angle
	    # angle = 42

	    # Drawing(600, 400, joinpath(dirname(dirname(@__FILE__)), "other", "turtle_drawing.pdf"))
	    Drawing(10000, 10000, joinpath("data/turtle_drawing_$(sample_size)_$(angle).pdf"))
	    origin()
	    # background("midnightblue")

        🐢 = Turtle()
	    Pencolor(🐢, "black")
	    Penwidth(🐢, 1.5)
	    n = 5


        for i in 1:sample_size
            _, n, D = construct_autogram(use_alt_connector = use_alt_connector)
            I[i] = n

            for j in 1:length(D)
                Turn(🐢, angle)
            end
            Forward(🐢, n)
        end

        Luxor.finish()
        println(summarystats(I))
        return


        @showprogress for i in 1:sample_size
            _, n, D = construct_autogram(use_alt_connector = use_alt_connector)
            I[i] = n
            A[i] = D
        end

        open("data/sequence.json", "w") do io
            JSON.print(io, A)
        end

        println(summarystats(I))
    end
end


function main_read()
    error("not yet implemented")
end


main_write(use_alt_connector = false, get_statistics = true, sample_size = 10)
