library StunEvent /* v1.0.0.0
*************************************************************************************
*
*   Event response for stunned units
*
*************************************************************************************
*
*   */uses/*
*       */ Event /*             hiveworkshop.com/forums/submissions-414/snippet-event-186555/
*
*************************************************************************************
*
*    struct StunEvent extends array
*
*       readonly Event EVENT
*           -   stun unit event
*       readonly unit unit
*           -   stunned unit
*
************************************************************************************/
    private module I
        private static method O takes nothing returns boolean
            local unit u
            if (GetIssuedOrderId() == 851973) then
                set u=unit
                set unit=GetTriggerUnit()
                call EVENT.fire()
                set unit=u
                set u=null
            endif
            return false
        endmethod
        private static method onInit takes nothing returns nothing
            local integer i=15
            local trigger t=CreateTrigger()
            loop
                call TriggerRegisterPlayerUnitEvent(t,Player(i),EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER,null)
                exitwhen i==0
                set i=i-1
            endloop
            call TriggerAddCondition(t,Condition(function thistype.O))
            set EVENT=CreateEvent()
            set t=null
        endmethod
    endmodule
    struct StunEvent extends array
        readonly static Event EVENT=0
        readonly static unit unit = null
        implement I
    endstruct
endlibrary