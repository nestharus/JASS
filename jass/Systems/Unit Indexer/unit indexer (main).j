library UnitIndexer /* v5.0.1.1
************************************************************************************
*
*   */ uses /*
*   
*       */ WorldBounds         	/*
*       */ Init              	/*
*       */ AllocQ               /*
*		*/ ErrorMessage 		/*
*		*/ StaticUniqueList 	/*
*		*/ UnitIndexerSettings 	/*
*		*/ Trigger				/*
*
************************************************************************************
*
*   struct UnitIndexer extends array
*
*       Fields
*       -------------------------
*
*       	static boolean enabled
*				-	is UnitIndexer onUnitIndex enabled?
*
*       	readonly static Trigger GlobalEvent.ON_INDEX
*				-	this is a global event that runs whenever any unit is indexed
*
*				Examples:	UnitIndexer.GlobalEvent.ON_INDEX.reference(yourTrigger)
*							UnitIndexer.GlobalEvent.ON_INDEX.register(yourCode)
*
*			readonly Trigger Event.ON_DEINDEX
*				-	this is a unit specific event that runs when your unit is deindexed
*
*				Examples:	unitIndex.indexer.Event.ON_DEINDEX.reference(yourTrigger)
*							unitIndex.indexer.Event.ON_DEINDEX.register(yourCode)
*
*			readonly static Trigger GlobalEvent.ON_DEINDEX
*				-	this is ON_DEINDEX, but global
*				-	this runs after unit specific deindex events
*
*				Examples:	UnitIndexer.GlobalEvent.ON_DEINDEX.reference(yourTrigger)
*							UnitIndexer.GlobalEvent.ON_DEINDEX.register(yourCode)
*
*       	readonly static UnitIndex eventIndex
*				-	when a unit is indexed or deindexed, this value stores
*					the index of that unit
*
*       	readonly static unit eventUnit
*				-	when a unit is indexed or deindexed, this value stores
*					the unit
*
************************************************************************************
*
*   struct UnitIndex extends array
*
*       Fields
*       -------------------------
*
*       	readonly unit unit
*				-	converts a unit index into a unit
*
*			readonly UnitIndexer indexer
*				-	the indexer in charge of handling the unit
*					useful for deindex event, which is unit specific
*
*		Operators
*		-------------------------
*
*       	static method operator [] takes unit whichUnit returns UnitIndex
*				-	converts a unit into a UnitIndex
*
*       Methods
*       -------------------------
*
*       	static method exists takes unit whichUnit returns boolean
*				-	determines whether the unit is indexed or not
*
*       	static method isDeindexing takes unit whichUnit returns boolean
*				-	determines whether the unit is in the process of being deindexed or not
*
************************************************************************************
*
*   module UnitIndex
*           
*       Fields
*       -------------------------
*
*			static boolean enabled
*				-	is UnitIndexer onUnitIndex enabled?
*
*           readonly static thistype eventIndex
*				-	when a unit is indexed or deindexed, this value stores
*					the index of that unit
*
*			readonly static unit eventUnit
*				-	when a unit is indexed or deindexed, this value stores
*					the unit
*
*           readonly unit unit
*				-	converts a unit index into a unit
*
*			readonly boolean isIndexed
*				-	is the unit index indexed for the struct?
*
*			readonly UnitIndexer indexer
*				-	the indexer in charge of handling the unit
*					useful for deindex event, which is unit specific
*
*			readonly static Trigger GlobalEvent.ON_INDEX
*				-	this is a global event that runs whenever any unit is indexed
*
*				Examples:	Struct.GlobalEvent.ON_INDEX.reference(yourTrigger)
*							Struct.GlobalEvent.ON_INDEX.register(yourCode)
*
*			readonly Trigger Event.ON_DEINDEX
*				-	this is a unit specific event that runs when your unit is deindexed
*
*				Examples:	struct.Event.ON_DEINDEX.reference(yourTrigger)
*							struct.Event.ON_DEINDEX.register(yourCode)
*
*			readonly static Trigger GlobalEvent.ON_DEINDEX
*				-	this is ON_DEINDEX, but global
*				-	this runs after unit specific deindex events
*
*				Examples:	Struct.GlobalEvent.ON_DEINDEX.reference(yourTrigger)
*							Struct.GlobalEvent.ON_DEINDEX.register(yourCode)
*
*		Operators
*		-------------------------
*
*			static method operator [] takes unit whichUnit returns thistype
*				-	converts a unit into thistype
*
*       Methods
*       -------------------------
*
*           static method exists takes unit whichUnit returns boolean
*				-	determines whether the unit is indexed or not
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
************************************************************************************/
    globals
        private UnitIndex p_eventIndex = 0
    endglobals

    //! runtextmacro UNIT_INDEXER_UNIT_INDEX()
    //! runtextmacro UNIT_INDEXER_PREGAME_EVENT()
    //! runtextmacro UNIT_INDEXER_UNIT_INDEXER()
    
    module UnitIndex
		/*
		*	[] is included because the struct automatically overrides it
		*
		*	eventIndex is included to return thistype instead of UnitIndex
		*/
		static method operator [] takes unit whichUnit returns thistype
			return UnitIndex[whichUnit]
		endmethod
		static method operator eventIndex takes nothing returns thistype
			return UnitIndexer.eventIndex
		endmethod
	
		/*
		*	this is used for inheritance
		*/
        private delegate UnitIndexDelegate unitIndexDelegate
		
		/*
		*	the method is done in the second case because when there is no
		*	onUnitIndex method, indexed depends on whether the actual
		*	instance is allocated or not
		*/
		static if thistype.onUnitIndex.exists then
			readonly boolean isIndexed
		else
			method operator isIndexed takes nothing returns boolean
				return p_UnitIndex(this).isAllocated
			endmethod
		endif
    
		/*
		*	onUnitDeindex
		*/
		static if thistype.onUnitDeindex.exists then
			static if thistype.onUnitIndex.exists then
				private static boolexpr onDeindexExpression
			endif
			
			private static method onDeindexEvent takes nothing returns boolean
                call thistype(eventIndex).onUnitDeindex()
				
				static if thistype.onUnitIndex.exists then
					set thistype(eventIndex).isIndexed = false
                endif
				
                return false
            endmethod
        endif
		
		/*
		*	onUnitIndex
		*/
        static if thistype.onUnitIndex.exists then
            private static method onIndexEvent takes nothing returns boolean
				static if thistype.onUnitDeindex.exists then
					if (thistype(eventIndex).onUnitIndex()) then
						set thistype(eventIndex).isIndexed = true
						
						call UnitIndexer(eventIndex).Event.ON_DEINDEX.register(onDeindexExpression)
					endif
				else
					set thistype(eventIndex).isIndexed = thistype(eventIndex).onUnitIndex()
				endif
				
                return false
            endmethod
        endif
		
		private static method onInit takes nothing returns nothing
			local thistype this = 8191
			
			loop
				set unitIndexDelegate = this
				
				exitwhen this == 0
				set this = this - 1
			endloop
			
			static if thistype.onUnitIndex.exists then
				static if thistype.onUnitDeindex.exists then
					set onDeindexExpression = Condition(function thistype.onDeindexEvent)
				endif
			
				call UnitIndexer.GlobalEvent.ON_INDEX.register(Condition(function thistype.onIndexEvent))
			elseif thistype.onUnitDeindex.exists then
				call UnitIndexer.GlobalEvent.ON_DEINDEX.register(Condition(function thistype.onDeindexEvent))
			endif
		endmethod
    endmodule
endlibrary