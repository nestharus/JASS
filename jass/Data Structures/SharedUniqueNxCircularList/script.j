library SharedUniqueNxCircularList /* v1.0.0.0
************************************************************************************
*
*   */uses/*
*   
*       */ ErrorMessage /*         hiveworkshop.com/forums/submissions-414/snippet-error-message-239210/
*
************************************************************************************
*
*   module SharedUniqueNxCircularList
*
*       Description
*       -------------------------
*
*           All lists/nodes across all lists must be unique
*           List/Node allocation/deallocation is not handled
*
*       Fields
*       -------------------------
*
*           readonly thistype first
*           readonly thistype last
*           readonly thistype next
*           readonly boolean sentinel
*
*       Methods
*       -------------------------
*
*           method destroy takes nothing returns nothing
*
*           method push takes thistype node returns nothing
*           method enqueue takes thistype node returns nothing
*
*           method pop takes nothing returns nothing
*           method dequeue takes nothing returns nothing
*
*           method remove takes nothing returns nothing
*
*           method clear takes nothing returns nothing
*               -   Initializes to a list, use instead of create
*               
*
************************************************************************************/
    module SharedUniqueNxCircularList
        private boolean collection
        debug private boolean added
    
        private thistype next_p
        method operator next takes nothing returns thistype
            debug call ThrowError(this == 0,    "SharedUniqueNxCircularList", "next", "thistype", this, "Attempted To Go Out Of Bounds.")
            debug call ThrowError(collection,   "SharedUniqueNxCircularList", "next", "thistype", this, "Attempted To Read Collection, expecting Node.")
            debug call ThrowError(not added,    "SharedUniqueNxCircularList", "next", "thistype", this, "Attempted To Manipulate Deallocated Node.")
            return next_p
        endmethod
        
        private thistype prev_p
        method operator prev takes nothing returns thistype
            debug call ThrowError(this == 0,    "SharedUniqueNxCircularList", "prev", "thistype", this, "Attempted To Go Out Of Bounds.")
            debug call ThrowError(collection,   "SharedUniqueNxCircularList", "prev", "thistype", this, "Attempted To Read Collection, expecting Node.")
            debug call ThrowError(not added,    "SharedUniqueNxCircularList", "prev", "thistype", this, "Attempted To Manipulate Deallocated Node.")
            return prev_p
        endmethod
        
        method operator first takes nothing returns thistype
            debug call ThrowError(this == 0,                    "SharedUniqueNxCircularList", "first", "thistype", this, "Attempted To Read Null thistype.")
            debug call ThrowError(added,                        "SharedUniqueNxCircularList", "first", "thistype", this, "Attempted To Read Node, Expecting Collection.")
            debug call ThrowError(not collection,               "SharedUniqueNxCircularList", "first", "thistype", this, "Attempted To Manipulate Deallocated Collection.")
            return next_p
        endmethod
        
        method operator last takes nothing returns thistype
            debug call ThrowError(this == 0,                "SharedUniqueNxCircularList", "last", "thistype", this, "Attempted To Read Null thistype.")
            debug call ThrowError(added,                    "SharedUniqueNxCircularList", "last", "thistype", this, "Attempted To Read Node, Expecting Collection.")
            debug call ThrowError(not collection,           "SharedUniqueNxCircularList", "last", "thistype", this, "Attempted To Manipulate Deallocated Collection.")
            return prev_p
        endmethod
        
        method operator sentinel takes nothing returns boolean
            return collection
        endmethod
        
        method enqueue takes thistype node returns nothing
            debug call ThrowError(this == 0,            "SharedUniqueNxCircularList", "enqueue", "thistype", this, "Attempted To Manipulate Null thistype.")
            debug call ThrowError(added,                "SharedUniqueNxCircularList", "enqueue", "thistype", this, "Attempted To Enqueue On To Node, Expecting Collection")
            debug call ThrowError(node == 0,            "SharedUniqueNxCircularList", "enqueue", "thistype", this, "Attempted To Enqueue Null Node.")
            debug call ThrowError(node.added,           "SharedUniqueNxCircularList", "enqueue", "thistype", this, "Attempted To Enqueue Node Belonging To Another thistype.")
        
            debug set node.added = true
        
            set node.next_p = this
            set node.prev_p = prev_p
            set prev_p.next_p = node
            set prev_p = node
        endmethod
        method push takes thistype node returns nothing
            debug call ThrowError(this == 0,            "SharedUniqueNxCircularList", "push", "thistype", this, "Attempted To Manipulate Null thistype.")
            debug call ThrowError(added,                "SharedUniqueNxCircularList", "push", "thistype", this, "Attempted To Push On To Node, Expecting Collection")
            debug call ThrowError(node == 0,            "SharedUniqueNxCircularList", "push", "thistype", this, "Attempted To Push Null Node.")
            debug call ThrowError(node.added,           "SharedUniqueNxCircularList", "push", "thistype", this, "Attempted To Push Node Belonging To Another thistype.")
        
            debug set node.added = true
        
            set node.next_p = next_p
            set node.prev_p = this
            set next_p.prev_p = node
            set next_p = node
        endmethod
        method remove takes nothing returns nothing
            debug call ThrowError(this == 0,                "SharedUniqueNxCircularList", "remove", "thistype", this, "Attempted To Manipulate Null thistype.")
            debug call ThrowError(collection,               "SharedUniqueNxCircularList", "remove", "thistype", this, "Attempted To Remove Collection, Expecting Node.")
            debug call ThrowError(not added,                "SharedUniqueNxCircularList", "remove", "thistype", this, "Attempted To Remove Node Not Belonging To A thistype.")
        
            debug set added = false
        
            set prev_p.next_p = next_p
            set next_p.prev_p = prev_p
        endmethod
        method pop takes nothing returns nothing
            debug call ThrowError(this == 0,                "SharedUniqueNxCircularList", "pop", "thistype", this, "Attempted To Manipulate Null thistype.")
            debug call ThrowError(added,                    "SharedUniqueNxCircularList", "pop", "thistype", this, "Attempted To Pop Node, Expecting Collection.")
            debug call ThrowError(not collection,           "SharedUniqueNxCircularList", "pop", "thistype", this, "Attempted To Manipulate Deallocated Collection.")
            debug call ThrowWarning(this == next_p,         "SharedUniqueNxCircularList", "pop", "thistype", this, "Popping Empty thistype.")
        
            set this = next_p
        
            set prev_p.next_p = next_p
            set next_p.prev_p = prev_p
        endmethod
        method dequeue takes nothing returns nothing
            debug call ThrowError(this == 0,                "SharedUniqueNxCircularList", "dequeue", "thistype", this, "Attempted To Manipulate Null thistype.")
            debug call ThrowError(added,                    "SharedUniqueNxCircularList", "dequeue", "thistype", this, "Attempted To Dequeue Node, Expecting Collection.")
            debug call ThrowError(not collection,           "SharedUniqueNxCircularList", "dequeue", "thistype", this, "Attempted To Manipulate Deallocated Collection.")
            debug call ThrowWarning(this == next_p,         "SharedUniqueNxCircularList", "dequeue", "thistype", this, "Dequeuing Empty thistype.")
        
            set this = next_p
        
            set prev_p.next_p = next_p
            set next_p.prev_p = prev_p
        endmethod
        method clear takes nothing returns nothing
            debug call ThrowError(this == 0,                "SharedUniqueNxCircularList", "clear", "thistype", this, "Attempted To Manipulate Null thistype.")
            debug call ThrowError(added,                    "SharedUniqueNxCircularList", "clear", "thistype", this, "Attempted To Clear Node, Expecting Collection.")
            
            debug if (not collection) then
                debug set collection = true
                
                debug set next_p = this
                debug set prev_p = this
                
                debug return
            debug endif
            
            debug loop
                debug set this = next_p
                debug exitwhen collection
                debug set added = false
            debug endloop
        
            set collection = true
            set next_p = this
            set prev_p = this
        endmethod
        
        method destroy takes nothing returns nothing
            debug call ThrowError(this == 0,                "SharedUniqueNxCircularList", "destroy", "thistype", this, "Attempted To Manipulate Null thistype.")
            debug call ThrowError(added,                    "SharedUniqueNxCircularList", "destroy", "thistype", this, "Attempted To Destroy Node, Expecting Collection.")
            debug call ThrowError(not collection,           "SharedUniqueNxCircularList", "destroy", "thistype", this, "Attempted To Manipulate Deallocated thistype.")
            
            set collection = false
        endmethod
    endmodule
endlibrary