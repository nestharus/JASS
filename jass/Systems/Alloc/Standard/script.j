library Alloc /* v1.2.0.0
*************************************************************************************
*
*	*/ uses /*
*
*		*/ ErrorMessage		/*		github.com/nestharus/JASS/tree/master/jass/Systems/ErrorMessage
*		*/ MemoryAnalysis	/*		
*
*************************************************************************************
*
*	Minimizes code generation and global variables while maintaining
*	excellent performance.
*
*		local thistype this = recycler[0]
*
*		if (recycler[this] == 0) then
*			set recycler[0] = this + 1
*		else
*			set recycler[0] = recycler[this]
*		endif
*
************************************************************************************
*
*	module Alloc
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
	module Alloc
		/*
		*	stack
		*/
		private static integer array recycler
		
		/*
		*	allocation
		*/
		static method allocate takes nothing returns thistype
			local thistype this = recycler[0]
			
			debug call ThrowError(this == 8192, "Alloc", "allocate", "thistype", 0, "Overflow.")
			
			if (recycler[this] == 0) then
				set recycler[0] = this + 1
			else
				set recycler[0] = recycler[this]
			endif
			
			set recycler[this] = -1
			
			return this
		endmethod
		
		method deallocate takes nothing returns nothing
			debug call ThrowError(recycler[this] != -1, "Alloc", "deallocate", "thistype", this, "Attempted To Deallocate Null Instance.")
			
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
			//! runtextmacro MEMORY_ANALYSIS_STATIC_FIELD_NEW("recycler")
			
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
			set recycler[0] = 1
		endmethod
	endmodule
endlibrary