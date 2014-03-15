library Event /* v2.1.0.0
************************************************************************************
*
*   */ uses /*
*   
*       */ Trigger              /*
*       */ Init                 /*
*       */ TableField           /*
*
************************************************************************************
*
*       struct Event extends array
*
*           readonly trigger trigger
*               -   used to register events to the trigger contained in the event
*
*           static method create takes nothing returns Event
*           method destroy takes nothing returns nothing
*
*           method refresh takes nothing returns nothing
*               -   used to refresh events
*
*           method registerTrigger takes Trigger whichTrigger returns TriggerReference
*           method register takes boolexpr whichExpression returns TriggerCondition
*               -   user registration
*               -   see Trigger library for details on TriggerReference and TriggerCondition
*
*           method registerLibraryTrigger takes Trigger whichTrigger returns TriggerReference
*           method registerLibrary takes boolexpr whichExpression returns TriggerCondition
*               -   library registration (runs first)
*               -   see Trigger library for details on TriggerReference and TriggerCondition
*
*           method fire takes nothing returns nothing
*               -   fire the event
*
************************************************************************************/
    struct Event extends array
        //! runtextmacro CREATE_TABLE_FIELD("private", "integer", "eventLibrary", "Trigger")
        //! runtextmacro CREATE_TABLE_FIELD("private", "integer", "eventTrigger", "Trigger")
        
        static method create takes nothing returns thistype
            local thistype this = Trigger.create()
            
            set eventLibrary = Trigger.create()
            set eventTrigger = Trigger.create()
            
            call eventTrigger.reference(this)
            call Trigger(this).reference(eventLibrary)
            
            return this
        endmethod
        method destroy takes nothing returns nothing
            call eventLibrary.destroy()
            call eventTrigger.destroy()
            call Trigger(this).destroy()
        endmethod
        
        method operator trigger takes nothing returns trigger
            return Trigger(this).trigger
        endmethod
        
        method refresh takes nothing returns nothing
            call eventTrigger.destroy()
            set eventTrigger = Trigger.create()
            call eventTrigger.reference(this)
        endmethod
        
        method registerTrigger takes Trigger whichTrigger returns TriggerReference
            return Trigger(this).reference(whichTrigger)
        endmethod
        method register takes boolexpr whichExpression returns TriggerCondition
            return Trigger(this).register(whichExpression)
        endmethod
        
        method registerLibraryTrigger takes Trigger whichTrigger returns TriggerReference
            return eventLibrary.reference(whichTrigger)
        endmethod
        method registerLibrary takes boolexpr whichExpression returns TriggerCondition
            return eventLibrary.register(whichExpression)
        endmethod
        
        method fire takes nothing returns nothing
            call Trigger(this).fire()
        endmethod
        
        private static method init takes nothing returns nothing
            //! runtextmacro INITIALIZE_TABLE_FIELD("eventLibrary")
            //! runtextmacro INITIALIZE_TABLE_FIELD("eventTrigger")
        endmethod
        
        implement Init
    endstruct
endlibrary