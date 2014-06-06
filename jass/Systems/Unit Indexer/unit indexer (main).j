library UnitIndexer /* v5.3.0.1
************************************************************************************
*
*	*/ uses /*
*
*		*/ WorldBounds			/*
*		*/ Init					/*
*		*/ AllocQ				/*
*		*/ ErrorMessage 		/*
*		*/ StaticUniqueList 	/*
*		*/ UnitIndexerSettings 	/*
*		*/ Trigger				/*
*
********************************************************************************
*
*	struct UnitIndexer extends array
*
*		Fields
*		-------------------------
*
*			static boolean enabled
*				-	is UnitIndexer onUnitIndex enabled?
*
*			readonly static Trigger GlobalEvent.ON_INDEX
*				-	this is a global event that runs whenever any unit is indexed
*
*				Examples:	UnitIndexer.GlobalEvent.ON_INDEX.reference(yourTrigger)
*							UnitIndexer.GlobalEvent.ON_INDEX.register(yourCode)
*
*				Examples:	unitIndex.indexer.Event.ON_DEINDEX.reference(yourTrigger)
*							unitIndex.indexer.Event.ON_DEINDEX.register(yourCode)
*
*			readonly Trigger Event.ON_DEINDEX
*				-	this is a local event that runs whenever a specific unit is deindexed
*
*				Examples:	unitIndex.indexer.Event.ON_DEINDEX.reference(yourTrigger)
*							unitIndex.indexer.Event.ON_DEINDEX.register(yourCode)
*
*			readonly static Trigger GlobalEvent.ON_DEINDEX
*				-	this is ON_DEINDEX, but global
*
*				Examples:	UnitIndexer.GlobalEvent.ON_DEINDEX.reference(yourTrigger)
*							UnitIndexer.GlobalEvent.ON_DEINDEX.register(yourCode)
*
*			readonly static UnitIndex eventIndex
*				-	when a unit is indexed or deindexed, this value stores
*					the index of that unit
*
*			readonly static unit eventUnit
*				-	when a unit is indexed or deindexed, this value stores
*					the unit
*
************************************************************************************
*
*	struct UnitIndex extends array
*
*		Fields
*		-------------------------
*
*			readonly unit unit
*				-	converts a unit index into a unit
*
*			readonly UnitIndexer indexer
*				-	the indexer in charge of handling the unit
*					useful for deindex event, which is unit specific
*
*		Operators
*		-------------------------
*
*			static method operator [] takes unit whichUnit returns UnitIndex
*				-	converts a unit into a UnitIndex
*
*		Methods
*		-------------------------
*
*			static method exists takes unit whichUnit returns boolean
*				-	determines whether the unit is indexed or not
*
*			static method isDeindexing takes unit whichUnit returns boolean
*				-	determines whether the unit is in the process of being deindexed or not
*
************************************************************************************
*
*	module GlobalUnitIndex
*
*		This has absolutely no module support
*
*		Fields
*		-------------------------
*
*			static constant boolean GLOBAL_UNIT_INDEX = true
*				-	this is used to ensure that only one unit index module is implemented.
*
*			readonly unit unit
*				-	converts a unit index into a unit
*
*			readonly boolean isUnitIndexed
*				-	is the unit index indexed
*
*			readonly UnitIndexer unitIndexer
*				-	the indexer in charge of handling the unit
*					useful for deindex event, which is unit specific
*
*		Methods
*		-------------------------
*
*			static method exists takes unit whichUnit returns boolean
*				-	determines whether the unit is indexed
*
*			static method isDeindexing takes unit whichUnit returns boolean
*				-	determines whether the unit is in the process of being deindexed or not
*
*		Interface
*		-------------------------
*
*			interface private method onUnitIndex takes nothing returns nothing
*			interface private method onUnitDeindex takes nothing returns nothing
*
*		Operators
*		-------------------------
*
*			static method operator [] takes unit whichUnit returns thistype
*				-	converts a unit into thistype
*
************************************************************************************
*
*	module UnitIndex
*
*		If you would like to create modules that work off of the UnitIndex module, implement
*		UnitIndex at the top of your module
*		
*		Fields
*		-------------------------
*
*			static constant boolean UNIT_INDEX = true
*				-	this is used to ensure that only one unit index module is implemented.
*
*			static boolean enabled
*				-	is this UnitIndex struct enabled?
*				-	this can only be disabed if onUnitIndex exists
*
*			readonly unit unit
*				-	converts a unit index into a unit
*
*			readonly boolean isUnitIndexed
*				-	is the unit index indexed for the struct?
*
*			readonly UnitIndexer unitIndexer
*				-	the indexer in charge of handling the unit
*					useful for deindex event, which is unit specific
*
*		Operators
*		-------------------------
*
*			static method operator [] takes unit whichUnit returns thistype
*				-	converts a unit into thistype
*
*		Methods
*		-------------------------
*
*			static method exists takes unit whichUnit returns boolean
*				-	determines whether the unit is indexed or not for the struct
*
*			static method isDeindexing takes unit whichUnit returns boolean
*				-	determines whether the unit is in the process of being deindexed or not
*
*		Interface
*		-------------------------
*
*			interface private method onUnitIndex takes nothing returns boolean
*				-	if return true, index the unit for this struct
*
*			interface private method onUnitDeindex takes nothing returns nothing
*				-	only runs for units indexed for this struct
*				-	if not onUnitIndex method is declared, it will run for all units
*
************************************************************************************
*
*	module UnitIndexEx
*
*		If you would like to create modules that work off of the UnitIndexEx module, implement
*		UnitIndexEx at the top of your module
*		
*		Fields
*		-------------------------
*
*			static constant boolean UNIT_INDEX_EX = true
*				-	this is used for modules that rely on local events
*					it allows these modules to differentiate between UnitIndex
*					and UnitIndexEx
*
*			static boolean enabled
*				-	is this UnitIndex struct enabled?
*				-	this can only be disabed if onUnitIndex exists
*
*			readonly unit unit
*				-	converts a unit index into a unit
*
*			readonly boolean isUnitIndexed
*				-	is the unit index indexed for the struct?
*
*			readonly UnitIndexer unitIndexer
*				-	the indexer in charge of handling the unit
*					useful for deindex event, which is unit specific
*
*			readonly static Trigger ON_INDEX
*				-	this is a local event that runs whenever any unit is indexed for the struct
*				-	this is primarily used for other resources that work off of your struct
*
*				Examples:	Struct.ON_INDEX.reference(yourTrigger)
*							Struct.ON_INDEX.register(yourCode)
*
*			readonly Trigger Event.ON_DEINDEX
*			readonly static Trigger Event.ON_DEINDEX
*				-	this is a unit specific event that runs when your local unit is deindexed
*				-	this is static if onUnitIndex does not exist
*
*				Examples:	struct.ON_DEINDEX.reference(yourTrigger)
*							struct.ON_DEINDEX.register(yourCode)
*
*		Operators
*		-------------------------
*
*			static method operator [] takes unit whichUnit returns thistype
*				-	converts a unit into thistype
*
*		Methods
*		-------------------------
*
*			static method exists takes unit whichUnit returns boolean
*				-	determines whether the unit is indexed or not for the struct
*
*			static method isDeindexing takes unit whichUnit returns boolean
*				-	determines whether the unit is in the process of being deindexed or not
*
*		Interface
*		-------------------------
*
*			interface private method onUnitIndex takes nothing returns boolean
*				-	if return true, index the unit for this struct
*
*			interface private method onUnitDeindex takes nothing returns nothing
*				-	only runs for units indexed for this struct
*				-	if not onUnitIndex method is declared, it will run for all units
*
************************************************************************************
*
*	//! textmacro CREATE_LOCAL_UNIT_INDEX
*
*		A macro was chosen because multiple modules utilizing this code may be
*		implemented into one struct. If this was a module, then all but one
*		of those modules would break.
*
*		Interface
*		-------------------------
*
*			interface private method onLocalUnitIndex takes nothing returns nothing
*				-	runs whenever a unit is indexed for this struct
*
*			interface private method onLocalUnitDeindex takes nothing returns nothing
*				-	runs whenever a unit is deindexed for this struct
*
*			interface private static method localInit takes nothing returns nothing
*				-	the macro requires the usage of onInit. Declare this method if you
*					would like onInit.
*
************************************************************************************/
	globals
		private UnitIndex p_eventIndex = 0
	endglobals

	//! runtextmacro UNIT_INDEXER_UNIT_INDEX()
	//! runtextmacro UNIT_INDEXER_PREGAME_EVENT()
	//! runtextmacro UNIT_INDEXER_UNIT_INDEXER()
	
	module GlobalUnitIndex
		static if thistype.UNIT_INDEX then
		elseif thistype.UNIT_INDEX_EX then
		else
			static constant boolean GLOBAL_UNIT_INDEX = true
			
			static method operator [] takes unit whichUnit returns thistype
				return p_UnitIndex[whichUnit]
			endmethod
			method operator unit takes nothing returns unit
				return p_UnitIndex(this).unit
			endmethod
			method operator unitIndexer takes nothing returns UnitIndexer
				return p_UnitIndex(this).indexer
			endmethod
			method operator isUnitIndexed takes nothing returns boolean
				return p_UnitIndex(this).isAllocated
			endmethod
			static method exists takes unit whichUnit returns boolean
				return p_UnitIndex.exists(whichUnit)
			endmethod
			static method isDeindexing takes unit whichUnit returns boolean
				return p_UnitIndex.isDeindexing(whichUnit)
			endmethod
			
			static if thistype.GLOBAL_UNIT_INDEX then
				static if thistype.onUnitIndex.exists then
					private static method onIndexEvent takes nothing returns boolean
						call thistype(UnitIndexer.eventIndex).onUnitIndex()
					
						return false
					endmethod
				endif
				static if thistype.onUnitDeindex.exists then
					private static method onDeindexEvent takes nothing returns boolean
						call thistype(UnitIndexer.eventIndex).onUnitDeindex()
						
						return false
					endmethod
				endif
				
				static if thistype.onUnitIndex.exists then
					private static method onInit takes nothing returns nothing
				elseif thistype.onUnitDeindex.exists then
					private static method onInit takes nothing returns nothing
				endif
				
				static if thistype.onUnitIndex.exists then
					call UnitIndexer.GlobalEvent.ON_INDEX.register(Condition(function thistype.onIndexEvent))
				endif
				
				static if thistype.onUnitDeindex.exists then
					call UnitIndexer.GlobalEvent.ON_DEINDEX.register(Condition(function thistype.onDeindexEvent))
				endif
				
				static if thistype.onUnitIndex.exists then
					endmethod
				elseif thistype.onUnitDeindex.exists then
					endmethod
				endif
			endif
		endif
	endmodule
	
	module UnitIndex
		static if thistype.GLOBAL_UNIT_INDEX then
			private static method error takes nothing returns nothing
				A module requires UnitIndex to operate correctly.
				This struct is currently implementing GlobalUnitIndex.
			endmethod
		elseif thistype.UNIT_INDEX_EX then
		else
			static constant boolean UNIT_INDEX = true
			
			/*
			*	[] is included because the struct automatically overrides it
			*
			*	eventIndex is included to return thistype instead of UnitIndex
			*/
			static method operator [] takes unit whichUnit returns thistype
				return UnitIndex[whichUnit]
			endmethod
			method operator unitIndexer takes nothing returns UnitIndexer
				return this
			endmethod
			method operator unit takes nothing returns unit
				return UnitIndex(this).unit
			endmethod
			
			static method isDeindexing takes unit whichUnit returns boolean
				return UnitIndex.isDeindexing(whichUnit)
			endmethod
			
			/*
			*	the method is done in the second case because when there is no
			*	onUnitIndex method, indexed depends on whether the actual
			*	instance is allocated or not
			*/
			static if thistype.onUnitIndex.exists then
				readonly boolean isUnitIndexed
			else
				method operator isUnitIndexed takes nothing returns boolean
					return p_UnitIndex(this).isAllocated
				endmethod
			endif
			
			static if thistype.onUnitIndex.exists then
				static method exists takes unit whichUnit returns boolean
					return UnitIndex.exists(whichUnit) and thistype(GetUnitUserData(whichUnit)).isUnitIndexed
				endmethod
			else
				static method exists takes unit whichUnit returns boolean
					return UnitIndex.exists(whichUnit)
				endmethod
			endif
			
			/*
			*	this is used to run local events
			*/
			static if thistype.onUnitIndex.exists then
				/*
				*	this is where UnitIndex is located
				*/
				private static TriggerCondition entryPoint
				
				/*
				*	this stores private onUnitIndex method
				*/
				private static boolexpr onIndexExpression
				
				/*
				*	enable works with code inside of entryPoint here
				*/
				private static boolean p_enabled = true
				static method operator enabled takes nothing returns boolean
					return p_enabled
				endmethod
				static method operator enabled= takes boolean enable returns nothing
					set p_enabled = enable
					
					if (enable) then
						call entryPoint.replace(onIndexExpression)
					else
						call entryPoint.replace(null)
					endif
				endmethod
			else
				/*
				*	if onUnitIndex does not exist, the struct can't be disabled
				*/
				static method operator enabled takes nothing returns boolean
					return true
				endmethod
				static method operator enabled= takes boolean enable returns nothing
					set enable = true
				endmethod
			endif
			
			/*
			*	onUnitDeindex
			*
			*	This must be implemented if onUnitIndex exists to clear isUnitIndexed
			*/
			static if thistype.onUnitDeindex.exists then
				static if thistype.onUnitIndex.exists then
					private static boolexpr onDeindexExpression
				endif
				
				private static method onDeindexEvent takes nothing returns boolean
					call thistype(UnitIndexer.eventIndex).onUnitDeindex()
					
					static if thistype.onUnitIndex.exists then
						set thistype(UnitIndexer.eventIndex).isUnitIndexed = false
					endif
					
					return false
				endmethod
			elseif thistype.onUnitIndex.exists then
				static if thistype.onUnitIndex.exists then
					private static boolexpr onDeindexExpression
				endif
				
				private static method onDeindexEvent takes nothing returns boolean
					set thistype(UnitIndexer.eventIndex).isUnitIndexed = false
					
					return false
				endmethod
			endif
			
			/*
			*	onUnitIndex
			*/
			static if thistype.onUnitIndex.exists then
				private static method onIndexEvent takes nothing returns boolean
					if (thistype(UnitIndexer.eventIndex).onUnitIndex()) then
						set thistype(UnitIndexer.eventIndex).isUnitIndexed = true
						
						/*
						*	this is always registered to clear isUnitIndexed
						*/
						call UnitIndexer(UnitIndexer.eventIndex).Event.ON_DEINDEX.register(onDeindexExpression)
					endif
					
					return false
				endmethod
			endif
			
			static if thistype.onUnitIndex.exists then
				private static method onInit takes nothing returns nothing
					set onIndexExpression = Condition(function thistype.onIndexEvent)
					set onDeindexExpression = Condition(function thistype.onDeindexEvent)
					
					set entryPoint = UnitIndexer.GlobalEvent.ON_INDEX.register(Condition(function thistype.onIndexEvent))
				endmethod
			elseif thistype.onUnitDeindex.exists then
				private static method onInit takes nothing returns nothing
					call UnitIndexer.GlobalEvent.ON_DEINDEX.register(Condition(function thistype.onDeindexEvent))
				endmethod
			endif
		endif
	endmodule
	
	private struct UnitIndexList extends array
		//! runtextmacro CREATE_TABLE_FIELD("public", "integer", "unitIndex2Node", "thistype")
		//! runtextmacro CREATE_TABLE_FIELD("public", "integer", "node2UnitIndex", "thistype")
		
		method add takes thistype index returns nothing
			local thistype node = enqueue()
			
			set node.node2UnitIndex = index
			set index.unitIndex2Node = node
		endmethod
		
		method delete takes nothing returns nothing
			call unitIndex2Node.remove()
		endmethod
		
		private static method init takes nothing returns nothing
			//! runtextmacro INITIALIZE_TABLE_FIELD("unitIndex2Node")
			//! runtextmacro INITIALIZE_TABLE_FIELD("node2UnitIndex")
		endmethod
		
		implement NxListT
		implement Init
	endstruct
	private struct UnitIndexModuleTrigger extends array
		method reference takes Trigger whichTrigger returns TriggerReference
			local TriggerReference triggerReference = Trigger(this).reference(whichTrigger)
			
			local UnitIndexList node = UnitIndexList(this).first
			local integer prevIndexedUnitId = p_eventIndex
			
			loop
				exitwhen node == UnitIndexList.sentinel or not whichTrigger.enabled
				
				set p_eventIndex = node.node2UnitIndex
				call whichTrigger.fire()
					
				set node = node.next
			endloop
			
			set p_eventIndex = prevIndexedUnitId
			
			return triggerReference
		endmethod
		
		method register takes boolexpr whichExpression returns TriggerCondition
			local TriggerCondition triggerCondition = Trigger(this).register(whichExpression)
			
			local trigger triggerContainer = CreateTrigger()
			
			local UnitIndexList node = UnitIndexList(this).first
			local integer prevIndexedUnitId = p_eventIndex
			
			call TriggerAddCondition(triggerContainer, whichExpression)
			
			loop
				exitwhen node == UnitIndexList.sentinel
				
				set p_eventIndex = node.node2UnitIndex
				call TriggerEvaluate(triggerContainer)
					
				set node = node.next
			endloop
			
			call TriggerClearConditions(triggerContainer)
			call DestroyTrigger(triggerContainer)
			set triggerContainer = null
			
			set p_eventIndex = prevIndexedUnitId
			
			return triggerCondition
		endmethod
	endstruct
	module UnitIndexEx
		static if thistype.GLOBAL_UNIT_INDEX then
			private static method error takes nothing returns nothing
				A module requires UnitIndexEx to operate correctly.
				This struct is currently implementing GlobalUnitIndex.
			endmethod
		elseif thistype.UNIT_INDEX then
			private static method error takes nothing returns nothing
				A module requires UnitIndexEx to operate correctly.
				This struct is currently implementing UnitIndex.
			endmethod
		else
			static constant boolean UNIT_INDEX_EX = true
			
			private static UnitIndex delegate unitIndex = 0
		
			/*
			*	[] is included because the struct automatically overrides it
			*
			*	eventIndex is included to return thistype instead of UnitIndex
			*/
			static method operator [] takes unit whichUnit returns thistype
				return UnitIndex[whichUnit]
			endmethod
			method operator unit takes nothing returns unit
				return UnitIndex(this).unit
			endmethod
			method operator unitIndexer takes nothing returns UnitIndexer
				return this
			endmethod
			
			static method isDeindexing takes unit whichUnit returns boolean
				return UnitIndex.isDeindexing(whichUnit)
			endmethod
			
			/*
			*	the method is done in the second case because when there is no
			*	onUnitIndex method, indexed depends on whether the actual
			*	instance is allocated or not
			*/
			static if thistype.onUnitIndex.exists then
				readonly boolean isUnitIndexed
			else
				method operator isUnitIndexed takes nothing returns boolean
					return p_UnitIndex(this).isAllocated
				endmethod
			endif
			
			static if thistype.onUnitIndex.exists then
				static method exists takes unit whichUnit returns boolean
					return UnitIndex.exists(whichUnit) and thistype(GetUnitUserData(whichUnit)).isUnitIndexed
				endmethod
			else
				static method exists takes unit whichUnit returns boolean
					return UnitIndex.exists(whichUnit)
				endmethod
			endif
		
			/*
			*	this is used to run local events
			*/
			static if thistype.onUnitIndex.exists then
				readonly static UnitIndexModuleTrigger ON_INDEX
			else
				readonly static WrappedTrigger ON_INDEX
			endif
			
			static if thistype.onUnitIndex.exists then
				/*
				*	this is where UnitIndex is located
				*/
				private static TriggerCondition entryPoint
				
				/*
				*	this stores private onUnitIndex method
				*/
				private static boolexpr onIndexExpression
				
				/*
				*	enable works with code inside of entryPoint here
				*/
				private static boolean p_enabled = true
				static method operator enabled takes nothing returns boolean
					return p_enabled
				endmethod
				static method operator enabled= takes boolean enable returns nothing
					set p_enabled = enable
					
					if (enable) then
						call entryPoint.replace(onIndexExpression)
					else
						call entryPoint.replace(null)
					endif
				endmethod
			else
				/*
				*	if onUnitIndex does not exist, the struct can't be disabled
				*/
				static method operator enabled takes nothing returns boolean
					return true
				endmethod
				static method operator enabled= takes boolean enable returns nothing
					set enable = true
				endmethod
			endif
			
			/*
			*	this is here so that the module runs after code that relies on the module
			*/
			static if thistype.onUnitIndex.exists then
				readonly Trigger ON_DEINDEX
			else
				readonly static Trigger ON_DEINDEX
			endif
			
			/*
			*	onUnitDeindex
			*/
			static if thistype.onUnitDeindex.exists then
				static if thistype.onUnitIndex.exists then
					private static boolexpr onDeindexExpression
				endif
				
				private static method onDeindexEvent takes nothing returns boolean
					call thistype(UnitIndexer.eventIndex).onUnitDeindex()
					
					static if thistype.onUnitIndex.exists then
						set thistype(UnitIndexer.eventIndex).isUnitIndexed = false
						
						call thistype(UnitIndexer.eventIndex).ON_DEINDEX.destroy()
						
						if (not PreGameEvent.isGameLoaded) then
							call UnitIndexList(UnitIndexer.eventIndex).delete()
						endif
					endif
					
					return false
				endmethod
			elseif thistype.onUnitIndex.exists then
				private static boolexpr onDeindexExpression
				
				private static method onDeindexEvent takes nothing returns boolean
					set thistype(UnitIndexer.eventIndex).isUnitIndexed = false
					
					call thistype(UnitIndexer.eventIndex).ON_DEINDEX.destroy()
					
					if (not PreGameEvent.isGameLoaded) then
						call UnitIndexList(UnitIndexer.eventIndex).delete()
					endif
					
					return false
				endmethod
			endif
			
			/*
			*	onUnitIndex
			*/
			static if thistype.onUnitIndex.exists then
				private static method onIndexEvent takes nothing returns boolean
					if (thistype(UnitIndexer.eventIndex).onUnitIndex()) then
						set thistype(UnitIndexer.eventIndex).isUnitIndexed = true
						
						set thistype(UnitIndexer.eventIndex).ON_DEINDEX = Trigger.create(true)
						call thistype(UnitIndexer.eventIndex).ON_DEINDEX.register(onDeindexExpression)

						call UnitIndexer(UnitIndexer.eventIndex).Event.ON_DEINDEX.reference(thistype(UnitIndexer.eventIndex).ON_DEINDEX)
						
						if (not PreGameEvent.isGameLoaded) then
							call UnitIndexList(ON_INDEX).add(UnitIndexer.eventIndex)
						endif
						
						call Trigger(thistype.ON_INDEX).fire()
					endif
					
					return false
				endmethod
			endif
			
			private static method destroyPregameUnitList takes nothing returns nothing
				call DestroyTimer(GetExpiredTimer())
				
				call UnitIndexList(ON_INDEX).destroy()
			endmethod
			
			private static method onInit takes nothing returns nothing
				set ON_INDEX = Trigger.create(false)
				
				static if thistype.onUnitIndex.exists then
					set onIndexExpression = Condition(function thistype.onIndexEvent)
					set onDeindexExpression = Condition(function thistype.onDeindexEvent)
					
					call UnitIndexList(ON_INDEX).clear()
					
					call TimerStart(CreateTimer(), 0, false, function thistype.destroyPregameUnitList)
					
					set entryPoint = UnitIndexer.GlobalEvent.ON_INDEX.register(Condition(function thistype.onIndexEvent))
				else
					set ON_DEINDEX = Trigger.create(true)
					static if thistype.onUnitDeindex.exists then
						call ON_DEINDEX.register(Condition(function thistype.onDeindexEvent))
					endif
					
					call UnitIndexer.GlobalEvent.ON_DEINDEX.reference(ON_DEINDEX)
					call UnitIndexer.GlobalEvent.ON_INDEX.reference(ON_INDEX)
				endif
			endmethod
		endif
	endmodule
	
	//! textmacro CREATE_LOCAL_UNIT_INDEX
		/*
		*	There are three cases
		*
		*		Case 1: UnitIndex is implemented
		*		Case 2: UnitIndexEx is implemented
		*		Case 3: Nothing is implemented, go to Case 2
		*/
		static if thistype.UNIT_INDEX then
			/*
			*	Here, UnitIndex is implemented
			*/
			
			/*
			*	There are two cases
			*
			*		onUnitEvent exists, which means that events are conditionally local
			*		onUnitEven does not exist, meaning all events are global
			*/
			static if thistype.onUnitIndex.exists then
				/*
				*	Here, events are conditionally local
				*/
				
				static if thistype.onLocalUnitDeindex.exists then
					private static boolexpr onLocalUnitDeindexEventExpr
				endif
			
				static if thistype.onLocalUnitIndex.exists then
					/*
					*	The user has a local unit index event
					*/
					private static method onLocalUnitIndexEvent takes nothing returns boolean
						/*
						*	Here, the event is only run if the unit happened to be indexed
						*/
						if (thistype(UnitIndexer.eventIndex).isUnitIndexed) then
							static if thistype.onLocalUnitDeindex.exists then
								call UnitIndexer.eventIndex.indexer.Event.ON_DEINDEX.register(onLocalUnitDeindexEventExpr)
							endif
							
							call thistype(UnitIndexer.eventIndex).onLocalUnitIndex()
						endif
						
						return false
					endmethod
				elseif thistype.onLocalUnitDeindex.exists then
					/*
					*	The user did not declare a local unit index event
					*
					*	onLocalUnitIndexEvent is still required because the deindex events are local
					*/
					private static method onLocalUnitIndexEvent takes nothing returns boolean
						if (thistype(UnitIndexer.eventIndex).isUnitIndexed) then
							call UnitIndexer.eventIndex.indexer.Event.ON_DEINDEX.register(onLocalUnitDeindexEventExpr)
						endif
						
						return false
					endmethod
				endif
				
				static if thistype.onLocalUnitDeindex.exists then
					private static method onLocalUnitDeindexEvent takes nothing returns boolean
						call thistype(UnitIndexer.eventIndex).onLocalUnitDeindex()
						return false
					endmethod
				endif
				
				/*
				*	onLocalUnitDeindexEvent is not registered globally here because these are local
				*	events. It must be created inside of onLocalUnitIndexEvent whether or not
				*	onLocalUnitIndex exists.
				*/
				static if thistype.onLocalUnitIndex.exists then
					private static method onInit takes nothing returns nothing
						static if thistype.onLocalUnitDeindex.exists then
							set onLocalUnitDeindexEventExpr = Condition(function thistype.onLocalUnitDeindexEvent)
						endif
						
						call UnitIndexer.GlobalEvent.ON_INDEX.register(Condition(function thistype.onLocalUnitIndexEvent))
						
						static if thistype.localInit.exists then
							call localInit()
						endif
					endmethod
				elseif thistype.onLocalUnitDeindex.exists then
					private static method onInit takes nothing returns nothing
						set onLocalUnitDeindexEventExpr = Condition(function thistype.onLocalUnitDeindexEvent)
							
						call UnitIndexer.GlobalEvent.ON_INDEX.register(Condition(function thistype.onLocalUnitIndexEvent))
						
						static if thistype.localInit.exists then
							call localInit()
						endif
					endmethod
				endif
			else
				/*
				*	Here, all events are global
				*/
				static if thistype.onLocalUnitIndex.exists then
					private static method onLocalUnitIndexEvent takes nothing returns boolean
						call thistype(UnitIndexer.eventIndex).onLocalUnitIndex()
						return false
					endmethod
				endif
				
				static if thistype.onLocalUnitDeindex.exists then
					private static method onLocalUnitDeindexEvent takes nothing returns boolean
						call thistype(UnitIndexer.eventIndex).onLocalUnitDeindex()
						return false
					endmethod
				endif
				
				static if thistype.onLocalUnitIndex.exists then
					private static method onInit takes nothing returns nothing
						static if thistype.onLocalUnitDeindex.exists then
							call UnitIndexer.GlobalEvent.ON_DEINDEX.register(Condition(function thistype.onLocalUnitDeindexEvent))
						endif
						
						call UnitIndexer.GlobalEvent.ON_INDEX.register(Condition(function thistype.onLocalUnitIndexEvent))
						
						static if thistype.localInit.exists then
							call localInit()
						endif
					endmethod
				elseif thistype.onLocalUnitDeindex.exists then
					private static method onInit takes nothing returns nothing
						call UnitIndexer.GlobalEvent.ON_DEINDEX.register(Condition(function thistype.onLocalUnitDeindexEvent))
						
						static if thistype.localInit.exists then
							call localInit()
						endif
					endmethod
				endif
			endif
		elseif thistype.GLOBAL_UNIT_INDEX then
			private static method error takes nothing returns nothing
				A module requires either UnitIndex or UnitIndexEx to operate correctly.
				This struct is currently implementing GlobalUnitIndex.
			endmethod
		else
			/*
			*	Here, UnitIndexEx is either implemented or nothing is implemented
			*
			*	Implement UnitIndexEx and work with its local events
			*/
			implement UnitIndexEx
			
			static if thistype.onUnitIndex.exists then
				/*
				*	local events
				*/
				static if thistype.onLocalUnitDeindex.exists then
					private static boolexpr onLocalUnitDeindexEventExpr
				endif
				
				/*
				*	if onUnitIndex exists, then onLocalUnitDeindex is local
				*
				*	this means that if onLocalUnitDeindex exists, the onLocalUnitIndexEvent must be
				*	made so that it can register onLocalUnitDeindex locally
				*/
				static if thistype.onLocalUnitIndex.exists then
					private static method onLocalUnitIndexEvent takes nothing returns boolean
						static if thistype.onLocalUnitDeindex.exists then
							call thistype(UnitIndexer.eventIndex).ON_DEINDEX.register(onLocalUnitDeindexEventExpr)
						endif
						
						call thistype(UnitIndexer.eventIndex).onLocalUnitIndex()
						
						return false
					endmethod
				elseif thistype.onLocalUnitDeindex.exists then
					private static method onLocalUnitIndexEvent takes nothing returns boolean
						call thistype(UnitIndexer.eventIndex).ON_DEINDEX.register(onLocalUnitDeindexEventExpr)
							
						return false
					endmethod
				endif
			elseif thistype.onLocalUnitIndex.exists then
				/*
				*	global events
				*
				*		onLocalUnitDeindex is run globally, so it doesn't need onLocalUnitIndexEvent
				*		anymore
				*/
				private static method onLocalUnitIndexEvent takes nothing returns boolean
					call thistype(UnitIndexer.eventIndex).onLocalUnitIndex()
					
					return false
				endmethod
			endif
			
			static if thistype.onLocalUnitDeindex.exists then
				private static method onLocalUnitDeindexEvent takes nothing returns boolean
					call thistype(UnitIndexer.eventIndex).onLocalUnitDeindex()
					
					return false
				endmethod
			endif
			
			/*
			*	The reason why ON_INDEX is used is so that the module can be enabled/disabled
			*	correctly
			*/
			private static method onInit takes nothing returns nothing
				static if thistype.onUnitIndex.exists then
					/*
					*	local events
					*/
					static if thistype.onLocalUnitDeindex.exists then
						set onLocalUnitDeindexEventExpr = Condition(function thistype.onLocalUnitDeindexEvent)
					endif
					
					/*
					*	onLocalUnitIndexEvent is registered for onLocalUnitdeindex because onLocalUnitDeindex
					*	must be registered to each unit. This means that it must register as units are indexed.
					*/
					static if thistype.onLocalUnitIndex.exists then
						call thistype.ON_INDEX.register(Condition(function thistype.onLocalUnitIndexEvent))
					elseif thistype.onLocalUnitDeindex.exists then
						call thistype.ON_INDEX.register(Condition(function thistype.onLocalUnitIndexEvent))
					endif
				else
					/*
					*	global events
					*
					*	ON_DEINDEX is used here instead of UnitIndexer.GlobalEvent.ON_DEINDEX for proper
					*	execution order
					*/
					
					static if thistype.onLocalUnitDeindex.exists then
						call thistype.ON_DEINDEX.register(Condition(function thistype.onLocalUnitDeindexEvent))
					endif
					
					static if thistype.onLocalUnitIndex.exists then
						call thistype.ON_INDEX.register(Condition(function thistype.onLocalUnitIndexEvent))
					endif
				endif
				
				static if thistype.localInit.exists then
					call localInit()
				endif
			endmethod
		endif
	//! endtextmacro
endlibrary