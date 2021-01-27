# include(joinpath(dirname(dirname(@__FILE__)), "src", "SpelledOut.jl")); using .SpelledOut
using Test
using SpelledOut

@testset "English" begin
    @test spelled_out(1234, lang = :en) == "one thousand, two hundred thirty-four"
    @test spelled_out(1234, lang = :en_US) == "one thousand, two hundred thirty-four"
    @test spelled_out(1234, lang = :en_UK) == "one thousand, two hundred and thirty-four"
    @test spelled_out(123456789, lang = :en) == "one hundred twenty-three million, four hundred fifty-six thousand, seven hundred eighty-nine"
    @test spelled_out(123456789, lang = :en_UK) == "one hundred and twenty-three million, four hundred and fifty-six thousand, seven hundred and eighty-nine"
    @test spelled_out(0, lang = :en) == "zero"
    @test spelled_out(0, lang = :en_UK) == "zero"
    @test spelled_out(100, lang = :en) == "one hundred"
    @test spelled_out(100, lang = :en_UK) == "one hundred"
    @test spelled_out(123456789, lang = :en_UK, dict=:european) == "one hundred and twenty-three million, four hundred and fifty-six thousand, seven hundred and eighty-nine"
    @test spelled_out(123456789, lang = :en, dict=:european) == "one hundred twenty-three million, four hundred fifty-six thousand, seven hundred eighty-nine"
    @test spelled_out(123456789, lang = :en_UK, dict=:british) == "one hundred and twenty-three million, four hundred and fifty-six thousand, seven hundred and eighty-nine"
    @test spelled_out(1234567890123, lang = :en_UK, dict=:british) == "one billion, two hundred and thirty-four thousand million, five hundred and sixty-seven million, eight hundred and ninety thousand, one hundred and twenty-three"
    @test spelled_out(1234567890123, lang = :en_UK, dict=:modern) == "one trillion, two hundred and thirty-four billion, five hundred and sixty-seven million, eight hundred and ninety thousand, one hundred and twenty-three"
    @test spelled_out(3.0, lang = :en) == "three"
    @test spelled_out(3, lang = :en) == "three"
    @test spelled_out(3.141592653589793, lang = :en) == "three point one four one five nine two six five three five eight nine seven nine three"
    @test spelled_out(2^log2(3390000), lang = :en) == "three million, three hundred ninety thousand" # should convert 3.3899999999999986e6 to an integer
    @test spelled_out(1000000.01, lang = :en) == "one million point zero one" # parse big floats correctly (i.e., avoid scientific notation.  Caveat: this is slow)
end

nothing
