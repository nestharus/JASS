library StaticQueueArray /* v1.0.0.0
************************************************************************************
*
*   */uses/*
*   
*       */ ErrorMessage /*         hiveworkshop.com/forums/submissions-414/snippet-error-message-239210/
*
************************************************************************************
*
*   module StaticQueueArray
*
*       Description
*       -------------------------
*
*           If continuing to add and remove without ever making the queue empty, will overflow
*           Automatically resets itself whenever the queue is empty (inside of pop)
*
*       Fields
*       -------------------------
*
*           readonly static integer sentinel
*
*           readonly static integer count
*
*           readonly static thistype first
*           readonly thistype next
*
*       Methods
*       -------------------------
*
*           static method enqueue takes nothing returns thistype
*           static method pop takes nothing returns nothing
*
*           static method clear takes nothing returns nothing
*
************************************************************************************/
    module StaticQueueArray
        readonly static thistype first = 0
        private static thistype last = 0
        
        static method operator count takes nothing returns integer
            return last - first
        endmethod
        
        static method operator sentinel takes nothing returns integer
            return last
        endmethod
        
        method operator next takes nothing returns thistype
            debug call ThrowError(integer(this) < integer(first) or integer(this) >= integer(last), "StaticQueue", "next", "thistype", this, "Attempted To Go Out Of Bounds.")
            
            return this + 1
        endmethod
        
        static method enqueue takes nothing returns thistype
            debug call ThrowError(last == 8191, "StaticQueue", "enqueue", "thistype", 0, "Overflow, Try Using UniqueQueue instead.")
            
            if (first == 0) then
                set first = 1
                set last = 1
            endif
            
            set last = last + 1
            
            return last - 1
        endmethod
        static method pop takes nothing returns nothing
            debug call ThrowError(integer(first) == integer(last), "StaticQueue", "pop", "StaticQueue", 0, "Attempted To Pop Empty Queue.")
            if (first == last) then
                set first = 0
                set last = 0
            else
                set first = first + 1
            endif
        endmethod
        static method clear takes nothing returns nothing
            set first = 0
            set last = 0
        endmethod
    endmodule
endlibrary