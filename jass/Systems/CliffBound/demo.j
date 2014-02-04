struct tester extends array
    private static method onHit takes nothing returns boolean
        call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, GetPlayerName(GetOwningPlayer(GetHitCliffUnit())) + " hit a cliff")
        return false
    endmethod
    
    private static method onInit takes nothing returns nothing
        call OnHitCliff(Condition(function thistype.onHit))
    endmethod
endstruct