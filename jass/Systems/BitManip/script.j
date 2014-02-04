library BitManip /* v1.0.2.1
*************************************************************************************
*
*   Used to manipulate bits in an integer
*
************************************************************************************
*
*   function ReadBits takes integer bits, integer bitStart, integer bitEnd returns integer
*       -   reads bits out of number from bitStart to bitEnd (including ends)
*
*       -   0: front of number, left side
*       -   31: back of number, right side
*
*       -   keep in mind numbers with leading 0s
*
*   function WriteBits takes integer bits, integer bitsToWrite, integer bitsToOccupy returns integer
*       -   bits is number to write to
*       -   bitsToWrite is the number to write
*       -   bitsToOccupy Range: 1 - 32
*
*   function GetBitSize takes integer bits returns integer
*   function GetFreeBits takes integer bits returns integer
*       -   empty bits in number (leading 0s)
*       -   O(log n)
*       -   Output Range: 0 - 32
*
*   function PopBitsBack takes integer bits, integer bitsToPop returns integer
*   function PopBitsFront takes integer bits, integer bitsToPop returns integer
*       -   bits is number
*       -   bitsToPop range: 0 to 32
*
*   function GetBitNumber takes integer bitCount returns integer
*       -   Returns a number containing bitCount bits, the first bit (excluding leading 0s) being 1
*       -   Essentially a power of 2 function (2^(bits - 1))
*       -   Range: 1 to 32
*
*   function Bits2String32 takes integer num returns string
*   function Bits2String takes integer num returns string
*       -   Returns string of bits making up the number
*       -   Bit2String32 returns 32 bits with leading 0s while Bits2String returns exact bits.
*
*   function ShiftLeft takes integer bits, integer shift returns integer
*   function ShiftRight takes integer bits, integer shift returns integer
*   function RotateLeft takes integer bits, integer shift returns integer
*   function RotateRight takes integer bits, integer shift returns integer
*
*************************************************************************************/
    globals
        private integer array powArr
    endglobals
    
    function Bits2String32 takes integer num returns string
        local string str0 = "00000000000000000000000000000000"
        local string str = ""
        local integer bit0 = 0
        if (num < 0) then
            set bit0 = 1
            set num = -2147483648 + num
        endif
        loop
            exitwhen 0 == num
            set str = I2S(num - num/2*2) + str
            set num = num/2
        endloop
        return I2S(bit0) + SubString(str0, 0, 31 - StringLength(str)) + str
    endfunction
    function Bits2String takes integer num returns string
        local string str0 = "00000000000000000000000000000000"
        local string str = ""
        local integer bit0 = 0
        if (num < 0) then
            set bit0 = 1
            set num = -2147483648 + num
        endif
        loop
            exitwhen 0 == num
            set str = I2S(num - num/2*2) + str
            set num = num/2
        endloop
        if (0 == bit0) then
            return str
        endif
        return I2S(bit0) + SubString(str0, 0, 31 - StringLength(str)) + str
    endfunction
    
    function ReadBits takes integer bits, integer bitStart, integer bitEnd returns integer
        local integer bit0 = 0
        local integer bitStar = bitStart
        
        if (bitEnd < bitStart) then
            return 0
        endif
        
        set bitStart = 31 - bitStart - (bitEnd - bitStart)
        if (bitStart == 31) then
            set bitStart = 30
        endif
        
        if (0 < bitEnd) then
            set bitEnd = bitEnd - bitStar
            
            if (0 < bitStar) then
                set bitEnd = bitEnd + 1
            endif
        endif
        
        if (bits < 0) then
            if (bitStar == 0) then
                set bit0 = 1
            endif
            set bits = -2147483648 + bits
        endif
        
        set bits = bits/powArr[bitStart]
        set bits = bits - bits/powArr[bitEnd]*powArr[bitEnd] + bit0*powArr[bitEnd]
        
        return bits
    endfunction
    
    function GetBitSize takes integer bits returns integer
        local integer low = 0
        local integer high = 31
        local integer mid = 15
        
        if (0 == bits) then
            return 0
        elseif (0 > bits) then
            return 32
        endif
        
        loop
            if (bits < powArr[mid - 1]) then
                set high = mid - 1
            else
                set low = mid + 1
            endif
            
            set mid = (high + low)/2
            exitwhen high < low
        endloop
        
        return mid
    endfunction
    
    function GetFreeBits takes integer bits returns integer
        return 32 - GetBitSize(bits)
    endfunction
    
    function WriteBits takes integer bits, integer bitsToWrite, integer bitsToOccupy returns integer
        return bits*powArr[bitsToOccupy] + bitsToWrite
    endfunction
    
    function PopBitsBack takes integer bits, integer bitsToPop returns integer
        local integer bit0 = 0
        
        if (0 > bits) then
            set bit0 = 1
            set bits = -2147483648 + bits
        endif
        
        if (bitsToPop > 30) then
            return bit0*(powArr[32 - bitsToPop]/2)
        endif

        return  bit0*powArr[31 - bitsToPop] + bits/powArr[bitsToPop]
    endfunction
    
    function PopBitsFront takes integer bits, integer bitsToPop returns integer
        if (0 == bitsToPop) then
            return bits
        endif
        if (32 == bitsToPop) then
            return 0
        endif
        
        if (0 > bits) then
            set bits = -2147483648 + bits
            set bitsToPop = bitsToPop - 1
        endif
        
        return bits/powArr[bitsToPop]
    endfunction
    
    function GetBitNumber takes integer bits returns integer
        return powArr[bits - 1]
    endfunction
    
    function ShiftLeft takes integer bits, integer shift returns integer
        return bits*powArr[shift]
    endfunction
    function ShiftRight takes integer bits, integer shift returns integer
        return ReadBits(bits, 0, 31 - shift)
    endfunction
    function RotateLeft takes integer bits, integer shift returns integer
        return ShiftLeft(bits, shift) + ReadBits(bits, 0, shift - 1)
    endfunction
    function RotateRight takes integer bits, integer shift returns integer
        return ShiftRight(bits, shift) + ReadBits(bits, 32 - shift, 31)*powArr[32 - shift]
    endfunction
    
    private module Init
        private static method onInit takes nothing returns nothing
            local integer i = 1
            set powArr[0] = 1
            loop
                set powArr[i] = powArr[i - 1]*2
                set i = i + 1
                exitwhen i == 32
            endloop
        endmethod
    endmodule
    private struct Inits extends array
        implement Init
    endstruct
endlibrary