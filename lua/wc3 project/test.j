/*
*	requires
*
*		Alloc
*		ErrorMessage
*
*	private struct p_UnitIndex extends array
*
*		debug method operator isAllocated takes nothing returns boolean
*		debug static method calculateMemoryUsage takes nothing returns integer
*		debug static method getAllocatedMemoryAsString takes nothing returns string
*
*		method lock takes nothing returns nothing
*		method unlock takes nothing returns nothing
*
*		method operator unit takes nothing returns unit
*		static method operator [] takes unit whichUnit returns thistype
*		static method exists takes unit whichUnit returns boolean
*
*	struct UnitIndex extends array
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
*/

private struct p_UnitIndex extends array
	implement Alloc

	private integer p_locks
	private unit p_unit
	
	static method create takes unit whichUnit returns thistype
		local thistype this = allocate()
		
		set p_unit = whichUnit
		call SetUnitUserData(whichUnit, this)
		
		call UnitAddAbility(whichUnit, ABILITIES_UNIT_INDEXER)
		call UnitMakeAbilityPermanent(whichUnit, true, ABILITIES_UNIT_INDEXER)
		
		return this
	endmethod
	
	method destroy takes nothing returns nothing
		if (0 != p_locks) then
			return
		endif
	
		set p_unit = null
		set p_locks = 0
	
		call deallocate()
	endmethod
	
	method lock takes nothing returns nothing
		debug call ThrowError(isAllocated, "UnitIndexer", "lock", "thistype", this, "Attempted to increase lock count of null unit index.")
	
		set p_locks = p_locks + 1
	endmethod
	method unlock takes nothing returns nothing
		debug call ThrowError(not isAllocated, 		"UnitIndexer", "unlock", "thistype", this, "Attempted to decrease lock count of null unit index.")
		debug call ThrowError(p_locks == 0, 		"UnitIndexer", "unlock", "thistype", this, "Attempted to decrease lock count of unit index with no locks.")
		
		set p_locks = p_locks - 1
		
		if (p_locks == 0 and GetUnitTypeId(p_unit) == 0) then
			call destroy()
		endif
	endmethod
	
	method operator unit takes nothing returns unit
		debug call ThrowWarning(not isAllocated, 										"UnitIndexer", "unit", "thistype", this, "Getting unit from a deallocated unit index.")
	
		return p_unit
	endmethod
	static method operator [] takes unit whichUnit returns thistype
		debug call ThrowWarning(GetUnitTypeId(whichUnit) == 0, 							"UnitIndexer", "[]", "thistype", 0, "Getting unit index of a null unit.")
		debug call ThrowWarning(thistype(GetUnitUserData(whichUnit)).unit != whichUnit, "UnitIndexer", "[]", "thistype", 0, "Getting unit index of a unit that isn't indexed.")
		
		return GetUnitUserData(whichUnit)
	endmethod
	
	static method exists takes unit whichUnit returns boolean
		debug call ThrowWarning(GetUnitTypeId(whichUnit) == 0, "UnitIndexer", "exists", "thistype", 0, "Checking for the existence of a null unit.")
	
		return thistype(GetUnitUserData(whichUnit)).unit == whichUnit
	endmethod
	
	static method isDeindexing takes unit whichUnit returns boolean
        return GetUnitTypeId(whichUnit) != 0 and GetUnitAbilityLevel(whichUnit, ABILITIES_UNIT_INDEXER) == 0 and thistype(GetUnitUserData(whichUnit)).unit == whichUnit
    endmethod
endstruct

struct UnitIndex extends array
	method lock takes nothing returns nothing
		call p_UnitIndex(this).lock()
	endmethod
	
	method unlock takes nothing returns nothing
		call p_UnitIndex(this).unlock()
	endmethod
	
	method operator unit takes nothing returns unit
		return p_UnitIndex(this).unit
	endmethod
	
	static method operator [] takes unit whichUnit returns thistype
		return p_UnitIndex[whichUnit]
	endmethod
	
	static method exists takes unit whichUnit returns boolean
		return p_UnitIndex.exists(whichUnit)
	endmethod
	
	static method isDeindexing takes unit whichUnit returns boolean
		return p_UnitIndex.isDeindexing(whichUnit)
	endmethod
endstruct

private struct UnitIndexDelegate extends array
	private static delegate UnitIndex array unitIndex
	
	private static method init takes nothing returns nothing
		local integer i = 8191
	
		loop
			set unitIndex[i] = i
			
			exitwhen i == 0
			set i = i - 1
		endloop
	endmethod
	
	implement Init
endstruct/*
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
endlibrary/*
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