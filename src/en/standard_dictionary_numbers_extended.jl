const _small_numbers = String[
    "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten",
    "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"]

const _small_number_dictionary = Dict{Char, String}(
    '0' => "zero", '1' => "one", '2' => "two", '3' => "three", '4' => "four", '5' => "five", '6' => "six",
    '7' => "seven", '8' => "eight", '9' => "nine")

const _tens = String[
    "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"]

# The scale_numbers are US, Canada and modern British (short scale)
const _scale_modern = String[
    "thousand",             "million",              "billion",                "trillion",               "quadrillion",
    "quintillion",          "sextillion",           "septillion",             "octillion",              "nonillion",
    "decillion",            "undecillion",          "duodecillion",           "tredecillion",           "quattuordecillion",
    "quindecillion",        "sexdecillion",         "septendecillion",        "octodecillion",          "novemdecillion",
    "vigintillion",         "unvigintillion",       "duovigintillion",        "tresvigintillion",       "quattuorvigintillion",
    "quinvigintillion",     "sesvigintillion",      "septemvigintillion",     "octovigintillion",       "novemvigintillion",
    "trigintillion",        "untrigintillion",      "duotrigintillion",       "trestrigintillion",      "quattuortrigintillion",
    "quintrigintillion",    "sestrigintillion",     "septentrigintillion",    "octotrigintillion",      "noventrigintillion",
    "quadragintillion"
    ]

const _scale_traditional_british = String[
    "thousand",              "million",               "thousand million",          "billion",                   "thousand billion",
    "trillion",              "thousand trillion",     "quadrillion",               "thousand quadrillion",      "quintillion",
    "thousand quintillion",  "sextillion",            "thousand sextillion",       "septillion",                "thousand septillion",    "octillion",             "thousand octillion",    "nonillion",                 "thousand nonillion",        "decillion",
    "thousand decillion",    "undecillion",           "thousand undecillion",      "duodecillion",              "thousand duodecillion",
    "tredecillion",          "thousand tredecillion", "quattuordecillion",         "thousand quattuordecillion","quindecillion",
    "thousand quindecillion","sedecillion",           "thousand sedecillion",      "septendecillion",           "thousand septendecillion",
    "octodecillion",         "thousand octodecillion","novendecillion",            "thousand novendecillion",   "vigintillion",
    "thousand vigintillion"
    ]

const _scale_traditional_european = String[
    "thousand",              "million",               "milliard",          "billion",              "billiard",
    "trillion",              "trilliard",             "quadrillion",       "quadrilliard",         "quintillion",
    "quintilliard",          "sextillion",            "sextilliard",       "septillion",           "septilliard",
    "octillion",             "octilliard",            "nonillion",         "nonilliard",           "decillion",
    "decilliard",            "undecillion",           "undecilliard",      "duodecillion",         "duodecilliard",
    "tredecillion",          "tredecilliard",         "quattuordecillion", "quattuordecilliard",   "quindecillion",
    "quindecilliard",        "sedecillion",           "sedecilliard",      "septendecillion",      "septendecilliard",
    "octodecillion",         "octodecilliard",        "novendecillion",    "novendecilliard",      "vigintillion",
    "vigintilliard"
    ]

const limit = BigInt(big(10)^120)
const limit_str = "10^120"
