library bgmult uses ltable, etable
    /*
    *   integer byte = BG_MULT(byte1, byte2)
    *                  byte = byte1.byte2
    */

    constant function BG_MULT takes integer byte1, integer byte2 returns integer
        if (0 == byte1 or 0 == byte2) then
            return 0
        endif
        set byte1 = ltable[byte1] + ltable[byte2]
        if (byte1 > 0xff) then
            set byte1 = byte1 - 0xff
        endif
        return etable[byte1]
    endfunction
endlibrary