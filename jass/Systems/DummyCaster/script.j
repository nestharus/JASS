library DummyCaster /* v2.0.0.1
*************************************************************************************
*
*   Dummy caster for casting spells
*
*   Spells must have 0 cooldown, 92083 range, and cost 0 mana. Spells must be instant and
*   can't share the same order as other spells on the dummy caster.
*
*************************************************************************************
*
*   */uses/*
*       */ optional UnitIndexer /*       hiveworkshop.com/forums/jass-functions-413/unit-indexer-172090/
*
************************************************************************************
*   SETTINGS
*/
globals
    /*************************************************************************************
    *
    *                                   PLAYER_OWNER
    *
    *   Owner of dummy caster
    *
    *************************************************************************************/
    private constant player PLAYER_OWNER = Player(15)
endglobals
/*
************************************************************************************
*
*   Dummy at position 32256,32256
*
*    struct DummyCaster extends array
*
*       method cast takes player castingPlayer, integer abilityLevel, integer order, real x, real y returns boolean
*           -   call DummyCaster[abilityId].cast(...)
*       method castTarget takes player castingPlayer, integer abilityLevel, integer order, widget t returns boolean
*           -   call DummyCaster[abilityId].castTarget(...)
*       method castPoint takes player castingPlayer, integer abilityLevel, integer order, real x, real y returns boolean
*           -   call DummyCaster[abilityId].castPoint(...)
*
************************************************************************************/
    globals
        private unit u
    endglobals
    private module N
        private static method onInit takes nothing returns nothing
            static if LIBRARY_UnitIndexer then
                set UnitIndexer.enabled=false
                set u=CreateUnit(PLAYER_OWNER,UNITS_DUMMY_CASTER,0,0,0)
                set UnitIndexer.enabled=true
            else
                set u=CreateUnit(PLAYER_OWNER,UNITS_DUMMY_CASTER,0,0,0)
            endif
            call SetUnitPosition(u,32256,32256)
        endmethod
    endmodule
    struct DummyCaster extends array
        implement N
        private static method prep takes integer a, player p, integer l returns nothing
            call UnitAddAbility(u, a)
            if (1 < l) then
                call SetUnitAbilityLevel(u, a, l)
            endif
            if (null != p) then
                call SetUnitOwner(u, p, false)
            endif
        endmethod
        private static method finish takes integer a returns nothing
            call SetUnitOwner(u, PLAYER_OWNER, false)
            call UnitRemoveAbility(u, a)
        endmethod
        method cast takes player p, integer level, integer order, real x, real y returns boolean
            local boolean b
            call SetUnitX(u, x)
            call SetUnitY(u, y)
            call prep(this, p, level)
            set b = IssueImmediateOrderById(u,order)
            call finish(this)
            call SetUnitPosition(u, 32256, 32256)
            return b
        endmethod
        method castTarget takes player p, integer level, integer order, widget t returns boolean
            local boolean b
            call prep(this, p, level)
            set b = IssueTargetOrderById(u,order,t)
            call finish(this)
            return b
        endmethod
        method castPoint takes player p, integer level, integer order, real x, real y returns boolean
            local boolean b
            call prep(this, p, level)
            set b = IssuePointOrderById(u,order,x,y)
            call finish(this)
            return b
        endmethod
    endstruct
endlibrary