library SharedStack /* v1.0.0.2
************************************************************************************
*
*   */uses/*
*   
*       */ ErrorMessage /*         hiveworkshop.com/forums/submissions-414/snippet-error-message-239210/
*
************************************************************************************
*
*   module SharedStack
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
*               - May only destroy stacks
*
*           method push takes nothing returns thistype
*           method pop takes nothing returns nothing
*
*           method clear takes nothing returns nothing
*
*           debug static method calculateMemoryUsage takes nothing returns integer
*           debug static method getAllocatedMemoryAsString takes nothing returns string
*
************************************************************************************/
    module SharedStack
        private static thistype instanceCount = 0
        debug private boolean isNode
        debug private boolean isCollection
        
        private thistype _next
        method operator next takes nothing returns thistype
            debug call ThrowError(this == 0,        "SharedStack", "next", "thistype", this, "Attempted To Go Out Of Bounds.")
            debug call ThrowError(isCollection,     "SharedStack", "next", "thistype", this, "Attempted To Read Stack, Expecting Node.")
            debug call ThrowError(not isNode,       "SharedStack", "next", "thistype", this, "Attempted To Read Invalid Node.")
            return _next
        endmethod
        
        method operator first takes nothing returns thistype
            debug call ThrowError(this == 0,            "SharedStack", "first", "thistype", this, "Attempted To Read Null Stack.")
            debug call ThrowError(isNode,               "SharedStack", "first", "thistype", this, "Attempted To Read Node, Expecting Stack.")
            debug call ThrowError(not isCollection,     "SharedStack", "first", "thistype", this, "Attempted To Read Invalid Stack.")
            return _next
        endmethod
        
        static method operator sentinel takes nothing returns integer
            return 0
        endmethod
        
        private static method allocate takes nothing returns thistype
            local thistype this = thistype(0)._next
            
            if (0 == this) then
                debug call ThrowError(instanceCount == 8191, "SharedStack", "allocate", "thistype", 0, "Overflow.")
                
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
            
            debug call ThrowError(this == 0,            "SharedStack", "push", "thistype", this, "Attempted To Push On To Null Stack.")
            debug call ThrowError(isNode,               "SharedStack", "push", "thistype", this, "Attempted To Push On To Node, Expecting Stack.")
            debug call ThrowError(not isCollection,     "SharedStack", "push", "thistype", this, "Attempted To Push On To Invalid Stack.")
            
            debug set node.isNode = true
            
            set node._next = _next
            set _next = node
            
            return node
        endmethod
        method pop takes nothing returns nothing
            local thistype node = _next
            
            debug call ThrowError(this == 0,            "SharedStack", "pop", "thistype", this, "Attempted To Pop Null Stack.")
            debug call ThrowError(isNode,               "SharedStack", "pop", "thistype", this, "Attempted To Pop Node, Expecting Stack.")
            debug call ThrowError(not isCollection,     "SharedStack", "pop", "thistype", this, "Attempted To Pop Invalid Stack.")
            debug call ThrowError(node == 0,            "SharedStack", "pop", "thistype", this, "Attempted To Pop Empty Stack.")
            
            debug set node.isNode = false
            
            set _next = node._next
            set node._next = thistype(0)._next
            set thistype(0)._next = node
        endmethod
        private method getBottom takes nothing returns thistype        
            loop
                exitwhen _next == 0
                set this = _next
            endloop
            
            return this
        endmethod
        method clear takes nothing returns nothing
            debug local thistype node = _next
        
            debug call ThrowError(this == 0,            "SharedStack", "clear", "thistype", this, "Attempted To Clear Null Stack.")
            debug call ThrowError(isNode,               "SharedStack", "clear", "thistype", this, "Attempted To Clear Node, Expecting Stack.")
            debug call ThrowError(not isCollection,     "SharedStack", "clear", "thistype", this, "Attempted To Clear Invalid Stack.")
            
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
            
            set getBottom()._next = thistype(0)._next
            set thistype(0)._next = _next
            set _next = 0
        endmethod
        method destroy takes nothing returns nothing
            debug call ThrowError(this == 0,            "SharedStack", "destroy", "thistype", this, "Attempted To Destroy Null Stack.")
            debug call ThrowError(isNode,               "SharedStack", "destroy", "thistype", this, "Attempted To Destroy Node, Expecting Stack.")
            debug call ThrowError(not isCollection,     "SharedStack", "destroy", "thistype", this, "Attempted To Destroy Invalid Stack.")
            
            debug call clear()
            
            debug set isCollection = false
            
            set getBottom()._next = thistype(0)._next
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