library SlopeSpeed uses /*
    */CliffBound /*[url]http://www.hiveworkshop.com/forums/submissions-414/snippet-cliffbound-181307/[/url]
    */
    
/*
    struct SlopeUnit
        
        //determines whether unit is affected by slopes
        boolean runs
        
        //determines whether the unit is currently running or not
        readonly boolean isRunning
*/
    
    globals
        private constant real GRAVITY = 9.81
        private constant real INTERVAL = .0325
    endglobals
    
    private function SlopeFilter takes unit u returns boolean
        return true
    endfunction
    
    globals
        private real gi
    endglobals
    
    struct SlopeUnit extends array
        private static integer array unitListNext
        private static integer array unitListPrevious
        private static boolean array inList
        
        private boolean runsx
        
        public method operator isRunning takes nothing returns boolean
            return inList[this]
        endmethod
        
        public method operator runs takes nothing returns boolean
            return runsx
        endmethod
        
        public method operator runs= takes boolean b returns nothing
            if (b != runsx) then
                set runsx = not b
                
                if (not b and IsUnitMoving(GetUnitById(this)) and SlopeFilter(GetUnitById(this))) then
                    set unitListNext[unitListPrevious[0]] = this
                    set unitListNext[this] = 0
                    set unitListPrevious[this] = unitListPrevious[0]
                    set unitListPrevious[0] = this
                    set inList[this] = true
                elseif (inList[this]) then
                    set unitListNext[unitListPrevious[this]] = unitListNext[this]
                    set unitListPrevious[unitListNext[this]] = unitListPrevious[this]
                    set inList[this] = false
                endif
            endif
        endmethod
        
        public method operator next takes nothing returns thistype
            return unitListNext[this]
        endmethod
        
        private static method RemoveFromList takes nothing returns boolean
            local integer id = GetUnitUserData(GetMovingUnit())
            if (inList[id]) then
                set unitListNext[unitListPrevious[id]] = unitListNext[id]
                set unitListPrevious[unitListNext[id]] = unitListPrevious[id]
                set inList[id] = false
            endif
            return false
        endmethod
        
        private static method AddToList takes nothing returns boolean
            local thistype id = GetUnitUserData(GetMovingUnit())
            
            if (not id.runsx and not inList[id] and SlopeFilter(GetUnitById(id))) then
                set unitListNext[unitListPrevious[0]] = id
                set unitListNext[id] = 0
                set unitListPrevious[id] = unitListPrevious[0]
                set unitListPrevious[0] = id
                set inList[id] = true
            endif
            
            return false
        endmethod
        
        private static method RemoveFromListDeindex takes nothing returns boolean
            if (inList[GetIndexedUnitId()]) then
                set unitListNext[unitListPrevious[GetIndexedUnitId()]] = unitListNext[GetIndexedUnitId()]
                set unitListPrevious[unitListNext[GetIndexedUnitId()]] = unitListPrevious[GetIndexedUnitId()]
                set inList[GetIndexedUnitId()] = false
            endif
            set thistype(GetIndexedUnitId()).runsx = false
            return false
        endmethod
        
        private static method ManipulateSpeed takes nothing returns nothing
            local CliffUnit ui = unitListNext[0]
            local unit u
            local real r
            loop
                exitwhen ui == 0
                set u = GetUnitById(ui)
                if (GetUnitFlyHeight(u) == 0) then
                    set r = GetUnitFacing(u)/180*bj_PI
                    call SetUnitX(u, ui.prevX-ui.cliffElevation*gi*Cos(r))
                    call SetUnitY(u, ui.prevY-ui.cliffElevation*gi*Sin(r))
                    call ui.update()
                endif
                set ui = unitListNext[ui]
            endloop
        endmethod
        
        private static method onInit takes nothing returns nothing
            set gi = INTERVAL*GRAVITY
            call OnUnitDeindex(Condition(function thistype.RemoveFromListDeindex))
            call OnUnitMove(Condition(function thistype.AddToList))
            call OnUnitStop(Condition(function thistype.RemoveFromList))
            call TimerStart(CreateTimer(), INTERVAL, true, function thistype.ManipulateSpeed)
        endmethod
    endstruct
endlibrary