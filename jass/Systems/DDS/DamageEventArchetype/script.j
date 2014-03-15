library DamageEventArchetype /* v1.0.2.0
*************************************************************************************
*
*   Damage Event Archetype plugin for DDS
*
*
*   Notes
*   --------------
*
*       -   Must invert Damage Return Factor for Locust Swarm based abilities
*
*       -   Must invert healing portion of Life Drain based abilities
*
*************************************************************************************
*
*   */uses/*
*
*       */ DDS                      /*      hiveworkshop.com/forums/spells-569/framework-dds-damage-detection-system-231238/
*       */ DamageEventModification  /*      hiveworkshop.com/forums/jass-resources-412/dds-plugin-damage-event-modification-231176/
*
************************************************************************************
*
*   SETTINGS
*/
globals
    /*************************************************************************************
    *
    *   Configure to spell reduction ability type id
    *
    *************************************************************************************/
    constant integer DAMAGE_EVENT_ARCHETYPE_PLUGIN_ABILITY = 'A002'
endglobals
/*
*************************************************************************************
*
*   API
*
*       static constant integer Archetype.SPELL
*       static constant integer Archetype.PHYSICAL
*       static constant integer Archetype.CODE
*
*       readonly static integer archetype
*           -   type of damage source damage came from: SPELL, PHYSICAL, CODE
*
*       static UnitIndex damageCode
*           -   set this to the unit that will be damaged with code
*
*       seals (can no longer be overwritten)
*
*           boolean enabled (from DDS Framework)
*
*************************************************************************************/
    //! textmacro DAMAGE_EVENT_ARCHETYPE_CODE
    globals
        private constant boolean ENABLED_EXISTS = true
        
        private real scale
    endglobals
    
    scope Archetype
        private struct DamageEventArchtype extends array
            static constant integer SPELL = 0
            static constant integer PHYSICAL = 1
            static constant integer CODE = 2
        endstruct
    
        /*
        *   DDS API
        *
        *       DDS.Archetype.SPELL
        *       DDS.Archetype.PHYSICAL
        *       DDS.Archetype.CODE
        *       DDS.archetype
        *       DDS.damageCode
        *       
        */
            private keyword archetype_p
            private keyword damageEventArchetypeInit
            private keyword damageCode_p
            module DAMAGE_EVENT_ARCHETYPE_API
                readonly static DamageEventArchtype Archetype = 0
                static integer archetype_p = 0
                static UnitIndex damageCode_p = 0
                
                static method operator damageCode= takes UnitIndex u returns nothing
                    set damageCode_p = u
                    static if ENABLE_GUI then
                        call DisableTrigger(GUI.damageCode)
                        set udg_DDS_damageCode = u
                        call EnableTrigger(GUI.damageCode)
                    endif
                endmethod
                static method operator damageCode takes nothing returns UnitIndex
                    return damageCode_p
                endmethod
                
                static method operator archetype takes nothing returns integer
                    return archetype_p
                endmethod
                
                private static method onIndex takes nothing returns boolean
                    call UnitAddAbility(GetIndexedUnit(), DAMAGE_EVENT_ARCHETYPE_PLUGIN_ABILITY)
                    call UnitMakeAbilityPermanent(GetIndexedUnit(), true, DAMAGE_EVENT_ARCHETYPE_PLUGIN_ABILITY)
                    
                    return false
                endmethod
                
                static method damageEventArchetypeInit takes nothing returns nothing
                    local integer playerId
            
                    set playerId = 15
                    loop
                        call SetPlayerAbilityAvailable(Player(playerId), DAMAGE_EVENT_ARCHETYPE_PLUGIN_ABILITY, false)
                        
                        exitwhen 0 == playerId
                        set playerId = playerId - 1
                    endloop
                
                    call RegisterUnitIndexEvent(Condition(function thistype.onIndex), UnitIndexer.INDEX)
                endmethod
            endmodule
            module DAMAGE_EVENT_ENABLE
                method operator enabled= takes boolean b returns nothing
                    static if ENABLE_GUI then
                        set udg_DDS_enabled[this] = b
                        set udg_DDS_enable = 0
                    endif
                
                    if (b) then
                        call EnableTrigger(Trigger(this).parent.trigger)
                        call UnitAddAbility(UnitIndex(this).unit, DAMAGE_EVENT_ARCHETYPE_PLUGIN_ABILITY)
                        call UnitMakeAbilityPermanent(UnitIndex(this).unit, true, DAMAGE_EVENT_ARCHETYPE_PLUGIN_ABILITY)
                    else
                        call DisableTrigger(Trigger(this).parent.trigger)
                        call UnitRemoveAbility(UnitIndex(this).unit, DAMAGE_EVENT_ARCHETYPE_PLUGIN_ABILITY)
                    endif
                endmethod
            endmodule
            module DAMAGE_EVENT_ARCHETYPE_INIT
                call DDS.damageEventArchetypeInit()
            endmodule

        /*
        *   DDS Interface
        */
        module DAMAGE_EVENT_ARCHETYPE_INTERFACE
            
        endmodule

        /*
        *   DDS Event Handling
        */
