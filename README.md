<h1 align="center">
    SpelledOut.jl
</h1>

<!-- [![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://jakewilliami.github.io/SpelledOut.jl/stable) -->
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://jakewilliami.github.io/SpelledOut.jl/dev)
[![CI](https://github.com/invenia/PkgTemplates.jl/workflows/CI/badge.svg)](https://github.com/jakewilliami/SpelledOut.jl/actions?query=workflow%3ACI)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
![Project Status](https://img.shields.io/badge/status-maturing-green)


## Description
This is a minimal package for a pure Julia implementation of converting numbers in their Arabic form to numbers in their natural language form.  The process of **spelling out** a number has also been referred to as **set full out**, and to write out in **long hand**.  Some people to whom I look up have suggested calling this **verbal depresentation**, to **digitate**, and&mdash;one of my favourites&mdash;to **transnumerate**.

## Quick Start
```julia
julia> using SpelledOut

julia> spelled_out(1234);

julia> spelled_out(1234, lang = :en);

julia> spelled_out(1234, lang = :en_UK);
```

See [here](https://jakewilliami.github.io/SpelledOut.jl/dev/supported_languages/#Supported-Languages) for a list of supported languages.

## Contributing
Each new language will require a language code to use it.  This code is determined by [ISO-639-1](https://www.loc.gov/standards/iso639-2/php/langcodes-keyword.php).<sup>[[1]](https://www.wikiwand.com/en/ISO_639-1)</sup>

When contributing, you should add a file and a directory: `src/<iso-639-1-lang-code>.jl`, and `src/<iso-639-1-lang-code>/`.  Within the latter, this is where you should store any language-specific dictionaries.

When implementing the main function for your language (typically called `spelled_out_<iso-639-1-lang-code>`), consider implementing methods on this function for the following types:
  - `Integer`
  - `Rational`
  - `Float64`
  - `Complex`

You can also add a fallback method and throw an error, but this should be caught by a `MethodError` anyway.  Now you can add to the main [`SpelledOut.jl`](src/SpelledOut.jl) function, in which you can add a branch for your language (following the trend).

Finally, ensure you update the documentation for [Supported Languages](https://jakewilliami.github.io/SpelledOut.jl/dev/supported_languages/#Supported-Languages).
