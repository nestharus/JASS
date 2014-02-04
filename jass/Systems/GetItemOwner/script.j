library GetItemOwner /* v1.1.0.1
*************************************************************************************
*
*   Retrieves the unit carrying an item.
*
*************************************************************************************
*
*   */uses/*
*   
*       */ UnitIndexer /*               hiveworkshop.com/forums/jass-functions-413/unit-indexer-172090/
*       */ Table /*                     hiveworkshop.com/forums/jass-functions-413/snippet-new-table-188084/
*       */ RegisterPlayerUnitEvent /*   hiveworkshop.com/forums/jass-functions-413/snippet-registerplayerunitevent-203338/
*
************************************************************************************
*
*   Functions
*
*       function GetItemOwnerId takes item i returns integer
*           -   returns indexed id of owning unit
*       function GetItemOwner takes item i returns unit
*           -   returns owning unit of item
*
************************************************************************************/
    globals
        private Table ot                    //owner table
    endglobals
    private module init
        //when a unit picks up an item, update the owner
        private static method op takes nothing returns boolean
            set ot[GetHandleId(GetManipulatedItem())]=GetUnitUserData(GetTriggerUnit())
            return false
        endmethod
        private static method onInit takes nothing returns nothing
            set ot=Table.create()
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_PICKUP_ITEM, function thistype.op)
        endmethod
    endmodule
    function GetItemOwnerId takes item i returns integer
        //if the item is owned, the owner is in the hashtable
        if (IsItemOwned(i)) then
            return ot[GetHandleId(i)]
        endif
        return 0
    endfunction
    function GetItemOwner takes item i returns unit
        return GetUnitById(GetItemOwnerId(i))
    endfunction
    private struct ItemLoc extends array
        implement init
    endstruct
endlibrary