module DAMAGE_EVENT_ARCHETYPE_RESPONSE_LOCALS
                local integer prevArchetype = archetype_p
endmodule
module DAMAGE_EVENT_ARCHETYPE_RESPONSE_BEFORE
                if (damage_p < 0) then
                    set archetype_p = Archetype.SPELL
                    
                    /*
                    *   Calculate spell resistance
                    */
                    call DisableTrigger(Trigger(targetId_p).parent.trigger)
                    
                        set life = GetWidgetLife(u)
                        set scale = GetUnitState(u, UNIT_STATE_MAX_LIFE)
                        call SetWidgetLife(u, scale)
                        call UnitDamageTarget(killUnit, u, -scale/2, false, false, null, DAMAGE_TYPE_UNIVERSAL, null)
                        set scale = 2*(scale - GetWidgetLife(u))/scale
                        if (scale > 1) then
                            set damageOriginal = -damageOriginal*scale
                        else
                            set damageOriginal = -damageOriginal
                        endif
                        call SetWidgetLife(u, life)
                    
                    call EnableTrigger(Trigger(targetId_p).parent.trigger)
                    
                    set damage_p = damageOriginal
                else
                    set archetype_p = Archetype.PHYSICAL
                endif

                if (damageCode_p != 0) then
                    set archetype_p = Archetype.CODE
                    set damageCode_p = 0
                endif
                
                static if ENABLE_GUI then
                    set DDS.damage = damage_p
                    set udg_DDS_damageCode = damageCode_p
                    set udg_DDS_archetype = archetype_p
                endif
endmodule
module DAMAGE_EVENT_ARCHETYPE_RESPONSE
                
endmodule
module DAMAGE_EVENT_ARCHETYPE_RESPONSE_AFTER
                
endmodule
module DAMAGE_EVENT_ARCHETYPE_RESPONSE_CLEANUP
                set archetype_p = prevArchetype
                static if ENABLE_GUI then
                    set udg_DDS_archetype = archetype_p
                endif
endmodule

        module DAMAGE_EVENT_ARCHETYPE_GUI_GLOBALS
            static trigger damageCode
        endmodule
        module DAMAGE_EVENT_ARCHETYPE_GUI
            private static method DDS_damageCode takes nothing returns boolean
                set DDS.damageCode = udg_DDS_damageCode
                return false
            endmethod
            private static method DDS_initVariables takes nothing returns nothing
                set GUI.damageCode = CreateTrigger()
                call TriggerRegisterVariableEvent(GUI.damageCode, "udg_DDS_damageCode", GREATER_THAN, 0.)
                call TriggerAddCondition(GUI.damageCode, Condition(function thistype.DDS_damageCode))
                
                set udg_DDS_ARCHETYPE_SPELL = DDS.Archetype.SPELL
                set udg_DDS_ARCHETYPE_PHYSICAL = DDS.Archetype.PHYSICAL
                set udg_DDS_ARCHETYPE_CODE = DDS.Archetype.CODE
            endmethod
            
            private static method onInit takes nothing returns nothing
                call DDS_initVariables()
            endmethod
        endmodule
    endscope
    //! endtextmacro
endlibrary