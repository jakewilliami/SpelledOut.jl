#!/usr/bin/env bash
    #=
    exec julia --project="$(realpath $(dirname $(realpath $(dirname $0))))/examples/" "${BASH_SOURCE[0]}" "$@" -e "include(popfirst!(ARGS))" \
    "${BASH_SOURCE[0]}" "$@"
    =#

include(joinpath(dirname(dirname(@__FILE__)), "src", "SpelledOut.jl"))

using .SpelledOut
using Test

@testset "SpelledOut.jl" begin
    @test spelled_out(1234) == "one thousand, two hundred thirty-four"
    @test spelled_out(1234, british=true) == "one thousand, two hundred and thirty-four"
    @test Spelled_out(1234) == "One thousand, two hundred thirty-four"
    @test Spelled_Out(1234) == "One Thousand, Two Hundred Thirty-Four"
    @test SPELLED_OUT(1234) == "ONE THOUSAND, TWO HUNDRED THIRTY-FOUR"
    @test spelled_out(123456789) == "one hundred twenty-three million, four hundred fifty-six thousand, seven hundred eighty-nine"
    @test spelled_out(123456789, british=true) == "one hundred and twenty-three million, four hundred and fifty-six thousand, seven hundred and eighty-nine"
    @test spelled_out(0) == "zero"
    @test spelled_out(0, british=true) == "zero"
    @test spelled_out(100) == "one hundred"
    @test spelled_out(100, british=true) == "one hundred"
    @test spelled_out(123456789, british=true, dict=:european) == "one hundred and twenty-three million, four hundred and fifty-six thousand, seven hundred and eighty-nine"
    @test spelled_out(123456789, dict=:european) == "one hundred twenty-three million, four hundred fifty-six thousand, seven hundred eighty-nine"
    @test spelled_out(123456789, british=true, dict=:british) == "one hundred and twenty-three million, four hundred and fifty-six thousand, seven hundred and eighty-nine"
    @test spelled_out(1234567890123, british=true, dict=:british) == "one billion, two hundred and thirty-four thousand million, five hundred and sixty-seven million, eight hundred and ninety thousand, one hundred and twenty-three"
    @test spelled_out(1234567890123, british=true, dict=:modern) == "one trillion, two hundred and thirty-four billion, five hundred and sixty-seven million, eight hundred and ninety thousand, one hundred and twenty-three"
end
