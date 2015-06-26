/*
*	Element extends Node
*
********************************************************************************************
*
*	API
*
*		static method createElement takes thistype collection returns thistype
*
*******************************************************************************************/

private keyword createElement

private module Element	
	public static method createElement takes thistype collection returns thistype
		local thistype this = createNode()
	
		set p__collection = collection
		
		static if DEBUG_MODE and LIBRARY_ErrorMessage and LIBRARY_MemoryAnalysis then
			call collection.p__address.monitor("Element", p__address)
		endif
		
		return this
	endmethod
endmodule