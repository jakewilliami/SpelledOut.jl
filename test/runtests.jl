include(joinpath(dirname(dirname(@__FILE__)), "src", "SpelledOut.jl"))

using .SpelledOut
using Test

@testset "SpelledOut.jl" begin
    @test spelled_out(1234) == "one thousand, two hundred thirty-four"
    @test spelled_out(1234, british=true) == "one thousand, two hundred and thirty-four"
    @test Spelled_out(1234) == "One thousand, two hundred thirty-four"
    @test Spelled_Out(1234) == "One Thousand, Two Hundred Thirty-Four"
    @test SPELLED_OUT(1234) == "ONE THOUSAND, TWO HUNDRED THIRTY-FOUR"
end
