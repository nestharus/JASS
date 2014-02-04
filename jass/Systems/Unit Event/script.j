library UnitEvent /* v3.0.1.2
*************************************************************************************
*
*   Makes new unit events for Warcraft 3.
*
*************************************************************************************
*
*   */uses/*
*   
*       */ UnitIndexer /*       (4.0.2.3) - hiveworkshop.com/forums/jass-functions-413/unit-indexer-172090/
*       */ RegisterPlayerUnitEvent /*       hiveworkshop.com/forums/jass-functions-413/snippet-registerplayerunitevent-203338/
*
************************************************************************************
*
*    Events:    registered via Event API
*       static constant Event UnitEvent.REMOVE
*       static constant Event UnitEvent.DECAY
*       static constant Event UnitEvent.EXPLODE
*       static constant Event UnitEvent.RESURRECT
*       static constant Event UnitEvent.REINCARNATE
*       static constant Event UnitEvent.ANIMATE
*       static constant Event UnitEvent.START_REINCARNATE
*
*   Functions:
*       function IsUnitDead takes integer index returns boolean
*       function IsUnitReincarnating takes integer index returns boolean
*       function IsUnitAnimated takes integer index returns boolean
*       function GetEventUnitId takes nothing returns integer
*       function GetEventUnit takes nothing returns unit
*   
*******************************************************************
*
*   module UnitEventStruct
*
*       -   A pseudo module interface that runs a set of methods if they exist.
*
*       -   implements UnitIndexStruct automatically
*
*       Interface:
*
*           -   These methods don't have to exist. If they don't exist, the code
*           -   that calls them won't even be in the module.
*
*           private method remove takes nothing returns nothing
*           private method decay takes nothing returns nothing
*           private method explode takes nothing returns nothing
*           private method resurrect takes nothing returns nothing
*           private method startReincarnate takes nothing returns nothing
*           private method reincarnate takes nothing returns nothing
*           private method animate takes nothing returns nothing
*
************************************************************************************/
    //! textmacro UNIT_EVENT_MACRO
    
    globals
        private real h=1000
        private timer time=null
        private real array j
        private boolean array k
        private boolean array z
        private boolean array x
        private boolean array v
        private integer array b
        private timer m=CreateTimer()
    endglobals
    function GetEventUnitId takes nothing returns integer
        return o
    endfunction
    function GetEventUnit takes nothing returns unit
        return e[o]
    endfunction
    function IsUnitDead takes integer index returns boolean
        return z[index]
    endfunction
    function IsUnitReincarnating takes integer index returns boolean
        return x[index]
    endfunction
    function IsUnitAnimated takes integer index returns boolean
        return k[index]
    endfunction
    private function OnReincarnateStart takes nothing returns nothing
        local integer i=o
        set o=b[0]
        loop
            if (x[o]) then
                call FireEvent(UnitEvent.START_REINCARNATE)
            endif
            set o=b[o]
            exitwhen 0==o
        endloop
        set b[0]=0
        set o=i
    endfunction
    private function OnDeath takes nothing returns boolean
        local unit u=GetTriggerUnit()
        local integer i=GetUnitUserData(u)
        local integer d=o
        if (u==e[i]) then
            set z[i]=true
            set x[i]=false
            if (not k[i]) then
                set j[i]=TimerGetElapsed(time)
            else
                set v[i]=true
                set k[i]=false
                set o=i
                call FireEvent(UnitEvent.EXPLODE)
                set o=d
            endif
        endif
        set u=null
        return false
    endfunction
    private module UnitEventModule
        local unit u=GetFilterUnit()
        local integer s=GetUnitUserData(u)
        local integer d=o
        if (u==e[s]) then
            set o=s
            if (0==GetUnitAbilityLevel(u,ABILITIES_UNIT_INDEXER)) then
                set x[s]=false
                set k[s]=false
                if (not v[s]) then
                    if (z[s] and h<=TimerGetElapsed(time)-j[s]) then
                        set z[s]=false
                        call FireEvent(UnitEvent.DECAY)
                    else
                        set z[s]=false
                        call FireEvent(UnitEvent.REMOVE)
                    endif
                else
                    set z[s]=false
                    set v[s]=false
                endif
                static if not LIBRARY_UnitList then
                    if (not a)then
                        set n[p[s]]=n[s]
                        set p[n[s]]=p[s]
                    endif
                else
                    set n[p[s]]=n[s]
                    set p[n[s]]=p[s]
                    call GroupRemoveUnit(g,e[s])
                endif
                call FireEvent(DEINDEX)
                if (0==lc[s]) then
                    set n[s]=y
                    set y=s
                endif
                set e[s]=null
            elseif (.405<GetWidgetLife(u) and 0!=GetUnitTypeId(u)) then
                if (x[s]) then
                    call FireEvent(UnitEvent.REINCARNATE)
                    set x[s]=false
                elseif (z[s]) then
                    set z[s]=false
                    if (IsUnitType(u,UNIT_TYPE_SUMMONED)) then
                        set k[s]=true
                        call FireEvent(UnitEvent.ANIMATE)
                    else
                        call FireEvent(UnitEvent.RESURRECT)
                    endif
                endif
            else
                set x[s]=true
                set b[s]=b[0]
                set b[0]=s
                call TimerStart(m,0,false,function OnReincarnateStart)
            endif
            set o=d
        endif
        set u=null
    endmodule
    //! endtextmacro
    //! textmacro UNIT_EVENT_MACRO_2
    private module UnitEventInits
        private static method decayer takes nothing returns boolean
            set h=TimerGetElapsed(time)-.9375
            call DestroyTrigger(GetTriggeringTrigger())
            return false
        endmethod
        private static method onInit takes nothing returns nothing
            local trigger t=CreateTrigger()
            local unit u
            set REMOVE=CreateEvent()
            set DECAY=CreateEvent()
            set EXPLODE=CreateEvent()
            set RESURRECT=CreateEvent()
            set REINCARNATE=CreateEvent()
            set ANIMATE=CreateEvent()
            set START_REINCARNATE=CreateEvent()
            set UnitIndexer.enabled=false
            set u=CreateUnit(Player(14),UNITS_UNIT_EVENT,WorldBounds.maxX,WorldBounds.maxY,0)
            set UnitIndexer.enabled=true
            call KillUnit(u)
            call ShowUnit(u,false)
            call TriggerRegisterUnitEvent(t,u,EVENT_UNIT_ISSUED_ORDER)
            call TriggerAddCondition(t,function thistype.decayer)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function OnDeath)
            call TimerStart(time,1000000,false,null)
            set u=null
            set t=null
        endmethod
    endmodule
    struct UnitEvent extends array
        readonly static Event REMOVE
        readonly static Event DECAY
        readonly static Event EXPLODE
        readonly static Event RESURRECT
        readonly static Event REINCARNATE
        readonly static Event ANIMATE
        readonly static Event START_REINCARNATE
        implement UnitEventInits
    endstruct
    //! endtextmacro
    //! textmacro UNIT_EVENT_STRUCT_MACRO
        private static method onInit takes nothing returns nothing
            static if thistype.remove.exists then
                call RegisterEvent(Condition(function thistype.onRemoveEvent),UnitEvent.REMOVE)
            endif
            static if thistype.decay.exists then
                call RegisterEvent(Condition(function thistype.onDecayEvent),UnitEvent.DECAY)
            endif
            static if thistype.explode.exists then
                call RegisterEvent(Condition(function thistype.onExplodeEvent),UnitEvent.EXPLODE)
            endif
            static if thistype.resurrect.exists then
                call RegisterEvent(Condition(function thistype.onResurrectEvent),UnitEvent.RESURRECT)
            endif
            static if thistype.startReincarnate.exists then
                call RegisterEvent(Condition(function thistype.onStartReincarnateEvent),UnitEvent.START_REINCARNATE)
            endif
            static if thistype.reincarnate.exists then
                call RegisterEvent(Condition(function thistype.onReincarnateEvent),UnitEvent.REINCARNATE)
            endif
            static if thistype.animate.exists then
                call RegisterEvent(Condition(function thistype.onAnimateEvent),UnitEvent.ANIMATE)
            endif
        endmethod
    //! endtextmacro
    module UnitEventStruct
        implement UnitIndexStruct
        static if thistype.remove.exists then
            private static method onRemoveEvent takes nothing returns boolean
                if (thistype(GetEventUnitId()).allocated) then
                    call thistype(GetEventUnitId()).remove()
                endif
                return false
            endmethod
        endif
        static if thistype.decay.exists then
            private static method onDecayEvent takes nothing returns boolean
                if (thistype(GetEventUnitId()).allocated) then
                    call thistype(GetEventUnitId()).decay()
                endif
                return false
            endmethod
        endif
        static if thistype.explode.exists then
            private static method onExplodeEvent takes nothing returns boolean
                if (thistype(GetEventUnitId()).allocated) then
                    call thistype(GetEventUnitId()).explode()
                endif
                return false
            endmethod
        endif
        static if thistype.resurrect.exists then
            private static method onResurrectEvent takes nothing returns boolean
                if (thistype(GetEventUnitId()).allocated) then
                    call thistype(GetEventUnitId()).resurrect()
                endif
                return false
            endmethod
        endif
        static if thistype.startReincarnate.exists then
            private static method onStartReincarnateEvent takes nothing returns boolean
                if (thistype(GetEventUnitId()).allocated) then
                    call thistype(GetEventUnitId()).startReincarnate()
                endif
                return false
            endmethod
        endif
        static if thistype.reincarnate.exists then
            private static method onReincarnateEvent takes nothing returns boolean
                if (thistype(GetEventUnitId()).allocated) then
                    call thistype(GetEventUnitId()).reincarnate()
                endif
                return false
            endmethod
        endif
        static if thistype.animate.exists then
            private static method onAnimateEvent takes nothing returns boolean
                if (thistype(GetEventUnitId()).allocated) then
                    call thistype(GetEventUnitId()).animate()
                endif
                return false
            endmethod
        endif
        static if thistype.remove.exists then
            //! runtextmacro UNIT_EVENT_STRUCT_MACRO()
        elseif thistype.decay.exists then
            //! runtextmacro UNIT_EVENT_STRUCT_MACRO()
        elseif thistype.explode.exists then
            //! runtextmacro UNIT_EVENT_STRUCT_MACRO()
        elseif thistype.resurrect.exists then
            //! runtextmacro UNIT_EVENT_STRUCT_MACRO()
        elseif thistype.startReincarnate.exists then
            //! runtextmacro UNIT_EVENT_STRUCT_MACRO()
        elseif thistype.reincarnate.exists then
            //! runtextmacro UNIT_EVENT_STRUCT_MACRO()
        elseif thistype.animate.exists then
            //! runtextmacro UNIT_EVENT_STRUCT_MACRO()
        endif
    endmodule
endlibrary