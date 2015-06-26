library DamageEventModification /* v1.1.0.1
*************************************************************************************
*
*   Damage Event Modification plugin for DDS
*
*************************************************************************************
*
*   */uses/*
*
*       */ DDS                      /*
*       */ DamageEvent              /*
*
*************************************************************************************
*
*   SETTINGS
*/
globals
    /*************************************************************************************
    *
    *   Configure to life bonus ability type id
    *
    *************************************************************************************/
    constant integer LIFE_SAVER_ABILITY_ID     = 'A001'
    constant integer LIFE_SAVER_ABILITY_ID_2   = 'A003'
    constant integer ARMOR_ABILITY_ID          = 'A004'
endglobals
/*
*************************************************************************************
*
*   API
*
*       static real damage
*           -   may now be changed
*       readonly static real damageOriginal
*           -   result of GetEventDamage()
*       readonly static real damageModifiedAmount
*           -   how much the damage variable was changed
*
*************************************************************************************
*
*   Plugin Information (can only be used by other plugins)
*
*       GLOBALS
*
*           boolean array saved
*               -   does the unit have life bonus
*
*           unit killUnit
*               -   a dummy unit that can be used to deal damage
*
*       LOCALS
*
*           real life
*               -   life of target unit
*
*           unit u
*               -   stores target, improved speed
*
*************************************************************************************/
    //! textmacro DAMAGE_EVENT_MODIFICATION_CODE
    private keyword saved
    private keyword killUnit
    
    private struct FixLife extends array
        static boolexpr exprKill
        static boolexpr exprLife
        
        private unit source
        private player sourcePlayer
        private real life
        private real damage
        
        static method funcKill takes nothing returns boolean
            local unit u = GetTriggerUnit()
            local thistype target = GetUnitUserData(u)
            local real maxLife = GetUnitState(UnitIndex(target).unit, UNIT_STATE_MAX_LIFE)
            
            call DestroyTrigger(GetTriggeringTrigger())
            
            set DDS[target].enabled = false
        
            call UnitAddAbility(u, ARMOR_ABILITY_ID)
            if (GetUnitTypeId(target.source) == 0) then
                call SetUnitX(killUnit, GetUnitX(u))
                call SetUnitY(killUnit, GetUnitY(u))
                call SetUnitOwner(killUnit, target.sourcePlayer, false)
                
                call SetWidgetLife(UnitIndex(target).unit, maxLife*.5)
                call UnitDamageTarget(killUnit, u, 10000000, false, true, null, DAMAGE_TYPE_UNIVERSAL, null)
                call SetWidgetLife(UnitIndex(target).unit, maxLife*.5)
                call UnitDamageTarget(killUnit, u, 10000000, false, true, null, DAMAGE_TYPE_NORMAL, null)
            else
                call SetWidgetLife(UnitIndex(target).unit, maxLife*.5)
                call UnitDamageTarget(target.source, u, 10000000, false, true, null, DAMAGE_TYPE_UNIVERSAL, null)
                call SetWidgetLife(UnitIndex(target).unit, maxLife*.5)
                call UnitDamageTarget(target.source, u, 10000000, false, true, null, DAMAGE_TYPE_NORMAL, null)
            endif
            call UnitRemoveAbility(u, ARMOR_ABILITY_ID)
            
            set DDS[target].enabled = true
            
            call SetWidgetLife(u, 0)
            
            set u = null
            
            return false
        endmethod
        
        static method funcLife takes nothing returns boolean
            local thistype target = GetUnitUserData(GetTriggerUnit())
            
            call DestroyTrigger(GetTriggeringTrigger())
            
            call SetWidgetLife(UnitIndex(target).unit, GetUnitState(UnitIndex(target).unit, UNIT_STATE_MAX_LIFE))
            call UnitRemoveAbility(UnitIndex(target).unit, LIFE_SAVER_ABILITY_ID)
            call UnitRemoveAbility(UnitIndex(target).unit, LIFE_SAVER_ABILITY_ID_2)
            call SetWidgetLife(UnitIndex(target).unit, target.life)
            
            return false
        endmethod
        
        static method applyKill takes thistype target, unit source, player sourcePlayer, real damage returns nothing
            local trigger t
            
            call SetWidgetLife(UnitIndex(target).unit, GetUnitState(UnitIndex(target).unit, UNIT_STATE_MAX_LIFE))
            
            set target.source = source
            set target.sourcePlayer = sourcePlayer
            
            set t = CreateTrigger()
            call TriggerRegisterUnitStateEvent(t, UnitIndex(target).unit, UNIT_STATE_LIFE, GREATER_THAN, GetWidgetLife(UnitIndex(target).unit)*.99)
            call TriggerAddCondition(t, exprKill)
            call SetWidgetLife(UnitIndex(target).unit, GetWidgetLife(UnitIndex(target).unit)*.99)
            
            set t = null
        endmethod
        
        static method applyLife takes thistype target, real life returns nothing
            local trigger t
            
            set target.life = life
            call SetWidgetLife(UnitIndex(target).unit, GetUnitState(UnitIndex(target).unit, UNIT_STATE_MAX_LIFE))
            if (GetWidgetLife(UnitIndex(target).unit) < 10) then
                call UnitAddAbility(UnitIndex(target).unit, LIFE_SAVER_ABILITY_ID_2)
            else
                call UnitAddAbility(UnitIndex(target).unit, LIFE_SAVER_ABILITY_ID)
            endif
            
            set t = CreateTrigger()
            if (GetEventDamage() < 0) then
                call TriggerRegisterUnitStateEvent(t, UnitIndex(target).unit, UNIT_STATE_LIFE, GREATER_THAN, GetWidgetLife(UnitIndex(target).unit)*.99)
                call SetWidgetLife(UnitIndex(target).unit, GetWidgetLife(UnitIndex(target).unit)*.99)
            else
                call TriggerRegisterUnitStateEvent(t, UnitIndex(target).unit, UNIT_STATE_LIFE, LESS_THAN, GetWidgetLife(UnitIndex(target).unit) - GetEventDamage()*.5)
            endif
            call TriggerAddCondition(t, exprLife)
            
            set t = null
        endmethod
    endstruct
    
    scope DamageEventModification
        globals
            unit killUnit
        endglobals
        
        /*
        *   DDS API
        *
        *       DDS.damage                  Can Now Be Set
        *       DDS.damageOriginal
        *       DDS.damageModifiedAmount
        *
        */
        module DAMAGE_EVENT_MODIFICATION_API
            readonly static real damageOriginal = 0
            
            static method operator damageModifiedAmount takes nothing returns real
                return damage_p - damageOriginal
            endmethod
            static method operator damage= takes real newDamage returns nothing
                set damage_p = newDamage
            endmethod
            
        endmodule
        module DAMAGE_EVENT_MODIFICATION_INIT
            set UnitIndexer.enabled = false
            set killUnit = CreateUnit(Player(15), 'hfoo', WorldBounds.maxX - 128, WorldBounds.maxY - 128, 0)
            set UnitIndexer.enabled = true
            
            call UnitAddAbility(killUnit, 'Aloc')
            call UnitAddAbility(killUnit, 'Avul')
            call ShowUnit(killUnit, false)
            call PauseUnit(killUnit, true)
            
            set FixLife.exprKill = Condition(function FixLife.funcKill)
            set FixLife.exprLife = Condition(function FixLife.funcLife)
        endmodule

        /*
        *   DDS Interface
        */
        module DAMAGE_EVENT_MODIFICATION_INTERFACE
            
        endmodule

        /*
        *   DDS Event Handling
        */
