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
    @test spelled_out(1//3, lang = :en_UK) == "one third"
    @test spelled_out(1//5, lang = :en_UK) == "one fifth"
    @test spelled_out(1//102, lang = :en_UK) == "one one hundred and second"
    @test spelled_out(1//102, lang = :en_US) == "one one hundred second"
    @test spelled_out(5//102, lang = :en_UK) == "five one hundred and seconds"
    @test spelled_out(5//12, lang = :en_UK) == "five twelfths"
    @test spelled_out(1//1, lang = :en_UK) == "one"
    @test spelled_out(40//1, lang = :en_UK) == "forty"
    @test spelled_out(40//2, lang = :en_UK) == "twenty"
    @test spelled_out(40//6, lang = :en_UK) == "twenty thirds"
end



@testset "Spanish" begin
    @test spelled_out(585000, lang = :es) == "quinientos ochenta y cinco mil"
   
end

@testset "Māori" begin
    # Source: https://www.maori.cl/learn/numbers.htm
    @test spelled_out(0, lang = :mi) == "kore"
    @test spelled_out(1, lang = :mi) == "tahi"
    @test spelled_out(2, lang = :mi) == "rua"
    @test spelled_out(3, lang = :mi) == "toru"
    @test spelled_out(4, lang = :mi) == "whā"
    @test spelled_out(5, lang = :mi) == "rima"
    @test spelled_out(6, lang = :mi) == "ono"
    @test spelled_out(7, lang = :mi) == "whitu"
    @test spelled_out(8, lang = :mi) == "waru"
    @test spelled_out(9, lang = :mi) == "iwa"
    @test spelled_out(10, lang = :mi) == "tekau"
    @test spelled_out(11, lang = :mi) == "tekau mā tahi"
    @test spelled_out(12, lang = :mi) == "tekau mā rua"
    @test spelled_out(13, lang = :mi) == "tekau mā toru"
    @test spelled_out(14, lang = :mi) == "tekau mā whā"
    @test spelled_out(15, lang = :mi) == "tekau mā rima"
    @test spelled_out(16, lang = :mi) == "tekau mā ono"
    @test spelled_out(17, lang = :mi) == "tekau mā whitu"
    @test spelled_out(18, lang = :mi) == "tekau mā waru"
    @test spelled_out(19, lang = :mi) == "tekau mā iwa"
    @test spelled_out(20, lang = :mi) == "rua tekau"
    @test spelled_out(21, lang = :mi) == "rua tekau mā tahi"
    @test spelled_out(22, lang = :mi) == "rua tekau mā rua"
    @test spelled_out(23, lang = :mi) == "rua tekau mā toru"
    @test spelled_out(30, lang = :mi) == "toru tekau"
    @test spelled_out(35, lang = :mi) == ""  # TODO
    @test spelled_out(40, lang = :mi) == "whā tekau"
    @test spelled_out(50, lang = :mi) == "rima tekau"
    @test spelled_out(60, lang = :mi) == "ono tekau"
    @test spelled_out(70, lang = :mi) == "whitu tekau"
    @test spelled_out(80, lang = :mi) == "waru tekau"
    @test spelled_out(90, lang = :mi) == "iwa tekau"
    @test spelled_out(100, lang = :mi) == "kotahi rau"
    @test spelled_out(101, lang = :mi) == "kotahi rau tahi"
    @test spelled_out(111, lang = :mi) == "kotahi rau tekau mā tahi"
    @test spelled_out(200, lang = :mi) == "rua rau"
    @test spelled_out(234, lang = :mi) == "rua rau toru tekau mā whā"
    @test spelled_out(300, lang = :mi) == "toru rau"
    @test spelled_out(400, lang = :mi) == "whā rau"
    @test spelled_out(500, lang = :mi) == "rima rau"
    @test spelled_out(600, lang = :mi) == "ono rau"
    @test spelled_out(700, lang = :mi) == "whitu rau"
    @test spelled_out(800, lang = :mi) == "waru rau"
    @test spelled_out(900, lang = :mi) == "iwa rau"
    @test spelled_out(1000, lang = :mi) == "kotahi mano"
    @test spelled_out(1982, lang = :mi) == "kotahi mano, iwa rau, waru tekau mā rua"
    @test spelled_out(2000, lang = :mi) == "rua mano"
    @test spelled_out(2016, lang = :mi) == "rua mano, tekau mā ono"
    @test spelled_out(2022, lang = :mi) == ""  # TODO
    @test spelled_out(3000, lang = :mi) == "toru mano"
    @test spelled_out(4000, lang = :mi) == "whā mano"
    @test spelled_out(5000, lang = :mi) == "rima mano"
    @test spelled_out(6000, lang = :mi) == "ono mano"
    @test spelled_out(7000, lang = :mi) == "whitu mano"
    @test spelled_out(8000, lang = :mi) == "waru mano"
    @test spelled_out(9000, lang = :mi) == "iwa mano"
    @test spelled_out(9100, lang = :mi) == ""  # TODO
    @test spelled_out(10_000, lang = :mi) == "tekau mano"
    @test spelled_out(1_000_000, lang = :mi) == "kotahi miriona"
    @test spelled_out(2_000_000, lang = :mi) == "rua miriona"
    @test spelled_out(3_000_000_000, lang = :mi) == "toru piriona"
end

nothing
