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
        local thistype node1=add(1)
        local thistype node2=add(2)
        local thistype node3=add(3)
        //call clear()
        call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"               "+I2S(down.value))
        call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"      "+I2S(down.left.value)+"               "+I2S(down.right.value))
        call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"  "+I2S(down.left.left.value)+"      "+I2S(down.left.right.value)+"       "+I2S(down.right.left.value)+"      "+I2S(down.right.right.value))
        call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,I2S(down.left.left.left.value)+"  "+I2S(down.left.left.right.value)+"  "+I2S(down.left.right.left.value)+"  "+I2S(down.left.right.right.value)+"  "+I2S(down.right.left.left.value)+"  "+I2S(down.right.left.right.value)+"  "+I2S(down.right.right.left.value)+"  "+I2S(down.right.right.right.value))
        call DestroyTimer(GetExpiredTimer())
    endmethod
    private static method onInit takes nothing returns nothing
        call TimerStart(CreateTimer(),0,false,function thistype.init)
    endmethod
endstruct