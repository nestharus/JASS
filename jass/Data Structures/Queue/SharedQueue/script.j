library SharedQueue /* v1.0.0.2
************************************************************************************
*
*   */uses/*
*   
*       */ ErrorMessage /*         hiveworkshop.com/forums/submissions-414/snippet-error-message-239210/
*
************************************************************************************
*
*   module SharedQueue
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
    module SharedQueue
        private static thistype instanceCount = 0
        debug private boolean isNode
        debug private boolean isCollection
        
        private thistype last
        
        private thistype _next
        method operator next takes nothing returns thistype
            debug call ThrowError(this == 0,        "SharedQueue", "next", "thistype", this, "Attempted To Go Out Of Bounds.")
            debug call ThrowError(isCollection,     "SharedQueue", "next", "thistype", this, "Attempted To Read Queue, Expecting Node.")
            debug call ThrowError(not isNode,       "SharedQueue", "next", "thistype", this, "Attempted To Read Invalid Node.")
            return _next
        endmethod
        
        method operator first takes nothing returns thistype
            debug call ThrowError(this == 0,            "SharedQueue", "first", "thistype", this, "Attempted To Read Null Queue.")
            debug call ThrowError(isNode,               "SharedQueue", "first", "thistype", this, "Attempted To Read Node, Expecting Queue.")
            debug call ThrowError(not isCollection,     "SharedQueue", "first", "thistype", this, "Attempted To Read Invalid Queue.")
            return _next
        endmethod
        
        static method operator sentinel takes nothing returns integer
            return 0
        endmethod
        
        private static method allocate takes nothing returns thistype
            local thistype this = thistype(0)._next
            
            if (0 == this) then
                debug call ThrowError(instanceCount == 8191, "SharedQueue", "allocate", "thistype", 0, "Overflow.")
                
                set this = instanceCount + 1
                set instanceCount = this
            else
                set thistype(0)._next = _next
            endif
            
            return this
        endmethod
        
        static method create takes nothing returns thistype
            local thistype this = allocate()     
            
            debug set isCollection = true
            
            set last = this
            set _next = 0
            
            return this
        endmethod
        method enqueue takes nothing returns thistype
            local thistype node = allocate()
            
            debug call ThrowError(this == 0,            "SharedQueue", "enqueue", "thistype", this, "Attempted To Enqueue On To Null Queue.")
            debug call ThrowError(isNode,               "SharedQueue", "enqueue", "thistype", this, "Attempted To Enqueue On To Node, Expecting Queue.")
            debug call ThrowError(not isCollection,     "SharedQueue", "enqueue", "thistype", this, "Attempted To Enqueue On To Invalid Queue.")
            
            debug set node.isNode = true
            
            set last._next = node
            set last = node
            set node._next = 0
            
            return node
        endmethod
        method pop takes nothing returns nothing
            local thistype node = _next
            
            debug call ThrowError(this == 0,            "SharedQueue", "pop", "thistype", this, "Attempted To Pop Null Queue.")
            debug call ThrowError(isNode,               "SharedQueue", "pop", "thistype", this, "Attempted To Pop Node, Expecting Queue.")
            debug call ThrowError(not isCollection,     "SharedQueue", "pop", "thistype", this, "Attempted To Pop Invalid Queue.")
            debug call ThrowError(node == 0,            "SharedQueue", "pop", "thistype", this, "Attempted To Pop Empty Queue.")
            
            debug set node.isNode = false
            
            set _next = node._next
            if (_next == 0) then
                set last = this
            endif
            set node._next = thistype(0)._next
            set thistype(0)._next = node
        endmethod
        method clear takes nothing returns nothing
            debug local thistype node = _next
        
            debug call ThrowError(this == 0,            "SharedQueue", "clear", "thistype", this, "Attempted To Clear Null Queue.")
            debug call ThrowError(isNode,               "SharedQueue", "clear", "thistype", this, "Attempted To Clear Node, Expecting Queue.")
            debug call ThrowError(not isCollection,     "SharedQueue", "clear", "thistype", this, "Attempted To Clear Invalid Queue.")
            
            static if DEBUG_MODE then
                loop
                    exitwhen node == 0
                    set node.isNode = false
                    set node = node._next
                endloop
            endif
            
            if (_next == 0) then
                return
            endif
            
            set last._next = thistype(0)._next
            set thistype(0)._next = _next
            
            set _next = 0
            set last = this
        endmethod
        method destroy takes nothing returns nothing
            debug call ThrowError(this == 0,            "SharedQueue", "destroy", "thistype", this, "Attempted To Destroy Null Queue.")
            debug call ThrowError(isNode,               "SharedQueue", "destroy", "thistype", this, "Attempted To Destroy Node, Expecting Queue.")
            debug call ThrowError(not isCollection,     "SharedQueue", "destroy", "thistype", this, "Attempted To Destroy Invalid Queue.")
            
            debug call clear()
            
            debug set isCollection = false
            
            set last._next = thistype(0)._next
            set thistype(0)._next = this
        endmethod
        
        static if DEBUG_MODE then
            static method calculateMemoryUsage takes nothing returns integer
                local thistype start = 1
                local thistype end = instanceCount
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
                    elseif (start.isCollection) then
                        set count = count + 1
                    endif
                    set start = start + 1
                endloop
                
                return count
            endmethod
            
            static method getAllocatedMemoryAsString takes nothing returns string
                local thistype start = 1
                local thistype end = instanceCount
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
                    elseif (start.isCollection) then
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