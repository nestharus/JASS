/**************************************************************************************************************************************************************
*
*   struct LevelGroupVersionCatalog extends array
*
*       static method create takes nothing returns LevelGroupVersionCatalog
*
*       method add takes integer rawId, integer ver, integer groupId, integer level returns nothing
*           -   Adds a new item to the catalog.
*
*                                                         Notes
*           -------------------------------------------------------------------------------------------------------
*           -
*           -   ver is the version of the game that the item was added to
*           -
*           -   groupId is the group that can use the item. The group may be a specific unit or a group of units.
*           -
*           -------------------------------------------------------------------------------------------------------
*
*       method addGroup takes integer ver, integer groupId, integer groupId2 returns nothing
*           -   Adds groupId2 to groupId in version ver.
*
*                                                         Notes
*           -------------------------------------------------------------------------------------------------------
*           -
*           -   groupId will be able to use any items that groupId2 is able to use
*           -
*           -   This will only be effective from ver and up, but groupId will be able to use anything groupId2 can use from
*           -   any version.
*           -
*           -------------------------------------------------------------------------------------------------------
*
*       method get takes integer ver, integer groupId, integer minLevel, integer maxLevel returns Catalog
*           -   Builds a temporary catalog (automatically destroyed later)
*
*                                                         Notes
*           -------------------------------------------------------------------------------------------------------
*           -
*           -   ver is the version of the game to retrieve the catalog for. Version 6 would retrieve all catalogs from version 1-6
*           -
*           -   groupId is the group to retrieve the catalog for in a slot. If group 'Hpal' had group 1 added to it and 'Hpal' was passed in, this
*           -   would return the catalogs for both 'Hpal' and group 1.
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
                set level = tree.add(level)
                
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
library LevelGroupVersionCatalog uses LevelFilter, TempCatalog
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
        
        private Table groupFilterTable
        private integer ver
        private Table prev
        
        private method createVersion takes integer ver returns nothing
            local integer lastVersion = prev[0]
            local GroupFilter filter = GroupFilter.create()
        
            set groupFilterTable[ver] = filter
            
            if (lastVersion != 0) then
                call filter.inherit(groupFilterTable[lastVersion])
            endif
            
            set prev[ver] = lastVersion
            set prev[0] = ver
            
            set this.ver = ver
        endmethod
        
        method getGroupFilter takes integer ver returns GroupFilter
            if (this.ver < ver) then
                call createVersion(ver)
            endif
            
            return groupFilterTable[ver]
        endmethod
        
        method get takes integer ver, integer groupId, integer minLevel, integer maxLevel returns Catalog
            return getGroupFilter(ver).get(groupId, minLevel, maxLevel)
        endmethod
        
        method getCatalog takes integer ver, integer groupId, integer level returns Catalog
            return getGroupFilter(ver).getCatalog(groupId, level)
        endmethod
        
        static method create takes nothing returns thistype
            local thistype this = instanceCount + 1
            set instanceCount = this
            
            set groupFilterTable = Table.create()
            
            set prev = Table.create()
            
            set ver = 0
            
            return this
        endmethod
    endstruct
    
    struct LevelGroupVersionCatalog extends array
        method addGroup takes integer ver, integer groupId, integer groupId2 returns nothing
            call VersionFilter(this).getGroupFilter(ver).addGroup(groupId, groupId2)
        endmethod
        
        method get takes integer ver, integer groupId, integer minLevel, integer maxLevel returns Catalog
            return VersionFilter(this).get(ver, groupId, minLevel, maxLevel)
        endmethod
    
        method add takes integer rawId, integer ver, integer groupId, integer level returns nothing
            call VersionFilter(this).getCatalog(ver, groupId, level).add(rawId)
        endmethod
        
        static method create takes nothing returns thistype
            return VersionFilter.create()
        endmethod
    endstruct
endlibrary