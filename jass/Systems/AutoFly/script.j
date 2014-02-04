library AutoFly /* v1.0.0.1
                    -Credits to Magtheridon96 and Bribe for code update
                    -Credits to Azlier for original
                    -thehelper.net/forums/showthread.php/139729-AutoFly
*************************************************************************************
*
*   Makes SetUnitFlyHeight possible
*
*************************************************************************************
*
*   */uses/*
*   
*       */ UnitIndexer /*           hiveworkshop.com/forums/jass-functions-413/unit-indexer-172090/
*
************************************************************************************/
    private function i takes nothing returns boolean
        return UnitAddAbility(GetIndexedUnit(), 'Amrf') and UnitRemoveAbility(GetIndexedUnit(), 'Amrf')
    endfunction
    private module Init
        private static method onInit takes nothing returns nothing
            call RegisterUnitIndexEvent(Condition(function i), UnitIndexer.INDEX)
        endmethod
    endmodule
    private struct Inits extends array
        implement Init
    endstruct
endlibrary