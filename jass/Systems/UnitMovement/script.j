library UnitMovement /* v1.0.1.1
    *************************************************************************************
    *
    *    Is able to track and manage events for:
    *        unit native movement
    *            -    It manages this decently, but while units are moving, it may fire stop events and native movement events
    *            -    As units continue to stop and move while moving (example is turning).
    *            -
    *            -    This library will also sometimes regards units as natively moving when they really are not.
    *            -    It guesses at whether a unit is natively moving or not (very good guess), but because it guesses, 
    *            -    it is not 100% accuracy. The situations where this will fail at its guess are rather rare.
    *
    *                Ex:
    *                    Two units are fighting each other on a moving platform. Even though they are standing still, 
    *                    UnitMovement will think that they are both natively moving since they have active orders.
    *
    *        unit movement
    *        unit stops
    *        indexing for units that can move        (resurrection, animation, unit indexing)
    *        deindexing for units that can move        (decay, death, removal, unit deindexing)
    *
    *    Feature events for filtered lists as well as collections of all moving and stationary units
    *
    ************************************************************************************
    *
    *    */uses/*
    *
    *       */ Tt                               /*      hiveworkshop.com/forums/jass-functions-413/system-timer-tools-201165/
    *       */ UnitEvent                        /*      hiveworkshop.com/forums/jass-functions-413/extension-unit-event-172365/
    *       */ RegisterPlayerUnitEvent          /*      hiveworkshop.com/forums/jass-resources-412/snippet-registerplayerunitevent-203338/
    *
    ************************************************************************************
    *
    *    function IsUnitStationaryById takes integer whichUnit returns boolean
    *    function IsUnitMovingById takes integer whichUnit returns boolean
    *    function IsUnitNativelyMovingById takes integer whichUnit returns boolean
    *    function CanUnitMoveById takes integer whichUnit returns boolean
    *    function GetMovingUnitById takes nothing returns integer
    *        -    Event data for all events in library
    *
    *    struct MovementTracker extends array
    *        readonly static Event eventIndex
    *        readonly static Event eventDeindex
    *
    *    struct StationaryUnits extends array
    *        readonly static StationaryUnits first
    *        readonly StationaryUnits next
    *        readonly static Event event
    *    struct MovingUnits extends array
    *        readonly static MovingUnits first
    *        readonly MovingUnits next
    *        readonly static Event event
    *    struct NativelyMovingUnits extends array
    *        readonly static NativelyMovingUnits first
    *        readonly NativelyMovingUnits next
    *        readonly static Event event
    *
    *    module MovingUnitsFilteredList
    *    module NativelyMovingUnitsFilteredList
    *    module StationaryUnitsFileredList
    *        private method filter takes nothing returns boolean
    *            -    Declare this above the module
    *            -    Takes the unit set to move and returns a boolean signifying whether to
    *            -    Add that unit to the filtered list or not
    *
    *        readonly boolean allocated
    *        readonly thistype next
    *
    *        Example
    *            struct MyListOfStoppedFootmen extends array
    *                private method filter takes nothing returns boolean
    *                    return GetUnitTypeId(GetUnitById(this))=='hfoo'
    *                endmethod
    *                implement StationaryUnitsFileredList
    *            endstruct
    *
    ************************************************************************************/
    globals
        //stationary
        private integer array sn
        private integer array sp
        
        //moving
        private integer array mn
        private integer array mp
        private boolean array im
        private real array mx
        private real array my
        private real array uf1
        private real array uf2
        
        //natively moving
        private integer array nn
        private integer array np
        private boolean array in
        
        //active
        private integer array an
        private integer array ap
        private boolean array ia
        
        //destroy stack
        private integer array ds
        
        private trigger utt=CreateTrigger()    //update target trigger
        private integer array ut            //unit target
        private conditionfunc utc            //update target code
        private integer utl=0                //update target event leaks
        private integer utu=0                //update target events up
        
        private Event ei                    //event index
        private Event ed                    //event deindex
        private Event es                    //event stationary
        private Event em                    //event move
        private Event en                    //event native move
        private integer eu=0                //event unit
    endglobals
    //! textmacro UnitMovement_GET_NEXT_ACTIVE_UNIT takes REF
        set $REF$=an[$REF$]
    //! endtextmacro
    //! textmacro UnitMovement_IS_MARKED_NATIVELY_MOVING takes REF
        if (in[$REF$]) then
    //! endtextmacro
    //! textmacro UnitMovement_IS_MARKED_ACTIVE takes REF
        if (ia[$REF$]) then
    //! endtextmacro
    //! textmacro UnitMovement_REMOVE_FROM_NATIVE_MOVEMENT takes REF
        set nn[np[$REF$]]=nn[$REF$]
        set np[nn[$REF$]]=np[$REF$]
        set in[$REF$]=false
        if (-1==ut[$REF$]) then
            set ut[$REF$]=0
        else
            set ut[$REF$]=-1
        endif
    //! endtextmacro
    //! textmacro UnitMovement_REMOVE_FROM_MOVEMENT takes REF
        set mn[mp[$REF$]]=mn[$REF$]
        set mp[mn[$REF$]]=mp[$REF$]
        set im[$REF$]=false
    //! endtextmacro
    //! textmacro UnitMovement_REMOVE_FROM_STATIONARY takes REF
        set sn[sp[$REF$]]=sn[$REF$]
        set sp[sn[$REF$]]=sp[$REF$]
    //! endtextmacro
    //! textmacro UnitMovement_REMOVE_FROM_ACTIVE takes REF
        set an[ap[$REF$]]=an[$REF$]
        set ap[an[$REF$]]=ap[$REF$]
        call Uf2[$REF$].destroy()
        set ia[$REF$]=false
        if (0==eu) then
            call UnitIndex($REF$).unlock()
        else
            set ds[$REF$]=ds[0]
            set ds[0]=$REF$
        endif
    //! endtextmacro
    //! textmacro UnitMovement_ADD_TO_NATIVE_MOVEMENT takes REF
        set nn[$REF$]=nn[0]
        set np[$REF$]=0
        set np[nn[0]]=$REF$
        set nn[0]=$REF$
        set in[$REF$]=true
    //! endtextmacro
    //! textmacro UnitMovement_ADD_TO_MOVEMENT takes REF
        set mn[$REF$]=mn[0]
        set mp[$REF$]=0
        set mp[mn[0]]=$REF$
        set mn[0]=$REF$
        set im[$REF$]=true
    //! endtextmacro
    //! textmacro UnitMovement_ADD_TO_STATIONARY takes REF
        set sn[$REF$]=sn[0]
        set sp[$REF$]=0
        set sp[sn[0]]=$REF$
        set sn[0]=$REF$
    //! endtextmacro
    //! textmacro UnitMovement_ADD_TO_ACTIVE takes REF
        set an[$REF$]=an[0]
        set ap[$REF$]=0
        set ap[an[0]]=$REF$
        set an[0]=$REF$
        set ia[$REF$]=true
        call UnitIndex($REF$).lock()
        call Uf2.create($REF$)
    //! endtextmacro
    //! textmacro UnitMovement_FIRE_EVENT takes REF, EVENT
        set pe=eu
        set eu=$REF$
        call $EVENT$.fire()
        set eu=pe
    //! endtextmacro
    //! textmacro UnitMovement_EVENT_LOCAL
        local integer pe
    //! endtextmacro
    //! textmacro UnitMovement_MOVING_LOCAL
        local unit u
        local real x
        local real y
        local integer o
    //! endtextmacro
    //! textmacro UnitMovement_NULL_MOVING_LOCAL
        set u=null
    //! endtextmacro
    //! textmacro UnitMovement_GET_UPDATED_UNIT_POINT takes REF
        set u=GetUnitById($REF$)
        set x=GetWidgetX(u)
        set y=GetWidgetY(u)
        set o=GetUnitCurrentOrder(u)
    //! endtextmacro
    //! textmacro UnitMovement_UPDATE_UNIT_POINT takes REF, X, Y
        set mx[$REF$]=$X$
        set my[$REF$]=$Y$
    //! endtextmacro
    //! textmacro UnitMovement_IS_MARKED_MOVING takes REF
        if (im[$REF$]) then
    //! endtextmacro
    //! textmacro UnitMovement_IF_ORDERED_TO_STOP takes REF
        //  stop                          hold position
        if (851972==GetIssuedOrderId() or 851993==GetIssuedOrderId()) then
    //! endtextmacro
    //! textmacro UnitMovement_IS_UNIT_MOVING takes REF
                                            //patrol with no target
        if (x!=mx[$REF$] or y!=my[$REF$] or (0==ut[$REF$] and 851991==o) or uf1[$REF$]!=uf2[$REF$]) then
    //! endtextmacro
    //! textmacro UnitMovement_IS_MARKED_STATIONARY takes REF
        if (not im[$REF$]) then
    //! endtextmacro
    //! textmacro UnitMovement_IS_UNIT_NOW_STATIONARY takes REF
        elseif (im[$REF$]) then
    //! endtextmacro
    //! textmacro UnitMovement_EXITWHEN_NULL takes REF
        exitwhen 0==$REF$
    //! endtextmacro
    //! textmacro UnitMovement_CAN_UNIT_MOVE takes REF
        if 0<GetUnitDefaultMoveSpeed(GetUnitById($REF$)) then
    //! endtextmacro
    //! textmacro UnitMovement_REGISTER_UNIT_FOR_TARGET_UPDATE takes REF
        set utu=utu+1
        call TriggerRegisterUnitEvent(utt,GetUnitById($REF$),EVENT_UNIT_ACQUIRED_TARGET)
    //! endtextmacro
    //! textmacro UnitMovement_UNREGISTER_UNIT_FOR_TARGET_UPDATE
        set utl=utl+1
        set utu=utu-1
    //! endtextmacro
    //! textmacro UnitMovement_IF_TOO_MANY_TARGET_EVENT_LEAKS
        if (utl>utu+25) then
    //! endtextmacro
    //! textmacro UnitMovement_RESET_TARGET_UPDATE_TRIGGER takes REF
        call DestroyTrigger(utt)
        set utt=CreateTrigger()
        call TriggerAddCondition(utt,utc)
        set utl=0
        set $REF$=an[0]
        loop
            exitwhen 0==$REF$
            call TriggerRegisterUnitEvent(utt,GetUnitById($REF$),EVENT_UNIT_ACQUIRED_TARGET)
            set $REF$=an[$REF$]
        endloop
    //! endtextmacro
    //! textmacro UnitMovement_IS_NOW_NATIVELY_MOVING takes REF
        if (not in[$REF$] and ((0!=o and 851972!=o and 851993!=o) or (0==o and 0!=ut[$REF$]))) then
    //! endtextmacro
    //! textmacro UnitMovement_SET_UNIT_TARGET takes REF, TARGET
        set ut[$REF$]=$TARGET$
    //! endtextmacro
    private struct Uf extends array
        private static constant real TIMEOUT=.1
        integer u
        static thistype array t
        implement CTTCExpire
            set uf1[this]=uf2[this]
            set uf2[this]=GetUnitFacing(GetUnitById(u))
        implement CTTCEnd
    endstruct
    private struct Uf2 extends array
        static method create takes integer u returns thistype
            set uf1[u]=GetUnitFacing(GetUnitById(u))
            set uf2[u]=uf1[u]
            set Uf.t[u]=Uf.create()
            set Uf.t[u].u=u
            return u
        endmethod
        method destroy takes nothing returns nothing
            call Uf.t[this].destroy()
        endmethod
    endstruct
    function GetMovingUnitById takes nothing returns integer
        return eu
    endfunction
    function IsUnitStationaryById takes integer u returns boolean
        return not im[u]
    endfunction
    function IsUnitMovingById takes integer u returns boolean
        return im[u]
    endfunction
    function IsUnitNativelyMovingById takes integer u returns boolean
        return in[u]
    endfunction
    function CanUnitMoveById takes integer u returns boolean
        return ia[u]
    endfunction
    private function OO takes nothing returns boolean    //On Order
        //null target
        //! runtextmacro UnitMovement_SET_UNIT_TARGET("GetUnitUserData(GetTriggerUnit())","0")
        return false
    endfunction
    private function OTO takes nothing returns boolean    //On Target Order
        //update target
        //! runtextmacro UnitMovement_SET_UNIT_TARGET("GetUnitUserData(GetTriggerUnit())","GetUnitUserData(GetOrderTargetUnit())")
        return false
    endfunction
    private function OSE takes nothing returns boolean    //On Spell Effect
        //update target
        //! runtextmacro UnitMovement_SET_UNIT_TARGET("GetUnitUserData(GetTriggerUnit())","GetUnitUserData(GetSpellTargetUnit())")
        return false
    endfunction
    private function UT takes nothing returns boolean    //Acquire Target
        //update target
        //! runtextmacro UnitMovement_SET_UNIT_TARGET("GetUnitUserData(GetTriggerUnit())","GetUnitUserData(GetEventTargetUnit())")
        return false
    endfunction
    private function SR takes nothing returns boolean    //Reincarnation Handler
        //null target
        //! runtextmacro UnitMovement_SET_UNIT_TARGET("GetEventUnitId()","0")
        return false
    endfunction
    private function A takes nothing returns boolean    //Resurrect/Animate
        local integer i=GetEventUnitId()
        //reactivate
        //! runtextmacro UnitMovement_EVENT_LOCAL()
        //! runtextmacro UnitMovement_CAN_UNIT_MOVE("i")
            //! runtextmacro UnitMovement_SET_UNIT_TARGET("i","0")
            //! runtextmacro UnitMovement_UPDATE_UNIT_POINT("i","GetWidgetX(GetUnitById(i))","GetWidgetY(GetUnitById(i))")
            //! runtextmacro UnitMovement_ADD_TO_STATIONARY("i")
            //! runtextmacro UnitMovement_ADD_TO_ACTIVE("i")
            //! runtextmacro UnitMovement_FIRE_EVENT("i","ei")
        endif
        return false
    endfunction
    private function R takes nothing returns boolean    //Death
        local integer i=GetEventUnitId()
        //deactivate
        //! runtextmacro UnitMovement_EVENT_LOCAL()
        //! runtextmacro UnitMovement_IS_MARKED_ACTIVE("i")
            //! runtextmacro UnitMovement_IS_MARKED_MOVING("i")
                //! runtextmacro UnitMovement_IS_MARKED_NATIVELY_MOVING("i")
                    //! runtextmacro UnitMovement_REMOVE_FROM_NATIVE_MOVEMENT("i")
                endif
                //! runtextmacro UnitMovement_REMOVE_FROM_MOVEMENT("i")
            else
                //! runtextmacro UnitMovement_REMOVE_FROM_STATIONARY("i")
            endif
            //! runtextmacro UnitMovement_REMOVE_FROM_ACTIVE("i")
            //! runtextmacro UnitMovement_FIRE_EVENT("i","ed")
        endif
        return false
    endfunction
    private function I takes nothing returns boolean        //Unit Index
        local integer i=GetIndexedUnitId()
        //activate
        //! runtextmacro UnitMovement_EVENT_LOCAL()
        //! runtextmacro UnitMovement_CAN_UNIT_MOVE("i")
            //! runtextmacro UnitMovement_SET_UNIT_TARGET("i","0")
            //! runtextmacro UnitMovement_UPDATE_UNIT_POINT("i","GetWidgetX(GetUnitById(i))","GetWidgetY(GetUnitById(i))")
            //! runtextmacro UnitMovement_ADD_TO_STATIONARY("i")
            //! runtextmacro UnitMovement_ADD_TO_ACTIVE("i")
            //! runtextmacro UnitMovement_REGISTER_UNIT_FOR_TARGET_UPDATE("i")
            //! runtextmacro UnitMovement_FIRE_EVENT("i","ei")
        endif
        return false
    endfunction
    private function D takes nothing returns boolean        //Unit Deindex
        local integer i=GetIndexedUnitId()
        //deactivate
        //! runtextmacro UnitMovement_EVENT_LOCAL()
        //! runtextmacro UnitMovement_CAN_UNIT_MOVE("i")
            //! runtextmacro UnitMovement_IS_MARKED_ACTIVE("i")
                //! runtextmacro UnitMovement_IS_MARKED_MOVING("i")
                    //! runtextmacro UnitMovement_IS_MARKED_NATIVELY_MOVING("i")
                        //! runtextmacro UnitMovement_REMOVE_FROM_NATIVE_MOVEMENT("i")
                    endif
                    //! runtextmacro UnitMovement_REMOVE_FROM_MOVEMENT("i")
                else
                    //! runtextmacro UnitMovement_REMOVE_FROM_STATIONARY("i")
                endif
                //! runtextmacro UnitMovement_REMOVE_FROM_ACTIVE("i")
                //! runtextmacro UnitMovement_FIRE_EVENT("i","ed")
            endif
            //! runtextmacro UnitMovement_UNREGISTER_UNIT_FOR_TARGET_UPDATE()
            //! runtextmacro UnitMovement_IF_TOO_MANY_TARGET_EVENT_LEAKS()
                //! runtextmacro UnitMovement_RESET_TARGET_UPDATE_TRIGGER("i")
            endif
        endif
        return false
    endfunction
    struct M extends array    //unit scan (timer will scan all units on map that can possibly move)
        implement CT32
            local integer i=an[0]    //event unit
            //! runtextmacro UnitMovement_MOVING_LOCAL()
            //! runtextmacro UnitMovement_EVENT_LOCAL()
            loop
                //! runtextmacro UnitMovement_EXITWHEN_NULL("i")
                //! runtextmacro UnitMovement_GET_UPDATED_UNIT_POINT("i")
                //! runtextmacro UnitMovement_IS_UNIT_MOVING("i")
                    //! runtextmacro UnitMovement_UPDATE_UNIT_POINT("i","x","y")
                    //! runtextmacro UnitMovement_IS_MARKED_STATIONARY("i")
                        //! runtextmacro UnitMovement_REMOVE_FROM_STATIONARY("i")
                        //! runtextmacro UnitMovement_ADD_TO_MOVEMENT("i")
                        //! runtextmacro UnitMovement_FIRE_EVENT("i","em")
                    endif
                    //! runtextmacro UnitMovement_IS_MARKED_ACTIVE("i")
                        //! runtextmacro UnitMovement_IS_NOW_NATIVELY_MOVING("i")
                            //! runtextmacro UnitMovement_ADD_TO_NATIVE_MOVEMENT("i")
                            //! runtextmacro UnitMovement_FIRE_EVENT("i","en")
                        endif
                    elseif (in[i] and 0==o and 0==ut[i]) then
                        //! runtextmacro UnitMovement_REMOVE_FROM_NATIVE_MOVEMENT("i")
                    endif
                //! runtextmacro UnitMovement_IS_UNIT_NOW_STATIONARY("i")
                    //! runtextmacro UnitMovement_IS_MARKED_NATIVELY_MOVING("i")
                        //! runtextmacro UnitMovement_REMOVE_FROM_NATIVE_MOVEMENT("i")
                    endif
                    //! runtextmacro UnitMovement_REMOVE_FROM_MOVEMENT("i")
                    //! runtextmacro UnitMovement_ADD_TO_STATIONARY("i")
                    //! runtextmacro UnitMovement_FIRE_EVENT("i","es")
                endif
                //! runtextmacro UnitMovement_GET_NEXT_ACTIVE_UNIT("i")
            endloop
            set i=ds[0]
            set ds[0]=0
            loop
                exitwhen 0==i
                call UnitIndex(i).unlock()
            endloop
            //! runtextmacro UnitMovement_NULL_MOVING_LOCAL()
        implement CT32End
    endstruct

    private module Init
        private static method onInit takes nothing returns nothing
            local integer i=15
            local trigger t1=CreateTrigger()
            local trigger t2=CreateTrigger()
            local trigger t3=CreateTrigger()
            local player q
            set utc=Condition(function UT)
            call TriggerAddCondition(utt,utc)
            loop
                set q=Player(i)
                call TriggerRegisterPlayerUnitEvent(t1,q,EVENT_PLAYER_UNIT_ISSUED_ORDER, null)
                call TriggerRegisterPlayerUnitEvent(t2,q,EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, null)
                call TriggerRegisterPlayerUnitEvent(t2,q,EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, null)
                call TriggerRegisterPlayerUnitEvent(t3,q,EVENT_PLAYER_UNIT_SPELL_EFFECT, null)
                exitwhen 0==i
                set i=i-1
            endloop
            call TriggerAddCondition(t1,Condition(function OO))
            call TriggerAddCondition(t2,Condition(function OTO))
            call TriggerAddCondition(t3,Condition(function OSE))
            call UnitEvent.RESURRECT.register(Condition(function A))
            call UnitEvent.ANIMATE.register(Condition(function A))
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function R)
            call UnitEvent.START_REINCARNATE.register(Condition(function SR))
            call RegisterUnitIndexEvent(Condition(function I), UnitIndexer.INDEX)
            call RegisterUnitIndexEvent(Condition(function D), UnitIndexer.DEINDEX)
            set ei=CreateEvent()
            set ed=CreateEvent()
            set es=CreateEvent()
            set em=CreateEvent()
            set en=CreateEvent()
            set q=null
            set t1=null
            set t2=null
            set t3=null
        endmethod
    endmodule
    struct MovementTracker extends array
        static method operator eventIndex takes nothing returns Event
            return ei
        endmethod
        static method operator eventDeindex takes nothing returns Event
            return ed
        endmethod
    endstruct
    struct StationaryUnits extends array
        implement Init
        static method operator first takes nothing returns thistype
            return sn[0]
        endmethod
        method operator next takes nothing returns thistype
            return sn[this]
        endmethod
        static method operator event takes nothing returns Event
            return es
        endmethod
    endstruct
    struct MovingUnits extends array
        static method operator first takes nothing returns thistype
            return mn[0]
        endmethod
        method operator next takes nothing returns thistype
            return mn[this]
        endmethod
        static method operator event takes nothing returns Event
            return em
        endmethod
    endstruct
    struct NativelyMovingUnits extends array
        static method operator first takes nothing returns thistype
            return nn[0]
        endmethod
        method operator next takes nothing returns thistype
            return nn[this]
        endmethod
        static method operator event takes nothing returns Event
            return en
        endmethod
    endstruct
    private keyword n
    private keyword p
    private keyword m
    private keyword s
    private keyword d
    private keyword i
    private keyword b
    module MovingUnitsFilteredList
        static integer array n
        static integer array p
        static boolean array b
        method operator next takes nothing returns thistype
            return n[this]
        endmethod
        method operator allocated takes nothing returns boolean
            return b[this]
        endmethod
        static method m takes nothing returns boolean
            local thistype i=GetMovingUnitById()
            if (i.filter() and ia[i] and not b[i]) then
                set b[i]=true
                set n[i]=n[0]
                set p[i]=0
                set n[p[0]]=i
                set n[0]=i
            endif
            return false
        endmethod
        static method s takes nothing returns boolean
            local thistype i=GetMovingUnitById()
            if (b[i] and ia[i]) then
                set n[p[i]]=n[i]
                set p[n[i]]=p[i]
                set b[i]=false
            endif
            return false
        endmethod
        static method d takes nothing returns boolean
            local thistype i=GetMovingUnitById()
            if (b[i]) then
                set n[p[i]]=n[i]
                set p[n[i]]=p[i]
                set b[i]=false
            endif
            return false
        endmethod
        private static method onInit takes nothing returns nothing
            call MovingUnits.event.register(Condition(function thistype.m))
            call StationaryUnits.event.register(Condition(function thistype.s))
            call MovementTracker.eventDeindex.register(Condition(function thistype.d))
        endmethod
    endmodule
    module NativelyMovingUnitsFilteredList
        static integer array n
        static integer array p
        static boolean array b
        method operator next takes nothing returns thistype
            return n[this]
        endmethod
        method operator allocated takes nothing returns boolean
            return b[this]
        endmethod
        static method m takes nothing returns boolean
            local thistype i=GetMovingUnitById()
            if (i.filter() and ia[i] and not b[i]) then
                set b[i]=true
                set n[i]=n[0]
                set p[i]=0
                set n[p[0]]=i
                set n[0]=i
            endif
            return false
        endmethod
        static method s takes nothing returns boolean
            local thistype i=GetMovingUnitById()
            if (b[i] and ia[i]) then
                set n[p[i]]=n[i]
                set p[n[i]]=p[i]
                set b[i]=false
            endif
            return false
        endmethod
        static method d takes nothing returns boolean
            local thistype i=GetMovingUnitById()
            if (b[i]) then
                set n[p[i]]=n[i]
                set p[n[i]]=p[i]
                set b[i]=false
            endif
            return false
        endmethod
        private static method onInit takes nothing returns nothing
            call NativelyMovingUnits.event.register(Condition(function thistype.m))
            call StationaryUnits.event.register(Condition(function thistype.s))
            call MovementTracker.eventDeindex.register(Condition(function thistype.d))
        endmethod
    endmodule
    module StationaryUnitsFileredList
        static integer array n
        static integer array p
        static boolean array b
        method operator next takes nothing returns thistype
            return n[this]
        endmethod
        method operator allocated takes nothing returns boolean
            return b[this]
        endmethod
        static method s takes nothing returns boolean
            local thistype i=GetMovingUnitById()
            if (i.filter() and ia[i] and not b[i]) then
                set b[i]=true
                set n[i]=n[0]
                set p[i]=0
                set n[p[0]]=i
                set n[0]=i
            endif
            return false
        endmethod
        static method m takes nothing returns boolean
            local thistype i=GetMovingUnitById()
            if (b[i] and ia[i]) then
                set n[p[i]]=n[i]
                set p[n[i]]=p[i]
                set b[i]=false
            endif
            return false
        endmethod
        static method d takes nothing returns boolean
            local thistype i=GetMovingUnitById()
            if (b[i]) then
                set n[p[i]]=n[i]
                set p[n[i]]=p[i]
                set b[i]=false
            endif
            return false
        endmethod
        private static method onInit takes nothing returns nothing
            call MovingUnits.event.register(Condition(function thistype.m))
            call StationaryUnits.event.register(Condition(function thistype.s))
            call MovementTracker.eventIndex.register(Condition(function thistype.s))
            call MovementTracker.eventDeindex.register(Condition(function thistype.d))
        endmethod
    endmodule
endlibrary