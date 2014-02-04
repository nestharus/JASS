library DynamicPriorityEvent /* v1.0.0.1
*************************************************************************************
*
*   Creates events that fire functions given a priority. A higher priority means that those
*   functions will fire first. Priorities may be any integer value.
*
*************************************************************************************
*
*   */uses/*
*
*       */ AVL              /*          hiveworkshop.com/forums/jass-resources-412/snippet-avl-tree-203168/
*       */ LinkedListNode   /*          hiveworkshop.com/forums/submissions-414/snippet-linked-list-node-being-redone-233937/
*
************************************************************************************
*
*   struct DynamicPriorityEvent extends array
*
*       static method create takes nothing returns DynamicPriorityEvent
*       method destroy takes nothing returns nothing
*
*       method clear takes nothing returns nothing
*           -   clears all functions from the event
*
*       method fire takes nothing returns nothing
*           -   fires all functions registered to the event
*
*       method register takes boolexpr function, integer priority returns DynamicPriorityEventCode
*           -   registers a function given a priority to the event so that it will run whenever
*           -   the event is fired
*
*           -   the returned DynamicPriorityEventCode is similar to a triggercondition
*
*   struct DynamicPriorityEventCode extends array
*
*       method destroy takes nothing returns nothing
*           -   destroys event code and unregisters it from event that it belongs to
*
************************************************************************************/
    private keyword List
    
    private module OnInit
        private static method onInit takes nothing returns nothing
            call init()
        endmethod
    endmodule

    /*
    *   Individual Code Nodes
    */
    private struct Node extends array
        implement LinkedListNode
        
        List head
        boolexpr boolexpr
    endstruct
    /*
    *   List of code nodes
    */
    private struct List extends array
        readonly integer count
        
        method add takes boolexpr c returns thistype
            /*
            *   Add node to list and get that node's instance
            */
            local Node node = Node(this).add()
            
            /*
            *   Increase list count
            */
            set count = count + 1
            
            /*
            *   Initialize node
            */
            set node.boolexpr = c
            set node.head = this
            
            return node
        endmethod
        
        static method remove takes Node node returns nothing
            /*
            *   Decrease list count
            */
            set node.head.count = node.head.count - 1
            
            /*
            *   Remove node from list that it belongs to
            */
           call Node(node.head).remove(node)
        endmethod
        
        method register takes trigger t returns nothing
            /*
            *   Iterate over all nodes in the list and register them to trigger t
            */
            
            local Node node = Node(this).first
            
            loop
                exitwhen node == 0
                call TriggerAddCondition(t, node.boolexpr)
                
                set node = node.next
            endloop
        endmethod
    endstruct
    /*
    *   Combination of Tree/Nodes
    *
    *       Tree = { treeNodes }
    *           treeNode = { listNodes }
    *
    *   Tree is ordered from least to greatest
    */
    private struct Tree extends array
        /*
        *   A tree node is a List
        */
        method operator list takes nothing returns List
            return this //tree node, not tree
        endmethod
    
        method lessThan takes thistype value returns boolean
            return integer(this) < integer(value)
        endmethod
        
        method greaterThan takes thistype value returns boolean
            return integer(this) > integer(value)
        endmethod
        
        implement AVL
    endstruct
    private struct PriorityTree extends array
        /*
        *   Readonly global return trigger to prevent leaks
        */
        readonly static trigger trigger = null
    
        /*
        *   PriorityTree is a wrapper for Tree
        */
        static method create takes nothing returns thistype
            return Tree.create()
        endmethod
        
        method destroy takes nothing returns nothing
            /*
            *   First clear all lists
            */
            loop
                set this = Tree(this).next
                exitwhen Tree(this).head
                
                call Node(this).clear()
            endloop
            
            /*
            *   Now destroy the tree
            */
            call Tree(this).destroy()
        endmethod
        
        method clear takes nothing returns nothing
            /*
            *   First clear all lists
            */
            loop
                set this = Tree(this).next
                exitwhen Tree(this).head
                
                call Node(this).clear()
            endloop
            
            /*
            *   Now clear the tree
            */
            call Tree(this).clear()
        endmethod
        
        method register takes trigger t returns nothing
            /*
            *   As the Tree is ordered from least to greatest, loop backwards
            */
            loop
                set this = Tree(this).prev
                exitwhen Tree(this).head
                
                /*
                *   Register the list to the trigger
                */
                call List(this).register(t)
            endloop
        endmethod
        
        method rebuild takes nothing returns nothing
            set trigger = CreateTrigger()
            call register(trigger)
        endmethod
        
        /*
        *   For priority and code
        *
        *       1. Add the priority to the tree if it does not already exist and
        *          retrieve the tree node containing that priority
        *
        *       2. Typecast tree node to a list and then add code to that list
        *
        *       3. Rebuild the trigger
        *
        *       4. Return listNode containing code
        */
        method add takes boolexpr c, integer priority returns thistype
            /*
            *   priority is being set to the new listNode to save on declaring
            *   a variable
            */
            set priority = List(Tree(this).add(priority)).add(c)
            return priority
        endmethod
        
        /*
        *   For a list node
        *
        *       1. A list node's head is the list that contains it
        *       2. The list that contains a list node is a tree node
        *       3. Tree nodes can be deleted without knowing the trees that they belong to
        *       4. List nodes can be deleted without knowing the lists that they belong to
        */
        static method remove takes Node listNode returns nothing
            /*
            *   Retrieve the list containing the node as a Tree node
            */
            local Tree treeNode = listNode.head
            
            /*
            *   Remove the node from the list
            */
            call List.remove(listNode)
            
            /*
            *   If there are no nodes remaining in the list, then remove
            *   the tree node
            */
            if (List(treeNode).count == 0) then
                call treeNode.delete()
            endif
        endmethod
    endstruct
    /*
    *   Handles cleanup of invalid triggers
    */
    private struct TriggerDestructor extends array
        private static timer cleanupTimer
        
        readonly static integer count = 0
        private static trigger array invalidTriggers
        
        private static method cleanup takes nothing returns nothing
            loop
                exitwhen count == 0
                set count = count - 1
                
                call TriggerClearConditions(invalidTriggers[count])
                call DestroyTrigger(invalidTriggers[count])
                set invalidTriggers[count] = null
            endloop
        endmethod
        
        static method add takes trigger t returns nothing
            if (null == t) then
                return
            endif
        
            call TimerStart(cleanupTimer, 0, false, function thistype.cleanup)
            
            set invalidTriggers[count] = t
            set count = count + 1
        endmethod
        
        private static method init takes nothing returns nothing
            set cleanupTimer = CreateTimer()
        endmethod
        
        implement OnInit
    endstruct
    /*
    *   Wrapper for PriorityTree and TriggerDestructor
    */
    private keyword updateTrigger
    struct DynamicPriorityEvent extends array
        private trigger trigger
    
        method fire takes nothing returns nothing
            if (null == trigger) then
                call PriorityTree(this).rebuild()
                set trigger = PriorityTree(this).trigger
            endif
            call TriggerEvaluate(trigger)
        endmethod
        
        static method create takes nothing returns thistype
            return PriorityTree.create()
        endmethod
        
        method destroy takes nothing returns nothing
            call PriorityTree(this).destroy()
        
            call TriggerDestructor.add(trigger)
            set trigger = null
        endmethod
        
        method destroyTrigger takes nothing returns nothing
            if (null == trigger) then
                return
            endif
            call TriggerDestructor.add(trigger)
            set trigger = null
        endmethod
        
        method clear takes nothing returns nothing
            call PriorityTree(this).clear()
        
            call destroyTrigger()
        endmethod
        
        /*
        *   1. Add the node to the tree and get that node
        *   2. Add the current trigger to the destructor
        *   3. Update the current trigger
        *   4. Return the node
        */
        method register takes boolexpr c, integer priority returns DynamicPriorityEventCode
            local Node node = PriorityTree(this).add(c, priority)
        
            call destroyTrigger()
            
            return node
        endmethod
    endstruct
    struct DynamicPriorityEventCode extends array
        method destroy takes nothing returns nothing
            /*
            *   "this" is a listNode
            *       listNode.head = treeNode
            *       treeNode.tree = tree
            */
            local DynamicPriorityEvent ev = Tree(Node(this).head).tree
            call PriorityTree.remove(this)
            call ev.destroyTrigger()
        endmethod
    endstruct
endlibrary