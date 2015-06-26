library BinaryHeap /* v4.0.0.0
*************************************************************************************
*
*   Binary Heap
*
************************************************************************************
*
*   Interface:
*       private static method compare takes thistype value1, thistype value2 returns boolean
*           -   < for minimum heap
*           -   > for maximum heap
*
*   static readonly thistype root
*       -   The node with the smallest/biggest value
*   readonly thistype node
*       -   Node stored within heap position (array[heapPosition] = node)
*   readonly thistype heap
*       -   Heap position of node (array[heapPosition] = node)
*   static readonly integer size
*       -   Size of binary heap
*   readonly integer value
*       -   Sorted value (the value of the node)
*
*   method modify takes integer sortValue returns nothing
*       -   Modifies the value of the node
*
*   static method insert takes integer sortValue returns thistype
*       -   Inserts a new node into the heap and returns it
*       -   Assigns that node the passed in value
*   method delete takes nothing returns nothing
*       -   Deletes node from heap
*
*   static method clear takes nothing returns nothing
*       -   Clears the heap
*
************************************************************************************/
    module BinaryHeap
        readonly static integer size = 0
        readonly thistype node                      //node
        private static thistype instanceCount = 0   //node instance count
        private static thistype array recycler      //node recycler
        readonly thistype value
        readonly thistype heap
        
        static method operator root takes nothing returns thistype
            return thistype(1).node
        endmethod
        
        static method allocate takes thistype value returns thistype
            local thistype this = recycler[0]
            
            if (0 == this) then
                set this = instanceCount + 1
                set instanceCount = this
            else
                set recycler[0] = recycler[this]
            endif
            
            set this.value = value
            set node.heap = 0
            
            return this
        endmethod
        method deallocate takes nothing returns nothing
            set recycler[this]=recycler[0]
            set recycler[0]=this
        endmethod
        
        private method link takes thistype heapPosition returns nothing
            set heapPosition.node = this
            set heap = heapPosition
        endmethod
        
        private method bubbleUp takes nothing returns nothing
            local thistype value = this.value
            local thistype heapPosition = heap
            
            local thistype parent
            
            /*
            *   Bubble node up
            */
            loop
                set parent = heapPosition/2
                
                exitwhen (0 == parent or compare(parent.node.value, value))
                
                set heapPosition.node = parent.node
                set heapPosition.node.heap = heapPosition
                
                set heapPosition = parent
            endloop
            
            /*
            *   Update pointers
            */
            call link(heapPosition)
        endmethod
        private method bubbleDown takes nothing returns nothing
            local thistype value = this.value
            local thistype heapPosition = heap
            
            local thistype left
            local thistype right
            
            /*
            *   Bubble node down
            */
            loop
                set left = heapPosition*2
                set right = left + 1
                
                exitwhen (0 == left.node or compare(value, left.node.value)) and (0 == right.node or compare(value, right.node.value))
                
                if (0 == right.node.value or (0 != left.node and compare(left.node.value, right.node.value))) then
                    /*
                    *   Go left
                    */
                    set heapPosition.node = left.node
                    set heapPosition.node.heap = heapPosition
                    set heapPosition = left
                else
                    /*
                    *   Go right
                    */
                    set heapPosition.node = right.node
                    set heapPosition.node.heap = heapPosition
                    set heapPosition = right
                endif
            endloop
            
            /*
            *   Update pointers
            */
            call link(heapPosition)
        endmethod
        
        method modify takes integer value returns nothing
            set this.value = value
            
            /*
            *   Bubble node into correct position
            */
            call bubbleUp()
            call bubbleDown()
        endmethod
        
        static method insert takes thistype value returns thistype
            local thistype heapPosition
            local thistype this
            
            /*
            *   Allocate new node
            */
            set this = allocate(value)
            
            /*
            *   Increase heap size
            */
            set heapPosition = size + 1
            set size = heapPosition
            
            /*
            *   Store node in last heap position
            */
            call link(heapPosition)
            
            /*
            *   Bubble node into correct position
            */
            call bubbleUp()
            
            return this
        endmethod
        method delete takes nothing returns nothing
            local thistype lastNode
            
            debug if (0 == size) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Attempted To Delete Node From Empty Heap")
                debug set this = 1/0
            debug endif

            /*
            *   Deallocate node
            */
            call deallocate()
            
            /*
            *   Remove last node from last position
            */
            set lastNode = thistype(size).node
            set thistype(size).node = 0
            set size = size - 1
            
            if (lastNode != node) then
                /*
                *   Put last node in deallocated node's position
                */
                call lastNode.link(heap)
                
                /*
                *   Bubble into correct spot
                */
                call lastNode.bubbleUp()
                call lastNode.bubbleDown()
            endif
        endmethod
        static method clear takes nothing returns nothing
            set size = 0
            set recycler[0] = 0
            set instanceCount = 0
            set thistype(1).node = 0
        endmethod
    endmodule
endlibrary