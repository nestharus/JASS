library IsPathBlocked /* v4.0.0.1
************************************************************************************
*
*   function IsPathBlocked takes unit obstruction returns boolean
*       -   Determines whether or not there is a path after a new unit is placed
*
*   function LoadPathingMap takes nothing returns nothing
*       -   Loads pathing for map
*       -   Call before using system
*
************************************************************************************
*
*   */uses/*
*
*       */ IsPathable /*                hiveworkshop.com/forums/submissions-414/snippet-ispathable-199131/
*       */ RegisterPlayerUnitEvent /*   hiveworkshop.com/forums/jass-resources-412/snippet-registerplayerunitevent-203338/
*       */ UnitIndexer /*               hiveworkshop.com/forums/jass-resources-412/system-unit-indexer-172090/
*       */ GetUnitCollision /*          hiveworkshop.com/forums/submissions-414/snippet-needs-work-getunitcollision-180495/
*
************************************************************************************
*
*   SETTINGS
*
*       This is how much work is done per thread when loading pathing map.
*       Tweak this value in debug mode until the pathing map crash message goes away to minimize load time.
*/
globals
    private constant integer BUFFER = 6500
endglobals
/*
************************************************************************************/
    private module Init
        private static method onInit takes nothing returns nothing
            call init()
        endmethod
    endmodule
    
    private function Normalize takes real coordinate returns integer
        if (0 < coordinate) then
            return R2I(coordinate + 16)/32*32
        endif
        return R2I(coordinate - 16)/32*32
    endfunction
    
    private struct Pathing extends array
        private static hashtable map = null
        
        static method isBlocked takes integer x, integer y returns boolean
            return HaveSavedBoolean(map, x, y)
        endmethod
        static method resetBlock takes integer x, integer y returns nothing
            call RemoveSavedBoolean(map, x, y)
        endmethod
        static method setBlock takes integer x, integer y returns nothing
            call SaveBoolean(map, x, y, true)
        endmethod
        
        private static method initHashtables takes nothing returns nothing
            call FlushParentHashtable(map)
            set map = InitHashtable()
        endmethod
        
        private static method init takes nothing returns nothing
            call initHashtables()
        endmethod
        implement Init
        
        static method reset takes nothing returns nothing
            call initHashtables()
        endmethod
    endstruct
    
    private struct TargetTable extends array
        private static hashtable target = InitHashtable()
        readonly static integer count = 0
        
        static method remove takes integer x, integer y returns nothing
            if (HaveSavedBoolean(target, x, y)) then
                call RemoveSavedBoolean(target, x, y)
                set count = count - 1
            endif
        endmethod
        static method add takes integer x, integer y returns nothing
            call SaveBoolean(target, x, y, true)
            set count = count + 1
        endmethod
        
        static method reset takes nothing returns nothing
            call FlushParentHashtable(target)
            set target = InitHashtable()
            set count = 0
        endmethod
    endstruct
    
    private struct HitTable extends array
        private static hashtable isHit = InitHashtable()
        
        method operator [] takes integer y returns boolean
            return HaveSavedBoolean(isHit, this, y)
        endmethod
        static method hit takes integer x, integer y returns nothing
            call SaveBoolean(isHit, x, y, true)
            call TargetTable.remove(x, y)
        endmethod
        static method reset takes nothing returns nothing
            call FlushParentHashtable(isHit)
            set isHit = InitHashtable()
        endmethod
    endstruct
    
    private struct BranchList extends array
        readonly thistype next
        
        static method add takes thistype branch returns nothing
            if (0 == branch) then
                return
            endif
        
            set branch.next = thistype(0).next
            set thistype(0).next = branch
        endmethod
        static method pop takes nothing returns nothing
            set thistype(0).next = thistype(0).next.next
        endmethod
        static method operator empty takes nothing returns boolean
            return thistype(0).next == 0
        endmethod
        
        static method reset takes nothing returns nothing
            set thistype(0).next = 0
        endmethod
    endstruct
    
    private struct Branch extends array
        private static integer instanceCount = 0
        private static integer array recycler
        private static method allocate takes nothing returns thistype
            local thistype this = recycler[0]
            if (0 == this) then
                set this = instanceCount + 1
                set instanceCount = this
            else
                set recycler[0] = recycler[this]
            endif
            return this
        endmethod
        private method deallocate takes nothing returns nothing
            set recycler[this] = recycler[0]
            set recycler[0] = this
        endmethod
        
        readonly integer x
        readonly integer y
        readonly integer dx
        readonly integer dy
        
        readonly boolean leftOpen
        readonly boolean rightOpen
        readonly boolean bottomOpen
        readonly boolean topOpen
        
        readonly boolean leftOpenPast
        readonly boolean rightOpenPast
        readonly boolean bottomOpenPast
        readonly boolean topOpenPast
        
        static method create takes integer x, integer y, integer dx, integer dy, thistype parent returns thistype
            local thistype this = 0
            
            if (not Pathing.isBlocked(x, y) and not HitTable[x][y]) then
                set this = allocate()
                
                set this.x = x
                set this.y = y
                set this.dx = dx
                set this.dy = dy
                
                if (0 == dx) then
                    set leftOpen = not Pathing.isBlocked(x - 64, y)
                    set rightOpen = not Pathing.isBlocked(x + 64, y)
                    
                    set leftOpenPast = leftOpen
                    set rightOpenPast = rightOpen
                    
                    set bottomOpen = true
                    set topOpen = true
                    set bottomOpenPast = true
                    set topOpenPast = true
                else
                    set bottomOpen = not Pathing.isBlocked(x, y - 64)
                    set topOpen = not Pathing.isBlocked(x, y + 64)
                    
                    set bottomOpenPast = bottomOpen
                    set topOpenPast = topOpen
                    
                    set leftOpen = true
                    set rightOpen = true
                    set leftOpenPast = true
                    set rightOpenPast = true
                endif
                
                if (leftOpen and rightOpen and bottomOpen and topOpen) then
                    if (parent != 0) then
                        if (0 == dx) then
                            call BranchList.add(create(x + 64, y, 64, 0, 0))
                            call BranchList.add(create(x - 64, y, -64, 0, 0))
                        else
                            call BranchList.add(create(x, y + 64, 0, 64, 0))
                            call BranchList.add(create(x, y - 64, 0, -64, 0))
                        endif
                    endif
                
                    call destroy()
                    return 0
                endif
                
                call HitTable.hit(x, y)
            endif
            
            return this
        endmethod
        method move takes nothing returns boolean
            set x = x + dx
            set y = y + dy
            
            if (0 == dx) then
                set leftOpenPast = leftOpen
                set rightOpenPast = rightOpen
                set leftOpen = not Pathing.isBlocked(x - 64, y)
                set rightOpen = not Pathing.isBlocked(x + 64, y)
            else
                set bottomOpenPast = bottomOpen
                set topOpenPast = topOpen
                set bottomOpen = not Pathing.isBlocked(x, y - 64)
                set topOpen = not Pathing.isBlocked(x, y + 64)
            endif
            
            if (leftOpen and rightOpen and bottomOpen and topOpen) then
                return false
            endif
            
            if (not Pathing.isBlocked(x, y) and not HitTable[x][y]) then
                call HitTable.hit(x, y)
                return true
            endif
            
            set x = x - dx
            set y = y - dy
            
            return false
        endmethod
        method destroy takes nothing returns nothing
            call deallocate()
        endmethod
        
        static method reset takes nothing returns nothing
            set instanceCount = 0
            set recycler[0] = 0
        endmethod
    endstruct
    
    private function ExpandBranch takes Branch branch returns nothing
        if (branch.leftOpenPast != branch.leftOpen) then
            if (branch.leftOpen) then
                call BranchList.add(Branch.create(branch.x - 64, branch.y, -64, 0, branch))
            else
                call BranchList.add(Branch.create(branch.x - 64, branch.y - branch.dy, -64, 0, branch))
            endif
        endif
        if (branch.rightOpenPast != branch.rightOpen) then
            if (branch.rightOpen) then
                call BranchList.add(Branch.create(branch.x + 64, branch.y, 64, 0, branch))
            else
                call BranchList.add(Branch.create(branch.x + 64, branch.y - branch.dy, 64, 0, branch))
            endif
        endif
        if (branch.bottomOpenPast != branch.bottomOpen) then
            if (branch.bottomOpen) then
                call BranchList.add(Branch.create(branch.x, branch.y - 64, 0, -64, branch))
            else
                call BranchList.add(Branch.create(branch.x - branch.dx, branch.y - 64, 0, -64, branch))
            endif
        endif
        if (branch.topOpenPast != branch.topOpen) then
            if (branch.topOpen) then
                call BranchList.add(Branch.create(branch.x, branch.y + 64, 0, 64, branch))
            else
                call BranchList.add(Branch.create(branch.x - branch.dx, branch.y + 64, 0, 64, branch))
            endif
        endif
    endfunction
    globals
        private boolean crashed
        private boolean iterateBranches_finished
    endglobals
    private function IterateBranches takes nothing returns nothing
        local Branch branch
        local integer rounds = 1100
        local boolean dest
        
        debug set crashed = true
        loop
            set branch = BranchList(0).next
            set rounds = rounds - 1
            
            set dest = not branch.move()
            if (dest) then
                call BranchList.pop()
                
                if (0 == branch.dx) then
                    call BranchList.add(Branch.create(branch.x - 64, branch.y, -64, 0, branch))
                    call BranchList.add(Branch.create(branch.x + 64, branch.y, 64, 0, branch))
                else
                    call BranchList.add(Branch.create(branch.x, branch.y - 64, 0, -64, branch))
                    call BranchList.add(Branch.create(branch.x, branch.y + 64, 0, 64, branch))
                endif
                
                call branch.destroy()
            else
                call ExpandBranch(branch)
            endif
            
            exitwhen 0 == TargetTable.count or BranchList.empty or 0 == rounds
        endloop
        debug set crashed = false
        
        set iterateBranches_finished = 0 == TargetTable.count or BranchList.empty
    endfunction
    
    private struct Spaces extends array
        private static integer array x
        private static integer array y
        private static integer array dx
        private static integer array dy
        private static integer count = 0
        
        static method getOpen takes integer x, integer y, integer endX, integer endY, integer dx, integer dy, boolean onBlock, boolean last returns boolean
            local boolean open
            
            loop
                if (onBlock) then
                    //find open
                    loop
                        set open = not Pathing.isBlocked(x, y)
                        exitwhen open or (x == endX and y == endY)
                        set x = x + dx
                        set y = y + dy
                    endloop
                    exitwhen not open
                    set onBlock = false
                    
                    if (x == endX and y == endY) then
                        return true
                    endif
                    if (thistype.x[0] == x and thistype.y[0] == y) then
                        return false
                    endif
                    set thistype.x[count] = x
                    set thistype.y[count] = y
                    set thistype.dx[count] = dx
                    set thistype.dy[count] = dy
                    set count = count + 1
                    
                    exitwhen last
                else
                    //find block
                    loop
                        set open = not Pathing.isBlocked(x, y)
                        exitwhen not open or (x == endX and y == endY)
                        set x = x + dx
                        set y = y + dy
                    endloop
                    exitwhen open
                    set onBlock = true
                endif
                
                exitwhen x == endX and y == endY
                set x = x + dx
                set y = y + dy
            endloop
            
            return onBlock
        endmethod
        static method registerTargets takes nothing returns nothing
            if (0 == count) then
                return
            endif
            
            loop
                set count = count - 1
                exitwhen count == 0
                
                call TargetTable.add(x[count], y[count])
            endloop
        endmethod
        static method operator originX takes nothing returns integer
            return thistype.x[0]
        endmethod
        static method operator originY takes nothing returns integer
            return thistype.y[0]
        endmethod
        static method operator originDY takes nothing returns integer
            return thistype.dy[0]
        endmethod
        static method operator originDX takes nothing returns integer
            return thistype.dx[0]
        endmethod
        static method reset takes nothing returns nothing
            set x[0] = 1
            set y[0] = 1
        endmethod
    endstruct
    private function RegisterTargets takes integer x, integer y, integer radius returns nothing
        local boolean onBlock
        local integer inner = radius - 32
        local integer outer = radius + 32
        
        call Spaces.reset()
        
        set onBlock = Spaces.getOpen(x - inner, y + outer, x + outer, y + outer, 64, 0, false, false)
        set onBlock = Spaces.getOpen(x + outer, y + inner, x + outer, y - outer, 0, -64, onBlock, false)
        set onBlock = Spaces.getOpen(x + inner, y - outer, x - outer, y - outer, -64, 0, onBlock, false)
        set onBlock = Spaces.getOpen(x - outer, y - inner, x - outer, y + outer, 0, 64, onBlock, false)
        if (onBlock) then
            call Spaces.getOpen(x - inner, y + outer, x + outer, y + outer, 64, 0, true, true)
        endif
        
        call Spaces.registerTargets()
        if (TargetTable.count != 0) then
            if (not Pathing.isBlocked(Spaces.originX - 64, Spaces.originY)) then
                call BranchList.add(Branch.create(Spaces.originX, Spaces.originY, -64, 0, 0))
            endif
            
            if (not Pathing.isBlocked(Spaces.originX + 64, Spaces.originY)) then
                call BranchList.add(Branch.create(Spaces.originX, Spaces.originY, 64, 0, 0))
            endif
            
            if (not Pathing.isBlocked(Spaces.originX, Spaces.originY + 64)) then
                call BranchList.add(Branch.create(Spaces.originX, Spaces.originY, 0, 64, 0))
            endif
            
            if (not Pathing.isBlocked(Spaces.originX, Spaces.originY - 64)) then
                call BranchList.add(Branch.create(Spaces.originX, Spaces.originY, 0, -64, 0))
            endif
        endif
    endfunction
    private function Reset takes nothing returns nothing
        call TargetTable.reset()
        call HitTable.reset()
        call Branch.reset()
        call BranchList.reset()
    endfunction
    private function FindPath takes nothing returns boolean
        if (0 == TargetTable.count) then
            return true
        endif
        
        set iterateBranches_finished = false
        loop
            call IterateBranches.evaluate()
            exitwhen iterateBranches_finished
            debug if (crashed) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"IS PATH BLOCKED: BRANCH ITERATION CRASH")
                debug return false
            debug endif
        endloop
        return 0 == TargetTable.count
    endfunction
    private function IsBlocked takes integer x, integer y, integer radius returns boolean
        local boolean pathFound
        
        call RegisterTargets(x, y, radius)
        
        set pathFound = FindPath()
        
        call Reset()
        
        return not pathFound
    endfunction
    function IsPathBlocked takes unit obstruction returns boolean
        return IsBlocked(Normalize(GetUnitX(obstruction)), Normalize(GetUnitY(obstruction)), Normalize(GetUnitCollision(obstruction)))
    endfunction
    
    globals
        private boolean array unitPathable
    endglobals
    private function UpdateUnitPathing takes unit whichUnit, boolean pathable returns nothing
        local integer x
        local integer y
        local integer startX
        local integer startY
        local integer endX
        local integer endY
        local integer inner
        
        if (unitPathable[GetUnitUserData(whichUnit)] != pathable) then
            set unitPathable[GetUnitUserData(whichUnit)] = pathable
            
            set inner = Normalize(GetUnitCollision(whichUnit)) - 32
            if (0 < inner) then
                set x = Normalize(GetUnitX(whichUnit))
                set y = Normalize(GetUnitY(whichUnit))
                
                set startX = x - inner
                set startY = y - inner
                set endX = x + inner
                set endY = y + inner
                set x = startX
                set y = startY
                
                loop
                    loop
                        if (pathable) then
                            call Pathing.setBlock(x, y)
                        else
                            call Pathing.resetBlock(x, y)
                        endif
                        exitwhen y == endY
                        set y = y + 64
                    endloop
                    exitwhen x == endX
                    set x = x + 64
                    
                    set y = startY
                endloop
            endif
        endif
    endfunction
    private function OnIndex takes nothing returns boolean
        if (IsUnitType(GetIndexedUnit(), UNIT_TYPE_STRUCTURE)) then
            call UpdateUnitPathing(GetIndexedUnit(), true)
        endif
        return false
    endfunction
    private function OnDeindex takes nothing returns boolean
        if (null == GetIndexedUnit()) then
            if (IsUnitType(GetTriggerUnit(), UNIT_TYPE_STRUCTURE)) then
                call UpdateUnitPathing(GetTriggerUnit(), false)
            endif
        else
            if (IsUnitType(GetIndexedUnit(), UNIT_TYPE_STRUCTURE)) then
                call UpdateUnitPathing(GetIndexedUnit(), false)
            endif
        endif
        return false
    endfunction
    
    globals
        private integer buffer_y
        private unit buffer_path_checker
        private boolean buffer_crashed
        private boolean buffer_finished
    endglobals
    private function PathingMapBuffer takes nothing returns nothing
        local integer rounds = BUFFER
        
        local integer x
        local integer y = buffer_y
        local integer endX = WorldBounds.maxX - 32 - 64
        local integer endY = WorldBounds.maxY - 32 - 64
        local integer dRounds = (WorldBounds.maxX - WorldBounds.minX)/64 - 1
        
        debug set buffer_crashed = true
        loop
            set x = WorldBounds.minX - 32 + 64
            loop
                call SetUnitPosition(buffer_path_checker, x, y)
                if (GetUnitX(buffer_path_checker) != x or GetUnitY(buffer_path_checker) != y) then
                    call Pathing.setBlock(x, y)
                endif
                
                set x = x + 64
                exitwhen x == endX
            endloop
                
            set rounds = rounds - dRounds
            set y = y + 64
            exitwhen y == endY or 1 > rounds
        endloop
        debug set buffer_crashed = false
        
        set buffer_y = y
        
        set buffer_finished = y == endY
    endfunction
    function LoadPathingMap takes nothing returns nothing
        call Pathing.reset()
        
        set buffer_y = WorldBounds.minY + 32 + 64
        set buffer_path_checker = GetPathingUnit(PATH_TYPE_WALKABILITY)
        
        set buffer_finished = false
        
        set UnitIndexer.enabled = false
        loop
            call PathingMapBuffer.evaluate()
            exitwhen buffer_finished
            debug if (buffer_crashed) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,"IS PATH BLOCKED: PATHING BUFFER CRASHED")
                debug return
            debug endif
        endloop
        call SetUnitX(buffer_path_checker, WorldBounds.minX)
        call SetUnitY(buffer_path_checker, WorldBounds.minY)
        set UnitIndexer.enabled = true
        
        set buffer_path_checker = null
    endfunction
    
    private struct Inits extends array
        private static method init takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function OnDeindex)
            call RegisterUnitIndexEvent(Condition(function OnIndex), UnitIndexer.INDEX)
            call RegisterUnitIndexEvent(Condition(function OnDeindex), UnitIndexer.DEINDEX)
        endmethod
        
        implement Init
    endstruct
endlibrary