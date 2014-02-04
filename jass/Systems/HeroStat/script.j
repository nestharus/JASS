library HeroStat /* v1.0.0.11
*************************************************************************************
*
*   A system that manages hero stat growth. Allows maps to be more easily balanced
*   by using a point system where each type of stat has a certain cost. For example,
*   the normal ratio of intelligence to strength to agility is .33:66:1. Rather than
*   trying to calculate all of this out and mess with it in the object editor, the ratios
*   themselves can be used with this system. This ensures easier hero balancing.
*
*   Unit types can each have their own strength, agility, and intelligence growth
*   Unit types can override base points and level growth (in case a unit type has weaker
*   abilities or is meant to be stronger)
*
*   Units can override unit type strength, agility, and intelligence growth
*   Units can override unit type/base points and level growth
*
*************************************************************************************
*   */uses/*
*   
*       */ Table /*         hiveworkshop.com/forums/jass-functions-413/snippet-new-table-188084/
*       */ UnitList /*      hiveworkshop.com/forums/jass-functions-413/snippet-unit-list-191657/
*
************************************************************************************
*   SETTINGS
*/
globals
    private constant real STR_COST = 1.20   //how many points per strength
    private constant real INT_COST = 1.00   //how many points per intelligence
    private constant real AGI_COST = 0.70   //how many points per agility
    
    private constant integer PTS = 30       //points to spend at level 1
    
    private constant real LVL_GROWTH = .5   //how many points based on PTS per level
                                            //.5 with 30 PTS would be 15 per level
