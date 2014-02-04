library TimerPool /* v1.0.0.3
*************************************************************************************
*
*   Allocation/Deallocation of timers that can reference data.
*
*************************************************************************************
*
*   */uses/*
*
*       */ ErrorMessage /*   [url]http://www.hiveworkshop.com/forums/jass-resources-412/snippet-error-message-239210/[/url]
*
************************************************************************************
*
*    SETTINGS
*/
globals
    /*************************************************************************************
    *
    *                    TIMER_COUNT
    *
    *    How many timers to run the system on.
    *
    *************************************************************************************/
    private constant integer TIMER_COUNT =                  2048
endglobals
/*
************************************************************************************
*
*    struct TimerPointer extends array
*
*       Creators/Destructors
*       -----------------------
*
*           static method create takes nothing returns TimerPointer
*           method destroy takes nothing returns nothing
*
*       Fields
*       -----------------------
*
*           readonly timer timer
*           integer count
*
*       Methods
*       -----------------------
*
*           method register takes boolexpr callback returns triggercondition
*           method unregister takes triggercondition whichTriggerCondition returns nothing
*
*    struct TimerPool extends array
*
*       static method operator [] takes timer whichTimer returns TimerPointer
*
************************************************************************************/
    globals
        /*
        *   First timer handle id
        */
        private integer OFFSET
        
        private timer array timers_p     //timer instances
        private trigger array onExpire_p //timer.trigger
        private integer array count_p
        
        private integer array recycler
    endglobals

    private module Init
        private static method onInit takes nothing returns nothing
            call init()
        endmethod
    endmodule
    
    struct TimerPointer extends array
        method operator timer takes nothing returns timer
            return timers_p[this]
        endmethod
        method operator trigger takes nothing returns trigger
            return onExpire_p[this]
        endmethod
        method operator count takes nothing returns integer
            return count_p[this]
        endmethod
        
        private method operator timer= takes timer v returns nothing
            set timers_p[this] = v
        endmethod
        private method operator trigger= takes trigger v returns nothing
            set onExpire_p[this] = v
        endmethod
        method operator count= takes integer v returns nothing
            set count_p[this] = v
        endmethod
    
        method register takes boolexpr onExpire returns triggercondition
            if (onExpire == null) then
                return null
            endif
            
            return TriggerAddCondition(trigger, onExpire)
        endmethod
        
        method unregister takes triggercondition tc returns nothing
            debug call ThrowError(0 == count, "TimerPool", "unregister", "TimerPointer", this, "Attempted to unregister from empty timer.")
            
            if (tc == null) then
                return
            endif
            
            call TriggerRemoveCondition(trigger, tc)
        endmethod
        
        static method create takes nothing returns thistype
            local thistype this = recycler[0]
            
            debug call ThrowError(this == 0, "TimerPool", "create", "TimerPointer", 0, "Overflow.")
            
            set recycler[0] = recycler[this]
            
            debug set recycler[this] = -1
            
            debug call ThrowError(timer == null or trigger == null, "TimerPool", "create", "TimerPointer", this, "Initialization Crashed. Try lowering number of timers.")
            
            return this
        endmethod
        
        method destroy takes nothing returns nothing
            debug call ThrowError(recycler[this] != -1, "TimerPool", "destroy", "TimerPointer", this, "Attempted to destroy null timer.")
            
            call PauseTimer(timer)
            
            set recycler[this] = recycler[0]
            set recycler[0] = this
        endmethod
        
        /*
        *   Create all timers that the system will use and associate them with triggers
        */
        private static method init takes nothing returns nothing
            local integer i = 2
            
            set recycler[0] = 1
            
            set thistype(1).timer = CreateTimer()
            set recycler[1] = 2
            set OFFSET = GetHandleId(thistype(1).timer) - 1
            
            /*
            *   Create timers and triggers independently due to offset
            */
            loop
                set thistype(i).timer = CreateTimer()
                
                set recycler[i] = i + 1
                
                exitwhen TIMER_COUNT == i
                set i = i + 1
            endloop
            
            set recycler[TIMER_COUNT] = 0
            
            set i = TIMER_COUNT
            loop
                
                set thistype(i).trigger = CreateTrigger()
                exitwhen 1 == i
                set i = i - 1
            endloop
        endmethod

        implement Init
    endstruct

    struct TimerPool extends array
        static method operator [] takes timer t returns TimerPointer
            return GetHandleId(t) - OFFSET
        endmethod
    endstruct
endlibrary