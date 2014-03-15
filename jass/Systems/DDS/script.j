library DDS /* v1.0.2.0
*************************************************************************************
*
*   */uses/*
*
*       */ TriggerRefresh   /*      hiveworkshop.com/forums/submissions-414/trigger-refresh-systems-using-single-unit-events-like-dds-231167/
*
************************************************************************************
*
*   SETTINGS
*/
globals
    /*************************************************************************************
    *
    *   How many units can refresh at a given moment (when a trigger is rebuilt).
    *   larger size means less triggers but harder refreshes.
    *
    *************************************************************************************/
    private constant integer TRIGGER_SIZE = 80
    
    /*************************************************************************************
    *
    *   Enables an interface for GUI users
    *
    *************************************************************************************/
    private constant boolean ENABLE_GUI = false
endglobals
/*
*************************************************************************************
*
*   struct DDS extends array
*
*       Plugin properties
*
*   module DDS
*
*       Plugin interface
*       Plugin properties (from DDS struct)
*
*   Standard Methods (can be overwritten)
*
*       boolean enabled
*
*           - enables and disables the system for a given unit
*
*               DDS[unit index].enabled = true
*
*************************************************************************************/
    private keyword Trigger
    
    private keyword DAMAGE_EVENT_API
    private keyword DAMAGE_EVENT_MODIFICATION_API
    private keyword DAMAGE_EVENT_ARCHETYPE_API
    private keyword DAMAGE_EVENT_UNIT_MODIFICATION_API
    private keyword DAMAGE_EVENT_RESPONSE_LOCALS
    private keyword DAMAGE_EVENT_MODIFICATION_RESPONSE_LOCALS
    private keyword DAMAGE_EVENT_ARCHETYPE_RESPONSE_LOCALS
    private keyword DAMAGE_EVENT_UNIT_MODIFICATION_RESPONSE_LOCALS
    private keyword DAMAGE_EVENT_RESPONSE_BEFORE
    private keyword DAMAGE_EVENT_MODIFICATION_RESPONSE_BEFORE
    private keyword DAMAGE_EVENT_ARCHETYPE_RESPONSE_BEFORE
    private keyword DAMAGE_EVENT_UNIT_MODIFICATION_RESPONSE_BEFORE
    private keyword DAMAGE_EVENT_RESPONSE
    private keyword DAMAGE_EVENT_MODIFICATION_RESPONSE
    private keyword DAMAGE_EVENT_ARCHETYPE_RESPONSE
    private keyword DAMAGE_EVENT_UNIT_MODIFICATION_RESPONSE
    private keyword DAMAGE_EVENT_RESPONSE_AFTER
    private keyword DAMAGE_EVENT_MODIFICATION_RESPONSE_AFTER
    private keyword DAMAGE_EVENT_ARCHETYPE_RESPONSE_AFTER
    private keyword DAMAGE_EVENT_UNIT_MODIFICATION_RESPONSE_AFTER
    private keyword DAMAGE_EVENT_RESPONSE_CLEANUP
    private keyword DAMAGE_EVENT_MODIFICATION_RESPONSE_CLEANUP
    private keyword DAMAGE_EVENT_ARCHETYPE_RESPONSE_CLEANUP
    private keyword DAMAGE_EVENT_UNIT_MODIFICATION_RESPONSE_CLEANUP
    private keyword DAMAGE_EVENT_INTERFACE
    private keyword DAMAGE_EVENT_MODIFICATION_INTERFACE
    private keyword DAMAGE_EVENT_ARCHETYPE_INTERFACE
    private keyword DAMAGE_EVENT_UNIT_MODIFICATION_INTERFACE
    private keyword DAMAGE_EVENT_INIT
    private keyword DAMAGE_EVENT_MODIFICATION_INIT
    private keyword DAMAGE_EVENT_ARCHETYPE_INIT
    private keyword DAMAGE_EVENT_UNIT_MODIFICATION_INIT
    private keyword GUI

    //! runtextmacro optional DAMAGE_EVENT_CODE()
    //! runtextmacro optional DAMAGE_EVENT_MODIFICATION_CODE()
    //! runtextmacro optional DAMAGE_EVENT_ARCHETYPE_CODE()
    //! runtextmacro optional DAMAGE_EVENT_UNIT_MODIFICATION_CODE()
    
    private keyword DDS_onDamage
    struct DDS extends array
        method operator enabled takes nothing returns boolean
            return IsTriggerEnabled(Trigger(this).parent.trigger)
        endmethod
        static if not ENABLED_EXISTS then
            method operator enabled= takes boolean b returns nothing
                static if ENABLE_GUI then
                    set udg_DDS_enabled[this] = b
                    set udg_DDS_enable = 0
                endif
                
                if (b) then
                    call EnableTrigger(Trigger(this).parent.trigger)
                else
                    call DisableTrigger(Trigger(this).parent.trigger)
                endif
            endmethod
        else
            implement optional DAMAGE_EVENT_ENABLE
        endif
    
        implement optional DAMAGE_EVENT_API
        implement optional DAMAGE_EVENT_MODIFICATION_API
        implement optional DAMAGE_EVENT_ARCHETYPE_API
        implement optional DAMAGE_EVENT_UNIT_MODIFICATION_API
    
        static method DDS_onDamage takes nothing returns nothing
            implement optional DAMAGE_EVENT_RESPONSE_LOCALS
            implement optional DAMAGE_EVENT_MODIFICATION_RESPONSE_LOCALS
            implement optional DAMAGE_EVENT_ARCHETYPE_RESPONSE_LOCALS
            implement optional DAMAGE_EVENT_UNIT_MODIFICATION_RESPONSE_LOCALS
            
            implement optional DAMAGE_EVENT_RESPONSE_BEFORE
            implement optional DAMAGE_EVENT_MODIFICATION_RESPONSE_BEFORE
            implement optional DAMAGE_EVENT_ARCHETYPE_RESPONSE_BEFORE
            implement optional DAMAGE_EVENT_UNIT_MODIFICATION_RESPONSE_BEFORE
            
            implement optional DAMAGE_EVENT_RESPONSE
            implement optional DAMAGE_EVENT_MODIFICATION_RESPONSE
            implement optional DAMAGE_EVENT_ARCHETYPE_RESPONSE
            implement optional DAMAGE_EVENT_UNIT_MODIFICATION_RESPONSE
            
            implement optional DAMAGE_EVENT_RESPONSE_AFTER
            implement optional DAMAGE_EVENT_MODIFICATION_RESPONSE_AFTER
            implement optional DAMAGE_EVENT_ARCHETYPE_RESPONSE_AFTER
            implement optional DAMAGE_EVENT_UNIT_MODIFICATION_RESPONSE_AFTER
            
            implement optional DAMAGE_EVENT_RESPONSE_CLEANUP
            implement optional DAMAGE_EVENT_MODIFICATION_RESPONSE_CLEANUP
            implement optional DAMAGE_EVENT_ARCHETYPE_RESPONSE_CLEANUP
            implement optional DAMAGE_EVENT_UNIT_MODIFICATION_RESPONSE_CLEANUP
        endmethod
    endstruct
    
    module DDS
        private static delegate DDS dds = 0
        
        implement optional DAMAGE_EVENT_INTERFACE
        implement optional DAMAGE_EVENT_MODIFICATION_INTERFACE
        implement optional DAMAGE_EVENT_ARCHETYPE_INTERFACE
        implement optional DAMAGE_EVENT_UNIT_MODIFICATION_INTERFACE
    endmodule

    //! runtextmacro TRIGGER_REFRESH("TRIGGER_SIZE", "EVENT_UNIT_DAMAGED", "function DDS.DDS_onDamage")
    
    private keyword DDS_initGUI
    private module DDS_Init_Module
        private static method onInit takes nothing returns nothing
            implement optional DAMAGE_EVENT_INIT
            implement optional DAMAGE_EVENT_MODIFICATION_INIT
            implement optional DAMAGE_EVENT_ARCHETYPE_INIT
            implement optional DAMAGE_EVENT_UNIT_MODIFICATION_INIT
        endmethod
    endmodule
    private struct DDS_Init extends array
        implement DDS_Init_Module
    endstruct
    
    /*
    *   GUI
    */
    static if ENABLE_GUI then
        struct GUI extends array
            public static trigger DDS_enable
        
            implement optional DAMAGE_EVENT_GUI_GLOBALS
            implement optional DAMAGE_EVENT_MODIFICATION_GUI_GLOBALS
            implement optional DAMAGE_EVENT_ARCHETYPE_GUI_GLOBALS
            implement optional DAMAGE_EVENT_UNIT_MODIFICATION_GUI_GLOBALS
        endstruct
    
        scope DDSGUI
            private module GUI_INIT
                private static method onInit takes nothing returns nothing
                    call init()
                endmethod
            endmodule
            private struct DDSGUI extends array
                private static method DDS_enableGUI takes nothing returns boolean
                    set DDS[R2I(RAbsBJ(udg_DDS_enable) + .5)].enabled = udg_DDS_enable > 0
                    return false
                endmethod
                private static method DDS_initVariables takes nothing returns nothing
                    set GUI.DDS_enable = CreateTrigger()
                    call TriggerRegisterVariableEvent(GUI.DDS_enable, "udg_DDS_enable", NOT_EQUAL, 0)
                    call TriggerAddCondition(GUI.DDS_enable, Condition(function thistype.DDS_enableGUI))
                endmethod
                private static method DDS_initEnable takes nothing returns nothing
                    local integer i = 8191
                    loop
                        exitwhen 0 == i
                        
                        set udg_DDS_enabled[i] = true
                        
                        set i = i - 1
                    endloop
                endmethod
                
                private static method init takes nothing returns nothing
                    call DDS_initVariables()
                    call DDS_initEnable()
                endmethod
                
                implement GUI_INIT
            endstruct
        endscope
        
        scope DEGUI
            private struct DEGUI extends array
                implement optional DAMAGE_EVENT_GUI
            endstruct
        endscope
        
        scope DMGUI
            private struct DMGUI extends array
                implement optional DAMAGE_EVENT_MODIFICATION_GUI
            endstruct
        endscope
        
        scope DAGUI
            private struct DAGUI extends array
                implement optional DAMAGE_EVENT_ARCHETYPE_GUI
            endstruct
        endscope
        
        scope DUGUI
            private struct DUGUI extends array
                implement optional DAMAGE_EVENT_UNIT_MODIFICATION_GUI
            endstruct
        endscope
    endif
endlibrary