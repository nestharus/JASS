library Spell /* v2.0.0.0
*************************************************************************************
*
*   General spell casting with dummy casters to cast those spells
*
*   Spells must cost 0 mana
*
*   Spells can be retrieved within trigger events by reading GetUnitUserData(unit)
*
*************************************************************************************
*
*   */uses/*
*
*       */ Dummy         /*                     hiveworkshop.com/forums/submissions-414/system-dummy-213908/
*
*   Recommended:
*
*          Order Ids:                           hiveworkshop.com/forums/jass-resources-412/repo-order-ids-197002/
*          Spell Struct:                        hiveworkshop.com/forums/jass-resources-412/system-spell-struct-204774/
*
************************************************************************************
*
*   struct Spell extends array
*
*       Creators/Destructors
*       -----------------------
*
*           static method create takes unit source, real x, real y, real z, real facing returns Spell
*               -   creates new dummy at location with source owner
*               -   a Dummy can just as easily be typecasted
*
*           method destroy takes nothing returns nothing
*               -   destroys the spell/dummy
*               -   this should be called instead of Dummy.destroy
*
*       Fields
*       -----------------------
*
*           readonly Dummy dummy
*               -   the dummy representing spell
*           unit source
*               -   owner of spell
*           readonly player owningPlayer
*               -   player that owns source. Player(15) if no source.
*
*           integer integer abilityId
*           integer abilityLevel
*           integer integer abilityOrder
*               -   it is recommended to make all dummy abilities use the same order id for ease
*
*       Methods
*       -----------------------
*
*           method cast takes nothing returns boolean
*           method castTarget takes widget target returns boolean
*           method castPoint takes real targetX, real targetY returns boolean
*           method cancel takes nothing returns nothing
*
************************************************************************************/
    struct Spell extends array
        method operator dummy takes nothing returns Dummy
            return this
        endmethod
        
        private unit source_p
        method operator source takes nothing returns unit
            return source_p
        endmethod
        method operator source= takes unit u returns nothing
            set source_p = u
            if (u == null) then
                call SetUnitOwner(dummy.unit, Player(15), true)
            else
                call SetUnitOwner(dummy.unit, GetOwningPlayer(u), true)
            endif
        endmethod
        
        method operator owningPlayer takes nothing returns player
            if (null == source) then
                return Player(15)
            endif
            return GetOwningPlayer(source)
        endmethod
        
        private integer abilityLevel_p
        private integer abilityId_p
        integer abilityOrder
        
        method operator abilityLevel takes nothing returns integer
            return abilityLevel_p
        endmethod
        method operator abilityId takes nothing returns integer
            return abilityId_p
        endmethod
        
        method operator abilityLevel= takes integer level returns nothing
            set abilityLevel_p = level
            if (level != GetUnitAbilityLevel(dummy.unit, abilityId)) then
                call SetUnitAbilityLevel(dummy.unit, abilityId, level)
            endif
        endmethod
        method operator abilityId= takes integer abilityId returns nothing
            call IssueImmediateOrderById(dummy.unit, 851972)
            
            call UnitRemoveAbility(dummy.unit, this.abilityId)
            
            set abilityId_p = abilityId
            call UnitAddAbility(dummy.unit, abilityId)
            
            if (1 < abilityLevel) then
                call SetUnitAbilityLevel(dummy.unit, abilityId, abilityLevel)
            endif
        endmethod
        
        static method create takes unit source, real x, real y, real z, real facing returns Spell
            local thistype this = Dummy.create(x, y, facing)
            
            if (source != null) then
                set this.source = source
                call SetUnitOwner(dummy.unit, GetOwningPlayer(source), true)
            endif
            
            call SetUnitFlyHeight(dummy.unit, z, 0)
            
            call PauseUnit(dummy.unit, false)
            
            return this
        endmethod
        
        method destroy takes nothing returns nothing
            call IssueImmediateOrderById(dummy.unit, 851972)
            
            call UnitRemoveAbility(dummy.unit, abilityId)
            call SetUnitOwner(dummy.unit, Player(15), true)
            
            set abilityId = 0
            set abilityLevel = 0
            set abilityOrder = 0
            
            set source = null
            
            call PauseUnit(dummy.unit, true)
            
            call Dummy(this).destroy()
        endmethod
        
        method cast takes nothing returns boolean
            return IssueImmediateOrderById(dummy.unit, abilityOrder)
        endmethod
        method castTarget takes widget target returns boolean
            return IssueTargetOrderById(dummy.unit, abilityOrder, target)
        endmethod
        method castPoint takes real targetX, real targetY returns boolean
            return IssuePointOrderById(dummy.unit, abilityOrder, targetX, targetY)
        endmethod
        method cancel takes nothing returns nothing
            call IssueImmediateOrderById(dummy.unit, 851972)
        endmethod
    endstruct
endlibrary