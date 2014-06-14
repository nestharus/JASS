library DamageEvent /* v2.0.0.0
*************************************************************************************
*
*   Damage Event plugin for DDS
*
*************************************************************************************
*
*   */uses/*
*
*       */ DDS                      /*
*		*/ Trigger					/*
*
************************************************************************************
*
*   SETTINGS
*/
globals
	/*************************************************************************************
	*
	*   Enabling four phases, which splits ON_DAMAGE into ON_DAMAGE and ON_DAMAGE_OUTGOING
	*
	*	This adds a little overhead, but gives more functionality. Only enable these extra
	*	phases if you need them.
	*
	*************************************************************************************/
	public constant boolean FOUR_PHASE = true
endglobals
/*
*************************************************************************************
*
*   API
*
*       readonly static Trigger DDS.GlobalDamageEvent.ON_DAMAGE_BEFORE
*			-	runs first whenever any unit is damaged (setup)
*
*		readonly static Trigger DDS.GlobalDamageEvent.ON_DAMAGE_AFTER
*			-	runs last and in reverse whenever any unit is damaged (cleanup)
*
*		readonly Trigger DDS.ON_DAMAGE
*			-	runs when a specific unit is damaged
*
*		method fireLocal takes nothing returns nothing
*			-	fires ON_DAMAGE followed by ON_DAMAGE_AFTER correctly
*
*			-	this is used for custom combat systems, meaning that the DDS data for
*				damage, target, etc will no longer be accurate
*
*			-	it is expected that damage data is created (similarly to ON_DAMAGE_BEFORE)
*
*       readony static real damage
*           -   amount of damage dealt
*
*       readonly static unit target
*       readonly static UnitIndex targetId
*           -   damaged unit
*
*       readonly static unit source
*       readonly static UnitIndex sourceId
*           -   unit that dealt damage
*
*       readonly static player sourcePlayer
*           -   owner of source
*
*		readonly static player targetPlayer
*			-	owner of target
*
*
*		MUST BE DECLARED -		onDamageBefore
*		------------------------------------------
*
*			readonly static Trigger ON_DAMAGE_BEFORE
*				-	allows a user to run through the struct rather than DDS
*
*
*		MUST BE DECLARED -		onDamageAfter
*		------------------------------------------
*
*			readonly static Trigger ON_DAMAGE_AFTER
*				-	allows a user to run through the struct rather than DDS
*
*
*		MUST BE DECLARED -		onDamage
*		------------------------------------------
*
*			readonly Trigger ON_DAMAGE
*				-	allows a user to run through the struct rather than DDS
*
*			method enableDamageEventLocal takes nothing returns boolean
*				-	will enable the local event for a given unit index
*					after the first enable, it will just increase a counter
*
*				-	returns true when actually enabling
*					returns false when just increasing the counter
*
*					Examples:	local MyStruct modifier = someUnitIndex //on item pickup
*								call modifier.enableDamageEventLocal()
*								set modifier.physicalDamageReduction = modifier.physicalDamageReduction + item.physicalDamageReduction
*
*			method disableDamageEventLocal takes nothing returns boolean
*				-	will disable the local event for a given unit index
*					decreases a counter until that counter reaches 0, at which point
*					the thing is actuall disabled
*
*				-	returns true when actually disabling
*					returns false when just decreasing the counter
*
*					Examples:	local MyStruct modifier = someUnitIndex //on item drop
*								call modifier.disableDamageEventLocal()
*								set modifier.physicalDamageReduction = modifier.physicalDamageReduction - item.physicalDamageReduction
*
*	FOUR_PHASE ONLY SECTION
*
*		readonly Trigger DDS.ON_DAMAGE_OUTGOING
*			-	runs when a specific unit deals damage
*
*		MUST BE DECLARED -		onDamageOutgoing
*		------------------------------------------
*
*			readonly Trigger ON_DAMAGE_OUTGOING
*				-	allows a user to run through the struct rather than DDS
*
*			method enableDamageEventLocalOutgoing takes nothing returns boolean
*				-	will enable the local event for a given unit index
*					after the first enable, it will just increase a counter
*
*				-	returns true when actually enabling
*					returns false when just increasing the counter
*
*					Examples:	local MyStruct modifier = someUnitIndex //on item pickup
*								call modifier.enableDamageEventLocalOutgoing()
*								set modifier.attackIncrease = modifier.attackIncrease + item.attackIncrease
*
*			method disableDamageEventLocalOutgoing takes nothing returns boolean
*				-	will disable the local event for a given unit index
*					decreases a counter until that counter reaches 0, at which point
*					the thing is actuall disabled
*
*				-	returns true when actually disabling
*					returns false when just decreasing the counter
*
*					Examples:	local MyStruct modifier = someUnitIndex //on item drop
*								call modifier.disableDamageEventLocalOutgoing()
*								set modifier.attackIncrease = modifier.attackIncrease - item.attackIncrease
*
*************************************************************************************
*
*   Interface
*
*       (optional) private static method onDamageBefore takes nothing returns nothing
*           -   is run first whenever a unit is damaged
*       (optional) private static method onDamageAfter takes nothing returns nothing
*           -   is run last whenever a unit is damaged
*
*       (optional) private method onDamage takes nothing returns nothing
*           -   is run when a specific unit is damaged
*
*			-	this == index of unit taking damage
*
*	FOUR_PHASE ONLY SECTION
*
*       (optional) private method onDamageOutgoing takes nothing returns nothing
*           -   is run when a specific unit deals damage
*
*			-	this == index of unit dealing damage
*
*************************************************************************************
*
*   Plugin Information (can only be used by other plugins)
*
*       static UnitIndex targetId_p
*       static UnitIndex sourceId_p
*
*       static real damage_p
*
*       static player sourcePlayer_p
*       static player targetPlayer_p
*
*************************************************************************************/
    //! textmacro DAMAGE_EVENT_CODE
	
    private keyword damage_p
    private keyword targetId_p
    private keyword sourceId_p
    private keyword sourcePlayer_p
    private keyword targetPlayer_p
	
    scope DamageEvent
		private keyword init
		private keyword ON_DAMAGE_MAIN
		private keyword ON_DAMAGE_MAIN_2
		
		private struct GlobalDamageEvent extends array
			readonly static Trigger ON_DAMAGE_BEFORE
			readonly static Trigger ON_DAMAGE_AFTER
			
			static method init takes nothing returns nothing
				set ON_DAMAGE_BEFORE = Trigger.create(false)
				set ON_DAMAGE_AFTER = Trigger.create(true)
			endmethod
		endstruct
		struct LocalDamageEvent extends array
			readonly Trigger ON_DAMAGE_MAIN				//BEFORE, OUTGOING
			readonly Trigger ON_DAMAGE_MAIN_2			//INCOMING, AFTER
			readonly Trigger ON_DAMAGE
			
			method fireLocal takes nothing returns nothing
				call ON_DAMAGE_MAIN_2.fire()
			endmethod
		
			static if DamageEvent_FOUR_PHASE then
				readonly Trigger ON_DAMAGE_OUTGOING
				
				private static method onUnitIndex takes nothing returns boolean
					local thistype this = UnitIndexer.eventIndex
					
					set ON_DAMAGE_MAIN = Trigger.create(false)
					set ON_DAMAGE_MAIN_2 = Trigger.create(false)
					set ON_DAMAGE = Trigger.create(false)
					set ON_DAMAGE_OUTGOING = Trigger.create(false)
					
					call ON_DAMAGE_MAIN.reference(GlobalDamageEvent.ON_DAMAGE_BEFORE)
					call ON_DAMAGE_MAIN.reference(ON_DAMAGE_OUTGOING)
					call ON_DAMAGE_MAIN_2.reference(ON_DAMAGE)
					call ON_DAMAGE_MAIN_2.reference(GlobalDamageEvent.ON_DAMAGE_AFTER)
			
					return false
				endmethod
				
				private static method onUnitDeindex takes nothing returns boolean
					local thistype this = UnitIndexer.eventIndex
					
					call ON_DAMAGE_MAIN.destroy()
					call ON_DAMAGE_MAIN_2.destroy()
					call ON_DAMAGE.destroy()
					call ON_DAMAGE_OUTGOING.destroy()
				
					return false
				endmethod
			else
				private static method onUnitIndex takes nothing returns boolean
					local thistype this = UnitIndexer.eventIndex
					
					set ON_DAMAGE_MAIN = Trigger.create(false)
					set ON_DAMAGE_MAIN_2 = Trigger.create(false)
					set ON_DAMAGE = Trigger.create(false)
					
					call ON_DAMAGE_MAIN.reference(GlobalDamageEvent.ON_DAMAGE_BEFORE)
					call ON_DAMAGE_MAIN.reference(ON_DAMAGE_MAIN_2)
					call ON_DAMAGE_MAIN_2.reference(ON_DAMAGE)
					call ON_DAMAGE_MAIN_2.reference(GlobalDamageEvent.ON_DAMAGE_AFTER)
			
					return false
				endmethod
				
				private static method onUnitDeindex takes nothing returns boolean
					local thistype this = UnitIndexer.eventIndex
					
					call ON_DAMAGE_MAIN.destroy()
					call ON_DAMAGE_MAIN_2.destroy()
					call ON_DAMAGE.destroy()
				
					return false
				endmethod
			endif
			
			static method init takes nothing returns nothing
				call UnitIndexer.GlobalEvent.ON_INDEX.register(Condition(function thistype.onUnitIndex))
				call UnitIndexer.GlobalEvent.ON_DEINDEX.register(Condition(function thistype.onUnitDeindex))
			endmethod
		endstruct
		
        /*
        *   DDS API
        *
        *       DDS.GlobalEvent.ON_DAMAGE_BEFORE
        *       DDS.GlobalEvent.ON_DAMAGE_AFTER
		*		DDS.Event.ON_DAMAGE
		*
        *       DDS.target
		*		DDS.targetId
        *       DDS.source
		*		DDS.sourceId
		*		DDS.sourcePlayer
        *       DDS.damage
        *
        */
        private keyword damageEventInit
        
        module DAMAGE_EVENT_API
			static method operator GlobalEvent takes nothing returns GlobalDamageEvent
				return 0
			endmethod
			method operator Event takes nothing returns LocalDamageEvent
				return this
			endmethod
		
            static UnitIndex targetId_p = 0
            static UnitIndex sourceId_p = 0
            static real damage_p = 0
            static player sourcePlayer_p = null
			static player targetPlayer_p = null
            
            static method operator targetId takes nothing returns UnitIndex
                return targetId_p
            endmethod
            static method operator target takes nothing returns unit
                return targetId.unit
            endmethod
            
            static method operator sourceId takes nothing returns UnitIndex
                return sourceId_p
            endmethod
            static method operator source takes nothing returns unit
                return sourceId.unit
            endmethod
            
            static method operator damage takes nothing returns real
                return damage_p
            endmethod
            
            static method operator sourcePlayer takes nothing returns player
                return sourcePlayer_p
            endmethod
			
            static method operator targetPlayer takes nothing returns player
                return targetPlayer_p
            endmethod
			
			static method damageEventInit takes nothing returns nothing
				call GlobalDamageEvent.init()
				call LocalDamageEvent.init()
			endmethod
        endmodule
		
        module DAMAGE_EVENT_INIT
            call DDS.damageEventInit()
        endmodule

        /*
        *   DDS Interface
        *
        *       interface private static method onDamage takes nothing returns nothing
        *
        *       
        */
        module DAMAGE_EVENT_INTERFACE
			/*
			*	private static method getCondition takes code c returns boolexpr
			*/
			static if thistype.onDamageBefore.exists then
				private static method getCondition takes code c returns boolexpr
					return Condition(c)
					return null
				endmethod
			elseif thistype.onDamageAfter.exists then
				private static method getCondition takes code c returns boolexpr
					return Condition(c)
					return null
				endmethod
			endif
			
			static if thistype.onDamageBefore.exists then
				readonly static Trigger ON_DAMAGE_BEFORE
			endif
			static if thistype.onDamageAfter.exists then
				readonly static Trigger ON_DAMAGE_AFTER
			endif
			
			static if thistype.onDamage.exists then
				readonly Trigger ON_DAMAGE
				private static boolexpr onDamageExpr
				private TriggerReference ON_DAMAGE_REF
				
				private static method onDamageFunc takes nothing returns boolean
					call thistype(targetId).onDamage()
					return false
				endmethod
				
				private integer count
				
				method enableDamageEventLocal takes nothing returns boolean
					set count = count + 1
				
					if (count == 1) then
						set ON_DAMAGE_REF = LocalDamageEvent(this).ON_DAMAGE.reference(ON_DAMAGE)
						
						return true
					endif
					
					return false
				endmethod
				
				method disableDamageEventLocal takes nothing returns boolean
					if (count == 0) then
						return false
					endif
				
					set count = count - 1
				
					if (count == 0) then
						call ON_DAMAGE_REF.destroy()
						
						return true
					endif
					
					return false
				endmethod
			endif
		
			static if DamageEvent_FOUR_PHASE then
				static if thistype.onDamageOutgoing.exists then
					readonly Trigger ON_DAMAGE_OUTGOING
					private static boolexpr onDamageOutgoingExpr
					private TriggerReference ON_DAMAGE_OUTGOING_REF
					
					private static method onDamageOutgoingFunc takes nothing returns boolean
						call thistype(sourceId).onDamageOutgoing()
						return false
					endmethod
					
					private integer countOutgoing
					
					method enableDamageEventLocalOutgoing takes nothing returns boolean
						set countOutgoing = countOutgoing + 1
					
						if (countOutgoing == 1) then
							set ON_DAMAGE_OUTGOING_REF = LocalDamageEvent(this).ON_DAMAGE_OUTGOING.reference(ON_DAMAGE_OUTGOING)
							
							return true
						endif
						
						return false
					endmethod
					
					method disableDamageEventLocalOutgoing takes nothing returns boolean
						if (countOutgoing == 0) then
							return false
						endif
					
						set countOutgoing = countOutgoing - 1
					
						if (countOutgoing == 0) then
							call ON_DAMAGE_OUTGOING_REF.destroy()
							
							return true
						endif
						
						return false
					endmethod
				endif
				
				static if thistype.onDamageOutgoing.exists then
					private static method onUnitIndex takes nothing returns boolean
						local thistype this = UnitIndexer.eventIndex
					
						static if thistype.onDamage.exists then
							set ON_DAMAGE = Trigger.create(false)
							call ON_DAMAGE.register(onDamageExpr)
						endif
						
						static if thistype.onDamageOutgoing.exists then
							set ON_DAMAGE_OUTGOING = Trigger.create(false)
							call ON_DAMAGE_OUTGOING.register(onDamageOutgoingExpr)
						endif
						
						return false
					endmethod
					
					private static method onUnitDeindex takes nothing returns boolean
						local thistype this = UnitIndexer.eventIndex
						
						static if thistype.onDamage.exists then
							call ON_DAMAGE.destroy()
							
							set count = 0
						endif
						
						static if thistype.onDamageOutgoing.exists then
							call ON_DAMAGE_OUTGOING.destroy()
							
							set countOutgoing = 0
						endif
						
						return false
					endmethod
				elseif thistype.onDamage.exists then
					private static method onUnitIndex takes nothing returns boolean
						local thistype this = UnitIndexer.eventIndex
					
						static if thistype.onDamage.exists then
							set ON_DAMAGE = Trigger.create(false)
							call ON_DAMAGE.register(onDamageExpr)
						endif
						
						static if thistype.onDamageOutgoing.exists then
							set ON_DAMAGE_OUTGOING = Trigger.create(false)
							call ON_DAMAGE_OUTGOING.register(onDamageOutgoingExpr)
						endif
						
						return false
					endmethod
					
					private static method onUnitDeindex takes nothing returns boolean
						local thistype this = UnitIndexer.eventIndex
						
						static if thistype.onDamage.exists then
							call ON_DAMAGE.destroy()
							
							set count = 0
						endif
						
						static if thistype.onDamageOutgoing.exists then
							call ON_DAMAGE_OUTGOING.destroy()
							
							set countOutgoing = 0
						endif
						
						return false
					endmethod
				endif
				
				static if thistype.onDamageBefore.exists then
					private static method onInit takes nothing returns nothing
						static if thistype.onDamage.exists then
							set onDamageExpr = Condition(function thistype.onDamageFunc)
						endif
						
						static if thistype.onDamageOutgoing.exists then
							set onDamageOutgoingExpr = Condition(function thistype.onDamageOutgoingFunc)
						endif
						
						static if thistype.onDamage.exists then
							call UnitIndexer.GlobalEvent.ON_INDEX.register(Condition(function thistype.onUnitIndex))
							call UnitIndexer.GlobalEvent.ON_DEINDEX.register(Condition(function thistype.onUnitDeindex))
						elseif thistype.onDamageOutgoing.exists then
							call UnitIndexer.GlobalEvent.ON_INDEX.register(Condition(function thistype.onUnitIndex))
							call UnitIndexer.GlobalEvent.ON_DEINDEX.register(Condition(function thistype.onUnitDeindex))
						endif
						
						static if thistype.onDamageBefore.exists then
							set ON_DAMAGE_BEFORE = Trigger.create(false)
							call ON_DAMAGE_BEFORE.register(getCondition(function thistype.onDamageBefore))
							call GlobalDamageEvent.ON_DAMAGE_BEFORE.reference(ON_DAMAGE_BEFORE)
						endif
						
						static if thistype.onDamageAfter.exists then
							set ON_DAMAGE_AFTER = Trigger.create(true)
							call ON_DAMAGE_AFTER.register(getCondition(function thistype.onDamageAfter))
							call GlobalDamageEvent.ON_DAMAGE_AFTER.reference(ON_DAMAGE_AFTER)
						endif
					endmethod
				elseif thistype.onDamageAfter.exists then
					private static method onInit takes nothing returns nothing
						static if thistype.onDamage.exists then
							set onDamageExpr = Condition(function thistype.onDamageFunc)
						endif
						
						static if thistype.onDamageOutgoing.exists then
							set onDamageOutgoingExpr = Condition(function thistype.onDamageOutgoingFunc)
						endif
						
						static if thistype.onDamage.exists then
							call UnitIndexer.GlobalEvent.ON_INDEX.register(Condition(function thistype.onUnitIndex))
							call UnitIndexer.GlobalEvent.ON_DEINDEX.register(Condition(function thistype.onUnitDeindex))
						elseif thistype.onDamageOutgoing.exists then
							call UnitIndexer.GlobalEvent.ON_INDEX.register(Condition(function thistype.onUnitIndex))
							call UnitIndexer.GlobalEvent.ON_DEINDEX.register(Condition(function thistype.onUnitDeindex))
						endif
						
						static if thistype.onDamageBefore.exists then
							set ON_DAMAGE_BEFORE = Trigger.create(false)
							call ON_DAMAGE_BEFORE.register(getCondition(function thistype.onDamageBefore))
							call GlobalDamageEvent.ON_DAMAGE_BEFORE.reference(ON_DAMAGE_BEFORE)
						endif
						
						static if thistype.onDamageAfter.exists then
							set ON_DAMAGE_AFTER = Trigger.create(true)
							call ON_DAMAGE_AFTER.register(getCondition(function thistype.onDamageAfter))
							call GlobalDamageEvent.ON_DAMAGE_AFTER.reference(ON_DAMAGE_AFTER)
						endif
					endmethod
				elseif thistype.onDamage.exists then
					private static method onInit takes nothing returns nothing
						static if thistype.onDamage.exists then
							set onDamageExpr = Condition(function thistype.onDamageFunc)
						endif
						
						static if thistype.onDamageOutgoing.exists then
							set onDamageOutgoingExpr = Condition(function thistype.onDamageOutgoingFunc)
						endif
						
						static if thistype.onDamage.exists then
							call UnitIndexer.GlobalEvent.ON_INDEX.register(Condition(function thistype.onUnitIndex))
							call UnitIndexer.GlobalEvent.ON_DEINDEX.register(Condition(function thistype.onUnitDeindex))
						elseif thistype.onDamageOutgoing.exists then
							call UnitIndexer.GlobalEvent.ON_INDEX.register(Condition(function thistype.onUnitIndex))
							call UnitIndexer.GlobalEvent.ON_DEINDEX.register(Condition(function thistype.onUnitDeindex))
						endif
						
						static if thistype.onDamageBefore.exists then
							set ON_DAMAGE_BEFORE = Trigger.create(false)
							call ON_DAMAGE_BEFORE.register(getCondition(function thistype.onDamageBefore))
							call GlobalDamageEvent.ON_DAMAGE_BEFORE.reference(ON_DAMAGE_BEFORE)
						endif
						
						static if thistype.onDamageAfter.exists then
							set ON_DAMAGE_AFTER = Trigger.create(true)
							call ON_DAMAGE_AFTER.register(getCondition(function thistype.onDamageAfter))
							call GlobalDamageEvent.ON_DAMAGE_AFTER.reference(ON_DAMAGE_AFTER)
						endif
					endmethod
				elseif thistype.onDamageOutgoing.exists then
					private static method onInit takes nothing returns nothing
						static if thistype.onDamage.exists then
							set onDamageExpr = Condition(function thistype.onDamageFunc)
						endif
						
						static if thistype.onDamageOutgoing.exists then
							set onDamageOutgoingExpr = Condition(function thistype.onDamageOutgoingFunc)
						endif
						
						static if thistype.onDamage.exists then
							call UnitIndexer.GlobalEvent.ON_INDEX.register(Condition(function thistype.onUnitIndex))
							call UnitIndexer.GlobalEvent.ON_DEINDEX.register(Condition(function thistype.onUnitDeindex))
						elseif thistype.onDamageOutgoing.exists then
							call UnitIndexer.GlobalEvent.ON_INDEX.register(Condition(function thistype.onUnitIndex))
							call UnitIndexer.GlobalEvent.ON_DEINDEX.register(Condition(function thistype.onUnitDeindex))
						endif
						
						static if thistype.onDamageBefore.exists then
							set ON_DAMAGE_BEFORE = Trigger.create(false)
							call ON_DAMAGE_BEFORE.register(getCondition(function thistype.onDamageBefore))
							call GlobalDamageEvent.ON_DAMAGE_BEFORE.reference(ON_DAMAGE_BEFORE)
						endif
						
						static if thistype.onDamageAfter.exists then
							set ON_DAMAGE_AFTER = Trigger.create(true)
							call ON_DAMAGE_AFTER.register(getCondition(function thistype.onDamageAfter))
							call GlobalDamageEvent.ON_DAMAGE_AFTER.reference(ON_DAMAGE_AFTER)
						endif
					endmethod
				endif
			else
				static if thistype.onDamage.exists then
					private static method onUnitIndex takes nothing returns boolean
						local thistype this = UnitIndexer.eventIndex
					
						set ON_DAMAGE = Trigger.create(false)
						call ON_DAMAGE.register(onDamageExpr)
					
						return false
					endmethod
					
					private static method onUnitDeindex takes nothing returns boolean
						local thistype this = UnitIndexer.eventIndex
					
						call ON_DAMAGE.destroy()
						
						set count = 0
						
						return false
					endmethod
				endif
				
				static if thistype.onDamageBefore.exists then
					private static method onInit takes nothing returns nothing
						static if thistype.onDamage.exists then
							set onDamageExpr = Condition(function thistype.onDamageFunc)
							
							call UnitIndexer.GlobalEvent.ON_INDEX.register(Condition(function thistype.onUnitIndex))
							call UnitIndexer.GlobalEvent.ON_DEINDEX.register(Condition(function thistype.onUnitDeindex))
						endif
					
						static if thistype.onDamageBefore.exists then
							set ON_DAMAGE_BEFORE = Trigger.create(false)
							call ON_DAMAGE_BEFORE.register(getCondition(function thistype.onDamageBefore))
							call GlobalDamageEvent.ON_DAMAGE_BEFORE.reference(ON_DAMAGE_BEFORE)
						endif
						
						static if thistype.onDamageAfter.exists then
							set ON_DAMAGE_AFTER = Trigger.create(true)
							call ON_DAMAGE_AFTER.register(getCondition(function thistype.onDamageAfter))
							call GlobalDamageEvent.ON_DAMAGE_AFTER.reference(ON_DAMAGE_AFTER)
						endif
					endmethod
				elseif thistype.onDamageAfter.exists then
					private static method onInit takes nothing returns nothing
						static if thistype.onDamage.exists then
							set onDamageExpr = Condition(function thistype.onDamageFunc)
							
							call UnitIndexer.GlobalEvent.ON_INDEX.register(Condition(function thistype.onUnitIndex))
							call UnitIndexer.GlobalEvent.ON_DEINDEX.register(Condition(function thistype.onUnitDeindex))
						endif
					
						static if thistype.onDamageBefore.exists then
							set ON_DAMAGE_BEFORE = Trigger.create(false)
							call ON_DAMAGE_BEFORE.register(getCondition(function thistype.onDamageBefore))
							call GlobalDamageEvent.ON_DAMAGE_BEFORE.reference(ON_DAMAGE_BEFORE)
						endif
						
						static if thistype.onDamageAfter.exists then
							set ON_DAMAGE_AFTER = Trigger.create(true)
							call ON_DAMAGE_AFTER.register(getCondition(function thistype.onDamageAfter))
							call GlobalDamageEvent.ON_DAMAGE_AFTER.reference(ON_DAMAGE_AFTER)
						endif
					endmethod
				elseif thistype.onDamage.exists then
					private static method onInit takes nothing returns nothing
						static if thistype.onDamage.exists then
							set onDamageExpr = Condition(function thistype.onDamageFunc)
							
							call UnitIndexer.GlobalEvent.ON_INDEX.register(Condition(function thistype.onUnitIndex))
							call UnitIndexer.GlobalEvent.ON_DEINDEX.register(Condition(function thistype.onUnitDeindex))
						endif
					
						static if thistype.onDamageBefore.exists then
							set ON_DAMAGE_BEFORE = Trigger.create(false)
							call ON_DAMAGE_BEFORE.register(getCondition(function thistype.onDamageBefore))
							call GlobalDamageEvent.ON_DAMAGE_BEFORE.reference(ON_DAMAGE_BEFORE)
						endif
						
						static if thistype.onDamageAfter.exists then
							set ON_DAMAGE_AFTER = Trigger.create(true)
							call ON_DAMAGE_AFTER.register(getCondition(function thistype.onDamageAfter))
							call GlobalDamageEvent.ON_DAMAGE_AFTER.reference(ON_DAMAGE_AFTER)
						endif
					endmethod
				endif
			endif
        endmodule

        /*
        *   DDS Event Handling
        */
