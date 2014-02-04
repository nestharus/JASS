library Costs /* v1.0.0.1
*************************************************************************************
*
*   */uses/*
*       */ optional GetUnitCost /*
*       */ optional GetItemCost /*
*       */ Table /*                     hiveworkshop.com/forums/jass-functions-413/snippet-new-table-188084/
*       */ WorldBounds /*               hiveworkshop.com/forums/jass-functions-413/snippet-worldbounds-180494/
*       */ optional UnitIndexer /*      hiveworkshop.com/forums/jass-functions-413/unit-indexer-172090/
*
************************************************************************************/
    globals
        private player p=Player(14)       //player to get gold/lumber costs
        private unit u=null               //sells/upgrades
    endglobals
    //! runtextmacro optional UNIT_COST()
    //! runtextmacro optional ITEM_COST()
    private module Init
        private static method onInit takes nothing returns nothing
            //! runtextmacro optional UNIT_COST_2()
            set UnitIndexer.enabled=false
            set u = CreateUnit(p,UNITS_GET_COST,WorldBounds.maxX,WorldBounds.maxY,0)
            set UnitIndexer.enabled=true
            //move seller to top right corner of map
            //must be offset by 1 square 64x64 square in order to work
            call SetUnitX(u,WorldBounds.maxX-64)
            call SetUnitY(u,WorldBounds.maxY-64)
            //! runtextmacro optional UNIT_COST_3()
            //! runtextmacro optional ITEM_COST_2()
        endmethod
    endmodule
    private struct Inits extends array
        implement Init
    endstruct
endlibrary