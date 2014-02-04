library SpellStruct /* v1.0.3.6
*************************************************************************************
*
*   An efficient and easy to use module for spell design.
*
*************************************************************************************
*
*   */uses/*
*   
*       */ Position /*              hiveworkshop.com/forums/submissions-414/snippet-position-184578/
*       */ SpellEffectEvent /*      hiveworkshop.com/forums/jass-functions-413/snippet-spelleffectevent-187193/
*       */ UnitEvent /*             hiveworkshop.com/forums/jass-functions-413/extension-unit-event-172365/
*
************************************************************************************
*
*   constant integer SPELL_FINISHED
*   constant integer SPELL_CANCELED
*   constant integer SPELL_CASTER_INVALID
*   constant integer SPELL_TARGET_INVALID
*
*   module SpellStructTop
*
*    -    Implement at the top of the struct. Avoids trigger generation from jasshelper.
*
*   module SpellStructBot
*
*    -    Implement at the bottom of the struct
*
*   module SpellStruct
*
*    -    Implement at the bottom of the struct. Implements both SpellStructTop and SpellStructBot.
*
*       readonly unit caster                (always present)
*       readonly Position target            (always present)
*
*       readonly boolean casting            (always present)
*       readonly boolean channeling         (always present)
*       readonly boolean finished           (always present)
*       readonly integer endCastReason      (always present)
*
*       (Interface) - "this" refers to unit index of caster
*
*           private static constant integer ABILITY_ID                  (not optional)
*
*           private method onChannel takes nothing returns nothing      (optional)
*               runs when channeling beings
*           private method onCast takes nothing returns nothing         (optional)
*               runs when casting begins
*           private method onEffect takes nothing returns nothing       (optional)
*               runs when casting begins
*           private method onFinish takes nothing returns nothing       (optional)
*               runs when the casting is finished
*           private method onEndCast takes nothing returns nothing      (optional)
*               runs when the casting is finished or was canceled for some reason
*
************************************************************************************/
    //! textmacro SPELL_STRUCT_HANDLER takes SPELL1, SPELL2
        private function $SPELL2$ takes nothing returns boolean
            return TriggerEvaluate($SPELL1$.trigger[GetSpellAbilityId()])
        endfunction
    //! endtextmacro
    //! textmacro SPELL_STRUCT_ON_SPELL_METHOD takes SPELL
        private static method on$SPELL$P takes nothing returns boolean
            local thistype this=GetUnitUserData(GetTriggerUnit())
    //! endtextmacro
    //! textmacro SPELL_STRUCT_ON_SPELL_METHOD_2
            return false
        endmethod
    //! endtextmacro
    //! textmacro SPELL_STRUCT_ON_SPELL takes SPELL1, SPELL2
        if (not $SPELL1$.handle.has(ABILITY_ID)) then
            set $SPELL1$.trigger[ABILITY_ID]=CreateTrigger()
        endif
        call TriggerAddCondition($SPELL1$.trigger[ABILITY_ID],Condition(function thistype.on$SPELL2$P))
    //! endtextmacro
    //! textmacro SPELL_STRUCT_HANDLER_INIT takes SPELL1, SPELL2, EVENT
        set $SPELL1$ = Table.create()
        call RegisterPlayerUnitEvent($EVENT$,function $SPELL2$)
    //! endtextmacro
    globals
        private Table channel
        private Table cast
        private Table finish
        private Table endCast
        private location l = Location(0,0)
        constant integer SPELL_FINISHED=0
        constant integer SPELL_CANCELED=1
        constant integer SPELL_CASTER_INVALID=2
        constant integer SPELL_TARGET_INVALID=3
    endglobals
    
    //! runtextmacro SPELL_STRUCT_HANDLER("channel","Channel")
    //! runtextmacro SPELL_STRUCT_HANDLER("cast","Cast")
    //! runtextmacro SPELL_STRUCT_HANDLER("finish","Finish")
    //! runtextmacro SPELL_STRUCT_HANDLER("endCast","EndCast")
    
    private module In
        private static method onInit takes nothing returns nothing
            //! runtextmacro SPELL_STRUCT_HANDLER_INIT("channel","Channel","EVENT_PLAYER_UNIT_SPELL_CHANNEL")
            //! runtextmacro SPELL_STRUCT_HANDLER_INIT("cast","Cast","EVENT_PLAYER_UNIT_SPELL_CAST")
            //! runtextmacro SPELL_STRUCT_HANDLER_INIT("finish","Finish","EVENT_PLAYER_UNIT_SPELL_FINISH")
            //! runtextmacro SPELL_STRUCT_HANDLER_INIT("endCast","EndCast","EVENT_PLAYER_UNIT_SPELL_ENDCAST")
        endmethod
    endmodule
    private struct I extends array
        implement In
    endstruct
    
    private function GetSpellTarget takes unit caster returns Position
        local location z
        local Position target
        
        if (null!=GetSpellTargetUnit()) then
            set target=Position[GetSpellTargetUnit()]
        elseif (null!=GetSpellTargetItem()) then
            set target=Position[GetSpellTargetItem()]
        elseif (null!=GetSpellTargetDestructable()) then
            set target=Position[GetSpellTargetDestructable()]
        else
            set z=GetSpellTargetLoc()
            if (null!=z) then
                set target=Position[z]
                set z=null
            else
                call MoveLocation(l,GetWidgetX(caster),GetWidgetY(caster))
                set target=Position.create(GetWidgetX(caster),GetWidgetY(caster),GetLocationZ(l)+GetUnitFlyHeight(caster))
            endif
        endif
        
        return target
    endfunction
    
    private function GetFinishReason takes unit caster, UnitIndex casterId, Position target returns integer
        if (IsUnitDead(casterId) or IsUnitReincarnating(casterId) or null==GetUnitById(casterId)) then
            return SPELL_CASTER_INVALID
        elseif (not target.valid) then
            return SPELL_TARGET_INVALID
        endif
        return 0
    endfunction
    
    globals
        private Position array trg
        private unit array cst
        
        private boolean array cng
        private boolean array chn
        private boolean array fns
        
        private integer array ecr
    endglobals

    module SpellStructTop
        method operator target takes nothing returns Position
            return trg[this]
        endmethod
        method operator caster takes nothing returns unit
            return cst[this]
        endmethod
        method operator casting takes nothing returns boolean
            return cng[this]
        endmethod
        method operator channeling takes nothing returns boolean
            return chn[this]
        endmethod
        method operator finished takes nothing returns boolean
            return fns[this]
        endmethod
        method operator endCastReason takes nothing returns integer
            return ecr[this]
        endmethod
    endmodule

    module SpellStructBot
        private method allocate takes nothing returns nothing
            set cst[this]=GetUnitById(this)
            set trg[this] = GetSpellTarget(cst[this])
            
            call trg[this].lock()
            
            if (IsUnitIndexed(GetTriggerUnit())) then
                call UnitIndex(this).lock()
            endif
        endmethod
        
        //! runtextmacro SPELL_STRUCT_ON_SPELL_METHOD("Channel")
            set chn[this]=true
            call allocate()
            static if thistype.onChannel.exists then
                call onChannel()
            endif
        //! runtextmacro SPELL_STRUCT_ON_SPELL_METHOD_2()
        
        //! runtextmacro SPELL_STRUCT_ON_SPELL_METHOD("Cast")
            
            
            if (chn[this]) then
                set chn[this]=false
                set cng[this]=true
                
                static if thistype.onCast.exists then
                    call onCast()
                endif
            endif
        //! runtextmacro SPELL_STRUCT_ON_SPELL_METHOD_2()
        
        static if thistype.onEffect.exists then
            //! runtextmacro SPELL_STRUCT_ON_SPELL_METHOD("Effect")
                if (cng[this]) then
                    call onEffect()
                endif
            //! runtextmacro SPELL_STRUCT_ON_SPELL_METHOD_2()
        endif
        
        //! runtextmacro SPELL_STRUCT_ON_SPELL_METHOD("Finish")
            set ecr[this] = GetFinishReason(cst[this],this,trg[this])
            
            set cng[this] = false
            
            set fns[this]=0==ecr[this]
            
            static if thistype.onFinish.exists then
                if (fns[this]) then
                    call onFinish()
                else
                    set chn[this] = false
                endif
            else
                set chn[this] = false
            endif
        //! runtextmacro SPELL_STRUCT_ON_SPELL_METHOD_2()
        
        //! runtextmacro SPELL_STRUCT_ON_SPELL_METHOD("EndCast")
            if (not fns[this] and 0==ecr[this]) then
                set ecr[this]=SPELL_CANCELED
                set chn[this]=false
                set cng[this]=false
            else
                set fns[this]=false
            endif
            static if thistype.onEndCast.exists then
                call onEndCast()
            endif
            set cst[this]=null
            set ecr[this]=0
            call trg[this].unlock()
            if (IsUnitIndexed(GetTriggerUnit())) then
                call UnitIndex(this).unlock()
            endif
        //! runtextmacro SPELL_STRUCT_ON_SPELL_METHOD_2()
        
        private static method onInit takes nothing returns nothing
            //! runtextmacro SPELL_STRUCT_ON_SPELL("channel", "Channel")
            //! runtextmacro SPELL_STRUCT_ON_SPELL("cast", "Cast")
            //! runtextmacro SPELL_STRUCT_ON_SPELL("finish", "Finish")
            //! runtextmacro SPELL_STRUCT_ON_SPELL("endCast", "EndCast")
            
            static if thistype.onEffect.exists then
                call RegisterSpellEffectEvent(ABILITY_ID,function thistype.onEffectP)
            endif
        endmethod
    endmodule

    module SpellStruct
        implement SpellStructTop
        implement SpellStructBot
    endmodule
endlibrary