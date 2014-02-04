library Dummy /* v1.0.0.5
*************************************************************************************
*
*   Allows one to create dummy units that are either at or are close
*   to the angle specified.
*
*   Dummy recycling minimizes the number of dummy units on the map while supporting near
*   instant SetUnitFacing.
*
*   Assigned dummy indexes are unit indexes.
*
*       Errors
*       ----------------------------
*
*           Any error will result in the system disabling itself and an error message
*
*           ->  May not kill dummies
*           ->  May not remove dummies
*           ->  May not attempt to recycle non dummies
*
*************************************************************************************
*
*   Credits
*
*       Vexorian for dummy.mdx
*
*       Bribe
*
*           Delayed recycling implemetation
*           ----------------------------
*
*               Bribe's delayed recycling implementation uses timestamps rather than timers, which
*               helps improve performance.
*
*           Stamps for queue node movement
*           ----------------------------
*
*               Convinced me that this was worth it
*
*           Time it takes to rotate 180 degrees
*           ----------------------------
*
*               Supplied me with the number .73
*
*************************************************************************************
*
*   */ uses /*
*
*       /* Any Unit Indexer */
*       */ UnitIndexer /*           can be any, but one must be chosen
*
************************************************************************************
*
*   SETTINGS
*
*/
globals
    /*
    *   The unit id of dummy.mdx
    */
    private constant integer DUMMY_ID = 'n000'
    
    /*
    *   The space between angles for the recycler
    *
    *   Angles used are angles from 0 to 359 in intervals of ANGLE_SPACING
    *
    *   Higher spacing means less units but lower accuracy when creating the facing
    *
    */
    private constant integer ANGLE_SPACING = 15
    
    /*
    *   How many projectiles to preload per angle
    *
    *   Preloaded projectile count is 360/ANGLE_SPACING*MAX_PROJECTILES
    *
    */
    private constant integer PRELOAD_PROJECTILES_PER_ANGLE = 1//50
    
    /*
    *   How much to delay before recycling dummy
    */
    private constant real RECYCLE_DELAY = 2
