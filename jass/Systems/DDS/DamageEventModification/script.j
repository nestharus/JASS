library DamageEventModification /* v1.0.3.0
*************************************************************************************
*
*   Damage Event Modification plugin for DDS
*
*************************************************************************************
*
*   */uses/*
*
*       */ DDS                      /*      hiveworkshop.com/forums/spells-569/framework-dds-damage-detection-system-231238/
*       */ DamageEvent              /*      hiveworkshop.com/forums/jass-resources-412/dds-plugin-damage-event-231172/
*       */ RegisterPlayerUnitEvent  /*      hiveworkshop.com/forums/jass-resources-412/snippet-registerplayerunitevent-203338/
*       */ LifeSaver                /*      hiveworkshop.com/forums/submissions-414/snippet-life-saver-234347/
*
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
*       readonly static real life
*           -   how much life the target unit has
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
    scope DamageEventModification
        globals
            private timer afterDamageTimer = CreateTimer()
        
            boolean array saved
            private UnitIndex array id
            private integer array index
            private integer stackCount = 0
            
            unit killUnit
        endglobals
        
        private function OnAfterDamage takes nothing returns nothing
            local integer i = stackCount
            local integer u
            
            loop
                set i = i - 1
                
                set u = id[i]
                
                call RemoveMaxLife(u)
                set saved[u] = false
                
                exitwhen 0 == i
            endloop
            
            set stackCount = 0
        endfunction
        
        private function AddAfterDamage takes UnitIndex whichUnit returns nothing
            if (not saved[whichUnit]) then
                set saved[whichUnit] = true
                
                set id[stackCount] = whichUnit
                set index[whichUnit] = stackCount
                set stackCount = stackCount + 1
                
                call TimerStart(afterDamageTimer, 0, false, function OnAfterDamage)
                
                call ApplyMaxLife(whichUnit)
            endif
        endfunction
        
        private function RemoveAfterDamage takes UnitIndex whichUnit returns nothing
            if (saved[whichUnit]) then
                set saved[whichUnit] = false
                
                call RemoveMaxLife(whichUnit)
                
                set stackCount = stackCount - 1
                set id[index[whichUnit]] = id[stackCount]
                set index[id[stackCount]] = index[whichUnit]
                
                if (stackCount == 0) then
                    call PauseTimer(afterDamageTimer)
                endif
            endif
        endfunction
    
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
            static method operator life takes nothing returns real
                return GetUnitLife(targetId_p)
            endmethod
            static method operator damage= takes real newDamage returns nothing
                set damage_p = newDamage
                
                static if ENABLE_GUI then
                    call DisableTrigger(GUI.damage)
                    call DisableTrigger(GUI.life)
                    set udg_DDS_damage = newDamage
                    set udg_DDS_damageOriginal = DDS.damageOriginal
                    set udg_DDS_damageModifiedAmount = DDS.damageModifiedAmount
                    set udg_DDS_life = DDS.life
                    call EnableTrigger(GUI.damage)
                    call EnableTrigger(GUI.life)
                endif
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
                
                static if ENABLE_GUI then
                    set damage = damage_p
                endif
endmodule
module DAMAGE_EVENT_MODIFICATION_RESPONSE
                
endmodule
module DAMAGE_EVENT_MODIFICATION_RESPONSE_AFTER
                set life = GetUnitLife(targetId_p)
                
                if (life - damage_p < .4051) then
                    call RemoveAfterDamage(targetId_p)
                    
                    if (actualDamage < 0) then
                        set DDS[targetId_p].enabled = false
                        
                        if (GetUnitTypeId(source) == 0) then
                            call SetUnitX(killUnit, GetUnitX(u))
                            call SetUnitY(killUnit, GetUnitY(u))
                            call SetUnitOwner(killUnit, sourcePlayer_p, false)
                            
                            call SetWidgetLife(u, damageOriginal)
                            call UnitDamageTarget(killUnit, u, damageOriginal*100, false, true, null, DAMAGE_TYPE_UNIVERSAL, null)
                            call SetWidgetLife(u, damageOriginal)
                            call UnitDamageTarget(killUnit, u, damageOriginal*100, false, true, null, DAMAGE_TYPE_NORMAL, null)
                        else
                            call SetWidgetLife(u, damageOriginal)
                            call UnitDamageTarget(source, u, damageOriginal*100, false, true, null, DAMAGE_TYPE_UNIVERSAL, null)
                            call SetWidgetLife(u, damageOriginal)
                            call UnitDamageTarget(source, u, damageOriginal*100, false, true, null, DAMAGE_TYPE_NORMAL, null)
                        endif
                        
                        if (GetWidgetLife(u) > 0) then
                            call AddAfterDamage(targetId_p)
                        endif
                        
                        set DDS[targetId_p].enabled = true
                    else
                        call SetWidgetLife(u, actualDamage)
                    endif
                elseif (saved[targetId_p]) then
                    call AddUnitTargetLife(targetId_p, -damage_p)
                    
                    if (actualDamage > 0) then
                        call SetWidgetLife(u, GetWidgetLife(u) + actualDamage)
                    endif
                elseif (actualDamage < 0) then
                    if (life + actualDamage - damage_p < .406) then
                        call AddAfterDamage(targetId_p)
                        call AddUnitTargetLife(targetId_p, -damage_p)
                    else
                        call SetWidgetLife(u, life + actualDamage - damage_p)
                    endif
                else
                    if (life + actualDamage - damage_p > GetUnitState(u, UNIT_STATE_MAX_LIFE)) then
                        call AddAfterDamage(targetId_p)
                        call AddUnitTargetLife(targetId_p, -damage_p)
                        call SetWidgetLife(u, GetWidgetLife(u) + actualDamage)
                    else
                        call SetWidgetLife(u, life + actualDamage - damage_p)
                    endif
                endif
endmodule
module DAMAGE_EVENT_MODIFICATION_RESPONSE_CLEANUP
                set damageOriginal = prevDamageOriginal
                set u = null
                
                static if ENABLE_GUI then
                    set damage = damage_p
                endif
endmodule        
        
        private module Init
            private static method onInit takes nothing returns nothing
                call init()
            endmethod
        endmodule
        private struct OnDeath extends array
            private static method onDeath takes nothing returns nothing
                call RemoveAfterDamage(GetUnitUserData(GetTriggerUnit()))
            endmethod
        
            private static method init takes nothing returns nothing
                call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            endmethod
            
            implement Init
        endstruct
        private struct Deindex extends array
            private method deindex takes nothing returns nothing
                call RemoveAfterDamage(this)
            endmethod
        
            implement UnitIndexStruct
        endstruct
        
        module DAMAGE_EVENT_MODIFICATION_GUI_GLOBALS
            static trigger damage
            static trigger life
            static trigger getLife
        endmodule
        module DAMAGE_EVENT_MODIFICATION_GUI
            private static method DDS_damage takes nothing returns boolean
                set DDS.damage = udg_DDS_damage
                return false
            endmethod
            private static method DDS_life takes nothing returns boolean
                call DisableTrigger(GUI.life)
                set udg_DDS_life = DDS.life
                call EnableTrigger(GUI.life)
                return false
            endmethod
            private static method DDS_getLife takes nothing returns boolean
                call DisableTrigger(GUI.getLife)
                set udg_DDS_getLife = GetUnitLife(R2I(udg_DDS_getLife + .5))
                call EnableTrigger(GUI.getLife)
                return false
            endmethod
            private static method DDS_initVariables takes nothing returns nothing
                set GUI.damage = CreateTrigger()
                call TriggerRegisterVariableEvent(GUI.damage, "udg_DDS_damage", NOT_EQUAL, 0.)
                call TriggerRegisterVariableEvent(GUI.damage, "udg_DDS_damage", EQUAL, 0.)
                call TriggerAddCondition(GUI.damage, Condition(function thistype.DDS_damage))
                
                set GUI.life = CreateTrigger()
                call TriggerRegisterVariableEvent(GUI.life, "udg_DDS_life", NOT_EQUAL, 0.)
                call TriggerRegisterVariableEvent(GUI.life, "udg_DDS_life", EQUAL, 0.)
                call TriggerAddCondition(GUI.life, Condition(function thistype.DDS_life))
                
                set GUI.getLife = CreateTrigger()
                call TriggerRegisterVariableEvent(GUI.getLife, "udg_DDS_getLife", GREATER_THAN, 0.)
                call TriggerAddCondition(GUI.getLife, Condition(function thistype.DDS_getLife))
            endmethod
            
            private static method onInit takes nothing returns nothing
                call DDS_initVariables()
            endmethod
        endmodule
    endscope
    //! endtextmacro
endlibrary