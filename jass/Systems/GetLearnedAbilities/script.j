library GetLearnedAbilities /* v1.0.0.0
*************************************************************************************
*
*   Allows one to retrieve all currently learned abilities of a unit
*
*************************************************************************************
*
*   */ uses /*
*
*       */ UnitIndexer /*       hiveworkshop.com/forums/jass-functions-413/unit-indexer-172090/
*       */ Table /*             hiveworkshop.com/forums/jass-functions-413/snippet-new-table-188084/
*
************************************************************************************
*
*   struct LearnedAbilities extends array
*
*       static method operator [] takes unit u returns LearnedAbilities
*       method operator [] takes integer index returns integer abilityId
*
*       method operator count takes nothing returns integer abilityCount
*
***********************************************************************************/
    globals
        private Table abils
        private Table marked
        private integer array c
    endglobals
    private function Index takes nothing returns boolean
        set abils[GetIndexedUnitId()]=Table.create()
        set marked[GetIndexedUnitId()]=Table.create()
        return false
    endfunction
    private function Deindex takes nothing returns boolean
        call Table(abils[GetIndexedUnitId()]).destroy()
        call Table(marked[GetIndexedUnitId()]).destroy()
        set c[GetIndexedUnitId()]=0
        return false
    endfunction
    private function Ability takes nothing returns boolean
        local integer i = GetUnitUserData(GetTriggerUnit())
        if (not Table(marked[i]).boolean.has(GetLearnedSkill())) then
            set Table(abils[i])[c[i]]=GetLearnedSkill()
            set Table(marked[i]).boolean[GetLearnedSkill()]=true
            set c[i]=c[i]+1
        endif
        return false
    endfunction
    private module M
        private static method onInit takes nothing returns nothing
            local integer i=15
            local trigger t=CreateTrigger()
            call TriggerAddCondition(t,Condition(function Ability))
            set abils = Table.create()
            set marked = Table.create()
            call RegisterUnitIndexEvent(Condition(function Index),UnitIndexer.INDEX)
            call RegisterUnitIndexEvent(Condition(function Deindex),UnitIndexer.DEINDEX)
            loop
                call TriggerRegisterPlayerUnitEvent(t,Player(i),EVENT_PLAYER_HERO_SKILL,null)
                exitwhen 0==i
                set i=i-1
            endloop
        endmethod
    endmodule
    struct LearnedAbilities extends array
        static method operator [] takes unit u returns LearnedAbilities
            return GetUnitUserData(u)
        endmethod
        method operator [] takes integer index returns integer
            return Table(abils[this])[index]
        endmethod
        method operator count takes nothing returns integer
            local integer i=c[this]
            local integer m
            loop
                exitwhen 0==i
                set i=i-1
                set m=Table(abils[this])[i]
                if (0==GetUnitAbilityLevel(GetUnitById(this),m)) then
                    call Table(marked[this]).remove(m)
                    set c[this]=c[this]-1
                    set Table(abils[this])[i]=Table(abils[this])[c[this]]
                    call Table(abils[this]).remove(c[this])
                endif
            endloop
            return c[this]
        endmethod
        implement M
    endstruct
endlibrary