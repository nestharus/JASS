/**************************************************************************************************************************************************************
*
*   struct LevelGroupSlotVersionCatalog extends array
*
*       static method create takes nothing returns LevelGroupSlotVersionCatalog
*
*       method add takes integer rawId, integer ver, integer groupId, integer slot, integer level returns nothing
*           -   Adds a new item to the catalog.
*
*                                                         Notes
*           -------------------------------------------------------------------------------------------------------
*           -
*           -   ver is the version of the game that the item was added to
*           -
*           -   groupId is the group that can use the item. The group may be a specific unit or a group of units.
*           -
*           -   slot is a second group dimension (perhaps an inventory slot or item class)
*           -
*           -------------------------------------------------------------------------------------------------------
*
*       method addGroup takes integer ver, integer groupId, integer groupId2, integer slot returns nothing
*           -   Adds groupId2 to groupId in version ver.
*
*                                                         Notes
*           -------------------------------------------------------------------------------------------------------
*           -
*           -   groupId will be able to use any items that groupId2 is able to use for a specific slot
*           -
*           -   This will only be effective from ver and up, but groupId will be able to use anything groupId2 can use from
*           -   any version.
*           -
*           -------------------------------------------------------------------------------------------------------
*
*       method get takes integer ver, integer groupId, integer slot, integer minLevel, integer maxLevel returns Catalog
*           -   Builds a temporary catalog (automatically destroyed later)
*
*                                                         Notes
*           -------------------------------------------------------------------------------------------------------
*           -
*           -   ver is the version of the game to retrieve the catalog for. Version 6 would retrieve all catalogs from version 1-6
*           -
*           -   groupId is the group to retrieve the catalog for in a slot. If group 'Hpal' had group 1 slot 1 added to it and 'Hpal' slot 1 was passed in, this
*           -   would return the catalogs for both 'Hpal' slot 1 and group 1 slot 1.
*           -
*           -------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************************************/
library_once TempCatalog uses Catalog
    struct TempCatalog extends array
        private static timer dest = CreateTimer()
        private static integer array rec
        private static integer recc = 0
        
        private static method destroyer takes nothing returns nothing
            loop
                set recc = recc - 1
                call CatalogDestroy(rec[recc])
                exitwhen 0 == recc
            endloop
        endmethod
        
        static method create takes nothing returns thistype
            local Catalog catalog = Catalog.create()
        
            set rec[recc] = catalog
            set recc = recc + 1
            call TimerStart(dest,0,false,function thistype.destroyer)
            
            return catalog
        endmethod
    endstruct
endlibrary
library_once IntTree uses AVL
    struct IntTree extends array
        private method lessThan takes thistype val returns boolean
            return integer(this)<integer(val)
        endmethod
        private method greaterThan takes thistype val returns boolean
            return integer(this)>integer(val)
        endmethod
        
        implement AVL
    endstruct
endlibrary
library_once IntTree2 uses AVL
    struct IntTree2 extends array
        private method lessThan takes thistype val returns boolean
            return integer(this)<integer(val)
        endmethod
        private method greaterThan takes thistype val returns boolean
            return integer(this)>integer(val)
        endmethod
        
        implement AVL
    endstruct
endlibrary
library_once LevelFilter uses IntTree, Table, Catalog, TempCatalog
    struct LevelFilter extends array
        private Table catalogTable
        private IntTree tree
        
        method get takes integer minLevel, integer maxLevel returns Catalog
            local Catalog catalog
            local IntTree level
            
            set level = tree.searchClose(minLevel,false)
            if (0 != level) then
                set catalog = TempCatalog.create()
                
                loop
                    exitwhen level.head or integer(level.value) > maxLevel
                    call catalog.addCatalog(catalogTable[level])
                    set level = level.next
                endloop
                
                return catalog
            endif
            
            return 0
        endmethod
        
        method getCatalog takes integer level returns Catalog
            local Catalog levelCatalog
            
            set levelCatalog = tree.search(level)
            
            if (0 == levelCatalog) then
                set level = tree.addUnique(level)
                
                set levelCatalog = Catalog.create()
                set catalogTable[level] = levelCatalog
                
                return levelCatalog
            endif
            
            return catalogTable[levelCatalog]
        endmethod
        
        static method create takes nothing returns thistype
            local thistype this
            
            set this = IntTree.create()
            
            set tree = this
            set catalogTable = Table.create()
            
            return this
        endmethod
    endstruct