endglobals
/*
************************************************************************************
*
*   library MissileRecycler uses Dummy
*   ----------------------------
*
*       For compatibility with Bribe's resource
*
*       function GetRecycledMissile takes real x, real y, real z, real facing returns unit
*       function RecycleMissile takes unit whichUnit returns nothing
*
************************************************************************************
*
*   Functions
*   ----------------------------
*
*       function IsUnitDummy takes unit whichUnit returns boolean
*
************************************************************************************
*
*
*   struct Dummy extends array
*
*       Creators/Destructors
*       ----------------------------
*
*           static method create takes real x, real y, real facing returns Dummy
*               -   For those of you who really want this to return a unit, getting
*               -   the unit from this is very easy, so don't whine
*
*               -   Dummy.create().unit -> unit
*
*           method destroy takes nothing returns nothing
*               -   For those of you who really want this to take a unit, getting
*               -   the dummy index is very easy.
*
*               -   Dummy[whichUnit].destroy()
*
*       Fields
*       ----------------------------
*
*           readonly unit unit
*
*       Operators
*       ----------------------------
*
*           static method operator [] takes unit dummyUnit returns Dummy
*
************************************************************************************/
    private keyword Queue
    
    globals
        /*
        *   Used for dummy instancing
        *   Dummy indexes are never destroyed, so there is no need for a recycler
        */
        private Queue dummyCount = 0
        
        /*
        *   Used to retrieve unit handle via dummy index
        */
        private unit array dummies
        private integer array indexPointer
        private integer array dummyPointer
        
        /*
        *   The owner of all dummy units. This shouldn't be changed.
        */
        private constant player DUMMY_OWNER = Player(15)
        
        /*
        *   Used to apply time stamps to dummies for recycling
        *   purposes. A dummy is only considered recycled if its
        *   stamp is less than the elapsed time of stamp timer.
        */
        private timer stampTimer
    endglobals
    
    function IsUnitDummy takes unit whichUnit returns boolean
        return dummies[GetUnitUserData(whichUnit)] == whichUnit
    endfunction
    
    /*
    *   min == max - 1
    *   max == min + 1
    *
    *   variance of counts must be 1
    */
    private struct ArrayStack extends array
        /*
        *   The minimum and maximum counts
        */
        static thistype max = 0
        static thistype min = 0
        
        /*
        *   list[count].first
        */
        thistype first
        
        /*
        *   queue.size
        */
        thistype count_p
        
        /*
        *   list[count].next
        */
        thistype next
        
        /*
        *   list[count].prev
        */
        thistype prev
        
        /*
        *   list[count].first -> queue of dummies
        */
        static method operator [] takes thistype index returns thistype
            return index.first
        endmethod
        
        /*
        *   list[count].add(queue of dummies)
        */
        private method add takes thistype node returns nothing
            /*
            *   Update min/max
            */
            if (integer(this) > integer(max)) then
                set max = this
            elseif (integer(this) < integer(min)) then
                set min = this
            endif
            
            /*
            *   Push on to front of list like a stack
            */
            set node.next = first
            set node.next.prev = node
            set node.prev = 0
            set first = node
            
            set node.count_p = this
        endmethod
        
        /*
        *   list[count].remove(list of dummies)
        */
        private method remove takes thistype node returns nothing
            /*
            *   If node is the first, update the first
            */
            if (node == first) then
                set first = node.next
                
                /*
                *   If list is empty, update min/max
                */
                if (0 == first) then
                    if (this == min) then
                        set min = max
                    else
                        set max = min
                    endif
                endif
            else
                /*
                *   Simple removal
                */
                set node.prev.next = node.next
                set node.next.prev = node.prev
            endif
        endmethod
        
        method operator count takes nothing returns integer
            return count_p
        endmethod
        method operator count= takes thistype value returns nothing
            /*
            *   Remove from list node was on
            */
            call count_p.remove(this)
            
            /*
            *   Add to new list
            */
            call value.add(this)
        endmethod
    endstruct
    
    /*
    *   queue = angle + 1
    */
    private struct Queue extends array
        private real stamp
        
        thistype next
        thistype last
        
        /*
        *   Update dummy count for queue
        */
        private method operator count takes nothing returns integer
            return ArrayStack(this).count
        endmethod
        private method operator count= takes integer value returns nothing
            set ArrayStack(this).count = value
        endmethod
        
        /*
        *   Queue with smallest number of dummies
        */
        private static method operator min takes nothing returns thistype
            return ArrayStack.min.first
        endmethod
        
        /*
        *   Queue with largest number of dummies
        */
        private static method operator max takes nothing returns thistype
            return ArrayStack.max.first
        endmethod
        
        static method add takes thistype dummy returns nothing
            /*
            *   Always add to the queue with the least amount of dummies
            */
            local thistype this = min
            
            /*
            *   Add to end of queue
            */
            set last.next = dummy
            set last = dummy
            set dummy.next = 0
            
            /*
            *   Update queue count
            */
            set count = count + 1
            
            /*
            *   Match unit angle with queue
            */
            call SetUnitFacing(dummies[indexPointer[dummy]], this - 1)
            
            /*
            *   Apply stamp so that dummy isn't used until the stamp is expired
            */
            set dummy.stamp = TimerGetElapsed(stampTimer) + RECYCLE_DELAY - .01
        endmethod
        static method pop takes thistype this, real x, real y, real facing returns integer
            /*
            *   Retrieve queue and first dummy on queue given angle
            */
            local unit dummyUnit                //dummy unit
            local thistype dummyIndex = next    //dummy index
            local integer unitIndex             //unit idex
            
            local thistype this2
            local thistype node

            local real stamp
            
            /*
            *   If the queue is empty, return new dummy
            */
            if (0 == dummyIndex or dummyIndex.stamp > TimerGetElapsed(stampTimer)) then
                /*
                *   Allocate new dummy
                */
                debug if (dummyCount == 8191) then
                    debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"DUMMY RECYCLER FATAL ERROR: DUMMY OVERLOAD")
                    debug set Dummy.enabled = false
                    debug set this = 1/0
                debug endif
                
                set dummyIndex = dummyCount + 1
                set dummyCount = dummyIndex
                
                /*
                *   Create and initialize new unit handle
                */
                set dummyUnit = CreateUnit(DUMMY_OWNER, DUMMY_ID, x, y, facing)
                set unitIndex = GetUnitUserData(dummyUnit)
                set indexPointer[dummyIndex] = unitIndex
                set dummyPointer[unitIndex] = dummyIndex
                
                set dummies[unitIndex] = dummyUnit
                call UnitAddAbility(dummyUnit, 'Amrf')
                call UnitRemoveAbility(dummyUnit, 'Amrf')
                call PauseUnit(dummyUnit, true)
                
                return dummyIndex
            endif
            
            /*
            *   Remove the dummy from the queue
            */
            set next = dummyIndex.next
            if (0 == next) then
                set last = this
            endif
            
            /*
            *   Only remove from the count if the queue has most dummies in it
            *
            *   If queue doesn't have most dummies in it, take a dummy from the queue
            *   with most dummies in it and keep count the same
            */
            if (count == ArrayStack.max) then
                set count = count - 1
            else
                /*
                *   Retrieve the queue with most dummies in it as well as the
                *   first dummy in that queue
                */
                set this2 = max
                set node = this2.next
                
                /*
                *   Remove first dummy from largest queue
                */
                if (0 == node.next) then
                    set this2.last = this2
                else
                    set this2.next = node.next
                endif
                
                set this2.count = this2.count - 1
                
                /*
                *   Add first dummy to current queue
                */
                set last.next = node
                set last = node
                set node.next = 0
                
                /*
                *   Match unit angle with queue
                */
                call SetUnitFacing(dummies[indexPointer[node]], this - 1)
                
                /*
                *   .73 seconds is how long it takes for a dummy to rotate 180 degrees
                *
                *   Credits to Bribe for these 4 lines of code and the .73 value
                */
                set stamp = TimerGetElapsed(stampTimer) + .73
                if (stamp > node.stamp) then
                    set node.stamp = stamp
                endif
            endif
            
            /*
            *   Move dummy to target position
            */
            set dummyUnit = dummies[indexPointer[dummyIndex]]
            call SetUnitX(dummyUnit, x)
            call SetUnitY(dummyUnit, y)
            call SetUnitFacing(dummyUnit, facing)
            set dummyUnit = null
            
            /*
            *   Return first dummy from current queue
            */
            return dummyIndex
        endmethod
    endstruct
    
    struct Dummy extends array
        debug static boolean enabled = false
        debug private boolean allocated
        
        /*
        *   Retrieve index given unit handle
        */
        static method operator [] takes unit dummyUnit returns thistype
            debug if (not enabled) then
                debug return 1/0
            debug endif
            
            return GetUnitUserData(dummyUnit)
        endmethod
        
        /*
        *   Retrieve unit handle given index
        */
        method operator unit takes nothing returns unit
            debug if (not enabled) then
                debug set this = 1/0
            debug endif
            
            return dummies[this]
        endmethod
        
        /*
        *   Slightly faster than ModuloInteger due to less args + constants
        */
        private static method getClosestAngle takes integer angle returns integer
            set angle = angle - angle/360*360
            
            if (0 > angle) then
                set angle = angle + 360
            endif
            
            return angle/ANGLE_SPACING*ANGLE_SPACING
        endmethod
        
        /*
        *   Returns either a new or a recycled dummy index
        */
        static method create takes real x, real y, real facing returns Dummy
            static if DEBUG_MODE then
                local thistype this
                
                if (not enabled) then
                    set x = 1/0
                endif
                
                set this = indexPointer[Queue.pop(getClosestAngle(R2I(facing)) + 1, x, y, facing)]
                
                debug set allocated = true
                
                return this
            else
                return indexPointer[Queue.pop(getClosestAngle(R2I(facing)) + 1, x, y, facing)]
            endif
        endmethod
        
        /*
        *   Recycles dummy index
        */
        method destroy takes nothing returns nothing
            debug if (not enabled) then
                debug set this = 1/0
            debug endif
            
            /*
            *   If the recycled dummy was invalid, issue critical error
            */
            debug if (0 == GetUnitTypeId(unit) or 0 == GetWidgetLife(unit) or not allocated) then
                debug if (not allocated) then
                    debug call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10, "DUMMY RECYCLER FATAL ERROR: DOUBLE FREE")
                debug elseif (null == unit) then
                    debug call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10, "DUMMY RECYCLER FATAL ERROR: REMOVED A DUMMY")
                debug elseif (0 == GetWidgetLife(unit)) then
                    debug call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10, "DUMMY RECYCLER FATAL ERROR: KILLED A DUMMY")
                debug else
                    debug call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10, "DUMMY RECYCLER FATAL ERROR: ATTEMPTED TO RECYCLE NON DUMMY UNIT")
                debug endif
                
                debug set enabled = false
                debug set this = 1/0
            debug endif
            debug if (indexPointer[dummyPointer[this]] != this) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"ERROR")
            debug endif
            
            debug set allocated = false
            
            call SetUnitPosition(dummies[this], 2147483647, 2147483647)
            call Queue.add(dummyPointer[this])
        endmethod
    endstruct
    
    /*
    *   Initialization
    */
    private function Initialize takes nothing returns nothing
        local unit dummy
        local integer last
        local integer angle
        local ArrayStack queue
        local integer count
        
        /*
        *   This timer 
        */
        set stampTimer = CreateTimer()
        call TimerStart(stampTimer, 604800, false, null)
        
        /*
        *   The highest possible angle
        */
        set last = 360/ANGLE_SPACING*ANGLE_SPACING
        if (360 == last) then
            set last = last - ANGLE_SPACING
            if (last < ANGLE_SPACING) then
                set last = 0
            endif
        endif
        
        /*
        *   The lowest possible angle
        */
        set angle = 0
        
        /*
        *   Start dummy count at the last possible angle so that
        *   angles don't overlap with dummy indexes. This is done
        *   to simplify queue algorithm and improve overall performance.
        *   At most 360 possible dummy unit indexes will be lost due to this.
        */
        set dummyCount = last + 1
        
        /*
        *   Initialize ArrayStack
        */
        set ArrayStack.min = PRELOAD_PROJECTILES_PER_ANGLE
        set ArrayStack.max = PRELOAD_PROJECTILES_PER_ANGLE
        set ArrayStack(PRELOAD_PROJECTILES_PER_ANGLE).first = 1
        
        loop
            /*
            *   queue pointer is angle + 1
            */
            set queue = angle + 1
            
            /*
            *   Only add projectiles to queue if MAX_PROJECTILES < 0
            */
            if (0 < PRELOAD_PROJECTILES_PER_ANGLE) then
                set count = PRELOAD_PROJECTILES_PER_ANGLE
                set queue.count_p = PRELOAD_PROJECTILES_PER_ANGLE
                
                set dummyCount = dummyCount + 1
                set Queue(queue).next = dummyCount
                
                /*
                *   Create and add all dummies to queue
                */
                loop
                    /*
                    *   Create and initialize unit handle
                    */
                    set dummy = CreateUnit(DUMMY_OWNER, DUMMY_ID, 0, 0, angle)
                    set indexPointer[dummyCount] = GetUnitUserData(dummy)
                    set dummyPointer[GetUnitUserData(dummy)] = dummyCount
                    set dummies[indexPointer[dummyCount]] = dummy
                    
                    call UnitAddAbility(dummy, 'Amrf')
                    call UnitRemoveAbility(dummy, 'Amrf')
                    call PauseUnit(dummy, true)
                    
                    set count = count - 1
                    exitwhen 0 == count
                    
                    /*
                    *   Point to next
                    */
                    set dummyCount.next = dummyCount + 1
                    set dummyCount = dummyCount + 1
                endloop
                
                set Queue(queue).last = dummyCount
            else
                set Queue(queue).last = queue
            endif
            
            exitwhen last == angle
            
            /*
            *   Go to next angle
            */
            set angle = angle + ANGLE_SPACING
            
            /*
            *   Link queues together
            */
            set queue.next = angle + 1
            set ArrayStack(angle + 1).prev = queue
            
            /*
            *   Go to next queue
            */
            set queue = angle + 1
        endloop
        
        set dummy = null
        
        debug set Dummy.enabled = true
    endfunction
    private module Init
        private static method onInit takes nothing returns nothing
            static if DEBUG_MODE then
                call ExecuteFunc(SCOPE_PRIVATE + "Initialize")
                if (not Dummy.enabled) then
                    call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"DUMMY RECYCLER FATAL ERROR: INITIALIZATION CRASHED, LOWER PRELOAD DUMMY COUNT")
                endif
            else
                call Initialize()
            endif
        endmethod
    endmodule
    private struct Inits extends array
        implement Init
    endstruct
endlibrary

library MissileRecycler uses Dummy
    function GetRecycledMissile takes real x, real y, real z, real facing returns unit
        local Dummy dummy = Dummy.create(x, y, facing)
        
        call SetUnitFlyHeight(dummy.unit, z, 0)
        
        return dummy.unit
    endfunction
    function RecycleMissile takes unit u returns nothing
        call Dummy[u].destroy()
    endfunction
endlibrary