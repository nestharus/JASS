library AVL /* v1.1.1.0
*************************************************************************************
*
*   An AVL Tree where all nodes are connected by an AVL tree, a linked list, and 
*   are referenced by a hashtable.
*
*************************************************************************************
*
*   */uses/*
*   
*       */ Table        /*
*
************************************************************************************
*
*   module AVL
*
*       interface private method lessThan takes thistype value returns boolean
*       interface private method greaterThan takes thistype value returns boolean
*
*       readonly thistype tree
*           -   Tree pointer. Accessible from any node on the tree.
*       readonly thistype root
*           -   Root of two children (if root is 0, it's the tree's root)
*       readonly thistype left
*       readonly thistype right
*       readonly thistype down (tree pointer only)
*           -   The tree has only 1 child, the root
*
*       readonly thistype next
*       readonly thistype prev
*       readonly boolean head
*
*       readonly thistype value
*           -   Value stored in node
*
*       static method create takes nothing returns thistype
*       method destroy takes nothing returns nothing
*
*       method search takes thistype value returns thistype
*           -   Returns the first node containing the value
*           -   If the value didn't exist, it will return 0
*       method searchClose takes thistype value, boolean low returns thistype
*           -   Searches for the best first match to the value. 
*           -
*           -   Low = True
*           -       Search for the closest value <= to the target value
*           -
*           -   Low = False
*           -       Search for the closest value >= to the target value
*
*       method has takes thistype value returns boolean
*           -   Returns true if a node contains the value
*
*       method add takes thistype value returns thistype
*           -   Returns new node containing added value.
*       method addUnique takes thistype val returns thistype
*           -   Returns either an existing node with value or adds a new node with the value.
*       method delete takes nothing returns nothing
*           -   Deletes node
*
*           ->  Delete the value 15 from the tree if it exists
*           ->  call search(15).delete()
*
*       method clear takes nothing returns thistype
*           -   Clears the tree of all nodes
*           -   Returns tree pointer (just in case some node in the tree was passed in rather than the tree)
*
************************************************************************************/
    module AVL
        private static thistype instanceCount = 0
        
        private Table searchTable
        private thistype p_root
        private thistype p_left
        private thistype p_right
        private integer p_height
        private thistype p_parent
        private thistype p_value
        private thistype p_next
        private thistype p_prev
        private thistype p_tree
        
        method operator tree takes nothing returns thistype
            return p_tree
        endmethod
        method operator root takes nothing returns thistype
            return p_parent
        endmethod
        method operator down takes nothing returns thistype
            return p_root
        endmethod
        method operator left takes nothing returns thistype
            return p_left
        endmethod
        method operator right takes nothing returns thistype
            return p_right
        endmethod
        method operator value takes nothing returns thistype
            return p_value
        endmethod
        method operator next takes nothing returns thistype
            return p_next
        endmethod
        method operator prev takes nothing returns thistype
            return p_prev
        endmethod
        method operator head takes nothing returns boolean
            return 0 == p_parent
        endmethod
        
        private method getHeight takes nothing returns integer
            //return the bigger leaf height
            if (p_left.p_height > p_right.p_height) then
                return p_left.p_height + 1
            endif
            
            return p_right.p_height + 1
        endmethod
        //return the difference between the left and right leaf heights
        private method getBalanceFactor takes nothing returns integer
            return p_left.p_height - p_right.p_height
        endmethod
        
        private method updateParent takes thistype leaf returns nothing
            //only update the parent of a target leaf if that leaf isn't the original leaf
            if (leaf != this) then
                //update the parent point to
                //first leaf
                if (0 == p_parent.p_parent) then
                    set p_parent.p_root = leaf
                //left
                elseif (p_parent.p_left == this) then
                    set p_parent.p_left = leaf
                //right
                else
                    set p_parent.p_right = leaf
                endif
                
                //update the leaf point back
                //if the leaf isn't null, update the leaf's parent
                if (0 != leaf) then
                    set leaf.p_parent = p_parent
                endif
            endif
        endmethod
        private method finishRotate takes thistype leaf returns nothing
            //this code is identical in rotateLeft and rotateRight, so it has
            //been abstracted to a method
            call updateParent(leaf)
            set p_parent = leaf
            set p_height = getHeight()
            set leaf.p_height = leaf.getHeight()
        endmethod
        private method rotateLeft takes nothing returns thistype
            local thistype leaf = p_right
            
            set p_right = leaf.p_left
            set leaf.p_left.p_parent = this
            set leaf.p_left = this
            call finishRotate(leaf)
            
            return leaf
        endmethod
        private method rotateRight takes nothing returns thistype
            local thistype leaf = p_left
            
            set p_left = leaf.p_right
            set leaf.p_right.p_parent = this
            set leaf.p_right = this
            call finishRotate(leaf)
            
            return leaf
        endmethod
        
        private static method allocate takes nothing returns thistype
            local thistype node
            
            if (0 == thistype(0).p_next) then
                set node = instanceCount + 1
                set instanceCount = node
            else
                set node = thistype(0).p_next
                set thistype(0).p_next = node.p_next
            endif
            
            set node.p_left = 0          //left leaf
            set node.p_right = 0         //right leaf
            set node.p_root = 0          //down leaf (first node of tree)
            set node.p_height = 1        //height (a node will always have at least a height of 1 for itself)
            
            return node
        endmethod
        static method create takes nothing returns thistype
            local thistype tree = allocate()
            
            set tree.p_parent = 0      //the parent of the tree node is 0
            
            //initialize tree next and prev
            set tree.p_next = tree
            set tree.p_prev = tree
            
            //tree value searchTable for O(1) searches on specific values
            set tree.searchTable = Table.create()
            
            //tree root is itself (allows one to pass any node from the tree into the methods)
            set tree.p_tree = tree
            
            return tree
        endmethod
        
        //balance from the current node up to the root O(log n)
        //balancing is rotations wherever rotations need to be done
        private method balance takes nothing returns nothing
            local integer balanceFactor
            
            loop
                exitwhen p_parent == 0
                
                set p_height = getHeight()
                set balanceFactor = getBalanceFactor()
                
                if (balanceFactor == 2) then
                    if (p_left.getBalanceFactor() == -1) then
                        call p_left.rotateLeft()
                    endif
                    
                    set this = rotateRight()
                    
                    return
                elseif (balanceFactor == -2) then
                    if (p_right.getBalanceFactor() == 1) then
                        call p_right.rotateRight()
                    endif
                    
                    set this = rotateLeft()
                    
                    return
                endif
                
                set this = p_parent
            endloop
        endmethod
        //goes to the very bottom of a node (for deletion)
        private method getBottom takes nothing returns thistype
            if (p_right != 0) then
                if (p_left != 0) then
                    set this = p_right
                    loop
                        exitwhen p_left == 0
                        
                        set this = p_left
                    endloop
                    
                    return this
                endif
                
                return p_right
            elseif (p_left != 0) then
                return p_left
            endif
            
            return this
        endmethod
        
        method has takes thistype val returns boolean
            return p_tree.searchTable.has(val)
        endmethod
        method search takes thistype val returns thistype
            return p_tree.searchTable[val]
        endmethod
        method searchClose takes thistype val, boolean low returns thistype
            local thistype node
            
            //retrieve tree
            set this = p_tree
            
            //if tree is empty, return 0
            if (p_root == 0) then
                return 0
            endif
            
            //check to see if the node exists in the tree and return it if it does
            set node = searchTable[val]
            if (node != 0) then
                return node
            endif
            
            //perform a standard tree search for the value to the bottom of the tree
            //will always be at most 1 off from the best match
            set this = p_root
            loop
                if (val.lessThan(p_value)) then
                    exitwhen p_left == 0
                    
                    set this = p_left
                else
                    exitwhen p_right == 0
                    
                    set this = p_right
                endif
            endloop
            
            //look at the found value's neighbors on the linked list
            if (low) then
                //shift down if greater than
                if (p_value.greaterThan(val)) then
                    set this = prev
                endif
                
                //return 0 if node wasn't found
                if (p_parent == 0 or p_value.greaterThan(val)) then
                    return 0
                endif
            else
                //shift up if less than
                if (p_value.lessThan(val)) then
                    set this = p_next
                endif
                
                //return 0 if node wasn't found
                if (p_parent == 0 or p_value.lessThan(val)) then
                    return 0
                endif
            endif
            
            return this
        endmethod
        
        method add takes thistype val returns thistype
            local thistype tree
            
            //check if the tree already has the value in it
            set this = p_tree
            set tree = searchTable[val]
            
            //if the tree doesn't have the value in it, add the value
            if (tree == 0) then
                set tree = this
            
                set this = allocate()
                set p_tree = tree                   //store tree into leaf
                set tree.searchTable[val] = this    //store leaf into value searchTable
                set p_value = val                   //store value into leaf
                
                //if the tree is empty
                if (tree.p_root == 0) then
                    set tree.p_root = this          //place as first node
                    set p_parent = tree             //parent of first node is tree
                    
                    //add to list
                    set p_next = tree
                    set p_prev = tree
                    set tree.p_next = this
                    set tree.p_prev = this
                else
                    //go to the first node in the tree
                    set tree = tree.p_root
                    
                    //go to the bottom of the tree with search algorithm
                    loop
                        if (val.lessThan(tree.p_value)) then
                            exitwhen tree.p_left == 0
                            
                            set tree = tree.p_left
                        else
                            exitwhen tree.p_right == 0
                            
                            set tree = tree.p_right
                        endif
                    endloop
                    
                    //add leaf to tree
                    set p_parent = tree
                    if (val.lessThan(tree.p_value)) then
                        set tree.p_left = this
                    else
                        set tree.p_right = this
                    endif
                    
                    //update the height of the parent
                    set tree.p_height = tree.getHeight()
                    
                    //balance from the parent upwards
                    call tree.p_parent.balance()
                    
                    //add leaf to list
                    if (tree.p_value.greaterThan(p_value)) then
                        set tree = tree.p_prev
                    endif
                    set p_next = tree.p_next
                    set p_prev = tree
                    set tree.p_next.p_prev = this
                    set tree.p_next = this
                endif
                
                return this
            endif
            
            set this = allocate()
            set p_tree = tree.p_tree            //store tree into leaf
            set p_value = val                   //store value into leaf
            set p_parent = -1
            
            //add leaf to list
            set p_next = tree.p_next
            set p_prev = tree
            set tree.p_next.p_prev = this
            set tree.p_next = this
            
            return this
        endmethod
        method addUnique takes thistype val returns thistype
            local thistype node = search(val)
            
            if (node == 0) then
                return add(val)
            endif
            
            return node
        endmethod
        method delete takes nothing returns nothing
            local thistype node     //n
            local thistype parent   //y
            
            //if the leaf to be deleted isn't 0 and the leaf isn't the tree
            if (this != 0 and p_parent != 0) then
                //if the leaf is in the tree
                if (p_parent != -1) then
                    //if the leaf is the only one of its kind in the tree
                    if (p_next.p_value != p_value) then
                        //remove the leaf from the value searchTable
                        call p_tree.searchTable.remove(p_value)
                        
                        set node = getBottom()              //retrieve the bottom leaf
                        set parent = node.p_parent          //store the parent here for balancing later
                        
                        //move the found leaf into the deleted leaf's position
                        call node.updateParent(0)
                        call updateParent(node)
                        
                        if (this != node) then
                            set node.p_left = p_left
                            set node.p_left.p_parent = node
                            set node.p_right = p_right
                            set node.p_right.p_parent = node
                            set node.p_parent = p_parent
                            set node.p_height = p_height
                        endif
                        
                        //balance from the found leaf's old parent upwards
                        call parent.balance()
                    //replace the leaf with an existing identical leaf
                    else
                        set node = p_next
                        set p_tree.searchTable[p_value] = node
                        
                        call updateParent(node)
                        
                        set node.p_left = p_left
                        set node.p_left.p_parent = node
                        set node.p_right = p_right
                        set node.p_right.p_parent = node
                        set node.p_parent = p_parent
                        set node.p_height = p_height
                    endif
                endif
                
                //remove deleted leaf from list
                set p_prev.p_next = p_next
                set p_next.p_prev = p_prev
                set p_next = thistype(0).p_next
                set thistype(0).p_next = this
            endif
        endmethod
        
        method clear takes nothing returns thistype
            //quick clear
            set this = p_tree
            
            if (p_next != this) then
                set p_prev.p_next = thistype(0).p_next
                set thistype(0).p_next = p_next
                
                set p_next = this
                set p_prev = this
                set p_root = 0
                
                call searchTable.flush()
            endif
            
            return this
        endmethod
        method destroy takes nothing returns nothing
            //quick destroy
            set this = p_tree
            
            call searchTable.destroy()
            
            set p_prev.p_next = thistype(0).p_next
            set thistype(0).p_next = this
        endmethod
    endmodule
endlibrary