/*
*	module UnitIndexStruct
*
*		readonly unit unit
*
*		static method operator [] takes unit whichUnit returns UnitIndex
*
*		method lock takes nothing returns nothing
*		method unlock takes nothing returns nothing
*
*		static method exists takes unit whichUnit returns boolean
*		static method isDeindexing takes unit whichUnit returns boolean
*
*		interface private method onIndex takes nothing returns nothing
*		interface private method onDeindex takes nothing returns nothing
*/

library UnitIndexer requires MapBounds, Event, Init, Alloc, ErrorMessage, StaticUniqueList
	globals
		private UnitIndex p_eventIndex = 0
	endglobals

	//! import "unit index.j"
	//! import "pregame event.j"
	//! import "unit indexer.j"
    
    module UnitIndexStruct
        static if thistype.onIndex.exists then
            private static method onIndexEvent takes nothing returns boolean
                call thistype(indexedUnitId).onIndex()
                return false
            endmethod
        endif
        static if thistype.onDeindex.exists then
            private static method onDeindexEvent takes nothing returns boolean
                call thistype(indexedUnitId).onDeindex()
                
                return false
            endmethod
        endif
		
        static if thistype.onIndex.exists then
            static if thistype.onDeindex.exists then
                private static method onInit takes nothing returns nothing
					call UnitIndexer.ON_INDEX.register(Condition(function thistype.onIndexEvent))
					call UnitIndexer.ON_DEINDEX.register(Condition(function thistype.onDeindexEvent))
                endmethod
            else
                private static method onInit takes nothing returns nothing
                    call UnitIndexer.ON_INDEX.register(Condition(function thistype.onIndexEvent))
                endmethod
            endif
        elseif thistype.onDeindex.exists then
            private static method onInit takes nothing returns nothing
                call UnitIndexer.ON_DEINDEX.register(Condition(function thistype.onDeindexEvent))
            endmethod
        endif
    endmodule
endlibrary