library BooleanExpression /* v1.0.0.13
************************************************************************************
*
*   */ uses /*
*   
*       */ ErrorMessage         /*          hiveworkshop.com/forums/submissions-414/snippet-error-message-239210/
*       */ List                 /*          hiveworkshop.com/forums/submissions-414/snippet-list-239400/
*       */ NxStack              /*          hiveworkshop.com/forums/submissions-414/snippet-nxstack-239368/
*       */ Alloc                /*          hiveworkshop.com/forums/jass-resources-412/snippet-alloc-alternative-221493/
*
************************************************************************************
*
*   struct BooleanExpression extends array
*
*       Description
*       -------------------------
*
*           Creates a single boolean expression via Or's
*
*           Provides a slight speed boost
*
*           Allows the for the safe usage of TriggerRemoveCondition given that the only boolexpr on the trigger
*           is the one from this struct
*
*           To put multiple boolean expressions on to one trigger, combine them with Or. Be sure to destroy later.
*
*           Alternatively, they can be wrapped with another BooleanExpression, but this will add overhead. Only use
*           if more than three are planned to be on one trigger.
*
*       Fields
*       -------------------------
*
*           readonly boolexpr expression
*
*               -   rebuilds expression if expression was modified
*               -   will break triggers unless the expression is removed/added again
*
*                   call booleanExpression.register(myCode)
*                   call TriggerRemoveCondition(thisTrigger, theOneCondition)
*                   set theOneCondition = TriggerAddCondition(thisTrigger, booleanExpression.expression)
*
*       Methods
*       -------------------------
*
*           static method create takes nothing returns BooleanExpression
*           method destroy takes nothing returns nothing
* 
*           method register takes boolexpr expression returns BooleanExpression
*           method unregister takes nothing returns nothing
*
*           method replace takes boolexpr expression returns nothing
*               -   Replaces the boolexpr inside of the registered expression
*               -   Useful for updating expressions without breaking order
*
*           method clear takes nothing returns nothing
*
*           debug static method calculateMemoryUsage takes nothing returns integer
*           debug static method getAllocatedMemoryAsString takes nothing returns string
*
************************************************************************************/
    private keyword ListExpression
    private keyword NodeExpression
    
    scope NodeExpressionScope
        private struct Node extends array
            /*
            *   Tree Fields
            */
            thistype root
            
            thistype left
            thistype right
            
            /*
            *   List Fields
            */
            thistype next
            thistype prev
            
            /*
            *   Standard Fields
            */
            boolexpr expression
            
            boolean canDestroy
            
            /*
            *       static method allocate takes nothing returns thistype
            *       method deallocate takes nothing returns nothing
            */
            implement Alloc
            
            static method create takes nothing returns thistype
                return allocate()
            endmethod
            
            /*
            *   Destroy all nodes within tree, clears, only used for complete tree destruction
            */
            method destroySub takes nothing returns nothing
                /*
                *   Destroy/Clear List Node
                */
                if (left == 0) then
                    set root = 0
                    set next = 0
                    set prev = 0
                /*
                *   Destroy/Clear Tree Node
                */
                else
                    if (canDestroy) then
                        set canDestroy = false
                        call DestroyBoolExpr(expression)
                    endif
                
                    set left.root = 0
                    call left.destroySub()
                    set left = 0
                    
                    set right.root = 0
                    call right.destroySub()
                    set right = 0
                endif
                
                set expression = null
                
                call deallocate()
            endmethod
            
            /*
            *   Joins two trees under a new root
            *   Returns new root
            */
            static method join takes Node left, Node right returns Node
                local Node this = Node.create()
                
                set this.left = left
                set this.right = right
                set left.root = this
                set right.root = this
                
                if (right.expression == null) then
                    set expression = left.expression
                elseif (left.expression == null) then
                    set expression = right.expression
                else
                    set canDestroy = true
                    set expression = Or(left.expression, right.expression)
                endif
                
                return this
            endmethod
            
            /*
            *   Joins the list nodes of
            *
            *       Tree/Node
            *       Node/Node
            */
            static method listJoin takes Node tree, Node node returns nothing
                debug call ThrowError(tree == 0,                  "BooleanExpression.NodeExpressionScope", "listJoin", "Node", 0, "Attempted To Join With Null Tree " + "(" + I2S(tree) + ").")
                debug call ThrowError(node == 0,                  "BooleanExpression.NodeExpressionScope", "listJoin", "Node", 0, "Attempted To Join With Null Node " + "(" + I2S(node) + ").")
                
                loop
                    exitwhen tree.right == 0
                    set tree = tree.right
                endloop
                
                set tree.next = node
                set node.prev = tree
            endmethod
            
            /*
            *   Splits a tree, returning the left piece
            */
            method splitLeft takes nothing returns Node
                local thistype left = this.left
                
                debug call ThrowError(left == 0,                  "BooleanExpression.NodeExpressionScope", "splitLeft", "Node", this, "Attempted To Split Node, Expecting Tree.")
                debug call ThrowError(root != 0,                  "BooleanExpression.NodeExpressionScope", "splitLeft", "Node", this, "Attempted To Split Child Tree, Expecting Tree.")
                
                if (canDestroy) then
                    set canDestroy = false
                    call DestroyBoolExpr(expression)
                endif
                set expression = null
                
                set right.root = 0
                set left.root = 0
                set this.left = 0
                set right = 0
                
                call deallocate()
                
                return left
            endmethod
            
            /*
            *   Returns malformed tree or 0
            *   Takes a node
            */
            method remove takes nothing returns Node
                local thistype node = next
                
                local thistype nextRoot = next.root
                local thistype currentRoot = root
                
                local boolean isRight = currentRoot.right == this
                
                local thistype lastNode = 0
                
                local thistype replacer
                
                debug call ThrowError(left != 0 or right != 0,    "BooleanExpression.NodeExpressionScope", "remove", "Node", this, "Attempted To Remove Tree, Expecting Node.")
                
                if (node != 0) then
                    loop
                        set lastNode = node
                        
                        set node.root = currentRoot
                        
                        /*
                        *   Set new child of root
                        */
                        if (currentRoot != 0) then
                            if (isRight) then
                                set currentRoot.right = node
                            else
                                set currentRoot.left = node
                            endif
                            
                            set isRight = not isRight
                        endif
                        
                        /*
                        *   Replace boolean expressions along tree
                        */
                        set replacer = node.root
                        loop
                            exitwhen replacer == 0
                            
                            if (replacer.canDestroy) then
                                set replacer.canDestroy = false
                                call DestroyBoolExpr(replacer.expression)
                            endif
                            
                            if (replacer.right.expression == null) then
                                set replacer.expression = replacer.left.expression
                            elseif (replacer.left.expression == null) then
                                set replacer.expression = replacer.right.expression
                            else
                                set replacer.canDestroy = true
                                set replacer.expression = Or(replacer.left.expression, replacer.right.expression)
                            endif
                            
                            set replacer = replacer.root
                        endloop
                        
                        set currentRoot = nextRoot
                        set node = node.next
                        exitwhen node == 0
                        set nextRoot = node.root
                    endloop
                    
                    /*
                    *   Clear Last Position If There Is One
                    */
                    if (currentRoot != 0) then
                        if (isRight) then
                            set currentRoot.right = 0
                        else
                            set currentRoot.left = 0
                        endif
                    endif
                    
                    /*
                    *   Remove from list
                    */
                    set next.prev = prev
                    
                    if (prev != 0) then
                        set prev.next = next
                        set prev = 0
                    endif
                    
                    set next = 0
                elseif (prev != 0) then
                    /*
                    *   Remove from list partial
                    */
                    set prev.next = next
                    set prev = 0
                endif
                
                /*
                *   Get last added tree (may be removed null)
                */
                if (lastNode == 0) then
                    set lastNode = root
                endif
                loop
                    exitwhen lastNode.root == 0
                    set lastNode = lastNode.root
                endloop
                
                /*
                *   Remove from tree
                */
                if (root.left == this) then
                    set root.left = 0
                elseif (root.right == this) then
                    set root.right = 0
                endif
                set root = 0
                
                /*
                *   Destroy removed node
                */
                set expression = null
                
                call deallocate()
                
                /*
                *   Return last added tree
                */
                return lastNode
            endmethod
            
            method replace takes boolexpr expression returns nothing
                set this.expression = expression
                loop
                    exitwhen root == 0
                    set this = root
                    
                    if (this.canDestroy) then
                        set this.canDestroy = false
                        call DestroyBoolExpr(this.expression)
                    endif
                    if (right.expression == null) then
                        set this.expression = left.expression
                    elseif (left.expression == null) then
                        set this.expression = right.expression
                    else
                        set this.canDestroy = true
                        set this.expression = Or(left.expression, right.expression)
                    endif
                endloop
            endmethod
        endstruct
        
        struct NodeExpression extends array
            method operator root takes nothing returns thistype
                return Node(this).root
            endmethod
            method operator left takes nothing returns thistype
                return Node(this).left
            endmethod
            method operator right takes nothing returns thistype
                return Node(this).right
            endmethod
            method operator next takes nothing returns thistype
                return Node(this).next
            endmethod
            method operator prev takes nothing returns thistype
                return Node(this).prev
            endmethod
            method operator expression takes nothing returns boolexpr
                return Node(this).expression
            endmethod
            method operator expression= takes boolexpr expression returns nothing
                set Node(this).expression = expression
            endmethod
            
            static method create takes boolexpr expression returns thistype
                local Node node = Node.create()
                set node.expression = expression
                return node
            endmethod
            method destroy takes nothing returns nothing
                call Node(this).destroySub()
            endmethod
            
            static method join takes Node left, Node right returns thistype
                return Node.join(left, right)
            endmethod
            static method listJoin takes Node prev, Node next returns nothing
                call Node.listJoin(prev, next)
            endmethod
            
            method splitLeft takes nothing returns thistype
                return Node(this).splitLeft()
            endmethod
            
            method remove takes nothing returns thistype
                return Node(this).remove()
            endmethod
            
            method operator top takes nothing returns thistype
                loop
                    exitwhen Node(this).root == 0
                    set this = Node(this).root
                endloop
                
                return this
            endmethod
            method replace takes boolexpr expression returns nothing
                call Node(this).replace(expression)
            endmethod
            
            static if DEBUG_MODE then
                static method calculateMemoryUsage takes nothing returns integer
                    return Node.calculateMemoryUsage()
                endmethod
                
                static method getAllocatedMemoryAsString takes nothing returns string
                    return Node.getAllocatedMemoryAsString()
                endmethod
            endif
        endstruct
        
        scope ListExpressionScope
            private struct List_P extends array
                NodeExpression expression
                
                static thistype array expressionOwner
                
                implement List
            endstruct
            
            struct ListExpression extends array
                static method operator sentinel takes nothing returns integer
                    return List_P.sentinel
                endmethod
                method operator list takes nothing returns thistype
                    return List_P(this).list
                endmethod
                method operator first takes nothing returns thistype
                    return List_P(this).first
                endmethod
                method operator last takes nothing returns thistype
                    return List_P(this).last
                endmethod
                method operator next takes nothing returns thistype
                    return List_P(this).next
                endmethod
                method operator prev takes nothing returns thistype
                    return List_P(this).prev
                endmethod
                method operator expression takes nothing returns boolexpr
                    return List_P(this).expression.expression
                endmethod
                
                /*
                *   Destroy all trees in list
                */
                private method clearExpressions takes nothing returns nothing
                    local thistype node = first
                    
                    loop
                        exitwhen node == 0
                        
                        if (List_P(node).expression != 0) then
                            call List_P(node).expression.destroy()
                            set List_P(node).expression = 0
                        endif
                        
                        set node = node.next
                    endloop
                endmethod
                
                static method create takes nothing returns thistype
                    local thistype this = List_P.create()
                    call List_P(this).enqueue()
                    
                    return this
                endmethod
                
                method destroy takes nothing returns nothing
                    call clearExpressions()
                    call List_P(this).destroy()
                endmethod
                
                method clear takes nothing returns nothing
                    call clearExpressions()
                    call List_P(this).clear()
                    call List_P(this).enqueue()
                endmethod
                
                private method operator firstExpression takes nothing returns NodeExpression
                    loop
                        exitwhen this == 0 or List_P(this).expression != 0
                        set this = next
                    endloop
                    
                    return List_P(this).expression
                endmethod
                
                method insert takes boolexpr expression returns thistype
                    local List_P node = first
                    local NodeExpression nodeExpression = NodeExpression.create(expression)
                    local NodeExpression firstExpression = thistype(node).firstExpression
                    
                    if (firstExpression != 0) then
                        call NodeExpression.listJoin(firstExpression, nodeExpression)
                    endif
                    
                    /*
                    *   If the first node on the list has no expression put expression in node
                    */
                    if (node.expression == 0) then
                        set node.expression = nodeExpression
                        
                        set List_P.expressionOwner[nodeExpression] = node
                    /*
                    *   If it does have an expression, join expressions
                    */
                    else
                        set node.expression = NodeExpression.join(node.expression, nodeExpression)
                        
                        loop
                            exitwhen node.next == 0 or node.next.expression == 0
                            
                            set node.next.expression = NodeExpression.join(node.next.expression, node.expression)
                            set node.expression = 0
                            
                            set node = node.next
                        endloop
                        
                        if (node.next == 0) then
                            set List_P(this).enqueue().expression = node.expression
                        else
                            set node.next.expression = node.expression
                        endif
                        
                        set node.expression = 0
                    endif
                    
                    /*
                    *   Used to remove expressions
                    */
                    set List_P.expressionOwner[node.next.expression] = node.next
                    
                    return nodeExpression
                endmethod
                
                /*
                *   Return owning list
                */
                method remove takes nothing returns thistype
                    local NodeExpression node = this
                    local NodeExpression tree = node.top
                    local List_P listNode = List_P.expressionOwner[tree]
                    local List_P owner = listNode.list
                    
                    local boolean isOdd = listNode.list.first.expression != 0       //no need to decompose when odd
                    
                    set node = node.remove()
                    
                    if (isOdd) then
                        set listNode.list.first.expression = 0
                    
                        return owner
                    else
                        /*
                        *   Decompose the tree
                        */
                        set listNode = List_P.expressionOwner[node.top]
                        set listNode.expression = 0
                        
                        loop
                            exitwhen node.left == 0
                            set tree = node.right
                            set node = node.splitLeft()
                            set listNode = listNode.prev
                            set listNode.expression = node
                            set List_P.expressionOwner[node] = listNode
                            set node = tree
                        endloop
                        
                        if (node != 0) then
                            set listNode = listNode.prev
                            set listNode.next.expression = node
                            set List_P.expressionOwner[node] = listNode
                        endif
                    endif
                    
                    return owner
                endmethod
                
                method replace takes boolexpr expression returns thistype
                    call NodeExpression(this).replace(expression)
                    return List_P.expressionOwner[NodeExpression(this).top].list
                endmethod
                
                static if DEBUG_MODE then
                    static method calculateMemoryUsage takes nothing returns integer
                        return List_P.calculateMemoryUsage()
                    endmethod
                    
                    static method getAllocatedMemoryAsString takes nothing returns string
                        return List_P.getAllocatedMemoryAsString()
                    endmethod
                endif
            endstruct
        endscope
    endscope
    
    private struct BooleanExpressionContainer extends array
        implement NxStack
        
        boolexpr expression
        boolexpr top
        
        /*
        *   This is one ugly algorithm
        *
        *   Move the list to an array
        *
        *   Merge slots on the array in pairs
        *   Remove the resulting empty holes
        *   Keep repeating until array only has 1 filled slot
        */
        private static boolexpr array buffer
        method build takes nothing returns nothing
            local ListExpression node = ListExpression(this).last
            
            local integer length = 0
            local integer segment = 0
            local integer positionStart = 0
            local integer positionEnd
            local integer targetStart
            local integer targetEnd
            
            /*
            *   Get length
            */
            loop
                exitwhen node == 0
                if (node.expression != null) then
                    set length = length + 1
                endif
                set node = node.prev
            endloop
            if (length == 0) then
                return
            endif
            set positionEnd = length
            
            /*
            *   Copy to array
            */
            set node = ListExpression(this).last
            loop
                exitwhen positionStart == positionEnd
                
                loop
                    exitwhen node.expression != null
                    set node = node.prev
                endloop
                set buffer[positionStart] = node.expression
                set positionStart = positionStart + 1
                
                exitwhen positionStart == positionEnd
                loop
                    set node = node.prev
                    exitwhen node.expression != null
                endloop
                set positionEnd = positionEnd - 1
                set buffer[positionEnd] = node.expression
                
                set node = node.prev
            endloop
            
            /*
            *   Merge
            */
            loop
                exitwhen length < 2
                
                set positionStart = segment
                set positionEnd = segment + length
                
                if (length - length/2*2 == 0) then
                    set length = length/2
                else
                    set length = length/2 + 1
                endif
                
                set segment = positionEnd
                
                set targetStart = segment
                set targetEnd = segment + length
                
                loop
                    exitwhen positionStart == positionEnd
                    set buffer[targetStart] = buffer[positionStart]
                    set buffer[positionStart] = null
                    set positionStart = positionStart + 1
                    exitwhen positionStart == positionEnd
                    
                    set positionEnd = positionEnd - 1
                    set buffer[targetStart] = Or(buffer[targetStart], buffer[positionEnd])
                    set push().expression = buffer[targetEnd]
                    set buffer[positionEnd] = null
                    set targetStart = targetStart + 1
                    exitwhen targetStart == targetEnd
                    
                    set targetEnd = targetEnd - 1
                    set buffer[targetEnd] = buffer[positionStart]
                    set buffer[positionStart] = null
                    set positionStart = positionStart + 1
                    exitwhen positionStart == positionEnd
                    
                    set positionEnd = positionEnd - 1
                    set buffer[targetEnd] = Or(buffer[targetEnd], buffer[positionEnd])
                    set push().expression = buffer[targetEnd]
                    set buffer[positionEnd] = null
                endloop
            endloop
            
            set top = buffer[segment + length - 1]
            set buffer[segment + length - 1] = null
        endmethod
        
        method destruct takes nothing returns nothing
            local thistype stack = this
        
            set top = null
            set this = first
            
            loop
                exitwhen this == 0
                call DestroyBoolExpr(expression)
                set expression = null
                set this = next
            endloop
            
            call stack.clear()
        endmethod
    endstruct
    
    struct BooleanExpression extends array
        private boolean modified
        
        debug private boolean isAllocated
        
        /*
        *   Only rebuild the expression when it is needed, otherwise leave it alone
        *   Rebuilding the expression will break triggers using it plus has a bit of overhead
        */
        method operator expression takes nothing returns boolexpr
            debug call ThrowError(this == 0,        "BooleanExpression", "expression", "BooleanExpression", this, "Attempted To Read Null Boolean Expression.")
            debug call ThrowError(not isAllocated,  "BooleanExpression", "expression", "BooleanExpression", this, "Attempted To Read Invalid Boolean Expression.")
        
            if (modified) then
                set modified = false
                call BooleanExpressionContainer(this).destruct()
                call BooleanExpressionContainer(this).build()
            endif
            
            return BooleanExpressionContainer(this).top
        endmethod
    
        static method create takes nothing returns thistype
            local thistype this = ListExpression.create()
            
            call BooleanExpressionContainer(this).clear()
            
            debug set isAllocated = true
            
            return this
        endmethod
        method destroy takes nothing returns nothing
            debug call ThrowError(this == 0,        "BooleanExpression", "destroy", "BooleanExpression", this, "Attempted To Destroy Null Boolean Expression.")
            debug call ThrowError(not isAllocated,  "BooleanExpression", "destroy", "BooleanExpression", this, "Attempted To Destroy Invalid Boolean Expression.")
        
            debug set isAllocated = false
            set modified = false
            call BooleanExpressionContainer(this).destruct()
            call BooleanExpressionContainer(this).destroy()
            call ListExpression(this).destroy()
        endmethod
        method clear takes nothing returns nothing
            debug call ThrowError(this == 0,        "BooleanExpression", "clear", "BooleanExpression", this, "Attempted To Clear Null Boolean Expression.")
            debug call ThrowError(not isAllocated,  "BooleanExpression", "clear", "BooleanExpression", this, "Attempted To Clear Invalid Boolean Expression.")
        
            set modified = false
            call BooleanExpressionContainer(this).destruct()
            call ListExpression(this).clear()
        endmethod
        method register takes boolexpr expression returns thistype
            debug call ThrowError(this == 0,            "BooleanExpression", "register", "BooleanExpression", this, "Attempted To Register To Null Boolean Expression.")
            debug call ThrowError(not isAllocated,      "BooleanExpression", "register", "BooleanExpression", this, "Attempted To Register To Invalid Boolean Expression.")
            
            set modified = true
            return ListExpression(this).insert(expression)
        endmethod
        method unregister takes nothing returns nothing
            /*
            *   No easy way to do error checking here, will have to let internal resources do it
            */
            set thistype(ListExpression(this).remove()).modified= true
        endmethod
        method replace takes boolexpr expression returns nothing
            set thistype(ListExpression(this).replace(expression)).modified = true
        endmethod
        
        static if DEBUG_MODE then
            static method calculateMemoryUsage takes nothing returns integer
                return NodeExpression.calculateMemoryUsage() + BooleanExpressionContainer.calculateMemoryUsage() + ListExpression.calculateMemoryUsage()
            endmethod
            
            static method getAllocatedMemoryAsString takes nothing returns string
                return "(Node Expression)[" + NodeExpression.getAllocatedMemoryAsString() + "], (List Expression)[" + ListExpression.getAllocatedMemoryAsString() + "], (Boolean Expression Container)[" + BooleanExpressionContainer.getAllocatedMemoryAsString() + "]"
            endmethod
        endif
    endstruct
endlibrary