module DAMAGE_EVENT_RESPONSE_LOCALS
                local UnitIndex prevTarget = targetId_p
                local UnitIndex prevSource = sourceId_p
                
                local real prevDamage = damage_p
endmodule
module DAMAGE_EVENT_RESPONSE_BEFORE
                if (0 == GetEventDamage()) then
                    return
                endif
                
                set targetId_p = GetUnitUserData(GetTriggerUnit())
                set sourceId_p = GetUnitUserData(GetEventDamageSource())
                set damage_p = GetEventDamage()
                set sourcePlayer_p = GetOwningPlayer(sourceId_p.unit)
                set targetPlayer_p = GetOwningPlayer(targetId_p.unit)
endmodule
module DAMAGE_EVENT_RESPONSE
				static if DamageEvent_FOUR_PHASE then
					call LocalDamageEvent(sourceId_p).ON_DAMAGE_MAIN.fire()
					call LocalDamageEvent(targetId_p).ON_DAMAGE_MAIN_2.fire()
				else
					call LocalDamageEvent(targetId_p).ON_DAMAGE_MAIN.fire()
				endif
endmodule
module DAMAGE_EVENT_RESPONSE_AFTER
                
endmodule
module DAMAGE_EVENT_RESPONSE_CLEANUP
                set targetId_p = prevTarget
                set sourceId_p = prevSource
                set damage_p = prevDamage
				
				if (sourceId_p == 0) then
					set sourcePlayer_p = null
				else
					set targetPlayer_p = GetOwningPlayer(sourceId_p.unit)
				endif
				
				if (targetId_p == 0) then
					set sourcePlayer_p = null
				else
					set targetPlayer_p = GetOwningPlayer(targetId_p.unit)
				endif
endmodule
    endscope
    //! endtextmacro
endlibrary