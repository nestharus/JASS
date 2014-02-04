library DayNightEvent /* v1.0.1.1

*           Method by jesus4lyf, originally by azlier, modified by nestharus.
*           Original thread: hiveworkshop.com/forums/jass-functions-413/snippet-daynightevent-177197/
*************************************************************************************
*
*   Bugless detection of day and night.
*
*************************************************************************************
*   */uses/*
*   
*       */ Event /*                 hiveworkshop.com/forums/jass-functions-413/snippet-event-186555/
*       */ optional UnitIndexer /*  hiveworkshop.com/forums/jass-functions-413/unit-indexer-172090/
*
************************************************************************************
*
*   constant function GetDayEvent takes nothing returns Event
*   constant function GetNightEvent takes nothing returns Event
*   function IsDay takes nothing returns boolean
*   function IsNight takes nothing returns boolean
*
************************************************************************************/
    globals
        private Event dv = 0
        private Event nv = 0
        private boolean d = false
        private unit du = null
        private unit nu = null
    endglobals

    constant function GetDayEvent takes nothing returns Event
        return dv
    endfunction
    constant function GetNightEvent takes nothing returns Event
        return nv
    endfunction
    function IsDay takes nothing returns boolean
        return d
    endfunction
    function IsNight takes nothing returns boolean
        return not d
    endfunction

    private function Flg takes nothing returns boolean
        set d = GetTriggerUnit() == du
        if (d) then
            call SetWidgetLife(nu, 1)
            call dv.fire()
        else
            call SetWidgetLife(du, 1)
            call nv.fire()
        endif
        
        return false
    endfunction
    
    private module Init
        private static method onInit takes nothing returns nothing
            local trigger t = CreateTrigger()
            local unit u
            static if LIBRARY_UnitIndexer then
                set UnitIndexer.enabled = false
            endif
            set u = CreateUnit(Player(15), UNITS_DAY_DETECTOR, 0, 0, 270)
            call PauseUnit(u,true)
            set du = u
            call SetUnitX(u, 32256)
            call SetUnitY(u, 32256)
            call SetWidgetLife(u, 1)
            call TriggerRegisterUnitStateEvent(t, u, UNIT_STATE_LIFE, GREATER_THAN_OR_EQUAL, 2)
            set u = CreateUnit(Player(15), UNITS_NIGHT_DETECTOR, 0, 0, 270)
            call PauseUnit(u,true)
            set nu = u
            call SetUnitX(u, 32256)
            call SetUnitY(u, 32256)
            call SetWidgetLife(u, 1)
            call TriggerRegisterUnitStateEvent(t, u, UNIT_STATE_LIFE, GREATER_THAN_OR_EQUAL, 2)
            call TriggerAddCondition(t, Condition(function Flg))
            static if LIBRARY_UnitIndexer then
                set UnitIndexer.enabled = true
            endif
            
            set dv = Event.create()
            set nv = Event.create()
            
            set u = null
            set t = null
        endmethod
    endmodule

    private struct Inits extends array
        implement Init
    endstruct
endlibrary