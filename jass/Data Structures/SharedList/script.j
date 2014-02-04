library SharedList /* v1.0.0.2
************************************************************************************
*
*   */uses/*
*   
*       */ ErrorMessage /*         hiveworkshop.com/forums/submissions-414/snippet-error-message-239210/
*
************************************************************************************
*
*   module SharedList
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
*           readonly thistype list
*
*           readonly thistype first
*           readonly thistype last
*
*           readonly thistype next
*           readonly thistype prev
*
*       Methods
*       -------------------------
*
*           static method create takes nothing returns thistype
*           method destroy takes nothing returns nothing
*               - May only destroy lists
*
*           method push takes nothing returns thistype
*           method enqueue takes nothing returns thistype
*
*           method pop takes nothing returns nothing
*           method dequeue takes nothing returns nothing
*
*           method remove takes nothing returns nothing
*
*           method clear takes nothing returns nothing
*
*           debug static method calculateMemoryUsage takes nothing returns integer
*           debug static method getAllocatedMemoryAsString takes nothing returns string
*
************************************************************************************/
    module SharedList
        private static thistype instanceCount = 0
        debug private boolean isNode
        debug private boolean isCollection
        
        private thistype _list
        method operator list takes nothing returns thistype
            debug call ThrowError(this == 0,    "SharedList", "list", "thistype", this, "Attempted To Read Null Node.")
            debug call ThrowError(isCollection, "SharedList", "next", "thistype", this, "Attempted To Read List, Expecting Node.")
            debug call ThrowError(not isNode,   "SharedList", "list", "thistype", this, "Attempted To Read Invalid Node.")
            return _list
        endmethod
        
        private thistype _next
        method operator next takes nothing returns thistype
            debug call ThrowError(this == 0,        "SharedList", "next", "thistype", this, "Attempted To Go Out Of Bounds.")
            debug call ThrowError(isCollection,     "SharedList", "next", "thistype", this, "Attempted To Read List, Expecting Node.")
            debug call ThrowError(not isNode,       "SharedList", "next", "thistype", this, "Attempted To Read Invalid Node.")
            return _next
        endmethod
        
        private thistype _prev
        method operator prev takes nothing returns thistype
            debug call ThrowError(this == 0,        "SharedList", "prev", "thistype", this, "Attempted To Go Out Of Bounds.")
            debug call ThrowError(isCollection,     "SharedList", "prev", "thistype", this, "Attempted To Read List, Expecting Node.")
            debug call ThrowError(not isNode,       "SharedList", "prev", "thistype", this, "Attempted To Read Invalid Node.")
            return _prev
        endmethod
        
        method operator first takes nothing returns thistype
            debug call ThrowError(this == 0,            "SharedList", "first", "thistype", this, "Attempted To Read Null List.")
            debug call ThrowError(isNode,               "SharedList", "first", "thistype", this, "Attempted To Read Node, Expecting List.")
            debug call ThrowError(not isCollection,     "SharedList", "first", "thistype", this, "Attempted To Read Invalid List.")
            return _next
        endmethod
        
        method operator last takes nothing returns thistype
            debug call ThrowError(this == 0,            "SharedList", "last", "thistype", this, "Attempted To Read Null List.")
            debug call ThrowError(isNode,               "SharedList", "last", "thistype", this, "Attempted To Read Node, Expecting List.")
            debug call ThrowError(not isCollection,     "SharedList", "last", "thistype", this, "Attempted To Read Invalid List.")
            return _prev
        endmethod
        
        static method operator sentinel takes nothing returns integer
            return 0
        endmethod
        
        private static method allocate takes nothing returns thistype
            local thistype this = thistype(0)._next
            
            if (0 == this) then
                debug call ThrowError(instanceCount == 8191, "SharedList", "allocate", "thistype", 0, "Overflow.")
                
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
            
            set _next = 0
            
            return this
        endmethod
        
        method push takes nothing returns thistype
            local thistype node = allocate()
            
            debug call ThrowError(this == 0,            "SharedList", "push", "thistype", this, "Attempted To Push On To Null List.")
            debug call ThrowError(isNode,               "SharedList", "push", "thistype", this, "Attempted To Push On To Node, Expecting List.")
            debug call ThrowError(not isCollection,     "SharedList", "push", "thistype", this, "Attempted To Push On To Invalid List.")
            
            debug set node.isNode = true
            
            set node._list = this
        
            if (_next == 0) then
                set _next = node
                set _prev = node
                set node._next = 0
            else
                set _next._prev = node
                set node._next = _next
                set _next = node
            endif
            
            set node._prev = 0
            
            return node
        endmethod
        
        method enqueue takes nothing returns thistype
            local thistype node = allocate()
            
            debug call ThrowError(this == 0,            "SharedList", "enqueue", "thistype", this, "Attempted To Enqueue On To Null List.")
            debug call ThrowError(isNode,               "SharedList", "enqueue", "thistype", this, "Attempted To Enqueue On To Node, Expecting List.")
            debug call ThrowError(not isCollection,     "SharedList", "enqueue", "thistype", this, "Attempted To Enqueue On To Invalid List.")
            
            debug set node.isNode = true
            
            set node._list = this
        
            if (_next == 0) then
                set _next = node
                set _prev = node
                set node._prev = 0
            else
                set _prev._next = node
                set node._prev = _prev
                set _prev = node
            endif
            
            set node._next = 0
            
            return node
        endmethod
        method pop takes nothing returns nothing
            local thistype node = _next
            
            debug call ThrowError(this == 0,            "SharedList", "pop", "thistype", this, "Attempted To Pop Null List.")
            debug call ThrowError(isNode,               "SharedList", "pop", "thistype", this, "Attempted To Pop Node, Expecting List.")
            debug call ThrowError(not isCollection,     "SharedList", "pop", "thistype", this, "Attempted To Pop Invalid List.")
            debug call ThrowError(node == 0,            "SharedList", "pop", "thistype", this, "Attempted To Pop Empty List.")
            
            debug set node.isNode = false
            
            set _next._list = 0
            
            set _next = _next._next
            if (_next == 0) then
                set _prev = 0
            else
                set _next._prev = 0
            endif
            
            set node._next = thistype(0)._next
            set thistype(0)._next = node
        endmethod
        method dequeue takes nothing returns nothing
            local thistype node = _prev
            
            debug call ThrowError(this == 0,            "SharedList", "dequeue", "thistype", this, "Attempted To Dequeue Null List.")
            debug call ThrowError(isNode,               "SharedList", "dequeue", "thistype", this, "Attempted To Dequeue Node, Expecting List.")
            debug call ThrowError(not isCollection,     "SharedList", "dequeue", "thistype", this, "Attempted To Dequeue Invalid List.")
            debug call ThrowError(node == 0,            "SharedList", "dequeue", "thistype", this, "Attempted To Dequeue Empty List.")
            
            debug set node.isNode = false
            
            set _prev._list = 0
        
            set _prev = _prev._prev
            if (_prev == 0) then
                set _next = 0
            else
                set _prev._next = 0
            endif
            
            set node._next = thistype(0)._next
            set thistype(0)._next = node
        endmethod
        method remove takes nothing returns nothing
            local thistype node = this
            set this = node._list
            
            debug call ThrowError(node == 0,            "SharedList", "remove", "thistype", this, "Attempted To Remove Null Node.")
            debug call ThrowError(not node.isNode,      "SharedList", "remove", "thistype", this, "Attempted To Remove Invalid Node (" + I2S(node) + ").")
            debug call ThrowError(not isCollection,     "SharedList", "remove", "thistype", this, "Attempted To Remove Node (" + I2S(node) + ") From Invalid List.")
            debug call ThrowError(this == 0,            "SharedList", "remove", "thistype", this, "Attempted To Remove Node (" + I2S(node) + ") Not Belonging To A List.")
            
            debug set node.isNode = false
            
            set node._list = 0
        
            if (0 == node._prev) then
                set _next = node._next
            else
                set node._prev._next = node._next
            endif
            if (0 == node._next) then
                set _prev = node._prev
            else
                set node._next._prev = node._prev
            endif
            
            set node._next = thistype(0)._next
            set thistype(0)._next = node
        endmethod
        method clear takes nothing returns nothing
            debug local thistype node = _next
        
            debug call ThrowError(this == 0,            "SharedList", "clear", "thistype", this, "Attempted To Clear Null List.")
            debug call ThrowError(isNode,               "SharedList", "clear", "thistype", this, "Attempted To Clear Node, Expecting List.")
            debug call ThrowError(not isCollection,     "SharedList", "clear", "thistype", this, "Attempted To Clear Invalid List.")
            
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
            
            set _prev._next = thistype(0)._next
            set thistype(0)._next = _next
            
            set _next = 0
            set _prev = 0
        endmethod
        method destroy takes nothing returns nothing
            debug call ThrowError(this == 0,            "SharedList", "destroy", "thistype", this, "Attempted To Destroy Null List.")
            debug call ThrowError(isNode,               "SharedList", "destroy", "thistype", this, "Attempted To Destroy Node, Expecting List.")
            debug call ThrowError(not isCollection,     "SharedList", "destroy", "thistype", this, "Attempted To Destroy Invalid List.")
            
            static if DEBUG_MODE then
                debug call clear()
                
                debug set isCollection = false
            else
                if (_next != 0) then
                    set _prev._next = thistype(0)._next
                    set thistype(0)._next = _next
                    
                    set _prev = 0
                endif
            endif
            
            set _next = thistype(0)._next
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