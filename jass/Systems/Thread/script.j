library Thread /* v2.0.1.1
*************************************************************************************
*
*   This script allows one to sync up threads between players. It is most useful for
*   preventing players from desyncing due to heavy local code blocks as well as syncing
*   up large streams of data.
*
*************************************************************************************
*
*   */uses/*
*
*       *  Alloc  *         hiveworkshop.com/forums/jass-resources-412/snippet-alloc-192348/
*       */ WorldBounds /*   hiveworkshop.com/forums/jass-resources-412/snippet-worldbounds-180494/
*
************************************************************************************
*
*   SETTINGS
*/
globals
    /*
    *   This unit can be retrieved from the map attached to this thread. Copy and paste
    *   the unit in the map into target map and then put the unit type id of that unit here.
    */
    private constant integer UNIT_SYNC_ID = 'h000'
endglobals
/*
************************************************************************************
*
*   function SynchronizeThread takes nothing returns nothing
*       -   synchronizes a thread
*
*   struct Thread extends array
*
*       readonly boolean synced
*           -   loop until this is true
*
*       static method create takes nothing returns Thread
*       method destroy takes nothing returns nothing
*
*       method sync takes nothing returns nothing
*           -   call from local player when that local player's operation is complete
*
*       method wait takes nothing returns nothing
*           -   wait for synchronization to complete
*
*   Examples
*
*       local Thread thread = Thread.create()
*
*       if (GetLocalPlayer() != targetPlayer) then
*           call thread.sync()  //synchronize waiting players
*       endif
* 
*       loop
*           if (GetLocalPlayer() == targetPlayer) then
*               //the hefty operation here should segment how much it does per iteration
*               //too much per iteration and slower computers will desync from the sheer magnitude
*               //of the operation
*               //this will have to be fine tuned based on the size of the operation
*               if (doHeftyOperation()) then
*                   call thread.sync()
*               endif
*           endif
*
*           call TriggerSyncReady()
*           exitwhen thread.synced
*       endloop
*
*       call thread.destroy()
*
*************************************************************************************/
    private keyword threadSyncer

    private module OnInit
        /*
        *   Struct Initialization
        */
        private static method onInit takes nothing returns nothing
            local integer playerId = 11
            local integer power = 2048
            set endPower = 0
            
            set syncThreadTrigger = CreateTrigger()
            call TriggerAddCondition(syncThreadTrigger, Condition(function thistype.syncThread))
            
            loop
                if (GetPlayerSlotState(Player(playerId)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(playerId)) == MAP_CONTROL_USER) then
                    call TriggerRegisterPlayerUnitEvent(syncThreadTrigger, Player(playerId), EVENT_PLAYER_UNIT_SELECTED, null)
                endif
                set playerPower[playerId] = power
                set endPower = endPower + power
                set power = power/2
                exitwhen 0 == playerId
                set playerId = playerId - 1
            endloop
        endmethod
    endmodule

    struct Thread extends array
        implement Alloc
        
        unit threadSyncer
        
        private static trigger syncThreadTrigger
        private integer count
        private static integer array playerPower
        private static integer endPower
        private boolean synced_p
        
        method operator synced takes nothing returns boolean
            local integer val
            local integer playerId = 11
            
            if (synced_p) then
                return true
            endif
            
            loop
                if (GetPlayerSlotState(Player(playerId)) != PLAYER_SLOT_STATE_PLAYING or GetPlayerController(Player(playerId)) != MAP_CONTROL_USER) then
                    set val = count/playerPower[playerId]
                    if (val - val/2*2 == 0) then
                        set count = count + playerPower[playerId]
                    endif
                endif
                
                exitwhen 0 == playerId
                set playerId = playerId - 1
            endloop
            
            set synced_p = count == endPower
            
            return synced_p
        endmethod
        
        static method create takes nothing returns thistype
            local thistype this = allocate()
            
            if (null == threadSyncer) then
                static if LIBRARY_UnitIndexer then
                    set UnitIndexer.enabled = false
                endif
                
                set threadSyncer = CreateUnit(Player(0), UNIT_SYNC_ID, WorldBounds.maxX, WorldBounds.maxY, 0)
                call SetUnitUserData(threadSyncer, this)
                call PauseUnit(threadSyncer, true)
                call SetUnitX(threadSyncer, WorldBounds.maxX)
                call SetUnitY(threadSyncer, WorldBounds.maxY)
                
                static if LIBRARY_UnitIndexer then
                    set UnitIndexer.enabled = true
                endif
            endif
            
            return this
        endmethod
        
        method destroy takes nothing returns nothing
            set count = 0
            set synced_p = false
            call deallocate()
        endmethod
        
        /*
        *   Call within a local block
        */
        method sync takes nothing returns nothing
            call SelectUnit(threadSyncer, true)
            call SelectUnit(threadSyncer, false)
        endmethod
        
        method wait takes nothing returns nothing
            loop
                call TriggerSyncStart()
                exitwhen synced_p
                call TriggerSyncReady()
            endloop
        endmethod
        
        private static method syncThread takes nothing returns boolean
            local thistype this = GetUnitUserData(GetTriggerUnit())
            local integer playerId = GetPlayerId(GetTriggerPlayer())
            local integer val
            
            if (threadSyncer != GetTriggerUnit()) then
                return false
            endif
            
            set val = count/playerPower[playerId]
            if (val - val/2*2 == 0) then
                set count = count + playerPower[playerId]
            endif
            
            set playerId = 11
            loop
                if (GetPlayerSlotState(Player(playerId)) != PLAYER_SLOT_STATE_PLAYING or GetPlayerController(Player(playerId)) != MAP_CONTROL_USER) then
                    set val = count/playerPower[playerId]
                    if (val - val/2*2 == 0) then
                        set count = count + playerPower[playerId]
                    endif
                endif
                
                exitwhen 0 == playerId
                set playerId = playerId - 1
            endloop
            
            set synced_p = count == endPower
            
            return false
        endmethod
        
        implement OnInit
    endstruct
    
    function SynchronizeThread takes nothing returns nothing
        local Thread thread = Thread.create()
        call thread.sync()
        call thread.wait()
        call thread.destroy()
    endfunction
endlibrary