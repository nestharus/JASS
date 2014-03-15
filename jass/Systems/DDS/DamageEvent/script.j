library DamageEvent /* v1.0.1.0
*************************************************************************************
*
*   Damage Event plugin for DDS
*
*************************************************************************************
*
*   */uses/*
*
*       */ DDS                      /*      hiveworkshop.com/forums/spells-569/framework-dds-damage-detection-system-231238/
*
*       This is only required if GUI is being used with PriorityEvent
*       */ optional AVL             /*
*
*       */ optional PriorityEvent   /*      hiveworkshop.com/forums/jass-resources-412/snippet-priority-event-213573/
*
*************************************************************************************
*
*   API
*
*       readonly static PriorityEvent ANY
*       readonly static Event ANY
*           -   the PriorityEvent version is used if PriorityEvent library in map
*           -   run whenever a unit is damaged
*
*       readony static real damage
*           -   amount of damage dealt
*
*       readonly static unit target
*       readonly static UnitIndex targetId
*           -   damaged unit
*
*       readonly static unit source
*       readonly static UnitIndex sourceId
*           -   unit that dealt damage
*
*       readonly static player sourcePlayer
*           -   owner of source
*
*************************************************************************************
*
*   Interface
*
*       (optional) private static constant integer PRIORITY                          defaults 0
*           -   only used if PriorityEvent library is in map
*           -   range is -2147483648 to 2147483647
*           -   the higher the priority, the earlier the module runs compared to other modules
*
*       (optional) private static method onDamage takes nothing returns nothing     defaults nothing
*           -   is run whenever a unit is damaged
*
*************************************************************************************
*
*   Plugin Information (can only be used by other plugins)
*
*       static UnitIndex targetId_p
*       static UnitIndex sourceId_p
*
*       static real damage_p
*
*       static player sourcePlayer_p
*
*************************************************************************************/
    //! textmacro DAMAGE_EVENT_CODE
    private keyword damage_p
    private keyword targetId_p
    private keyword sourceId_p
    private keyword sourcePlayer_p
    scope DamageEvent
        /*
        *   DDS API
        *
        *       DDS.ANY
        *       DDS.target
        *       DDS.source
        *       DDS.amount
        *
        */
        private keyword damageEventInit
        
        module DAMAGE_EVENT_API
            static if LIBRARY_PriorityEvent then
                readonly static PriorityEvent ANY
            else
                readonly static Event ANY
            endif
            
            static UnitIndex targetId_p = 0
            static UnitIndex sourceId_p = 0
            static real damage_p = 0
            static player sourcePlayer_p = null
            
            static method operator targetId takes nothing returns UnitIndex
                return targetId_p
            endmethod
            static method operator target takes nothing returns unit
                return targetId.unit
            endmethod
            
            static method operator sourceId takes nothing returns UnitIndex
                return sourceId_p
            endmethod
            static method operator source takes nothing returns unit
                return sourceId.unit
            endmethod
            
            static method operator damage takes nothing returns real
                return damage_p
            endmethod
            
            static method operator sourcePlayer takes nothing returns player
                return sourcePlayer_p
            endmethod
            
            static method damageEventInit takes nothing returns nothing
                static if LIBRARY_PriorityEvent then
                    set ANY = PriorityEvent.create()
                else
                    set ANY = Event.create()
                endif
            endmethod
        endmodule
        module DAMAGE_EVENT_INIT
            call DDS.damageEventInit()
        endmodule

        /*
        *   DDS Interface
        *
        *       (optional) private static constant ineger PRIORITY          defaults 0
        *       (optional) private static method onDamage takes nothing     defaults nothing
        *
        *       
        */
        static if LIBRARY_PriorityEvent then
            private struct DamageEventPriority extends array
                readonly static constant integer PRIORITY = 0
            endstruct
        endif
        module DAMAGE_EVENT_INTERFACE
            static if LIBRARY_PriorityEvent then
                private static delegate DamageEventPriority priority = 0
            endif
            
            static if thistype.onDamage.exists then
                private static method init takes code c returns nothing
                    static if LIBRARY_PriorityEvent then
                        call ANY.register(Condition(c), PRIORITY)
                    else
                        call ANY.register(Condition(c))
                    endif
                    return
                endmethod

                private static method onInit takes nothing returns nothing
                    call init(function thistype.onDamage)
                endmethod
            endif
        endmodule

        /*
        *   DDS Event Handling
        */
module DAMAGE_EVENT_RESPONSE_LOCALS
                local UnitIndex prevTarget = targetId_p
                local UnitIndex prevSource = sourceId_p
                
                local real prevDamage = damage_p
