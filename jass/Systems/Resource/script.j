library Resource /* v2.0.0.2
*************************************************************************************
*
*   */uses/*
*
*       */ Event /*             hiveworkshop.com/forums/submissions-414/snippet-event-186555/
*
************************************************************************************
*
*   struct Resource extends array
*
*       static constant Event EVENT_GOLD
*       static constant Event EVENT_LUMBER
*           -   fires any time gold/lumber changes
*           -   if EVENT_GOLD_WC3 did not fire and EVENT_GOLD_HOOK did not fire, the player cheated with a cheat pack or a single player cheat
*
*       static constant Event EVENT_GOLD_WC3
*       static constant Event EVENT_LUMBER_WC3
*           -   fires any time warcraft 3 changed gold/lumber (bounty, player tribute, etc)
*
*       static constant Event EVENT_GOLD_HOOK
*       static constant Event EVENT_LUMBER_HOOK
*           -   fires any time map script changes gold/lumber (SetPlayerState, etc)
*
*       readonly static player eventPlayer
*           -   trigger player
*       readonly static integer eventChange
*           -   how much the resource changed
*       readonly static playerstate eventState
*           -   trigger state (PLAYER_STATE_RESOURCE_GOLD or PLAYER_STATE_RESOURCE_LUMBER)
*
*       readonly integer gold
*       readonly integer lumber
*           -   current player gold/lumber
*
************************************************************************************/
    globals
        private integer r=0
    endglobals
    private function NPS takes player p, playerstate ps, integer v returns nothing
        if ((ps==PLAYER_STATE_RESOURCE_GOLD or ps==PLAYER_STATE_RESOURCE_LUMBER) and v != GetPlayerState(p, ps) and -1 < v) then
            set r=r+1
        endif
    endfunction
    private function NoPlayerState takes player p, playerstate ps, integer v returns nothing
        call NPS(p,ps,v)
    endfunction
    private function NoPlayerState2 takes playerstate ps, boolean flag, player p returns nothing
        if (flag) then
            call NPS(p,ps,1)
        else
            call NPS(p,ps,0)
        endif
    endfunction
    private function NoPlayerState3 takes nothing returns nothing
        local integer i = 11
        loop
            if (GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING) then
                set r=r+2
            endif
            exitwhen 0 == i
            set i=i-1
        endloop
    endfunction
    hook SetPlayerState NoPlayerState
    hook SetPlayerStateBJ NoPlayerState
    hook AdjustPlayerStateSimpleBJ NoPlayerState
    hook SetPlayerFlagBJ NoPlayerState2
    hook MeleeStartingResources NoPlayerState3
    private module Inits
        private static method onchange takes nothing returns boolean
            local player p=eventPlayer
            local thistype this
            local integer y=eventChange
            local playerstate o=eventState
            set eventPlayer=GetTriggerPlayer()
            set this=GetPlayerId(eventPlayer)
            if (GetEventPlayerState()==PLAYER_STATE_RESOURCE_GOLD) then
                set q=gold
                set gold=GetPlayerState(eventPlayer,PLAYER_STATE_RESOURCE_GOLD)
                set eventChange=gold-q
                set eventState=PLAYER_STATE_RESOURCE_GOLD
                if (0==r) then
                    call EVENT_GOLD_WC3.fire()
                else
                    set r=r-1
                    call EVENT_GOLD_HOOK.fire()
                endif
                call EVENT_GOLD.fire()
            else
                set w=lumber
                set lumber=GetPlayerState(eventPlayer,PLAYER_STATE_RESOURCE_LUMBER)
                set eventChange=lumber-w
                set eventState=PLAYER_STATE_RESOURCE_LUMBER
                if (0==r) then
                    call EVENT_LUMBER_WC3.fire()
                else
                    set r=r-1
                    call EVENT_LUMBER_HOOK.fire()
                endif
                call EVENT_LUMBER.fire()
            endif
            set eventPlayer=p
            set eventChange=y
            set eventState=o
            set o=null
            set p=null
            return false
        endmethod
        private static method onInit takes nothing returns nothing
            local thistype this=15
            local trigger t=CreateTrigger()
            local player p
            set EVENT_GOLD=CreateEvent()
            set EVENT_LUMBER=CreateEvent()
            set EVENT_GOLD_WC3=CreateEvent()
            set EVENT_LUMBER_WC3=CreateEvent()
            set EVENT_GOLD_HOOK=CreateEvent()
            set EVENT_LUMBER_HOOK=CreateEvent()
            loop
                set p=Player(this)
                set gold = GetPlayerState(p,PLAYER_STATE_RESOURCE_GOLD)
                set lumber = GetPlayerState(p,PLAYER_STATE_RESOURCE_LUMBER)
                call TriggerRegisterPlayerStateEvent(t,p,PLAYER_STATE_RESOURCE_GOLD, GREATER_THAN_OR_EQUAL,0)
                call TriggerRegisterPlayerStateEvent(t,p,PLAYER_STATE_RESOURCE_LUMBER, GREATER_THAN_OR_EQUAL,0)
                exitwhen 0==this
                set this=this-1
            endloop
            call TriggerAddCondition(t,Condition(function thistype.onchange))
            set p=null
        endmethod
    endmodule
    struct Resource extends array
        readonly integer gold
        readonly integer lumber
        readonly static integer eventChange=0
        readonly static player eventPlayer=null
        readonly static playerstate eventState=null
        private integer q
        private integer w
        readonly static Event EVENT_GOLD=0
        readonly static Event EVENT_LUMBER=0
        readonly static Event EVENT_GOLD_WC3=0
        readonly static Event EVENT_LUMBER_WC3=0
        readonly static Event EVENT_GOLD_HOOK=0
        readonly static Event EVENT_LUMBER_HOOK=0
        implement Inits
    endstruct
endlibrary