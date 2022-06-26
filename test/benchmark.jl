using SpelledOut
using BenchmarkTools

@btime spelled_out($123456789, lang = $:en_UK)
