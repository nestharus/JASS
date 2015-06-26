//! import "Element.j"
//! import "Collection.j"

private struct recycler extends array
	public static method operator [] takes Element index returns Element
		return index.next
	endmethod
	
	public static method operator []= takes Element index, Element value returns nothing
		set index.next = value
	endmethod
endstruct

private struct Allocator extends array
	private static integer instanceCount = 0
	
	public static method allocate takes nothing returns Element
		local thistype this = recycler[0]
		
		if (this == 0) then
			set this = instanceCount + 1
			set instanceCount = this
		else
			set recycler[0] = recycler[this]
		endif
		
		return this
	endmethod
	
	public static method deallocate takes thistype this returns nothing
		set recycler[this] = recycler[0]
		set recycler[0] = this
	endmethod
	
	public static method deallocateRange takes thistype start, thistype end returns nothing
		set recycler[end] = recycler[0]
		set recycler[0] = start
	endmethod
	
	static if LIBRARY_MemoryAnalysis then
		//! runtextmacro MEMORY_ANALYSIS_STATIC_FIELD_OLD("recycler", "instanceCount")
		
		public static method calculateMemoryUsage takes nothing returns integer
			return calculateAllocatedMemory__recycler()
		endmethod
		
		public static method getAllocatedMemoryAsString takes nothing returns string
			return allocatedMemoryString__recycler()
		endmethod
	endif
endstruct