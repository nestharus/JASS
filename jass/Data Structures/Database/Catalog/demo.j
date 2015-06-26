//item catalogs
globals
    //random ids to display
    constant integer POTION = '0000'
    constant integer HOOD = '0001'
    constant integer LEATHER_BOOTS = '0002'
    constant integer MAGIC_STAFF = '0003'
    constant integer BOW = '0004'
    constant integer SPELL_SWORD = '0005'
    constant integer RUSTY_SWORD = '0006'
    constant integer SPELL_GLOVES = '0007'
    constant integer LEATHER_GLOVES = '0008'
endglobals
struct HeroCatalog extends array
    //general items that can be used by anyone
    implement Catalog
    
    private static method onInit takes nothing returns nothing
        call add(POTION)
        call add(HOOD)
        call add(LEATHER_BOOTS)
        call add(LEATHER_GLOVES)
    endmethod
endstruct

struct MagicCatalog extends array
    //items that can only be used by heroes with magic
    implement Catalog
    
    private static method onInit takes nothing returns nothing
        call addCatalog(HeroCatalog.catalog)
        
        call add(MAGIC_STAFF)
        call add(SPELL_GLOVES)
    endmethod
endstruct

struct MeleeCatalog extends array
    //can only be used by melee heroes
    implement Catalog
    
    private static method onInit takes nothing returns nothing
        call addCatalog(HeroCatalog.catalog)
        
        call add(RUSTY_SWORD)
    endmethod
endstruct

struct RangedCatalog extends array
    //can only be used by ranged heroes
    implement Catalog
    
    private static method onInit takes nothing returns nothing
        call addCatalog(HeroCatalog.catalog)
        
        call add(BOW)
    endmethod
endstruct

struct PaladinCatalog extends array
    //can only be used by paladins
    implement Catalog
    
    private static method onInit takes nothing returns nothing
        call addCatalog(MagicCatalog.catalog)
        call addCatalog(MeleeCatalog.catalog)
        
        call add(SPELL_SWORD)
    endmethod
endstruct

struct Tester extends array
    private static method run takes nothing returns nothing
        local PaladinCatalog c = 1
        local PaladinCatalog h = 1
        local integer i = c.count
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "Paladin\n------------------")
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "Count: " + I2S(i))
        loop
            set h = c.raw
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 240, A2S(h) + "    " + I2S(h.id))
            exitwhen c == i
            set c = c + 1
        endloop
        call DestroyTimer(GetExpiredTimer())
    endmethod
    private static method onInit takes nothing returns nothing
        call TimerStart(CreateTimer(), 0, false, function thistype.run)
    endmethod
endstruct