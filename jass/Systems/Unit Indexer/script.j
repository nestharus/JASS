library UnitIndexer uses WorldBounds, Event, UnitIndexerSettings
    globals
        private trigger q=CreateTrigger()
        private trigger l=CreateTrigger()
        private unit array e
        private integer r=0
        private integer y=0
        private integer o=0
        private boolean a=false
        private integer array n
        private integer array p
        private integer array lc
    endglobals
    function GetIndexedUnitId takes nothing returns integer
        return o
    endfunction
    function GetIndexedUnit takes nothing returns unit
        return e[o]
    endfunction
    //! runtextmacro optional UNIT_LIST_LIB()
    private struct PreLoader extends array
        public static method run takes nothing returns nothing
            call DestroyTimer(GetExpiredTimer())
            set a=true
        endmethod
        public static method eval takes trigger t returns nothing
            local integer f=n[0]
            local integer d=o
            loop
                exitwhen 0==f
                if (IsTriggerEnabled(t)) then
                    set o=f
                    if (TriggerEvaluate(t)) then
                        call TriggerExecute(t)
                    endif
                else
                    exitwhen true
                endif
                set f=n[f]
            endloop
            set o=d
        endmethod
        public static method evalb takes boolexpr c returns nothing
            local trigger t=CreateTrigger()
            local thistype f=n[0]
            local integer d=o
            call TriggerAddCondition(t,c)
            loop
                exitwhen 0==f
                set o=f
                call TriggerEvaluate(t)
                set f=n[f]
            endloop
            call DestroyTrigger(t)
            set t=null
            set o=d
        endmethod
    endstruct
    //! runtextmacro optional UNIT_EVENT_MACRO()
    private module UnitIndexerInit
        private static method onInit takes nothing returns nothing
            local integer i=15
            local boolexpr bc=Condition(function thistype.onLeave)
            local boolexpr bc2=Condition(function thistype.onEnter)
            local group g=CreateGroup()
            local player p
            set INDEX=CreateEvent()
            set DEINDEX=CreateEvent()
            call TriggerRegisterEnterRegion(q,WorldBounds.worldRegion,bc2)
            loop
                set p=Player(i)
                call TriggerRegisterPlayerUnitEvent(l,p,EVENT_PLAYER_UNIT_ISSUED_ORDER,bc)
                call SetPlayerAbilityAvailable(p,ABILITIES_UNIT_INDEXER,false)
                call GroupEnumUnitsOfPlayer(g,p,bc2)
                exitwhen 0==i
                set i=i-1
            endloop
            call DestroyGroup(g)
            set bc=null
            set g=null
            set bc2=null
            set p=null
            call TimerStart(CreateTimer(),0,false,function PreLoader.run)
        endmethod
    endmodule
    struct UnitIndex extends array
        method operator locks takes nothing returns integer
            return lc[this]
        endmethod
        method operator locks= takes integer v returns nothing
            set lc[this] = v
        endmethod
        method lock takes nothing returns nothing
            debug if (null!=e[this]) then
                set lc[this]=lc[this]+1
            debug else
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"UNIT INDEXER ERROR: ATTEMPT TO LOCK NULL INDEX")
            debug endif
        endmethod
        method unlock takes nothing returns nothing
            debug if (0<lc[this]) then
                set lc[this]=lc[this]-1
                if (0==lc[this] and null==e[this]) then
                    set n[this]=y
                    set y=this
                endif
            debug else
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"UNIT INDEXER ERROR: ATTEMPT TO UNLOCK UNLOCKED INDEX")
            debug endif
        endmethod
        method operator unit takes nothing returns unit
            return e[this]
        endmethod
        static method operator [] takes unit whichUnit returns thistype
            return GetUnitUserData(whichUnit)
        endmethod
    endstruct
    struct UnitIndexer extends array
        readonly static Event INDEX
        readonly static Event DEINDEX
        static boolean enabled = true
        private static method onEnter takes nothing returns boolean
            local unit Q=GetFilterUnit()
            local integer i
            local integer d=o
            if (enabled and Q!=e[GetUnitUserData(Q)] and 0==GetUnitUserData(Q)) then
                if (0==y) then
                    set r=r+1
                    set i=r
                else
                    set i=y
                    set y=n[y]
                endif
                call UnitAddAbility(Q,ABILITIES_UNIT_INDEXER)
                call UnitMakeAbilityPermanent(Q,true,ABILITIES_UNIT_INDEXER)
                call SetUnitUserData(Q,i)
                set e[i]=Q
                static if not LIBRARY_UnitList then
                    if (not a)then
                        set p[i]=p[0]
                        set n[p[0]]=i
                        set n[i]=0
                        set p[0]=i
                    endif
                else
                    set p[i]=p[0]
                    set n[p[0]]=i
                    set n[i]=0
                    set p[0]=i
                    call GroupAddUnit(g,e[i])
                endif
                set o=i
                call FireEvent(INDEX)
                set o=d
            endif
            set Q=null
            return false
        endmethod
        private static method onLeave takes nothing returns boolean
            static if LIBRARY_UnitEvent then
                implement optional UnitEventModule
            else
                local unit u=GetFilterUnit()
                local integer i=GetUnitUserData(u)
                local integer d=o
                if (0==GetUnitAbilityLevel(u,ABILITIES_UNIT_INDEXER) and u==e[i]) then
                    static if not LIBRARY_UnitList then
                        if (not a)then
                            set n[p[i]]=n[i]
                            set p[n[i]]=p[i]
                        endif
                    else
                        set n[p[i]]=n[i]
                        set p[n[i]]=p[i]
                        call GroupRemoveUnit(g,e[i])
                    endif
                    set o=i
                    call FireEvent(DEINDEX)
                    set o=d
                    if (0==lc[i]) then
                        set n[i]=y
                        set y=i
                    endif
                    set e[i]=null
                endif
                set u=null
            endif
            return false
        endmethod
        implement UnitIndexerInit
    endstruct
    //! runtextmacro optional UNIT_EVENT_MACRO_2()
    function RegisterUnitIndexEvent takes boolexpr c,integer ev returns nothing
        call RegisterEvent(c, ev)
        if (not a and ev==UnitIndexer.INDEX and 0!=n[0]) then
            call PreLoader.evalb(c)
        endif
    endfunction
    function TriggerRegisterUnitIndexEvent takes trigger t,integer ev returns nothing
        call TriggerRegisterEvent(t,ev)
        if (not a and ev == UnitIndexer.INDEX and 0!=n[0]) then
            call PreLoader.eval(t)
        endif
    endfunction
    function GetUnitById takes integer W returns unit
        return e[W]
    endfunction
    function GetUnitId takes unit u returns integer
        return GetUnitUserData(u)
    endfunction
    function IsUnitIndexed takes unit u returns boolean
        return u==e[GetUnitUserData(u)]
    endfunction
    function IsUnitDeindexing takes unit u returns boolean
        return IsUnitIndexed(u) and 0==GetUnitAbilityLevel(u,ABILITIES_UNIT_INDEXER)
    endfunction
    module UnitIndexStructMethods
        static method operator [] takes unit u returns thistype
            return GetUnitUserData(u)
        endmethod
        method operator unit takes nothing returns unit
            return e[this]
        endmethod
    endmodule
    module UnitIndexStruct
        implement UnitIndexStructMethods
        
        static if thistype.filter.exists then
            static if thistype.index.exists then
                static if thistype.deindex.exists then
                    readonly boolean allocated
                else
                    method operator allocated takes nothing returns boolean
                        return filter(e[this])
                    endmethod
                endif
            else
                method operator allocated takes nothing returns boolean
                    return filter(e[this])
                endmethod
            endif
        elseif (thistype.index.exists) then
            static if thistype.deindex.exists then
                readonly boolean allocated
            else
                method operator allocated takes nothing returns boolean
                    return this==GetUnitUserData(e[this])
                endmethod
            endif
        else
            method operator allocated takes nothing returns boolean
                return this==GetUnitUserData(e[this])
            endmethod
        endif
        static if thistype.index.exists then
            private static method onIndexEvent takes nothing returns boolean
                static if thistype.filter.exists then
                    if (filter(e[o])) then
                        static if thistype.deindex.exists then
                            set thistype(o).allocated=true
                        endif
                        call thistype(o).index()
                    endif
                else
                    static if thistype.deindex.exists then
                        set thistype(o).allocated=true
                    endif
                    call thistype(o).index()
                endif
                return false
            endmethod
        endif
        static if thistype.deindex.exists then
            private static method onDeindexEvent takes nothing returns boolean
                static if thistype.filter.exists then
                    static if thistype.index.exists then
                        if (thistype(o).allocated) then
                            set thistype(o).allocated=false
                            call thistype(o).deindex()
                        endif
                    else
                        if (filter(e[o])) then
                            call thistype(o).deindex()
                        endif
                    endif
                else
                    static if thistype.index.exists then
                        set thistype(o).allocated=false
                    endif
                    call thistype(o).deindex()
                endif
                return false
            endmethod
        endif
        static if thistype.index.exists then
            static if thistype.deindex.exists then
                private static method onInit takes nothing returns nothing
                    call RegisterUnitIndexEvent(Condition(function thistype.onIndexEvent),UnitIndexer.INDEX)
                    call RegisterUnitIndexEvent(Condition(function thistype.onDeindexEvent),UnitIndexer.DEINDEX)
                endmethod
            else
                private static method onInit takes nothing returns nothing
                    call RegisterUnitIndexEvent(Condition(function thistype.onIndexEvent),UnitIndexer.INDEX)
                endmethod
            endif
        elseif thistype.deindex.exists then
            private static method onInit takes nothing returns nothing
                call RegisterUnitIndexEvent(Condition(function thistype.onDeindexEvent),UnitIndexer.DEINDEX)
            endmethod
        endif
    endmodule
endlibrary