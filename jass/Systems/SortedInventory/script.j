library SortedInventory /* v1.0.0.0
*************************************************************************************
*
*   Used for saving hero inventories. Returns a list with all of the items in the inventory
*   sorted from lowest level to highest level with slot priority.
*
*************************************************************************************
*
*   */uses/*
*   
*       */ AVL /*         hiveworkshop.com/forums/jass-resources-412/snippet-avl-tree-203168/
*
************************************************************************************
*
*   struct SortedInventory extends array
*
*       static method create takes unit whichUnit, Table levelTable returns thistype
*       method destroy takes nothing returns nothing
*
*       method operator next takes nothing returns thistype
*       method operator prev takes nothing returns thistype
*       method operator head takes nothing returns boolean
*
*       method operator item takes nothing returns item
*       method operator itemTypeId takes nothing returns integer
*       method operator level takes nothing returns integer
*       method operator slot takes nothing returns integer
*
************************************************************************************/
    private struct InventorySlot extends array
        readonly item item
        readonly integer itemTypeId
        readonly integer level
        readonly integer slot
        
        private static integer instanceCount = 0
        private static integer array recycler
        
        static method create takes item whichItem, integer itemTypeId, integer level, integer slot returns thistype
            local thistype this = recycler[0]
            
            if (0 == this) then
                set this = instanceCount + 1
                set instanceCount = this
            else
                set recycler[0] = recycler[this]
            endif
            
            set this.item = whichItem
            set this.itemTypeId = itemTypeId
            set this.level = level
            set this.slot = slot
            
            return this
        endmethod
        
        method destroy takes nothing returns nothing
            set this.item = null
            set recycler[this] = recycler[0]
            set recycler[0] = this
        endmethod
    endstruct

    private struct InventoryTree extends array
        method operator item takes nothing returns item
            return InventorySlot(this).item
        endmethod
        method operator itemTypeId takes nothing returns integer
            return InventorySlot(this).itemTypeId
        endmethod
        method operator level takes nothing returns integer
            return InventorySlot(this).level
        endmethod
        method operator slot takes nothing returns integer
            return InventorySlot(this).slot
        endmethod
        private method lessThan takes InventorySlot val returns boolean
            return level < val.level or (level == val.level and slot < val.slot)
        endmethod
        private method greaterThan takes InventorySlot val returns boolean
            return level > val.level or (level == val.level and slot > val.slot)
        endmethod
        
        implement AVL
    endstruct
    
    struct SortedInventory extends array
        private integer countp
        
        method operator next takes nothing returns thistype
            return InventoryTree(this).next
        endmethod
        method operator prev takes nothing returns thistype
            return InventoryTree(this).prev
        endmethod
        method operator head takes nothing returns boolean
            return InventoryTree(this).head
        endmethod
        method operator value takes nothing returns InventorySlot
            return InventoryTree(this).value
        endmethod
        method operator item takes nothing returns item
            return value.item
        endmethod
        method operator itemTypeId takes nothing returns integer
            return value.itemTypeId
        endmethod
        method operator level takes nothing returns integer
            return value.level
        endmethod
        method operator slot takes nothing returns integer
            return value.slot
        endmethod
        method operator count takes nothing returns integer
            return countp
        endmethod
        static method create takes unit whichUnit, Table levelTable returns thistype
            local thistype this = InventoryTree.create()
            
            local integer currentInventorySlot = UnitInventorySize(whichUnit)
            local InventorySlot slot
            
            local item whichItem
            local integer itemTypeId
            local integer itemLevel
            
            local integer count = 0
            
            loop
                exitwhen 0 == currentInventorySlot
                set currentInventorySlot = currentInventorySlot - 1
                
                set whichItem = UnitItemInSlot(whichUnit, currentInventorySlot)
                set itemTypeId = GetItemTypeId(whichItem)
                if (0 != itemTypeId) then
                    set itemLevel = levelTable[itemTypeId]
                    
                    set slot = InventorySlot.create(whichItem, itemTypeId, itemLevel, currentInventorySlot)
                    
                    call InventoryTree(this).add(slot)
                    
                    set count = count + 1
                endif
            endloop
            
            set this.countp = count
            
            set whichItem = null
            
            return this
        endmethod
        method destroy takes nothing returns nothing
            loop
                set this = next
                exitwhen head
                call value.destroy()
            endloop
            call InventoryTree(this).destroy()
        endmethod
    endstruct
endlibrary