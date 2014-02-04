library GameStart /* v2.0.0.0
*************************************************************************************
*
*   Used to detect when all players have finished loading
*
*************************************************************************************
*
*   */uses/*
*
*       */ Thread       /*  hiveworkshop.com/forums/submissions-414/snippet-thread-218269/
*
************************************************************************************
*
*   function IsGameStarted takes nothing returns boolean
*   function WaitForGameToStart takes nothing returns nothing
*       -   Stops the thread until the game is started
*
*************************************************************************************/
    globals
        private boolean gameStarted = false
        private integer count = 0
    endglobals
    
    function IsGameStarted takes nothing returns boolean
        return gameStarted
    endfunction
    function WaitForGameToStart takes nothing returns nothing
        loop
            exitwhen gameStarted
            call TriggerSyncStart()
            call TriggerSyncReady()
        endloop
    endfunction
    
    private module InitMod
        private static method onInit takes nothing returns nothing
            call init()
        endmethod
    endmodule
    private struct Init extends array
        private static method run takes nothing returns nothing
            local Thread thread = Thread.create()
            call thread.sync()
            call thread.wait()
            call thread.destroy()
            set gameStarted = true
        endmethod
        private static method init takes nothing returns nothing
            call run.execute()
        endmethod
        implement InitMod
    endstruct
endlibrary