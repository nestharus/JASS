library PlayerAllianceAdv /* v1.0.1.4
*************************************************************************************
*
*   Manages player alliances (like allied and shared vision) between players using alliance
*   flags and counts of the different flags. The highest flag is the flag that is enabled (
*   if 2 players are marked as an enemy and they are also marked as allied, the allied flag
*   will be the one that's used). Alliances can be created and destroyed. As alliances are created, 
*   a counter is incremented for that alliance between the two players. When the alliance is destroyed,
*   the counter is decremented. If the counter reaches 0, the next flag is used. If there are no flags, 
*   a flag of 0 is used (ALLIANCE_UNALLIED).
*
*   Alliances are stored into a composite number (a number made up of numbers that are mashed together).
*
*************************************************************************************
*
*   */uses/*
*   
*       */ PlayerAlliance /*       hiveworkshop.com/forums/submissions-414/snippet-playeralliance-192941/
*
*************************************************************************************
*
*   function GetAllianceId takes integer playerId1, integer playerId2, integer allianceFlag returns PlayerAlliance
*       -   Converts playerId1, playerId2, allianceFlag into a composite number representing the alliance
*   function GetAlliance takes integer playerId1, integer playerId2 returns integer
*       -   Returns current alliance flag between players.
*
*************************************************************************************
*
*   struct PlayerAlliance extends array
*
*       -   Struct that generates alliances between players. Alliances aren't instantiated but rather
*       -   built into an id. The id is then used to increase a counter related to that alliance by 1.
*       -   It will then check the best current alliance against the one just created. If the one created
*       -   is better, it will use it (allied > enemy), otherwise it'll ignore it and possibly use later.
*       -   The id stores the player 1 id, player 2 id, and the alliance flag.
*
*       readonly PlayerAlliance previous
*           -   Used for reading the values stored in the id (returns pointers**)
*           -   alliance flag -> target player -> source player
*       readonly integer value
*           -   Used to read the value inside of a pointer
*       static method create takes player sourcePlayer, player targetPlayer, integer allianceFlag returns PlayerAlliance
*           -   Creates an alliance between a source player and a target player given an alliance flag (see
*           -   player alliance lib for flags). If the alliance passed in is higher than the best current alliance
*           -   between the two players, it will immediately be used (passive -> ally). If it isn't, it'll be ignored
*           -   until later (passive doesn't go to enemy).
*       method destroy takes nothing returns nothing
*           -   Destroys a player alliance. Will decrease the counter of the alliance between the players by 1.
*           -   If the counter was 0, it goes down to the next highest flag (allied might degrade to passive).
*
************************************************************************************/
    globals
        /*************************************************************************************
        *
        *   Converters
        *
        *       Composite number converters (to avoid math) int[16][16][8]
        *
        *************************************************************************************/
        private integer array cp    //previous composite number
        private integer array cv    //value stored at the back of the number
        
        /*************************************************************************************
        *
        *   Player Alliance
        *
        *************************************************************************************/
        private integer array aa    //strength of player alliance (how many times flag was set)
        private integer array ah    //highest flag set on player alliance
    endglobals
    
    /*************************************************************************************
    *
    *   GetAlliance
    *
    *       Retrieves the current alliance flag between two players.
    *
    *       integer pid1:           Source player of alliance
    *       integer pid2:           Target player of alliance
    *
    *       returns:                integer (alliance flag)
    *
    *************************************************************************************/
    function GetAlliance takes integer pid1, integer pid2 returns integer
        return ah[pid1*16+pid2]
    endfunction
    
    /*************************************************************************************
    *
    *   PlayerAlliance
    *
    *       Can take a composite number and loop through the values stored inside of it as well as
    *       split it apart. Also creates player alliances and destroys them. When a player alliance is
    *       created, it increases the counter between those two players for that alliance. If the flag is
    *       higher than the current alliance flag for the two players, that alliance is used. If not, the
    *       alliance is ignored. When alliances are destroyed, the method will search for flags that are
    *       being used and implement those flags (two players might be allied for a short period and then
    *       go back to passive, yes, they stack!).
    *
    *   Fields
    *
    *       readonly PlayerAlliance previous
    *       readonly integer value
    *
    *   Methods
    *
    *       static method create takes player p1, player p2, integer flag returns thistype
    *       method destroy takes nothing returns nothing
    *       method operator previous takes nothing returns thistype
    *       method operator value takes nothing returns integer
    *
    *************************************************************************************/
    struct PlayerAlliance extends array
        /*************************************************************************************
        *
        *   previous
        *
        *       Retrieves the previous node
        *       flag -> player 2 -> player 1
        *
        *************************************************************************************/
        method operator previous takes nothing returns thistype
            return cp[this]
        endmethod
        
        /*************************************************************************************
        *
        *   value
        *
        *       Retrieves the value stored in the current plyer alliance node (player ids or
        *       alliance flag).
        *
        *************************************************************************************/
        method operator value takes nothing returns integer
            return cv[this]
        endmethod
    
        /*************************************************************************************
        *
        *   create
        *
        *       Creates a player alliance and returnst he instance of it (instances are not unique!)
        *       alliances may be created and destroyed multiple times. A counter is stored in the background
        *       that tracks how many times an instance has been created/destroyed. At map init, all instances
        *       are automatically generated (all of the lists).
        *
        *       player p1:              Source ally player
        *       player p2:              Target ally player
        *       integer flag:           Alliance flag (see PlayerAlliance lib)
        *
        *       returns:                PlayerAlliance
        *
        *************************************************************************************/
        static method create takes player p1, player p2, integer flag returns thistype
            local integer pid       //player id of p1
            local integer pid2      //player id of p2
            local thistype i_1      //pid,pid2
            local thistype i_2      //pid2,pid
            local thistype i1       //this 1
            local thistype i2       //this 2
            //if the flag is >= 0 and <= 7, it was a valid alliance
            debug if (flag >= 0 and flag <= 7 and p1 != null and p2 != null and p1 != p2) then
                set pid = GetPlayerId(p1)
                set pid2 = GetPlayerId(p2)
                //retrieve instances
                set i_1 = pid*16+pid2
                set i_2 = pid2*16+pid
                set i1 = i_1*8+flag   //this is a composite number of p1, p2 and flag
                set i2 = i_2*8+flag   //this 2 is a composite number of p2, p1 and flag
                //increment instances usages by 1
                set aa[i1] = aa[i1]+1
                set aa[i2] = aa[i2]+1
                
                //check to see if the current flag is bigger than the highest flag set for the players
                if (flag > ah[i_1]) then
                    //if it is, then update the player alliances
                    set ah[i_1] = flag
                    set ah[i_2] = flag
                    call Ally(p1, p2, flag)
                endif
            debug else
                debug if (p1 == null) then
                    debug call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "PLAYER ALLIANCE ERROR: NULL PLAYER 1 ")
                debug endif
                debug if (p2 == null) then
                    debug call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "PLAYER ALLIANCE ERROR: NULL PLAYER 2 ")
                debug endif
                debug if (p1 == p2) then
                    debug call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "PLAYER ALLIANCE ERROR: PLAYER 1 == PLAYER 2 ")
                debug endif
                debug if (flag < 0 or flag > 7) then
                    debug call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "PLAYER ALLIANCE ERROR: INVALID ALLIANCE FLAG")
                debug endif
                return 0
            debug endif
            return i1
        endmethod
        
        /*************************************************************************************
        *
        *   destroy
        *
        *       Destroys a player alliance (they may be destroyed as many times as they were created).
        *
        *       returns:                nothing
        *
        *************************************************************************************/
        method destroy takes nothing returns nothing
            //modulo math doesn't need to be used to split the number apart
            //as all of the splits are stored into a list
            //flag -> player 2 -> player 1
            //values are stored into cv
            //i1,i2 are instances, pidc and pidc2 are composite pid numbers (pid*16+pid2 etc)
            //only the first node on the list is a valid composite number, the rest
            //are just pointers
            //thus pidc and pidc2 have to be built, but i1 does not
            local integer i1 = this             //i1 == this
            local integer flag = cv[i1]         //alliance flag
            local integer pidc = cp[i1]         //use initially to get prev
            local integer pidc2
            local integer pid2 = cv[pidc]       //player 2
            local integer pid = cv[cp[pidc]]    //player 1
            local integer i2
            //ensure that the instance is valid*
            debug if (i1 <= 2039 and i1 >= 8) then 
                set pidc = pid*16+pid2
                set pidc2 = pid2*16+pid
                set i2 = pidc2*8+flag       //retrieve other instance
                //make sure instantiated
                debug if (aa[i1] > 0) then
                    set aa[i1] = aa[i1]-1
                    set aa[i2] = aa[i2]-1
                    
                    //if deallocated and flag isn't 0, go to next highest flag
                    if (aa[i1] == 0 and flag > 0) then
                        //loop until found a flag that has count > 0 or no more flags
                        loop
                            set flag = flag - 1
                            //build composite number using current flag
                            set i1 = pidc*8+flag
                            //check to see if there is an alliance in the flag or if the flag is 0
                            exitwhen aa[i1] > 0 or flag == 0
                        endloop
                        //update highest flag
                        set ah[pidc] = flag
                        set ah[pidc2] = flag
                        //ally players using new flag
                        call Ally(Player(pid), Player(pid2), flag)
                    endif
                debug else
                    debug call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "PLAYER ALLIANE ERROR: ATTEMPTED TO DESTROY NULL ALLIANCE")
                debug endif
            debug else
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "PLAYER ALLIANE ERROR: ATTEMPTED TO DESTROY INVALID ALLIANCE")
            debug endif
        endmethod
    endstruct
    
    /*************************************************************************************
    *
    *   GetAllianceId
    *
    *       Retrieves a composite number representing alliance: (pid1*16+pid2)*8+flag
    *       The player order doesn't matter, but there are two ids that represent each
    *       alliance (either can be used).
    *
    *       integer pid1:           Source player of alliance
    *       integer pid2:           Target player of alliance
    *       integer flag:           Alliance flag (PlayerAlliance lib)
    *
    *       returns:                integer (composite number)
    *
    *************************************************************************************/
    function GetAllianceId takes integer pid1, integer pid2, integer flag returns PlayerAlliance
        debug if (pid1 >= 0 and pid1 <= 15 and pid2 >= 0 and pid2 <= 15 and flag >= 0 and flag <= 7 and pid1 != pid2) then
            return (pid1*16+pid2)*8+flag
        debug endif
        debug if (pid1 == pid2) then
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "PLAYER ALLIANCE ID ERROR: INVALID PLAYER ALLIANCE")
        debug endif
        debug if (pid1 < 0 or pid1 > 15) then
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "PLAYER ALLIANCE ID ERROR: INVALID PLAYER ID 1")
        debug endif
        debug if (pid2 < 0 or pid2 > 15) then
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "PLAYER ALLIANCE ID ERROR: INVALID PLAYER ID 2")
        debug endif
        debug if (flag < 0 or flag > 15) then
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "PLAYER ALLIANCE ID ERROR: INVALID ALLIANCE FLAG")
        debug endif
        debug return 0
    endfunction
    
    /*************************************************************************************
    *
    *   Initialization
    *
    *************************************************************************************/
    private module Inits
        private static method onInit takes nothing returns nothing
            local integer ic                //current pointer for player 1
            local integer ic2               //current pointer for player 2
            local integer i = 15            //current player 1
            local integer i2 = 14           //current player 2
            local integer f                 //current flag
            local integer v                 //current p1,p2,f
            local integer h = 254           //current p1,p2
            local integer h2 = 239          //current p2,p1
            local integer c = 2039          //current player pointer (pointers 8-2039 used by composites)
            local player p1 = Player(15)    //current player 1
            local player p2                 //current player 2
            
            /*
                Connect all of the lists up
                
                loop through player 1s
                    loop through player 2s
                        see if the players are allied and set alliance flags (for initial teams)
                        loop through flags
            */
            loop
                //store player 1 into pointer c
                set c = c + 1
                set ic = c
                set cv[c] = i
                loop
                    set p2 = Player(i2)
                    set f = 7
                    
                    //make player 2 point back to player 1
                    set c = c + 1
                    set ic2 = c
                    set cv[c] = i2
                    set cp[c] = ic
                    
                    //make player 1 point back to player 2 on another list
                    set c = c + 1
                    set cv[c] = i
                    set cp[c] = ic2
                    
                    //loop through flags and make flag point back to player 2
                    loop
                        //player 1 final list
                        set v = h*8+f
                        set cp[v] = ic2
                        set cv[v] = f
                        
                        //player 2 final list
                        set v = h2*8+f
                        set cp[v] = c
                        set cv[v] = f
                        
                        exitwhen f == 0
                        set f = f - 1
                    endloop
                    exitwhen i2 == 0
                    set i2 = i2 - 1
                    set h = h - 1
                    set h2 = h2 - 16
                endloop
                set i = i - 1
                exitwhen i == 0
                set i2 = i-1
                set p1 = Player(i)
                set h = h - 17 + i //(h-15-2+i)
                set h2 = h - 15
            endloop
        endmethod
    endmodule
    
    private struct Init extends array
        implement Inits
    endstruct
endlibrary