module DAMAGE_EVENT_MODIFICATION_RESPONSE_LOCALS
                local real actualDamage
                local real prevDamageOriginal = damageOriginal
                local real life
                local unit u
endmodule
module DAMAGE_EVENT_MODIFICATION_RESPONSE_BEFORE
                set actualDamage = damage_p
                set damageOriginal = actualDamage                   //original damage as seen by user
                set u = targetId_p.unit
endmodule
module DAMAGE_EVENT_MODIFICATION_RESPONSE
                
endmodule
module DAMAGE_EVENT_MODIFICATION_RESPONSE_AFTER
                set life = GetWidgetLife(u)
                
                if (actualDamage < 0) then
                    if (life - damage_p < .4051) then
                        call FixLife.applyKill(targetId_p, source, sourcePlayer_p, actualDamage)
                    elseif (life + actualDamage - damage_p < .406) then
                        call FixLife.applyLife(targetId_p, life - damage_p)
                    else
                        call SetWidgetLife(u, life + actualDamage - damage_p)
                    endif
                elseif (life - damage_p < .4051) then
                    call SetWidgetLife(u, actualDamage)
                else
                    call SetWidgetLife(u, life + actualDamage - damage_p)
                endif
endmodule
module DAMAGE_EVENT_MODIFICATION_RESPONSE_CLEANUP
                set damageOriginal = prevDamageOriginal
                set u = null
endmodule        
    endscope
    //! endtextmacro
endlibrary