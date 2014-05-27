library TriggerRefresh /* v1.0.3.0
*************************************************************************************
*
*   Optimal trigger refreshing for unit events. Used in such things as Damage Detection
*   Systems.
*
*   Events are never destroyed. When a unit event is registered to a trigger and that
*   unit no longer exists, the event remains. The trigger has to be recreated in order
*   to clean the leak. This resource recreates triggers in the most optimal manner possible.
*
*   Used in DamageEvent and recommended for all Damage Detection Systems.
*
*   Place the macros in order at the bottom of the DDS Library.
*
*************************************************************************************
*
*   */uses/*
*
*       */ UnitIndexer      /*      hiveworkshop.com/forums/jass-functions-413/unit-indexer-172090/
*       All Requirements of Unit Indexer are not needed as they are included with Trigger Refresh
*
*************************************************************************************
*
*   //! textmacro TRIGGER_REFRESH takes TRIGGER_SIZE, TRIGGER_EVENT, CODE
*
*       This macro creates the refreshing trigger. 
*
*           TRIGGER_SIZE
*               How many units to register to a given trigger. More units = less refreshes, but
*               more fps spikes. A value of 80 is recommended.
*
*           TRIGGER_EVENT
*               The event to register to the trigger. Example: EVENT_UNIT_DAMAGED.
*
*           CODE
*               Registers code to the trigger. Only 1 function may be registered to the trigger.
*
*   private keyword Trigger
*   Trigger(UnitIndex).parent.trigger
*       -   enable/disable trigger for specific unit
*
*************************************************************************************
*
*   //quick and dirty DDS
*   library MyDDS
*       private function Core takes nothing returns nothing
*           //will display whenever a unit is damaged
*           call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,R2S(GetEventDamage()))
*       endfunction
*
*       //! runtextmacro TRIGGER_REFRESH("80", "EVENT_UNIT_DAMAGED", "function Core")
*   endlibrary
*
*************************************************************************************/
endlibrary