endlibrary
library_once SlotFilter
    struct SlotFilter extends array
        private static hashtable table = InitHashtable()
        private static integer hash = 0
        method operator [] takes integer slot returns integer
            local integer id = LoadInteger(table, this, slot)
            
            if (0 == id) then
                set hash = hash + 1
                call SaveInteger(table, this, slot, hash)
                
                return hash
            endif
            
            return id
        endmethod
        static method operator [] takes integer groupId returns thistype
            return groupId
        endmethod
    endstruct
endlibrary
library LevelGroupSlotVersionCatalog uses LevelFilter, TempCatalog, SlotFilter
    private module GroupFilterInit
        private static method onInit takes nothing returns nothing
            set levelFilter = Table.create()
        endmethod
    endmodule
    
    private struct GroupFilter extends array
        private static integer instanceCount = 0
        private Table groupFilterTable              //groupFilterTable[groupId] -> groupFilter
        private static Table levelFilter            //levelFilter[groupFilter] -> LevelFilter
        private Table groupIdTable                  //groupIdTable[groupFilter] -> groupId
        private Table groupIds                      //group[groupCount] -> groupId
        private integer groupCount
        
        private method getGroupId takes integer groupFilter returns integer
            return groupIdTable[groupFilter]
        endmethod
        
        private method getGroupFilter takes integer groupId returns Catalog
            local GroupFilter groupFilter = groupFilterTable[groupId]
            
            if (0 == groupFilter) then
                set groupFilter = Catalog.create()
                set levelFilter[groupFilter] = LevelFilter.create()
                
                set groupFilterTable[groupId] = groupFilter
                
                set groupIdTable[groupFilter] = groupId
                
                set groupIds[groupCount] = groupId
                set groupCount = groupCount + 1
            endif
            
            return groupFilter
        endmethod
    
        method getCatalog takes integer groupId, integer level returns Catalog
            return LevelFilter(levelFilter[getGroupFilter(groupId)]).getCatalog(level)
        endmethod
        
        method get takes integer groupId, integer minLevel, integer maxLevel returns Catalog
            return getEv(groupId, minLevel, maxLevel)
        endmethod
        
        private method getEv takes integer groupId, integer minLevel, integer maxLevel returns Catalog
            local Catalog catalog
            local CatalogLoop looper
            local GroupFilter groupFilter
            local boolean array hit
            
            set catalog = TempCatalog.create()
            set groupFilter = getGroupFilter(groupId)
            call catalog.addCatalog(LevelFilter(levelFilter[groupFilter]).get(minLevel, maxLevel))
            set looper = CatalogLoop.create(groupFilter, 1)
            loop
                set groupFilter = looper.next
                exitwhen 0 == groupFilter
                if (not hit[groupFilter]) then
                    set hit[groupFilter] = true
                    call catalog.addCatalog(LevelFilter(levelFilter[groupFilter]).get(minLevel, maxLevel))
                endif
            endloop
            
            return catalog
        endmethod
        
        method inherit takes GroupFilter groupFilter returns nothing
            call inheritEv(groupFilter)
        endmethod
        
        private method inheritEv takes GroupFilter groupFilter returns nothing
            local integer groupCount = groupFilter.groupCount
            local integer groupId
            
            local CatalogLoop looper
            local Catalog groupFilterCatalog
            local Catalog oldGroupFilterCatalog
            
            loop
                exitwhen 0 == groupCount
                set groupCount = groupCount - 1
                
                set groupId = groupFilter.groupIds[groupCount]
                set groupFilterCatalog = getGroupFilter(groupId)
                set oldGroupFilterCatalog = groupFilter.getGroupFilter(groupId)
                call groupFilterCatalog.add(oldGroupFilterCatalog)
                call groupFilterCatalog.addCatalog(oldGroupFilterCatalog)
                
                set looper = CatalogLoop.create(oldGroupFilterCatalog, 1)
                loop
                    set oldGroupFilterCatalog = looper.next
                    exitwhen 0 == oldGroupFilterCatalog
                    
                    set oldGroupFilterCatalog = getGroupFilter(groupFilter.groupIdTable[oldGroupFilterCatalog])
                    call groupFilterCatalog.add(oldGroupFilterCatalog)
                    call groupFilterCatalog.addCatalog(oldGroupFilterCatalog)
                endloop
            endloop
        endmethod
        
        static method create takes nothing returns thistype
            local thistype this
            
            set this = instanceCount + 1
            set instanceCount = this
            
            set groupFilterTable = Table.create()
            set groupIdTable = Table.create()
            set groupIds = Table.create()
            set groupCount = 0
            
            return this
        endmethod
        
        method addGroup takes Catalog groupId, Catalog groupId2 returns nothing
            set groupId = getGroupFilter(groupId)
            set groupId2 = getGroupFilter(groupId2)
            call groupId.add(groupId2)
            call groupId.addCatalog(groupId2)
        endmethod
        
        implement GroupFilterInit
    endstruct
    
    private struct VersionFilter extends array
        private static integer instanceCount = 0
        
        private GroupFilter filter
        
        /*
        *   thistype(versionTree.searchClose(ver, true)).filter
        */
        private IntTree2 versionTree
        
        private method createVersion takes nothing returns nothing
            set filter = GroupFilter.create()
            
            if (not IntTree2(this).prev.head) then
                call filter.inherit(thistype(IntTree2(this).prev).filter)
            endif
        endmethod
        
        method findGroupFilter takes integer ver returns GroupFilter
            set this = versionTree.searchClose(ver, true)
            
            if (this == 0) then
                return TempCatalog.create()
            endif
            
            return filter
        endmethod
        
        method getGroupFilter takes thistype ver returns GroupFilter
            set ver = versionTree.addUnique(ver)
            
            if (ver.filter == 0) then
                call ver.createVersion()
            endif
            
            return ver.filter
        endmethod
        
        method get takes integer ver, integer groupId, integer minLevel, integer maxLevel returns Catalog
            return findGroupFilter(ver).get(groupId, minLevel, maxLevel)
        endmethod
        
        method getCatalog takes integer ver, integer groupId, integer level returns Catalog
            return getGroupFilter(ver).getCatalog(groupId, level)
        endmethod
        
        static method create takes nothing returns thistype
            local thistype this = instanceCount + 1
            set instanceCount = this
            
            set versionTree = IntTree2.create()
            
            return this
        endmethod
    endstruct
    
    struct LevelGroupSlotVersionCatalog extends array
        method addGroup takes integer ver, integer groupId, integer groupId2, integer slot returns nothing
            call VersionFilter(this).getGroupFilter(ver).addGroup(SlotFilter[groupId][slot], SlotFilter[groupId2][slot])
        endmethod
        
        method get takes integer ver, integer groupId, integer slot, integer minLevel, integer maxLevel returns Catalog
            return VersionFilter(this).get(ver, SlotFilter[groupId][slot], minLevel, maxLevel)
        endmethod
    
        method add takes integer rawId, integer ver, integer groupId, integer slot, integer level returns nothing
            call VersionFilter(this).getCatalog(ver, SlotFilter[groupId][slot], level).add(rawId)
        endmethod
        
        static method create takes nothing returns thistype
            return VersionFilter.create()
        endmethod
    endstruct
endlibrary