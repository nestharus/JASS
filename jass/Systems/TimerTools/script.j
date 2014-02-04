library TimerTools /* v3.0.0.3
*************************************************************************************
*
*   Timer tools timers use a special merging algorithm. When two timers merge, they
*   both expire on the same timer. The first tick accuracy is based on the size of the timer's timeout. 
*   The larger the timeout, the more inaccurate the first tick can be. The tick only becomes inaccurate
*   if it merges with another timer.
*
*   Max Timeout: 25.6
*   Min Timeout: .003125
*
*   Specializes in repeating timers.
*
************************************************************************************
*
*    SETTINGS
*/
globals
    /*************************************************************************************
    *
    *                    RELATIVE_MERGE
    *
    *    Effects the accuracy of first tick. The smaller the merge value, the less chance two
    *    timers have of sharing the same first tick, which leads to worse performance.
    *    However, a larger merge value decreases the accuracy of the first tick.
    *
    *    Formula: Ln(RELATIVE_MERGE/timeout)/230.258509*timeout
    *        Ln(64000/3600)/230.258509*3600=44.995589035797596625536391805959 seconds max off
    *
    *************************************************************************************/
    private constant real RELATIVE_MERGE =                  64000

    /*************************************************************************************
    *
    *                    CONSTANT_MERGE
    *
    *    Effects the accuracy of the first tick. This is a constant merge. If this value +.01 is
    *    greater than the value calculated from RELATIVE_MERGE, the timer auto merges.
    *
    *    Constant merge must be greater than 0.
    *
    *************************************************************************************/
    private constant real CONSTANT_MERGE =                  .1
    
    /*************************************************************************************
    *
    *                    TIMER_COUNT
    *
    *    How many timers to run the system on. Most maps will only need 200 due to merge.
    *
    *************************************************************************************/
    private constant integer TIMER_COUNT =                  3000
