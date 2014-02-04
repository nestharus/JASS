struct Tester extends array
    /*
    *   With Spell and Spell Struct, complex and efficient spells are very easy to craft
    */
    private static method cast takes nothing returns nothing
        local Spell spell = Spell.create(null, 0, 0, 0, 270)
    
        /*
        *   Spells can be reused. Spells can act both as dummies and as spells themselves.
        *   Spells can also be spawned from dummies.
        *
        *   The great thing about spell reuse is that it allows heroes to cast multiple spells at once.
        *   Let's say that you have 5 spells that are all over time things like moonshower. You can run
        *   all of them at once by assigning 1 permanent dummy for each spell on the hero. The dummies
        *   can then be reused.
        *
        *   Of course, because spells can act both as spells and dummies, a spell effect can spawn other
        *   spell effects and so on.
        */
        set spell.abilityId = 'AHtc'
        set spell.abilityLevel = 2
        set spell.abilityOrder = 852096
        
        call spell.cast()
    endmethod
    
    private static method init takes nothing returns nothing
        call UnitAddAbility(CreateUnit(Player(0), 'hpea', 0, 0, 270), 'Avul')
        call PanCameraToTimed(0, 0, 0)
        
        call TimerStart(CreateTimer(), .3, true, function thistype.cast)
    endmethod
    
    private static method onInit takes nothing returns nothing
        call TimerStart(CreateTimer(),0,false,function thistype.init)
    endmethod
    
    private static constant integer ABILITY_ID = 'AHtc'
    
    private method onEndCast takes nothing returns nothing
        call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"Dummy Caster: "+I2S(this))
        
        call Spell(this).destroy()
    endmethod
    
    implement SpellStruct
endstruct