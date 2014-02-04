library Type /* v1.0.0.0
*************************************************************************************
*
*   Type checking
*
*************************************************************************************
*
*   struct Type extends array
*
*       readonly Type parent
*           -   Parent type
*
*       static method create takes Type parent returns Type
*           -   Creates a new type given a parent
*
*       method extends takes Type type returns boolean
*           -   A.extends(B) checks if A extends B (B parent of A)
*       method isParent takes Type type returns boolean
*           -   A.isParent(B) checks if A is a parent of B (B extends A)
*
*************************************************************************************/
    struct Type extends array
        private static integer instanceCount = 0
        private static hashtable parentTable = InitHashtable()
        readonly Type parent
        
        static method create takes Type parent returns Type
            local thistype this = instanceCount + 1
            set instanceCount = this
            
            call SaveBoolean(parentTable, this, this, true)
            call SaveBoolean(parentTable, this, 0, true)
            
            set this.parent = parent
            loop
                exitwhen parent == 0
                call SaveBoolean(parentTable, this, parent, true)
                set parent = thistype(parent).parent
            endloop
            
            return instanceCount
        endmethod
        
        method extends takes Type t returns boolean
            return HaveSavedBoolean(parentTable, this, t)
        endmethod
        method isParent takes Type t returns boolean
            return HaveSavedBoolean(parentTable, t, this)
        endmethod
    endstruct
endlibrary