//! textmacro TRIGGER_REFRESH takes TRIGGER_SIZE, TRIGGER_EVENT, CODE
    scope TriggerRefresh
        globals
            private boolexpr condition
        endglobals
        
        struct Trigger extends array
            private static integer instanceCount = 0
        
            private thistype first
            private thistype next
            private thistype prev
            readonly thistype parent
            
            private integer inactiveUnits
            readonly integer activeUnits
            
            readonly trigger trigger
            
            private method registerUnit takes UnitIndex whichUnit returns boolean
                if (activeUnits < $TRIGGER_SIZE$) then
                    call TriggerRegisterUnitEvent(trigger, whichUnit.unit, $TRIGGER_EVENT$)
                    set activeUnits = activeUnits + 1
                    
                    return true
                endif
                
                return false
            endmethod
            private method unregisterUnit takes nothing returns nothing
                set inactiveUnits = inactiveUnits + 1
                set activeUnits = activeUnits - 1
            endmethod
            
            private method createTrigger takes nothing returns nothing
                set trigger = CreateTrigger()
                call TriggerAddCondition(trigger, condition)
            endmethod
            private method remakeTrigger takes nothing returns nothing
                call DestroyTrigger(trigger)
                call createTrigger()
            endmethod
            private method rebuildTrigger takes nothing returns nothing
                local thistype current = first
                
                call remakeTrigger()
                
                /*
                *   Iterate over all units registered to the trigger and reregister them
                */
                set current.prev.next = 0
                loop
                    exitwhen 0 == current
                    call TriggerRegisterUnitEvent(trigger, UnitIndex(current).unit, $TRIGGER_EVENT$)
                    set current = current.next
                endloop
                set first.prev.next = current
            endmethod
            
            private method remake takes nothing returns nothing
                if (inactiveUnits == $TRIGGER_SIZE$) then
                    set inactiveUnits = 0
                    call rebuildTrigger()
                endif
            endmethod
            
            private method addToList takes thistype whichUnit returns nothing
                set whichUnit.parent = this
            
                if (0 == first) then
                    set first = whichUnit
                    set whichUnit.next = whichUnit
                    set whichUnit.prev = whichUnit
                else
                    set this = first
                    
                    set whichUnit.prev = prev
                    set whichUnit.next = this
                    set prev.next = whichUnit
                    set prev = whichUnit
                endif
            endmethod
            method add takes thistype whichUnit returns boolean
                if (0 == this) then
                    return false
                endif
            
                if (registerUnit(whichUnit)) then
                    call addToList(whichUnit)
                    
                    return true
                endif
                
                return false
            endmethod
            
            private method removeFromList takes thistype whichUnit returns nothing
                set whichUnit.parent = 0
            
                set whichUnit.prev.next = whichUnit.next
                set whichUnit.next.prev = whichUnit.prev
                
                if (first == whichUnit) then
                    set first = whichUnit.next
                    if (first == whichUnit) then
                        set first = 0
                    endif
                endif
            endmethod
            static method remove takes thistype whichUnit returns nothing
                local thistype this = whichUnit.parent
            
                call removeFromList(whichUnit)
                call unregisterUnit()
                call remake()
            endmethod
            
            private static method allocate takes nothing returns thistype
                set instanceCount = instanceCount + 1
                return instanceCount
            endmethod
            static method create takes nothing returns thistype
                local thistype this = allocate()
                
                call createTrigger()
                
                return this
            endmethod
        endstruct
        
        private struct TriggerHeapInner extends array
            readonly static integer size = 0
            readonly thistype node
            readonly thistype heap
            
            public method bubbleUp takes nothing returns nothing
                local integer activeUnits = Trigger(this).activeUnits
                local thistype heapPosition = heap
                
                local thistype parent
                
                /*
                *   Bubble node up
                */
                loop
                    set parent = heapPosition/2
                    
                    if (integer(parent) != 0 and activeUnits < Trigger(parent.node).activeUnits) then
                        set heapPosition.node = parent.node
                        set heapPosition.node.heap = heapPosition
                    else
                        exitwhen true
                    endif
                    
                    set heapPosition = parent
                endloop
                
                /*
                *   Update pointers
                */
                set heapPosition.node = this
                set heap = heapPosition
            endmethod
            public method bubbleDown takes nothing returns nothing
                local integer activeUnits = Trigger(this).activeUnits
                local thistype heapPosition = heap
                
                local thistype left
                local thistype right
                
                /*
                *   Bubble node down
                */
                loop
                    set left = heapPosition*2
                    set right = left + 1
                    
                    if (Trigger(left.node).activeUnits < activeUnits and Trigger(left.node).activeUnits < Trigger(right.node).activeUnits) then
                        /*
                        *   Go left
                        */
                        set heapPosition.node = left.node
                        set heapPosition.node.heap = heapPosition
                        set heapPosition = left
                    elseif (Trigger(right.node).activeUnits < activeUnits) then
                        /*
                        *   Go right
                        */
                        set heapPosition.node = right.node
                        set heapPosition.node.heap = heapPosition
                        set heapPosition = right
                    else
                        exitwhen true
                    endif
                endloop
                
                /*
                *   Update pointers
                */
                set heapPosition.node = this
                set heap = heapPosition
            endmethod
            
            static method insert takes thistype this returns nothing
                /*
                *   Increase heap size
                */
                set size = size + 1
                
                /*
                *   Store node in last heap position
                */
                set thistype(size).node = this
                set heap = size
                
                /*
                *   Bubble node into correct position
                */
                call bubbleUp()
            endmethod
        endstruct
        
        private struct TriggerHeap extends array
            static method add takes UnitIndex whichUnit returns nothing
                local Trigger trig = TriggerHeapInner(1).node
                
                if (not trig.add(whichUnit)) then
                    set trig = Trigger.create()
                    call trig .add(whichUnit)
                    call TriggerHeapInner.insert(trig)
                else
                    call TriggerHeapInner(trig).bubbleDown()
                endif
            endmethod
            static method remove takes UnitIndex whichUnit returns nothing
                local Trigger trig = Trigger(whichUnit).parent
                call Trigger.remove(whichUnit)
                call TriggerHeapInner(trig).bubbleUp()
            endmethod
        endstruct
        
        private module TriggerRefreshInitModule
            private static method onInit takes nothing returns nothing
                call init($CODE$)
            endmethod
        endmodule
        
        private struct TriggerRefreshInit extends array
            private static method onIndex takes nothing returns boolean
                call TriggerHeap.add(UnitIndexer.eventIndex)
                
                return false
            endmethod
            
            private static method onDeindex takes nothing returns boolean
                call TriggerHeap.remove(UnitIndexer.eventIndex)
            
                return false
            endmethod
        
            private static method init takes code c returns nothing
                set condition = Condition(c)
                
				call UnitIndexer.GlobalEvent.ON_INDEX.register(Condition(function thistype.onIndex))
				call UnitIndexer.GlobalEvent.ON_DEINDEX.register(Condition(function thistype.onDeindex))
            endmethod
            
            implement TriggerRefreshInitModule
        endstruct
    endscope
//! endtextmacro