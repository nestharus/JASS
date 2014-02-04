library GetUnitCost /* v1.0.1.0
*************************************************************************************
*
*   */uses/*
*       */ UnitIndexer /*               hiveworkshop.com/forums/jass-functions-413/system-unit-indexer-172090/
*       */ RegisterPlayerUnitEvent /*   hiveworkshop.com/forums/jass-resources-412/snippet-registerplayerunitevent-203338/
*
************************************************************************************
*
*    Functions
*
*       function GetUnitTypeIdGoldCost takes integer unitTypeId returns integer
*       function GetUnitTypeIdWoodCost takes integer unitTypeId returns integer
*
*                   NATIVES WORK WITH NON-HERO UNITS ONLY
*/
        native GetUnitGoldCost takes integer unitid returns integer
        native GetUnitWoodCost takes integer unitid returns integer
/*
*       function GetUnitTotalGoldCost takes unit whichUnit returns integer
*           -   Gets total unit gold cost including prior upgrades
*       function GetUnitTotalWoodCost takes unit whichUnit returns integer
*           -   Gets total unit wood cost including prior upgrades
*
************************************************************************************/
//! textmacro UNIT_COST
    globals
        private Table g = 0                 //unit type id gold cost table
        private Table l = 0                 //unit type id lumber cost table
        private integer array gu            //unit gold cost array (indexed)
        private integer array lu            //unit lumber cost array (indexed)
        private integer array ug            //upgrade gold
        private integer array ul            //upgrade lumber
    endglobals
    //unit cost (sell)
    private function O takes nothing returns boolean
        call RemoveUnit(GetSoldUnit())
        return false
    endfunction
    private function LogUnit takes integer id returns nothing
        //store previous gold, lumber, and food
        local integer k=GetPlayerState(p,PLAYER_STATE_RESOURCE_GOLD)
        local integer w=GetPlayerState(p,PLAYER_STATE_RESOURCE_LUMBER)
        local integer h=GetPlayerState(p,PLAYER_STATE_RESOURCE_FOOD_USED)
        local integer m=GetPlayerState(p,PLAYER_STATE_RESOURCE_FOOD_CAP)
        call SetPlayerState(p,PLAYER_STATE_RESOURCE_GOLD,1000000)
        call SetPlayerState(p,PLAYER_STATE_RESOURCE_LUMBER,1000000)
        call SetPlayerState(p,PLAYER_STATE_RESOURCE_FOOD_USED,0)
        call SetPlayerState(p,PLAYER_STATE_RESOURCE_FOOD_CAP,100000)
        //build unit
        set UnitIndexer.enabled=false
        call AddUnitToStock(u,id,1,1)
        call IssueNeutralImmediateOrderById(p,u,id)
        call RemoveUnitFromStock(u,id)
        set UnitIndexer.enabled = true
        //retrieve gold and lumber cost
        set g[id]=1000000-GetPlayerState(p,PLAYER_STATE_RESOURCE_GOLD)
        set l[id]=1000000-GetPlayerState(p,PLAYER_STATE_RESOURCE_LUMBER)
        //set player gold back to what it was
        call SetPlayerState(p,PLAYER_STATE_RESOURCE_GOLD,k)
        call SetPlayerState(p,PLAYER_STATE_RESOURCE_LUMBER,w)
        call SetPlayerState(p,PLAYER_STATE_RESOURCE_FOOD_USED,h)
        call SetPlayerState(p,PLAYER_STATE_RESOURCE_FOOD_CAP,m)
    endfunction
    function GetUnitTypeIdGoldCost takes integer id returns integer
        debug if (null!=UnitId2String(id)) then
            if (not g.has(id)) then
                if (IsHeroUnitId(id)) then
                    call LogUnit(id)
                else
                    set g[id]=GetUnitGoldCost(id)
                    set l[id]=GetUnitWoodCost(id)
                endif
            endif
            return g[id]
        debug else
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"COSTS ERROR: INVALID UNIT TYPE ID")
        debug endif
        debug return 0
    endfunction
    function GetUnitTypeIdWoodCost takes integer id returns integer
        debug if (null!=UnitId2String(id)) then
            if (not g.has(id)) then
                if (IsHeroUnitId(id)) then
                    call LogUnit(id)
                else
                    set g[id]=GetUnitGoldCost(id)
                    set l[id]=GetUnitWoodCost(id)
                endif
            endif
            return l[id]
        debug else
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"COSTS ERROR: INVALID UNIT TYPE ID")
        debug endif
        debug return 0
    endfunction
    function GetUnitTotalGoldCost takes unit t returns integer
        debug if (null!=t) then
            if (0==GetUnitUserData(t)) then
                return GetUnitTypeIdGoldCost(GetUnitTypeId(t))
            endif
            return gu[GetUnitUserData(t)]
        debug else
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"COSTS ERROR: INVALID UNIT")
        debug endif
        debug return 0
    endfunction
    function GetUnitTotalWoodCost takes unit t returns integer
        debug if (null!=t) then
            if (0==GetUnitUserData(t)) then
                return GetUnitTypeIdWoodCost(GetUnitTypeId(t))
            endif
            return lu[GetUnitUserData(t)]
        debug else
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"COSTS ERROR: INVALID UNIT")
        debug endif
        debug return 0
    endfunction
    //on unit index
    private function I takes nothing returns boolean
        local integer i=GetUnitTypeId(GetIndexedUnit())
        local integer k=GetIndexedUnitId()
        //store gold/lumber cost for unit
        set gu[k]=GetUnitTypeIdGoldCost(i)
        set lu[k]=l[i]
        return false
    endfunction
    //on unit deindex
    private function D takes nothing returns boolean
        local integer k=GetIndexedUnitId()
        //reset gold/lumber cost for unit
        set gu[k]=0
        set lu[k]=0
        return false
    endfunction
    //on unit upgrade start
    private function US takes nothing returns boolean
        local integer k=GetUnitUserData(GetTriggerUnit())
        local integer i=GetUnitTypeId(GetTriggerUnit())
        //if the unit is indexed, store upgrade gold/lumber cost
        if (0!=k) then
            set ug[k]=GetUnitTypeIdGoldCost(i)
            set ul[k]=l[i]
            set gu[k]=ug[k]+gu[k]
            set lu[k]=ul[k]+lu[k]
        endif
        return false
    endfunction
    //on unit upgrade cancel
    private function UC takes nothing returns boolean
        local integer k=GetUnitUserData(GetTriggerUnit())
        //if unit is indexed, add upgrade cost to cost
        if (0!=k) then
            set gu[k]=gu[k]-ug[k]
            set lu[k]=lu[k]-ul[k]
        endif
        return false
    endfunction
//! endtextmacro
//! textmacro UNIT_COST_2
    local trigger t=CreateTrigger()           //sell unit
//! endtextmacro
//! textmacro UNIT_COST_3
    set g=Table.create()                  //gold table
    set l=Table.create()                  //lumber table
    //register unit indexing for setting/resetting gold/lumber costs for units
    call RegisterUnitIndexEvent(Condition(function I),UnitIndexer.INDEX)
    call RegisterUnitIndexEvent(Condition(function D),UnitIndexer.DEINDEX)
    //this is done for removing units that are sold for getting their costs
    call TriggerRegisterUnitEvent(t,u,EVENT_UNIT_SELL)
    call TriggerAddCondition(t,Condition(function O))
    
    //this is done for updating unit gold/lumber costs on upgrade
    call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_UPGRADE_START, function US)
    call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_UPGRADE_CANCEL, function UC)
//! endtextmacro
endlibrary