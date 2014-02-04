library LifeSaver /* v1.0.1.1
*************************************************************************************
*
*   Applies very large life bonus to a unit, maintaining scale
*
*   Removes bonus on unit death/deindex
*
*************************************************************************************
*
*   */uses/*
*
        */ UnitIndexer              /*          hiveworkshop.com/forums/jass-functions-413/unit-indexer-172090/
*       */ RegisterPlayerUnitEvent  /*          hiveworkshop.com/forums/jass-resources-412/snippet-registerplayerunitevent-203338/
*
************************************************************************************
*
*   SETTINGS
*/
globals
    /*************************************************************************************
    *
    *   Configure to life bonus ability type id
    *
    *************************************************************************************/
    constant integer LIFE_SAVER_ABILITY_ID = 'A001'
endglobals
/*
*************************************************************************************
*
*   function ApplyMaxLife takes UnitIndex whichUnit returns nothing
*       -   adds 10 million health to unit and creates background value with unit's regular life
*   function RemoveMaxLife takes UnitIndex whichUnit returns nothing
*       -   removes bonus and sets unit's life to background value
*   function GetUnitLife takes UnitIndex whichUnit returns real
*       -   returns widget life with no bonus, or background value with bonus
*   function AddUnitLife takes UnitIndex whichUnit, real r returns nothing
*       -   adds to widget life
*   function AddUnitTargetLife takes UnitIndex whichUnit, real r returns nothing
*       -   adds to background value
*
*************************************************************************************/
    globals
        private real array currentLife
        
        private real life
        private real scale
    endglobals

    function ApplyMaxLife takes UnitIndex whichUnit returns nothing
        set currentLife[whichUnit] = GetWidgetLife(whichUnit.unit)
        
        set scale = currentLife[whichUnit]/GetUnitState(whichUnit.unit, UNIT_STATE_MAX_LIFE)
        if (scale < .1) then
            set scale = .1
        endif
    
        call UnitAddAbility(whichUnit.unit, LIFE_SAVER_ABILITY_ID)
        call UnitMakeAbilityPermanent(whichUnit.unit, true, LIFE_SAVER_ABILITY_ID)
        call SetWidgetLife(whichUnit.unit, GetUnitState(whichUnit.unit, UNIT_STATE_MAX_LIFE)*scale)
    endfunction
    function RemoveMaxLife takes UnitIndex whichUnit returns nothing
        call UnitRemoveAbility(whichUnit.unit, LIFE_SAVER_ABILITY_ID)
        call SetWidgetLife(whichUnit.unit, currentLife[whichUnit])
        set currentLife[whichUnit] = -1
    endfunction
    function GetUnitLife takes UnitIndex whichUnit returns real
        if (currentLife[whichUnit] == -1) then
            return GetWidgetLife(whichUnit.unit)
        endif
        return currentLife[whichUnit]
    endfunction
    function AddUnitLife takes UnitIndex whichUnit, real r returns nothing
        call SetWidgetLife(whichUnit.unit, GetWidgetLife(whichUnit.unit) + r)
    endfunction
    function AddUnitTargetLife takes UnitIndex whichUnit, real r returns nothing
        set currentLife[whichUnit] = currentLife[whichUnit] + r
    endfunction
    
    private function OnDeath takes nothing returns nothing
        call UnitRemoveAbility(GetTriggerUnit(), LIFE_SAVER_ABILITY_ID)
        set currentLife[GetUnitUserData(GetTriggerUnit())] = -1
    endfunction
    
    private module Init
        private static method onInit takes nothing returns nothing
            call init()
        endmethod
    endmodule
    
    private struct Index extends array    
        private static method init takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function OnDeath)
        endmethod
    
        implement Init
    
        private method index takes nothing returns nothing
            set currentLife[this] = -1
        endmethod
        
        implement UnitIndexStruct
    endstruct
endlibrary