library Queue /* v1.0.0.6
************************************************************************************
*
*   */uses/*
*   
*       */ ErrorMessage /*         hiveworkshop.com/forums/submissions-414/snippet-error-message-239210/
*
************************************************************************************
*
*   module Queue
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
*           readonly thistype first
*           readonly thistype next
*
*       Methods
*       -------------------------
*
*           static method create takes nothing returns thistype
*           method destroy takes nothing returns nothing
*               - May only destroy queues
*
*           method enqueue takes nothing returns thistype
*           method pop takes nothing returns nothing
*
*           method clear takes nothing returns nothing
*
*           debug static method calculateMemoryUsage takes nothing returns integer
*           debug static method getAllocatedMemoryAsString takes nothing returns string
*
************************************************************************************/
    module Queue
        private static thistype collectionCount = 0
        private static thistype nodeCount = 0
        debug private boolean isNode
        debug private boolean isCollection
        
        private thistype last
        
        private thistype _next
        method operator next takes nothing returns thistype
            debug call ThrowError(this == 0,        "Queue", "next", "thistype", this, "Attempted To Go Out Of Bounds.")
            debug call ThrowError(not isNode,       "Queue", "next", "thistype", this, "Attempted To Read Invalid Node.")
            return _next
        endmethod
        
        private thistype _first
        method operator first takes nothing returns thistype
            debug call ThrowError(this == 0,            "Queue", "first", "thistype", this, "Attempted To Read Null Queue.")
            debug call ThrowError(not isCollection,     "Queue", "first", "thistype", this, "Attempted To Read Invalid Queue.")
            return _first
        endmethod
        
        static method operator sentinel takes nothing returns integer
            return 0
        endmethod
        
        private static method allocateCollection takes nothing returns thistype
            local thistype this = thistype(0)._first
            
            if (0 == this) then
                debug call ThrowError(collectionCount == 8191, "Queue", "allocateCollection", "thistype", 0, "Overflow.")
                
                set this = collectionCount + 1
                set collectionCount = this
            else
                set thistype(0)._first = _first
            endif
            
            return this
        endmethod
        
        private static method allocateNode takes nothing returns thistype
            local thistype this = thistype(0)._next
            
            if (0 == this) then
                debug call ThrowError(nodeCount == 8191, "Queue", "allocateNode", "thistype", 0, "Overflow.")
                
                set this = nodeCount + 1
                set nodeCount = this
            else
                set thistype(0)._next = _next
            endif
            
            return this
        endmethod
        
        static method create takes nothing returns thistype
            local thistype this = allocateCollection()     
            
            debug set isCollection = true
            
            set _first = 0
            
            return this
        endmethod
        method enqueue takes nothing returns thistype
            local thistype node = allocateNode()
            
            debug call ThrowError(this == 0,            "Queue", "enqueue", "thistype", this, "Attempted To Enqueue On To Null Queue.")
            debug call ThrowError(not isCollection,     "Queue", "enqueue", "thistype", this, "Attempted To Enqueue On To Invalid Queue.")
            
            debug set node.isNode = true
            
            if (_first == 0) then
                set _first = node
            else
                set last._next = node
            endif
            
            set last = node
            set node._next = 0
            
            return node
        endmethod
        method pop takes nothing returns nothing
            local thistype node = _first
            
            debug call ThrowError(this == 0,            "Queue", "pop", "thistype", this, "Attempted To Pop Null Queue.")
            debug call ThrowError(not isCollection,     "Queue", "pop", "thistype", this, "Attempted To Pop Invalid Queue.")
            debug call ThrowError(node == 0,            "Queue", "pop", "thistype", this, "Attempted To Pop Empty Queue.")
            
            debug set node.isNode = false
            
            set _first = node._next
            set node._next = thistype(0)._next
            set thistype(0)._next = node
        endmethod
        method clear takes nothing returns nothing
            debug local thistype node = _first
        
            debug call ThrowError(this == 0,            "Queue", "clear", "thistype", this, "Attempted To Clear Null Queue.")
            debug call ThrowError(not isCollection,     "Queue", "clear", "thistype", this, "Attempted To Clear Invalid Queue.")
            
            static if DEBUG_MODE then
                loop
                    exitwhen node == 0
                    set node.isNode = false
                    set node = node._next
                endloop
            endif
            
            if (_first == 0) then
                return
            endif
            
            set last._next = thistype(0)._next
            set thistype(0)._next = _first
            
            set _first = 0
        endmethod
        method destroy takes nothing returns nothing
            debug call ThrowError(this == 0,            "Queue", "destroy", "thistype", this, "Attempted To Destroy Null Queue.")
            debug call ThrowError(not isCollection,     "Queue", "destroy", "thistype", this, "Attempted To Destroy Invalid Queue.")
            
            static if DEBUG_MODE then
                debug call clear()
                
                debug set isCollection = false
            else
                if (_first != 0) then
                    set last._next = thistype(0)._next
                    set thistype(0)._next = _first
                endif
            endif
            
            set _first = thistype(0)._first
            set thistype(0)._first = this
        endmethod
        
        static if DEBUG_MODE then
            static method calculateMemoryUsage takes nothing returns integer
                local thistype start = 1
                local thistype end = 8191
                local integer count = 0
                
                loop
                    exitwhen integer(start) > integer(end)
                    if (integer(start) + 500 > integer(end)) then
                        return count + checkRegion(start, end)
                    else
                        set count = count + checkRegion(start, start + 500)
                        set start = start + 501
                    endif
                endloop
                
                return count
            endmethod
              
            private static method checkRegion takes thistype start, thistype end returns integer
                local integer count = 0
            
                loop
                    exitwhen integer(start) > integer(end)
                    if (start.isNode) then
                        set count = count + 1
                    endif
                    if (start.isCollection) then
                        set count = count + 1
                    endif
                    set start = start + 1
                endloop
                
                return count
            endmethod
            
            static method getAllocatedMemoryAsString takes nothing returns string
                local thistype start = 1
                local thistype end = 8191
                local string memory = null
                
                loop
                    exitwhen integer(start) > integer(end)
                    if (integer(start) + 500 > integer(end)) then
                        if (memory != null) then
                            set memory = memory + ", "
                        endif
                        set memory = memory + checkRegion2(start, end)
                        set start = end + 1
                    else
                        if (memory != null) then
                            set memory = memory + ", "
                        endif
                        set memory = memory + checkRegion2(start, start + 500)
                        set start = start + 501
                    endif
                endloop
                
                return memory
            endmethod
              
            private static method checkRegion2 takes thistype start, thistype end returns string
                local string memory = null
            
                loop
                    exitwhen integer(start) > integer(end)
                    if (start.isNode) then
                        if (memory == null) then
                            set memory = I2S(start)
                        else
                            set memory = memory + ", " + I2S(start) + "N"
                        endif
                    endif
                    if (start.isCollection) then
                        if (memory == null) then
                            set memory = I2S(start)
                        else
                            set memory = memory + ", " + I2S(start) + "C"
                        endif
                    endif
                    set start = start + 1
                endloop
                
                return memory
            endmethod
        endif
    endmodule
endlibrary