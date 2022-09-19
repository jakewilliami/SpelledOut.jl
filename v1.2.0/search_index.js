var documenterSearchIndex = {"docs":
[{"location":"usage/#Usage","page":"Usage","title":"Usage","text":"","category":"section"},{"location":"usage/","page":"Usage","title":"Usage","text":"Modules = [SpelledOut]","category":"page"},{"location":"usage/#Main.SpelledOut.spelled_out-Tuple{Number}","page":"Usage","title":"Main.SpelledOut.spelled_out","text":"function spelled_out(\n    number::Number;\n    lang::Symbol = <locale language>,\n    dict::Symbol = :modern\n)\n\nSpells out a number in words, in lowercase, given a specified language.  The default language is the one used on your system.  The dict keyword argument only applies to some languages; see \"Supported Languages\" in the docs for more information.\n\n\n\nExamples\n\njulia> spelled_out(12, lang = :en)\n\"twelve\"\n\njulia> spelled_out(112, lang = :en)\n\"one hundred twelve\"\n\njulia> spelled_out(112, lang = :en_GB)\n\"one hundred and twelve\"\n\njulia> spelled_out(112, lang = :en, dict = :european)\n\"one hundred twelve\"\n\njulia> spelled_out(112, lang = :es)\n\"ciento doce\"\n\njulia> spelled_out(19, lang = :pt_BR)\n\"dezenove\"\n\njulia> spelled_out(19, lang = :pt)\n\"dezanove\"\n\n\n\n\n\n","category":"method"},{"location":"supported_languages/#Supported-Languages","page":"Supported Languages","title":"Supported Languages","text":"","category":"section"},{"location":"supported_languages/","page":"Supported Languages","title":"Supported Languages","text":"Current languages to choose from are:","category":"page"},{"location":"supported_languages/","page":"Supported Languages","title":"Supported Languages","text":"English\nVariants\n:en_US (aliases: :en)\n:en_UK (aliases: :en_GB; equivalencies: :en_NZ, :en_AU)\nDictionaries supported include :modern, :british, and :european, and default to the former.\nSpanish (:es)\nPortuguese \nVariants\n(:pt_BR)\n(:pt)","category":"page"},{"location":"#Home","page":"Home","title":"Home","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This is a minimal package for a pure Julia implementation of converting numbers in their Arabic form to numbers in their language form. The process of spelling out a number has also been referred to as set full out, to write out in long hand, and — as a great mind once suggested — to transnumerate.","category":"page"},{"location":"#Caveats","page":"Home","title":"Caveats","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Unfortunately, as this library requires DecFP for spelling out floats as expected, we cannot support i686 (32-bit) systems.","category":"page"},{"location":"#Contents","page":"Home","title":"Contents","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = SpelledOut\nDocTestSetup = quote\n    using SpelledOut\nend","category":"page"},{"location":"#Installing-SpelledOut.jl","page":"Home","title":"Installing SpelledOut.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"using Pkg\nPkg.add(\"SpelledOut\")","category":"page"},{"location":"#Index","page":"Home","title":"Index","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"","category":"page"}]
}
