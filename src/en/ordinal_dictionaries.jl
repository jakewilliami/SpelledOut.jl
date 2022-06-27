const irregular = Dict("one" => "first", "two" => "second", "three" => "third", "five" => "fifth",
                                "eight" => "eighth", "nine" => "ninth", "twelve" => "twelfth")
const suffix = "th"
const ysuffix = "ieth"

ordinal(n::Integer) =
           string(n, (11 <= mod(n, 100) <= 13) ? "th" : (["th", "st", "nd", "rd", "th"][min(mod1(n, 10) + 1, 5)]))
