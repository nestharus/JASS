library UniqueListT /* v1.0.0.1
************************************************************************************
*
*   */uses/*
*   
*       */ ErrorMessage /*
*		*/ TableField	/*
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
*           method push takes thistype node returns nothing
*           method enqueue takes thistype node returns thistype
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
	
    private keyword p_list
    private keyword p_next
    private keyword p_prev
    private keyword p_first
    private keyword p_last

    module UniqueListT
        private static thistype collectionCount = 0
        private static thistype nodeCount = 0
		
		static if DEBUG_MODE then
            //! runtextmacro CREATE_TABLE_FIELD("public", "boolean", "isNode", "boolean")
            //! runtextmacro CREATE_TABLE_FIELD("public", "boolean", "isCollection", "boolean")
        endif
        
		//! runtextmacro CREATE_TABLE_FIELD("public", "integer", "p_list", "thistype")
        method operator list takes nothing returns thistype
            debug call ThrowError(this == 0,    "List", "list", "thistype", this, "Attempted To Read Null Node.")
            debug call ThrowError(not isNode,   "List", "list", "thistype", this, "Attempted To Read Invalid Node.")
            return p_list
        endmethod
        
        //! runtextmacro CREATE_TABLE_FIELD("public", "integer", "p_next", "thistype")
        method operator next takes nothing returns thistype
            debug call ThrowError(this == 0,    "List", "next", "thistype", this, "Attempted To Go Out Of Bounds.")
            debug call ThrowError(not isNode,   "List", "next", "thistype", this, "Attempted To Read Invalid Node.")
            return p_next
        endmethod
        
        //! runtextmacro CREATE_TABLE_FIELD("public", "integer", "p_prev", "thistype")
        method operator prev takes nothing returns thistype
            debug call ThrowError(this == 0,    "List", "prev", "thistype", this, "Attempted To Go Out Of Bounds.")
            debug call ThrowError(not isNode,   "List", "prev", "thistype", this, "Attempted To Read Invalid Node.")
            return p_prev
        endmethod
        
        //! runtextmacro CREATE_TABLE_FIELD("public", "integer", "p_first", "thistype")
        method operator first takes nothing returns thistype
            debug call ThrowError(this == 0,        "List", "first", "thistype", this, "Attempted To Read Null List.")
            debug call ThrowError(not isCollection, "List", "first", "thistype", this, "Attempted To Read Invalid List.")
            return p_first
        endmethod
        
        //! runtextmacro CREATE_TABLE_FIELD("public", "integer", "p_last", "thistype")
        method operator last takes nothing returns thistype
            debug call ThrowError(this == 0,        "List", "last", "thistype", this, "Attempted To Read Null List.")
            debug call ThrowError(not isCollection, "List", "last", "thistype", this, "Attempted To Read Invalid List.")
            return p_last
        endmethod
        
        static method operator sentinel takes nothing returns integer
            return 0
        endmethod
        
        private static method allocateCollection takes nothing returns thistype
            local thistype this = thistype(0).p_first
            
            if (0 == this) then
                debug call ThrowError(collectionCount == 8191, "List", "allocateCollection", "thistype", 0, "Overflow.")
                
                set this = collectionCount + 1
                set collectionCount = this
            else
                set thistype(0).p_first = p_first
            endif
            
            return this
        endmethod
        
        static method create takes nothing returns thistype
            local thistype this = allocateCollection()
            
            debug set isCollection = true
            
            set p_first = 0
            
            return this
        endmethod
        method push takes thistype node returns nothing
            debug call ThrowError(this == 0,        "List", "push", "thistype", this, "Attempted To Push On To Null List.")
            debug call ThrowError(not isCollection, "List", "push", "thistype", this, "Attempted To Push On To Invalid List.")
            
            debug set node.isNode = true
            
            set node.p_list = this
        
            if (p_first == 0) then
                set p_first = node
                set p_last = node
                set node.p_next = 0
            else
                set p_first.p_prev = node
                set node.p_next = p_first
                set p_first = node
            endif
            
            set node.p_prev = 0
        endmethod
        method enqueue takes thistype node returns nothing
            debug call ThrowError(this == 0,        "List", "enqueue", "thistype", this, "Attempted To Enqueue On To Null List.")
            debug call ThrowError(not isCollection, "List", "enqueue", "thistype", this, "Attempted To Enqueue On To Invalid List.")
            
            debug set node.isNode = true
            
            set node.p_list = this
        
            if (p_first == 0) then
                set p_first = node
                set p_last = node
                set node.p_prev = 0
            else
                set p_last.p_next = node
                set node.p_prev = p_last
                set p_last = node
            endif
            
            set node.p_next = 0
        endmethod
        method pop takes nothing returns nothing
            local thistype node = p_first
            
            debug call ThrowError(this == 0,        "List", "pop", "thistype", this, "Attempted To Pop Null List.")
            debug call ThrowError(not isCollection, "List", "pop", "thistype", this, "Attempted To Pop Invalid List.")
            debug call ThrowError(node == 0,        "List", "pop", "thistype", this, "Attempted To Pop Empty List.")
            
            debug set node.isNode = false
            
            set p_first.p_list = 0
            
            set p_first = p_first.p_next
            if (p_first == 0) then
                set p_last = 0
            else
                set p_first.p_prev = 0
            endif
        endmethod
        method dequeue takes nothing returns nothing
            local thistype node = p_last
            
            debug call ThrowError(this == 0,        "List", "dequeue", "thistype", this, "Attempted To Dequeue Null List.")
            debug call ThrowError(not isCollection, "List", "dequeue", "thistype", this, "Attempted To Dequeue Invalid List.")
            debug call ThrowError(node == 0,        "List", "dequeue", "thistype", this, "Attempted To Dequeue Empty List.")
            
            debug set node.isNode = false
            
            set p_last.p_list = 0
        
            set p_last = p_last.p_prev
            if (p_last == 0) then
                set p_first = 0
            else
                set p_last.p_next = 0
            endif
        endmethod
        method remove takes nothing returns nothing
            local thistype node = this
            set this = node.p_list
            
            debug call ThrowError(node == 0,        "List", "remove", "thistype", this, "Attempted To Remove Null Node.")
            debug call ThrowError(not node.isNode,  "List", "remove", "thistype", this, "Attempted To Remove Invalid Node (" + I2S(node) + ").")
            
            debug set node.isNode = false
            
            set node.p_list = 0
        
            if (0 == node.p_prev) then
                set p_first = node.p_next
            else
                set node.p_prev.p_next = node.p_next
            endif
            if (0 == node.p_next) then
                set p_last = node.p_prev
            else
                set node.p_next.p_prev = node.p_prev
            endif
        endmethod
        method clear takes nothing returns nothing
            debug local thistype node = p_first
        
            debug call ThrowError(this == 0,            "List", "clear", "thistype", this, "Attempted To Clear Null List.")
            debug call ThrowError(not isCollection,     "List", "clear", "thistype", this, "Attempted To Clear Invalid List.")
            
            static if DEBUG_MODE then
                loop
                    exitwhen node == 0
                    set node.isNode = false
                    set node = node.p_next
                endloop
            endif
            
            set p_first = 0
            set p_last = 0
        endmethod
        method destroy takes nothing returns nothing
            debug call ThrowError(this == 0,            "List", "destroy", "thistype", this, "Attempted To Destroy Null List.")
            debug call ThrowError(not isCollection,     "List", "destroy", "thistype", this, "Attempted To Destroy Invalid List.")
            
            static if DEBUG_MODE then
                debug call clear()
                
                debug set isCollection = false
            else
				set p_last = 0
            endif
            
            set p_first = thistype(0).p_first
            set thistype(0).p_first = this
        endmethod
        
        private static method onInit takes nothing returns nothing
			static if DEBUG_MODE then
				//! runtextmacro INITIALIZE_TABLE_FIELD("isNode")
				//! runtextmacro INITIALIZE_TABLE_FIELD("isCollection")
			endif
            //! runtextmacro INITIALIZE_TABLE_FIELD("p_list")
            //! runtextmacro INITIALIZE_TABLE_FIELD("p_next")
            //! runtextmacro INITIALIZE_TABLE_FIELD("p_prev")
            //! runtextmacro INITIALIZE_TABLE_FIELD("p_first")
            //! runtextmacro INITIALIZE_TABLE_FIELD("p_last")
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