endglobals
/*
************************************************************************************
*   function GetHiddenHeroStrBonus takes unit u returns integer
*       -   Retrieves bonuses caused by SetHeroStr
*   function GetHiddenHeroAgiBonus takes unit u returns integer
*       -   Retrieves bonuses caused by SetHeroAgi
*   function GetHiddenHeroIntBonus takes unit u returns integer
*       -   Retrieves bonuses caused by SetHeroInt
*
*   struct HeroTypeStat extends array
*       static method operator [] takes integer unitTypeId returns HeroTypeStat
*           -   Retrieves HeroTypeStat struct given a unit type id (IndexUnitTypeId)
*
*       real strength       -   Weight of strength per level (% out of 1)
*       real agility        -   Weight of agility per level (% out of 1)
*       real intelligence   -   Weight of intelligence per level (% out of 1)
*       real base           -   How many points to get at level 1. Overrides PTS.
*       real growth         -   How many points to get at each level. Overrides LVL_GROWTH.
*                               % of base.
*
*       method unsetBase takes nothing returns nothing
*           -   Removes override of PTS
*       method unsetGrowth takes nothing returns nothing
*           -   Removes override of LVL_GROWTH
*
*   struct HeroStat extends array
*       static method operator [] takes unit u returns HeroStat
*           -   Retrieves HeroStat struct given a unit (GetUnitId)
*
*       real strength       -   Overrides HeroTypeStat strength
*       real agility        -   Overrides HeroTypeStat agility
*       real intelligence   -   Overrides HeroTypeStat intelligence 
*       real base           -   Overrides HeroTypeStat base and PTS
*       real growth         -   Overrides HeroTypeStat growth and LVL_GROWTH
*
*       method unsetGrowth takes nothing returns nothing
*       method unsetBase takes nothing returns nothing
*       method unsetStrength takes nothing returns nothing
*       method unsetAgility takes nothing returns nothing
*       method unsetIntelligence takes nothing returns nothing
*
************************************************************************************/
    globals
        //unit type specific
        private real array st       //strength growth
        private real array ag       //agility growth
        private real array in       //intelligence growth
        private real array gr       //growth pts
        private real array bs       //base pts
        private real array gy       //gr*bs
        private boolean array og    //override growth
        private boolean array ob    //override base
        
        //unit specific
        private real array st2      //strength growth
        private real array ag2      //agility growth
        private real array in2      //intelligence growth
        private real array gr2      //growth pts
        private real array bs2      //base pts
        private real array gy2      //gr*bs
        private boolean array og2   //override growth
        private boolean array ob2   //override base
        private boolean array ost
        private boolean array oag
        private boolean array oin
        private Table ut = 0        //unit type table
        private integer tc = 0      //type count
        
        private integer array str
        private integer array agr
        private integer array inr
        
        private real gs = PTS*LVL_GROWTH
    endglobals
    private keyword tgrow
    struct HeroTypeStat extends array
        static method operator [] takes integer v returns thistype
            if (ut.has(v)) then
                return ut[v]
            endif
            set tc = tc + 1
            set ut[v] = tc
            return tc
        endmethod
        
        method operator tgrow takes nothing returns real
            if (og[this] or ob[this]) then
                return gy[this]
            endif
            return gs
        endmethod
        method operator growth takes nothing returns real
            if (og[this]) then
                return gr[this]
            endif
            return LVL_GROWTH
        endmethod
        method operator base takes nothing returns real
            if (ob[this]) then
                return bs[this]
            endif
            return PTS+0.
        endmethod
        
        method unsetGrowth takes nothing returns nothing
            set og[this] = false
        endmethod
        method unsetBase takes nothing returns nothing
            set ob[this] = false
        endmethod
        
        method operator growth= takes real v returns nothing
            set og[this] = true
            set gr[this] = v
            set gy[this] = gr[this]*base
        endmethod
        method operator base= takes real v returns nothing
            set ob[this] = true
            set bs[this] = v
            set gy[this] = growth*bs[this]
        endmethod
        
        method operator strength takes nothing returns real
            return st[this]
        endmethod
        method operator agility takes nothing returns real
            return ag[this]
        endmethod
        method operator intelligence takes nothing returns real
            return in[this]
        endmethod
        
        method operator strength= takes real v returns nothing
            debug local real b = PTS
            debug if (ob[this]) then
                debug set b = bs[this]
            debug endif
            debug if (v*STR_COST + ag[this]*AGI_COST + in[this]*INT_COST <= b) then
                set st[this] = v
            debug else
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "HERO STR STAT OVERFLOW")
            debug endif
        endmethod
        method operator agility= takes real v returns nothing
            debug local real b = PTS
            debug if (ob[this]) then
                debug set b = bs[this]
            debug endif
            debug if (st[this]*STR_COST + v*AGI_COST + in[this]*INT_COST <= b) then
                set ag[this] = v
            debug else
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "HERO AGI STAT OVERFLOW")
            debug endif
        endmethod
        method operator intelligence= takes real v returns nothing
            debug local real b = PTS
            debug if (ob[this]) then
                debug set b = bs[this]
            debug endif
            debug if (st[this]*STR_COST + ag[this]*AGI_COST + v*INT_COST <= b) then
                set in[this] = v
            debug else
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "HERO INT STAT OVERFLOW")
            debug endif
        endmethod
    endstruct
    struct HeroStat extends array
        static method operator [] takes unit u returns thistype
            return GetUnitId(u)
        endmethod
        
        method operator tgrow takes nothing returns real
            if (og2[this] or ob2[this]) then
                return gy2[this]
            endif
            return HeroTypeStat[GetUnitTypeId(GetUnitById(this))].tgrow
        endmethod
        method operator growth takes nothing returns real
            if (og2[this]) then
                return gr2[this]
            endif
            return HeroTypeStat[GetUnitTypeId(GetUnitById(this))].growth
        endmethod
        method operator base takes nothing returns real
            if (ob2[this]) then
                return bs2[this]
            endif
            return HeroTypeStat[GetUnitTypeId(GetUnitById(this))].base
        endmethod
        
        method unsetGrowth takes nothing returns nothing
            set og2[this] = false
        endmethod
        method unsetBase takes nothing returns nothing
            set ob2[this] = false
        endmethod
        
        method operator growth= takes real v returns nothing
            set og2[this] = true
            set gr2[this] = v
            set gy2[this] = gr2[this]*base
        endmethod
        method operator base= takes real v returns nothing
            set ob2[this] = true
            set bs2[this] = v
            set gy2[this] = growth*bs2[this]
        endmethod
            
        method operator strength takes nothing returns real
            if (ost[this]) then
                return st2[this]
            endif
            return st[HeroTypeStat[GetUnitTypeId(GetUnitById(this))]]
        endmethod
        method operator agility takes nothing returns real
            if (oag[this]) then
                return ag2[this]
            endif
            return ag[HeroTypeStat[GetUnitTypeId(GetUnitById(this))]]
        endmethod
        method operator intelligence takes nothing returns real
            if (oin[this]) then
                return in2[this]
            endif
            return in[HeroTypeStat[GetUnitTypeId(GetUnitById(this))]]
        endmethod
        
        method unsetStrength takes nothing returns nothing
            set ost[this] = false
        endmethod
        method unsetAgility takes nothing returns nothing
            set oag[this] = false
        endmethod
        method unsetIntelligence takes nothing returns nothing
            set oin[this] = false
        endmethod
        
        method operator strength= takes real v returns nothing
            debug local real b = base
            debug if (v*STR_COST + agility*AGI_COST + intelligence*INT_COST <= b) then
                set st2[this] = v
                set ost[this] = true
            debug else
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "HERO STR STAT OVERFLOW")
            debug endif
        endmethod
        method operator agility= takes real v returns nothing
            debug local real b = base
            debug if (strength*STR_COST + v*AGI_COST + intelligence*INT_COST <= b) then
                set ag2[this] = v
                set oag[this] = true
            debug else
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "HERO AGI STAT OVERFLOW")
            debug endif
        endmethod
        method operator intelligence= takes real v returns nothing
            debug local real b = base
            debug if (strength*STR_COST + agility*AGI_COST + v*INT_COST <= b) then
                set in2[this] = v
                set oin[this] = true
            debug else
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "HERO INT STAT OVERFLOW")
            debug endif
        endmethod
    endstruct
    
    private module Init
        private static method lvl takes nothing returns boolean
            local unit u = GetIndexedUnit()
            local HeroStat i = GetUnitId(u)
            local integer l = GetHeroLevel(u)
            local real p
            local real p2
            if (IsUnitType(u, UNIT_TYPE_HERO)) then
                set p = i.base*i.strength/STR_COST
                set p2 = i.tgrow*i.strength/STR_COST
                if (l > 1) then
                    set str[i] = GetHeroStr(u, false)-R2I(p+p2*(l-2))
                else
                    set str[i] = GetHeroStr(u, false)
                endif
                call SetHeroStr(u, R2I(p+p2*(l-1)+str[i]), true)
                
                set p = i.base*i.agility/AGI_COST
                set p2 = i.tgrow*i.agility/AGI_COST
                if (l > 1) then
                    set agr[i] = GetHeroAgi(u, false)-R2I(p+p2*(l-1))
                else
                    set agr[i] = GetHeroAgi(u, false)
                endif
                call SetHeroAgi(u, R2I(p+p2*(l-1)+agr[i]), true)
                
                set p = i.base*i.intelligence/INT_COST
                set p2 = i.tgrow*i.intelligence/INT_COST
                if (l > 1) then
                    set inr[i] = GetHeroInt(u, false)-R2I(p+p2*(l-1))
                else
                    set inr[i] = GetHeroInt(u, false)
                endif
                call SetHeroInt(u, R2I(p+p2*(l-1)+inr[i]), true)
            endif
            set u = null
            return false
        endmethod
        private static method lvl2 takes nothing returns boolean
            local unit u = GetTriggerUnit()
            local HeroStat i = GetUnitId(u)
            local integer l = GetHeroLevel(u)
            local real p
            local real p2
            if (IsUnitType(u, UNIT_TYPE_HERO)) then
                set p = i.base*i.strength/STR_COST
                set p2 = i.tgrow*i.strength/STR_COST
                if (l > 1) then
                    set str[i] = GetHeroStr(u, false)-R2I(p+p2*(l-2))
                else
                    set str[i] = GetHeroStr(u, false)-R2I(p)
                endif
                call SetHeroStr(u, R2I(p+p2*(l-1)+str[i]), true)
                
                set p = i.base*i.agility/AGI_COST
                set p2 = i.tgrow*i.agility/AGI_COST
                if (l > 1) then
                    set agr[i] = GetHeroAgi(u, false)-R2I(p+p2*(l-2))
                else
                    set agr[i] = GetHeroAgi(u, false)-R2I(p)
                endif
                call SetHeroAgi(u, R2I(p+p2*(l-1)+agr[i]), true)
                
                set p = i.base*i.intelligence/INT_COST
                set p2 = i.tgrow*i.intelligence/INT_COST
                if (l > 1) then
                    set inr[i] = GetHeroInt(u, false)-R2I(p+p2*(l-2))
                else
                    set inr[i] = GetHeroInt(u, false)-R2I(p)
                endif
                call SetHeroInt(u, R2I(p+p2*(l-1)+inr[i]), true)
            endif
            set u = null
            return false
        endmethod
        private static method res takes nothing returns boolean
            set str[GetIndexedUnitId()] = 0
            set agr[GetIndexedUnitId()] = 0
            set inr[GetIndexedUnitId()] = 0
            return false
        endmethod
        private static method inits takes nothing returns nothing
            local trigger t = CreateTrigger()
            local unit u
            local HeroStat i = 15
            local integer l
            local real p
            local real p2
            loop
                call TriggerRegisterPlayerUnitEvent(t, Player(i), EVENT_PLAYER_HERO_LEVEL, null)
                exitwhen i == 0
                set i = i - 1
            endloop
            call TriggerAddCondition(t, Condition(function thistype.lvl2))
            call RegisterUnitIndexEvent(Condition(function thistype.lvl), UnitIndexer.INDEX)
            call RegisterUnitIndexEvent(Condition(function thistype.res), UnitIndexer.DEINDEX)
            set i = UnitList[0].next
            loop
                exitwhen i == 0
                set u = GetUnitById(i)
                if (IsUnitType(u, UNIT_TYPE_HERO)) then
                    set l = GetHeroLevel(u)
                    
                    set p = i.base*i.strength/STR_COST
                    set p2 = i.tgrow*i.strength/STR_COST
                    if (l > 1) then
                        set str[i] = GetHeroStr(u, false)-R2I(p+p2*(l-2))
                    else
                        set str[i] = GetHeroStr(u, false)
                    endif
                    call SetHeroStr(u, R2I(p+p2*(l-1)+str[i]), true)
                    
                    set p = i.base*i.agility/AGI_COST
                    set p2 = i.tgrow*i.agility/AGI_COST
                    if (l > 1) then
                        set agr[i] = GetHeroAgi(u, false)-R2I(p+p2*(l-2))
                    else
                        set agr[i] = GetHeroAgi(u, false)
                    endif
                    call SetHeroAgi(u, R2I(p+p2*(l-1)+agr[i]), true)
                    
                    set p = i.base*i.intelligence/INT_COST
                    set p2 = i.tgrow*i.intelligence/INT_COST
                    if (l > 1) then
                        set inr[i] = GetHeroInt(u, false)-R2I(p+p2*(l-2))
                    else
                        set inr[i] = GetHeroInt(u, false)
                    endif
                    call SetHeroInt(u, R2I(p+p2*(l-1)+inr[i]), true)
                endif
                set u = null
                set i = UnitList[i].next
            endloop
            call DestroyTimer(GetExpiredTimer())
        endmethod
        
        private static method onInit takes nothing returns nothing
            set ut = Table.create()
            call TimerStart(CreateTimer(), 0, false, function thistype.inits)
        endmethod
    endmodule
    
    private struct Inits extends array
        implement Init
    endstruct
    
    function GetHiddenHeroStrBonus takes unit u returns integer
        local HeroStat i = GetUnitId(u)
        if (GetHeroLevel(u) > 1) then
            return GetHeroStr(u, false)-R2I(i.base*i.strength+i.tgrow*i.strength*(GetHeroLevel(u)-2))
        endif
        return GetHeroStr(u, false)-R2I(i.base*i.strength)
    endfunction
    function GetHiddenHeroAgiBonus takes unit u returns integer
        local HeroStat i = GetUnitId(u)
        if (GetHeroLevel(u) > 1) then
            return GetHeroAgi(u, false)-R2I(i.base*i.agility+i.tgrow*i.agility*(GetHeroLevel(u)-2))
        endif
        return GetHeroAgi(u, false)-R2I(i.base*i.agility)
    endfunction
    function GetHiddenHeroIntBonus takes unit u returns integer
        local HeroStat i = GetUnitId(u)
        if (GetHeroLevel(u) > 1) then
            return GetHeroInt(u, false)-R2I(i.base*i.intelligence+i.tgrow*i.intelligence*(GetHeroLevel(u)-2))
        endif
        return GetHeroInt(u, false)-R2I(i.base*i.intelligence)
    endfunction
endlibrary