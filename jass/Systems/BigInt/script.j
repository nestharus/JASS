library BigInt /* v2.4.0.0
*************************************************************************************
*
*   Used for creating very large unsigned integers in any base. Stored in linked list.
*
*************************************************************************************
*
*   */uses/*
*
*       */ Base /*         hiveworkshop.com/forums/submissions-414/snippet-base-188814/
*
*************************************************************************************
*
*   struct BigInt extends array
*
*       - All Operations Require That Bases Between Two BigInts
*       - Be The Same Size
*
*       - No Methods Will Ever Crash. If A Method Is Op Limit Safe, It Means
*       - That It Runs Inside Of Its Own Thread, Allowing You To Call It Many Times
*       - Safely.
*
*       ---------------------------------------
*       -
*       -   Key
*       -
*       -       Op Limit Safe: +
*       -       Not Op Limit Safe: ~
*       -
*       ---------------------------------------
*
*       -   Fields
*
*           +readonly boolean packed
*               -   Is the value in a compressed state? (unreadable, but good for base conversions)
*           +readonly integer size
*           +readonly thistype next
*           +readonly thistype prev
*               -   Used For Iterating Over Digits
*           +integer digit
*               -   The Value Of The Specific Digit
*           +readonly boolean head
*               -   A Value Of 0 Will Only Have The Head
*               -   The Head Can Only Be 0, So Do Not Change Value
*               -   Of The Head Or You Will Break Division.
*
*       -   Methods
*
*           ~method lt takes BigInt i returns boolean
*               -   this < i
*           ~method gt takes BigInt i returns boolean
*               - this > i
*           ~method eq takes BigInt i returns boolean
*               -   this == i
*           ~method neq takes BigInt i returns boolean
*               -   this != i
*           ~method ltoe takes BigInt i returns boolean
*               -   this <= i
*           ~method gtoe takes BigInt i returns boolean
*               -   this >= i
*
*           ~method add takes integer i returns nothing
*               -   this + i
*           ~method addBig takes BigInt i returns nothing
*               -   this + i
*           ~method addString takes string s returns nothing
*               -   this + s
*
*           ~method subtract takes integer i returns nothing
*               -   this - i
*           ~method subtractBig takes BigInt i returns nothing
*               -   this - i
*
*           ~method multiply takes integer i returns nothing
*               -   this * i
*           ~method multiplyBig takes BigInt i returns nothing
*               -   this * i
*
*           ~method divide takes integer d returns integer
*               -   this / d
*           ~method divideBig takes BigInt d returns BigInt
*               -   this/d
*
*           ~method operator base takes nothing returns integer
*               -   Returns base size (base alphabet is not stored)
*           ~method operator base= takes integer base returns nothing
*               -   Converts BigInt to target base size
*               -   Base 0 is default base, which is 46340
*               -   Only perform operations on BigInts when they are in Base 0 As
*               -   The Operations Will Be Much Faster
*
*           ~method mod takes integer i returns integer
*               -   this % i
*           ~method modBig takes BigInt i returns BigInt
*               -   this % i
*
*           +static method create takes nothing returns BigInt
*               -   Creates 0 BigInt In Default Base
*               -   Do Not Change Default Base Unless Displaying
*           +static method convertString takes string s, Base base returns BigInt
*               -   Converts Target String In Base To BigInt
*               -   Be Sure To Change Base Of BigInt To 0 Afterwards
*           +method destroy takes nothing returns nothing
*
*           +method clear takes nothing returns nothing
*               -   Resets BigInt To 0, Does Not Reset Base
*           +method copy takes nothing returns BigInt
*               -   Copies BigInt
*           +method remake takes nothing returns BigInt
*               -   Moves All Digits On BigInt To A New BigInt And
*               -   Returns It
*
*                   local BigInt i = convertString("22829", base10)
*                   local BigInt i2 = i.remake()
*                       ->  i = 0
*                       ->  i2 = 22829
*
*           +method enq takes integer i returns nothing
*               -   Adds A New Digit To Front Of BigInt
*
*                   local BigInt i = convertString("22829", base10)
*                   call i.enq(7)
*                       ->  i = 722829
*           +method deq takes nothing returns nothing
*               -   Removes Digit From Front Of BigInt
*
*                   local BigInt i = convertString("22829", base10)
*                   call i.deq()
*                       ->  i = 2829
*
*           +method deto takes thistype target returns nothing
*               -   Similar to deq except pushes onto target BigInt
*
*           +method popto takes thistype target returns nothing
*               -   Similar to pop except enques onto target BigInt
*
*           +method push takes integer i returns nothing
*               -   Pushes A New Digit To Back Of BigInt
*
*                   local BigInt i = convertString("22829", base10)
*                   call i.push(7)
*                       ->  i = 228297
*           +method pop takes nothing returns nothing
*               -   Removes Digit From Back Of BigInt
*
*                   local BigInt i = convertString("22829", base10)
*                   call i.pop()
*                       ->  i = 2282
*
*           +method toInt takes nothing returns integer
*               -   Converts BigInt To An Integer
*               -   This Will Overflow If The BigInt Can't Fit Into An Integer
*
*                   local BigInt i = convertString("22829", base10)
*                   local integer int = i.toInt()
*                       -> int = 22829
*           +method toString takes nothing returns string
*           +method toStringAlphabet takes Base base returns nothing
*               -   Converts BigInt To A String
*               -   If The Base Is The Default Base, The Digits Will Be Listed In That Base
*
*                   local BigInt i = convertString("22829", base10)
*                   local string str = i.toString()
*                       -> str = "2 2 8 2 9"
*                   set str = i.toStringAlphabet(base10)
*                       -> str = "22829"
*
*           ~method pack takes nothing returns nothing
*               -   Commpresses the BigInt as much as possible (useful for base conversion)
*           ~method unpack takes nothing returns nothing
*               -   Decompresses the BigInt
*
*************************************************************************************/
    globals
        private constant integer BASE = 46340
        private constant boolean DEBUG_MSGS = false
        private constant boolean DOUBLE_FREE_CHECK = false
    endglobals
    
    private module Init
        private static method onInit takes nothing returns nothing
            local integer base
        
            set evalBase = CreateTrigger()
            call TriggerAddCondition(evalBase, Condition(function thistype.ebase))
            
            set evalMultBig = CreateTrigger()
            call TriggerAddCondition(evalMultBig, Condition(function thistype.eMultiplyBig))
            
            set evalDivideBig = CreateTrigger()
            call TriggerAddCondition(evalDivideBig, Condition(function thistype.eDivideBig))
            
            set evalSetBase = CreateTrigger()
            call TriggerAddCondition(evalSetBase, Condition(function thistype.setBase))
            
            set evalConvertString = CreateTrigger()
            call TriggerAddCondition(evalConvertString, Condition(function thistype.eConvertString))
            
            set evalCopy = CreateTrigger()
            call TriggerAddCondition(evalCopy, Condition(function thistype.eCopy))
            
            set evalToString = CreateTrigger()
            call TriggerAddCondition(evalToString, Condition(function thistype.eToString))
            
            set packedBase[2] = 32768
            set packedPower[2] = 15
            set packedBase[3] = 19683
            set packedPower[3] = 9
            set packedBase[4] = 16384
            set packedPower[4] = 8
            set packedBase[5] = 15625
            set packedPower[5] = 6
            set packedBase[6] = 7776
            set packedPower[6] = 5
            set packedBase[7] = 16807
            set packedPower[7] = 5
            set packedBase[8] = 32768
            set packedPower[8] = 5
            set packedBase[9] = 6561
            set packedPower[9] = 4
            set packedBase[10] = 10000
            set packedPower[10] = 4
            set packedBase[11] = 14641
            set packedPower[11] = 4
            set packedBase[12] = 20736
            set packedPower[12] = 4
            set packedBase[13] = 28561
            set packedPower[13] = 4
            set packedBase[14] = 38416
            set packedPower[14] = 4
            set packedBase[15] = 3375
            set packedPower[15] = 3
            set packedBase[16] = 4096
            set packedPower[16] = 3
            set packedBase[17] = 4913
            set packedPower[17] = 3
            set packedBase[18] = 5832
            set packedPower[18] = 3
            set packedBase[19] = 6859
            set packedPower[19] = 3
            set packedBase[20] = 8000
            set packedPower[20] = 3
            set packedBase[21] = 9261
            set packedPower[21] = 3
            set packedBase[22] = 10648
            set packedPower[22] = 3
            set packedBase[23] = 12167
            set packedPower[23] = 3
            set packedBase[24] = 13824
            set packedPower[24] = 3
            set packedBase[25] = 15625
            set packedPower[25] = 3
            set packedBase[26] = 17576
            set packedPower[26] = 3
            set packedBase[27] = 19683
            set packedPower[27] = 3
            set packedBase[28] = 21952
            set packedPower[28] = 3
            set packedBase[29] = 24389
            set packedPower[29] = 3
            set packedBase[30] = 27000
            set packedPower[30] = 3
            set packedBase[31] = 29791
            set packedPower[31] = 3
            set packedBase[32] = 32768
            set packedPower[32] = 3
            set packedBase[33] = 35937
            set packedPower[33] = 3
            set packedBase[34] = 39304
            set packedPower[34] = 3
            set packedBase[35] = 42875
            set packedPower[35] = 3
            
            set base = 128
            loop
                exitwhen 35 == base
                set packedBase[base] = base*base
                set packedPower[base] = 2
                set base = base - 1
            endloop
        endmethod
    endmodule
    
    struct BigInt extends array
        private integer bm
        readonly thistype next
        readonly thistype prev
        integer digit
        readonly boolean head
        readonly integer size
        readonly boolean packed
        
        private static trigger evalBase
        private static trigger evalMultBig
        private static trigger evalDivideBig
        private static trigger evalSetBase
        private static trigger evalConvertString
        private static trigger evalCopy
        private static trigger evalToString
        
        private static integer array packedBase
        private static integer array packedPower
        
        private static integer count = 0
        
        debug private static boolean rn
        
        static if DOUBLE_FREE_CHECK then
            private boolean allocated
        endif
        private static method allocate takes nothing returns thistype
            local thistype this = thistype(0).next
            if (0 == this) then
                set this = count + 1
                set count = this
            else
                set thistype(0).next = next
            endif
            
            static if DOUBLE_FREE_CHECK then
                if (allocated) then
                    call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"DOUBLE ALLOC")
                    set this = 1/0
                endif
                set allocated = true
            endif
            
            set digit = 0
            
            return this
        endmethod
        
        static if DOUBLE_FREE_CHECK then
            private method deallocate takes nothing returns nothing
                if (not allocated) then
                    call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"DOUBLE FREE")
                    set this = 1/0
                endif
                set allocated = false
                
                set next = thistype(0).next
                set thistype(0).next = this
            endmethod
        endif
        
        static if DOUBLE_FREE_CHECK then
            private static method deallocateRange takes thistype min, thistype max returns nothing
                set max.next = thistype(0).next
                set thistype(0).next = min
                
                loop
                    if (not max.allocated) then
                        call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"DOUBLE FREE")
                        set max = 1/0
                    endif
                    set max.allocated = false
                    exitwhen max == min
                    set max = max.prev
                endloop
            endmethod
        endif
        
        private method ad takes thistype n returns nothing
            set n.next = this
            set n.prev = prev
            set prev.next = n
            set prev = n
            set size = size + 1
        endmethod
        private method adp takes thistype n returns nothing
            set n.next = next
            set n.prev = this
            set next.prev = n
            set next = n
            set size = size + 1
        endmethod
        method deto takes thistype tar returns nothing
            debug if not (head and tar.head) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempted To Pop Null BigInt")
                debug set this = 1/0
                debug return
            debug endif
            debug if (0 == size) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempted To Pop 0 BigInt")
                debug set this = 1/0
                debug return
            debug endif
            
            set size = size - 1
            set this = prev
            set prev.next = next
            set next.prev = prev
            
            if (not tar.prev.head or 0 != digit) then
                call tar.adp(this)
            else
                static if DOUBLE_FREE_CHECK then
                    call deallocate()
                else
                    set next = thistype(0).next
                    set thistype(0).next = this
                endif
            endif
        endmethod
        method popto takes thistype tar returns nothing
            debug if not (head and tar.head) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempted To Pop Null BigInt")
                debug set this = 1/0
                debug return
            debug endif
            debug if (0 == size) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempted To Pop 0 BigInt")
                debug set this = 1/0
                debug return
            debug endif
            
            set size = size - 1
            set this = next
            set prev.next = next
            set next.prev = prev
            
            if (not tar.prev.head or 0 != digit) then
                call tar.ad(this)
            else
                static if DOUBLE_FREE_CHECK then
                    call deallocate()
                else
                    set next = thistype(0).next
                    set thistype(0).next = this
                endif
            endif
        endmethod
        method lt takes thistype i returns boolean
            local boolean b = false
            debug if (not head or not i.head) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempting To < Compare Null BigInt")
                debug set i = 1/0
                debug return false
            debug endif
            debug if (bm != i.bm) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempting To < Compare BigInts With Different Bases")
                debug set i = 1/0
                debug return false
            debug endif
            
            if (size == i.size) then
                loop
                    set this = prev
                    set i = i.prev
                    exitwhen head or digit != i.digit
                endloop
                return digit < i.digit
            endif
            
            return size < i.size
        endmethod
        method gt takes thistype i returns boolean
            local boolean b = false
            debug if (not head or not i.head) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempting To > Compare Null BigInt")
                debug set i = 1/0
                debug return false
            debug endif
            debug if (bm != i.bm) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempting To > Compare BigInts With Different Bases")
                debug set i = 1/0
                debug return false
            debug endif
            
            if (size == i.size) then
                loop
                    set this = prev
                    set i = i.prev
                    exitwhen head or digit != i.digit
                endloop
                return digit > i.digit
            endif
            
            return size > i.size
        endmethod
        method eq takes thistype i returns boolean
            debug if (not head) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempting To == Compare Null BigInt")
                debug set i = 1/0
                debug return false
            debug endif
            
            if (0 == i) then
                loop
                    set this = next
                    exitwhen head or 0 != digit
                endloop
                return head
            endif
        
            debug if (not i.head) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempting To == Compare Null BigInt")
                debug set i = 1/0
                debug return false
            debug endif
            debug if (bm != i.bm) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempting To == Compare BigInts With Different Bases")
                debug set i = 1/0
                debug return false
            debug endif
            
            if (size == i.size) then
                loop
                    set this = next
                    set i = i.next
                    exitwhen head or digit != i.digit
                endloop
                return head
            endif
            
            return false
        endmethod
        method neq takes thistype i returns boolean
            debug if (not head or not i.head) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempting To != Compare Null BigInt")
                debug set i = 1/0
                debug return false
            debug endif
            debug if (bm != i.bm) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempting To != Compare BigInts With Different Bases")
                debug set i = 1/0
                debug return false
            debug endif
            return not eq(i)
        endmethod
        method ltoe takes thistype i returns boolean
            local boolean b = false
            debug if (not head or not i.head) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempting To <= Compare Null BigInt")
                debug set i = 1/0
                debug return false
            debug endif
            debug if (bm != i.bm) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempting To <= Compare BigInts With Different Bases")
                debug set i = 1/0
                debug return false
            debug endif
            
            if (size == i.size) then
                loop
                    set this = prev
                    set i = i.prev
                    exitwhen head or digit != i.digit
                endloop
                return digit <= i.digit
            endif
            
            return size < i.size
        endmethod
        method gtoe takes thistype i returns boolean
            local boolean b = false
            debug if (not head or not i.head) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempting To >= Compare Null BigInt")
                debug set i = 1/0
                debug return false
            debug endif
            debug if (bm != i.bm) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempting To >= Compare BigInts With Different Bases")
                debug set i = 1/0
                debug return false
            debug endif
            
            if (size == i.size) then
                loop
                    set this = prev
                    set i = i.prev
                    exitwhen head or digit != i.digit
                endloop
                return digit >= i.digit
            endif
            
            return size > i.size
        endmethod
        
        method add takes integer i returns nothing
            local integer carry = 0
            local thistype root = this
            local integer base
            
            debug if (not head) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempting To Add Null BigInt")
                debug set i = 1/0
                debug return
            debug endif
            
            if (packed) then
                set base = packedBase[bm]
                if (base == 0) then
                    set base = bm
                endif
            else
                set base = bm
            endif
            
            loop
                exitwhen 0 == i
                set this = next
                if (head) then
                    set this = allocate()
                    call root.ad(this)
                endif
                set digit = digit + i - i/base*base + carry
                set i = i/base
                set carry = digit/base
                set digit = digit - digit/base*base
            endloop
            loop
                exitwhen 0 == carry
                set this = next
                if (head) then
                    set this = allocate()
                    call root.ad(this)
                endif
                set digit = digit + carry
                set carry = digit/base
                set digit = digit - digit/base*base
            endloop
        endmethod
        method addBig takes BigInt i returns nothing
            local integer carry = 0
            local thistype root = this
            local integer count = 0
            local integer base
            
            debug if (not head or not i.head) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempting To Add Null BigInt")
                debug set i = 1/0
                debug return
            debug endif
            debug if (bm != i.bm) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempting To Add BigInts With Different Bases")
                debug set i = 1/0
                debug return
            debug endif
            
            if (packed) then
                set base = packedBase[bm]
                if (base == 0) then
                    set base = bm
                endif
            else
                set base = bm
            endif
            
            loop
                set i = i.next
                exitwhen i.head
                set this = next
                if (head) then
                    set this = allocate()
                    call root.ad(this)
                endif
                set digit = digit + i.digit + carry
                set carry = digit/base
                set digit = digit - digit/base*base
            endloop
            loop
                exitwhen 0 == carry
                set this = next
                if (head) then
                    set this = allocate()
                    call root.ad(this)
                endif
                set digit = digit + carry
                set carry = digit/base
                set digit = digit - digit/base*base
            endloop
        endmethod
        method addString takes string s, Base b returns nothing
            local integer carry = 0
            local thistype root = this
            local integer i = StringLength(s)
            local integer base = b.size
            
            debug if (not head) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempting To Add Null BigInt")
                debug set i = 1/0
                debug return
            debug endif
            debug if (bm != base) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempting To Add BigInts With Different Bases")
                debug set i = 1/0
                debug return
            debug endif
            
            loop
                exitwhen 0 == i
                set this = next
                if (head) then
                    set this = allocate()
                    call root.ad(this)
                endif
                set digit = digit + b.ord(SubString(s, i - 1, i)) + carry
                set carry = digit/base
                set digit = digit - digit/base*base
                set i = i - 1
            endloop
            
            loop
                exitwhen 0 == carry
                set this = next
                if (head) then
                    set this = allocate()
                    call root.ad(this)
                endif
                set digit = digit + carry
                set carry = digit/base
                set digit = digit - digit/base*base
            endloop
        endmethod
            
        static method create takes nothing returns thistype
            local thistype this = allocate()
            
            set size = 0
            set next = this
            set prev = this
            set head = true
            set bm = BASE
            
            set packed = false
            
            return this
        endmethod
        
        private static string eStringToConvert
        private static Base eConvertingBase
        private static BigInt eConvertingBigInt
        private static integer eConvertingIndex
        private static method eConvertString takes nothing returns boolean
            local thistype this = eConvertingBigInt
            local string s = eStringToConvert
            local Base base = eConvertingBase
            local thistype digit
            local integer index = eConvertingIndex
            local integer ops = 1260
            
            debug set rn = false
            loop
                exitwhen 0 == index or 0 == ops
                set ops = ops - 1
                set index = index - 1
                set digit = allocate()
                call ad(digit)
                set digit.digit = base.ord(SubString(s, index, index+1))
            endloop
            debug set rn = true
            
            set eConvertingIndex = index
            
            return 0 == index
        endmethod
        
        static method convertString takes string s, Base base returns thistype
            local thistype this = allocate()
            
            debug if (0 != base and 0 == base.size) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempted To Convert Bad Base")
                debug return 0
            debug endif
            debug if (0 == StringLength(s)) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempted To Convert Bad String")
                debug return 0
            debug endif
            
            set size = 0
            set next = this
            set prev = this
            set head = true
            set bm = base.size
            set packed = false
            
            set eStringToConvert = s
            set eConvertingBase = base
            set eConvertingBigInt = this
            set eConvertingIndex = StringLength(s)
            
            loop
                exitwhen TriggerEvaluate(evalConvertString)
                debug if not rn then
                    static if DEBUG_MSGS then
                        debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"CONVERT STRING THREAD CRASH")
                    endif
                    debug set this = 1/0
                debug endif
            endloop
            
            return this
        endmethod
        method clear takes nothing returns nothing
            debug if (not head) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempted To Clear Null BigInt")
                debug return
            debug endif
            if (not next.head) then
                static if DOUBLE_FREE_CHECK then
                    call deallocateRange(next, prev)
                else
                    set prev.next = thistype(0).next
                    set thistype(0).next = next
                endif
                set next = this
                set prev = this
                set size = 0
            endif
            set digit = 0
        endmethod
        method destroy takes nothing returns nothing
            debug if (not head) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempted To Destroy Null BigInt")
                debug return
            debug endif
            
            static if DOUBLE_FREE_CHECK then
                call deallocateRange(this, prev)
            else
                set prev.next = thistype(0).next
                set thistype(0).next = this
            endif
            
            set head = false
            set size = 0
        endmethod
        
        private static BigInt eToCopy
        private static BigInt eCloneCopy
        private static method eCopy takes nothing returns boolean
            local thistype this = eToCopy
            local thistype n = eCloneCopy
            local thistype clone = eCloneCopy
            local integer ops = 3092
            
            debug set rn = false
            loop
                set this = next
                exitwhen head or 0 == ops
                set ops = ops - 1
                set n = allocate()
                call clone.ad(n)
                set n.digit = digit
            endloop
            debug set rn = true
            
            set eToCopy = this
        
            return head
        endmethod
        method copy takes nothing returns thistype
            local thistype clone
            
            debug if (not head) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempted To Copy Null BigInt")
                debug return 0
            debug endif
            
            set clone = allocate()
            
            set clone.next = clone
            set clone.prev = clone
            set clone.head = true
            set clone.bm = bm
            set clone.packed = packed
            
            set eToCopy = this
            set eCloneCopy = clone
            loop
                exitwhen TriggerEvaluate(evalCopy)
                debug if (not rn) then
                    static if DEBUG_MSGS then
                        debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"COPY THREAD CRASH")
                    endif
                    debug set this = 1/0
                debug endif
            endloop
            
            return clone
        endmethod
        method remake takes nothing returns thistype
            local thistype clone
            
            debug if (not head) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempted To Remake Null BigInt")
                debug return 0
            debug endif
            
            set clone = allocate()
            set clone.head = true
            set clone.bm = bm
            set clone.size = size
            set clone.packed = packed
            if (clone == this) then
                call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Allocation Error In Remake")
                set size = 1/0
            endif
            set size = 0
            if (not next.head) then
                set clone.next = next
                set clone.prev = prev
                set clone.next.prev = clone
                set clone.prev.next = clone
                set next = this
                set prev = this
            else
                set clone.next = clone
                set clone.prev = clone
            endif
            
            return clone
        endmethod
        method enq takes integer i returns nothing
            local thistype n
            debug if (not head) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempted To Enqueue Null BigInt")
                debug return
            debug endif
            set n = allocate()
            call ad(n)
            set n.digit = i
        endmethod
        method push takes integer i returns nothing
            local thistype n
            debug if (not head) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempted To Push Null BigInt")
                debug return
            debug endif
            set n = allocate()
            call adp(n)
            set n.digit = i
        endmethod
        method pop takes nothing returns nothing
            debug if (not head) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempted To Pop Null BigInt")
                debug return
            debug endif
            debug if (next.head) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempted To Pop 0 BigInt")
                debug return
            debug endif
            set size = size - 1
            set this = next
            set prev.next = next
            set next.prev = prev
            static if DOUBLE_FREE_CHECK then
                call deallocate()
            else
                set next = thistype(0).next
                set thistype(0).next = this
            endif
        endmethod
        method deq takes nothing returns nothing
            debug if (not head) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempted To Deq Null BigInt")
                debug return
            debug endif
            debug if (next.head) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempted To Deq 0 BigInt")
                debug return
            debug endif
            set size = size - 1
            set this = prev
            set prev.next = next
            set next.prev = prev
            static if DOUBLE_FREE_CHECK then
                call deallocate()
            else
                set next = thistype(0).next
                set thistype(0).next = this
            endif
        endmethod
        method toInt takes nothing returns integer
            local integer i = 0
            local integer base
            debug if (not head) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempted To Convert Null BigInt To Int")
                debug set i = 1/0
            debug endif
            if (packed) then
                set base = packedBase[bm]
                if (base == 0) then
                    set base = bm
                endif
            else
                set base = bm
            endif
            loop
                set this = prev
                exitwhen head
                set i = i*base+digit
            endloop
            return i
        endmethod
        private static string eBigIntString
        private static BigInt eBigInt2String
        private static Base eBigInt2StringBase
        private static method eToString takes nothing returns boolean
            local thistype this = eBigInt2String
            local string s = ""
            local string array chars
            local integer stringLength = 0
            local Base b = eBigInt2StringBase
            
            debug local integer c = 0
            debug local thistype root = this
            
            if (packed or b == 0) then
                if (next.head) then
                    set eBigIntString = "0"
                    return true
                endif
                loop
                    set this = next
                    exitwhen head
                    set chars[stringLength] = I2S(digit)
                    set chars[stringLength + 1] = ", "
                    set stringLength = stringLength + 2
                    debug set c = c + 1
                    debug if (c > root.size) then
                        debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Malformed BigInt: "+s)
                        debug set b = 1/0
                    debug endif
                endloop
                set stringLength = stringLength - 1
            else
                if (next.head) then
                    set eBigIntString = b.char(0)
                    return true
                endif
                loop
                    set this = next
                    exitwhen head
                    set chars[stringLength] = b.char(digit)
                    set stringLength = stringLength + 1
                    debug set c = c + 1
                    debug if (c > root.size) then
                        debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Malformed BigInt: "+s)
                        debug set b = 1/0
                    debug endif
                endloop
            endif
            loop
                exitwhen 0 == stringLength
                set stringLength = stringLength - 1

                set s = s + chars[stringLength]
            endloop
            debug if (root.size != StringLength(s)) then
                debug if (c > root.size) then
                    debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Malformed BigInt: "+s)
                    debug set b = 1/0
                debug endif
            debug endif
            
            set eBigIntString = s
        
            return true
        endmethod
        method toString takes nothing returns string
            debug if (not head) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempted To Convert Null BigInt To String")
                debug set this = 1/0
            debug endif
            
            set eBigInt2String = this
            set eBigInt2StringBase = 0
            if (not TriggerEvaluate(evalToString)) then
                set this = 1/0
            endif
            
            return eBigIntString
        endmethod
        method toStringAlphabet takes Base base returns string
            debug if (not head) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempted To Convert Null BigInt To String")
                debug set this = 1/0
            debug endif
            debug if (base.size != bm) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempted Output BigInt In Invalid Alphabet")
                debug set this = 1/0
            debug endif
            
            set eBigInt2String = this
            set eBigInt2StringBase = base
            if (not TriggerEvaluate(evalToString)) then
                set this = 1/0
            endif
            
            return eBigIntString
        endmethod
        
        method subtract takes integer i returns nothing
            local integer m
            local integer base
            local thistype tn
            local thistype tc
            local thistype ro = this
            debug if (not head) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempted To Subtract Null BigInt")
                debug set m = 1/0
            debug endif
            if (packed) then
                set base = packedBase[bm]
                if (base == 0) then
                    set base = bm
                endif
            else
                set base = bm
            endif
            loop
                exitwhen 0 == i
                set this = next
                set m = i-i/base*base
                set i = i/base
                if (digit < m) then
                    set tc = this
                    set tn = next
                    loop
                        set tn.digit = tn.digit - 1
                        set tc.digit = tc.digit + base
                        exitwhen -1 < tn.digit
                        set tc = tc.next
                        set tn = tn.next
                    endloop
                endif
                set digit = digit - m
            endloop
            
            set this = ro
            if (0 == prev.digit and not prev.head) then
                loop
                    set this = prev
                    exitwhen 0 != digit or head
                    set ro.size = ro.size - 1
                endloop
            
                set this = next
                static if DOUBLE_FREE_CHECK then
                    call deallocateRange(this, ro.prev)
                else
                    set ro.prev.next = thistype(0).next
                    set thistype(0).next = this
                endif
                set ro.prev = prev
                set prev.next = ro
            endif
        endmethod
        method subtractBig takes BigInt i returns nothing
            local integer base
            local thistype root = this
            local thistype tn
            local thistype tc
            debug if (not head or not i.head) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempted To Subtract Null BigInt")
                debug set i = 1/0
            debug endif
            debug if (bm != i.bm) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempting To Subtract BigInts With Different Bases")
                debug set i = 1/0
            debug endif
            if (packed) then
                set base = packedBase[bm]
                if (base == 0) then
                    set base = bm
                endif
            else
                set base = bm
            endif
            loop
                set this = next
                set i = i.next
                exitwhen i.head
                if (digit < i.digit) then
                    set tc = this
                    set tn = next
                    loop
                        set tn.digit = tn.digit - 1
                        set tc.digit = tc.digit + base
                        exitwhen -1 < tn.digit
                        set tc = tc.next
                        set tn = tn.next
                    endloop
                endif
                set digit = digit - i.digit
            endloop
            
            set this = root
            if (0 == prev.digit and not prev.head) then
                loop
                    set this = prev
                    exitwhen 0 != digit or head
                    set root.size = root.size - 1
                endloop
            
                set this = next
                static if DOUBLE_FREE_CHECK then
                    call deallocateRange(this, root.prev)
                else
                    set root.prev.next = thistype(0).next
                    set thistype(0).next = this
                endif
                set root.prev = prev
                set prev.next = root
            endif
        endmethod
        
        method multiply takes integer i returns nothing
            local integer carry = 0
            local thistype root = this
            local integer m = 0
            local thistype cur = this
            local BigInt i2
            local thistype curi
            local integer base
            
            debug if (not head) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempted To Multiply Null BigInt")
                debug set m = 1/0
            debug endif
            
            if (0 == i) then
                call clear()
                return
            elseif (next.head) then
                return
            endif
            
            if (packed) then
                set base = packedBase[bm]
                if (base == 0) then
                    set base = bm
                endif
            else
                set base = bm
            endif
            
            set i2 = remake()
            
            loop
                exitwhen 0 == i
                set m = i-i/base*base
                set i = i/base
                loop
                    set this = next
                    set i2 = i2.next
                    exitwhen i2.head
                    if (head) then
                        set this = allocate()
                        call root.ad(this)
                    endif
                    set digit = digit + i2.digit*m
                    set carry = digit/base
                    set digit = digit - digit/base*base
                    set curi = this
                    loop
                        exitwhen 0 == carry
                        set this = next
                        if (head) then
                            set this = allocate()
                            call root.ad(this)
                        endif
                        set digit = digit + carry
                        set carry = digit/base
                        set digit = digit - digit/base*base
                    endloop
                    set this = curi
                endloop
                set cur = cur.next
                set this = cur
            endloop
            
            call i2.destroy()
        endmethod
        
        private static integer emto
        private static integer embt
        private static BigInt embt2
        private static integer embm
        private static integer embb
        private static integer embs
        private static integer embc
        private static method eMultiplyBig takes nothing returns boolean
            local thistype this = embt
            local thistype i = embm
            local integer carry = 0
            local thistype root = emto
            local integer m = 0
            local thistype cur = embc
            local BigInt i2 = embt2
            local thistype curi
            local integer base = embb
            local integer z = 2325
            
            debug set rn = false
            loop
                if (0 == embs) then
                    set i = i.next
                    exitwhen i.head
                    set m = i.digit
                    set embs = 1
                endif
                
                if (0 == m) then
                    call root.push(0)
                else
                    loop
                        set this = next
                        set i2 = i2.next
                        exitwhen i2.head
                        if (head) then
                            set this = allocate()
                            call root.ad(this)
                        endif
                        set curi = this
                        set digit = digit + i2.digit*m
                        set carry = digit/base
                        set digit = digit - digit/base*base
                        loop
                            exitwhen 0 == carry
                            set this = next
                            if (head) then
                                set this = allocate()
                                call root.ad(this)
                            endif
                            set digit = digit + carry
                            set carry = digit/base
                            set digit = digit - digit/base*base
                        endloop
                        set this = curi
                        set z = z - 1
                        if (0 == z) then
                            set embm = i
                            set embt = this
                            set embc = cur
                            set embt2 = i2
                            debug set rn = true
                            return false
                        endif
                    endloop
                endif
                set embs = 0
                
                set cur = cur.next
                set this = cur
            endloop
            debug set rn = true
            
            return true
        endmethod
        method multiplyBig takes BigInt i returns nothing
            debug if (not head or not i.head) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempted To Multiply Null BigInt")
                debug set i = 1/0
            debug endif
            debug if (bm != i.bm) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempting To Multiply BigInts With Different Bases")
                debug set i = 1/0
            debug endif
            
            if (i.next.head) then
                call clear()
                return
            elseif (next.head) then
                return
            endif
            
            if (packed) then
                set embb = packedBase[bm]
                if (base == 0) then
                    set base = bm
                endif
            else
                set embb = bm
            endif
            
            set embc = this
            set emto = this
            set embt = this
            set embm = i
            set i = remake()
            set embt2 = i
            set embs = 0
            
            loop
                exitwhen TriggerEvaluate(evalMultBig)
                debug if (not rn) then
                    debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Multiply Big Crashed")
                    debug set i = 1/0
                debug endif
            endloop
            
            call i.destroy()
        endmethod
        
        private method multFast takes integer base, thistype orig, integer guess returns nothing
            local integer carry = 0
            local thistype root = this
            local integer size = orig.size
            
            loop
                set orig = orig.next
                exitwhen orig.head
                set this = next
                set digit = orig.digit*guess + carry
                set carry = digit/base
                set digit = digit - digit/base*base
            endloop
            loop
                exitwhen 0 == carry
                set this = next
                if (head) then
                    set this = allocate()
                    call root.ad(this)
                endif
                set size = size + 1
                set digit = carry - carry/base*base
                set carry = carry/base
            endloop
            if (root.size > size) then
                set this = next
                set orig = root.prev
                
                //remove from list
                set prev.next = root
                set root.prev = prev
                
                static if DOUBLE_FREE_CHECK then
                    call deallocateRange(this, orig)
                else
                    set orig.next = thistype(0).next
                    set thistype(0).next = this
                endif
            endif
            set root.size = size
        endmethod
        
        private static BigInt eDivBigT
        private static BigInt eDivBigN
        private static BigInt eDivBigD
        private static BigInt eDivBigR
        private static integer eDivBigB
        private static method eDivideBig takes nothing returns boolean
            local integer guess1
            local integer guess2
            local thistype this = eDivBigT
            local BigInt remainder = eDivBigR
            local thistype divisor = eDivBigD
            local thistype numerator = eDivBigN
            local integer base = eDivBigB
            local thistype toSubtract
            local thistype rootThis = this
            local thistype rootRemainder = remainder
            local thistype rootDivisor = divisor
            local thistype rootNumerator = numerator
            local thistype rootToSubtract
            local thistype tn
            local thistype tc
            local integer toPush
            
            local integer guess
            
            local boolean isLessThan
            
            local integer largeRemainderCombined
            local integer largeDivisor = divisor.prev.digit
            local integer largeDivisor2 = divisor.prev.prev.digit
            local integer largeDivisorCombined = largeDivisor*base+largeDivisor2
            
            debug local integer mzmz
            
            debug set rn = false
            
            loop
                if (0 == size) then
                    set toPush = -divisor.size
                else
                    set toPush = -1
                endif
                
                loop
                    exitwhen 0 == numerator.size or remainder.gtoe(divisor)
                    call numerator.deto(remainder)
                    set toPush = toPush + 1
                endloop
                
                static if DEBUG_MSGS then
                    call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,I2S(size)+", "+I2S(toPush))
                endif
                
                set isLessThan = remainder.lt(divisor)
                
                if (isLessThan) then
                    set toPush = toPush + 1
                endif
                
                if (0 < size and 0 < toPush) then
                    loop
                        call push(0)
                        set toPush = toPush - 1
                        exitwhen 0 == toPush
                    endloop
                endif
                
                exitwhen isLessThan
                
                set largeRemainderCombined = remainder.prev.digit*base + remainder.prev.prev.digit
                
                set guess = remainder.prev.digit/largeDivisor
                if (0 == guess and 1 < remainder.size) then
                    set guess = largeRemainderCombined/largeDivisor
                elseif (1 < divisor.size and 1 < remainder.size) then
                    set guess = largeRemainderCombined/largeDivisorCombined
                    if (0 == guess) then
                        set guess = base - 1
                    endif
                endif
                
                static if DEBUG_MSGS then
                    call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,remainder.toString()+" / "+divisor.toString())
                endif
                static if DEBUG_MSGS then
                    call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Pre Guess: "+I2S(guess))
                endif
                
                set toSubtract = divisor.copy()
                set rootToSubtract = toSubtract
                call toSubtract.multFast(base, divisor, guess)
                
                static if DEBUG_MSGS then
                    call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"To Subtract Initial: "+toSubtract.toString())
                endif
                
                set guess1 = -1
                set guess2 = -1
                loop
                    if (toSubtract.prev.digit*base + toSubtract.prev.prev.digit > remainder.prev.digit*base + remainder.prev.prev.digit) then
                        set guess1 = guess - ((toSubtract.prev.digit*base + toSubtract.prev.prev.digit) - (remainder.prev.digit*base + remainder.prev.prev.digit))/divisor.prev.digit
                        
                        static if DEBUG_MSGS then
                            call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Guess 1: "+I2S(guess1))
                        endif
                        if (0 < guess1 and base > guess1 and guess1 != guess) then
                            call toSubtract.multFast(base, divisor, guess1)
                            if (guess1 + 5 > guess and guess1 - 5 < guess) then
                                set guess = guess1
                                exitwhen true
                            endif
                            set guess = guess1
                            
                            static if DEBUG_MSGS then
                                call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"To Subtract 1: "+toSubtract.toString())
                            endif
                            
                            if (remainder.size > toSubtract.size) then
                                set guess2 = guess + ((remainder.prev.digit*base + remainder.prev.prev.digit) - (toSubtract.prev.digit))/divisor.prev.digit
                            else
                                if (remainder.prev.digit > toSubtract.prev.digit) then
                                    set guess2 = guess + ((remainder.prev.digit*base + remainder.prev.prev.digit) - (toSubtract.prev.digit*base + toSubtract.prev.prev.digit))/divisor.prev.digit
                                else
                                    set guess2 = guess + (remainder.prev.prev.digit - toSubtract.prev.prev.digit)/divisor.prev.digit + (divisor.prev.prev.digit + base/2)/base
                                endif
                            endif
                            
                            static if DEBUG_MSGS then
                                call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Guess 2: "+I2S(guess2))
                            endif
                            
                            if (base > guess2 and 0 < guess2 and guess1 != guess2) then
                                call toSubtract.multFast(base, divisor, guess2)
                                if (guess2 + 5 > guess and guess2 - 5 < guess) then
                                    set guess = guess2
                                    exitwhen true
                                endif
                                set guess = guess2
                                
                                static if DEBUG_MSGS then
                                    call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"To Subtract 2: "+toSubtract.toString())
                                endif
                            else
                                exitwhen true
                            endif
                        else
                            exitwhen true
                        endif
                    else
                        exitwhen true
                    endif
                endloop
                
                static if DEBUG_MSGS then
                    call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Estimated Guess: "+I2S(guess))
                endif
                
                debug set mzmz = 0
                loop
                    //compare
                    if (remainder.size == toSubtract.size) then
                        loop
                            set toSubtract = toSubtract.prev
                            set remainder = remainder.prev
                            exitwhen toSubtract.head or remainder.digit != toSubtract.digit
                        endloop
                        exitwhen remainder.digit >= toSubtract.digit
                    else
                        exitwhen true
                    endif
                    
                    set toSubtract = rootToSubtract
                    set remainder = rootRemainder
                    
                    if (0 == guess - 1) then
                        set guess = base - 1
                        call toSubtract.multFast(base, divisor, guess)
                        exitwhen true
                    else
                        debug set mzmz = mzmz + 1
                        debug if (3 == mzmz) then
                            debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Not Accurate Enough Guess")
                            debug set guess = 1/0
                        debug endif
                        
                        set guess = guess - 1
                        
                        static if DEBUG_MSGS then
                            call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Subtracting Toward Correct Guess: "+I2S(guess))
                        endif
                        
                        //subtract
                        loop
                            set toSubtract = toSubtract.next
                            set divisor = divisor.next
                            exitwhen divisor.head
                            if (toSubtract.digit < divisor.digit) then
                                set tc = toSubtract
                                set tn = toSubtract.next
                                loop
                                    set tn.digit = tn.digit - 1
                                    set tc.digit = tc.digit + base
                                    exitwhen -1 < tn.digit
                                    set tc = tc.next
                                    set tn = tn.next
                                endloop
                            endif
                            set toSubtract.digit = toSubtract.digit - divisor.digit
                        endloop
                        
                        set divisor = rootDivisor
                        set toSubtract = rootToSubtract
                        
                        if (0 == toSubtract.prev.digit and 0 < toSubtract.size) then
                            set tn = toSubtract
                            loop
                                set tn = tn.prev
                                exitwhen 0 != tn.digit or tn.head
                                set toSubtract.size = toSubtract.size - 1
                            endloop
                        
                            set tn = tn.next
                            static if DOUBLE_FREE_CHECK then
                                call deallocateRange(tn, toSubtract.prev)
                            else
                                set toSubtract.prev.next = thistype(0).next
                                set thistype(0).next = tn
                            endif
                            set toSubtract.prev = tn.prev
                            set tn.prev.next = toSubtract
                        endif
                    endif
                endloop
                
                static if DEBUG_MSGS then
                    call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Guess Final: "+I2S(guess))
                endif
                static if DEBUG_MSGS then
                    call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"To Subtract Final: "+rootToSubtract.toString())
                endif
                
                call push(guess)
                
                static if DEBUG_MSGS then
                    call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,rootRemainder.toString()+" - "+rootToSubtract.toString())
                endif
                
                set toSubtract = rootToSubtract.next
                set remainder = rootRemainder.next
                
                loop
                    if (remainder.digit < toSubtract.digit) then
                        set tc = remainder
                        set tn = remainder.next
                        loop
                            set tn.digit = tn.digit - 1
                            set tc.digit = tc.digit + base
                            exitwhen -1 < tn.digit
                            set tc = tc.next
                            set tn = tn.next
                        endloop
                    endif
                    set remainder.digit = remainder.digit - toSubtract.digit
                    set toSubtract = toSubtract.next
                    set remainder = remainder.next
                    exitwhen toSubtract.head
                endloop
                
                set remainder = rootRemainder
                if (0 == remainder.prev.digit and 0 < remainder.size) then
                    loop
                        set remainder = remainder.prev
                        exitwhen 0 != remainder.digit or remainder.head
                        set rootRemainder.size = rootRemainder.size - 1
                    endloop
                
                    set remainder = remainder.next
                    static if DOUBLE_FREE_CHECK then
                        call deallocateRange(remainder, rootRemainder.prev)
                    else
                        set rootRemainder.prev.next = thistype(0).next
                        set thistype(0).next = remainder
                    endif
                    set rootRemainder.prev = remainder.prev
                    set remainder.prev.next = rootRemainder
                endif
                set remainder = rootRemainder
                
                call toSubtract.destroy()
                
                static if DEBUG_MSGS then
                    call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"-> "+remainder.toString())
                endif
            endloop
            
            debug set rn = true
            
            static if DEBUG_MSGS then
                call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Dividend: "+toString())
            endif
            
            return true
        endmethod
        
        method divideBig takes thistype d returns thistype
            local BigInt r
            local BigInt n
            
            local integer base
            
            debug if (not head or not d.head) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempted To Divide Null BigInt")
                debug return 0
            debug endif
            debug if (d.next.head) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempted To Divide By 0")
                debug return 0
            debug endif
            debug if (bm != d.bm) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempting To Divide BigInts With Different Bases")
                debug set base = 1/0
                debug return 0
            debug endif
            
            set n = remake()
            
            if (n.lt(d)) then
                return n
            endif
            
            set r = create()
            set r.bm = n.bm
            
            if (packed) then
                set base = packedBase[bm]
                if (base == 0) then
                    set base = bm
                endif
            else
                set base = bm
            endif
            
            set eDivBigN = n
            set eDivBigT = this
            set eDivBigR = r
            set eDivBigD = d
            set eDivBigB = base
            
            call TriggerEvaluate(evalDivideBig)
            debug if (not rn) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Divide Big Crashed")
                debug set base = 1/0
            debug endif
            
            call n.destroy()
            
            return r
        endmethod
        method divide takes integer d returns integer
            local BigInt i
            local BigInt r
            
            debug if (not head) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempted To Divide Null BigInt")
                debug return 0
            debug endif
            debug if (0 == d) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempted To Divide By 0")
                debug return 0
            debug endif
            
            set i = create()
            set i.bm = bm
            call i.add(d)
            set r = divideBig(i)
            call i.destroy()
            set d = r.toInt()
            call r.destroy()
            
            return d
        endmethod
        method operator base takes nothing returns Base
            return bm
        endmethod
        
        method pack takes nothing returns nothing
            local thistype root = this
            local thistype old
            local integer digit = 0
            local integer base = bm
            local integer packedBase
            local integer packedPow
            local integer extra
            local integer counter
            
            if (packed) then
                return
            endif
            
            set packed = true
            
            if (0 == thistype.packedBase[base] or base > 128) then
                return
            endif
            
            set packedBase = thistype.packedBase[base]
            set packedPow = thistype.packedPower[base]
            set extra = size - size/packedPow*packedPow
            set counter = packedPow
            
            set old = remake()
            
            if (0 != extra) then
                loop
                    exitwhen 0 == extra
                    set extra = extra - 1
                    set old = old.prev
                    set digit = digit*base + old.digit
                endloop
                set this = allocate()
                set this.digit = digit
                call root.adp(this)
            endif
            
            set digit = 0
            loop
                set old = old.prev
                exitwhen old.head
                set digit = digit*base + old.digit
                set counter = counter - 1
                if (0 == counter) then
                    set counter = packedPow
                    set this = allocate()
                    set this.digit = digit
                    call root.adp(this)
                    set digit = 0
                endif
            endloop
            
            call old.destroy()
        endmethod
        
        method unpack takes nothing returns nothing
            local thistype root = this
            local thistype old
            local thistype oldRoot
            local integer digit = 0
            local integer base = bm
            local integer packedBase
            local integer packedPow
            local integer counter
            local integer lastDigit
            
            if (not packed) then
                return
            endif
            
            set packed = false
            
            if (0 == thistype.packedBase[base] or base > 128) then
                return
            endif
            
            set packedBase = thistype.packedBase[bm]
            set packedPow = thistype.packedPower[base]
            
            set old = remake()
            set oldRoot = old
            
            set old = old.prev
            if (old.head) then
                call old.destroy()
                return
            endif
            
            set lastDigit = old.digit
            call oldRoot.deq()
            
            set old = oldRoot
            loop
                set old = old.next
                exitwhen old.head
                set digit = old.digit
                set counter = packedPow
                loop
                    set this = allocate()
                    call root.ad(this)
                    set this.digit = digit - digit/base*base
                    set counter = counter - 1
                    exitwhen 0 == counter
                    set digit = digit/base
                endloop
            endloop
            
            set digit = lastDigit
            loop
                set this = allocate()
                call root.ad(this)
                set this.digit = digit - digit/base*base
                set digit = digit/base
                exitwhen 0 == digit
            endloop
            
            call old.destroy()
        endmethod
        
        //evalBase
        private static integer ebs
        private static integer ebs2
        private static integer ebt
        private static integer ebi
        private static integer em
        
        private method fastdiv takes integer base, integer divide, integer remainder returns integer
            loop
                set digit = remainder/divide
                set remainder = remainder - remainder/divide*divide
                
                loop
                    set this = prev
                    if (head) then
                        return remainder
                    endif
                    
                    set remainder = remainder*base + digit
                    exitwhen remainder >= divide
                    set digit = 0
                endloop
            endloop
            
            return remainder
        endmethod
        private static method ebase takes nothing returns boolean
            local BigInt from = ebi
            local BigInt this = ebt
            local integer fromBase = ebs
            local integer toBase = ebs2
            
            local thistype node
            local thistype remainder
            
            debug set rn = false
            
            loop
                //allocate node
                set node = allocate()
                
                //add node
                set node.next = this
                set node.prev = prev
                set prev.next = node
                set prev = node
                set size = size + 1
                
                set remainder = 0
                loop
                    set remainder = remainder*fromBase + from.digit
                    exitwhen remainder >= toBase
                    set from = from.prev
                    exitwhen from.head
                endloop
                
                if (from.head) then
                    set node.digit = remainder
                else
                    set node.digit = from.fastdiv(fromBase, toBase, remainder)
                endif
                
                exitwhen from.head
            endloop
            
            debug set rn = true
            
            return false
        endmethod
        //evalBase
        
        private static integer baseToSet
        private static thistype thisToConvert
        private static method setBase takes nothing returns boolean
            local thistype this = thisToConvert
            local Base base = baseToSet
            local BigInt toConvert
            local integer oldBase
            local integer newBase
            local boolean wasPacked
            
            set wasPacked = packed
            
            if (not wasPacked) then
                call pack()
            endif
            
            set oldBase = packedBase[bm]
            if (0 == oldBase) then
                set oldBase = bm
            endif
            set newBase = packedBase[base]
            if (0 == newBase) then
                set newBase = base
            endif
            
            if (oldBase == newBase) then
                set bm = base
                if (not wasPacked) then
                    call unpack()
                    return false
                endif
            endif
            
            set toConvert = remake()
            
            set ebs = oldBase
            set ebs2 = newBase
            set ebt = this
            set ebi = toConvert.prev
            
            call TriggerEvaluate(evalBase)
            debug if (not rn) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Base Conversion Crash -> "+I2S(newBase))
                debug set bm = bm/0
            debug endif
            
            call toConvert.destroy()
            
            set bm = base
            
            if (not wasPacked) then
                call unpack()
            endif
            
            return false
        endmethod
        
        method operator base= takes integer base returns nothing
            debug if (not head) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempted To Change Base Of Null BigInt")
                debug return
            debug endif
            debug if (base < 0) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attmpted To Change Base Of BigInt To Invalid Base")
                debug return
            debug endif
            
            if (base == 0) then
                set base = BASE
            endif
            
            if (bm != base and 0 < size) then
                set baseToSet = base
                set thisToConvert = this
                call TriggerEvaluate(evalSetBase)
            else
                set bm = base
            endif
        endmethod
        method modBig takes BigInt i returns BigInt
            local BigInt h = copy()
            local BigInt k = h.divideBig(i)
            call h.destroy()
            return k
        endmethod
        method mod takes integer i returns integer
            local BigInt m
            local BigInt r
            if (1 == i) then
                return 0
            endif
            set m = create()
            set m.bm = bm
            call m.add(i)
            set r = modBig(m)
            set i = r.toInt()
            call m.destroy()
            call r.destroy()
            return i
        endmethod
        
        implement Init
    endstruct
endlibrary