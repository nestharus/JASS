/**************************************************************************************************************************************************************
*
*   struct GroupVersionCatalog extends array
*
*       static method create takes nothing returns GroupVersionCatalog
*
*       method add takes integer rawId, integer ver, integer groupId returns nothing
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
*           -   Adds groupId to groupId2 in version ver.
*
*                                                         Notes
*           -------------------------------------------------------------------------------------------------------
*           -
*           -   groupId2 will be able to use any items that groupId is able to use.
*           -
*           -   This will only be effective from ver and up, but groupId2 will be able to use anything groupId can use from
*           -   any version.
*           -
*           -------------------------------------------------------------------------------------------------------
*
*       method get takes integer ver, integer groupId returns Catalog
*           -   Retrieves a temporary catalog (automatically destroyed later)
*
*                                                         Notes
*           -------------------------------------------------------------------------------------------------------
*           -
*           -   ver is the version of the game to retrieve the catalog for. Version 6 would retrieve all catalogs from version 1-6
*           -
*           -   groupId is the group to retrieve the catalog for. If group 'Hpal' had group 1 added to it and 'Hpal' was passed in, this
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
library GroupVersionCatalog uses TempCatalog
    private module GroupFilterInit
        private static method onInit takes nothing returns nothing
            set groupCatalog = Table.create()
        endmethod
    endmodule
    
    private struct GroupFilter extends array
        private static integer instanceCount = 0
        private Table groupFilterTable
        private static Table groupCatalog
        private Table groupIdTable
        
        method getGroupFilter takes integer groupId returns Catalog
            local GroupFilter groupFilter = groupFilterTable[groupId]
            
            if (0 == groupFilter) then
                set groupFilter = Catalog.create()
                set groupCatalog[groupFilter] = Catalog.create()
                
                call Catalog(groupFilter).add(groupFilter)
                set groupFilterTable[groupId] = groupFilter
                
                set groupIdTable[groupFilter] = groupId
            endif
            
            return groupFilter
        endmethod
        
        method getFilter takes integer groupId returns Catalog
            return groupFilterTable[groupId]
        endmethod
        
        method getGroupId takes integer groupFilter returns integer
            return groupIdTable[groupFilter]
        endmethod
        
        method getCatalog takes integer groupId returns Catalog
            return groupCatalog[getGroupFilter(groupId)]
        endmethod
        
        method get takes integer groupId returns Catalog
            local Catalog catalog
            local CatalogLoop looper
            local GroupFilter groupFilter
            local boolean array hit
            
            set catalog = TempCatalog.create()
            
            set groupFilter = getFilter(groupId)
            set looper = CatalogLoop.create(groupFilter,1)
            loop
                set groupFilter = looper.next
                exitwhen 0 == groupFilter
                if (not hit[groupFilter]) then
                    set hit[groupFilter] = true
                    call catalog.addCatalog(groupCatalog[groupFilter])
                endif
            endloop
            
            return catalog
        endmethod
        
        method addGroup takes integer groupId, integer groupId2 returns nothing
            call getGroupFilter(groupId).addCatalog(getGroupFilter(groupId2))
        endmethod
        
        static method create takes nothing returns thistype
            local thistype this
            
            set this = instanceCount + 1
            set instanceCount = this
            
            set groupFilterTable = Table.create()
            set groupIdTable = Table.create()
            
            return this
        endmethod
        
        implement GroupFilterInit
    endstruct
    private struct VersionFilter extends array
        private static integer instanceCount = 0
        
        private Table groupFilterTable
        
        method get takes integer ver, integer groupId returns Catalog
            local Catalog catalog = TempCatalog.create()
            call catalog.addCatalog(GroupFilter(groupFilterTable[ver]).get(groupId))
            return catalog
        endmethod
        
        method getGroup takes integer ver returns GroupFilter
            if (0 == groupFilterTable[ver]) then
                set groupFilterTable[ver] = GroupFilter.create()
            endif
            
            return groupFilterTable[ver]
        endmethod
        
        method getCatalog takes integer ver, integer groupId returns integer
            return getGroup(ver).getCatalog(groupId)
        endmethod
        
        static method create takes nothing returns thistype
            local thistype this = instanceCount + 1
            set instanceCount = this
            
            set groupFilterTable = Table.create()
            
            return this
        endmethod
    endstruct
    
    private module ItemCatalogInit
        private static method onInit takes nothing returns nothing
            set eUpdate = CreateTrigger()
            call TriggerAddCondition(eUpdate, Condition(function thistype.update))
        endmethod
    endmodule
    struct GroupVersionCatalog extends array
        private static integer instanceCount = 0
    
        private VersionFilter versionFilter
        
        private Table groupTable
        private Table groups
        private integer groupCount
        private integer ver
        
        private Table groupAddTable
        
        private static trigger eUpdate
        private static integer toUpdate
        
        private static method update takes nothing returns boolean
            local thistype this = toUpdate
            local integer xver = ver - 1
            local integer c = groupCount
            local CatalogLoop looper
            local integer groupId
            local Catalog catalog
            local Catalog catalogNew
            loop
                exitwhen 0 == c
                set c = c - 1
                
                call versionFilter.getGroup(ver).getGroupFilter(groups[c]).addCatalog(versionFilter.getGroup(xver).getGroupFilter(groups[c]))
                
                set looper = CatalogLoop.create(groupAddTable[groups[c]], 1)
                loop
                    set groupId = looper.next
                    exitwhen 0 == groupId
                    call versionFilter.getGroup(ver).addGroup(groups[c], groupId)
                endloop
            endloop
            return false
        endmethod
        
        method addGroup takes integer ver, integer groupId, integer groupId2 returns nothing
            call versionFilter.getGroup(ver).addGroup(groupId, groupId2)
            if (this.ver < ver) then
                set this.ver = ver
                if (1 < ver) then
                    set toUpdate = this
                    call TriggerEvaluate(eUpdate)
                endif
            endif
            if (not groupTable.boolean.has(groupId)) then
                set groupAddTable[groupId] = Catalog.create()
                set groupTable.boolean[groupId] = true
                set groups[groupCount] = groupId
                set groupCount = groupCount + 1
            endif
            if (not groupTable.boolean.has(groupId2)) then
                set groupAddTable[groupId2] = Catalog.create()
                set groupTable.boolean[groupId2] = true
                set groups[groupCount] = groupId2
                set groupCount = groupCount + 1
            endif
            call CatalogAdd(groupAddTable[groupId], groupId2)
        endmethod
        
        method get takes integer ver, integer groupId returns Catalog
            return versionFilter.get(ver, groupId)
        endmethod
    
        method add takes integer rawId, integer ver, integer groupId returns nothing
            local Catalog catalog = versionFilter.getCatalog(ver, groupId)
            
            if (this.ver < ver) then
                set this.ver = ver
                if (1 < ver) then
                    set toUpdate = this
                    call TriggerEvaluate(eUpdate)
                endif
            endif
            if (not groupTable.boolean.has(groupId)) then
                set groupAddTable[groupId] = Catalog.create()
                set groupTable.boolean[groupId] = true
                set groups[groupCount] = groupId
                set groupCount = groupCount + 1
            endif
            
            call catalog.add(rawId)
        endmethod
        
        static method create takes nothing returns thistype
            local thistype this = instanceCount + 1
            set instanceCount = this
            
            set versionFilter = VersionFilter.create()
            
            set groupTable = Table.create()
            set groups = Table.create()
            set groupAddTable = Table.create()
            
            return this
        endmethod
    
        implement ItemCatalogInit
    endstruct
endlibrary