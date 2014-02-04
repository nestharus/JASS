library GetItemCost /* v1.0.0.1
************************************************************************************
*
*    Functions
*
*       function GetItemTypeIdGoldCost takes integer itemTypeId returns integer
*       function GetItemTypeIdWoodCost takes integer itemTypeId returns integer
*       function GetItemTypeIdCharges takes integer itemTypeId returns integer
*
*       function GetItemGoldCost takes item whichItem returns integer
*           -   Gets total item gold cost including item charges
*       function GetItemWoodCost takes item whichItem returns integer
*           -   Gets total item wood cost including item charges
*
************************************************************************************/
//! textmacro ITEM_COST
    globals
        private Table gi=0                  //item type id gold cost table
        private Table li=0                  //item type id lumber cost table
        private Table ci=0                  //item type id charge table
        private boolexpr b=null             //enum item function
        private real d=0                    //distance
        private item fi=null                //found item
        private integer it=0                //item type filter
        private rect r                      //world rect
        private real pe                     //percent divider
    endglobals
    //item cost (enum)
    //Select Unit method is not used in this case because it only seems to work
    //with players 0-11. Even with the use of 0 through 11, it can be buggy.
    private function E takes nothing returns boolean
        local real x                        //x coord
        local real y                        //y coord
        local item s=GetFilterItem()        //filter item
        //find the closest item of the matching type
        if (it==GetItemTypeId(s)) then
            //retrieve x,y as percents so that the values are smaller
            //magnitudes of coordinates can easily flow well above 2^31-1 limit
            set x=(GetWidgetX(s)-WorldBounds.minX)/pe        //percent
            set y=(GetWidgetY(s)-WorldBounds.minY)/pe        //percent
            set x=SquareRoot(x*x+y*y)         //magnitude
            //The item was sold at max coordinates, meaning 141.421356% (distance from bot left to top right)
            //the entire world must be enumerated over due to pathing (item might not be placed at unit)
            //when the pathing reaches a certain point, the item is placed at the unit
            //this will find the item with the greatest magnitude, thus approaching 141.421356%
            if (x>d) then
                set d=x
                set fi=s
            endif
        endif
        set s=null
        return false
    endfunction
    private function LogItem takes integer id returns nothing
        //get previous gold/lumber
        local integer k = GetPlayerState(p,PLAYER_STATE_RESOURCE_GOLD)
        local integer w = GetPlayerState(p,PLAYER_STATE_RESOURCE_LUMBER)
        local item ts
        call SetPlayerState(p,PLAYER_STATE_RESOURCE_GOLD,1000000)
        call SetPlayerState(p,PLAYER_STATE_RESOURCE_LUMBER,1000000)
        //build item
        call AddItemToStock(u,id,1,1)
        call IssueNeutralImmediateOrderById(p,u,id)
        call RemoveItemFromStock(u,id)
        //find and remove item
        set it=id         //item type id to find
        set d=-1          //closest range
        call EnumItemsInRect(r,b,null)
        set ci[id]=GetItemCharges(fi)
        call RemoveItem(fi)
        set fi=null
        //retrieve gold and lumber cost
        set gi[id]=1000000-GetPlayerState(p,PLAYER_STATE_RESOURCE_GOLD)
        set li[id]=1000000-GetPlayerState(p,PLAYER_STATE_RESOURCE_LUMBER)
        //set player gold back to what it was
        call SetPlayerState(p,PLAYER_STATE_RESOURCE_GOLD,k)
        call SetPlayerState(p,PLAYER_STATE_RESOURCE_LUMBER,w)
    endfunction
    function GetItemTypeIdGoldCost takes integer id returns integer
        if (not gi.has(id)) then
            call LogItem(id)
        endif
        return gi[id]
    endfunction
    function GetItemTypeIdWoodCost takes integer id returns integer
        if (not gi.has(id)) then
            call LogItem(id)
        endif
        return li[id]
    endfunction
    function GetItemTypeIdCharges takes integer id returns integer
        if (not gi.has(id)) then
            call LogItem(id)
        endif
        return ci[id]
    endfunction
    function GetItemGoldCost takes item i returns integer
        local integer s = GetItemTypeId(i)
        local real s2 = GetItemTypeIdCharges(s)
        if (s2 > 0) then
            return R2I(gi[s]*(GetItemCharges(i)/s2))
        endif
        return gi[s]
    endfunction
    function GetItemWoodCost takes item i returns integer
        local integer s = GetItemTypeId(i)
        local real s2 = GetItemTypeIdCharges(s)
        if (s2 > 0) then
            return R2I(li[s]*(GetItemCharges(i)/s2))
        endif
        return li[s]
    endfunction
//! endtextmacro
//! textmacro ITEM_COST_2
    //item pathing can only go out 1024
    //after 1024, it is just placed at the unit it was sold at
    set r=Rect(WorldBounds.maxX-1088,WorldBounds.maxY-1088,WorldBounds.maxX,WorldBounds.maxY)
    set b=Condition(function E)           //item enum function
    set gi=Table.create()                 //gold item table
    set li=Table.create()                 //lumber item table
    set ci=Table.create()                 //charge item table
    set pe=(WorldBounds.maxX-WorldBounds.minX)*100        //percent divider
//! endtextmacro
endlibrary