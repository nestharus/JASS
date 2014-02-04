library bxor uses sbyte, sxor
    /*
    *   integer b_xor = B_XOR(0xff, 0xac) -> 0x53
    */
    
    constant function B_XOR takes integer byte1, integer byte2 returns integer
        return S_XOR(lbyte[byte1], lbyte[byte2])*0x10 + S_XOR(rbyte[byte1], rbyte[byte2])
    endfunction
endlibrary