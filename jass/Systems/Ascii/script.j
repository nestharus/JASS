library Ascii /* v1.1.0.0         Nestharus/Bribe
************************************************************************************
*
*   function Char2Ascii takes string s returns integer
*       integer ascii = Char2Ascii("F")
*
*   function Ascii2Char takes integer a returns string
*       string char = Ascii2Char('F')
*
*   function A2S takes integer a returns string
*       string rawcode = A2S('CODE')
*
*   function S2A takes string s returns integer
*       integer rawcode = S2A("CODE")
*
************************************************************************************/
    globals
        private integer array i //hash
        private integer array h //hash2
        private integer array y //hash3
        private string array c  //char
    endglobals
    function Char2Ascii takes string p returns integer
        local integer z = i[StringHash(p)/0x1F0748+0x40D]
        if (c[z] != p) then
            if (c[z - 32] != p) then
                if (c[h[z]] != p) then
                    if (c[y[z]] != p) then
                        if (c[83] != p) then
                            debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"ASCII ERROR: INVALID CHARACTER: " + p)
                            return 0
                        endif
                        return 83
                    endif
                    return y[z]
                endif
                return h[z]
            endif
            return z - 32
        endif
        return z
    endfunction
    function Ascii2Char takes integer a returns string
        return c[a]
    endfunction
    function A2S takes integer a returns string
        local string s=""
        loop
            set s=c[a-a/256*256]+s
            set a=a/256
            exitwhen 0==a
        endloop
        return s
    endfunction
    function S2A takes string s returns integer
        local integer a=0
        local integer l=StringLength(s)
        local integer j=0
        local string m
        local integer h
        loop
            exitwhen j==l
            set a = a*256 + Char2Ascii(SubString(s,j,j+1))
            set j=j+1
        endloop
        return a
    endfunction
    private module Init
        private static method onInit takes nothing returns nothing
            set i[966] = 8
            set i[1110] = 9
            set i[1621] = 10
            set i[1375] = 12
            set i[447] = 13
            set i[233] = 32
            set i[2014] = 33
            set i[1348] = 34
            set i[1038] = 35
            set i[1299] = 36
            set i[1018] = 37
            set i[1312] = 38
            set i[341] = 39
            set i[939] = 40
            set i[969] = 41
            set i[952] = 42
            set i[2007] = 43
            set i[1415] = 44
            set i[2020] = 45
            set i[904] = 46
            set i[1941] = 47
            set i[918] = 48
            set i[1593] = 49
            set i[719] = 50
            set i[617] = 51
            set i[703] = 52
            set i[573] = 53
            set i[707] = 54
            set i[1208] = 55
            set i[106] = 56
            set i[312] = 57
            set i[124] = 58
            set i[1176] = 59
            set i[74] = 60
            set i[1206] = 61
            set i[86] = 62
            set i[340] = 63
            set i[35] = 64
            set i[257] = 65
            set i[213] = 66
            set i[271] = 67
            set i[219] = 68
            set i[1330] = 69
            set i[1425] = 70
            set i[1311] = 71
            set i[238] = 72
            set i[1349] = 73
            set i[244] = 74
            set i[1350] = 75
            set i[205] = 76
            set i[1392] = 77
            set i[1378] = 78
            set i[1432] = 79
            set i[1455] = 80
            set i[1454] = 81
            set i[1431] = 82
            set i[1409] = 83
            set i[1442] = 84
            set i[534] = 85
            set i[1500] = 86
            set i[771] = 87
            set i[324] = 88
            set i[1021] = 89
            set i[73] = 90
            set i[1265] = 91
            set i[1941] = 92
            set i[1671] = 93
            set i[1451] = 94
            set i[1952] = 95
            set i[252] = 96
            set i[257] = 97
            set i[213] = 98
            set i[271] = 99
            set i[219] = 100
            set i[1330] = 101
            set i[1425] = 102
            set i[1311] = 103
            set i[238] = 104
            set i[1349] = 105
            set i[244] = 106
            set i[1350] = 107
            set i[205] = 108
            set i[1392] = 109
            set i[1378] = 110
            set i[1432] = 111
            set i[1455] = 112
            set i[1454] = 113
            set i[1431] = 114
            set i[1409] = 115
            set i[1442] = 116
            set i[534] = 117
            set i[1500] = 118
            set i[771] = 119
            set i[324] = 120
            set i[1021] = 121
            set i[73] = 122
            set i[868] = 123
            set i[1254] = 124
            set i[588] = 125
            set i[93] = 126
            set i[316] = 161
            set i[779] = 162
            set i[725] = 163
            set i[287] = 164
            set i[212] = 165
            set i[7] = 166
            set i[29] = 167
            set i[1958] = 168
            set i[1009] = 169
            set i[1580] = 170
            set i[1778] = 171
            set i[103] = 172
            set i[400] = 174
            set i[1904] = 175
            set i[135] = 176
            set i[1283] = 177
            set i[469] = 178
            set i[363] = 179
            set i[550] = 180
            set i[1831] = 181
            set i[1308] = 182
            set i[1234] = 183
            set i[1017] = 184
            set i[1093] = 185
            set i[1577] = 186
            set i[606] = 187
            set i[1585] = 188
            set i[1318] = 189
            set i[980] = 190
            set i[1699] = 191
            set i[1292] = 192
            set i[477] = 193
            set i[709] = 194
            set i[1600] = 195
            set i[2092] = 196
            set i[50] = 197
            set i[546] = 198
            set i[408] = 199
            set i[853] = 200
            set i[205] = 201
            set i[411] = 202
            set i[1311] = 203
            set i[1422] = 204
            set i[1808] = 205
            set i[457] = 206
            set i[1280] = 207
            set i[614] = 208
            set i[1037] = 209
            set i[237] = 210
            set i[1409] = 211
            set i[1023] = 212
            set i[1361] = 213
            set i[695] = 214
            set i[161] = 215
            set i[1645] = 216
            set i[1822] = 217
            set i[644] = 218
            set i[1395] = 219
            set i[677] = 220
            set i[1677] = 221
            set i[881] = 222
            set i[861] = 223
            set i[1408] = 224
            set i[1864] = 225
            set i[1467] = 226
            set i[1819] = 227
            set i[1971] = 228
            set i[949] = 229
            set i[774] = 230
            set i[1828] = 231
            set i[865] = 232
            set i[699] = 233
            set i[786] = 234
            set i[1806] = 235
            set i[1286] = 236
            set i[1128] = 237
            set i[1490] = 238
            set i[1720] = 239
            set i[1817] = 240
            set i[729] = 241
            set i[1191] = 242
            set i[1164] = 243
            set i[413] = 244
            set i[349] = 245
            set i[1409] = 246
            set i[660] = 247
            set i[2016] = 248
            set i[1087] = 249
            set i[1497] = 250
            set i[753] = 251
            set i[1579] = 252
            set i[1456] = 253
            set i[606] = 254
            set i[1625] = 255
            set h[92] = 47
            set h[201] = 108
            set h[201] = 76
            set h[203] = 103
            set h[203] = 71
            set h[246] = 115
            set h[246] = 83
            set h[246] = 211
            set h[254] = 187
            set y[201] = 108
            set y[203] = 103
            set y[246] = 115

            set c[8]="\b"
            set c[9]="\t"
            set c[10]="\n"
            set c[12]="\f"
            set c[13]="\r"
            set c[32]=" "
            set c[33]="!"
            set c[34]="\""
            set c[35]="#"
            set c[36]="$"
            set c[37]="%"
            set c[38]="&"
            set c[39]="'"
            set c[40]="("
            set c[41]=")"
            set c[42]="*"
            set c[43]="+"
            set c[44]=","
            set c[45]="-"
            set c[46]="."
            set c[47]="/"
            set c[48]="0"
            set c[49]="1"
            set c[50]="2"
            set c[51]="3"
            set c[52]="4"
            set c[53]="5"
            set c[54]="6"
            set c[55]="7"
            set c[56]="8"
            set c[57]="9"
            set c[58]=":"
            set c[59]=";"
            set c[60]="<"
            set c[61]="="
            set c[62]=">"
            set c[63]="?"
            set c[64]="@"
            set c[65]="A"
            set c[66]="B"
            set c[67]="C"
            set c[68]="D"
            set c[69]="E"
            set c[70]="F"
            set c[71]="G"
            set c[72]="H"
            set c[73]="I"
            set c[74]="J"
            set c[75]="K"
            set c[76]="L"
            set c[77]="M"
            set c[78]="N"
            set c[79]="O"
            set c[80]="P"
            set c[81]="Q"
            set c[82]="R"
            set c[83]="S"
            set c[84]="T"
            set c[85]="U"
            set c[86]="V"
            set c[87]="W"
            set c[88]="X"
            set c[89]="Y"
            set c[90]="Z"
            set c[91]="["
            set c[92]="\\"
            set c[93]="]"
            set c[94]="^"
            set c[95]="_"
            set c[96]="`"
            set c[97]="a"
            set c[98]="b"
            set c[99]="c"
            set c[100]="d"
            set c[101]="e"
            set c[102]="f"
            set c[103]="g"
            set c[104]="h"
            set c[105]="i"
            set c[106]="j"
            set c[107]="k"
            set c[108]="l"
            set c[109]="m"
            set c[110]="n"
            set c[111]="o"
            set c[112]="p"
            set c[113]="q"
            set c[114]="r"
            set c[115]="s"
            set c[116]="t"
            set c[117]="u"
            set c[118]="v"
            set c[119]="w"
            set c[120]="x"
            set c[121]="y"
            set c[122]="z"
            set c[123]="{"
            set c[124]="|"
            set c[125]="}"
            set c[126]="~"
            set c[128] = "€"
            set c[130] = "‚"
            set c[131] = "ƒ"
            set c[132] = "„"
            set c[133] = "…"
            set c[134] = "†"
            set c[135] = "‡"
            set c[136] = "ˆ"
            set c[137] = "‰"
            set c[138] = "Š"
            set c[139] = "‹"
            set c[140] = "Œ"
            set c[142] = ""
            set c[145] = "‘"
            set c[146] = "’"
            set c[147] = "“"
            set c[148] = "”"
            set c[149] = "•"
            set c[150] = "–"
            set c[151] = "—"
            set c[152] = "˜"
            set c[153] = "™"
            set c[154] = "š"
            set c[155] = "›"
            set c[156] = "œ"
            set c[158] = ""
            set c[159] = "Ÿ"
            set c[160] = " "
            set c[161] = "¡"
            set c[162] = "¢"
            set c[163] = "£"
            set c[164] = "¤"
            set c[165] = "¥"
            set c[166] = "¦"
            set c[167] = "§"
            set c[168] = "¨"
            set c[169] = "©"
            set c[170] = "ª"
            set c[171] = "«"
            set c[172] = "¬"
            set c[174] = "®"
            set c[175] = "¯"
            set c[176] = "°"
            set c[177] = "±"
            set c[178] = "²"
            set c[179] = "³"
            set c[180] = "´"
            set c[181] = "µ"
            set c[182] = "¶"
            set c[183] = "·"
            set c[184] = "¸"
            set c[185] = "¹"
            set c[186] = "º"
            set c[187] = "»"
            set c[188] = "¼"
            set c[189] = "½"
            set c[190] = "¾"
            set c[191] = "¿"
            set c[192] = "À"
            set c[193] = "Á"
            set c[194] = "Â"
            set c[195] = "Ã"
            set c[196] = "Ä"
            set c[197] = "Å"
            set c[198] = "Æ"
            set c[199] = "Ç"
            set c[200] = "È"
            set c[201] = "É"
            set c[202] = "Ê"
            set c[203] = "Ë"
            set c[204] = "Ì"
            set c[205] = "Í"
            set c[206] = "Î"
            set c[207] = "Ï"
            set c[208] = "Ğ"
            set c[209] = "Ñ"
            set c[210] = "Ò"
            set c[211] = "Ó"
            set c[212] = "Ô"
            set c[213] = "Õ"
            set c[214] = "Ö"
            set c[215] = "×"
            set c[216] = "Ø"
            set c[217] = "Ù"
            set c[218] = "Ú"
            set c[219] = "Û"
            set c[220] = "Ü"
            set c[221] = "İ"
            set c[222] = "Ş"
            set c[223] = "ß"
            set c[224] = "à"
            set c[225] = "á"
            set c[226] = "â"
            set c[227] = "ã"
            set c[228] = "ä"
            set c[229] = "å"
            set c[230] = "æ"
            set c[231] = "ç"
            set c[232] = "è"
            set c[233] = "é"
            set c[234] = "ê"
            set c[235] = "ë"
            set c[236] = "ì"
            set c[237] = "í"
            set c[238] = "î"
            set c[239] = "ï"
            set c[240] = "ğ"
            set c[241] = "ñ"
            set c[242] = "ò"
            set c[243] = "ó"
            set c[244] = "ô"
            set c[245] = "õ"
            set c[246] = "ö"
            set c[247] = "÷"
            set c[248] = "ø"
            set c[249] = "ù"
            set c[250] = "ú"
            set c[251] = "û"
            set c[252] = "ü"
            set c[253] = "ı"
            set c[254] = "ş"
            set c[255] = "ÿ"
        endmethod
    endmodule
    private struct Inits extends array
        implement Init
    endstruct
endlibrary