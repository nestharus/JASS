library Base /* v1.0.4.1
*************************************************************************************
*
*   A script used for base conversion where integers are represented as strings in
*   another base.
*
*************************************************************************************
*
*   */uses/*
*
*       */ Ascii /*         wc3c.net/showthread.php?t=110153
*       */ Table /*         hiveworkshop.com/forums/jass-functions-413/snippet-new-table-188084/
*
************************************************************************************
*
*   struct Base extends array
*
*       readonly integer size
*           -   number of digits in base
*       readonly string string
*           -   string representing base's character set
*
*       static method operator [] takes string base returns Base
*
*       method convertToString takes integer i returns string
*       method convertToInteger takes string i returns integer
*
*       method ord takes string c returns integer
*       method char takes integer i returns string
*
*       method isValid takes string value returns boolean
*           -   determines if all of the characters in the string are valid base character
*
*************************************************************************************/

/*************************************************************************************
*
*   Code
*
*************************************************************************************/
    globals
        private Table gt=0          //stacks of strings with same hashes
        private integer array n     //next node pointer for gt stack
        private string array b      //base of string
        private Table array t       //base character table
        private integer c=0         //base instance count
        private integer array s     //base size
    endglobals
    private module Init
        private static method onInit takes nothing returns nothing
            set gt=Table.create()
        endmethod
    endmodule
    struct Base extends array
        debug private static boolean array a        //is allocated
        method operator string takes nothing returns string
            return b[this]
        endmethod
        method operator size takes nothing returns integer
            return s[this]
        endmethod
        static method operator [] takes string base returns thistype
            local integer value     //string hash value
            local string char       //iterated character
            local integer i=0       //this
            local integer v         //stack of hashes
            local integer dv        //copy of v
            local integer hv        //copy of value
            debug if (1<StringLength(base)) then
                set value = StringHash(base)    //first get the hash
                set i = gt[value]               //get first node of hash table
                set v = i                       //copy
                if (0!=i) then                  //if stack exists, then loop through
                    loop
                        exitwhen 0==i or base==b[i]
                        set i=n[i]
                    endloop
                endif
                //if this still doesn't exist, create it
                if (0==i) then
                    //allocate
                    set c=c+1
                    set i=c
                    set dv=v
                    set hv=value
                    debug set a[i]=true
                    set t[i]=Table.create()     //character table
                    set b[i]=base               //base string
                    //value is now used for iterating through the base string
                    set value=StringLength(base)
                    set s[i]=value    
                    loop
                        set value=value-1
                        set char=SubString(base,value,value+1)
                        set v=Char2Ascii(char)
                        //if the character already exists, stop
                        //and deallocate (invalid base)
                        debug if (t[i].has(v)) then
                            debug call t[i].destroy()   //destroy character table
                            debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"BASE CREATION ERROR: "+char+" MULTIPLY DEFINED")
                            debug set c=c-1
                            debug set a[i]=false
                            debug return 0
                        //character doesn't exist
                        debug else
                            set t[i][v]=value
                            set t[i].string[-value]=char
                        debug endif
                        exitwhen 0==value
                    endloop
                    //if dv is 0, then allocate dv
                    if (0==dv) then
                        set gt[hv]=i
                    //otherwise add i to hash stack
                    else
                        set n[i]=n[dv]
                        set n[dv]=i
                    endif
                endif
                return i
            debug endif
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"BASE CREATION ERROR: "+base+" IS INVALID")
            debug return 0
        endmethod
        method convertToString takes integer i returns string
            local integer k=s[this]
            local string n=""
            debug if (a[this]) then
                debug if (0<=i) then
                    loop
                        exitwhen i<k
                        set n=t[this].string[-(i-i/k*k)]+n
                        set i=i/k
                    endloop
                    return t[this].string[-i]+n
                debug endif
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"BASE CONVERSION ERROR: "+I2S(i)+" IS OUT OF BOUNDS")
                debug return null
            debug endif
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"BASE CONVERSION ERROR: "+I2S(this)+" IS NOT ALLOCATED")
            debug return null
        endmethod
        method convertToInteger takes string i returns integer
            local integer n=0
            local integer p=StringLength(i)
            local integer l=0
            local integer k=s[this]
            local string char
            debug if (a[this]) then
                loop
                    exitwhen 0==p
                    set p=p-1
                    set l=l+1
                    set char=SubString(i,l-1,l)
                    debug if (t[this].has(Char2Ascii(char))) then
                        set n=n+t[this][Char2Ascii(char)]*R2I(Pow(k,p))
                    debug else
                        debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"BASE CONVERSION ERROR: "+char+" IS OUT OF BOUNDS")
                        debug return 0
                    debug endif
                endloop
                return n
            debug endif
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"BASE CONVERSION ERROR: "+I2S(this)+" IS NOT ALLOCATED")
            debug return 0
        endmethod
        method ord takes string c returns integer
            debug if (a[this]) then
                debug if (1<StringLength(c) or ""==c or null==c or not (t[this].has(Char2Ascii(c)))) then
                    debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"BASE ORD ERROR: "+c+" IS OUT OF BOUNDS")
                    debug return 0
                debug endif
                return t[this][Char2Ascii(c)]
            debug endif
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"BASE ORD ERROR: "+I2S(this)+" IS NOT ALLOCATED")
            debug return 0
        endmethod
        method char takes integer i returns string
            debug if (a[this]) then
                debug if (i<s[this] and 0<=i) then
                    return t[this].string[-i]
                debug endif
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"BASE CHAR ERROR: "+I2S(i)+" IS OUT OF BOUNDS")
                debug return null
            debug endif
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"BASE CHAR ERROR: "+I2S(this)+" IS NOT ALLOCATED")
            debug return null
        endmethod
        method isValid takes string s returns boolean
            local integer i=StringLength(s)
            local string c
            if (0<i) then
                loop
                    set c=SubString(s,i-1,i)
                    if (not t[this].has(Char2Ascii(c))) then
                        return false
                    endif
                    set i=i-1
                    exitwhen 0==i
                endloop
            else
                return false
            endif
            return true
        endmethod
        implement Init
    endstruct
endlibrary