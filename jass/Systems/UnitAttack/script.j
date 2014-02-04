library UnitAttack /* v1.0.0.1
*************************************************************************************
*
*   Allows maps to have custom unit attack ranges and cooldowns.
*
*   Setup
*
*       1. Give all units 90000 range
*       2. Give all units 90000 acquisition range
*       3. Give all units .1 attack cooldown
*       4. Enable only 1 attack for all units
*
*       -       If Using Fully Custom Attacks (projectile system etc)     -
*       5. Remove all unit projectile art
*       6. Make all unit weapon types instant
*
*       -       If Using Custom Targeting       -
*       7. Make all units able to target anything
*
*************************************************************************************
*
*   */uses/*
*
*       */ UnitIndexer      /*      hiveworkshop.com/forums/jass-functions-413/unit-indexer-172090/
*
*************************************************************************************
*
*   struct UnitAttack extends UnitIndexStructMethods
*
*       real maxRange
*       real minRange
*       real cooldown
*       real acquireRange
*       readonly UnitIndex target
*
*************************************************************************************/
    private struct Attack_p extends array
        real cooldown
        timer cooldownTimer
        real maxRange
        real minRange
        static Table table
        static UnitIndex array targets
        
        static trigger resetTrigger = CreateTrigger()
        
        private static timer preventAttackTimer = CreateTimer()
        private static integer preventAttackCount = 0
        private static UnitIndex array unitPrevented
        private static boolean array prevented
        private static boolean array retreating
        private static real array rx
        private static real array ry
        private static real array rd
        private static real array ra
        
        method doAttack takes nothing returns nothing
            if (0 != targets[this]) then
                if (0 < GetWidgetLife(targets[this].unit)) then
                    call DisableTrigger(resetTrigger)
                    call IssueTargetOrderById(UnitIndex(this).unit, 851983, targets[this].unit)
                    call EnableTrigger(resetTrigger)
                endif
                call targets[this].unlock()
                set targets[this] = 0
            endif
        endmethod
        
        static method runAttack takes nothing returns nothing
            call thistype(table[GetHandleId(GetExpiredTimer())]).doAttack()
        endmethod
        
        private method index takes nothing returns nothing
            if (null == cooldownTimer) then
                set cooldownTimer = CreateTimer()
                set table[GetHandleId(cooldownTimer)] = this
            endif
            
            set cooldown = 5
            call TimerStart(cooldownTimer, 0, false, null)
        endmethod
        private method deindex takes nothing returns nothing
            if (0 != targets[this]) then
                call targets[this].unlock()
                set targets[this] = 0
            endif
        endmethod
        
        private static method preventAttacks takes nothing returns nothing
            local UnitIndex whichUnit
            local real x
            local real y
            local real angle
            local real distance
            local real minRange
            local real x0
            local real y0
            
            loop
                exitwhen 0 == preventAttackCount
                set preventAttackCount = preventAttackCount - 1
                
                set whichUnit = unitPrevented[preventAttackCount]
                
                if (null != whichUnit.unit) then
                    if (retreating[whichUnit]) then
                        call IssueImmediateOrderById(whichUnit.unit, 851972)
                        
                        set distance = rd[whichUnit]
                        set angle = ra[whichUnit]
                        set minRange = thistype(whichUnit).minRange + 128
                        set x = rx[whichUnit]
                        set y = ry[whichUnit]
                        set x0 = GetUnitX(whichUnit.unit)
                        set y0 = GetUnitY(whichUnit.unit)
                        loop
                            exitwhen not IsTerrainPathable(x, y, PATHING_TYPE_WALKABILITY) or angle > 4*bj_PI
                            set angle = angle + bj_PI/4
                            set x = x0 - distance*Cos(angle) + minRange*Cos(angle)
                            set y = y0 - distance*Sin(angle) + minRange*Sin(angle)
                        endloop
                        call IssuePointOrderById(whichUnit.unit, 851986,  x, y)
                    else
                        call DisableTrigger(resetTrigger)
                        if (0 != targets[whichUnit]) then
                            call IssueImmediateOrderById(whichUnit.unit, 851972)
                            if (0 == TimerGetRemaining(thistype(whichUnit).cooldownTimer)) then
                                call IssueTargetOrderById(whichUnit.unit, 851983, targets[whichUnit].unit)
                            else
                                if (thistype(whichUnit).maxRange < 256) then
                                    call IssuePointOrderById(whichUnit.unit, 851986, GetUnitX(targets[whichUnit].unit), GetUnitY(targets[whichUnit].unit))
                                else
                                    call IssueTargetOrderById(whichUnit.unit, 851986, targets[whichUnit].unit)
                                endif
                            endif
                        endif
                        call EnableTrigger(resetTrigger)
                    endif
                    
                    call whichUnit.unlock()
                    set prevented[whichUnit] = false
                    set retreating[whichUnit] = false
                endif
            endloop
        endmethod
    
        private static method attack takes nothing returns boolean
            local UnitIndex whichUnit = GetUnitUserData(GetAttacker())
            local real xu1 = GetUnitX(whichUnit.unit)
            local real yu1 = GetUnitY(whichUnit.unit)
            local real xu2 = GetUnitX(GetTriggerUnit())
            local real yu2 = GetUnitY(GetTriggerUnit())
            local real x = xu2 - xu1
            local real y = yu2 - yu1
            local real maxRange = thistype(whichUnit).maxRange
            local real minRange = thistype(whichUnit).minRange
            local real distance
            local real angle
            set maxRange = maxRange*maxRange
            set minRange = minRange*minRange
            set distance = x*x + y*y
            
            if (0 != TimerGetRemaining(thistype(whichUnit).cooldownTimer) or distance > maxRange or distance < minRange) then
                /*
                *   An invalid attack ran, handle id
                */
                
                /*
                *   Update the target
                */
                if (0 != targets[whichUnit]) then
                    call targets[whichUnit].unlock()
                endif
                
                set targets[whichUnit] = GetUnitUserData(GetTriggerUnit())
                call targets[whichUnit].lock()
                
                if (distance < minRange) then
                    /*
                    *   If distance too close, order unit to run away
                    */
                    set distance = SquareRoot(distance)
                    
                    set minRange = thistype(whichUnit).minRange + 128
                    set angle = Atan2(yu2 - yu1, xu2 - xu1) - bj_PI
                    
                    set rx[whichUnit] = GetUnitX(whichUnit.unit) - distance*Cos(angle) + minRange*Cos(angle)
                    set ry[whichUnit] = GetUnitY(whichUnit.unit) - distance*Sin(angle) + minRange*Sin(angle)
                    set rd[whichUnit] = distance
                    set ra[whichUnit] = angle
                    
                    set retreating[whichUnit] = true
                endif
                
                if (not prevented[whichUnit]) then
                    /*
                    *   If the attack hasn't been prevented yet, prevent the attack
                    */
                    set prevented[whichUnit] = true
                
                    if (0 == preventAttackCount) then
                        call TimerStart(preventAttackTimer, 0, false, function thistype.preventAttacks)
                    endif
                    
                    set unitPrevented[preventAttackCount] = whichUnit
                    set preventAttackCount = preventAttackCount + 1
                    
                    call whichUnit.lock()
                endif
            else
                /*
                *   Valid attack ran, reset cooldown
                */
                call TimerStart(thistype(whichUnit).cooldownTimer, thistype(whichUnit).cooldown, false, function thistype.runAttack)
            endif
        
            return false
        endmethod
        
        private static method reset takes nothing returns boolean
            local thistype this = GetUnitUserData(GetTriggerUnit())
            
            if (0 != targets[this]) then
                call targets[this].unlock()
                set targets[this] = 0
            endif
        
            return false
        endmethod
    
        private static method onInit takes nothing returns nothing
            local integer i = 15
            local trigger t = CreateTrigger()
            
            call TriggerAddCondition(t, Condition(function thistype.attack))
            call TriggerAddCondition(resetTrigger, Condition(function thistype.reset))
            
            set table = Table.create()
            
            loop
                call TriggerRegisterPlayerUnitEvent(t, Player(i), EVENT_PLAYER_UNIT_ATTACKED, null)
                call TriggerRegisterPlayerUnitEvent(resetTrigger, Player(i), EVENT_PLAYER_UNIT_ISSUED_ORDER, null)
                call TriggerRegisterPlayerUnitEvent(resetTrigger, Player(i), EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, null)
                call TriggerRegisterPlayerUnitEvent(resetTrigger, Player(i), EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, null)
                exitwhen 0 == i
                set i = i - 1
            endloop
            
            set t = null
        endmethod
        
        implement UnitIndexStruct
    endstruct
    
    struct UnitAttack extends array
        method operator maxRange takes nothing returns real
            return Attack_p(this).maxRange
        endmethod
        method operator maxRange= takes real maxRange returns nothing
            set Attack_p(this).maxRange = maxRange
        endmethod
        method operator minRange takes nothing returns real
            return Attack_p(this).minRange
        endmethod
        method operator minRange= takes real minRange returns nothing
            set Attack_p(this).minRange = minRange
        endmethod
        method operator cooldown takes nothing returns real
            return Attack_p(this).cooldown
        endmethod
        method operator target takes nothing returns UnitIndex
            return Attack_p.targets[this]
        endmethod
        method operator acquireRange takes nothing returns real
            return GetUnitAcquireRange(GetUnitById(this))
        endmethod
        method operator acquireRange= takes real acquireRange returns nothing
            if (acquireRange < 64) then
                call SetUnitAcquireRange(GetUnitById(this), 64)
            else
                call SetUnitAcquireRange(GetUnitById(this), acquireRange)
            endif
        endmethod
        method operator cooldown= takes real cooldown returns nothing
            if (cooldown > TimerGetRemaining(Attack_p(this).cooldownTimer)) then
                call TimerStart(Attack_p(this).cooldownTimer, TimerGetRemaining(Attack_p(this).cooldownTimer) + cooldown - Attack_p(this).cooldown, false, function Attack_p.runAttack)
            else
                call Attack_p(this).doAttack()
                call TimerStart(Attack_p(this).cooldownTimer, 0, false, null)
            endif
            set Attack_p(this).cooldown = cooldown
        endmethod
        implement UnitIndexStructMethods
    endstruct
endlibrary