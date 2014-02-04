library Stun /* v1.0.0.4
*************************************************************************************
*
*   Supports stunning units.
*       -remaining stun time on a unit retrieval
*       -add stun time to unit
*       -set stun time for unit
*       -remove stun from unit
*
*************************************************************************************
*
*   */uses/*
*       */ UnitIndexer /*       hiveworkshop.com/forums/jass-functions-413/snippet-worldbounds-180494/
*       */ DummyCaster /*       hiveworkshop.com/forums/submissions-414/snippet-dummy-caster-197087/
*       */ Table /*             hiveworkshop.com/forums/jass-functions-413/snippet-new-table-188084/
*
*************************************************************************************
*
*    Functions
*
*       function UnitGetStun takes unit u returns real
*       function UnitAddStun takes unit u, real time returns nothing
*       function UnitSetStun takes unit u, real time returns nothing
*       function UnitRemoveStun takes unit u, real time returns nothing
*
************************************************************************************/
    globals
        private Table h=0
        private timer array t
        private boolean array r
    endglobals
    //stun expire
    private function B takes nothing returns nothing
        local integer i=h[GetHandleId(GetExpiredTimer())]
        set r[i]=false
        call UnitRemoveAbility(GetUnitById(i),BUFFS_STUN)
    endfunction
    //unit death
    private function E takes nothing returns boolean
        local integer i=GetUnitUserData(GetTriggerUnit())
        if (r[i]) then
            set r[i]=false
            call PauseTimer(t[i])
        endif
        return false
    endfunction
    //unit index
    private function M takes nothing returns boolean
        local integer i=GetIndexedUnitId()
        set t[i]=CreateTimer()
        set h[GetHandleId(t[i])]=i
        return false
    endfunction
    //unit deindex
    private function D takes nothing returns boolean
        local integer i=GetIndexedUnitId()
        call h.remove(GetHandleId(t[i]))
        call DestroyTimer(t[i])
        set t[i]=null
        set r[i]=false
        return false
    endfunction
    //init
    private module I
        private static method onInit takes nothing returns nothing
            local trigger q=CreateTrigger()
            local integer i=15
            call DummyCaster[ABILITIES_STUN].register()
            call RegisterUnitIndexEvent(Condition(function M),UnitIndexer.INDEX)
            call RegisterUnitIndexEvent(Condition(function D),UnitIndexer.DEINDEX)
            loop
                call TriggerRegisterPlayerUnitEvent(q,Player(i),EVENT_PLAYER_UNIT_DEATH,null)
                exitwhen 0==i
                set i=i-1
            endloop
            call TriggerAddCondition(q,Condition(function E))
            set h=Table.create()
            set q=null
        endmethod
    endmodule
    private struct N extends array
        implement I
    endstruct
    function UnitGetStun takes unit u returns real
        local integer i = GetUnitUserData(u)
        debug if (0==i) then
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"STUN ERROR: INVALID UNIT")
            debug return 0.
        debug endif
        if (r[i]) then
            return TimerGetRemaining(t[i])
        endif
        return 0.
    endfunction
    function UnitAddStun takes unit u, real time returns nothing
        local integer i = GetUnitUserData(u)
        debug if (0==i) then
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"STUN ERROR: INVALID UNIT")
            debug return
        debug endif
        if (r[i]) then
            set time=time+TimerGetRemaining(t[i])
        else
            set r[i]=true
        endif
        if (0<time) then
            call TimerStart(t[i],time,false,function B)
            call DummyCaster[852231].castTarget(u)
        else
            call PauseTimer(t[i])
            set r[i] = false
            call UnitRemoveAbility(GetUnitById(i),BUFFS_STUN)
        endif
    endfunction
    function UnitSetStun takes unit u, real time returns nothing
        local integer i = GetUnitUserData(u)
        debug if (time<0) then
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"STUN ERROR: INVALID TIME")
            debug return
        debug endif
        debug if (0==i) then
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"STUN ERROR: INVALID UNIT")
            debug return
        debug endif
        if (0<time) then
            set r[i]=true
            call TimerStart(t[i],time,false,function B)
            call DummyCaster[852231].castTarget(u)
        else
            set r[i]=false
            call PauseTimer(t[i])
            call UnitRemoveAbility(GetUnitById(i),BUFFS_STUN)
        endif
    endfunction
    function UnitRemoveStun takes unit u, real time returns nothing
        local integer i = GetUnitUserData(u)
        debug if (0==i) then
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"STUN ERROR: INVALID UNIT")
            debug return
        debug endif
        call UnitRemoveAbility(GetUnitById(i),BUFFS_STUN)
        set r[i]=false
        call PauseTimer(t[i])
    endfunction
endlibrary