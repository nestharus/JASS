/*
*	requires
*
*		Event
*		MapBounds
*
*	struct UnitIndexer extends array
*
*		static boolean enabled = true
*
*		static constant Event Event.ON_INDEX
*		static constant Event Event.ON_DEINDEX
*
*		readonly UnitIndex eventIndex = 0
*		readonly unit eventUnit = null
*/

private struct WrappedEvent extends array
	method registerTrigger takes trigger whichTrigger returns nothing
		call Event(this).registerTrigger(whichTrigger)
		call PreGameEvent.fireTrigger(whichTrigger)
	endmethod
	
	method register takes boolexpr whichExpression returns nothing
		call Event(this).register(whichExpression)
		call PreGameEvent.fireExpression(whichExpression)
	endmethod
endstruct

private struct UnitIndexerEvent extends array
	readonly static WrappedEvent 	ON_INDEX
	readonly static Event 			ON_DEINDEX
	
	private static method init takes nothing returns nothing
		set ON_INDEX = Event.create()
		set ON_DEINDEX = Event.create()
	endmethod
	
	implement Init
endstruct

struct UnitIndexer extends array
	static method operator eventIndex takes nothing returns UnitIndex
		return p_eventIndex
	endmethod
	static method operator eventUnit takes nothing returns unit
		return eventIndex.unit
	endmethod
	static method operator Event takes nothing returns UnitIndexerEvent
		return 0
	endmethod

	static boolean enabled = true
	
	private static method fire takes Event whichEvent, integer whichIndex returns nothing
		local integer prevIndexedUnit = p_eventIndex
		set p_eventIndex = whichIndex
		call whichEvent.fire()
		set p_eventIndex = prevIndexedUnit
	endmethod
	
	private static method onIndex takes nothing returns boolean
		local unit indexedUnit = GetFilterUnit()
		local p_UnitIndex index
		
		if (enabled and p_UnitIndex.exists(indexedUnit)) then
			set index = p_UnitIndex.create(indexedUnit)
			
			call PreGameEvent.addUnitIndex(index)
			
			call fire(Event.ON_INDEX, index)
		endif
		
		set indexedUnit = null
		
		return false
	endmethod
	
	private static method onDeindex takes nothing returns boolean
		local unit deindexedUnit = GetFilterUnit()
		local p_UnitIndex index = GetUnitUserData(deindexedUnit)
		
		if (GetUnitAbilityLevel(deindexedUnit, ABILITIES_UNIT_INDEXER) == 0 and p_UnitIndex.exists(deindexedUnit)) then
			call PreGameEvent.removeUnitIndex(index)
			
			call fire(Event.ON_DEINDEX, index)
			
			call index.destroy()
		endif
		
		set deindexedUnit = null
		
		return false
	endmethod
	
	private static method init takes nothing returns nothing
		local trigger indexTrigger = CreateTrigger()
		local trigger deindexTrigger = CreateTrigger()
		
		local boolexpr onIndexCondition 	= Condition(function thistype.onIndex)
		local boolexpr onDeindexCondition 	= Condition(function thistype.onDeindex)
		
		local group enumGroup = CreateGroup()
		
		local integer currentPlayerId = 15
		local player currentPlayer
		
		call TriggerRegisterEnterRegion(indexTrigger, MapBounds.region, onIndexCondition)
		
		loop
			set currentPlayer = Player(currentPlayerId)
			
			call SetPlayerAbilityAvailable(currentPlayer, ABILITIES_UNIT_INDEXER, false)
			call TriggerRegisterPlayerUnitEvent(deindexTrigger, currentPlayer, EVENT_PLAYER_UNIT_ISSUED_ORDER, onDeindexCondition)
			call GroupEnumUnitsOfPlayer(enumGroup, currentPlayer, onIndexCondition)
			
			exitwhen currentPlayerId == 0
			set currentPlayerId = currentPlayerId - 1
		endloop
		
		call DestroyGroup(enumGroup)
		
		set onIndexCondition = null
		set onDeindexCondition = null
		
		set enumGroup = null
		set currentPlayer = null
		
		set indexTrigger = null
		set deindexTrigger = null
	endmethod
	
	implement Init
endstruct