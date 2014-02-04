library BitInt /* v1.0.2.4
*************************************************************************************
*
*   Allows manipulation of sequences of bits
*
*************************************************************************************
*
*   */uses/*
*
*       */ BitManip       /*  hiveworkshop.com/forums/jass-resources-412/snippet-bit-manip-226117/
*
************************************************************************************
*
*   struct BitInt extends array
*
*       Creators/Destructors
*       -----------------------
*
*           static method create takes nothing returns BitInt
*           static method convertString takes string str, integer bitGroup returns BitInt
*               -   converts string to BitInt and returns that BitInt
*               -   bitGroup should be how many bits are stored in each char
*
*           method destroy takes nothing returns nothing
*
*       Fields
*       -----------------------
*
*           readonly static string array charTable
*               -   charTable[i] -> str
*               -   useful for converting things like hex into a readable BitInt string
*
*           readonly BitInt next
*           readonly BitInt prev
*               -   used to iterate over bit nodes
*               -   head is sentinel, list is circular
*
*           integer bitGroup
*               -   how many bits per digit (bit count!)
*               -   8: bytes
*               -   6: good toString output
*
*               -   Range: 1 to 32
*
*           integer bits            //dangerous to set, do not set unless you know what you are doing
*               -   bits at node (node only)
*               -   bits of head is always 0
*
*           integer bitCount        //dangerous to set, do not set unless you know what you are doing
*               -   # of bits in BitInt (head only)
*
*           integer bitSize         //dangerous to set, do not set unless you know what you are doing
*               -   bit size of node (node only)
*               -   bit size of head is always bitGroup
*
*       Methods
*       -----------------------
*
*           //dangerous to use, do not use unless you know what you are doing
*           method addNode takes nothing returns nothing
*               -   add node to back (new node = prev)
*               -   this will only add to the list
*
*               -   bits will be 0
*               -   bitSize will be 0
*               -   bitCount will not be updated
*
*           //dangerous to use, do not use unless you know what you are diong
*           method popNode takes nothing returns nothing
*               -   remove node from front (popped node = next)
*
*               -   bitCount will not be updated! (super dangerous)
*
*           method toString takes nothing returns string
*               -   converts BitInt to string
*               -   bit group > 6 will output list of digits
*
*           method write takes integer bits, integer bitCount returns nothing
*               -   write bits to BitInt across bitCount
*               -   bitCount is the number of bits you want to take up
*
*           method overwrite takes integer bits, integer bitCount, integer position returns nothing
*               -   overwrite bits from position to position + bitCount with new bits
*
*           method read takes integer bitCount returns integer
*               -   read bitCount bits from sequence (from position 0)
*               -   removes read bits
*
*           method copy takes nothing returns BitInt
*               -   copy BitInt and return that copy
*
*           //dangerous, read note
*           method pushFront takes BitInt bits returns nothing
*               -   Pushes bits on to front of this
*               -   Can push on to partials, but can't push parials
*               -   A BitInt is partial if bitCount%bitGroup != 0
*
*           //dangerous, read note
*           method pushBack takes BitInt bits returns nothing
*               -   Pushes bits on to back of this
*               -   Can push partials, but can't push on to partials
*               -   A BitInt is partial if bitCount%bitGroup != 0
*
*           method popFront takes integer nodeCount returns BitInt
*               -   Pops off front nodes and returns BitInt containing them
*
*           method popBack takes integer nodeCount returns BitInt
*               -   Pops off back nodes and returns BitInt containing them
*
*           static method char2Int takes string char returns integer
*               -   Converts a character to an integer
*
*************************************************************************************/
    private module BitIntInit
        private static method onInit takes nothing returns nothing
            call init()
        endmethod
    endmodule
    struct BitInt extends array
        private static hashtable intTable
        readonly static string array charTable
        private static constant string CHARS = "W_P(SU3?'T%E#86:7&X1MO+F[H)D4*NL$,;<2`@!V]/^~}J-CI95RQ.0BaY{ZG=K"
        //private static constant string CHARS = "0123456789abcdefghijklmnopqrstuvwxyz_(?'%#:&+[)*$,;<`@!]/^~}-.{="
        
        private static integer instanceCount = 0
        debug private static boolean enabled = true
        
        readonly thistype next
        readonly thistype prev
        
        integer bits
        integer bitCount
        integer bitSize
        
        private integer bitGroupZ
        
        static method char2Int takes string char returns integer
            return LoadInteger(intTable, StringHash(char), 0)
        endmethod
        
        method operator bitGroup takes nothing returns integer
            return this.bitGroupZ
        endmethod
        
        static method allocate takes nothing returns thistype
            local thistype this = thistype(0).next
            
            debug if (not enabled) then
                debug return 1/0
            debug endif
            
            if (this == 0) then
                debug if (instanceCount == 8191) then
                    debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"OVERFLOW") 
                    debug set enabled = false
                    debug set this = 1/0
                debug endif
            
                set this = instanceCount + 1
                set instanceCount = this
            else
                set thistype(0).next = next
            endif
            
            set bits = 0
            set bitSize = 0
            set bitCount = 0
            
            return this
        endmethod
        
        method deallocate takes nothing returns nothing
            debug if (not enabled) then
                debug set this = 1/0
            debug endif
            
            set next = thistype(0).next
            set thistype(0).next = this
        endmethod
        
        static method create takes nothing returns BitInt
            local thistype this = allocate()
            
            set this.bitGroupZ = 8
            set this.bitSize = bitGroupZ
            
            set next = this
            set prev = this
            
            return this
        endmethod
        
        method destroy takes nothing returns nothing
            set prev.next = thistype(0).next
            set thistype(0).next = this
        endmethod
        
        method addNode takes nothing returns nothing
            local thistype node = allocate()
            
            set node.next = this
            set node.prev = this.prev
            set prev.next = node
            set this.prev = node
        endmethod
        method popNode takes nothing returns nothing
            if (this == next) then
                return
            endif
            
            set this = next
            set prev.next = next
            set next.prev = prev
            
            set this.bits = 0
            set this.bitSize = 0
            
            set prev = this
            
            call deallocate()
        endmethod
        
        method write takes integer bits, integer bitCount returns nothing
            set this.bitCount = this.bitCount + bitCount
        
            if (0 < bitCount) then
                if (bitGroupZ == prev.bitSize) then
                    call addNode()
                endif
                
                loop
                    if (bitCount <= bitGroupZ - prev.bitSize) then
                        set prev.bits = WriteBits(prev.bits, ReadBits(bits, 32 - bitCount, 31), bitCount)
                        set prev.bitSize = prev.bitSize + bitCount
                        
                        exitwhen true
                    else
                        set prev.bits = WriteBits(prev.bits, ReadBits(bits, 32 - bitCount, 32 - bitCount + bitGroupZ - prev.bitSize - 1), bitGroupZ - prev.bitSize)
                        
                        set bitCount = bitCount - bitGroupZ + prev.bitSize
                        set prev.bitSize = bitGroupZ
                        exitwhen 0 >= bitCount
                        
                        call addNode()
                    endif
                endloop
            endif
        endmethod
        
        method overwrite takes integer bits, integer bitCount, integer position returns nothing
            local thistype node = next
            
            if (0 < bitCount) then
                loop
                    exitwhen position < bitGroupZ or this == node
                    set position = position - bitGroupZ
                    set node = node.next
                endloop
                
                if (this == node) then
                    return
                endif
                
                loop
                    if (bitCount <= bitGroupZ - position) then
                        set node.bits = (ReadBits(node.bits, 32 - bitGroupZ, 32 - bitGroupZ + position - 1)*GetBitNumber(bitGroupZ - position + 1) + ReadBits(bits, 32 - bitCount, 31))*GetBitNumber(bitGroupZ - bitCount - position + 1) + ReadBits(node.bits, 32 - bitGroupZ + position + bitCount, 31)
                        
                        exitwhen true
                    else
                        set node.bits = ReadBits(node.bits, 32 - bitGroupZ, 32 - bitGroupZ + position - 1)*GetBitNumber(bitGroupZ - position + 1) + ReadBits(bits, 32 - bitCount, 32 - bitCount + bitGroupZ - position - 1)
                        
                        set bitCount = bitCount - bitGroupZ + position
                        exitwhen 0 >= bitCount
                        
                        set node = node.next
                        exitwhen this == node
                    endif
                    
                    set position = 0
                endloop
            endif
        endmethod
        
        method read takes integer bitCount returns integer
            local integer bits = 0
            
            set this.bitCount = this.bitCount - bitCount
            if (this.bitCount < 0) then
                set this.bitCount = 0
            endif
            
            loop
                exitwhen next == this
                
                if (bitCount >= next.bitSize) then
                    set bits = bits*GetBitNumber(next.bitSize + 1) + next.bits
                    set bitCount = bitCount - next.bitSize
                    call popNode()
                    
                    exitwhen 0 >= bitCount
                else
                    set bits = bits*GetBitNumber(bitCount + 1) + ReadBits(next.bits, 32 - next.bitSize, 32 - next.bitSize + bitCount - 1)
                    set next.bits = ReadBits(next.bits, 32 - next.bitSize + bitCount, 31)
                    set next.bitSize = next.bitSize - bitCount
                    set bitCount = 0
                    
                    if (0 == next.bitSize) then
                        call popNode()
                    endif
                    
                    exitwhen true
                endif
            endloop
        
            return bits*GetBitNumber(bitCount + 1)
        endmethod
        
        private static thistype changeNode
        private static thistype newNode
        method operator bitGroup= takes integer bitGroup returns nothing
            local integer bitCount
        
            if (this.bitGroupZ == bitGroup) then
                return
            endif
            
            if (this == next) then
                set this.bitGroupZ = bitGroup
                set this.bitSize = bitGroupZ
                return
            endif
            
            set thistype.changeNode = this
            set bitCount = this.bitCount
            
            set thistype.newNode = allocate()
            set newNode.bitGroupZ = bitGroup
            set newNode.bitSize = bitGroup
            set newNode.next = newNode
            set newNode.prev = newNode
            
            loop
                call changeGroup()
                exitwhen this == next
            endloop
            
            set this.bitCount = bitCount
            set this.next = newNode.next
            set this.prev = newNode.prev
            set this.next.prev = this
            set this.prev.next = this
            
            set newNode.bitSize = 0
            set newNode.bitCount = 0
            set newNode.prev = newNode
            call newNode.deallocate()
            
            set this.bitGroupZ = bitGroup
            set this.bitSize = bitGroupZ
        endmethod
        private static method changeGroup takes nothing returns nothing
            local thistype this = thistype.changeNode
            local thistype new = thistype.newNode
            local integer newGroup = new.bitGroupZ
            local integer buffer
            local integer rounds = 550
            
            loop
                exitwhen this == next or 0 == rounds
                set rounds = rounds - 1
                
                if (this.bitCount < newGroup) then
                    if (0 < this.bitCount) then
                        set buffer = this.bitCount
                        call new.write(read(this.bitCount), buffer)
                    endif
                    exitwhen true
                else
                    call new.addNode()
                    set new.prev.bits = read(newGroup)
                    set new.prev.bitSize = newGroup
                endif
            endloop
        endmethod
        
        method toString takes nothing returns string
            local string str = ""
            local thistype node = next
            
            if (bitGroupZ <= 6) then
                loop
                    exitwhen this == node
                    
                    set str = str + charTable[node.bits]
                    
                    set node = node.next
                endloop
                
                if (str == "") then
                    return charTable[0]
                endif
            else
                loop
                    exitwhen this == node
                    
                    set str = str + " " + I2S(node.bits)
                    
                    set node = node.next
                endloop
                
                if (str == "") then
                    return "0"
                endif
            endif
            
            return str
        endmethod
        
        static method convertString takes string str, integer bitGroup returns BitInt
            local thistype this = allocate()
            local integer i = 0
            local integer len = StringLength(str)
            local integer bitNum = GetBitNumber(bitGroup + 1)
            
            set this.bitGroupZ = bitGroup
            set this.bitSize = bitGroup
            
            set next = this
            set prev = this
            
            loop
                exitwhen i == len
                set i = i + 1
                
                call addNode()
                set prev.bits = LoadInteger(intTable, StringHash(SubString(str, i - 1, i)), 0)
                if (prev.bits >= bitNum) then
                    call destroy()
                    return 0
                endif
                set prev.bitSize = bitGroup
                set bitCount = bitCount + bitGroup
            endloop
            
            return this
        endmethod
        
        method copy takes nothing returns BitInt
            local thistype new = allocate()
            local thistype node = next
            
            set new.next = new
            set new.prev = new
            
            loop
                exitwhen node == this
                
                call new.addNode()
                set new.prev.bits = node.bits
                set new.prev.bitSize = node.bitSize
                
                set node = node.next
            endloop
            
            set new.bitGroupZ = this.bitGroupZ
            set new.bitCount = this.bitCount
            set new.bitSize = new.bitGroupZ
            
            return new
        endmethod
        
        method pushFront takes BitInt bits returns nothing
            if (bits.next == bits) then
                return
            endif
            
            set this.bitCount = this.bitCount + bits.bitCount
            set bits.bitGroup = this.bitGroup
            set bits.next.prev = this
            set bits.prev.next = this.next
            set this.next.prev = bits.prev
            set this.next = bits.next
            
            set bits.bitCount = 0
            set bits.next = bits
            set bits.prev = bits
        endmethod
        
        method pushBack takes BitInt bits returns nothing
            if (bits.next == bits) then
                return
            endif
            
            set this.bitCount = this.bitCount + bits.bitCount
            set bits.bitGroup = this.bitGroup
            set bits.prev.next = this
            set bits.next.prev = this.prev
            set this.prev.next = bits.next
            set this.prev = bits.prev
            
            set bits.bitCount = 0
            set bits.next = bits
            set bits.prev = bits
        endmethod
        
        method popFront takes integer nodeCount returns BitInt
            local BitInt new = BitInt.allocate()
            local thistype node = this
            
            set new.bitGroupZ = this.bitGroupZ
            set new.bitSize = new.bitGroupZ
            
            loop
                exitwhen node.next == this or 0 == nodeCount
                set node = node.next
                set nodeCount = nodeCount - 1
                set this.bitCount = this.bitCount - this.bitGroupZ
                set new.bitCount = new.bitCount + this.bitGroupZ
            endloop
            
            if (node == this) then
                set new.next = new
                set new.prev = new
                return new
            endif
            
            set new.next = this.next
            set new.prev = node
            set node.next.prev = this
            set this.next = node.next
            set new.next.prev = new
            set node.next = new
            
            set this.bitCount = this.bitCount + this.bitGroupZ - new.prev.bitSize
            set new.bitCount = new.bitCount - this.bitGroupZ + new.prev.bitSize
            
            return new
        endmethod
        
        method popBack takes integer nodeCount returns BitInt
            local BitInt new = BitInt.allocate()
            local thistype node = this
            
            set new.bitGroupZ = this.bitGroupZ
            set new.bitSize = new.bitGroupZ
            
            loop
                exitwhen node.prev == this or 0 == nodeCount
                set node = node.prev
                set nodeCount = nodeCount - 1
                set this.bitCount = this.bitCount - this.bitGroupZ
                set new.bitCount = new.bitCount + this.bitGroupZ
            endloop
            
            if (node == this) then
                set new.next = new
                set new.prev = new
                return new
            endif
            
            set new.next = node
            set new.prev = this.prev
            set node.prev.next = this
            set this.prev = node.prev
            set node.prev = new
            set new.prev.next = new
            
            set this.bitCount = this.bitCount + this.bitGroupZ - new.prev.bitSize
            set new.bitCount = new.bitCount - this.bitGroupZ + new.prev.bitSize
            
            return new
        endmethod
        
        private static method init takes nothing returns nothing
            local integer i = StringLength(CHARS)
            set intTable = InitHashtable()
            
            loop
                set i = i - 1
                call SaveInteger(intTable, StringHash(SubString(CHARS, i, i + 1)), 0, i)
                set charTable[i] = SubString(CHARS, i, i + 1)
                exitwhen 0 == i
            endloop
        endmethod
        
        implement BitIntInit
    endstruct
endlibrary