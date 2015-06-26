private struct Element extends array
	/* element to collection */
	//! runtextmacro CREATE_TABLE_FIELD("public", "integer", "toCollection", "thistype")
	
	/* is element collection? */
	//! runtextmacro CREATE_TABLE_FIELD("public", "boolean", "isCollection", "boolean")
	
	//! runtextmacro CREATE_TABLE_FIELD("public", "integer", "next", "thistype")
	//! runtextmacro CREATE_TABLE_FIELD("public", "integer", "prev", "thistype")
	
	static if LIBRARY_MemoryAnalysis then
		//! runtextmacro CREATE_TABLE_FIELD("public", "integer", "address", "MemoryMonitor")
	endif
	
	private static method init takes nothing returns nothing
		//! runtextmacro INITIALIZE_TABLE_FIELD("toCollection")
		//! runtextmacro INITIALIZE_TABLE_FIELD("isCollection")
		//! runtextmacro INITIALIZE_TABLE_FIELD("next")
		//! runtextmacro INITIALIZE_TABLE_FIELD("prev")
		
		static if LIBRARY_MemoryAnalysis then
			//! runtextmacro INITIALIZE_TABLE_FIELD("address")
		endif
	endmethod
	
	implement Init
endstruct