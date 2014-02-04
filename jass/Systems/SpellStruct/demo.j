library MyLifeSteal uses SpellStruct, Tt
    private struct LifeSteal extends array
        static constant real TIMEOUT=.5

        real damage
        UnitIndex source
        UnitIndex target

        implement CTQ
        implement CTQExpire
            call UnitDamageTarget(GetUnitById(source),GetUnitById(target),damage,false,false,ATTACK_TYPE_MAGIC,DAMAGE_TYPE_MAGIC,WEAPON_TYPE_WHOKNOWS)
            call SetWidgetLife(GetUnitById(source),GetWidgetLife(GetUnitById(source))+damage)
        implement CTQNull
        implement CTQEnd
        
        static method allocate takes real time, real intervalDamage, UnitIndex source, UnitIndex target returns thistype
            local thistype this = create()
            
            set damage = intervalDamage*TIMEOUT
            set this.target = target
            set this.source = source
            call source.lock()
            call target.lock()
            
            return this
        endmethod

        method deallocate takes nothing returns nothing
            call source.unlock()
            call target.unlock()
            call destroy()
        endmethod
    endstruct
    
    private struct Deployer extends array
        private static constant real TIME_PER_LEVEL = 6
        private static constant real DAMAGE_PER_LEVEL = 10
        private static constant integer ABILITY_ID='lif1'

        private LifeSteal lifeSteal

        private method onEffect takes nothing returns nothing
            set lifeSteal = LifeSteal.allocate/*
            */(/*
                */GetUnitAbilityLevel(caster,GetSpellAbilityId())*TIME_PER_LEVEL,/*
                */GetUnitAbilityLevel(caster,GetSpellAbilityId())*DAMAGE_PER_LEVEL,/*
                */this,/*
                */GetUnitUserData(target.unit)/*
            */)
        endmethod

        private method onEndCast takes nothing returns nothing
            call lifeSteal.deallocate()
        endmethod

        implement SpellStruct
    endstruct
endlibrary