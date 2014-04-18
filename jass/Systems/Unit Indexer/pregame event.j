/*
*	requires
*
*		StaticUniqueList
*
*	private struct PreGameEvent extends array
*
*		Evaluates all triggers and functions registered to
*		Unit Indexer before game start for all indexed units.
*
*
*		static method fireTrigger takes trigger whichTrigger returns nothing
*		static method fireExpression takes boolexpr whichExpression returns nothing
*
*		static method addUnitIndex takes integer whichUnitIndex returns nothing
*		static method removeUnitIndex takes integer whichUnitIndex returns nothing
*/

//! textmacro UNIT_INDEXER_PREGAME_EVENT
private struct PreGameEvent extends array
	readonly static boolean isGameLoaded = false

	implement StaticUniqueList
	
	private static method p_fireTrigger takes Trigger whichTrigger returns nothing
		local thistype this = first
		local integer prevIndexedUnitId = p_eventIndex
		
		loop
			exitwhen this == sentinel or not whichTrigger.enabled
			
			set p_eventIndex = this
			call whichTrigger.fire()
			
			set this = next
		endloop
		
		set p_eventIndex = prevIndexedUnitId
	endmethod
	static method fireTrigger takes Trigger whichTrigger returns nothing
		if (first != 0) then
			call p_fireTrigger(whichTrigger)
		endif
	endmethod
	
	private static method p_fireExpression takes boolexpr whichExpression returns nothing
		local trigger triggerContainer = CreateTrigger()
		local thistype this = first
		local integer prevIndexedUnitId = p_eventIndex
		
		call TriggerAddCondition(triggerContainer, whichExpression)
		
		loop
			exitwhen this == sentinel
			
			set p_eventIndex = this
			call TriggerEvaluate(triggerContainer)
			
			set this = next
		endloop
		
		call TriggerClearConditions(triggerContainer)
		call DestroyTrigger(triggerContainer)
		set triggerContainer = null
		
		set p_eventIndex = prevIndexedUnitId
	endmethod
	static method fireExpression takes boolexpr whichExpression returns nothing
		if (first != 0) then
			call p_fireExpression(whichExpression)
		endif
	endmethod
	
	static method addUnitIndex takes integer whichUnitIndex returns nothing
		if (isGameLoaded) then
			return
		endif
		
		call enqueue(whichUnitIndex)
	endmethod
	
	static method removeUnitIndex takes integer whichUnitIndex returns nothing
		if (isGameLoaded) then
			return
		endif
		
		call thistype(whichUnitIndex).remove()
	endmethod
	
	private static method run takes nothing returns nothing
		call DestroyTimer(GetExpiredTimer())
		
		set isGameLoaded = true
		
		call clear()
	endmethod
	private static method init takes nothing returns nothing
		call TimerStart(CreateTimer(), 0, false, function thistype.run)
	endmethod
	
	implement Init
endstruct
//! endtextmacro