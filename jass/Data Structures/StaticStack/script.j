library StaticStack /* v1.0.0.2
************************************************************************************
*
*   */uses/*
*   
*       */ ErrorMessage /*         hiveworkshop.com/forums/submissions-414/snippet-error-message-239210/
*
************************************************************************************
*
*   module StaticStack
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
*           debug static method calculateMemoryUsage takes nothing returns integer
*           debug static method getAllocatedMemoryAsString takes nothing returns string
*
************************************************************************************/
    module StaticStack
        private static thistype nodeCount = 0
        debug private boolean isNode
        
        private thistype _next
        method operator next takes nothing returns thistype
            debug call ThrowError(this == 0,        "StaticStack", "next", "thistype", this, "Attempted To Go Out Of Bounds.")
            debug call ThrowError(not isNode,       "StaticStack", "next", "thistype", this, "Attempted To Read Invalid Node.")
            return _next
        endmethod
        
        readonly static thistype first = 0
        
        static method operator sentinel takes nothing returns integer
            return 0
        endmethod
        
        private static method allocateNode takes nothing returns thistype
            local thistype this = thistype(0)._next
            
            if (0 == this) then
                debug call ThrowError(nodeCount == 8191, "StaticStack", "allocateNode", "thistype", 0, "Overflow.")
                
                set this = nodeCount + 1
                set nodeCount = this
            else
                set thistype(0)._next = _next
            endif
            
            return this
        endmethod
        
        static method push takes nothing returns thistype
            local thistype node = allocateNode()
            
            debug set node.isNode = true
            
            set node._next = first
            set first = node
            
            return node
        endmethod
        static method pop takes nothing returns nothing
            local thistype node = first
            
            debug call ThrowError(node == 0,            "StaticStack", "pop", "thistype", 0, "Attempted To Pop Empty Stack.")
            
            debug set node.isNode = false
            
            set first = node._next
            
            set node._next = thistype(0)._next
            set thistype(0)._next = node
        endmethod
        private static method getBottom takes nothing returns thistype
            local thistype this = first
        
            loop
                exitwhen _next == 0
                set this = _next
            endloop
            
            return this
        endmethod
        static method clear takes nothing returns nothing
            debug local thistype node = first
            
            static if DEBUG_MODE then
                loop
                    exitwhen node == 0
                    set node.isNode = false
                    set node = node._next
                endloop
            endif
            
            if (first == 0) then
                return
            endif
            
            set getBottom()._next = thistype(0)._next
            set thistype(0)._next = first
            set first = 0
        endmethod
        
        static if DEBUG_MODE then
            static method calculateMemoryUsage takes nothing returns integer
                local thistype start = 1
                local thistype end = nodeCount
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
                    set start = start + 1
                endloop
                
                return count
            endmethod
            
            static method getAllocatedMemoryAsString takes nothing returns string
                local thistype start = 1
                local thistype end = nodeCount
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
                    set start = start + 1
                endloop
                
                return memory
            endmethod
        endif
    endmodule
endlibrary