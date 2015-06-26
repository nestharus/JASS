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
library VersionCatalog uses TempCatalog, IntTree2
    private struct VersionFilter extends array
        private static integer instanceCount = 0
        
        private Catalog catalog
        private IntTree2 versionTree
        
        private method createVersion takes nothing returns nothing
            set catalog = Catalog.create()
            
            if (not IntTree2(this).prev.head) then
                call catalog.addCatalog(thistype(IntTree2(this).prev).catalog)
            endif
        endmethod
        
        method get takes integer ver returns Catalog
            set this = versionTree.searchClose(ver, true)
            
            if (this == 0) then
                return TempCatalog.create()
            endif
            
            return catalog
        endmethod
        
        method getCatalog takes thistype ver returns Catalog
            set ver = versionTree.addUnique(ver)
            
            if (ver.catalog == 0) then
                call ver.createVersion()
            endif
            
            return ver.catalog
        endmethod
        
        static method create takes nothing returns thistype
            local thistype this = instanceCount + 1
            set instanceCount = this
            
            set versionTree = IntTree2.create()
            
            return this
        endmethod
    endstruct
    
    struct VersionCatalog extends array
        method get takes integer ver returns Catalog
            return VersionFilter(this).get(ver)
        endmethod
    
        method add takes integer rawId, integer ver returns nothing
            call VersionFilter(this).getCatalog(ver).add(rawId)
        endmethod
        
        static method create takes nothing returns thistype
            return VersionFilter.create()
        endmethod
    endstruct
endlibrary