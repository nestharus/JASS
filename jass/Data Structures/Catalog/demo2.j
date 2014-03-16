struct ItemCatalog extends array
    implement Catalog
    
    private static Table itemCharge
    private static Table isPerishable
    
    static method getPerishable takes integer itemTypeId returns boolean
        return isPerishable.boolean[itemTypeId]
    endmethod
    
    static method getMaxCharge takes integer itemTypeId returns integer
        return itemCharge[itemTypeId]
    endmethod
    
    static method addItem takes integer itemTypeId, integer maxCharge, boolean isPerishable returns nothing
        call add(itemTypeId)
        set thistype.itemCharge[itemTypeId] = maxCharge
        set thistype.isPerishable.boolean[itemTypeId] = isPerishable
    endmethod
    
    private static method onInit takes nothing returns nothing
        set catalog = VersionCatalog.create()
        
        set itemCharge = Table.create()
        set isPerishable = Table.create()
        
        /*************************************************************************************************
        *            item id       max charge      isPerishable
        *************************************************************************************************/
        call addItem('totw',       3,              true)
        call addItem('afac',       0,              false)
        call addItem('spsh',       0,              false)
        call addItem('ajen',       0,              false)
        call addItem('bgst',       0,              false)
        call addItem('bspd',       0,              false)
    endmethod
endstruct

struct tests extends array
    private static method print takes nothing returns nothing
        local Catalog catalog
        local CatalogLoop looper
        local integer itemTypeId
        
        set catalog = ItemCatalog.catalog
        
        set looper = CatalogLoop.create(catalog,1)
        loop
            set itemTypeId = looper.next
            exitwhen 0 == itemTypeId
            call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,GetObjectName(itemTypeId) + "(" + I2S(catalog.id(itemTypeId)) + ")")
        endloop
    endmethod
    private static method init takes nothing returns nothing
        call DestroyTimer(GetExpiredTimer())
        
        call print()
    endmethod
    
    private static method onInit takes nothing returns nothing
        call TimerStart(CreateTimer(), 0, false, function thistype.init)
    endmethod
endstruct