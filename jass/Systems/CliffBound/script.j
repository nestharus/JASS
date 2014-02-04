library CliffBound uses /*
    */IsUnitMoving /*[url]http://www.hiveworkshop.com/forums/jass-functions-413/isunitmoving-178341/[/url]
    */UnitIndexer //http://www.hiveworkshop.com/forums/jass-functions-413/unit-indexer-172090/
    globals
        //stop unit when it hits cliff?
        private constant boolean STOP_ON_CLIFF = true
        
        //how often cliff checking runs
        private constant real CLIFF_CHECK_INTERVAL = .0325
        
        //how much z elevation needed to constitute a cliff?
        //32*.325
        private constant real CLIFF_ELEVATION = 10.4
    endglobals
    
    //whether unit u should run through this or not
    function CliffFilter takes unit u returns boolean
        return true
    endfunction
    
/*
struct CliffUnit
    //valid x,y,z coordinates of unit
    readonly real prevX
    readonly real prevY
    readonly real prevZ
    
    //cliff x,y,z coordinates of hit cliff
    readonly real cliffX
    readonly real cliffY
    readonly real cliffZ
    
    //elevation of hit cliff
    readonly real cliffElevation
    
    //update coordinates if moving unit around
    method update takes nothing returns nothing

//event response for unit hitting cliff
function GetHitCliffUnit takes nothing returns unit
function GetHitCliffUnitId takes nothing returns integer

//run b whenever a unit hits a cliff
function OnHitCliff takes boolexpr b returns nothing
*/

    globals
        private location loc = Location(0, 0)
        
        private real array prevZc
        private real array prevXc
        private real array prevYc
        
        private real array cliffXc
        private real array cliffYc
        private real array cliffZc
        
        private boolean array inList
        
        private real array cliffElevationc
        
        private unit hitCliffUnit = null
        private integer hitCliffUnitId = 0
        
        private integer array unitListNext
        private integer array unitListPrevious
        
        private trigger onHitCliffEvent = CreateTrigger()
    endglobals
    
    private function RemoveFromList takes nothing returns boolean
        local integer id = GetUnitUserData(GetMovingUnit())
        if (inList[id]) then
            set unitListNext[unitListPrevious[id]] = unitListNext[id]
            set unitListPrevious[unitListNext[id]] = unitListPrevious[id]
            set inList[id] = false
        endif
        return false
    endfunction
    
    private function AddToList takes nothing returns boolean
        local integer id = GetUnitUserData(GetMovingUnit())
        if (not inList[id] and CliffFilter(GetMovingUnit())) then
            set unitListNext[unitListPrevious[0]] = id
            set unitListNext[id] = 0
            set unitListPrevious[id] = unitListPrevious[0]
            set unitListPrevious[0] = id
            set prevXc[id] = GetUnitX(GetMovingUnit())
            set prevYc[id] = GetUnitY(GetMovingUnit())
            call MoveLocation(loc, prevXc[id], prevYc[id])
            set prevZc[id] = GetLocationZ(loc)
            set inList[id] = true
        endif
        return false
    endfunction
    
    function GetHitCliffUnit takes nothing returns unit
        return hitCliffUnit
    endfunction
    
    function GetHitCliffUnitId takes nothing returns integer
        return hitCliffUnitId
    endfunction
    
    private function RemoveFromListDeindex takes nothing returns boolean
        if (inList[GetIndexedUnitId()]) then
            set unitListNext[unitListPrevious[GetIndexedUnitId()]] = unitListNext[GetIndexedUnitId()]
            set unitListPrevious[unitListNext[GetIndexedUnitId()]] = unitListPrevious[GetIndexedUnitId()]
            set inList[GetIndexedUnitId()] = false
        endif
        return false
    endfunction
    
    private function OnHitCliffC takes nothing returns nothing
        static if STOP_ON_CLIFF then
            local real r
        endif
        set hitCliffUnitId = unitListNext[0]
        loop
            exitwhen hitCliffUnitId == 0
            set hitCliffUnit = GetUnitById(hitCliffUnitId)
            set cliffXc[hitCliffUnitId] = GetUnitX(hitCliffUnit)
            set cliffYc[hitCliffUnitId] = GetUnitY(hitCliffUnit)
            call MoveLocation(loc, cliffXc[hitCliffUnitId], cliffYc[hitCliffUnitId])
            set cliffZc[hitCliffUnitId] = GetLocationZ(loc)
            set cliffElevationc[hitCliffUnitId] = cliffZc[hitCliffUnitId]-prevZc[hitCliffUnitId]
            if (GetUnitFlyHeight(hitCliffUnit) == 0 and (cliffElevationc[hitCliffUnitId] >= CLIFF_ELEVATION or cliffElevationc[hitCliffUnitId] <= -CLIFF_ELEVATION)) then
                call TriggerEvaluate(onHitCliffEvent)
                static if STOP_ON_CLIFF then
                    set r = GetUnitFacing(hitCliffUnit)/180*bj_PI
                    call IssueImmediateOrder(hitCliffUnit, "stop")
                    call SetUnitX(hitCliffUnit, prevXc[hitCliffUnitId]-CLIFF_ELEVATION*Cos(r))
                    call SetUnitY(hitCliffUnit, prevYc[hitCliffUnitId]-CLIFF_ELEVATION*Sin(r))
                else
                    set prevXc[hitCliffUnitId] = cliffXc[hitCliffUnitId]
                    set prevYc[hitCliffUnitId] = cliffYc[hitCliffUnitId]
                    set prevZc[hitCliffUnitId] = cliffZc[hitCliffUnitId]
                endif
            else
                set prevXc[hitCliffUnitId] = cliffXc[hitCliffUnitId]
                set prevYc[hitCliffUnitId] = cliffYc[hitCliffUnitId]
                set prevZc[hitCliffUnitId] = cliffZc[hitCliffUnitId]
            endif
            set hitCliffUnitId = unitListNext[hitCliffUnitId]
        endloop
    endfunction
    
    function OnHitCliff takes boolexpr b returns nothing
        call TriggerAddCondition(onHitCliffEvent, b)
    endfunction
    
    struct CliffUnit extends array
        public method operator next takes nothing returns thistype
            return unitListNext[this]
        endmethod
        
        public method operator prevX takes nothing returns real
            return prevXc[this]
        endmethod
        
        public method operator prevY takes nothing returns real
            return prevYc[this]
        endmethod
        
        public method operator prevZ takes nothing returns real
            return prevZc[this]
        endmethod
        
        public method operator cliffX takes nothing returns real
            return cliffXc[this]
        endmethod
        
        public method operator cliffY takes nothing returns real
            return cliffYc[this]
        endmethod
        
        public method operator cliffZ takes nothing returns real
            return cliffZc[this]
        endmethod
        
        public method operator cliffElevation takes nothing returns real
            return cliffElevationc[this]
        endmethod
        
        public method update takes nothing returns nothing
            local unit u = GetUnitById(this)
            local real e
            set prevXc[this] = GetUnitX(u)
            set prevYc[this] = GetUnitY(u)
            call MoveLocation(loc, prevXc[this], prevYc[this])
            set e = GetLocationZ(loc)
            set cliffElevationc[this] = e-prevZc[this]
            set prevZc[this] = e
            set u = null
        endmethod
        
        private static method onInit takes nothing returns nothing
            call TimerStart(CreateTimer(), CLIFF_CHECK_INTERVAL, true, function OnHitCliffC)
            call OnUnitDeindex(Condition(function RemoveFromListDeindex))
            call OnUnitMove(Condition(function AddToList))
            call OnUnitStop(Condition(function RemoveFromList))
        endmethod
    endstruct
endlibrary