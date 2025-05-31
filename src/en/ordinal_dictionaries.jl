const irregular = Dict(
    "one" => "first",
    "two" => "second",
    "three" => "third",
    "five" => "fifth",
    "eight" => "eighth",
    "nine" => "ninth",
    "twelve" => "twelfth",
)
const suffix = "th"
const ysuffix = "ieth"

function ordinal(n::Integer)
    return string(
        n,
        if (11 <= mod(n, 100) <= 13)
            "th"
        else
            (["th", "st", "nd", "rd", "th"][min(mod1(n, 10) + 1, 5)])
        end,
    )
end
