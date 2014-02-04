library Xor32 requires bxor
    /*
    *   integer b = XOR32(int1, int2)
    */
    globals
        private integer b1
        private integer b2
    endglobals
    
    function XOR32 takes integer int1, integer int2 returns integer
        if (0 > int1) then
            set int1 = -2147483648 + int1
            set b1 = 1
        else
            set b1 = 0
        endif
        if (0 > int2) then
            set int2 = -2147483648 + int2
            set b2 = 1
        else
            set b2 = 0
        endif
        
        return B_XOR(b1*128 + int1/0x1000000, b2*128 + int2/0x1000000)*0x1000000 + /*
            */ B_XOR((int1 - int1/0x1000000*0x1000000)/0x10000, (int2 - int2/0x1000000*0x1000000)/0x10000) * 0x10000 + /*
            */ B_XOR((int1 - int1/0x10000*0x10000)/0x100, (int2 - int2/0x10000*0x10000)/0x100) * 0x100 + /*
            */ B_XOR(int1 - int1/0x100*0x100, int2 - int2/0x100*0x100)
    endfunction
endlibrary