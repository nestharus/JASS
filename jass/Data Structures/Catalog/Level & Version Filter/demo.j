struct ItemCatalog extends array
    private static delegate LevelVersionCatalog catalog
    
    private static Table itemCharge
    private static Table isPerishable
    private static Table itemLevel
    
    static method getPerishable takes integer itemTypeId returns boolean
        return isPerishable.boolean[itemTypeId]
    endmethod
    
    static method getMaxCharge takes integer itemTypeId returns integer
        return itemCharge[itemTypeId]
    endmethod
    
    static method getLevel takes integer itemTypeId returns integer
        return itemLevel[itemTypeId]
    endmethod
    
    static method add takes integer itemTypeId, integer ver, integer level, integer maxCharge, boolean isPerishable returns nothing
        call catalog.add(itemTypeId, ver, level)
        set thistype.itemCharge[itemTypeId] = maxCharge
        set thistype.isPerishable.boolean[itemTypeId] = isPerishable
        set thistype.itemLevel[itemTypeId] = level
    endmethod
    
    private static method onInit takes nothing returns nothing
        local integer cver
        
        set catalog = LevelVersionCatalog.create()
        
        set itemCharge = Table.create()
        set isPerishable = Table.create()
        set itemLevel = Table.create()
        
        /***********************************************************************
        *
        *   Version 1
        *
        ***********************************************************************/
        set cver = 1
            /*************************************************************************************************
            *        item id    version     level   max charge      isPerishable
            *************************************************************************************************/
            call add('totw',    cver,       1,      3,              true)
        
        /***********************************************************************
        *
        *   Version 2
        *
        ***********************************************************************/
        set cver = 2
            /*************************************************************************************************
            *        item id    version     level   max charge      isPerishable
            *************************************************************************************************/
            call add('afac',    cver,       2,      0,              false)
        
        /***********************************************************************
        *
        *   Version 3
        *
        ***********************************************************************/
        set cver = 3
            /*************************************************************************************************
            *        item id    version     level   max charge      isPerishable
            *************************************************************************************************/
            call add('spsh',    cver,       3,      0,              false)
        
        /***********************************************************************
        *
        *   Version 4
        *
        ***********************************************************************/
        set cver = 4
            /*************************************************************************************************
            *        item id    version     level   max charge      isPerishable
            *************************************************************************************************/
            call add('ajen',    cver,       4,      0,              false)
        
        /***********************************************************************
        *
        *   Version 5
        *
        ***********************************************************************/
        set cver = 5
            /*************************************************************************************************
            *        item id    version     level   max charge      isPerishable
            *************************************************************************************************/
            call add('bgst',    cver,       5,      0,              false)
        
        /***********************************************************************
        *
        *   Version 6
        *
        ***********************************************************************/
        set cver = 6
            /*************************************************************************************************
            *        item id    version     level   max charge      isPerishable
            *************************************************************************************************/
            call add('bspd',    cver,       6,      0,              false)
    endmethod
endstruct

struct tests extends array
    private static method print takes integer ver, integer minLevel, integer maxLevel returns nothing
        local Catalog catalog
        local CatalogLoop looper
        local integer itemTypeId
        
        set catalog = ItemCatalog.get(ver, minLevel, maxLevel)
        
        set looper = CatalogLoop.create(catalog,1)
        loop
            set itemTypeId = looper.next
            exitwhen 0 == itemTypeId
            call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,GetObjectName(itemTypeId)+" at level "+I2S(ItemCatalog.getLevel(itemTypeId))+" for levels ["+I2S(minLevel)+","+I2S(maxLevel)+"]")
        endloop
    endmethod
    private static method init takes nothing returns nothing
        call DestroyTimer(GetExpiredTimer())
        
        call print(1, 1, 10)
        call print(2, 1, 10)
        call print(3, 1, 10)
        call print(4, 1, 10)
        call print(5, 1, 10)
        call print(6, 1, 10)
    endmethod
    
    private static method onInit takes nothing returns nothing
        call TimerStart(CreateTimer(), 0, false, function thistype.init)
    endmethod
endstruct