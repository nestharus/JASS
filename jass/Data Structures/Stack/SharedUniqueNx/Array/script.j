library SharedUniqueNxStack /* v1.0.0.2
************************************************************************************
*
*   module SharedUniqueNxStack
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
*           method push takes thistype node returns nothing
*           method pop takes nothing returns nothing
*
*           method clear takes nothing returns nothing
*               -   Initializes stack, use instead of create
*
*           debug static method calculateMemoryUsage takes nothing returns integer
*           debug static method getAllocatedMemoryAsString takes nothing returns string
*
************************************************************************************/
    module SharedUniqueNxStack
        debug private boolean isCollection
        debug private boolean isNode
        
        private thistype _next
        method operator next takes nothing returns thistype
            debug call ThrowError(this == 0,        "SharedUniqueNxStack", "next", "thistype", this, "Attempted To Go Out Of Bounds.")
            debug call ThrowError(isCollection,     "SharedUniqueNxStack", "next", "thistype", this, "Attempted To Read Stack, Expecting Node.")
            debug call ThrowError(not isNode,       "SharedUniqueNxStack", "next", "thistype", this, "Attempted To Read Invalid Node.")
            return _next
        endmethod
        
        method operator first takes nothing returns thistype
            debug call ThrowError(this == 0,            "SharedUniqueNxStack", "first", "thistype", this, "Attempted To Read Null Stack.")
            debug call ThrowError(isNode,               "SharedUniqueNxStack", "first", "thistype", this, "Attempted To Read Node, Expecting Stack.")
            debug call ThrowError(not isCollection,     "SharedUniqueNxStack", "first", "thistype", this, "Attempted To Read Invalid Stack.")
            return _next
        endmethod
        
        static method operator sentinel takes nothing returns integer
            return 0
        endmethod
        
        method clear takes nothing returns nothing
            debug local thistype node = _next
        
            debug call ThrowError(this == 0,            "SharedUniqueNxStack", "clear", "thistype", this, "Attempted To Clear Null Stack.")
            debug call ThrowError(isNode,               "SharedUniqueNxStack", "clear", "thistype", this, "Attempted To Clear Node, Expecting Stack.")
            
            debug if (not isCollection) then
                debug set isCollection = true
                
                debug set _next = 0
                
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
        endmethod
        method destroy takes nothing returns nothing
            debug call ThrowError(this == 0,            "SharedUniqueNxStack", "destroy", "thistype", this, "Attempted To Destroy Null Stack.")
            debug call ThrowError(isNode,               "SharedUniqueNxStack", "destroy", "thistype", this, "Attempted To Destroy Node, Expecting Stack.")
            debug call ThrowError(not isCollection,     "SharedUniqueNxStack", "destroy", "thistype", this, "Attempted To Destroy Invalid Stack.")
            
            debug call clear()
            
            debug set isCollection = false
        endmethod
        method push takes thistype node returns nothing
            debug call ThrowError(this == 0,            "SharedUniqueNxStack", "push", "thistype", this, "Attempted To Push (" + I2S(node) + ") On To Null Stack.")
            debug call ThrowError(isNode,               "SharedUniqueNxStack", "push", "thistype", this, "Attempted To Push (" + I2S(node) + ") On To Node, Expecting Stack.")
            debug call ThrowError(not isCollection,     "SharedUniqueNxStack", "push", "thistype", this, "Attempted To Push On To Invalid Stack.")
            debug call ThrowError(node.isNode,          "SharedUniqueNxStack", "push", "thistype", this, "Attempted To Push Owned Node (" + I2S(node) + ").")
            
            debug set node.isNode = true
        
            set node._next = _next
            set _next = node
        endmethod
        method pop takes nothing returns nothing
            local thistype node = _next
        
            debug call ThrowError(this == 0,            "SharedUniqueNxStack", "pop", "thistype", this, "Attempted To Pop Null Stack.")
            debug call ThrowError(isNode,               "SharedUniqueNxStack", "pop", "thistype", this, "Attempted To Pop Node, Expecting Stack.")
            debug call ThrowError(not isCollection,     "SharedUniqueNxStack", "pop", "thistype", this, "Attempted To Pop Invalid Stack.")
            debug call ThrowError(node == 0,            "SharedUniqueNxStack", "pop", "thistype", this, "Attempted To Pop Empty Stack.")
            
            debug set node.isNode = false
            
            set _next = _next._next
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