<h1 align="center">
    SpelledOut.jl
</h1>

[![Code Style: Blue][code-style-img]][code-style-url] [![Build Status](https://travis-ci.com/jakewilliami/SpelledOut.jl.svg?branch=master)](https://travis-ci.com/jakewilliami/SpelledOut.jl) ![Project Status](https://img.shields.io/badge/status-maturing-green)


## Description
This is a minimal package for a pure Julia implementation of converting numbers in their Arabic form to numbers in their Anglo-Saxan form.  The process of **spelling out** a number has also been referred to as **set full out**, to write out in **long hand**, and &mdash; as a great mind once suggested &mdash; to **transnumerate**.

## Examples

```julia
julia> spell_out(12)
"twelve"

julia> Spell_out(12)
"Twelve"

julia> Spell_Out(12)
"Twelve"

julia> Spell_Out(100)
"One Hundred"
```