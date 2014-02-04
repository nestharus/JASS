/**************************************************************************************************************************************************************
*
*   struct VersionCatalog extends array
*
*       static method create takes nothing returns VersionCatalog
*
*       method add takes integer id, integer ver returns nothing
*           -   Adds a new item to the catalog.
*
*       method get takes integer ver returns Catalog
*           -   Retrieves catalog for version
*
**************************************************************************************************************************************************************/
library VersionCatalog
    struct VersionCatalog extends array
        private static integer instanceCount = 0
    
        private Table catalogs
        private integer catalogCount
        
        method get takes integer ver returns Catalog
            return catalogs[ver]
        endmethod

        method add takes integer id, integer ver returns nothing
            local Catalog catalog = catalogs[ver]
            
            if (0 == catalog) then
                set catalog = Catalog.create()
                set catalogs[ver] = catalog
                if (1 < ver) then
                    call catalog.addCatalog(catalogs[ver-1])
                endif
            endif
            
            call catalog.add(id)
        endmethod
        
        static method create takes nothing returns thistype
            local thistype this = instanceCount + 1
            set instanceCount = this
            
            set catalogs = Table.create()
            
            return this
        endmethod
    endstruct
endlibrary