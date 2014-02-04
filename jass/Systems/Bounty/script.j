library Bounty /* v1.0.0.6
*************************************************************************************
*
*   Fires bounty gold/lumber events and can retrieve
*       -   killing unit
*       -   dying unit
*       -   owning player of killing unit
*       -   owning player of dying unit
*       -   bounty gold
*       -   bounty lumber
*
*************************************************************************************
*
*   */uses/*
*       */ Event /*                     hiveworkshop.com/forums/submissions-414/snippet-event-186555/
*       */ Resource /*                  hiveworkshop.com/forums/jass-functions-413/snippet-resource-186638/
*       */ RegisterPlayerUnitEvent /*   hiveworkshop.com/forums/jass-functions-413/snippet-registerplayerunitevent-203338/
*
************************************************************************************
*
*   SETTINGS
*/
globals
    /*************************************************************************************
    *
    *                                   AUTO SET GIVE BOUNTY
    *
    *   This library requires PLAYER_STATE_GIVES_BOUNTY be set to true. If AUTO SET GIVE
    *   BOUNTY is true, this library will automatically set it for you. This is not auto set
    *   as sometimes maps need some players to not give bounty.
    *
    *************************************************************************************/
    private constant boolean AUTO_SET_GIVE_BOUNTY=false
endglobals
/*
************************************************************************************
*
*    struct Bounty extends array
*
*       static readonly Event event
*       static readonly integer gold
*       static readonly integer lumber
*       static readonly player killingPlayer
*       static readonly player dyingPlayer
*       static readonly unit killingUnit
*       static readonly unit dyingUnit
*
************************************************************************************/
    globals
        private integer g=0           //recorded gold (on resource change)
        private integer l=0           //recorded lumber (on resource change)
        private integer s=0           //sync (couples gold/lumber/unit death together)
        private timer v=null          //unsync timer
    endglobals
    //initialization
    private module Init
        private static method onInit takes nothing returns nothing
            static if AUTO_SET_GIVE_BOUNTY then
                local integer i=15
                loop
                    call SetPlayerState(Player(i),PLAYER_STATE_GIVES_BOUNTY,1)
                    exitwhen 0==i
                    set i=i-1
                endloop
            endif
            
            set event=CreateEvent()
            set v=CreateTimer()
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.O)
            
            //resource change registration
            call Resource.EVENT_GOLD_WC3.register(Condition(function thistype.B))
            call Resource.EVENT_LUMBER_WC3.register(Condition(function thistype.B))
        endmethod
    endmodule
    struct Bounty extends array
        readonly static Event event=0
        readonly static integer gold=0
        readonly static integer lumber=0
        readonly static player killingPlayer=null
        readonly static player dyingPlayer=null
        readonly static unit killingUnit=null
        readonly static unit dyingUnit=null
        //unsync function
        private static method E takes nothing returns nothing
            set s=0
        endmethod
        //on unit death
        private static method O takes nothing returns boolean
            local player m          //prev killing player
            local player z          //prev dying player
            local integer h         //prev bounty gold
            local integer q         //prev bounty lumber
            local unit j            //prev killing unit
            local unit r            //prev dying unit
            if (0!=s) then          //sync at 2 (gold and lumber already fired in that order an instant ago)
                set s=0             //reset sync (bounty events within bounty events)
                call PauseTimer(v)
                //store previous values
                set m=killingPlayer
                set z=dyingPlayer
                set h=gold
                set q=lumber
                set j=killingUnit
                set r=dyingUnit
                //retrieve current values
                set gold=g
                set lumber=l
                set killingUnit=GetKillingUnit()
                set killingPlayer=GetOwningPlayer(killingUnit)
                set dyingUnit=GetTriggerUnit()
                set dyingPlayer=GetTriggerPlayer()
                //fire event
                call event.fire()
                //restore previous values
                set killingPlayer=m
                set dyingPlayer=z
                set gold=h
                set lumber=q
                set killingUnit=j
                set dyingUnit=r
                set j=null
                set r=null
            endif
            return false
        endmethod
        //on resource change
        private static method B takes nothing returns boolean
            //gold (can happen for a new sync or after a failed sync)
            if ((1 != s) and Resource.eventState==PLAYER_STATE_RESOURCE_GOLD) then
                set g=Resource.eventChange
                set s=1
            //lumber happens after gold
            elseif ((1==s) or (0==s and Resource.eventState==PLAYER_STATE_RESOURCE_LUMBER)) then
                set s=2
                set l=Resource.eventChange
            endif
            //desync timer
            call TimerStart(v,0,false,function thistype.E)
            return false
        endmethod
        implement Init
    endstruct
endlibrary