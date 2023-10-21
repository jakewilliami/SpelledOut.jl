const _mi_ten = "tekau"
const _mi_ma = "mā"

# "kao" = no
# short for "kaore" = no
# Can be used to refer to nothing
# kotahi is used in context, so like "one of x" (whereas tahi is
# literally the number one)
# in counting context, kotahi, e rua, e toru, etc. up to e iwa.
# ordinal is tuatahi, tuarua, etc., up to tuaiwa
const _mi_small_numbers = String[
    "kore", "tahi", "rua", "toru", "whā", "rima", "ono", "whitu", "waru", "iwa", _mi_ten
]

const _mi_kotahi = "kotahi"
const _mi_100 = "rau"

const _mi_scale = String[
    _mi_ten, _mi_100, "mano", "miriona", "piriona"
]

const _mi_scale_large = _mi_scale[3:end]