endglobals
/*
************************************************************************************
*
*    struct Timer extends array
*
*       Creators/Destructors
*       -----------------------
*
*           static method create takes real timeout, boolexpr onExpire, integer funcId returns Timer
*           method destroy takes nothing returns nothing
*
*       Fields
*       -----------------------
*
*           readonly Timer next
*               -   sentinel 0
*
*           readonly static integer expired
*               -   expired timer group id (not Timer instance)
*
*           readonly boolean registered
*               -   has Timer been registered
*               -   occurs when timer has been added to timer group and is ready to run
*
*           readonly boolean disabled
*               -   is Timer disabled
*               -   occurs on timer that are to be detroyed close to or during expiration 
*               -   that were created close to or during expiration
*
*           readonly boolean toBeDestroyed
*               -   is Timer to be destroyed
*               -   occurs when a timer is destroyed during expiration
*
*           readonly boolean toBeAdded
*               -   occurs when timer created close to or during expiration
*
*           readonly integer parent
*               -   retrieves the timer group id that the timer is on
*
*           readonly boolean isHead
*               -   is the timer the first timer in its subgroup
*
*       Methods
*       -----------------------
*
*           static method getExpired takes integer funcId returns Timer
*               -   retrieves first Timer in expiring timer group for function
*               -   hashtable read
*
*    module TimerHead
*
*       Description
*       -----------------------
*           Avoids hashtable read for a struct by maintaining a head variable. Changes
*           hashtable read to an array read.
*
*       Fields
*       -----------------------
*
*           readonly Timer first
*               -   thistype(Timer.expired).first == Timer.getExpired(funcId)
*
*       Methods
*       -----------------------
*
*           static method add takes Timer timerNode returns nothing
*               -   call this whenever creating timer for local function
*               -   pass in the newly created timer
*
*           static method remove takes Timer timerNode returns nothing
*               -   call this whenever destroying timer for local function
*               -   pass in the destroyed timer
*
************************************************************************************/    
    globals
        private boolean enabled = true
        private code handler = null
    endglobals
    
    //hiveworkshop.com/forums/jass-functions-413/snippet-natural-logarithm-108059/
    //credits to BlinkBoy
    private function Ln takes real a returns real
        local real s = 0
        loop
            exitwhen a < 2.71828
            set a = a/2.71828
            set s = s + 1
        endloop
        return s + (a - 1)*(1 + 8/(1 + a) + 1/a)/6
    endfunction
    
    private module Init
        private static method onInit takes nothing returns nothing
            call init()
        endmethod
    endmodule
    private keyword ExpirationCode
    private struct TimerPool extends array
        readonly static integer OFFSET
        private static timer array timers
        private static trigger array onExpire
        private static integer array count
        
        private static integer array recycler
        private static integer instanceCount = 0
        
        static constant method operator [] takes integer i returns timer
            return timers[i]
        endmethod
        
        static constant method getTimerId takes integer handleId returns integer
            return handleId - OFFSET
        endmethod
        static constant method getTrigger takes integer timerId returns trigger
            return onExpire[timerId]
        endmethod
        static constant method getCount takes integer timerId returns integer
            return count[timerId]
        endmethod
        
        static method register takes integer timerId, boolexpr onExpire returns triggercondition
            static if DEBUG_MODE then
                if (not enabled) then
                    set timerId = 1/0
                endif
            endif
            set count[timerId] = count[timerId] + 1
            
            if (null == onExpire) then
                return null
            endif
            
            return TriggerAddCondition(thistype.onExpire[timerId], onExpire)
        endmethod
        
        static method unregister takes integer timerId, triggercondition tc returns nothing
            static if DEBUG_MODE then
                if (not enabled) then
                    set timerId = 1/0
                endif
                if (0 == count[timerId]) then
                    call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"TIMER POOL ATTEMPT TO UNREGISTER EMPTY TIMER")
                    set enabled = false
                    set timerId = 1/0
                endif
            endif
            
            set count[timerId] = count[timerId] - 1
            
            if (null == tc) then
                return
            endif
            
            call TriggerRemoveCondition(thistype.onExpire[timerId], tc)
        endmethod
    
        private static method init takes nothing returns nothing
            local integer i = 2
            
            set timers[1] = CreateTimer()
            set OFFSET = GetHandleId(timers[1]) - 1
            
            loop
                set timers[i] = CreateTimer()
                exitwhen TIMER_COUNT == i
                set i = i + 1
            endloop
            
            set i = TIMER_COUNT
            loop
                
                set onExpire[i] = CreateTrigger()
                exitwhen 1 == i
                set i = i - 1
            endloop
        endmethod
        
        static method getTimer takes nothing returns integer
            local integer i = recycler[0]
            
            static if DEBUG_MODE then
                if (not enabled) then
                    return 1/0
                endif
            endif
            
            if (0 == i) then
                static if DEBUG_MODE then
                    if (instanceCount == TIMER_COUNT) then
                        call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"TIMER OVERFLOW")
                        set enabled = false
                        return 1/0
                    endif
                endif
                
                set i = instanceCount + 1
                set instanceCount = i
            else
                set recycler[0] = recycler[i]
            endif
            
            static if DEBUG_MODE then
                set recycler[i] = -1
                
                if (timers[i] == null or onExpire[i] == null) then
                    call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"INITIALIZATION CRASHED")
                    set enabled = false
                    set i = 1/0
                endif
            endif
            
            return i
        endmethod
        
        static method recycleTimer takes integer timerId returns nothing
            static if DEBUG_MODE then
                if (not enabled) then
                    set timerId = 1/0
                endif
                if (recycler[timerId] != -1) then
                    call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"TIMER DOUBLE FREE ERROR: ("+I2S(timerId)+")")
                    set enabled = false
                    set timerId = timerId/0
                endif
            endif
            
            call PauseTimer(timers[timerId])
            
            set recycler[timerId] = recycler[0]
            set recycler[0] = timerId
        endmethod
    
        implement Init
    endstruct
    private struct TimerFunction extends array
        private static hashtable table = InitHashtable()
        method operator [] takes integer b returns integer
            return LoadInteger(table, this, b)
        endmethod
        method operator []= takes integer b, integer v returns nothing
            call SaveInteger(table, this, b, v)
        endmethod
    endstruct
    private struct ExpirationCode extends array
        private static integer instanceCount = 0
        private static integer array recycler
        
        readonly integer timerId
        readonly triggercondition onExpireCode
        readonly boolexpr onExpireCodeB
        boolean disabled
        readonly boolean registered
        
        readonly thistype next
        readonly thistype prev
        private integer funcId
        static method create takes integer timerId, boolexpr onExpireCode, integer funcId returns thistype
            local thistype this = recycler[0]
            
            static if DEBUG_MODE then
                if (not enabled) then
                    set this = 1/0
                endif
            endif
            
            if (0 == this) then
                static if DEBUG_MODE then
                    if (instanceCount + 1 == 8192) then
                        call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"TIMER EXPIRE CODE OVERFLOW")
                        set enabled = false
                        return 1/0
                    endif
                endif
            
                set this = instanceCount + 1
                set instanceCount = this
            else
                set recycler[0] = recycler[this]
            endif
            
            set this.timerId = timerId
            set this.onExpireCodeB = onExpireCode
            set this.funcId = funcId
            
            static if DEBUG_MODE then
                set recycler[this] = -1
            endif
            
            return this
        endmethod
        
        static if DEBUG_MODE then
            private method validate takes nothing returns nothing
                local boolean array hit
                
                loop
                    exitwhen 0 == this
                    
                    if (hit[this] or recycler[this] != -1 or not registered) then
                        call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"CORRUPTED EXPIRATION LIST")
                        set enabled = false
                        set this = 1/0
                    endif
                    set hit[this] = true
                
                    set this = next
                endloop
            endmethod
        endif
        method register takes nothing returns nothing
            local thistype head = TimerFunction[timerId][funcId]
            if (0 == head) then
                set next = 0
                set prev = 0
                set TimerFunction[timerId][funcId] = this
                set this.onExpireCode = TimerPool.register(timerId, onExpireCodeB)
            else
                set next = 0
                set prev = head.prev
                set head.prev = this
                if (0 == prev) then
                    set head.next = this
                else
                    set prev.next = this
                endif
                call TimerPool.register(timerId, null)
            endif
            set registered = true
            
            debug call thistype(TimerFunction[timerId][funcId]).validate()
        endmethod
        
        method destroy takes nothing returns nothing
            local thistype head
            
            static if DEBUG_MODE then
                if (not enabled) then
                    set this = 1/0
                endif
            
                if (recycler[this] != -1) then
                    call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"TIMER EXPIRE CODE DOUBLE FREE ERROR")
                    set enabled = false
                    set this = 1/0
                endif
            endif
            
            if (registered) then
                set head = TimerFunction[timerId][funcId]
                
                if (this == head) then
                    static if DEBUG_MODE then
                        if (head.prev.next != 0 or head.next.prev != 0 or head.prev == head or head.next == head) then
                            call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"HEAD CORRUPTION")
                            set enabled = false
                            set this = 1/0
                        endif
                    endif
                    set TimerFunction[timerId][funcId] = next
                    
                    if (next != 0) then
                        set next.onExpireCode = this.onExpireCode
                        set this.onExpireCode = null
                        set next.prev = prev
                        set head = next
                        set head.next.prev = 0
                        if (head.prev == head) then
                            set head.prev = 0
                        endif
                    endif
                else
                    if (0 == prev) then
                        set head.next = next
                    else
                        set prev.next = next
                    endif
                    if (0 == next) then
                        set head.prev = prev
                    else
                        set next.prev = prev
                    endif
                endif
                call TimerPool.unregister(timerId, onExpireCode)
                
                debug call thistype(TimerFunction[timerId][funcId]).validate()
            endif
            
            set disabled = false
            set registered = false
            set onExpireCode = null
            set onExpireCodeB = null
            
            set recycler[this] = recycler[0]
            set recycler[0] = this
        endmethod
    endstruct
    
    //add to creation queue when a timer is currently expired or when the timer
    //is about to expire
    private struct CreationQueue extends array
        private thistype next
        private thistype first
        private thistype last
        private integer toAdd
        
        static method getToAdd takes integer timerId returns integer
            return thistype(timerId).toAdd
        endmethod
        
        static method add takes ExpirationCode expirationCode returns nothing
            local thistype this = expirationCode.timerId
            
            static if DEBUG_MODE then
                if (not enabled) then
                    set expirationCode = 1/0
                endif
            endif
            
            set toAdd = toAdd + 1
            
            if (0 == first) then
                set first = expirationCode
            else
                set last.next = expirationCode
            endif
            
            set last = expirationCode
            set thistype(expirationCode).next = 0
        endmethod
        
        static method remove takes ExpirationCode expirationCode returns nothing
            local thistype this = expirationCode.timerId
            
            static if DEBUG_MODE then
                if (not enabled) then
                    set expirationCode = 1/0
                endif
                
                if (0 == thistype(expirationCode.timerId).toAdd) then
                    call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"ATTEMPT TO REMOVE UNREGISTERED FUTURE CODE")
                    set enabled = false
                    set expirationCode = 1/0
                endif
            endif
            
            set expirationCode.disabled = true
            
            set toAdd = toAdd - 1
        endmethod
        
        static method register takes integer timerId returns nothing
            local thistype node = thistype(timerId).first
            
            static if DEBUG_MODE then
                if (not enabled) then
                    set timerId = 1/0
                endif
            endif
            
            set thistype(timerId).first = 0
            set thistype(timerId).last = 0
            set thistype(timerId).toAdd = 0
        
            loop
                exitwhen 0 == node
                
                if (ExpirationCode(node).disabled) then
                    call ExpirationCode(node).destroy()
                else
                    static if DEBUG_MODE then
                        if (ExpirationCode(node).registered) then
                            call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"TIMER NODE DOUBLE REGISTRATION ERROR")
                            set enabled = false
                            set timerId = 1/0
                        endif
                    endif
                    call ExpirationCode(node).register()
                endif
                
                set node = node.next
            endloop
        endmethod
    endstruct
    
    //add to destruction queue when a timer is currently expired
    private struct DestructionQueue extends array
        private thistype next
        
        private thistype first
        private thistype last
        
        static method add takes ExpirationCode expirationCode returns nothing
            local thistype this = expirationCode.timerId
            
            if (0 == first) then
                set first = expirationCode
            else
                set last.next = expirationCode
            endif
            
            set last = expirationCode
            set thistype(expirationCode).next = 0
        endmethod
        
        static method clean takes integer timerId returns nothing
            local thistype node = thistype(timerId).first
            
            set thistype(timerId).first = 0
            set thistype(timerId).last = 0
        
            loop
                exitwhen 0 == node
                
                call ExpirationCode(node).destroy()
                
                set node = node.next
            endloop
        endmethod
    endstruct
    private struct TimerList extends array
        private static integer array lists
        private static integer array timeoutId
        private static boolean array isConst
        private static boolean array isSet
        private static real array relativeOffset
        
        thistype next       //node.next
        thistype prev       //node.prev
        
        static method timerId2TimeoutId takes integer timerId returns integer timeoutId
            return timeoutId[timerId]
        endmethod
        static constant method getTimeout takes integer timeoutId returns real
            return timeoutId/320.
        endmethod
        static method getRelativeOffset takes real timeout returns real
            if (timeout <= CONSTANT_MERGE) then
                return CONSTANT_MERGE
            endif
            set timeout = Ln(RELATIVE_MERGE/timeout)/230.258509*timeout
            if (timeout < CONSTANT_MERGE) then
                return CONSTANT_MERGE
            endif
            return timeout
        endmethod
        static method convertTimeout takes real timeout returns real
            if (timeout < .003125) then
                return .003125
            endif
            return timeout
        endmethod
        static method getTimeoutId takes real timeout returns integer
            return R2I(timeout*320 + .5)
        endmethod
        static method operator [] takes integer timeoutId returns thistype
            return lists[timeoutId]
        endmethod
        static method operator []= takes integer timeoutId, integer t returns nothing
            set lists[timeoutId] = t
        endmethod
        
        static method add takes integer timeoutId, boolexpr onExpire, integer funcId returns thistype
            local thistype timerId = thistype[timeoutId]
            local thistype newTimerId
            local ExpirationCode expirationCode
            local real timeout = getTimeout(timeoutId)
            
            if (timerId == 0) then
                set timerId = TimerPool.getTimer()
                set thistype.timeoutId[timerId] = timeoutId
                set thistype[timeoutId] = timerId
                set timerId.next = timerId
                set timerId.prev = timerId
                set expirationCode = ExpirationCode.create(timerId, onExpire, funcId)
                call expirationCode.register()
                call TimerStart(TimerPool[timerId], timeout, true, handler)
                
                if (not isSet[timeoutId]) then
                    set isSet[timeoutId] = true
                    set relativeOffset[timeoutId] = getRelativeOffset(timeout)
                    
                    set isConst[timeoutId] = timeout <= relativeOffset[timeoutId]*2
                endif
            else
                if (isConst[timeoutId]) then
                    if (TimerGetRemaining(TimerPool[timerId]) < timeout/2) then
                        set expirationCode = ExpirationCode.create(timerId, onExpire, funcId)
                        call CreationQueue.add(expirationCode)
                    else
                        set timerId = timerId.prev
                        set expirationCode = ExpirationCode.create(timerId, onExpire, funcId)
                        call expirationCode.register()
                    endif
                else
                    //timer is expiring soon enough, add to creation stack
                    if (TimerGetRemaining(TimerPool[timerId]) <= relativeOffset[timeoutId]) then
                        set expirationCode = ExpirationCode.create(timerId, onExpire, funcId)
                        call CreationQueue.add(expirationCode)
                    //timer at end is expiring at relatively the same time as new timer
                    elseif (TimerGetRemaining(TimerPool[timerId.prev]) >= timeout - relativeOffset[timeoutId]) then
                        set timerId = timerId.prev
                        set expirationCode = ExpirationCode.create(timerId, onExpire, funcId)
                        call expirationCode.register()
                    //there is no suitable timer to merge with
                    else
                        set newTimerId = TimerPool.getTimer()
                        set thistype.timeoutId[newTimerId] = timeoutId
                        
                        set newTimerId.prev = timerId.prev
                        set newTimerId.next = timerId
                        set newTimerId.prev.next = newTimerId
                        set timerId.prev = newTimerId
                        
                        set expirationCode = ExpirationCode.create(newTimerId, onExpire, funcId)
                        call expirationCode.register()
                        call TimerStart(TimerPool[newTimerId], timeout, true, handler)
                    endif
                endif
            endif
            
            return expirationCode
        endmethod
    endstruct
    
    private struct Handler extends array
        readonly static integer expiringTimer = 0
        private static method expire takes nothing returns nothing
            local integer timerId = TimerPool.getTimerId(GetHandleId(GetExpiredTimer()))
            
            static if DEBUG_MODE then
                if (not enabled) then
                    call PauseTimer(GetExpiredTimer())
                    return
                endif
                if (0 == TimerPool.getCount(timerId)) then
                    call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"TIMER EXPIRATION ERROR EMPTY TIMER")
                    set enabled = false
                    return
                endif
                if (TimerPool[timerId] != GetExpiredTimer()) then
                    call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"TIMER EXPIRATION ERROR CORRUPT TIMER")
                    set enabled = false
                    return
                endif
            endif
            
            set expiringTimer = timerId
            call TriggerEvaluate(TimerPool.getTrigger(timerId))
            set expiringTimer = 0
            
            call CreationQueue.register(timerId)
            call DestructionQueue.clean(timerId)
            
            set TimerList[TimerList.timerId2TimeoutId(timerId)] = TimerList(timerId).next
            
            if (0 == TimerPool.getCount(timerId)) then
                set TimerList(timerId).prev.next = TimerList(timerId).next
                set TimerList(timerId).next.prev = TimerList(timerId).prev
                if (TimerList(timerId).next == timerId) then
                    set TimerList[TimerList.timerId2TimeoutId(timerId)] = 0
                endif
                call TimerPool.recycleTimer(timerId)
            endif
        endmethod
    
        private static method init takes nothing returns nothing
            set handler = function thistype.expire
        endmethod
        
        implement Init
    endstruct
    
    struct Timer extends array
        method operator next takes nothing returns thistype
            return ExpirationCode(this).next
        endmethod
        static method create takes real timeout, boolexpr onExpire, integer funcId returns Timer
            return TimerList.add(TimerList.getTimeoutId(timeout), onExpire, funcId)
        endmethod
        method destroy takes nothing returns nothing
            local integer timerId = ExpirationCode(this).timerId
            
            if (ExpirationCode(this).registered) then
                if (Handler.expiringTimer == timerId) then
                    call DestructionQueue.add(this)
                else
                    call ExpirationCode(this).destroy()
                    if (0 == TimerPool.getCount(timerId)) then
                        call TimerPool.recycleTimer(timerId)
                        set TimerList(timerId).prev.next = TimerList(timerId).next
                        set TimerList(timerId).next.prev = TimerList(timerId).prev
                        if (TimerList[TimerList.timerId2TimeoutId(timerId)] == timerId) then
                            set TimerList[TimerList.timerId2TimeoutId(timerId)] = TimerList(timerId).next
                            if (TimerList(timerId).next == timerId) then
                                set TimerList[TimerList.timerId2TimeoutId(timerId)] = 0
                            endif
                        endif
                    endif
                endif
            else
                set ExpirationCode(this).disabled = true
            endif
        endmethod
        static method getExpired takes integer funcId returns Timer
            return TimerFunction[Handler.expiringTimer][funcId]
        endmethod
        static method operator expired takes nothing returns integer
            return Handler.expiringTimer
        endmethod
        method operator registered takes nothing returns boolean
            return ExpirationCode(this).registered
        endmethod
        method operator disabled takes nothing returns boolean
            return ExpirationCode(this).disabled
        endmethod
        method operator toBeDestroyed takes nothing returns boolean
            return Handler.expiringTimer == ExpirationCode(this).timerId
        endmethod
        method operator toBeAdded takes nothing returns boolean
            return not ExpirationCode(this).registered
        endmethod
        method operator parent takes nothing returns integer
            return ExpirationCode(this).timerId
        endmethod
        method operator isHead takes nothing returns boolean
            return ExpirationCode(this).prev.next == 0
        endmethod
    endstruct
    
    module TimerHead
        readonly Timer first
        private thistype futureHead
        private thistype futureNext
        private thistype futurePrev
        
        static method updateFirst takes thistype parent returns nothing
            set parent.first = parent.futureHead
        endmethod
        
        static if DEBUG_MODE then
            private method validate takes string msg returns nothing
                local thistype head = this
                local boolean array hit
                
                loop
                    if (hit[this]) then
                        call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"FUTURE LIST CORRUPTION: (" + msg + ")")
                        set enabled = false
                        set this = 1/0
                    endif
                    set hit[this] = true
                    
                    set this = futureNext
                    exitwhen this == head
                endloop
            endmethod
        endif
        
        static method add takes thistype timerNode returns nothing
            local thistype parent = Timer(timerNode).parent
            
            if (0 == parent.futureHead) then
                set parent.futureHead = timerNode
                set timerNode.futureNext = timerNode
                set timerNode.futurePrev = timerNode
                
                if (0 == parent.first) then
                    set parent.first = timerNode
                endif
            else
                set parent = parent.futureHead
                
                set timerNode.futureNext = parent
                set timerNode.futurePrev = parent.futurePrev
                set timerNode.futurePrev.futureNext = timerNode
                set parent.futurePrev = timerNode
            endif
            
            debug call parent.futureHead.validate("add")
        endmethod
        static method remove takes thistype timerNode returns nothing
            local thistype parent = Timer(timerNode).parent
            
            set timerNode.futurePrev.futureNext = timerNode.futureNext
            set timerNode.futureNext.futurePrev = timerNode.futurePrev
            
            if (timerNode == parent.futureHead) then
                set parent.futureHead = timerNode.futureNext
                if (parent.futureHead == timerNode) then
                    set parent.futureHead = 0
                endif
            endif
            
            if (not Timer(timerNode).toBeDestroyed) then
                if (timerNode == parent.first) then
                    set parent.first = parent.futureHead
                endif
            endif
            
            debug call parent.futureHead.validate("remove")
        endmethod
    endmodule
endlibrary