endmodule
module DAMAGE_EVENT_RESPONSE_BEFORE
                if (0 == GetEventDamage()) then
                    return
                endif
                
                set targetId_p = GetUnitUserData(GetTriggerUnit())
                set sourceId_p = GetUnitUserData(GetEventDamageSource())
                set damage_p = GetEventDamage()
                set sourcePlayer_p = GetOwningPlayer(sourceId_p.unit)
                static if ENABLE_GUI then
                    set udg_DDS_damage = damage_p
                    set udg_DDS_target = GetTriggerUnit()
                    set udg_DDS_source = GetEventDamageSource()
                    set udg_DDS_targetId = targetId_p
                    set udg_DDS_sourceId = sourceId_p
                    set udg_DDS_sourcePlayer = sourcePlayer_p
                endif
endmodule
module DAMAGE_EVENT_RESPONSE
                call ANY.fire()
                static if ENABLE_GUI then
                    static if not LIBRARY_PriorityEvent then
                        set udg_DDS_event = 1
                        set udg_DDS_event = 0
                    endif
                endif
endmodule
module DAMAGE_EVENT_RESPONSE_AFTER
                
endmodule
module DAMAGE_EVENT_RESPONSE_CLEANUP
                set targetId_p = prevTarget
                set sourceId_p = prevSource
                set damage_p = prevDamage
                set sourcePlayer_p = GetOwningPlayer(sourceId_p.unit)
                static if ENABLE_GUI then
                    set udg_DDS_damage = damage_p
                    set udg_DDS_target = GetUnitById(targetId_p)
                    set udg_DDS_source = GetUnitById(sourceId_p)
                    set udg_DDS_targetId = targetId_p
                    set udg_DDS_sourceId = sourceId_p
                    set udg_DDS_sourcePlayer = sourcePlayer_p
                endif
endmodule

        static if LIBRARY_PriorityEvent then
            static if ENABLE_GUI then
                private struct GUI_Priorities extends array
                    method lessThan takes thistype value returns boolean
                        return integer(this) < integer(value)
                    endmethod
                    
                    method greaterThan takes thistype value returns boolean
                        return integer(this) > integer(value)
                    endmethod
                    
                    implement AVL
                endstruct
                module DAMAGE_EVENT_GUI_GLOBALS
                    static trigger eventRegister
                endmodule
                module DAMAGE_EVENT_GUI
                    private static GUI_Priorities array stack
                    private static integer stackSize = 0
                    private static GUI_Priorities priority
                    private static method onEvent takes nothing returns boolean
                        set udg_DDS_event = stack[stackSize].value
                        
                        set stack[stackSize] = stack[stackSize].prev
                        
                        if (stack[stackSize].head) then
                            set stackSize = stackSize - 1
                        endif
                    
                        return false
                    endmethod
                    private static method onEventStart takes nothing returns boolean
                        set stackSize = stackSize + 1
                        set stack[stackSize] = priority.prev
                        
                        return false
                    endmethod
                    private static method DDS_eventRegister takes nothing returns boolean
                        local integer priority
                        
                        if (udg_DDS_eventRegister < 0) then
                            set priority = R2I(udg_DDS_eventRegister - .5)
                        else
                            set priority = R2I(udg_DDS_eventRegister + .5)
                        endif
                        
                        call thistype.priority.add(priority)
                        call DDS.ANY.register(Condition(function thistype.onEvent), priority)
                        
                        return false
                    endmethod
                    private static method DDS_initVariables takes nothing returns nothing
                        set GUI.eventRegister = CreateTrigger()
                        call TriggerRegisterVariableEvent(GUI.eventRegister, "udg_DDS_eventRegister", LESS_THAN, 0)
                        call TriggerRegisterVariableEvent(GUI.eventRegister, "udg_DDS_eventRegister", GREATER_THAN, 1)
                        call TriggerAddCondition(GUI.eventRegister, Condition(function thistype.DDS_eventRegister))
                    endmethod
                    
                    private static method onInit takes nothing returns nothing
                        call DDS_initVariables()
                        
                        set priority = GUI_Priorities.create()
                        
                        call priority.add(-1)
                        call priority.add(0)
                        call priority.add(1)
                        
                        call DDS.ANY.register(Condition(function thistype.onEventStart), 2147483647)
                        call DDS.ANY.register(Condition(function thistype.onEvent), -1)
                        call DDS.ANY.register(Condition(function thistype.onEvent), 0)
                        call DDS.ANY.register(Condition(function thistype.onEvent), 1)
                    endmethod
                endmodule
            endif
        endif
    endscope
    //! endtextmacro
endlibrary