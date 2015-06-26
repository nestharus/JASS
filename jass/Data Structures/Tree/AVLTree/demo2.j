struct Tester extends array
    private method lessThan takes thistype val returns boolean
        return integer(this)<integer(val)
    endmethod
    private method greaterThan takes thistype val returns boolean
        return integer(this)>integer(val)
    endmethod
    private method difference takes thistype val returns integer
        return integer(this)-integer(val)
    endmethod
    
    implement AVL
    
    private static method init takes nothing returns nothing
        local thistype this=create()
        local thistype s
        local string str=""
        
        call add(5)
        call add(10)
        call add(15)
        call add(20)
        call add(25)
        call add(30)
        call add(35)
        call add(40)
        call add(45)
        call add(50)
        call add(55)
        call add(60)
        call add(65)
        call add(70)
        call add(75)
        
        loop
            set this=next
            exitwhen head
            if (str=="") then
                set str=I2S(value)
            else
                set str=str+","+I2S(value)
            endif
        endloop
        call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,str)
        
        set s = searchClose(22,false)
        call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"22 High -> "+I2S(s.value))
        set s = searchClose(22,true)
        call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"22 Low -> "+I2S(s.value))
        
        call DestroyTimer(GetExpiredTimer())
    endmethod
    private static method onInit takes nothing returns nothing
        call TimerStart(CreateTimer(),0,false,function thistype.init)
    endmethod
endstruct