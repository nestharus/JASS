library SharedUniqueNxQueue /* v1.0.0.3
************************************************************************************
*
*   module SharedUniqueNxQueue
*
*       Description
*       -------------------------
*
*           Node Properties:
*
*               Unique to Node/Collection
*               Allocated
*               Not 0
*
*           Collection Properties:
*
*               Unique to Node/Collection
*               Allocated
*               Not 0
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
*           method destroy takes nothing returns nothing
*
*           method enqueue takes thistype node returns nothing
*           method pop takes nothing returns nothing
*
*           method clear takes nothing returns nothing
*               -   Initializes queue, use instead of create
*
*           debug static method calculateMemoryUsage takes nothing returns integer
*           debug static method getAllocatedMemoryAsString takes nothing returns string
*
************************************************************************************/
    module SharedUniqueNxQueue
        debug private boolean isCollection
        debug private boolean isNode
        
        private thistype last
        
        private thistype _next
        method operator next takes nothing returns thistype
            debug call ThrowError(this == 0,        "SharedUniqueNxQueue", "next", "thistype", this, "Attempted To Go Out Of Bounds.")
            debug call ThrowError(isCollection,     "SharedUniqueNxQueue", "next", "thistype", this, "Attempted To Read Stack, Expecting Node.")
            debug call ThrowError(not isNode,       "SharedUniqueNxQueue", "next", "thistype", this, "Attempted To Read Invalid Node.")
            return _next
        endmethod
        
        method operator first takes nothing returns thistype
            debug call ThrowError(this == 0,            "SharedUniqueNxQueue", "first", "thistype", this, "Attempted To Read Null Queue.")
            debug call ThrowError(isNode,               "SharedUniqueNxQueue", "first", "thistype", this, "Attempted To Read Node, Expecting Queue.")
            debug call ThrowError(not isCollection,     "SharedUniqueNxQueue", "first", "thistype", this, "Attempted To Read Invalid Queue.")
            return _next
        endmethod
        
        static method operator sentinel takes nothing returns integer
            return 0
        endmethod
        
        method clear takes nothing returns nothing
            debug local thistype node = _next
        
            debug call ThrowError(this == 0,            "SharedUniqueNxQueue", "clear", "thistype", this, "Attempted To Clear Null Queue.")
            debug call ThrowError(isNode,               "SharedUniqueNxQueue", "clear", "thistype", this, "Attempted To Clear Node, Expecting Queue.")
            
            debug if (not isCollection) then
                debug set isCollection = true
                
                debug set _next = 0
                debug set last = this
                
                debug return
            debug endif
            
            static if DEBUG_MODE then
                loop
                    exitwhen node == 0
                    set node.isNode = false
                    set node = node._next
                endloop
            endif
            
            set _next = 0
            set last = this
        endmethod
        method destroy takes nothing returns nothing
            debug call ThrowError(this == 0,            "SharedUniqueNxQueue", "destroy", "thistype", this, "Attempted To Destroy Null Queue.")
            debug call ThrowError(isNode,               "SharedUniqueNxQueue", "destroy", "thistype", this, "Attempted To Destroy Node, Expecting Queue.")
            debug call ThrowError(not isCollection,     "SharedUniqueNxQueue", "destroy", "thistype", this, "Attempted To Destroy Invalid Queue.")
            
            debug call clear()
            
            debug set isCollection = false
        endmethod
        method enqueue takes thistype node returns nothing
            debug call ThrowError(this == 0,            "SharedUniqueNxQueue", "enqueue", "thistype", this, "Attempted To Enqueue (" + I2S(node) + ") On To Null Queue.")
            debug call ThrowError(isNode,               "SharedUniqueNxQueue", "enqueue", "thistype", this, "Attempted To Enqueue (" + I2S(node) + ") On To Node Expecting Queue.")
            debug call ThrowError(not isCollection,     "SharedUniqueNxQueue", "enqueue", "thistype", this, "Attempted To Enqueue On To Invalid Queue.")
            debug call ThrowError(node.isNode,          "SharedUniqueNxQueue", "enqueue", "thistype", this, "Attempted To Enqueue Owned Node (" + I2S(node) + ").")
            
            debug set node.isNode = true
        
            set last._next = node
            set last = node
            set node._next = 0
        endmethod
        method pop takes nothing returns nothing
            local thistype node = _next
        
            debug call ThrowError(this == 0,            "SharedUniqueNxQueue", "pop", "thistype", this, "Attempted To Pop Null Queue.")
            debug call ThrowError(isNode,               "SharedUniqueNxQueue", "pop", "thistype", this, "Attempted To Pop Node, Expecting Queue.")
            debug call ThrowError(not isCollection,     "SharedUniqueNxQueue", "pop", "thistype", this, "Attempted To Pop Invalid Queue.")
            debug call ThrowError(node == 0,            "SharedUniqueNxQueue", "pop", "thistype", this, "Attempted To Pop Empty Queue.")
            
            debug set node.isNode = false
            
            set _next = node._next
            if (_next == 0) then
                set last = this
            endif
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
                    elseif (start.isCollection) then
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