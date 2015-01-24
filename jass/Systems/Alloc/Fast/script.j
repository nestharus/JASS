library AllocFast /* v1.2.0.0
*************************************************************************************
*
*	*/ uses /*
*
*		*/ ErrorMessage		/*		github.com/nestharus/JASS/tree/master/jass/Systems/ErrorMessage
*		*/ MemoryAnalysis	/*		
*
*************************************************************************************
*
*	Maximizes speed by reducing local variable declarations and removing
*	if-statement.
*
*		set alloc = recycler[0]
*		set recycler[0] = recycler[alloc]
*
************************************************************************************
*
*	module AllocFast
*
*		static method allocate takes nothing returns thistype
*		method deallocate takes nothing returns nothing
*
*		readonly boolean isAllocated
*
*		debug static method calculateMemoryUsage takes nothing returns integer
*		debug static method getAllocatedMemoryAsString takes nothing returns string
*
************************************************************************************/
	module AllocFast
		/*
		*	stack
		*/
		private static integer array recycler
		private static integer alloc
		
		/*
		*	allocation
		*/
		static method allocate takes nothing returns thistype
			set alloc = recycler[0]
			
			debug call ThrowError(alloc == 0, "AllocFast", "allocate", "thistype", 0, "Overflow.")
			
			set recycler[0] = recycler[alloc]
			set recycler[alloc] = -1
			
			return alloc
		endmethod
		
		method deallocate takes nothing returns nothing
			debug call ThrowError(recycler[this] != -1, "AllocFast", "deallocate", "thistype", this, "Attempted To Deallocate Null Instance.")
			
			set recycler[this] = recycler[0]
			set recycler[0] = this
		endmethod
		
		/*
		*	analysis
		*/
		method operator isAllocated takes nothing returns boolean
			return recycler[this] == -1
		endmethod
		
		static if DEBUG_MODE then
			//! runtextmacro MEMORY_ANALYSIS_STATIC_FIELD_FAST("recycler")
			
			static method calculateMemoryUsage takes nothing returns integer
				return calculateAllocatedMemory__recycler()
			endmethod
			
			static method getAllocatedMemoryAsString takes nothing returns string
				return allocatedMemoryString__recycler()
			endmethod
		endif
		
		/*
		*	initialization
		*/
		private static method onInit takes nothing returns nothing
			local integer i = 0

			set recycler[8191] = 0 //so that the array doesn't reallocate over and over again
			
			loop
				set recycler[i] = i + 1
				
				exitwhen i == 8190
				set i = i + 1
			endloop
		endmethod
	endmodule
endlibrary