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
*		Node next
*		Node prev
*		Node collection
*		debug MemoryMonitor address
*
*		readonly boolean next_has
*		readonly boolean prev_has
*		debug readonly boolean collection_has
*		debug readonly boolean address_has
*
*		method next_clear takes nothing returns nothing
*		method prev_clear takes nothing returns nothing
*		method collection_clear takes nothing returns nothing
*		method address_clear takes nothing returns nothing
*
*		debug readonly boolean isCollection
*		debug readonly boolean isElement
*		debug readonly boolean allocated
*		readonly boolean isNull
*
*		static method create takes nothing returns thistype
*		method destroy returns nothing
*		static method destroyRange takes thistype start, thistype end returns nothing
*
*		debug static method calculateMemoryUsage takes nothing returns integer
*		debug static method getAllocatedMemoryAsString takes nothing returns string
*
*******************************************************************************************/

private keyword Node
private keyword Element
private keyword Collection

struct Node extends array
	private static integer instanceCount = 0

	/* element to collection */
	//! runtextmacro CREATE_TABLE_FIELD("public", "integer", "collection", "thistype")
	
	//! runtextmacro CREATE_TABLE_FIELD("public", "integer", "next", "thistype")
	//! runtextmacro CREATE_TABLE_FIELD("public", "integer", "prev", "thistype")
	
	static if DEBUG_MODE and LIBRARY_ErrorMessage and LIBRARY_MemoryAnalysis then
		//! runtextmacro CREATE_TABLE_FIELD("public", "integer", "address", "MemoryMonitor")
	endif
	
	static if DEBUG_MODE and LIBRARY_ErrorMessage then
		public method operator isCollection takes nothing returns boolean
			return collection == -1
		endmethod
		public method operator isElement takes nothing returns boolean
			return collection > 0
		endmethod
		public method operator allocated takes nothing returns boolean
			return collection != 0
		endmethod
	endif
	
	public method operator isNull takes nothing returns boolean
		return this == 0
	endmethod
	
	public static method create takes nothing returns thistype
		local thistype this = thistype(0).next
		
		if (this == 0) then
			set this = instanceCount + 1
			set instanceCount = this
		else
			set thistype(0).next = next
		endif
		
		static if DEBUG_MODE and LIBRARY_ErrorMessage and LIBRARY_MemoryAnalysis then
			set address = MemoryMonitor.create("Node")
		endif
		
		return this
	endmethod
	
	public method destroy takes nothing returns nothing
		set next = thistype(0).next
		set thistype(0).next = this
		
		static if DEBUG_MODE and LIBRARY_ErrorMessage and LIBRARY_MemoryAnalysis then
			call address.destroy()
		endif
	endmethod
	
	public static method destroyRange takes thistype start, thistype end returns nothing
		set end.next = thistype(0).next
		set thistype(0).next = start
	
		static if DEBUG_MODE and LIBRARY_ErrorMessage then
			loop
				static if LIBRARY_MemoryAnalysis then
					call start.address.destroy()
				endif
				
				exitwhen integer(start) == integer(end)
				
				set start = start.next
			endloop
		endif
	endmethod
	
	static if DEBUG_MODE and LIBRARY_ErrorMessage and LIBRARY_MemoryAnalysis then
		//! runtextmacro MEMORY_ANALYSIS_FIELD_OLD("next", "instanceCount")
		
		public static method calculateMemoryUsage takes nothing returns integer
			return calculateAllocatedMemory__next()
		endmethod
		
		public static method getAllocatedMemoryAsString takes nothing returns string
			return allocatedMemoryString__next()
		endmethod
	endif
	
	private static method init takes nothing returns nothing
		//! runtextmacro INITIALIZE_TABLE_FIELD("collection")
		
		//! runtextmacro INITIALIZE_TABLE_FIELD("next")
		//! runtextmacro INITIALIZE_TABLE_FIELD("prev")
		
		static if DEBUG_MODE and LIBRARY_ErrorMessage and LIBRARY_MemoryAnalysis then
			//! runtextmacro INITIALIZE_TABLE_FIELD("address")
		endif
	endmethod
	
	implement Init
endstruct