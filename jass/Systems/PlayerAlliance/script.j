library PlayerAlliance /* v1.0.0.0
*************************************************************************************
*
*   Simple player alliances
*
*******************************************************************
*
*   Alliance Flags
*
*       constant integer ALLIANCE_UNALLIED
*       constant integer ALLIANCE_UNALLIED_VISION
*       constant integer ALLIANCE_NEUTRAL
*       constant integer ALLIANCE_NEUTRAL_VISION
*       constant integer ALLIANCE_ALLIED
*       constant integer ALLIANCE_VISION
*       constant integer ALLIANCE_ALLIED_UNITS
*       constant integer ALLIANCE_ALLIED_ADVUNITS
*
*   function Ally takes player player1, player player2, integer allianceFlag returns nothing
*       -   Allies two players given alliance flag
*
************************************************************************************/
    globals
        /*************************************************************************************
        *
        *   Alliance Flags
        *
        *************************************************************************************/
        constant integer ALLIANCE_UNALLIED = 0
                                                                //ally = false
                                                                //vision = false
                                                                //control = false
                                                                //full control = false
                                                                //passive = false
        constant integer ALLIANCE_UNALLIED_VISION = 1
                                                                //ally = false
                                                                //vision = true
                                                                //control = false
                                                                //full control = false
                                                                //passive = false
        constant integer ALLIANCE_NEUTRAL = 2
                                                                //ally = false
                                                                //vision = false
                                                                //control = false
                                                                //full control = false
                                                                //passive = true
        constant integer ALLIANCE_NEUTRAL_VISION = 3
                                                                //ally = false
                                                                //vision = true
                                                                //control = false
                                                                //full control = false
                                                                //passive = true
        constant integer ALLIANCE_ALLIED = 4
                                                                //ally = true
                                                                //vision = false
                                                                //control = false
                                                                //full control = false
                                                                //passive = false
        constant integer ALLIANCE_VISION = 5
                                                                //ally = true
                                                                //vision = true
                                                                //control = false
                                                                //full control = false
                                                                //passive false
        constant integer ALLIANCE_ALLIED_UNITS = 6
                                                                //ally = true
                                                                //vision = true
                                                                //control = true
                                                                //full control = false
                                                                //passive = false
        constant integer ALLIANCE_ALLIED_ADVUNITS = 7
                                                                //ally = true
                                                                //vision = true
                                                                //control = true
                                                                //full control = true
                                                                //passive = false
    endglobals
    
    /*************************************************************************************
    *
    *   Ally
    *
    *       Allies two players given an alliance flag. Will ally both source player and target player.
    *
    *       player p1:              The source player of alliance
    *       player p2:              The target player of alliance
    *
    *       returns:                nothing
    *
    *************************************************************************************/
    function Ally takes player p1, player p2, integer flag returns nothing
        debug if (p1 != null and p2 != null and p1 != p2 and flag >= 0 and flag <= 7) then
            //first see if the alliance type was an actual alliance or not
            if (flag < ALLIANCE_ALLIED) then
                //if it wasn't, unset alliance flags
                call SetPlayerAlliance(p1, p2, ALLIANCE_PASSIVE,       false)
                call SetPlayerAlliance(p1, p2, ALLIANCE_HELP_REQUEST,  false)
                call SetPlayerAlliance(p1, p2, ALLIANCE_HELP_RESPONSE, false)
                call SetPlayerAlliance(p1, p2, ALLIANCE_SHARED_XP,     false)
                call SetPlayerAlliance(p1, p2, ALLIANCE_SHARED_SPELLS, false)
                call SetPlayerAlliance(p2, p1, ALLIANCE_PASSIVE,       false)
                call SetPlayerAlliance(p2, p1, ALLIANCE_HELP_REQUEST,  false)
                call SetPlayerAlliance(p2, p1, ALLIANCE_HELP_RESPONSE, false)
                call SetPlayerAlliance(p2, p1, ALLIANCE_SHARED_XP,     false)
                call SetPlayerAlliance(p2, p1, ALLIANCE_SHARED_SPELLS, false)
                call SetPlayerAlliance(p1, p2, ALLIANCE_SHARED_CONTROL, false)
                call SetPlayerAlliance(p2, p1, ALLIANCE_SHARED_CONTROL, false)
                call SetPlayerAlliance(p1, p2, ALLIANCE_SHARED_ADVANCED_CONTROL, false)
                call SetPlayerAlliance(p2, p1, ALLIANCE_SHARED_ADVANCED_CONTROL, false)
                //if enemy
                if (flag <= ALLIANCE_UNALLIED_VISION) then
                    //unset passive flag
                    call SetPlayerAlliance(p1, p2, ALLIANCE_PASSIVE, false)
                    call SetPlayerAlliance(p2, p1, ALLIANCE_PASSIVE, false)
                    //check for vision
                    if (flag == ALLIANCE_UNALLIED_VISION) then
                        call SetPlayerAlliance(p1, p2, ALLIANCE_SHARED_VISION, true)
                        call SetPlayerAlliance(p2, p1, ALLIANCE_SHARED_VISION, true)
                    else
                        call SetPlayerAlliance(p1, p2, ALLIANCE_SHARED_VISION, false)
                        call SetPlayerAlliance(p2, p1, ALLIANCE_SHARED_VISION, false)
                    endif
                //if neutral
                else
                    //set passive flag
                    call SetPlayerAlliance(p1, p2, ALLIANCE_PASSIVE, true)
                    call SetPlayerAlliance(p2, p1, ALLIANCE_PASSIVE, true)
                    //check for vision
                    if (flag == ALLIANCE_NEUTRAL_VISION) then
                        call SetPlayerAlliance(p1, p2, ALLIANCE_SHARED_VISION, true)
                        call SetPlayerAlliance(p2, p1, ALLIANCE_SHARED_VISION, true)
                    else
                        call SetPlayerAlliance(p1, p2, ALLIANCE_SHARED_VISION, false)
                        call SetPlayerAlliance(p2, p1, ALLIANCE_SHARED_VISION, false)
                    endif
                endif
            else
                //make allied
                call SetPlayerAlliance(p1, p2, ALLIANCE_PASSIVE,       true)
                call SetPlayerAlliance(p1, p2, ALLIANCE_HELP_REQUEST,  true)
                call SetPlayerAlliance(p1, p2, ALLIANCE_HELP_RESPONSE, true)
                call SetPlayerAlliance(p1, p2, ALLIANCE_SHARED_XP,     true)
                call SetPlayerAlliance(p1, p2, ALLIANCE_SHARED_SPELLS, true)
                call SetPlayerAlliance(p2, p1, ALLIANCE_PASSIVE,       true)
                call SetPlayerAlliance(p2, p1, ALLIANCE_HELP_REQUEST,  true)
                call SetPlayerAlliance(p2, p1, ALLIANCE_HELP_RESPONSE, true)
                call SetPlayerAlliance(p2, p1, ALLIANCE_SHARED_XP,     true)
                call SetPlayerAlliance(p2, p1, ALLIANCE_SHARED_SPELLS, true)
                //check for vision
                if (flag >= ALLIANCE_VISION) then
                    //add vision
                    call SetPlayerAlliance(p1, p2, ALLIANCE_SHARED_VISION, true)
                    call SetPlayerAlliance(p2, p1, ALLIANCE_SHARED_VISION, true)
                    //check for shared control
                    if (flag >= ALLIANCE_ALLIED_UNITS) then
                        //add shared control
                        call SetPlayerAlliance(p1, p2, ALLIANCE_SHARED_CONTROL, true)
                        call SetPlayerAlliance(p2, p1, ALLIANCE_SHARED_CONTROL, true)
                        //check for advanced control
                        if (flag == ALLIANCE_ALLIED_ADVUNITS) then
                            call SetPlayerAlliance(p1, p2, ALLIANCE_SHARED_ADVANCED_CONTROL, true)
                            call SetPlayerAlliance(p2, p1, ALLIANCE_SHARED_ADVANCED_CONTROL, true)
                        else
                            call SetPlayerAlliance(p1, p2, ALLIANCE_SHARED_ADVANCED_CONTROL, false)
                            call SetPlayerAlliance(p2, p1, ALLIANCE_SHARED_ADVANCED_CONTROL, false)
                        endif
                    else
                        call SetPlayerAlliance(p1, p2, ALLIANCE_SHARED_CONTROL, false)
                        call SetPlayerAlliance(p2, p1, ALLIANCE_SHARED_CONTROL, false)
                        call SetPlayerAlliance(p1, p2, ALLIANCE_SHARED_ADVANCED_CONTROL, false)
                        call SetPlayerAlliance(p2, p1, ALLIANCE_SHARED_ADVANCED_CONTROL, false)
                    endif
                else
                    call SetPlayerAlliance(p1, p2, ALLIANCE_SHARED_VISION, false)
                    call SetPlayerAlliance(p2, p1, ALLIANCE_SHARED_VISION, false)
                    call SetPlayerAlliance(p1, p2, ALLIANCE_SHARED_CONTROL, false)
                    call SetPlayerAlliance(p2, p1, ALLIANCE_SHARED_CONTROL, false)
                    call SetPlayerAlliance(p1, p2, ALLIANCE_SHARED_ADVANCED_CONTROL, false)
                    call SetPlayerAlliance(p2, p1, ALLIANCE_SHARED_ADVANCED_CONTROL, false)
                endif
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
        debug endif
    endfunction
endlibrary