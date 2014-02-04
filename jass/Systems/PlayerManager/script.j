library PlayerManager uses /*
    */Event //hiveworkshop.com/forums/submissions-414/snippet-event-186555/
/*===================================================================
Name: Player Manager
Version: v9.0.0.0
Author: Nestharus

struct Human, Computer, ActivePlayer, InactivePlayer
    static readonly thistype first
    static readonly thistype last
    readonly thistype next
    readonly thistype previous
    readonly boolean end
    readonly player get
    readonly integer count
    
    //end is true when the player is null
    //loop
    //  set myPlayer = myPlayer.next
    //  exitwhen myPlayer.end
    //endloop
    
struct Players
    readonly static Event LEAVE
    readonly static integer eventPlayer

    readonly thistype next
    readonly boolean end
    readonly player get
    readonly static player localPlayer
    readonly static integer localPlayerId
===================================================================*/
    private keyword next_p
    private keyword previous_p
    private keyword get_p
    private keyword end_p
    private keyword count_p
    private keyword last_p
    private keyword first_p
    
    //! textmacro REMOVE_FROM_PLAYER_STRUCT takes PLAYER_TYPE, PLAYER_ID
        set $PLAYER_TYPE$.count_p = $PLAYER_TYPE$.count_p - 1
        set $PLAYER_TYPE$[$PLAYER_ID$].previous_p.next_p = $PLAYER_TYPE$[$PLAYER_ID$].next_p
        set $PLAYER_TYPE$[$PLAYER_ID$].next_p.previous_p = $PLAYER_TYPE$[$PLAYER_ID$].previous_p
        set $PLAYER_TYPE$[$PLAYER_ID$].get_p = null
    //! endtextmacro
    //! textmacro ADD_TO_PLAYER_STRUCT takes PLAYER_TYPE, PLAYER_ID
        set $PLAYER_TYPE$.count_p = $PLAYER_TYPE$.count_p + 1
        set $PLAYER_TYPE$[16].previous_p.next_p = $PLAYER_ID$
        set $PLAYER_TYPE$[$PLAYER_ID$].previous_p = $PLAYER_TYPE$[16].previous_p
        set $PLAYER_TYPE$[16].previous_p = $PLAYER_ID$
        set $PLAYER_TYPE$[$PLAYER_ID$].next_p = 16
        
        set $PLAYER_TYPE$[$PLAYER_ID$].get_p = Players[$PLAYER_ID$].get
    //! endtextmacro
    
    private module Initializer
        private static method onPlayerLeave takes nothing returns boolean
            local integer i = GetPlayerId(GetTriggerPlayer())
            local integer prev = eventPlayer
            set eventPlayer = i
            call FireEvent(LEAVE)
            set eventPlayer = prev
            
            //! runtextmacro REMOVE_FROM_PLAYER_STRUCT("Human", "i")
            //! runtextmacro REMOVE_FROM_PLAYER_STRUCT("ActivePlayer", "i")
            //! runtextmacro ADD_TO_PLAYER_STRUCT("InactivePlayer", "i")
            
            return false
        endmethod
        
        private static method onInit takes nothing returns nothing
            local integer i = 0
            local trigger humanLeave = CreateTrigger()
            set LEAVE = CreateEvent()
            
            set thistype[16].end = true
            set Human[16].end_p = true
            set Computer[16].end_p = true
            set ActivePlayer[16].end_p = true
            set InactivePlayer[16].end_p = true
            set Human[16].next_p = 16
            set Computer[16].next_p = 16
            set ActivePlayer[16].next_p = 16
            set InactivePlayer[16].next_p = 16
            set Human[16].previous_p = 16
            set Computer[16].previous_p = 16
            set ActivePlayer[16].previous_p = 16
            set InactivePlayer[16].previous_p = 16
            
            loop
                set thistype[i].get = Player(i)
                
                if (GetPlayerSlotState(thistype[i].get) == PLAYER_SLOT_STATE_PLAYING) then
                    //! runtextmacro ADD_TO_PLAYER_STRUCT("ActivePlayer", "i")
                    if (GetPlayerController(thistype[i].get) == MAP_CONTROL_USER) then
                        //! runtextmacro ADD_TO_PLAYER_STRUCT("Human", "i")
                    else
                        //! runtextmacro ADD_TO_PLAYER_STRUCT("Computer", "i")
                    endif
                    call TriggerRegisterPlayerEvent(humanLeave, thistype[i].get, EVENT_PLAYER_LEAVE)
                else
                    //! runtextmacro ADD_TO_PLAYER_STRUCT("InactivePlayer", "i")
                endif
                set i = i + 1
                set thistype[i-1].next = i
                exitwhen i == 12
            endloop
            
            loop
                set thistype[i].get = Player(i)
                set i = i + 1
                set thistype[i-1].next = i
                exitwhen i == 16
            endloop
            if (Human.count_p > 1) then
                call TriggerAddCondition(humanLeave, Condition(function thistype.onPlayerLeave))
            else
                call DestroyTrigger(humanLeave)
            endif
            set humanLeave = null
            
            set localPlayer = GetLocalPlayer()
            set localPlayerId = GetPlayerId(localPlayer)
        endmethod
    endmodule

    struct Players extends array
        readonly thistype next
        readonly boolean end
        readonly player get
        readonly static player localPlayer
        readonly static integer localPlayerId
        readonly static Event LEAVE = 0
        readonly static integer eventPlayer = 0
        
        implement Initializer
    endstruct
    
    private module PlayerVars
        thistype next_p
        thistype previous_p
        player get_p
        boolean end_p
        static integer count_p = 0
        
        public method operator next takes nothing returns thistype
            return next_p
        endmethod
        public method operator previous takes nothing returns thistype
            return previous_p
        endmethod
        public method operator get takes nothing returns player
            return get_p
        endmethod
        public method operator end takes nothing returns boolean
            return end_p
        endmethod
        public static method operator count takes nothing returns integer
            return count_p
        endmethod
        public static method operator last takes nothing returns integer
            return thistype[16].previous
        endmethod
        public static method operator first takes nothing returns integer
            return thistype[16].next
        endmethod
    endmodule
    
    struct Human extends array
        implement PlayerVars
    endstruct
    struct Computer extends array
        implement PlayerVars
    endstruct
    struct ActivePlayer extends array
        implement PlayerVars
    endstruct
    struct InactivePlayer extends array
        implement PlayerVars
    endstruct
endlibrary