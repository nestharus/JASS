library Tree /* v1.0.0.0
************************************************************************************
*
*   */uses/*
*   
*       */ ErrorMessage /*         hiveworkshop.com/forums/submissions-414/snippet-error-message-239210/
*
************************************************************************************
*
*   module Tree
*
*       Description
*       -------------------------
*
*           Trees and nodes are the same
*
*       Fields
*       -------------------------
*
*           readonly static integer sentinel
*
*           readonly thistype root
*
*           readonly thistype children
*           readonly thistype lastChild
*
*           readonly thistype next
*           readonly thistype prev
*
*       Methods
*       -------------------------
*
*           static method create takes nothing returns thistype
*           method destroy takes nothing returns nothing
*
*           method clear takes nothing returns nothing
*
*           method insert takes nothing returns thistype
*
*           debug static method calculateMemoryUsage takes nothing returns integer
*           debug static method getAllocatedMemoryAsString takes nothing returns string
*
*       Examples
*       -------------------------
*
            private method breadthfirst takes nothing returns nothing
                local UniqueQueue queue = UniqueQueue.create()
                local thistype node
                
                call queue.enqueue(this)
                
                loop
                    set this = queue.first
                    exitwhen this == 0
                    call queue.pop()
                    
                    set node = children
                    loop
                        exitwhen node == 0

                        call queue.enqueue(node)

                        set node = node.next
                    endloop
                    
                    //
                    //  Code (this)
                    //
                endloop
                
                call queue.destroy()
            endmethod
            
            private method depthfirsti takes nothing returns nothing
                local UniqueStack stack = UniqueStack.create()
                local thistype node
                
                call stack.push(this)
                
                loop
                    set this = stack.first
                    exitwhen this == 0
                    call stack.pop()
                    
                    set node = lastChild
                    loop
                        exitwhen node == 0
                        
                        call stack.push(node)
                        
                        set node = node.prev
                    endloop
                    
                    //
                    //  Code (this)
                    //
                endloop
            endmethod
            
            private method depthfirst takes string s, integer maxDepth returns nothing
                local thistype node = children
                
                //
                //  Atom Code (1, 1.1, 1.1.1, 1.1.2, 1.2, etc) (this)
                //
                
                if (maxDepth > 0) then
                    loop
                        exitwhen node == 0
                        
                        //
                        //  Collection Joining Code (this {parent}, node {child})
                        //
                        call node.depthfirst(s, maxDepth - 1)
                        
                        set node = node.next
                    endloop
                endif
                
                //
                //  Atom Code (1.1.1, 1.1.2, 1.1, 1.2, 1, etc) (this)
                //
                //      used for in-order and post-order
                //
            endmethod
*
************************************************************************************/
    module Tree
        /*
        *   All nodes within a tree are collections
        */
        private static thistype collectionCount = 0
        debug private boolean isCollection
        
        private thistype _root
        method operator root takes nothing returns thistype
            debug call ThrowError(this == 0,        "Tree", "root", "thistype", this, "Attempted To Read Null Node.")
            debug call ThrowError(not isCollection, "Tree", "root", "thistype", this, "Attempted To Read Invalid Node.")
            
            return _root
        endmethod
        
        private thistype _next
        method operator next takes nothing returns thistype
            debug call ThrowError(this == 0,        "Tree", "next", "thistype", this, "Attempted To Go Out Of Bounds.")
            debug call ThrowError(not isCollection, "Tree", "next", "thistype", this, "Attempted To Read Invalid Node.")
            return _next
        endmethod
        
        private thistype _prev
        method operator prev takes nothing returns thistype
            debug call ThrowError(this == 0,        "Tree", "prev", "thistype", this, "Attempted To Go Out Of Bounds.")
            debug call ThrowError(not isCollection, "Tree", "prev", "thistype", this, "Attempted To Read Invalid Node.")
            return _prev
        endmethod
        
        private thistype _first
        method operator children takes nothing returns thistype
            debug call ThrowError(this == 0,        "Tree", "children", "thistype", this, "Attempted To Read Null Node.")
            debug call ThrowError(not isCollection, "Tree", "children", "thistype", this, "Attempted To Read Invalid Node.")
            return _first
        endmethod
        
        private thistype _last
        method operator lastChild takes nothing returns thistype
            debug call ThrowError(this == 0,        "Tree", "lastChild", "thistype", this, "Attempted To Read Null Node.")
            debug call ThrowError(not isCollection, "Tree", "lastChild", "thistype", this, "Attempted To Read Invalid Node.")
            return _last
        endmethod
        
        static method operator sentinel takes nothing returns integer
            return 0
        endmethod
        
        private static method _allocateCollection takes nothing returns thistype
            local thistype this = thistype(0)._first
            
            if (0 == this) then
                debug call ThrowError(collectionCount == 8191, "Tree", "allocateCollection", "thistype", 0, "Overflow.")
                
                set this = collectionCount + 1
                set collectionCount = this
            else
                set thistype(0)._first = _first
            endif
            
            return this
        endmethod
        
        private method _enqueue takes nothing returns thistype
            local thistype node = _allocateCollection()
            
            set node._root = this
        
            if (_first == 0) then
                set _first = node
                set _last = node
                set node._prev = 0
            else
                set _last._next = node
                set node._prev = _last
                set _last = node
            endif
            
            set node._next = 0
            
            return node
        endmethod
        private method _remove takes nothing returns nothing
            local thistype node = this
            set this = node._root
            
            set node._root = 0
        
            if (0 == node._prev) then
                set _first = node._next
            else
                set node._prev._next = node._next
            endif
            if (0 == node._next) then
                set _last = node._prev
            else
                set node._next._prev = node._prev
            endif
            
            set node._next = thistype(0)._next
            set thistype(0)._next = node
        endmethod
        private method _clear takes nothing returns nothing
            if (_first == 0) then
                return
            endif
            
            set _last._next = thistype(0)._next
            set thistype(0)._next = _first
            
            set _first = 0
            set _last = 0
        endmethod
        
        static method create takes nothing returns thistype
            local thistype this = _allocateCollection()
                
            debug set isCollection = true
            
            return this
        endmethod
        
        method destroy takes nothing returns nothing
            local thistype node = _first
            local thistype next
            
            debug call ThrowError(this == 0,            "Tree", "destroy", "thistype", this, "Attempted To Destroy Null Tree.")
            debug call ThrowError(not isCollection,     "Tree", "destroy", "thistype", this, "Attempted To Destroy Invalid Tree.")
            
            loop
                exitwhen node == 0
                
                set next = node.next
                
                call node._remove()
                call node.destroy()
                
                set node = next
            endloop
            
            call _clear()
            
            if (_root != 0) then
                call ._remove()
            
                set _root = 0
            endif
            
            set _first = thistype(0)._first
            set thistype(0)._first = this
            
            debug set isCollection = false
        endmethod
        
        method clear takes nothing returns nothing
            local thistype node = _first
            local thistype next
        
            debug call ThrowError(this == 0,            "Tree", "clear", "thistype", this, "Attempted To Clear Null Tree.")
            debug call ThrowError(not isCollection,     "Tree", "clear", "thistype", this, "Attempted To Clear Invalid Tree.")
            
            loop
                exitwhen node == 0
                
                set next = node.next
                
                call node.destroy()
                
                set node = next
            endloop
            
            set _first = 0
            set _last = 0
        endmethod
        
        method insert takes nothing returns thistype
            local thistype node
            
            debug call ThrowError(this == 0,            "Tree", "insert", "thistype", this, "Attempted To Insert To Null Tree.")
            debug call ThrowError(not isCollection,     "Tree", "insert", "thistype", this, "Attempted To Insert To Invalid Tree.")
            
            set node = _enqueue()
            
            debug set node.isCollection = true
            
            return node
        endmethod
        
        static if DEBUG_MODE then
            static method calculateMemoryUsage takes nothing returns integer
                local thistype start = 1
                local thistype end = collectionCount
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
                    if (start.isCollection) then
                        set count = count + 1
                    endif
                    set start = start + 1
                endloop
                
                return count
            endmethod
            
            static method getAllocatedMemoryAsString takes nothing returns string
                local thistype start = 1
                local thistype end = collectionCount
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