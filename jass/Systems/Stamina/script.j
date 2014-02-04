library Stamina /* v2.0.0.0
    *************************************************************************************
    *
    *   Handles unit stamina for high quality maps. Can add a whole new level of gameplay
    *   and strategy to maps. For example, units becoming exhausted after fighting for a
    *   long period of time.
    *
    ************************************************************************************
    *
    *    */uses/*
    *
    *        */ UnitMovement    /*  hiveworkshop.com/forums/submissions-414/system-unit-movement-201449/
    *        */ Table           /*  hiveworkshop.com/forums/jass-functions-413/snippet-new-table-188084/
    *        */ Event           /*  hiveworkshop.com/forums/submissions-414/snippet-event-186555/
    *
    ************************************************************************************
    *
    *   function SetUnitStaminaById takes UnitIndex index, real value returns nothing
    *   function SetUnitStaminaRegenById takes UnitIndex index, real value returns nothing
    *   function SetUnitStaminaCostById takes UnitIndex index, real value returns nothing
    *   function SetUnitStaminaMaxById takes UnitIndex index, real value returns nothing
    *
    *   function GetUnitStaminaById takes UnitIndex index returns real
    *   function GetUnitStaminaRegenById takes UnitIndex index returns real
    *   function GetUnitStaminaCostById takes UnitIndex index returns real
    *   function GetUnitStaminaMaxById takes UnitIndex index returns real
    *
    *   function SetUnitTypeStaminaRegen takes integer unitTypeId, real value returns real
    *   function SetUnitTypeStaminaCost takes integer unitTypeId, real value returns real
    *   function SetUnitTypeStaminaMax takes integer unitTypeId, real value returns real
    *
    *   function GetUnitTypeStaminaRegen takes integer unitTypeId returns nothing
    *   function GetUnitTypeStaminaCost takes integer unitTypeId returns nothing
    *   function GetUnitTypeStaminaMax takes integer unitTypeId returns nothing
    *
    *   function SetUnitTypeStaminaRegenForPlayer takes integer unitTypeId, integer playerId, real value returns nothing
    *   function SetUnitTypeStaminaCostForPlayer takes integer unitTypeId, integer playerId, real value returns nothing
    *   function SetUnitTypeStaminaMaxForPlayer takes integer unitTypeId, integer playerId, real value returns nothing
    *
    *   function GetUnitTypeStaminaRegenForPlayer takes integer unitTypeId, integer playerId returns real
    *   function GetUnitTypeStaminaCostForPlayer takes integer unitTypeId, integer playerId returns real
    *   function GetUnitTypeStaminaMaxForPlayer takes integer unitTypeId, integer playerId returns real
    *
    *   struct StaminaUnits extends array
    *
    *       readonly thistype next
    *       readonly thistype prev
    *
    ************************************************************************************/
    globals
        private group enumGroup = CreateGroup()
        
        private Event onStaminaChange
    endglobals
    
    private keyword Stamina
    private keyword add
    private keyword remove
    private keyword added
    
    struct StaminaUnits extends array
        readonly boolean added
        readonly thistype next
        readonly thistype prev
        
        method add takes nothing returns nothing
            if (added) then
                return
            endif
            
            set added = true
            set prev = thistype(0).prev
            set next = 0
            set thistype(0).prev.next = this
            set thistype(0).prev = this
        endmethod
        
        method remove takes nothing returns nothing
            if (not added) then
                return
            endif
            
            set added = false
        
            set prev.next = next
            set next.prev = prev
        endmethod
    endstruct
    
    private struct StationaryList extends array
        readonly boolean added
        readonly thistype next
        readonly thistype prev
        
        method add takes nothing returns nothing
            if (added or IsUnitNativelyMovingById(this)) then
                return
            endif
            
            set added = true
            set prev = thistype(0).prev
            set next = 0
            set thistype(0).prev.next = this
            set thistype(0).prev = this
            
            call StaminaUnits(this).add()
        endmethod
        
        method remove takes nothing returns nothing
            if (not added) then
                return
            endif
            
            set added = false
        
            set prev.next = next
            set next.prev = prev
            
            call StaminaUnits(this).remove()
        endmethod
    endstruct
    
    private struct MovementList extends array
        readonly boolean added
        readonly thistype next
        readonly thistype prev
        
        method add takes nothing returns nothing
            if (added or not IsUnitNativelyMovingById(this)) then
                return
            endif
            
            set added = true
            set prev = thistype(0).prev
            set next = 0
            set thistype(0).prev.next = this
            set thistype(0).prev = this
            
            call StaminaUnits(this).add()
        endmethod
        
        method remove takes nothing returns nothing
            if (not added) then
                return
            endif
            
            set added = false
            
            set prev.next = next
            set next.prev = prev
            
            call StaminaUnits(this).remove()
        endmethod
    endstruct
    
    private struct Stamina extends array
        private real valueT
        private real regenT
        private real costT
        private real maxT
        
        method operator value takes nothing returns real
            return valueT
        endmethod
        
        method operator value= takes real v returns nothing
            if (v > maxT) then
                set valueT = maxT
                return
            endif
            
            if (0 > v) then
                set valueT = 0
                return
            endif
            
            set valueT = v
        endmethod
        
        method operator regen takes nothing returns real
            return regenT
        endmethod
        method operator regen= takes real v returns nothing
            set regenT = v
            
            if (0 == v or 0 == maxT) then
                call StationaryList(this).remove()
            else
                call StationaryList(this).add()
            endif
        endmethod
        
        method operator cost takes nothing returns real
            return costT
        endmethod
        method operator cost= takes real v returns nothing
            set costT = v
            
            if (0 == v or 0 == maxT) then
                call MovementList(this).remove()
            else
                call MovementList(this).add()
            endif
        endmethod
        
        method operator max takes nothing returns real
            return maxT
        endmethod
        method operator max= takes real v returns nothing
            set maxT = v
            
            if (0 == v) then
                call MovementList(this).remove()
                call StationaryList(this).remove()
            else
                call MovementList(this).add()
                call StationaryList(this).add()
            endif
        endmethod
    endstruct
    
    private struct StaminaType extends array
        private static Table regenT
        private static Table costT
        private static Table maxT
        
        private static method onInit takes nothing returns nothing
            set regenT = Table.create()
            set costT = Table.create()
            set maxT = Table.create()
        endmethod
        
        method operator regen takes nothing returns real
            return regenT.real[this]
        endmethod
        method operator regen= takes real new returns nothing
            local unit u
            local real old = regen
            local Stamina stamina
            
            set regenT.real[this] = new
            
            call GroupEnumUnitsOfType(enumGroup, GetObjectName(this), null)
            loop
                set u = FirstOfGroup(enumGroup)
                exitwhen null == u
                
                call GroupRemoveUnit(enumGroup, u)
                
                set stamina = GetUnitUserData(u)
                
                set stamina.regen = stamina.regen + new - old
            endloop
        endmethod
        
        method operator cost takes nothing returns real
            return costT.real[this]
        endmethod
        method operator cost= takes real new returns nothing
            local unit u
            local real old = cost
            local Stamina stamina
            
            set costT.real[this] = new
            
            call GroupEnumUnitsOfType(enumGroup, GetObjectName(this), null)
            loop
                set u = FirstOfGroup(enumGroup)
                exitwhen null == u
                
                call GroupRemoveUnit(enumGroup, u)
                
                set stamina = GetUnitUserData(u)
                
                set stamina.cost = stamina.cost + new - old
            endloop
        endmethod
        
        method operator max takes nothing returns real
            return maxT.real[this]
        endmethod
        method operator max= takes real new returns nothing
            local unit u
            local real old = max
            local Stamina stamina
            
            set maxT.real[this] = new
            
            call GroupEnumUnitsOfType(enumGroup, GetObjectName(this), null)
            loop
                set u = FirstOfGroup(enumGroup)
                exitwhen null == u
                
                call GroupRemoveUnit(enumGroup, u)
                
                set stamina = GetUnitUserData(u)
                
                set stamina.max = stamina.max + new - old
            endloop
        endmethod
    endstruct
    
    private struct StaminaTypePlayer extends array
        private Table regenT
        private Table costT
        private Table maxT
        
        private static method onInit takes nothing returns nothing
            local thistype this = 15
            
            loop
                set regenT = Table.create()
                set costT = Table.create()
                set maxT = Table.create()
            
                exitwhen 0 == this
                set this = this - 1
            endloop
        endmethod
        
        method getRegen takes integer unitTypeId returns real
            return regenT.real[unitTypeId]
        endmethod
        method setRegen takes integer unitTypeId, real new returns nothing
            local unit u
            local real old = getRegen(unitTypeId)
            local Stamina stamina
            
            set regenT.real[unitTypeId] = new
            
            call GroupEnumUnitsOfPlayer(enumGroup, Player(this), null)
            loop
                set u = FirstOfGroup(enumGroup)
                exitwhen null == u
                
                call GroupRemoveUnit(enumGroup, u)
                
                if (GetUnitTypeId(u) == unitTypeId) then
                    set stamina = GetUnitUserData(u)
                    
                    set stamina.regen = stamina.regen + new - old
                endif
            endloop
        endmethod
        
        method getCost takes integer unitTypeId returns real
            return costT.real[unitTypeId]
        endmethod
        method setCost takes integer unitTypeId, real new returns nothing
            local unit u
            local real old = getCost(unitTypeId)
            local Stamina stamina
            
            set costT.real[unitTypeId] = new
            
            call GroupEnumUnitsOfPlayer(enumGroup, Player(this), null)
            loop
                set u = FirstOfGroup(enumGroup)
                exitwhen null == u
                
                call GroupRemoveUnit(enumGroup, u)
                
                if (GetUnitTypeId(u) == unitTypeId) then
                    set stamina = GetUnitUserData(u)
                    
                    set stamina.cost = stamina.cost + new - old
                endif
            endloop
        endmethod
        
        method getMax takes integer unitTypeId returns real
            return maxT.real[unitTypeId]
        endmethod
        method setMax takes integer unitTypeId, real new returns nothing
            local unit u
            local real old = getMax(unitTypeId)
            local Stamina stamina
            
            set maxT.real[unitTypeId] = new
            
            call GroupEnumUnitsOfPlayer(enumGroup, Player(this), null)
            loop
                set u = FirstOfGroup(enumGroup)
                exitwhen null == u
                
                call GroupRemoveUnit(enumGroup, u)
                
                if (GetUnitTypeId(u) == unitTypeId) then
                    set stamina = GetUnitUserData(u)
                    
                    set stamina.max = stamina.max + new - old
                endif
            endloop
        endmethod
    endstruct
    
    private struct Core extends array
        private static method onUnitStationary takes nothing returns boolean
            local Stamina stamina = GetMovingUnitById()
            
            call MovementList(stamina).remove()
            if (0 != stamina.regen and 0 != stamina.max) then
                call StationaryList(stamina).add()
            endif
            
            return false
        endmethod
        
        private static method onUnitMove takes nothing returns boolean
            local Stamina stamina = GetMovingUnitById()
            
            call StationaryList(stamina).remove()
            if (0 != stamina.cost and 0 != stamina.max) then
                call MovementList(stamina).add()
            endif
            
            return false
        endmethod
        
        private static method onUnitActive takes nothing returns boolean
            local Stamina stamina = GetUnitTypeId(GetUnitById(GetMovingUnitById()))
            
            if (0 != stamina.regen and 0 != stamina.max) then
                call StationaryList(stamina).add()
            endif
            
            if (0 != stamina.cost and 0 != stamina.max) then
                call MovementList(stamina).add()
            endif
            
            return false
        endmethod
        
        private static method onUnitInactive takes nothing returns boolean
            local Stamina stamina = GetUnitTypeId(GetUnitById(GetMovingUnitById()))
            
            call MovementList(stamina).remove()
            call StationaryList(stamina).remove()
            
            return false
        endmethod
    
        private static method onIndex takes nothing returns boolean
            local StaminaTypePlayer owningPlayer = GetPlayerId(GetOwningPlayer(GetIndexedUnit()))
            local Stamina stamina = GetUnitUserData(GetIndexedUnit())
            local StaminaType staminaType = GetUnitTypeId(GetIndexedUnit())
            
            set stamina.cost = staminaType.cost + owningPlayer.getCost(staminaType)
            set stamina.regen = staminaType.regen + owningPlayer.getRegen(staminaType)
            set stamina.max = staminaType.max + owningPlayer.getMax(staminaType)
        
            return false
        endmethod
    
        private static method onInit takes nothing returns nothing
            call StationaryUnits.event.register(Condition(function thistype.onUnitStationary))
            call NativelyMovingUnits.event.register(Condition(function thistype.onUnitMove))
            call MovementTracker.eventIndex.register(Condition(function thistype.onUnitActive))
            call MovementTracker.eventDeindex.register(Condition(function thistype.onUnitInactive))
            
            call RegisterUnitIndexEvent(Condition(function thistype.onIndex), UnitIndexer.INDEX)
            
            set onStaminaChange = Event.create()
        endmethod
    endstruct
    
    private struct StaminaLoss extends array
        implement CT32
            local MovementList moving = MovementList(0).next
            local StationaryList stationary = StationaryList(0).next
            local Stamina stamina
            
            loop
                exitwhen 0 == moving
                
                set stamina = moving
                
                if (0 < stamina.value) then
                    set stamina.value = stamina.value - stamina.cost*.03125
                endif
                
                set moving = moving.next
            endloop
            
            loop
                exitwhen 0 == stationary
                
                set stamina = stationary
                
                if (stamina.value < stamina.max) then
                    set stamina.value = stamina.value + stamina.regen*.03125
                endif
                
                set stationary = stationary.next
            endloop
        implement CT32End
        
        private static method onInit takes nothing returns nothing
            call StaminaLoss.start()
        endmethod
    endstruct
    
    function SetUnitStaminaById takes UnitIndex index, real value returns nothing
        set Stamina(index).value = value
    endfunction
    function SetUnitStaminaRegenById takes UnitIndex index, real value returns nothing
        set Stamina(index).regen = value
    endfunction
    function SetUnitStaminaCostById takes UnitIndex index, real value returns nothing
        set Stamina(index).cost = value
    endfunction
    function SetUnitStaminaMaxById takes UnitIndex index, real value returns nothing
        set Stamina(index).max = value
    endfunction
    
    function GetUnitStaminaById takes UnitIndex index returns real
        return Stamina(index).value
    endfunction
    function GetUnitStaminaRegenById takes UnitIndex index returns real
        return Stamina(index).regen
    endfunction
    function GetUnitStaminaCostById takes UnitIndex index returns real
        return Stamina(index).cost
    endfunction
    function GetUnitStaminaMaxById takes UnitIndex index returns real
        return Stamina(index).max
    endfunction
    
    function SetUnitTypeStaminaRegen takes integer unitTypeId, real value returns nothing
        set StaminaType(unitTypeId).regen = value
    endfunction
    function SetUnitTypeStaminaCost takes integer unitTypeId, real value returns nothing
        set StaminaType(unitTypeId).cost = value
    endfunction
    function SetUnitTypeStaminaMax takes integer unitTypeId, real value returns nothing
        set StaminaType(unitTypeId).max = value
    endfunction
    
    function GetUnitTypeStaminaRegen takes integer unitTypeId returns real
        return StaminaType(unitTypeId).regen
    endfunction
    function GetUnitTypeStaminaCost takes integer unitTypeId returns real
        return StaminaType(unitTypeId).cost
    endfunction
    function GetUnitTypeStaminaMax takes integer unitTypeId returns real
        return StaminaType(unitTypeId).max
    endfunction
    
    function SetUnitTypeStaminaRegenForPlayer takes integer unitTypeId, integer playerId, real value returns nothing
        call StaminaTypePlayer(playerId).setRegen(unitTypeId, value)
    endfunction
    function SetUnitTypeStaminaCostForPlayer takes integer unitTypeId, integer playerId, real value returns nothing
        call StaminaTypePlayer(playerId).setCost(unitTypeId, value)
    endfunction
    function SetUnitTypeStaminaMaxForPlayer takes integer unitTypeId, integer playerId, real value returns nothing
        call StaminaTypePlayer(playerId).setMax(unitTypeId, value)
    endfunction
    
    function GetUnitTypeStaminaRegenForPlayer takes integer unitTypeId, integer playerId returns real
        return StaminaTypePlayer(playerId).getRegen(unitTypeId)
    endfunction
    function GetUnitTypeStaminaCostForPlayer takes integer unitTypeId, integer playerId returns real
        return StaminaTypePlayer(playerId).getCost(unitTypeId)
    endfunction
    function GetUnitTypeStaminaMaxForPlayer takes integer unitTypeId, integer playerId returns real
        return StaminaTypePlayer(playerId).getMax(unitTypeId)
    endfunction
endlibrary