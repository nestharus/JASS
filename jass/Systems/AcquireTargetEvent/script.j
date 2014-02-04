library AcquireTargetEvent /* v1.0.0.0
*************************************************************************************
*
*   Allows easy EVENT_UNIT_ACQUIRE_TARGET events.
*
*************************************************************************************
*
*   */uses/*
*
*       */ UnitIndexer      /*      hiveworkshop.com/forums/jass-functions-413/unit-indexer-172090/
*       */ Event            /*      hiveworkshop.com/forums/jass-resources-412/snippet-event-186555/
*       */ BinaryHeap       /*      hiveworkshop.com/forums/jass-resources-412/snippet-binary-heap-199353/
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
endglobals
/*
*************************************************************************************
*
*   struct AcquireTargetEvent extends array
*
*       static boolean enabled
*
*       readonly static Event ANY
*
*       readonly static unit target
*       readonly static unit source
*       readonly static UnitIndex targetId
*       readonly static UnitIndex sourceId
*
*************************************************************************************/
    private struct AcquireTargetEventProperties extends array
        static method operator target takes nothing returns unit
            return GetUnitById(AcquireTargetEvent.targetId)
        endmethod
        static method operator source takes nothing returns unit
            return GetUnitById(AcquireTargetEvent.sourceId)
        endmethod
    endstruct
    
    globals
        private boolexpr acquireTargetCondition
    endglobals
    
    private struct AcquireTargetTrigger extends array
        private static integer instanceCount = 0
    
        private thistype first
        private thistype next
        private thistype prev
        readonly thistype parent
        
        private integer inactiveUnits
        readonly integer activeUnits
        
        private trigger acquireTargetTrigger
        
        private method registerUnit takes UnitIndex whichUnit returns boolean
            if (activeUnits < TRIGGER_SIZE) then
                call TriggerRegisterUnitEvent(acquireTargetTrigger, GetUnitById(whichUnit), EVENT_UNIT_ACQUIRED_TARGET)
                set activeUnits = activeUnits + 1
                
                return true
            endif
            
            return false
        endmethod
        private method unregisterUnit takes UnitIndex whichUnit returns nothing
            set inactiveUnits = inactiveUnits + 1
            set activeUnits = activeUnits - 1
        endmethod
        
        private method createTrigger takes nothing returns nothing
            set acquireTargetTrigger = CreateTrigger()
            call TriggerAddCondition(acquireTargetTrigger, acquireTargetCondition)
        endmethod
        private method remakeTrigger takes nothing returns nothing
            call DestroyTrigger(acquireTargetTrigger)
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
                call TriggerRegisterUnitEvent(acquireTargetTrigger, GetUnitById(current), EVENT_UNIT_ACQUIRED_TARGET)
                set current = current.next
            endloop
            set first.prev.next = current
        endmethod
        
        private method remake takes nothing returns nothing
            if (inactiveUnits == TRIGGER_SIZE) then
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
            call unregisterUnit(whichUnit)
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
    
    private struct AcquireTargetTriggerHeapInner extends array
        private static method compare takes AcquireTargetTrigger trig1, AcquireTargetTrigger trig2 returns boolean
            return trig1.activeUnits <= trig2.activeUnits
        endmethod
        implement BinaryHeap
    endstruct
    
    private struct AcquireTargetTriggerHeap extends array
        private static AcquireTargetTriggerHeapInner array parent
        
        static method add takes UnitIndex whichUnit returns nothing
            local AcquireTargetTrigger acquireTargetTrigger = AcquireTargetTriggerHeapInner.root.value
            
            if (not acquireTargetTrigger.add(whichUnit)) then
                set acquireTargetTrigger = AcquireTargetTrigger.create()
                call acquireTargetTrigger.add(whichUnit)
                set parent[acquireTargetTrigger] = AcquireTargetTriggerHeapInner.insert(acquireTargetTrigger)
            else
                call parent[acquireTargetTrigger].modify(acquireTargetTrigger)
            endif
        endmethod
        static method remove takes UnitIndex whichUnit returns nothing
            local AcquireTargetTrigger acquireTargetTrigger = AcquireTargetTrigger(whichUnit).parent
            call AcquireTargetTrigger.remove(whichUnit)
            call parent[acquireTargetTrigger].modify(acquireTargetTrigger)
        endmethod
    endstruct
    
    private module AcquireTargetEventMod
        readonly static Event ANY
        readonly static UnitIndex targetId
        readonly static UnitIndex sourceId
        static boolean enabled
        
        private static delegate AcquireTargetEventProperties acquireTargetEventProperties = 0
        
        private static method acquireTarget takes nothing returns boolean
            local integer previousTargetId
            local integer previousSourceId
            
            if (enabled) then
                /*
                *   Store previous amounts
                */
                set previousTargetId = targetId
                set previousSourceId = sourceId
                
                /*
                *   Update amounts to new amounts
                */
                set targetId = GetUnitUserData(GetEventTargetUnit())
                set sourceId = GetUnitUserData(GetTriggerUnit())
                
                /*
                *   Fire event
                */
                call ANY.fire()
                
                /*
                *   Restore previous amounts
                */
                set targetId = previousTargetId
                set sourceId = previousSourceId
            endif
            
            return false
        endmethod
        private static method index takes nothing returns boolean
            call UnitIndex(GetIndexedUnitId()).lock()
            call AcquireTargetTriggerHeap.add(GetIndexedUnitId())
            return false
        endmethod
        private static method deindex takes nothing returns boolean
            call AcquireTargetTriggerHeap.remove(GetIndexedUnitId())
            call UnitIndex(GetIndexedUnitId()).unlock()
            return false
        endmethod
        
        private static method onInit takes nothing returns nothing
            set enabled = true
            
            set ANY = Event.create()
            
            call RegisterUnitIndexEvent(Condition(function thistype.index), UnitIndexer.INDEX)
            call RegisterUnitIndexEvent(Condition(function thistype.deindex), UnitIndexer.DEINDEX)
            
            set acquireTargetCondition = Condition(function thistype.acquireTarget)
            
            set targetId = 0
            set sourceId = 0
        endmethod
    endmodule
    
    struct AcquireTargetEvent extends array
        implement AcquireTargetEventMod
    endstruct
endlibrary