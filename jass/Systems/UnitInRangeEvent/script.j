library UnitInRangeEvent /* v2.0.0.1
*************************************************************************************
*
*   Trigger condition UnitInRangeEvent
*
*************************************************************************************
*
*   */uses/*
*
*       */ Table /*                 hiveworkshop.com/forums/jass-functions-413/snippet-new-table-188084/
*       */ UnitIndexer /*           hiveworkshop.com/forums/jass-functions-413/unit-indexer-172090/
*
************************************************************************************
*
*   function RegisterUnitInRangeEvent takes code eventCode, unit whichUnit, real range returns integer
*   function UnregisterUnitInRangeEvent takes integer this returns nothing
*
*   function GetEventSourceUnitId takes nothing returns UnitIndex
*   function GetEventSourceUnit takes nothing returns unit
*
************************************************************************************/
    globals
        private integer instanceCount = 0
        private integer array first
        private integer array next              //recycler
        private integer array prev
        private trigger array trig
        private integer array source
        private integer array handleId
        
        private Table rangeEvent
    endglobals
    
    static if DEBUG_MODE then
        private struct Debug extends array
            static boolean array allocated
        endstruct
    endif
    
    function GetEventSourceUnitId takes nothing returns UnitIndex
        return source[rangeEvent[GetHandleId(GetTriggeringTrigger())]]
    endfunction
    function GetEventSourceUnit takes nothing returns unit
        return GetUnitById(GetEventSourceUnitId())
    endfunction
    function RegisterUnitInRangeEvent takes code eventCode, unit whichUnit, real range returns integer
        local integer sourceUnit=GetUnitUserData(whichUnit)
        local integer this
        local trigger eventTrigger
        local integer head
        local integer triggerId
        
        //if the unit isn't null
        debug if (GetUnitById(sourceUnit) == whichUnit and null != whichUnit) then
            //allocate
            if (0 == next[0]) then
                set this = instanceCount + 1
                set instanceCount = this
            else
                set this = next[0]
                set next[0]=next[this]
            endif
            debug set Debug.allocated[this] = true
            
            //add to list
            set head = first[sourceUnit]
            if (0 == head) then
                set first[sourceUnit] = this
                set next[this] = this
                set prev[this] = this
            else
                set prev[this] = prev[head]
                set next[this] = head
                set next[prev[head]] = this
                set prev[head] = this
            endif
            
            //register trigger
            set eventTrigger = CreateTrigger()
            call TriggerRegisterUnitInRange(eventTrigger, whichUnit, range, null)
            call TriggerAddCondition(eventTrigger, Condition(eventCode))
            
            //store fields
            set triggerId = GetHandleId(eventTrigger)
            
            set handleId[this] = triggerId
            set trig[this] = eventTrigger
            set source[this] = sourceUnit
            
            set rangeEvent[triggerId] = this
            
            //clean
            set eventTrigger = null
            
            return this
        debug else
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"RANGE EVENT ERROR: ATTEMPT TO REGISTER NULL UNIT")
        debug endif
        
        return 0
    endfunction
    function UnregisterUnitInRangeEvent takes integer this returns nothing
        local integer sourceUnit
        
        //if event was allocated
        debug if (Debug.allocated[this]) then
            set sourceUnit = source[this]
        
            //remove from list
            set next[prev[this]] = next[this]
            set prev[next[this]] = prev[this]
            
            if (first[sourceUnit] == this) then
                set first[sourceUnit] = next[this]
                
                if (first[sourceUnit] == this) then
                    set first[sourceUnit] = 0
                endif
            endif
            
            //deallocate
            set next[this] = next[0]
            set next[0] = this
            debug set Debug.allocated[this] = false
            
            //clean
            call DestroyTrigger(trig[this])
            set trig[this] = null
            
            call rangeEvent.remove(handleId[this])
        debug else
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"RANGE EVENT ERROR: ATTEMPT TO UNREGISTER NULL RANGE EVENT")
        debug endif
    endfunction
    private module Init
        private static method onDeindex takes nothing returns boolean
            local integer sourceUnit = GetIndexedUnitId()
            local integer node = first[sourceUnit]
            
            //if there are any events on the unit
            if (0 != node) then
                //clean all events
                set next[prev[node]] = 0
                loop
                    call DestroyTrigger(trig[node])
                    set trig[node] = null
                    
                    call rangeEvent.remove(handleId[node])
                    
                    debug set Debug.allocated[node] = false
                    
                    set node = next[node]
                    exitwhen 0 == node
                endloop
                
                //deallocate list
                set node = first[sourceUnit]
                set next[prev[node]] = next[0]
                set next[0] = node
            endif
            
            return false
        endmethod
        private static method onInit takes nothing returns nothing
            call RegisterUnitIndexEvent(Condition(function thistype.onDeindex),UnitIndexer.DEINDEX)
            set rangeEvent=Table.create()
        endmethod
    endmodule
    private struct Inits extends array
        implement Init
    endstruct
endlibrary