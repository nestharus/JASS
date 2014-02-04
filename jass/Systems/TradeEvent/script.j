library Trade /* v2.0.1.1
*************************************************************************************
*
*   This library makes it possible to capture resource trades between players.
*
*************************************************************************************
*
*   */uses/*
*
*       */ Resource /*       hiveworkshop.com/forums/submissions-414/snippet-resource-186638/
*
*************************************************************************************
*
*    struct Trade extends array
*
*       static constant Event EVENT_GOLD
*           -   Event that fires when gold is traded between players
*           -   See Event API
*       static constant Event EVENT_LUMBER
*           -   Event that fires when lumber is traded between players
*           -   See Event API
*
*       readonly static player giver
*           -   The player giving the gold/lumber
*       readonly static player taker
*           -   The player recieving the gold/lumber
*       readonly static integer amount
*           -   The amount of gold/lumber that was traded
*       readonly static playerstate state
*           -   The playerstate of the trade
*           -
*           -   PLAYER_STATE_RESOURCE_GOLD, PLAYER_STATE_RESOURCE_LUMBER
*
************************************************************************************/
        
    private module T
        private static boolean s=false
        private static timer q=CreateTimer()
        private static playerstate w=null
        private static player e=null
        private static integer r=0
        private static method y takes nothing returns nothing
            set s=false
        endmethod
        private static method trade takes nothing returns boolean
            local player p1=giver
            local player p2=taker
            if (s and null!=e and e!=Resource.eventPlayer and r==-Resource.eventChange and w==Resource.eventState) then
                set giver=e
                set taker=Resource.eventPlayer
                if (PLAYER_STATE_RESOURCE_GOLD==Resource.eventState) then
                    call EVENT_GOLD.fire()
                else
                    call EVENT_LUMBER.fire()
                endif
                set giver=p1
                set taker=p2
                set s=false
                call PauseTimer(q)
            elseif (0>Resource.eventChange) then
                set e=Resource.eventPlayer
                set r=Resource.eventChange
                set w=Resource.eventState
                set s=true
                call TimerStart(q,0,false,function thistype.y)
            endif
            return false
        endmethod
        private static method onInit takes nothing returns nothing
            local boolexpr bc=Condition(function thistype.trade)
            set EVENT_GOLD=CreateEvent()
            set EVENT_LUMBER=CreateEvent()
            call Resource.EVENT_GOLD_WC3.register(bc)
            call Resource.EVENT_LUMBER_WC3.register(bc)
            set bc=null
        endmethod
    endmodule
    struct Trade extends array
        readonly static player giver=null
        readonly static player taker=null
        readonly static Event EVENT_GOLD=0
        readonly static Event EVENT_LUMBER=0
        static method operator amount takes nothing returns integer
            return Resource.eventChange
        endmethod
        static method operator state takes nothing returns playerstate
            return Resource.eventState
        endmethod
        implement T
    endstruct
endlibrary