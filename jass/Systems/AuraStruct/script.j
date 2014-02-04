library AuraStruct /* v3.0.2.2
*************************************************************************************
*
*   An efficient and easy to use module for fully custom aura design.
*
*************************************************************************************
*
*   */uses/*
*
*       */ UnitIndexer /*               hiveworkshop.com/forums/jass-resources-412/system-unit-indexer-172090/
*       */ UnitInRangeEvent /*          hiveworkshop.com/forums/submissions-414/unitinrangeevent-205036/
*       */ TimerTools /*                hiveworkshop.com/forums/jass-functions-413/system-timer-tools-201165/
*       */ RegisterPlayerUnitEvent /*   hiveworkshop.com/forums/jass-functions-413/snippet-registerplayerunitevent-203338/
*
************************************************************************************
*
*   module AuraMod
*
*       Creator
*       -----------------------
*
*           static method register takes UnitIndex source, real auraRange returns nothing
*
*       Interface
*       -----------------------
*
*           private static constant boolean AURA_STACKS
*               (required) -   Does the aura stack?
*
*           private static constant real AURA_INTERVAL
*               (required) -   How often to run the aura
*
*           private static method getLevel takes UnitIndex sourceId returns integer
*               (required) -    Returns the level of the aura on the unit
*
*           private static method onLevel takes UnitIndex source, integer level returns nothing
*               (optional) -    Runs when aura levels up
*
*           private static method getRange takes UnitIndex source, integer level returns real
*               (required) -    Should return the range of the aura
*
*           private method onEndEffect takes UnitIndex source, UnitIndex affected, integer level returns nothing
*               (optional) -    Runs when the aura effect ends (aura no longer on unit)
*
*           private method onEffect takes UnitIndex source, UnitIndex affected, integer level returns nothing
*               (optional) -    Runs when aura effect starts (aura just went on to unit)
*
*           private method onPeriodicEffect takes UnitIndex source, UnitIndex affected, integer level returns nothing
*               (optional) -    Runs every period of the aura. First run is right after onEffect
*
*           private static method absFilter takes UnitIndex source, UnitIndex entering returns boolean
*               (optional) -    Runs when the unit initially enters in the range of the aura. If this returns false, the
*                          -    unit is ignored as if it doesn't exist and it will never be able to get the aura
*
*           private method filter takes UnitIndex source, UnitIndex affected, integer level returns boolean
*               (optional) -    Runs whenever the aura cycles (every TIMEOUT seconds). This helps determine if the
*                          -    aura is active or not for the unit.
*
*           private static method removeBuff takes unit source, unit whichUnit, integer level returns nothing
*               (optional) -    Runs when the buff icon should be removed from the unit
*
*           private static method addBuff takes unit source, unit whichUnit, integer level returns nothing
*               (optional) -    Runs when the buff icon should be added to the unit
*
************************************************************************************/
    private struct AuraStruct extends array
        readonly UnitIndex source
        readonly UnitIndex affected
        integer level
        integer oldLevel
        boolean active
        boolean alive
        
        static method create takes UnitIndex source, UnitIndex affected, boolexpr cond, integer funcId, real timeout returns thistype
            local thistype this = Timer.create(timeout, cond, funcId)
            
            set this.source = source
            set this.affected = affected
            
            call source.lock()
            call affected.lock()
            
            return this
        endmethod
        
        method destroy takes nothing returns nothing
            call Timer(this).destroy()
            set this.level = 0
            set this.oldLevel = 0
            set this.active = false
            
            call source.unlock()
            call affected.unlock()
        endmethod
    endstruct
    private struct AuraQueue extends array
        AuraStruct aura    //instance -> aura
        static AuraQueue array affected //instance -> affected
        static AuraStruct array high
        static AuraQueue array instance
    endstruct
    
    globals
        private hashtable table = InitHashtable()
    endglobals

    module AuraMod
        private static boolexpr cond
        private AuraStruct highest
        private integer enter
        private real range
        private integer oldLevel2
        
        implement TimerHead
    
        private static method allocate2 takes thistype source, thistype affected returns thistype
            local thistype this = AuraStruct.create(source, affected, cond, handler, AURA_INTERVAL)
            call add(this)
            call SaveBoolean(table, TABLE + source, affected, true)
            return this
        endmethod
        
        private static method onEnter takes nothing returns nothing
            local UnitIndex source = GetEventSourceUnitId()
            local UnitIndex affected = GetUnitUserData(GetTriggerUnit())
            
            static if thistype.absFilter.exists then
                if (not thistype.absFilter(source, affected)) then
                    return
                endif
            endif
            
            if (not HaveSavedBoolean(table, TABLE + source, affected)) then
                call allocate2(source, affected)
            endif
        endmethod
        
        static method register takes thistype source, real range returns nothing
            local integer level = getLevel(source)
            
            static if thistype.onLevel.exists then
                if (thistype(source).oldLevel2 != level) then
                    set thistype(source).oldLevel2 = level
                    call onLevel(source, level)
                endif
            endif
            
            if (source.range == range) then
                return
            endif
            
            set source.range = range
        
            if (source.enter != 0) then
                call UnregisterUnitInRangeEvent(source.enter)
                set source.enter = 0
            endif
            
            if (0 != range) then
                set source.enter = RegisterUnitInRangeEvent(function thistype.onEnter, GetUnitById(source), range)
            endif
            
            static if thistype.absFilter.exists then
                if (not thistype.absFilter(source, source)) then
                    return
                endif
            endif
            
            if (not HaveSavedBoolean(table, TABLE + source, source)) then
                call allocate2(source, source)
            endif
        endmethod
        
        private static method handler takes nothing returns boolean
            local AuraStruct aura = thistype(Timer.expired).first
            
            local unit source
            local unit affected
            
            local real dx
            local real dy
            local real range
            
            local boolean add
            
            local AuraQueue queue = 0
            
            local UnitIndex affectedP
            local UnitIndex sourceP
            
            local boolean alive
            
            local integer level
            
            loop
                set sourceP = aura.source
                set affectedP = aura.affected
                
                if (affectedP.unit != null and sourceP.unit != null) then
                    set source = sourceP.unit
                    set affected = affectedP.unit
                    
                    set aura.level = getLevel(sourceP)
                
                    set dx = GetUnitX(source) - GetUnitX(affected)
                    set dy = GetUnitY(source) - GetUnitY(affected)
                    set range = getRange(sourceP, aura.level)
                    
                    call register(sourceP, range)
                    
                    set add = dx*dx + dy*dy <= range*range and aura.level > 0
                
                    static if thistype.filter.exists then
                        set add = add and thistype(aura).filter(sourceP, affectedP, aura.level)
                    endif
                else
                    set add = false
                endif
                if (add) then
                    if (AURA_STACKS) then
                        set queue.aura = aura
                        set AuraQueue.affected[queue] = affectedP
                        if (aura.level > AuraQueue.high[affectedP].level) then
                            set AuraQueue.high[affectedP] = aura
                            set AuraQueue.instance[affectedP] = queue
                        endif
                        set queue = queue + 1
                    elseif (AuraQueue.high[affectedP].level < aura.level) then
                        if (0 == AuraQueue.high[affectedP]) then
                            set AuraQueue.affected[queue] = affectedP
                            set AuraQueue.instance[affectedP] = queue
                            set queue = queue + 1
                        endif
                        set AuraQueue.high[affectedP] = aura
                        set AuraQueue.instance[affectedP].aura = aura
                    else
                        set add = false
                    endif
                endif
                if (not add) then
                    if (aura.active) then
                        set aura.active = false
                        
                        static if thistype.onEndEffect.exists then
                            call thistype(aura).onEndEffect(sourceP, affectedP, aura.oldLevel)
                        endif
                        
                        if (aura == thistype(affectedP).highest) then
                            set thistype(affectedP).highest = 0
                            static if thistype.removeBuff.exists then
                                call thistype.removeBuff(sourceP.unit, affectedP.unit, aura.oldLevel)
                            endif
                        endif
                    endif
                    if (0 == aura.level) then
                        call RemoveSavedBoolean(table, TABLE + sourceP, affectedP)
                        set thistype(sourceP).oldLevel2 = 0
                        call aura.destroy()
                        call remove(aura)
                    endif
                    
                    set aura.oldLevel = aura.level
                endif
            
                set aura = Timer(aura).next
                exitwhen aura == 0
            endloop
            
            loop
                exitwhen queue == 0
                set queue = queue - 1
                
                set affectedP = AuraQueue.affected[queue]
                set alive = GetWidgetLife(affectedP.unit) > 0
                if (0 != AuraQueue.high[affectedP]) then
                    if (thistype(affectedP).highest == AuraQueue.high[affectedP]) then
                        set level = thistype(affectedP).highest.oldLevel
                    elseif (not thistype(affectedP).highest.active or thistype(affectedP).highest.level < AuraQueue.high[affectedP].level) then
                        set level = thistype(affectedP).highest.level
                    else
                        set level = thistype(affectedP).highest.level
                        set AuraQueue.high[affectedP] = thistype(affectedP).highest
                    endif
                    
                    if (AuraQueue.high[affectedP].level != level) then
                        static if thistype.removeBuff.exists then
                            if (0 != level) then
                                call thistype.removeBuff(thistype(affectedP).highest.source.unit, GetUnitById(affectedP), level)
                            endif
                        endif
                        
                        if (not AURA_STACKS) then
                            set aura = thistype(affectedP).highest
                        
                            if (aura != AuraQueue.high[affectedP] and aura.active) then
                                set aura.active = false
                                
                                static if thistype.onEndEffect.exists then
                                    if (aura.level != aura.oldLevel) then
                                        call thistype(aura).onEndEffect(aura.source, aura.affected, aura.oldLevel)
                                    else
                                        call thistype(aura).onEndEffect(aura.source, aura.affected, aura.level)
                                    endif
                                endif
                                
                                set aura.oldLevel = aura.level
                            endif
                        endif
                        
                        set thistype(affectedP).highest = AuraQueue.high[affectedP]
                        static if thistype.addBuff.exists then
                            if (0 != thistype(affectedP).highest) then
                                call thistype.addBuff(thistype(affectedP).highest.source.unit, GetUnitById(affectedP), thistype(affectedP).highest.level)
                            endif
                        endif
                    elseif (0 != thistype(affectedP).highest and thistype(affectedP).highest.alive != alive and alive) then
                        static if thistype.addBuff.exists then
                            call thistype.addBuff(thistype(affectedP).highest.source.unit, GetUnitById(affectedP), thistype(affectedP).highest.level)
                        endif
                    endif
                    set AuraQueue.high[affectedP] = 0
                elseif (0 != thistype(affectedP).highest and thistype(affectedP).highest.alive != alive and alive) then
                    static if thistype.addBuff.exists then
                        call thistype.addBuff(thistype(affectedP).highest.source.unit, GetUnitById(affectedP), thistype(affectedP).highest.level)
                    endif
                endif
                set thistype(affectedP).highest.alive = alive
                
                set aura = queue.aura
                set sourceP = aura.source
                if (0 != aura and (AURA_STACKS or aura == thistype(affectedP).highest)) then
                    if (aura.active) then
                        if (aura.oldLevel != aura.level) then
                            static if thistype.onEndEffect.exists then
                                call thistype(aura).onEndEffect(sourceP, affectedP, aura.oldLevel)
                            endif
                            static if thistype.onEffect.exists then
                                call thistype(aura).onEffect(sourceP, affectedP, aura.level)
                            endif
                        endif
                    else
                        set aura.active = true
                        static if thistype.onEffect.exists then
                            call thistype(aura).onEffect(sourceP, affectedP, aura.level)
                        endif
                    endif
                    static if thistype.onPeriodicEffect.exists then
                        call thistype(aura).onPeriodicEffect(sourceP, affectedP, aura.level)
                    endif
                endif
                
                set aura.oldLevel = aura.level
            endloop
            
            set source = null
            set affected = null
        
            return false
        endmethod
        
        private static method onInit takes nothing returns nothing
            set cond = Condition(function thistype.handler)
        endmethod
        
        private static constant integer TABLE = 8192*handler
    endmodule
endlibrary