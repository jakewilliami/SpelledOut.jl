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
        "Home" => "index.md",
        "Supported Languages" => "supported_languages.md",
        "Usage" => "usage.md"
    ]
)

deploydocs(;
    repo  =  "github.com/jakewilliami/SpelledOut.jl.git",
)
