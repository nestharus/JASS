/*
*	requires
*
*		Alloc
*		ErrorMessage
*
*		private struct p_UnitIndex extends array
*
*		method operator isAllocated takes nothing returns boolean
*		debug static method calculateMemoryUsage takes nothing returns integer
*		debug static method getAllocatedMemoryAsString takes nothing returns string
*
*		method operator indexer takes nothing returns UnitIndexer
*		method operator unit takes nothing returns unit
*		static method operator [] takes unit whichUnit returns thistype
*		static method exists takes unit whichUnit returns boolean
*
*	struct UnitIndex extends array
*
*		readonly unit unit
*		readonly UnitIndexer indexer
*
*		static method operator [] takes unit whichUnit returns UnitIndex
*
*		static method exists takes unit whichUnit returns boolean
*		static method isDeindexing takes unit whichUnit returns boolean
*/

//! textmacro UNIT_INDEXER_UNIT_INDEX
private struct p_UnitIndex extends array
	implement AllocQ

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
		set p_unit = null
	
		call deallocate()
	endmethod
	
	method operator indexer takes nothing returns UnitIndexer
		debug call ThrowWarning(not isAllocated,											"UnitIndexer", "indexer", "thistype", this, "Getting indexer from a deallocated unit index.")
		
		return this
	endmethod
	
	method operator unit takes nothing returns unit
		debug call ThrowWarning(not isAllocated,											"UnitIndexer", "unit", "thistype", this, "Getting unit from a deallocated unit index.")
	
		return p_unit
	endmethod
	static method operator [] takes unit whichUnit returns thistype
		debug call ThrowWarning(GetUnitTypeId(whichUnit) == 0,								"UnitIndexer", "[]", "thistype", 0, "Getting unit index of a null unit.")
		debug call ThrowWarning(thistype(GetUnitUserData(whichUnit)).p_unit != whichUnit,	"UnitIndexer", "[]", "thistype", 0, "Getting unit index of a unit that isn't indexed.")
		
		return GetUnitUserData(whichUnit)
	endmethod
	
	static method exists takes unit whichUnit returns boolean
		debug call ThrowWarning(GetUnitTypeId(whichUnit) == 0, "UnitIndexer", "exists",		"thistype", 0, "Checking for the existence of a null unit.")
	
		return thistype(GetUnitUserData(whichUnit)).p_unit == whichUnit
	endmethod
	
	static method isDeindexing takes unit whichUnit returns boolean
		return GetUnitTypeId(whichUnit) != 0 and GetUnitAbilityLevel(whichUnit, ABILITIES_UNIT_INDEXER) == 0 and thistype(GetUnitUserData(whichUnit)).p_unit == whichUnit
	endmethod
endstruct

struct UnitIndex extends array
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
	
	method operator indexer takes nothing returns UnitIndexer
		return p_UnitIndex(this).indexer
	endmethod
endstruct
//! endtextmacro