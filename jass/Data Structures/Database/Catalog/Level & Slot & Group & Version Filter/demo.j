struct ItemCatalog extends array
    private static delegate LevelGroupSlotVersionCatalog catalog
    
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
    
    static method add takes integer itemTypeId, integer ver, integer groupId, integer slotId, integer level, integer maxCharge, boolean isPerishable returns nothing
        call catalog.add(itemTypeId, ver, groupId, slotId, level)
        set thistype.itemCharge[itemTypeId] = maxCharge
        set thistype.isPerishable.boolean[itemTypeId] = isPerishable
        set thistype.itemLevel[itemTypeId] = level
    endmethod
    
    private static method init takes nothing returns nothing
        local integer cver
        
        call DestroyTimer(GetExpiredTimer())
        
        set catalog = LevelGroupSlotVersionCatalog.create()
        
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
            *             version    parent group   sub group   slot
            *************************************************************************************************/
            call addGroup(cver,     'Hpal',         1,          1)
            
            /*************************************************************************************************
            *        item id    version     group id    slot id   level   max charge      isPerishable
            *************************************************************************************************/
            call add('totw',    cver,       1,          1,          1,      3,              true)
        
        /***********************************************************************
        *
        *   Version 2
        *
        ***********************************************************************/
        set cver = 2
            /*************************************************************************************************
            *             version    parent group   sub group   slot
            *************************************************************************************************/
            call addGroup(cver,        'Hmkg',         1,       1)
            
            /*************************************************************************************************
            *        item id    version     group id    slot id   level   max charge      isPerishable
            *************************************************************************************************/
            call add('afac',    cver,       1,          1,        2,      0,              false)
        
        /***********************************************************************
        *
        *   Version 3
        *
        ***********************************************************************/
        set cver = 3
            /*************************************************************************************************
            *             version    parent group   sub group   slot
            *************************************************************************************************/
            call addGroup(cver,        'Hamg',         1,       1)
            
            /*************************************************************************************************
            *        item id    version     group id    slot id   level   max charge      isPerishable
            *************************************************************************************************/
            call add('spsh',    cver,       1,          1,        3,        0,              false)
        
        /***********************************************************************
        *
        *   Version 4
        *
        ***********************************************************************/
        set cver = 4
            /*************************************************************************************************
            *             version    parent group   sub group   slot
            *************************************************************************************************/
            call addGroup(cver,        'Hblm',         2,       1)
            
            /*************************************************************************************************
            *        item id    version     group id    slot id   level   max charge      isPerishable
            *************************************************************************************************/
            call add('ajen',    cver,       2,          1,        4,      0,              false)
        
        /***********************************************************************
        *
        *   Version 5
        *
        ***********************************************************************/
        set cver = 5
            /*************************************************************************************************
            *             version    parent group   sub group   slot
            *************************************************************************************************/
            call addGroup(cver,        'Obla',         2,       1)
            
            /*************************************************************************************************
            *        item id    version     group id    slot id   level   max charge      isPerishable
            *************************************************************************************************/
            call add('bgst',    cver,       2,          1,        5,      0,              false)
        
        /***********************************************************************
        *
        *   Version 6
        *
        ***********************************************************************/
        set cver = 6
            /*************************************************************************************************
            *             version    parent group   sub group   slot
            *************************************************************************************************/
            call addGroup(cver,        'Ofar',         2,       1)
            
            /*************************************************************************************************
            *        item id    version     group id    slot id   level   max charge      isPerishable
            *************************************************************************************************/
            call add('bspd',    cver,       2,          1,        6,      0,              false)
    endmethod
    
    private static method onInit takes nothing returns nothing
        call TimerStart(CreateTimer(), 0, false, function thistype.init)
    endmethod
endstruct

struct tests extends array
    private static method print takes integer ver, integer groupId, integer slot, integer minLevel, integer maxLevel returns nothing
        local Catalog catalog
        local CatalogLoop looper
        local integer itemTypeId
        
        local string out
        
        set catalog = ItemCatalog.get(ver, groupId, slot, minLevel, maxLevel)
        
        set looper = CatalogLoop.create(catalog,1)
        loop
            set itemTypeId = looper.next
            exitwhen 0 == itemTypeId
            
            set out = "Version " + I2S(ver) + ": "
            set out = out + GetObjectName(groupId) + " has "
            set out = out + GetObjectName(itemTypeId) + "(" + I2S(catalog.id(itemTypeId)) + ")"
            set out = out + " at level " + I2S(ItemCatalog.getLevel(itemTypeId))
            set out = out + " in slot " + I2S(slot)
            set out = out + " for levels [" + I2S(minLevel)+","+I2S(maxLevel) + "]"
            call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000, out)
        endloop
    endmethod
    
    private static method init takes nothing returns nothing
        call DestroyTimer(GetExpiredTimer())
        
        //slots are just hash, so they don't require testing
        /*
        *   Hpal
        *   Hmkg
        *   Hamg
        *   Hbml
        *   Obla
        *   Ofar
        *   1
        *   2
        */
        call print(1, 'Hpal', 1, 1, 10)     //check version
        call print(2, 'Hpal', 1, 1, 10)     //check version
        call print(3, 'Hpal', 1, 1, 10)     //check version
        call print(4, 'Hpal', 1, 1, 10)     //check version, rest are like version 4
        call print(1, 'Hmkg', 1, 1, 10)        //check version
        call print(3, 'Hmkg', 1, 1, 10)        //check version
        call print(4, 'Hmkg', 1, 1, 10)        //check version, other heroes are ok
        call print(1, 1, 1, 1, 10)          //check group with items
    endmethod
    
    private static method onInit takes nothing returns nothing
        call TimerStart(CreateTimer(), .1, false, function thistype.init)
    endmethod
endstruct