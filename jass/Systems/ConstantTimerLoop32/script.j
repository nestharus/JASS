library CTL /* v1.2.0.3
    *************************************************************************************
    *
    *    CTL or Constant Timer Loop provides a loop for constant merged timers of timeout .03125
    *
    *    Similar to T32 but pauses timer when no structs have instances and removes structs
    *    from timer trigger when those structs have no instances. 
    *
    *    This can also create new timers after destroying a previous timer and generates less 
    *    code in the module. It also generates no triggers so long as the module is implemented 
    *    at the top of the struct.
    *
    ************************************************************************************
    *
    *    module CTL
    *
    *       Allows creation/destruction of timers in a struct. Provides instancing of those timers.
    *
    *       -   static method create takes nothing returns thistype
    *       -   method destroy takes nothing returns nothing
    *
    *       CTL (optional)
    *           local variables, code before running any timers
    *       CTLExpire (not optional)
    *           timer code
    *       CTLNull (optional)
    *           null any locals, runs after all timers
    *       CTLEnd (not optional)
    *
    *   module CT32
    *
    *       Converts struct into a timer group. Allows the timer group to be started and stopped.
    *       Instancing and looping through active timers is up to the user.
    *
    *       -   static method start takes nothing returns nothing
    *       -   static method stop takes nothing returns nothing
    *
    *       CT32 (not optional)
    *           timer code
    *       CT32End (not optional)
    *
    *   struct TimerGroup32 extends array
    *
    *       Allows for the creation of timer groups. Timer instancing and looping is entirely up
    *       to the user.
    *
    *       -   static method create takes code func returns thistype
    *       -   method destroy takes nothing returns nothing
    *       -   method start takes nothing returns nothing
    *       -   method stop takes nothing returns nothing
    *
    ************************************************************************************/
    globals
        private integer tgc = 0          //timer group count
        private integer array tgr        //timer group recycler
        
        private integer ic=0                    //instance count
        private integer tc=0                    //timer count
        private integer array rf                //root first
        private integer array n                 //next
        private integer array p                 //previous
        private integer array th                //timer head
        private integer array ns                //next stack
        private trigger t=CreateTrigger()
        private timer m=CreateTimer()
        private triggercondition array ct
        private conditionfunc array rc
        
        private boolean array e32               //enabled
        private integer array i32r              //ct32 recycler
        private integer i32cr = 0               //ct32 count recycler
        private boolean array ir32              //is recycling
        private boolean array id32              //is destroying
    endglobals
    private function E takes nothing returns nothing
        local integer i=ns[0]
        set ns[0]=0
        loop
            exitwhen 0==i
            if (0==p[i]) then
                if (0==n[i]) then
                    call TriggerRemoveCondition(t,ct[th[i]])
                    set ct[th[i]]=null
                    set tc=tc-1
                    set rf[th[i]]=0
                else
                    set rf[th[i]]=n[i]
                    set p[n[i]]=0
                endif
            else
                set p[n[i]]=p[i]
                set n[p[i]]=n[i]
            endif
            set n[i]=n[0]
            set n[0]=i
            set i=ns[i]
        endloop
        loop
            exitwhen 0 == i32cr
            set i32cr = i32cr - 1
            set i = i32r[i32cr]
            if (not e32[i]) then
                call TriggerRemoveCondition(t,ct[i])
                set ct[i] = null
                
                if (id32[i]) then
                    set tgr[i] = tgr[0]
                    set tgr[0] = i
                    set id32[i] = false
                endif
                
                set ir32[i] = false
            endif
        endloop
        if (0==tc) then
            call PauseTimer(m)
        else
            call TriggerEvaluate(t)
        endif
    endfunction
    private function CT takes integer r returns integer
        local integer i
        local integer f
        if (0==n[0]) then
            set i=ic+1
            set ic=i
        else
            set i=n[0]
            set n[0]=n[i]
        endif
        set th[i]=r
        set ns[i]=-1
        set f=rf[r]
        if (0==f) then
            set n[i]=0
            set p[i]=0
            set rf[r]=i
            set ct[r]=TriggerAddCondition(t,rc[r])
            //set ct[r] = null
            if (0==tc) then
                call TimerStart(m,.031250000,true,function E)
            endif
            set tc=tc+1
        else
            set n[i]=f
            set p[i]=0
            set p[f]=i
            set rf[r]=i
        endif
        return i
    endfunction
    private function DT takes integer t returns nothing
        debug if (0>ns[t]) then
            set ns[t]=ns[0]
            set ns[0]=t
        debug else
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"TIMER LOOP ERROR: ATTEMPT TO DESTROY NULL TIMER")
        debug endif
    endfunction
    private function A takes code c returns integer
        local integer i = tgr[0]
        if (0 == i) then
            set i = tgc + 1
            set tgc = i
        else
            set tgr[0] = tgr[i]
        endif
        set rc[i]=Condition(c)
        return i
    endfunction
    private function A32 takes integer i returns nothing
        if (not (e32[i] or id32[i])) then
            if (ir32[i]) then
                set ir32[i] = false
            else
                set ct[i] = TriggerAddCondition(t, rc[i])
            endif
        
            if (0 == tc) then
                call TimerStart(m,.031250000,true,function E)
            endif
            set tc = tc + 1
            set e32[i] = true
        endif
    endfunction
    private function SR32 takes integer i returns nothing
        if (e32[i]) then
            if (not (ir32[i] or id32[i])) then
                set i32r[i32cr] = i
                set i32cr = i32cr + 1
                set ir32[i] = true
            endif
            set e32[i] = false
            set tc = tc - 1
        endif
    endfunction
    private function DT32 takes integer i returns nothing
        if (not id32[i]) then
            if (not ir32[i]) then
                set ir32[i] = true
                set tc = tc - 1
                set i32r[i32cr] = i
                set i32cr = i32cr + 1
                set e32[i] = false
            endif
            set id32[i] = true
        endif
    endfunction
    private keyword r
    private keyword e
    module CTL
        static integer rctl32
        static method create takes nothing returns thistype
            return CT(rctl32)
        endmethod
        method destroy takes nothing returns nothing
            call DT(this)
        endmethod
        static method ectl32 takes nothing returns boolean
            local thistype this=rf[rctl32]
    endmodule
    module CTLExpire
            implement CTL
            loop
                exitwhen 0==this
    endmodule
    module CTLNull
                set this=n[this]
            endloop
    endmodule
    module CTLEnd
            implement CTLNull
            return false
        endmethod
        private static method onInit takes nothing returns nothing
            set rctl32 = A(function thistype.ectl32)
        endmethod
    endmodule
    module CT32
        static integer rctl32
        static method start takes nothing returns nothing
            call A32(rctl32)
        endmethod
        static method stop takes nothing returns nothing
            call SR32(rctl32)
        endmethod
        static method ectl32 takes nothing returns boolean
    endmodule
    module CT32End
            return false
        endmethod
        private static method onInit takes nothing returns nothing
            set rctl32 = A(function thistype.ectl32)
        endmethod
    endmodule
    
    struct TimerGroup32 extends array
        static method create takes code c returns thistype
            return A(c)
        endmethod
        method destroy takes nothing returns nothing
            call DT32(this)
        endmethod
        method start takes nothing returns nothing
            call A32(this)
        endmethod
        method stop takes nothing returns nothing
            call SR32(this)
        endmethod
    endstruct
endlibrary