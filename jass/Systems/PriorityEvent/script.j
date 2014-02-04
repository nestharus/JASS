library PriorityEvent /* v2.0.1.2
*************************************************************************************
*
*   Creates events that fire given a priority. A higher priority means that those
*   events will fire first. A priority of 0 means that those events will fire last.
*
*   Priority events can only be created at map init
*   Code can only be registered to priority events at map init
*
*************************************************************************************
*
*   */uses/*
*
*       */ AVL              /*          hiveworkshop.com/forums/jass-resources-412/snippet-avl-tree-203168/
*
************************************************************************************
*
*   struct PriorityEvent extends array
*
*       Fields
*       -------------------------
*
*           readonly PriorityEventPriorityList priorityList
*
*           static method create takes nothing returns thistype
*           method register takes boolexpr func, integer priority returns nothing
*           method fire takes nothing returns nothing
*
************************************************************************************
*
*   struct PriorityEventPriorityList extends array
*
*       Description
*       -------------------------
*
*           Used to iterate over the list of priorities in a PriorityEvent
*
*       Fields
*       -------------------------
*
*           readonly boolexpr code
*           readonly boolean head
*           readonly thistype next
*           readonly integer priority
*
*       Example
*       -------------------------
*
*           local PriorityEventPriorityList priorityNode = priorityEvent.priorityList
*
*           loop
*               set priorityNode = priorityNode.prev
*               exitwhen priorityNode.head
*
*               call TriggerAddCondition(myTrigger, priorityNode.code)
*           endloop
*
************************************************************************************/
    private struct PriorityEventTree extends array
        method lessThan takes thistype value returns boolean
            return integer(this) < integer(value)
        endmethod
        
        method greaterThan takes thistype value returns boolean
            return integer(this) > integer(value)
        endmethod
        
        implement AVL
    endstruct
    
    private keyword treeNodeIsHead
    private keyword treeNodeGetNext
    private keyword treeNodeGetBoolExpr
    
    private module PriorityEventMod
        private static integer instanceCount = 0
        
        /*
        *   A queue of code registered with the same priority
        */
        private thistype next_p
        private thistype last_p
        private thistype first_p
        
        /*
        *   The priorities are stored in the tree list
        */
        
        /*
        *   Iterate from 0 to count to go over all created events
        */
        private static PriorityEventTree count = 0
        private static PriorityEventTree array tree
        
        /*
        *   This is a temporary trigger to store all code of the same priority
        *   Once the game has started, all code will be merged on to one trigger
        */
        private trigger event
        private boolexpr codeList
        
        /*
        *   Need to store the code in order to merge all it all on to one trigger
        */
        private boolexpr code
        
        /*
        *   All code is merged on this
        */
        private trigger allEvent
        
        /*
        *   Has the code all been merged?
        */
        private static boolean merged = false
        
        method operator priorityList takes nothing returns PriorityEventPriorityList
            return this
        endmethod
        
        static method create takes nothing returns thistype
            local thistype this
            
            debug if (merged) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Priority Event Error: Can Only Create Events On Game Init")
                debug set this = 1/0
            debug endif
            
            /*
            *   Allocate new event
            */
            set this = PriorityEventTree.create()
            
            /*
            *   Add to array for merging later
            */
            set tree[count] = this
            set count = count + 1
            
            /*
            *   Create the merging trigger
            */
            set thistype(count).allEvent = CreateTrigger()
            
            return count
        endmethod
    
        method register takes boolexpr func, integer priority returns nothing
            local thistype node
            
            debug if (merged) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,10,"Priority Event Error: Can Only Register Code On Game Init")
                debug set node = 1/0
            debug endif
            
            /*
            *   Allocate a new node to store the function
            */
            set node = instanceCount + 1
            set instanceCount = node
            
            set node.code = func
            
            /*
            *   Retrieve the priority. This will act as the pointer to
            *   the queue that the node will be added to.
            */
            set this = PriorityEventTree(this).add(priority)
            
            if (null == event) then
                /*
                *   If the queue hasn't been created yet, create it
                */
                set event = CreateTrigger()
                
                set first_p = node
                set last_p = node
                set codeList = func
            else
                /*
                *   Add node to queue
                */
                set last_p.next_p = node
                set last_p = node
                set codeList = Or(codeList, func)
            endif
            
            call TriggerAddCondition(event, func)
        endmethod
        
        method fire takes nothing returns nothing
            if (merged) then
                /*
                *   If the code has all been merged (game started), evaluate the trigger that contains all code
                */
                call TriggerEvaluate(allEvent)
            else
                /*
                *   If the code hasn't been merged yet, evaluate all of the triggers along the priority queue
                */
                loop
                    set this = PriorityEventTree(this).prev
                    exitwhen PriorityEventTree(this).head
                    call TriggerEvaluate(event)
                endloop
            endif
        endmethod
        
        /*
        *   This is called when the game starts. It merges all of the registered code
        *   for each event on to single triggers to improve performance
        */
        private static method merge takes nothing returns nothing
            local thistype this
            local integer current = count
            local PriorityEventTree priority
            local thistype node
            
            set merged = true
            
            /*
            *   Iterate over all events
            */
            loop
                exitwhen 0 == current
                set current = current - 1
                set this = tree[current]
                
                /*
                *   Iterate over all priorities
                */
                set priority = this
                loop
                    set priority = priority.prev
                    exitwhen priority.head
                    
                    /*
                    *   Clean up temporary priority event trigger
                    */
                    call TriggerClearConditions(thistype(priority).event)
                    call DestroyTrigger(thistype(priority).event)
                    set thistype(priority).event = null
                    
                    /*
                    *   Iterate over all registered code on the priority trigger
                    */
                    set node = thistype(priority).first_p
                    loop
                        exitwhen 0 == node
                        
                        /*
                        *   Add to main trigger
                        */
                        call TriggerAddCondition(allEvent, node.code)
                        
                        set node = node.next_p
                    endloop
                endloop
            endloop
        
            call DestroyTimer(GetExpiredTimer())
        endmethod
        
        private static method onInit takes nothing returns nothing
            call TimerStart(CreateTimer(), 0, false, function thistype.merge)
        endmethod
        
        static method treeNodeGetNext takes PriorityEventTree treeNode returns integer
            return treeNode.prev
        endmethod
        static method treeNodeIsHead takes PriorityEventTree treeNode returns boolean
            return treeNode.head
        endmethod
        static method treeNodeGetBoolExpr takes thistype treeNode returns boolexpr
            return treeNode.codeList
        endmethod
    endmodule
    struct PriorityEvent extends array
        implement PriorityEventMod
    endstruct
    
    struct PriorityEventPriorityList extends array
        method operator code takes nothing returns boolexpr
            return PriorityEvent.treeNodeGetBoolExpr(this)
        endmethod
        method operator head takes nothing returns boolean
            return PriorityEvent.treeNodeIsHead(this)
        endmethod
        method operator next takes nothing returns thistype
            return PriorityEvent.treeNodeGetNext(this)
        endmethod
        method operator priority takes nothing returns integer
            return PriorityEventTree(this).value
        endmethod
    endstruct
endlibrary