library TimerTimeout /* v1.0.0.2
*************************************************************************************
*
*   Used to retrieve important timer data related to timeouts.
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
endglobals
/*
************************************************************************************
*
*    struct TimerTimeout extends array
*
*       Fields
*       -----------------------
*
*           readonly real timeout
*               -   timeout stored within the id
*           readonly real relativeOffset
*               -   used for merging timers (how many seconds off)
*           readonly boolean isConstant
*               -   is constant merge offset
*
*       Operators
*       -----------------------
*
*           static method operator [] takes real timeout returns TimerTimeout
*               -   given a timeout, return's a timer timeout id
*
************************************************************************************/
    private module Init
        private static method onInit takes nothing returns nothing
            call init()
        endmethod
    endmodule
    
    struct TimerTimeout extends array
        readonly real timeout
        readonly real relativeOffset
        readonly boolean isConstant
        
        static method operator [] takes real timeout returns thistype
            if (timeout < .003125) then
                return 1
            endif
            if (timeout > 25.5968750) then
                return 8191
            endif
            
            return R2I(timeout*320 + .5)
        endmethod
        
        private static method findMiddle takes nothing returns integer
            local integer low = R2I(CONSTANT_MERGE*320)
            local integer high = 8191
            local integer mid
            local real timeout
            local real s
            local real a
            
            loop
                set mid = (high + low)/2
                exitwhen high == low
                
                set timeout = mid/320.
                
                set s = 0
                set a = RELATIVE_MERGE/timeout
                loop
                    exitwhen a < 2.71828
                    set a = a/2.71828
                    set s = s + 1
                endloop
                set a = (s + (a - 1)*(1 + 8/(1 + a) + 1/a)/6)/230.258509*timeout
                if (a < CONSTANT_MERGE) then
                    if (low == mid) then
                        set low = low + 1
                    else
                        set low = mid
                    endif
                else
                    if (high == mid) then
                        set high = high - 1
                    else
                        set high = mid
                    endif
                endif
            endloop
            set timeout = mid/320.
            set s = 0
            set a = RELATIVE_MERGE/timeout
            loop
                exitwhen a < 2.71828
                set a = a/2.71828
                set s = s + 1
            endloop
            set a = (s + (a - 1)*(1 + 8/(1 + a) + 1/a)/6)/230.258509*timeout
            if (a > CONSTANT_MERGE) then
                set mid = mid - 1
            endif
            
            return mid
        endmethod
        
        private static method init takes nothing returns nothing
            local thistype this = 1
            local integer constantMerge = findMiddle()
            local integer constantMerge0 = R2I(CONSTANT_MERGE*320)
            
            loop
                set timeout = this/320.
                set relativeOffset = CONSTANT_MERGE
                set isConstant = true
            
                exitwhen this == constantMerge0
                set this = this + 1
            endloop
            
            set this = this + 1
            loop
                set timeout = this/320.
                set relativeOffset = CONSTANT_MERGE
                
                exitwhen this == constantMerge
                set this = this + 1
            endloop
            
            loop
                set this = initialize()
                exitwhen this == 8191
            endloop
        endmethod
        
        private method initialize takes nothing returns thistype
            local integer target = this + 900
            local real s
            local real a
            
            if (target > 8191) then
                set target = 8191
            endif
        
            loop
                set this = this + 1
                
                set timeout = this/320.
                
                /*
                *   Ln
                *
                *       hiveworkshop.com/forums/jass-functions-413/snippet-natural-logarithm-108059/
                *
                *       credits to BlinkBoy
                */
                set s = 0
                set a = RELATIVE_MERGE/timeout
                loop
                    exitwhen a < 2.71828
                    set a = a/2.71828
                    set s = s + 1
                endloop
                set relativeOffset = (s + (a - 1)*(1 + 8/(1 + a) + 1/a)/6)/230.258509*timeout
                
                exitwhen this == target
            endloop
            
            return this
        endmethod
        
        implement Init
    endstruct
endlibrary