library MD5 /* v1.0.0.0
*************************************************************************************
*
*   */uses/*
*   
*       */ BitInt   /*      hiveworkshop.com/forums/jass-resources-412/snippet-bitint-226174/
*       */ Or32     /*      hiveworkshop.com/forums/submissions-414/snippet-byte-222894/
*       */ And32    /*      hiveworkshop.com/forums/submissions-414/snippet-byte-222868/
*       */ Not32    /*      hiveworkshop.com/forums/submissions-414/snippet-byte-not-225161/
*       */ Xor32    /*      hiveworkshop.com/forums/jass-resources-412/snippet-byte-xor-222642/
*
************************************************************************************
*
*   function MD5 takes BitInt data returns BitInt
*       -   Generates MD5 hash as BitInt for input data
*
*************************************************************************************/
    globals
        private integer array buffer
        
        private integer state0
        private integer state1
        private integer state2
        private integer state3
    endglobals
    
    //! textmacro MD5_ROUND0 takes a, b, c, d, k, s, t
        set $a$ = $a$ + XOR32($d$, AND32($b$, XOR32($c$, $d$))) + $t$ + buffer[$k$]
        set $a$ = $b$ + OR32(ShiftLeft($a$, $s$), ShiftRight($a$, 32 - $s$))
    //! endtextmacro
    //! textmacro MD5_ROUND1 takes a, b, c, d, k, s, t
        set $a$ = $a$ + XOR32($c$, AND32($d$, XOR32($b$, $c$))) + $t$ + buffer[$k$]
        set $a$ = $b$ + OR32(ShiftLeft($a$, $s$), ShiftRight($a$, 32 - $s$))
    //! endtextmacro
    //! textmacro MD5_ROUND2 takes a, b, c, d, k, s, t
        set $a$ = $a$ + XOR32(XOR32($b$, $c$), $d$) + $t$ + buffer[$k$]
        set $a$ = $b$ + OR32(ShiftLeft($a$, $s$), ShiftRight($a$, 32 - $s$))
    //! endtextmacro
    //! textmacro MD5_ROUND3 takes a, b, c, d, k, s, t
        set $a$ = $a$ + XOR32($c$, OR32($b$, NOT32($d$))) + $t$ + buffer[$k$]
        set $a$ = $b$ + OR32(ShiftLeft($a$, $s$), ShiftRight($a$, 32 - $s$))
    //! endtextmacro
    globals
        private integer ipos
        private integer ilen
    endglobals
    private function Transform takes nothing returns nothing
        local integer a
        local integer b
        local integer c
        local integer d
        
        local integer rounds = 3
        loop
            set a = state0
            set b = state1
            set c = state2
            set d = state3
    
            //! runtextmacro MD5_ROUND0("a", "b", "c", "d", "ipos",  "7", "0xD76AA478")
            //! runtextmacro MD5_ROUND0("d", "a", "b", "c", "ipos +  1",  "12", "0xE8C7B756")
            //! runtextmacro MD5_ROUND0("c", "d", "a", "b", "ipos +  2",  "17", "0x242070DB")
            //! runtextmacro MD5_ROUND0("b", "c", "d", "a", "ipos +  3",  "22", "0xC1BDCEEE")
            //! runtextmacro MD5_ROUND0("a", "b", "c", "d", "ipos +  4",  "7", "0xF57C0FAF")
            //! runtextmacro MD5_ROUND0("d", "a", "b", "c", "ipos +  5",  "12", "0x4787C62A")
            //! runtextmacro MD5_ROUND0("c", "d", "a", "b", "ipos +  6",  "17", "0xA8304613")
            //! runtextmacro MD5_ROUND0("b", "c", "d", "a", "ipos +  7",  "22", "0xFD469501")
            //! runtextmacro MD5_ROUND0("a", "b", "c", "d", "ipos +  8",  "7", "0x698098D8")
            //! runtextmacro MD5_ROUND0("d", "a", "b", "c", "ipos +  9",  "12", "0x8B44F7AF")
            //! runtextmacro MD5_ROUND0("c", "d", "a", "b", "ipos +  10",  "17", "0xFFFF5BB1")
            //! runtextmacro MD5_ROUND0("b", "c", "d", "a", "ipos +  11",  "22", "0x895CD7BE")
            //! runtextmacro MD5_ROUND0("a", "b", "c", "d", "ipos +  12",  "7", "0x6B901122")
            //! runtextmacro MD5_ROUND0("d", "a", "b", "c", "ipos +  13",  "12", "0xFD987193")
            //! runtextmacro MD5_ROUND0("c", "d", "a", "b", "ipos +  14",  "17", "0xA679438E")
            //! runtextmacro MD5_ROUND0("b", "c", "d", "a", "ipos +  15",  "22", "0x49B40821")
            //! runtextmacro MD5_ROUND1("a", "b", "c", "d", "ipos +  1",  "5", "0xF61E2562")
            //! runtextmacro MD5_ROUND1("d", "a", "b", "c", "ipos +  6",  "9", "0xC040B340")
            //! runtextmacro MD5_ROUND1("c", "d", "a", "b", "ipos + 11", "14", "0x265E5A51")
            //! runtextmacro MD5_ROUND1("b", "c", "d", "a", "ipos", "20", "0xE9B6C7AA")
            //! runtextmacro MD5_ROUND1("a", "b", "c", "d", "ipos +  5", " 5", "0xD62F105D")
            //! runtextmacro MD5_ROUND1("d", "a", "b", "c", "ipos + 10", " 9", "0x02441453")
            //! runtextmacro MD5_ROUND1("c", "d", "a", "b", "ipos + 15", "14", "0xD8A1E681")
            //! runtextmacro MD5_ROUND1("b", "c", "d", "a", "ipos +  4", "20", "0xE7D3FBC8")
            //! runtextmacro MD5_ROUND1("a", "b", "c", "d", "ipos +  9", " 5", "0x21E1CDE6")
            //! runtextmacro MD5_ROUND1("d", "a", "b", "c", "ipos + 14", " 9", "0xC33707D6")
            //! runtextmacro MD5_ROUND1("c", "d", "a", "b", "ipos +  3", "14", "0xF4D50D87")
            //! runtextmacro MD5_ROUND1("b", "c", "d", "a", "ipos +  8", "20", "0x455A14ED")
            //! runtextmacro MD5_ROUND1("a", "b", "c", "d", "ipos + 13", " 5", "0xA9E3E905")
            //! runtextmacro MD5_ROUND1("d", "a", "b", "c", "ipos +  2", " 9", "0xFCEFA3F8")
            //! runtextmacro MD5_ROUND1("c", "d", "a", "b", "ipos +  7", "14", "0x676F02D9")
            //! runtextmacro MD5_ROUND1("b", "c", "d", "a", "ipos + 12", "20", "0x8D2A4C8A")
            //! runtextmacro MD5_ROUND2("a", "b", "c", "d", "ipos +  5",  "4", "0xFFFA3942")
            //! runtextmacro MD5_ROUND2("d", "a", "b", "c", "ipos +  8", "11", "0x8771F681")
            //! runtextmacro MD5_ROUND2("c", "d", "a", "b", "ipos + 11", "16", "0x6D9D6122")
            //! runtextmacro MD5_ROUND2("b", "c", "d", "a", "ipos + 14", "23", "0xFDE5380C")
            //! runtextmacro MD5_ROUND2("a", "b", "c", "d", "ipos +  1", " 4", "0xA4BEEA44")
            //! runtextmacro MD5_ROUND2("d", "a", "b", "c", "ipos +  4", "11", "0x4BDECFA9")
            //! runtextmacro MD5_ROUND2("c", "d", "a", "b", "ipos +  7", "16", "0xF6BB4B60")
            //! runtextmacro MD5_ROUND2("b", "c", "d", "a", "ipos + 10", "23", "0xBEBFBC70")
            //! runtextmacro MD5_ROUND2("a", "b", "c", "d", "ipos + 13", " 4", "0x289B7EC6")
            //! runtextmacro MD5_ROUND2("d", "a", "b", "c", "ipos", "11", "0xEAA127FA")
            //! runtextmacro MD5_ROUND2("c", "d", "a", "b", "ipos +  3", "16", "0xD4EF3085")
            //! runtextmacro MD5_ROUND2("b", "c", "d", "a", "ipos +  6", "23", "0x04881D05")
            //! runtextmacro MD5_ROUND2("a", "b", "c", "d", "ipos +  9", " 4", "0xD9D4D039")
            //! runtextmacro MD5_ROUND2("d", "a", "b", "c", "ipos + 12", "11", "0xE6DB99E5")
            //! runtextmacro MD5_ROUND2("c", "d", "a", "b", "ipos + 15", "16", "0x1FA27CF8")
            //! runtextmacro MD5_ROUND2("b", "c", "d", "a", "ipos +  2", "23", "0xC4AC5665")
            //! runtextmacro MD5_ROUND3("a", "b", "c", "d", "ipos",  "6", "0xF4292244")
            //! runtextmacro MD5_ROUND3("d", "a", "b", "c", "ipos +  7", "10", "0x432AFF97")
            //! runtextmacro MD5_ROUND3("c", "d", "a", "b", "ipos + 14", "15", "0xAB9423A7")
            //! runtextmacro MD5_ROUND3("b", "c", "d", "a", "ipos +  5", "21", "0xFC93A039")
            //! runtextmacro MD5_ROUND3("a", "b", "c", "d", "ipos + 12", " 6", "0x655B59C3")
            //! runtextmacro MD5_ROUND3("d", "a", "b", "c", "ipos +  3", "10", "0x8F0CCC92")
            //! runtextmacro MD5_ROUND3("c", "d", "a", "b", "ipos + 10", "15", "0xFFEFF47D")
            //! runtextmacro MD5_ROUND3("b", "c", "d", "a", "ipos +  1", "21", "0x85845DD1")
            //! runtextmacro MD5_ROUND3("a", "b", "c", "d", "ipos +  8", " 6", "0x6FA87E4F")
            //! runtextmacro MD5_ROUND3("d", "a", "b", "c", "ipos + 15", "10", "0xFE2CE6E0")
            //! runtextmacro MD5_ROUND3("c", "d", "a", "b", "ipos +  6", "15", "0xA3014314")
            //! runtextmacro MD5_ROUND3("b", "c", "d", "a", "ipos + 13", "21", "0x4E0811A1")
            //! runtextmacro MD5_ROUND3("a", "b", "c", "d", "ipos +  4", " 6", "0xF7537E82")
            //! runtextmacro MD5_ROUND3("d", "a", "b", "c", "ipos + 11", "10", "0xBD3AF235")
            //! runtextmacro MD5_ROUND3("c", "d", "a", "b", "ipos +  2", "15", "0x2AD7D2BB")
            //! runtextmacro MD5_ROUND3("b", "c", "d", "a", "ipos +  9", "21", "0xEB86D391")
            
            set state0 = state0 + a
            set state1 = state1 + b
            set state2 = state2 + c
            set state3 = state3 + d
            
            set ipos = ipos + 16
            set rounds = rounds - 1
            exitwhen ipos == ilen or 0 == rounds
        endloop
    endfunction
    
    private function LoadData takes BitInt data returns integer
        local integer size = 0
        local BitInt node = data.next
        local integer sub = 0
        
        set data.bitGroup = 8
        
        loop
            exitwhen node == data
            set buffer[size] = 0
            set sub = 0
            loop
                set buffer[size] = buffer[size] + node.bits*GetBitNumber(sub + 1)
                set node = node.next
                set sub = sub + 8
                exitwhen 32 == sub or node == data
            endloop
            set size = size + 1
        endloop
        
        if (size > 0 and sub < 32) then
            set buffer[size - 1] = 128*GetBitNumber(sub + 1) + buffer[size - 1]
        else
            set buffer[size] = 128
            set size = size + 1
        endif
        
        set sub = size*32
        loop
            exitwhen sub - sub/512*512 == 448
            set sub = sub + 32
            set buffer[size] = 0
            set size = size + 1
        endloop
        
        set buffer[size] = data.bitCount/8*8 + (data.bitCount - data.bitCount/8*8)
        set buffer[size + 1] = 0
        
        return size + 2
    endfunction
    
    private function Write takes integer state, BitInt hash returns nothing
        local integer bit0
        
        if (0 > state) then
            set state = -2147483648 + state
            set bit0 = 1
        else
            set bit0 = 0
        endif
        
        call hash.addNode()
        set hash.prev.bitSize = 8
        set hash.prev.bits = bit0*128 + state/0x1000000
        set state = state - state/0x1000000*0x1000000
        
        call hash.addNode()
        set hash.prev.bitSize = 8
        set hash.prev.bits = state/0x10000
        set state = state - state/0x10000*0x10000
        
        call hash.addNode()
        set hash.prev.bitSize = 8
        set hash.prev.bits = state/0x100
        set state = state - state/0x100*0x100
        
        call hash.addNode()
        set hash.prev.bitSize = 8
        set hash.prev.bits = state
    endfunction
    
    function MD5 takes BitInt data returns BitInt
        local BitInt hash = BitInt.create()
        
        set ilen = LoadData.evaluate(data)
        set ipos = 0
        
        set state0 = 0x67452301
        set state1 = 0xefcdab89
        set state2 = 0x98badcfe
        set state3 = 0x10325476
        
        loop
            call Transform.evaluate()
            exitwhen ipos == ilen
        endloop
        
        set hash.bitCount = 128
        call Write(state0, hash)
        call Write(state1, hash)
        call Write(state2, hash)
        call Write(state3, hash)
        
        return hash
    endfunction
endlibrary