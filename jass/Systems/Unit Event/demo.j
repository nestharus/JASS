struct UnitEventDemo extends array
    private static real x
    private static real y
    
    private method death takes nothing returns nothing
        call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, I2S(this)+":"+ GetUnitName(unit) + " died")
    endmethod
    
    private method remove takes nothing returns nothing
        call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, I2S(this)+":"+ GetUnitName(unit) + " removed")
    endmethod
    
    private method decay takes nothing returns nothing
        call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, I2S(this)+":"+ GetUnitName(unit) + " decayed")
    endmethod
    
    private method explode takes nothing returns nothing
        call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, I2S(this)+":"+ GetUnitName(unit) + " exploded")
    endmethod
    
    private method resurrect takes nothing returns nothing
        call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, I2S(this)+":"+ GetUnitName(unit) + " resurrected")
    endmethod
    
    private method startReincarnate takes nothing returns nothing
        call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, I2S(this)+":"+ GetUnitName(unit) + " is reincarnating")
    endmethod
    
    private method reincarnate takes nothing returns nothing
        call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, I2S(this)+":"+ GetUnitName(unit) + " reincarnated")
    endmethod
    
    private method animate takes nothing returns nothing
        call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, I2S(this)+":"+ GetUnitName(unit) + " animated")
    endmethod
    
    private static method filter takes unit u returns boolean
        //normally
        //return (GetUnitTypeId(u) == 'hkni')
        
        if (GetUnitTypeId(u) == 'hkni') then
            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, GetUnitName(u) + " was filtered")
            return false
        endif
        return true
    endmethod
    
    private static method removes takes nothing returns nothing
        call RemoveUnit(CreateUnit(Player(0), 'hkni', x, y, 0))
        call RemoveUnit(CreateUnit(Player(0), 'hrif', x, y, 0))
    endmethod
    
    private static method onInit takes nothing returns nothing
        local unit u
        
        set x = GetRectCenterX(bj_mapInitialPlayableArea)
        set y = GetRectCenterY(bj_mapInitialPlayableArea)
        call PanCameraTo(x, y)
        
        call CreateUnit(Player(0), 'hfoo', x, y, 0)
        call CreateUnit(Player(0), 'hpea', x, y, 0)
        call CreateUnit(Player(0), 'hfoo', x, y, 0)
        call CreateUnit(Player(0), 'hpea', x, y, 0)
        call CreateUnit(Player(0), 'hfoo', x, y, 0)
        call CreateUnit(Player(0), 'hpea', x, y, 0)
        set u = CreateUnit(Player(0), 'Hpal', x, y, 0)
        call SetHeroLevel(u, 10, false)
        call SetHeroAgi(u, 8000, true)
        call SetHeroInt(u, 8000, true)
        call SetHeroStr(u, 8000, true)
        set u = CreateUnit(Player(0), 'Udea', x, y, 0)
        call SetHeroLevel(u, 10, false)
        call SetHeroAgi(u, 8000, true)
        call SetHeroInt(u, 8000, true)
        call SetHeroStr(u, 8000, true)
        set u = CreateUnit(Player(0), 'Otch', x, y, 0)
        call SetHeroLevel(u, 10, false)
        
        call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Creating and Removing a unit in 5 seconds\n\n")
        call TimerStart(CreateTimer(), 5, false, function thistype.removes)
        
        set u = null
    endmethod
    
    implement UnitEventStruct
endstruct