struct ItemCatalog extends array
    private static delegate VersionCatalog catalog
    
    private static Table itemCharge
    private static Table isPerishable
    
    static method getPerishable takes integer itemTypeId returns boolean
        return isPerishable.boolean[itemTypeId]
    endmethod
    
    static method getMaxCharge takes integer itemTypeId returns integer
        return itemCharge[itemTypeId]
    endmethod
    
    static method add takes integer itemTypeId, integer ver, integer maxCharge, boolean isPerishable returns nothing
        call catalog.add(itemTypeId, ver)
        set thistype.itemCharge[itemTypeId] = maxCharge
        set thistype.isPerishable.boolean[itemTypeId] = isPerishable
    endmethod
    
    private static method onInit takes nothing returns nothing
        local integer cver
        
        set catalog = VersionCatalog.create()
        
        set itemCharge = Table.create()
        set isPerishable = Table.create()
        
        /***********************************************************************
        *
        *   Version 1
        *
        ***********************************************************************/
        set cver = 1
            /*************************************************************************************************
            *        item id    version     max charge      isPerishable
            *************************************************************************************************/
            call add('totw',    cver,       3,              true)
        
        /***********************************************************************
        *
        *   Version 2
        *
        ***********************************************************************/
        set cver = 2
            /*************************************************************************************************
            *        item id    version     max charge      isPerishable
            *************************************************************************************************/
            call add('afac',    cver,       0,              false)
            
        /***********************************************************************
        *
        *   Version 3
        *
        ***********************************************************************/
        set cver = 3
            /*************************************************************************************************
            *        item id    version     max charge      isPerishable
            *************************************************************************************************/
            call add('spsh',    cver,       0,              false)
        
        /***********************************************************************
        *
        *   Version 4
        *
        ***********************************************************************/
        set cver = 4
            /*************************************************************************************************
            *        item id    version     max charge      isPerishable
            *************************************************************************************************/
            call add('ajen',    cver,       0,              false)
        
        /***********************************************************************
        *
        *   Version 5
        *
        ***********************************************************************/
        set cver = 5
            /*************************************************************************************************
            *        item id    version     max charge      isPerishable
            *************************************************************************************************/
            call add('bgst',    cver,       0,              false)
        
        /***********************************************************************
        *
        *   Version 6
        *
        ***********************************************************************/
        set cver = 6
            /*************************************************************************************************
            *        item id    version     max charge      isPerishable
            *************************************************************************************************/
            call add('bspd',    cver,       0,              false)
    endmethod
endstruct

struct tests extends array
    private static method print takes integer ver returns nothing
        local Catalog catalog
        local CatalogLoop looper
        local integer itemTypeId
        
        set catalog = ItemCatalog.get(ver)
        
        set looper = CatalogLoop.create(catalog,1)
        loop
            set itemTypeId = looper.next
            exitwhen 0 == itemTypeId
            call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,I2S(ver)+": "+GetObjectName(itemTypeId) + "(" + I2S(catalog.id(itemTypeId)) + ")")
        endloop
    endmethod
    
    private static method init takes nothing returns nothing
        call DestroyTimer(GetExpiredTimer())
        
        call print(1)
        call print(2)
        call print(3)
        call print(4)
        call print(5)
        call print(6)
    endmethod
    
    private static method onInit takes nothing returns nothing
        call TimerStart(CreateTimer(), 0, false, function thistype.init)
    endmethod
endstruct