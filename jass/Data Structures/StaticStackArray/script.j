library StaticStackArray /* v1.0.0.0
************************************************************************************
*
*   */uses/*
*   
*       */ ErrorMessage /*         hiveworkshop.com/forums/submissions-414/snippet-error-message-239210/
*
************************************************************************************
*
*   module StaticStackArray
*
*       Description
*       -------------------------
*
*           NA
*
*       Fields
*       -------------------------
*
*           readonly static integer sentinel
*
*           readonly static thistype first
*           readonly thistype next
*
*       Methods
*       -------------------------
*
*           static method push takes nothing returns thistype
*           static method pop takes nothing returns nothing
*
*           static method clear takes nothing returns nothing
*
************************************************************************************/
    module StaticStackArray
        readonly static thistype first = 0
        
        method operator next takes nothing returns thistype
            debug call ThrowError(integer(this) <= 0 or integer(this) > integer(first), "StaticStack", "next", "thistype", this, "Attempted To Go Out Of Bounds.")
            return this - 1
        endmethod
        
        static method operator sentinel takes nothing returns integer
            return 0
        endmethod
        
        static method push takes nothing returns thistype
            debug call ThrowError(first == 8191, "StaticStack", "push", "thistype", 0, "Overflow, Try Using UniqueStack Instead.")
            set first = first + 1
            return first
        endmethod
        static method pop takes nothing returns nothing
            debug call ThrowError(first == 0, "StaticStack", "pop", "thistype", 0, "Attempted To Pop Empty Stack.")
            set first = first - 1
        endmethod
        static method clear takes nothing returns nothing
            set first = 0
        endmethod
    endmodule
endlibrary