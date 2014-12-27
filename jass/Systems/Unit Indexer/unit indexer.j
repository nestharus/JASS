/*
*	requires
*
*		Event
*		WorldBounds
*
*	struct UnitIndexer extends array
*
*		static boolean enabled = true
*
*		readonly static Trigger GlobalEvent.ON_INDEX
*		readonly static Trigger GlobalEvent.ON_DEINDEX
*		readonly Trigger Event.ON_DEINDEX
*
*		readonly UnitIndex eventIndex = 0
*		readonly unit eventUnit = null
*
*	private struct WrappedTrigger extends array
*
*		method reference takes Trigger whichTrigger returns nothing
*
*		method register takes boolexpr whichExpression returns nothing
*
*/

//! textmacro UNIT_INDEXER_UNIT_INDEXER
private struct WrappedTrigger extends array
	static if DEBUG_MODE then
		method reference takes Trigger whichTrigger returns TriggerReference
			return reference_p(whichTrigger)
		endmethod
		
		method register takes boolexpr whichExpression returns TriggerCondition
			return register_p(whichExpression)
		endmethod
		
		private method reference_p takes Trigger whichTrigger returns TriggerReference
			local TriggerReference triggerReference = Trigger(this).reference(whichTrigger)
			
			call PreGameEvent.fireTrigger(whichTrigger)
			
			return triggerReference
		endmethod
	
		private method register_p takes boolexpr whichExpression returns TriggerCondition
			local TriggerCondition triggerCondition = Trigger(this).register(whichExpression)
			
			call PreGameEvent.fireExpression(whichExpression)
			
			return triggerCondition
		endmethod
	else
		method reference takes Trigger whichTrigger returns TriggerReference
			local TriggerReference triggerReference = Trigger(this).reference(whichTrigger)
			
			call PreGameEvent.fireTrigger(whichTrigger)
			
			return triggerReference
		endmethod
	
		method register takes boolexpr whichExpression returns TriggerCondition
			local TriggerCondition triggerCondition = Trigger(this).register(whichExpression)
			
			call PreGameEvent.fireExpression(whichExpression)
			
			return triggerCondition
		endmethod
	endif
endstruct

private struct UnitIndexerTriggerGlobal extends array
	readonly static WrappedTrigger	ON_INDEX
	readonly static Trigger			ON_DEINDEX
	
	private static method init takes nothing returns nothing
		set ON_INDEX = Trigger.create(false)
		set ON_DEINDEX = Trigger.create(true)
	endmethod
	
	implement Init
endstruct

private keyword ON_DEINDEX_MAIN
private struct UnitIndexerTrigger extends array
	readonly Trigger ON_DEINDEX
	
	method createDeindex takes nothing returns nothing
		set ON_DEINDEX = Trigger.create(true)
		
		call ON_DEINDEX.reference(UnitIndexerTriggerGlobal.ON_DEINDEX)
	endmethod
	
	method destroyDeindex takes nothing returns nothing
		call ON_DEINDEX.destroy()
	endmethod
endstruct

struct UnitIndexer extends array
	private trigger deindexTrigger
	private static boolexpr onDeindexCondition

	static method operator eventIndex takes nothing returns UnitIndex
		return p_eventIndex
	endmethod
	static method operator eventUnit takes nothing returns unit
		return eventIndex.unit
	endmethod
	
	static method operator GlobalEvent takes nothing returns UnitIndexerTriggerGlobal
		return 0
	endmethod
	method operator Event takes nothing returns UnitIndexerTrigger
		return this
	endmethod

	static boolean enabled = true
	
	private static method fire takes Trigger whichTrigger, integer whichIndex returns nothing
		local integer prevIndexedUnit = p_eventIndex
		set p_eventIndex = whichIndex
		call whichTrigger.fire()
		set p_eventIndex = prevIndexedUnit
	endmethod
	
	private static method onIndex takes nothing returns boolean
		local unit indexedUnit = GetFilterUnit()
		local p_UnitIndex index
		
		if (enabled and not p_UnitIndex.exists(indexedUnit)) then
			set index = p_UnitIndex.create(indexedUnit)
			
			set thistype(index).deindexTrigger = CreateTrigger()
			call TriggerRegisterUnitEvent(thistype(index).deindexTrigger, indexedUnit, EVENT_UNIT_ISSUED_ORDER)
			call TriggerAddCondition(thistype(index).deindexTrigger, onDeindexCondition)
			
			call PreGameEvent.addUnitIndex(index)
			
			call thistype(index).Event.createDeindex()
			
			call fire(GlobalEvent.ON_INDEX, index)
		endif
		
		set indexedUnit = null
		
		return false
	endmethod
	
	private static method onDeindex takes nothing returns boolean
		local p_UnitIndex index = GetUnitUserData(GetTriggerUnit())
		
		if (GetUnitAbilityLevel(GetTriggerUnit(), ABILITIES_UNIT_INDEXER) == 0) then
			call PreGameEvent.removeUnitIndex(index)
			
			call fire(thistype(index).Event.ON_DEINDEX, index)
			
			call thistype(index).Event.destroyDeindex()
			
			call DestroyTrigger(thistype(index).deindexTrigger)
			set thistype(index).deindexTrigger = null
			
			call index.destroy()
		endif
		
		return false
	endmethod
	
	private static method init takes nothing returns nothing
		local trigger indexTrigger = CreateTrigger()
		
		local boolexpr onIndexCondition	 = Condition(function thistype.onIndex)
		
		local group enumGroup = CreateGroup()
		
		local integer currentPlayerId = 15
		local player currentPlayer
		
		set onDeindexCondition= Condition(function thistype.onDeindex)
		
		call TriggerRegisterEnterRegion(indexTrigger, WorldBounds.worldRegion, onIndexCondition)
		
		loop
			set currentPlayer = Player(currentPlayerId)
			
			call SetPlayerAbilityAvailable(currentPlayer, ABILITIES_UNIT_INDEXER, false)
			call GroupEnumUnitsOfPlayer(enumGroup, currentPlayer, onIndexCondition)
			
			exitwhen currentPlayerId == 0
			set currentPlayerId = currentPlayerId - 1
		endloop
		
		call DestroyGroup(enumGroup)
		
		set onIndexCondition = null
		
		set enumGroup = null
		set currentPlayer = null
		
		set indexTrigger = null
	endmethod
	
	implement Init
endstruct
//! endtextmacro