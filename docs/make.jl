include(joinpath(dirname(@__DIR__), "src", "SpelledOut.jl"))
using Documenter, .SpelledOut

Documenter.makedocs(
    clean = true,
    doctest = true,
    modules = Module[SpelledOut],
    repo = "",
    highlightsig = true,
    sitename = "SpelledOut Documentation",
    expandfirst = [],
    pages = [
        "Index" => "index.md",
    ]
)

deploydocs(;
    repo  =  "github.com/jakewilliami/SpelledOut.jl.git",
)
