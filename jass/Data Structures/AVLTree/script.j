library AVL /* v1.1.0.6
*************************************************************************************
*
*   An AVL Tree where all nodes are connected by an AVL tree, a linked list, and 
*   are referenced by a hashtable.
*
*************************************************************************************
*
*   */uses/*
*   
*       */ Table /*         hiveworkshop.com/forums/jass-functions-413/snippet-new-table-188084/
*
************************************************************************************
*
*   module AVLTree
*
*       Interface:
*           method lessThan takes thistype value returns boolean
*           method greaterThan takes thistype value returns boolean
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
*           -   Returns the node containing the value
*           -   If the value didn't exist, it will return 0
*       method searchClose takes thistype value, boolean low returns thistype
*           -   Searches for the best match to the value. 
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
*           -   Returns new node containing added value. If the value
*           -   was already in the tree, it returns the node that already
*           -   contained that value.
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
        private static Table array table    //for O(1) searches on specific values
        private static thistype c=0         //instance count
        private static thistype array b     //root
        private static thistype array l     //left
        private static thistype array r     //right
        private static integer array h      //height
        private static thistype array p     //parent
        private static thistype array v     //value
        private static integer array nn     //next node
        private static integer array pn     //prev node
        private static integer array ro     //root
        method operator tree takes nothing returns thistype
            return ro[this]
        endmethod
        method operator root takes nothing returns thistype
            return p[this]
        endmethod
        method operator down takes nothing returns thistype
            return b[this]
        endmethod
        method operator left takes nothing returns thistype
            return l[this]
        endmethod
        method operator right takes nothing returns thistype
            return r[this]
        endmethod
        method operator value takes nothing returns thistype
            return v[this]
        endmethod
        method operator next takes nothing returns thistype
            return nn[this]
        endmethod
        method operator prev takes nothing returns thistype
            return pn[this]
        endmethod
        method operator head takes nothing returns boolean
            return 0==p[this]
        endmethod
        private method getHeight takes nothing returns integer
            //return the bigger leaf height
            if (h[l[this]]>h[r[this]]) then
                return h[l[this]]+1
            endif
            return h[r[this]]+1
        endmethod
        private method updateParent takes integer n returns nothing
            //only update the parent of a target leaf if that leaf isn't the original leaf
            if (n!=this) then
                //update the parent point to
                //first leaf
                if (0==p[p[this]]) then
                    set b[p[this]]=n
                //left
                elseif (l[p[this]]==this) then
                    set l[p[this]]=n
                //right
                else
                    set r[p[this]]=n
                endif
                
                //update the leaf point back
                //if the leaf isn't null, update the leaf's parent
                if (0!=n) then
                    set p[n]=p[this]
                endif
            endif
        endmethod
        private method finishRotate takes thistype n returns nothing
            //this code is identical in rotateLeft and rotateRight, so it has
            //been abstracted to a method
            call updateParent(n)
            set p[this]=n
            set h[this]=getHeight()
            set h[n]=n.getHeight()
        endmethod
        private method rotateLeft takes nothing returns thistype
            local thistype n=r[this]
            set r[this]=l[n]
            set p[l[n]]=this
            set l[n]=this
            call finishRotate(n)
            return n
        endmethod
        private method rotateRight takes nothing returns thistype
            local thistype n=l[this]
            set l[this]=r[n]
            set p[r[n]]=this
            set r[n]=this
            call finishRotate(n)
            return n
        endmethod
        //return the difference between the left and right leaf heights
        private method getBalanceFactor takes nothing returns integer
            return h[l[this]]-h[r[this]]
        endmethod
        private static method allocate takes nothing returns thistype
            local integer n
            if (0==nn[0]) then
                set n=c+1
                set c=n
            else
                set n=nn[0]     //notice that the recycler uses the next pointer
                                //the reason it is used is for fast clear/destroy and to save
                                //a variable
                set nn[0]=nn[n]
            endif
            set l[n]=0          //left leaf
            set r[n]=0          //right leaf
            set b[n]=0          //down leaf (first node of tree)
            set h[n]=1          //height (a node will always have at least a height of 1 for itself)
            return n
        endmethod
        static method create takes nothing returns thistype
            local integer n=allocate()
            set p[n]=0      //the parent of the tree node is 0
            
            //initialize tree next and prev
            set nn[n]=n
            set pn[n]=n
            
            //tree value table for O(1) searches on specific values
            set table[n]=Table.create()
            
            //tree root is itself (allows one to pass any node from the tree into the methods)
            set ro[n]=n
            
            return n
        endmethod
        //balance from the current node up to the root O(log n)
        //balancing is rotations wherever rotations need to be done
        private method balance takes nothing returns nothing
            local integer f
            loop
                exitwhen 0==p[this]
                set h[this]=getHeight()
                set f=getBalanceFactor()
                if (2==f) then
                    if (-1==l[this].getBalanceFactor()) then
                        call l[this].rotateLeft()
                    endif
                    set this=rotateRight()
                    return
                elseif (-2==f) then
                    if (1==r[this].getBalanceFactor()) then
                        call r[this].rotateRight()
                    endif
                    set this=rotateLeft()
                    return
                endif
                set this=p[this]
            endloop
        endmethod
        //goes to the very bottom of a node (for deletion)
        private method getBottom takes nothing returns thistype
            if (0!=r[this]) then
                if (0!=l[this]) then
                    set this=r[this]
                    loop
                        exitwhen 0==l[this]
                        set this=l[this]
                    endloop
                    return this
                else
                    return r[this]
                endif
            elseif (0!=l[this]) then
                return l[this]
            endif
            return this
        endmethod
        method search takes thistype val returns thistype
            return table[ro[this]][val]
        endmethod
        method has takes thistype val returns boolean
            return table[ro[this]].has(val)
        endmethod
        method searchClose takes thistype val, boolean low returns thistype
            local thistype n
            
            //retrieve tree
            set this=ro[this]
            
            //if tree is empty, return 0
            if (0==b[this]) then
                return 0
            endif
            
            //check to see if the node exists in the tree and return it if it does
            set n=table[this][val]
            if (0!=n) then
                return n
            endif
            
            //perform a standard tree search for the value to the bottom of the tree
            //will always be at most 1 off from the best match
            set this=b[this]
            loop
                if (val.lessThan(v[this])) then
                    exitwhen 0==l[this]
                    set this=l[this]
                else
                    exitwhen 0==r[this]
                    set this=r[this]
                endif
            endloop
            
            //look at the found value's neighbors on the linked list
            if (low) then
                //shift down if greater than
                if (v[this].greaterThan(val)) then
                    set this=prev
                endif
                //return 0 if node wasn't found
                if (0==p[this] or v[this].greaterThan(val)) then
                    return 0
                endif
            else
                //shift up if less than
                if (v[this].lessThan(val)) then
                    set this=next
                endif
                //return 0 if node wasn't found
                if (0==p[this] or v[this].lessThan(val)) then
                    return 0
                endif
            endif
            
            return this
        endmethod
        method add takes thistype val returns thistype
            local thistype n
            
            //check if the tree already has the value in it
            set this=ro[this]
            set n=table[this][val]
            
            //if the tree doesn't have the value in it, add the value
            if (0==n) then
                set n=this
            
                set this=allocate()
                set ro[this]=n              //store tree into leaf
                set table[n][val]=this      //store leaf into value table
                set v[this]=val             //store value into leaf
                
                //if the tree is empty
                if (0==b[n]) then
                    set b[n]=this           //place as first node
                    set p[this]=n           //parent of first node is tree
                    
                    //add to list
                    set nn[this]=n
                    set pn[this]=n
                    set nn[n]=this
                    set pn[n]=this
                else
                    //go to the first node in the tree
                    set n=b[n]
                    
                    //go to the bottom of the tree with search algorithm
                    loop
                        if (val.lessThan(v[n])) then
                            exitwhen 0==l[n]
                            set n=l[n]
                        else
                            exitwhen 0==r[n]
                            set n=r[n]
                        endif
                    endloop
                    
                    //add leaf to tree
                    set p[this]=n
                    if (val.lessThan(v[n])) then
                        set l[n]=this
                    else
                        set r[n]=this
                    endif
                    
                    //update the height of the parent
                    set h[n]=n.getHeight()
                    
                    //balance from the parent upwards
                    call p[n].balance()
                    
                    //add leaf to list
                    if (v[n].greaterThan(v[this])) then
                        set n=pn[n]
                    endif
                    set nn[this]=nn[n]
                    set pn[this]=n
                    set pn[nn[n]]=this
                    set nn[n]=this
                endif
                return this
            endif
            return n
        endmethod
        method delete takes nothing returns nothing
            local thistype n
            local thistype y
            
            //if the leaf to be deleted isn't 0 and the leaf isn't the tree
            if (0 != this and 0 != p[this]) then
                //remove the leaf from the value table
                call table[ro[this]].remove(v[this])
                
                set n=getBottom()       //retrieve the bottom leaf
                set y=p[n]              //store the parent here for balancing later
                
                //move the found leaf into the deleted leaf's position
                call n.updateParent(0)
                call updateParent(n)
                if (this!=n) then
                    set l[n]=l[this]
                    set p[l[n]]=n
                    set r[n]=r[this]
                    set p[r[n]]=n
                    set p[n]=p[this]
                    set h[n]=h[this]
                endif
                
                //balance from the found leaf's old parent upwards
                call y.balance()
                
                //remove deleted leaf from list
                set nn[pn[this]]=nn[this]
                set pn[nn[this]]=pn[this]
                set nn[this]=nn[0]
                set nn[0]=this
            endif
        endmethod
        method clear takes nothing returns thistype
            //quick clear
            set this=ro[this]
            if (nn[this] != this) then
                set nn[pn[this]]=nn[0]
                set nn[0]=nn[this]
                set nn[this]=this
                set pn[this]=this
                set b[this] = 0
                call table[this].flush()
            endif
            return this
        endmethod
        method destroy takes nothing returns nothing
            //quick destroy
            set this=ro[this]
            set nn[pn[this]]=nn[0]
            set nn[0]=this
            call table[this].destroy()
        endmethod
    endmodule
endlibrary