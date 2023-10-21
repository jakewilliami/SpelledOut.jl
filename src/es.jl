# Andrés Riedemann (January, 2021)

include(joinpath(@__DIR__, "es", "standard_es.jl"))

function es_spell_1e3(number,short_one=false)
    if number <= 99 #0 - 99
        if number<30 #1 - 30
            iszero(number) && return ""
            if isone(number) && short_one
                return "uno"
            elseif number == 21 && short_one
                return "veintiuno"
            else
                return es_1_a_29[number]
            end
        else #30-99
            unit,dec = digits(number)
            if isone(unit) && short_one
                unit_text = " y uno"
            elseif iszero(unit)
                unit_text = ""
            else
                unit_text =  " y " * es_1_a_29[unit]
            end
            return es_decenas[dec] * unit_text
        end
    elseif 100  <= number <= 999
        number == 100 && return "cien"
        unit,cent = digits(number,base=100)
        unit_text = es_spell_1e3(unit,short_one)
        return es_centenas[cent] * " "  * unit_text
    end
end

function es_spell_1e6(number,short_one=false)
    number = Int(number)
    number == 0 && return ""
    number == 1000 && return "mil"
    number <= 999 && return es_spell_1e3(number,short_one)
    low,high = digits(number,base=1000)
    low_txt = es_spell_1e3(low,short_one)
    if high == 1
        high_text = "mil "
    else
        high_text = es_spell_1e3(high,false) * " mil "
    end
    return high_text * low_txt
end

#spells only decimals, including 0
function es_spell_decimal(number,partitive=true)
    whole, decimal = split(string(number), ".")
    decnum,wholenum = abs.(modf(number))
    decimal_length = length(decimal)
    decint = decnum*10^decimal_length
    if partitive
        if decimal_length>6
            throw(error("""partitive pronunciation of spanish decimals is only supported to up to six decimals, the decimal part is $decimal .
            If you want english-like decimals (cero punto dos), try using partitive = false.
            If the decimal part seems to differ from the perceived input number, try using big numbers: `big"123.23"`.
            """))
        end

        dectext = es_spell_1e6(Dec128(decint),false)
        res = strip(dectext) * " " * es_decimales[decimal_length]
        if decint != 1
            res = res * "s"
        end
        return res
    else
        res =  digits(decint) .|> z->es_spell_1e3(z,true) .|> strip |> reverse |> z->join(z," ")
        res = "punto " * res
    end
end


function es_spell_large_map(number,i)
    if isone(i)
        return es_spell_1e6(number,true)
    elseif isone(number)
        return "un " * es_multiplos_1e6_singular[i-1]
    else

        return es_spell_1e6(number,false) * " " * es_multiplos_1e6_plural[i-1]
    end
end

function es_spell_large(_number)
    number = Int(abs(_number)) #could cause problems, as we cannot convert (yet) to big int
    list =digits(number,base=1_000_000)
    res = es_spell_large_map.(list,1:length(list)) .|> strip |> reverse |> z->join(z," ")
    (_number < 0) && (res = "menos " * res)
    return res
end


function spelled_out_es(number; dict=:standard)
    if iszero(number)
        return "cero"
    end
    if isinteger(number)
        if dict in (:standard,:large,:modern)
            res = es_spell_large(number)
        elseif dict in (:short,)
            res = es_spell_short(number)
        else
            throw(error("unrecognized dict value: $dict"))
        end
        return res
    else #with decimals

        #delete this when proper separate keywords are implemented
        partitive = true
        _dec,_int = modf(number)
        _int = Dec128(_int)
        if (_int == 0) & !partitive
            intres = "cero"

        elseif (_int == 0) & partitive
            intres = ""
        elseif dict in (:standard,:large,:modern)
            intres = es_spell_large(_int) * " con "
        elseif dict in (:short,)
            intres = es_spell_short(_int) * " con "
        else
            throw(error("unrecognized dict value: $dict"))
        end

        decres = es_spell_decimal(abs(_dec))
        return intres * decres
    end
end
