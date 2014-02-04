/**************************************************************************************************************************************************************
*
*   struct LevelVersionCatalog extends array
*
*       static method create takes nothing returns LevelVersionCatalog
*
*       method add takes integer rawId, integer ver, integer level returns nothing
*           -   Adds new item to catalog
*
*                                                         Notes
*           -------------------------------------------------------------------------------------------------------
*           -
*           -   ver is the version of the game that the item was added to
*           -
*           -   level is the level that the hero must be in order to use the item
*           -
*           -------------------------------------------------------------------------------------------------------

*       method get takes integer ver, integer minLevel, integer maxLevel returns Catalog
*           -   Retrieves a temporary catalog (automatically destroyed later)
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
library_once LevelTree uses AVL
    struct LevelTree extends array
        private method lessThan takes thistype val returns boolean
            return integer(this)<integer(val)
        endmethod
        private method greaterThan takes thistype val returns boolean
            return integer(this)>integer(val)
        endmethod
        
        implement AVL
    endstruct
endlibrary
library_once LevelFilter uses LevelTree
    struct LevelFilter extends array
        private Table catalogTable
        private LevelTree tree
        
        method get takes integer minLevel, integer maxLevel returns Catalog
            local Catalog catalog
            local LevelTree level
            
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
            local LevelTree levelCatalog
            
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
            
            set this = LevelTree.create()
            
            set tree = this
            set catalogTable = Table.create()
            
            return this
        endmethod
    endstruct
endlibrary
    
library LevelVersionCatalog uses LevelFilter, TempCatalog
    private struct VersionFilter extends array
        private static integer instanceCount = 0
    
        private Table levelFilterTable
        
        method get takes integer ver, integer minLevel, integer maxLevel returns Catalog
            local Catalog catalog = TempCatalog.create()
            loop
                exitwhen 0 == ver
                call catalog.addCatalog(LevelFilter(levelFilterTable[ver]).get(minLevel, maxLevel))
                set ver = ver - 1
            endloop
            return catalog
        endmethod
        
        method getLevelFilter takes integer ver returns LevelFilter
            if (0 == levelFilterTable[ver]) then
                set levelFilterTable[ver] = LevelFilter.create()
            endif
            
            return levelFilterTable[ver]
        endmethod
        
        method getCatalog takes integer ver, integer level returns Catalog
            return getLevelFilter(ver).getCatalog(level)
        endmethod
        
        static method create takes nothing returns thistype
            local thistype this = instanceCount + 1
            set instanceCount = this
            
            set levelFilterTable = Table.create()
            
            return this
        endmethod
    endstruct
    
    struct LevelVersionCatalog extends array
        private static integer instanceCount = 0
        private static VersionFilter versionFilter
        
        method get takes integer ver, integer minLevel, integer maxLevel returns Catalog
            return versionFilter.get(ver, minLevel, maxLevel)
        endmethod
    
        method add takes integer rawId, integer ver, integer level returns nothing
            call versionFilter.getCatalog(ver, level).add(rawId)
        endmethod
        
        static method create takes nothing returns thistype
            local thistype this = instanceCount + 1
            set instanceCount = this
            
            set versionFilter = VersionFilter.create()
            
            return this
        endmethod
    endstruct
endlibrary