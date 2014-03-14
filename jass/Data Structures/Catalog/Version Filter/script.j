/**************************************************************************************************************************************************************
*
*   struct VersionCatalog extends array
*
*       static method create takes nothing returns VersionCatalog
*
*       method add takes integer rawId, integer ver returns nothing
*           -   Adds a new item to the catalog.
*
*                                                         Notes
*           -------------------------------------------------------------------------------------------------------
*           -
*           -   ver is the version of the game that the item was added to
*           -
*           -------------------------------------------------------------------------------------------------------
*
*       method get takes integer ver returns Catalog
*           -   Retrieves the catalog
*
*                                                         Notes
*           -------------------------------------------------------------------------------------------------------
*           -
*           -   ver is the version of the game to retrieve the catalog for. Version 6 would retrieve all catalogs from version 1-6
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
library VersionCatalog uses TempCatalog
    private struct VersionFilter extends array
        private static integer instanceCount = 0
        
        private Table catalogTable
        private integer ver
        private Table prev
        
        private method createVersion takes integer ver returns nothing
            local integer lastVersion = prev[0]
            local Catalog catalog = Catalog.create()
            
            set catalogTable[ver] = catalog
            
            if (lastVersion != 0) then
                call catalog.addCatalog(catalogTable[lastVersion])
            endif
            
            set prev[ver] = lastVersion
            set prev[0] = ver
            
            set this.ver = ver
        endmethod
        
        method get takes integer ver returns Catalog
            if (this.ver < ver) then
                call createVersion(ver)
            endif
            
            return catalogTable[ver]
        endmethod
        
        static method create takes nothing returns thistype
            local thistype this = instanceCount + 1
            set instanceCount = this
            
            set catalogTable = Table.create()
            
            set prev = Table.create()
            
            set ver = 0
            
            return this
        endmethod
    endstruct
    
    struct VersionCatalog extends array
        method get takes integer ver returns Catalog
            return VersionFilter(this).get(ver)
        endmethod
    
        method add takes integer rawId, integer ver returns nothing
            call VersionFilter(this).get(ver).add(rawId)
        endmethod
        
        static method create takes nothing returns thistype
            return VersionFilter.create()
        endmethod
    endstruct
endlibrary