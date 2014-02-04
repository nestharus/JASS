library ListT /* v1.0.0.0
************************************************************************************
*
*   */uses/*
*   
*       */ ErrorMessage /*         hiveworkshop.com/forums/submissions-414/snippet-error-message-239210/
*       */ Table        /*         hiveworkshop.com/forums/jass-resources-412/snippet-new-table-188084/
*
************************************************************************************
*
*   module ListT
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
    private keyword isNode
    private keyword isCollection
    
    private keyword list_p
    private keyword next_p
    private keyword prev_p
    private keyword first_p
    private keyword last_p
    
    module ListT
        private static thistype collectionCount = 0
        private static thistype nodeCount = 0
        
        debug private static Table _isNode
        debug method operator isNode takes nothing returns boolean
            return _isNode.boolean[this]
        endmethod
        debug method operator isNode= takes boolean value returns nothing
            set _isNode.boolean[this] = value
        endmethod
        
        debug private static Table _isCollection
        debug method operator isCollection takes nothing returns boolean
            return _isCollection.boolean[this]
        endmethod
        debug method operator isCollection= takes boolean value returns nothing
            set _isCollection.boolean[this] = value
        endmethod
        
        private static Table _list
        method operator list takes nothing returns thistype
            debug call ThrowError(this == 0,    "ListT", "list", "thistype", this, "Attempted To Read Null Node.")
            debug call ThrowError(not isNode,   "ListT", "list", "thistype", this, "Attempted To Read Invalid Node.")
            return _list[this]
        endmethod
        method operator list_p takes nothing returns thistype
            return _list[this]
        endmethod
        method operator list_p= takes thistype value returns nothing
            set _list[this] = value
        endmethod
        
        private static Table _next
        method operator next takes nothing returns thistype
            debug call ThrowError(this == 0,    "ListT", "next", "thistype", this, "Attempted To Go Out Of Bounds.")
            debug call ThrowError(not isNode,   "ListT", "next", "thistype", this, "Attempted To Read Invalid Node.")
            return _next[this]
        endmethod
        method operator next_p takes nothing returns thistype
            return _next[this]
        endmethod
        method operator next_p= takes thistype value returns nothing
            set _next[this] = value
        endmethod
        
        private static Table _prev
        method operator prev takes nothing returns thistype
            debug call ThrowError(this == 0,    "ListT", "prev", "thistype", this, "Attempted To Go Out Of Bounds.")
            debug call ThrowError(not isNode,   "ListT", "prev", "thistype", this, "Attempted To Read Invalid Node.")
            return _prev[this]
        endmethod
        method operator prev_p takes nothing returns thistype
            return _prev[this]
        endmethod
        method operator prev_p= takes thistype value returns nothing
            set _prev[this] = value
        endmethod
        
        private static Table _first
        method operator first takes nothing returns thistype
            debug call ThrowError(this == 0,        "ListT", "first", "thistype", this, "Attempted To Read Null List.")
            debug call ThrowError(not isCollection, "ListT", "first", "thistype", this, "Attempted To Read Invalid List.")
            return _first[first]
        endmethod
        method operator first_p takes nothing returns thistype
            return _first[this]
        endmethod
        method operator first_p= takes thistype value returns nothing
            set _first[this] = value
        endmethod
        
        private static Table _last
        method operator last takes nothing returns thistype
            debug call ThrowError(this == 0,        "ListT", "last", "thistype", this, "Attempted To Read Null List.")
            debug call ThrowError(not isCollection, "ListT", "last", "thistype", this, "Attempted To Read Invalid List.")
            return _last[this]
        endmethod
        method operator last_p takes nothing returns thistype
            return _last[this]
        endmethod
        method operator last_p= takes thistype value returns nothing
            set _last[this] = value
        endmethod
        
        private static method onInit takes nothing returns nothing
            debug set _isNode = Table.create()
            debug set _isCollection = Table.create()
            set _list = Table.create()
            set _next = Table.create()
            set _prev = Table.create()
            set _first = Table.create()
            set _last = Table.create()
        endmethod
        
        static method operator sentinel takes nothing returns integer
            return 0
        endmethod
        
        private static method allocateCollection takes nothing returns thistype
            local thistype this = thistype(0).first_p
            
            if (0 == this) then
                set this = collectionCount + 1
                set collectionCount = this
            else
                set thistype(0).first_p = first_p
            endif
            
            return this
        endmethod
        
        private static method allocateNode takes nothing returns thistype
            local thistype this = thistype(0).next_p
            
            if (0 == this) then
                set this = nodeCount + 1
                set nodeCount = this
            else
                set thistype(0).next_p = next_p
            endif
            
            return this
        endmethod
        
        static method create takes nothing returns thistype
            local thistype this = allocateCollection()
            
            debug set isCollection = true
            
            set first_p = 0
            
            return this
        endmethod
        method push takes nothing returns thistype
            local thistype node = allocateNode()
            
            debug call ThrowError(this == 0,        "ListT", "push", "thistype", this, "Attempted To Push On To Null List.")
            debug call ThrowError(not isCollection, "ListT", "push", "thistype", this, "Attempted To Push On To Invalid List.")
            
            debug set node.isNode = true
            
            set node._list = this
        
            if (first_p == 0) then
                set first_p = node
                set last_p = node
                set node.next_p = 0
            else
                set first_p.prev_p = node
                set node.next_p = first_p
                set first_p = node
            endif
            
            set node.prev_p = 0
            
            return node
        endmethod
        method enqueue takes nothing returns thistype
            local thistype node = allocateNode()
            
            debug call ThrowError(this == 0,        "List", "enqueue", "thistype", this, "Attempted To Enqueue On To Null List.")
            debug call ThrowError(not isCollection, "List", "enqueue", "thistype", this, "Attempted To Enqueue On To Invalid List.")
            
            debug set node.isNode = true
            
            set node._list = this
        
            if (first_p == 0) then
                set first_p = node
                set last_p = node
                set node.prev_p = 0
            else
                set last_p.next_p = node
                set node.prev_p = last_p
                set last_p = node
            endif
            
            set node.next_p = 0
            
            return node
        endmethod
        method pop takes nothing returns nothing
            local thistype node = first_p
            
            debug call ThrowError(this == 0,        "List", "pop", "thistype", this, "Attempted To Pop Null List.")
            debug call ThrowError(not isCollection, "List", "pop", "thistype", this, "Attempted To Pop Invalid List.")
            debug call ThrowError(node == 0,        "List", "pop", "thistype", this, "Attempted To Pop Empty List.")
            
            debug set node.isNode = false
            
            set first_p._list = 0
            
            set first_p = first_p.next_p
            if (first_p == 0) then
                set last_p = 0
            else
                set first_p.prev_p = 0
            endif
            
            set node.next_p = thistype(0).next_p
            set thistype(0).next_p = node
        endmethod
        method dequeue takes nothing returns nothing
            local thistype node = last_p
            
            debug call ThrowError(this == 0,        "List", "dequeue", "thistype", this, "Attempted To Dequeue Null List.")
            debug call ThrowError(not isCollection, "List", "dequeue", "thistype", this, "Attempted To Dequeue Invalid List.")
            debug call ThrowError(node == 0,        "List", "dequeue", "thistype", this, "Attempted To Dequeue Empty List.")
            
            debug set node.isNode = false
            
            set last_p._list = 0
        
            set last_p = last_p.prev_p
            if (last_p == 0) then
                set first_p = 0
            else
                set last_p.next_p = 0
            endif
            
            set node.next_p = thistype(0).next_p
            set thistype(0).next_p = node
        endmethod
        method remove takes nothing returns nothing
            local thistype node = this
            set this = node._list
            
            debug call ThrowError(node == 0,        "List", "remove", "thistype", this, "Attempted To Remove Null Node.")
            debug call ThrowError(not node.isNode,  "List", "remove", "thistype", this, "Attempted To Remove Invalid Node (" + I2S(node) + ").")
            
            debug set node.isNode = false
            
            set node._list = 0
        
            if (0 == node.prev_p) then
                set first_p = node.next_p
            else
                set node.prev_p.next_p = node.next_p
            endif
            if (0 == node.next_p) then
                set last_p = node.prev_p
            else
                set node.next_p.prev_p = node.prev_p
            endif
            
            set node.next_p = thistype(0).next_p
            set thistype(0).next_p = node
        endmethod
        method clear takes nothing returns nothing
            debug local thistype node = first_p
        
            debug call ThrowError(this == 0,            "List", "clear", "thistype", this, "Attempted To Clear Null List.")
            debug call ThrowError(not isCollection,     "List", "clear", "thistype", this, "Attempted To Clear Invalid List.")
            
            static if DEBUG_MODE then
                loop
                    exitwhen node == 0
                    set node.isNode = false
                    set node = node.next_p
                endloop
            endif
            
            if (first_p == 0) then
                return
            endif
            
            set last_p.next_p = thistype(0).next_p
            set thistype(0).next_p = first_p
            
            set first_p = 0
            set last_p = 0
        endmethod
        method destroy takes nothing returns nothing
            debug call ThrowError(this == 0,            "List", "destroy", "thistype", this, "Attempted To Destroy Null List.")
            debug call ThrowError(not isCollection,     "List", "destroy", "thistype", this, "Attempted To Destroy Invalid List.")
            
            static if DEBUG_MODE then
                debug call clear()
                
                debug set isCollection = false
            else
                if (first_p != 0) then
                    set last_p.next_p = thistype(0).next_p
                    set thistype(0).next_p = first_p
                    
                    set last_p = 0
                endif
            endif
            
            set first_p = thistype(0).first_p
            set thistype(0).first_p = this
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