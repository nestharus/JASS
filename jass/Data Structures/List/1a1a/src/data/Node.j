/*
*	Node
*
*		Provides direct access to data shared between Element and Collection.
*		Manages addresses in debug mode.
*		Infers whether a node is an element or a collection in debug mode.
*
********************************************************************************************
*
*	API
*
*		thistype p__next
*		thistype p__prev
*		thistype p__collection
*		debug MemoryMonitor p__address
*
*		readonly boolean isNull
*
*		static method createNode takes nothing returns thistype
*		method destroyNode returns nothing
*		static method destroyNodeRange takes thistype start, thistype end returns nothing
*
*		debug static method calculateMemoryUsage takes nothing returns integer
*		debug static method getAllocatedMemoryAsString takes nothing returns string
*
*******************************************************************************************/

static if DEBUG_MODE and LIBRARY_ErrorMessage then
	private function IsCollection takes integer flag returns boolean
		return flag == -1
	endfunction
	private function IsElement takes integer flag returns boolean
		return flag > 0
	endfunction
	private function  IsAllocated takes integer flag returns boolean
		return flag != 0
	endfunction
	private function  IsNull takes integer flag returns boolean
		return flag == 0
	endfunction
endif

private keyword p__collection
private keyword p__next
private keyword p__prev
private keyword p__address

private keyword createNode
private keyword destroyNode
private keyword destroyNodeRange

private module Node
	private static integer instanceCount = 0
	
	public thistype p__collection
	public thistype p__next
	public thistype p__prev

	static if DEBUG_MODE and LIBRARY_ErrorMessage and LIBRARY_MemoryAnalysis then
		public MemoryMonitor p__address
	endif
	
	public method operator isNull takes nothing returns boolean
		return this == 0
	endmethod
	
	public static method createNode takes nothing returns thistype
		local thistype this = thistype(0).p__next
		
		if (this == 0) then
			static if DEBUG_MODE and LIBRARY_ErrorMessage then
				call ThrowError(instanceCount == 8191, 				"ListHN", "create", "ListHN", 0, ErrorMessage.OVERFLOW)
			endif
			
			set this = instanceCount + 1
			set instanceCount = this
		else
			set thistype(0).p__next = p__next
		endif
		
		static if DEBUG_MODE and LIBRARY_ErrorMessage and LIBRARY_MemoryAnalysis then
			set p__address = MemoryMonitor.create("Node")
		endif
		
		return this
	endmethod
	
	public method destroyNode takes nothing returns nothing
		set p__next = thistype(0).p__next
		set thistype(0).p__next = this
		
		static if DEBUG_MODE and LIBRARY_ErrorMessage and LIBRARY_MemoryAnalysis then
			call p__address.destroy()
		endif
	endmethod
	
	public static method destroyNodeRange takes thistype start, thistype end returns nothing
		set end.p__next = thistype(0).p__next
		set thistype(0).p__next = start
	
		static if DEBUG_MODE and LIBRARY_ErrorMessage then
			loop
				static if LIBRARY_MemoryAnalysis then
					call start.p__address.destroy()
				endif
				
				exitwhen integer(start) == integer(end)
				
				set start = start.p__next
			endloop
		endif
	endmethod
	
	static if DEBUG_MODE and LIBRARY_ErrorMessage and LIBRARY_MemoryAnalysis then
		//! runtextmacro MEMORY_ANALYSIS_FIELD_OLD("p__next", "instanceCount")
		
		public static method calculateMemoryUsage takes nothing returns integer
			return calculateAllocatedMemory__p__next()
		endmethod
		
		public static method getAllocatedMemoryAsString takes nothing returns string
			return allocatedMemoryString__p__next()
		endmethod
	endif
endmodule