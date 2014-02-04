/*Utility Information
//===================================================================
Name: GameTime
Version: 1.0
Author: Nestharus

Description: This will track the game time.

Requirements: None

Installation: NA

Usage:
------------------------------------------------------------------
-GetElapsedGameTime takes nothing returns real
 will return the current elapsed game time
 
 local real currentGameTime = GetElapsedGameTime()
------------------------------------------------------------------*/
//===================================================================

library GameTime initializer Initialization
    globals
        private timer gameTime = CreateTimer()
    endglobals
    
    function GetElapsedGameTime takes nothing returns real
        return TimerGetElapsed(gameTime)
    endfunction
    
    private function Initialization takes nothing returns nothing
        call TimerStart(gameTime, 1000000, false, null)
    endfunction
endlibrary