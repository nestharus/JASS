/**************************************************************************************************************************************************************
*
*   struct LevelVersionCatalog extends array
*
*       static method create takes nothing returns LevelVersionCatalog
*
*       method add takes integer rawId, integer ver, integer level returns nothing
*           -   Adds a new item to the catalog.
*
*                                                         Notes
*           -------------------------------------------------------------------------------------------------------
*           -
*           -   ver is the version of the game that the item was added to
*           -
*           -------------------------------------------------------------------------------------------------------
*
*       method get takes integer ver, integer minLevel, integer maxLevel returns Catalog
*           -   Builds a temporary catalog (automatically destroyed later)
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
library LevelVersionCatalog uses LevelFilter, TempCatalog, IntTree2
    private struct VersionFilter extends array
        private static integer instanceCount = 0
        
        private LevelFilter filter
        private IntTree2 versionTree
        
        method getLevelFilter takes thistype ver returns LevelFilter
            set ver = versionTree.addUnique(ver)
            
            if (ver.filter == 0) then
                set ver.filter = LevelFilter.create()
            endif
            
            return ver.filter
        endmethod
        
        method get takes integer ver, integer minLevel, integer maxLevel returns Catalog
            local Catalog catalog = TempCatalog.create()
            local IntTree2 node = versionTree.searchClose(ver, true)
            
            if (node == 0) then
                return catalog
            endif
            
            loop
                exitwhen node.head
                
                call catalog.addCatalog(thistype(node).filter.get(minLevel, maxLevel))
                
                set node = node.prev
            endloop
            
            return catalog
        endmethod
        
        method getCatalog takes integer ver, integer level returns Catalog
            return getLevelFilter(ver).getCatalog(level)
        endmethod
        
        static method create takes nothing returns thistype
            local thistype this = instanceCount + 1
            set instanceCount = this
            
            set versionTree = IntTree2.create()
            
            return this
        endmethod
    endstruct
    
    struct LevelVersionCatalog extends array
        method get takes integer ver, integer minLevel, integer maxLevel returns Catalog
            return VersionFilter(this).get(ver, minLevel, maxLevel)
        endmethod
    
        method add takes integer rawId, integer ver, integer level returns nothing
            call VersionFilter(this).getCatalog(ver, level).add(rawId)
        endmethod
        
        static method create takes nothing returns thistype
            return VersionFilter.create()
        endmethod
    endstruct
endlibrary