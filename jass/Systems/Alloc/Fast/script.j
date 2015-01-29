library AllocFast /* v1.3.1.0
*************************************************************************************
*
*	*/ uses /*
*
*		*/ optional ErrorMessage	/*		github.com/nestharus/JASS/tree/master/jass/Systems/ErrorMessage
*		*/ optional MemoryAnalysis	/*		
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
*		The Following Require Error Message To Be In The Map
*		--------------------------------------------------------
*
*			debug readonly boolean allocated
*
*		The Following Require Memory Analysis To Be In The Map
*		--------------------------------------------------------
*
*			debug readonly integer monitorCount
*			-	the amount of global memory being monitored by this
*			debug readonly integer monitorString
*			-	gets a string representation of all global memory being monitored by this
*			debug readonly integer address
*			-	global memory address for debugging
*			-	used with monitor and stopMonitor
*
*			debug static method calculateMemoryUsage takes nothing returns integer
*			debug static method getAllocatedMemoryAsString takes nothing returns string
*
*			debug method monitor takes string label, integer address returns nothing
*			-	monitor a global memory address with a label
*			-	used to identify memory leaks
*			-	should be memory that ought to be destroyed by the time this is destroyed
*			debug method stopMonitor takes integer address returns nothing
*			-	stops monitoring global memory
*			debug method stopMonitorValue takes handle monitoredHandle returns nothing
*			-	stops monitoring handle values
*
*			The Following Are Used To Monitor Handle Values
*
*				debug method monitor_widget				takes string label, widget				handleToTrack returns nothing
*				debug method monitor_destructable		takes string label, destructable		handleToTrack returns nothing
*				debug method monitor_item				takes string label, item				handleToTrack returns nothing
*				debug method monitor_unit				takes string label, unit				handleToTrack returns nothing
*				debug method monitor_timer				takes string label, timer				handleToTrack returns nothing
*				debug method monitor_trigger			takes string label, trigger				handleToTrack returns nothing
*				debug method monitor_triggercondition	takes string label, triggercondition	handleToTrack returns nothing
*				debug method monitor_triggeraction		takes string label, triggeraction		handleToTrack returns nothing
*				debug method monitor_force				takes string label, force				handleToTrack returns nothing
*				debug method monitor_group				takes string label, group				handleToTrack returns nothing
*				debug method monitor_location			takes string label, location			handleToTrack returns nothing
*				debug method monitor_rect				takes string label, rect				handleToTrack returns nothing
*				debug method monitor_boolexpr			takes string label, boolexpr			handleToTrack returns nothing
*				debug method monitor_effect				takes string label, effect				handleToTrack returns nothing
*				debug method monitor_unitpool			takes string label, unitpool			handleToTrack returns nothing
*				debug method monitor_itempool			takes string label, itempool			handleToTrack returns nothing
*				debug method monitor_quest				takes string label, quest				handleToTrack returns nothing
*				debug method monitor_defeatcondition	takes string label, defeatcondition		handleToTrack returns nothing
*				debug method monitor_timerdialog		takes string label, timerdialog			handleToTrack returns nothing
*				debug method monitor_leaderboard		takes string label, leaderboard			handleToTrack returns nothing
*				debug method monitor_multiboard			takes string label, multiboard			handleToTrack returns nothing
*				debug method monitor_multiboarditem		takes string label, multiboarditem		handleToTrack returns nothing
*				debug method monitor_dialog				takes string label, dialog				handleToTrack returns nothing
*				debug method monitor_button				takes string label, button				handleToTrack returns nothing
*				debug method monitor_texttag			takes string label, texttag				handleToTrack returns nothing
*				debug method monitor_lightning			takes string label, lightning			handleToTrack returns nothing
*				debug method monitor_image				takes string label, image				handleToTrack returns nothing
*				debug method monitor_ubersplat			takes string label, ubersplat			handleToTrack returns nothing
*				debug method monitor_region				takes string label, region				handleToTrack returns nothing
*				debug method monitor_fogmodifier		takes string label, fogmodifier			handleToTrack returns nothing
*				debug method monitor_hashtable			takes string label, hashtable			handleToTrack returns nothing
*
************************************************************************************/
	module AllocFast
		/*
		*	stack
		*/
		private static integer array recycler
		private static integer alloc
		
		static if LIBRARY_MemoryAnalysis then
			debug private MemoryMonitor globalAddress
			
			debug method operator address takes nothing returns integer
				debug call ThrowError(recycler[this] != -1, "Alloc", "address", "thistype", this, "Attempted To Access Null Instance.")
				debug return globalAddress
			debug endmethod
		endif
		
		/*
		*	allocation
		*/
		static method allocate takes nothing returns thistype
			set alloc = recycler[0]
			
			static if LIBRARY_ErrorMessage then
				debug call ThrowError(alloc == 0, "AllocFast", "allocate", "thistype", 0, "Overflow.")
			endif
			
			set recycler[0] = recycler[alloc]
			
			static if LIBRARY_ErrorMessage then
				debug set recycler[alloc] = -1
			endif
			
			static if LIBRARY_MemoryAnalysis then
				debug set thistype(alloc).globalAddress = MemoryMonitor.allocate("thistype")
			endif
			
			return alloc
		endmethod
		
		method deallocate takes nothing returns nothing
			static if LIBRARY_ErrorMessage then
				debug call ThrowError(recycler[this] != -1, "AllocFast", "deallocate", "thistype", this, "Attempted To Deallocate Null Instance.")
			endif
			
			static if LIBRARY_MemoryAnalysis then
				debug call globalAddress.deallocate()
				debug set globalAddress = 0
			endif
			
			set recycler[this] = recycler[0]
			set recycler[0] = this
		endmethod
		
		static if LIBRARY_MemoryAnalysis then
			debug method monitor takes string label, integer address returns nothing
				debug call ThrowError(recycler[this] != -1, "AllocFast", "monitor", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor(label, address)
			debug endmethod
			debug method stopMonitor takes integer address returns nothing
				debug call ThrowError(recycler[this] != -1, "AllocFast", "stopMonitor", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.stopMonitor(address)
			debug endmethod
			debug method stopMonitorValue takes handle monitoredHandle returns nothing
				debug call ThrowError(recycler[this] != -1, "AllocFast", "stopMonitorValue", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.stopMonitorValue(monitoredHandle)
			debug endmethod
			
			debug method operator monitorCount takes nothing returns integer
				debug call ThrowError(recycler[this] != -1, "AllocFast", "monitorCount", "thistype", this, "Attempted To Access Null Instance.")
				debug return globalAddress.monitorCount
			debug endmethod
			debug method operator monitorString takes nothing returns string
				debug call ThrowError(recycler[this] != -1, "AllocFast", "monitorString", "thistype", this, "Attempted To Access Null Instance.")
				debug return globalAddress.monitorString
			debug endmethod
			
			debug method monitor_widget				takes string label, widget				handleToTrack returns nothing
				debug call ThrowError(recycler[this] != -1, "AllocFast", "monitor_widget", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_widget(label, handleToTrack)
			debug endmethod
			debug method monitor_destructable		takes string label, destructable		handleToTrack returns nothing
				debug call ThrowError(recycler[this] != -1, "AllocFast", "monitor_destructable", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_destructable(label, handleToTrack)
			debug endmethod
			debug method monitor_item				takes string label, item				handleToTrack returns nothing
				debug call ThrowError(recycler[this] != -1, "AllocFast", "monitor_item", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_item(label, handleToTrack)
			debug endmethod
			debug method monitor_unit				takes string label, unit				handleToTrack returns nothing
				debug call ThrowError(recycler[this] != -1, "AllocFast", "monitor_unit", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_unit(label, handleToTrack)
			debug endmethod
			debug method monitor_timer				takes string label, timer				handleToTrack returns nothing
				debug call ThrowError(recycler[this] != -1, "AllocFast", "monitor_timer", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_timer(label, handleToTrack)
			debug endmethod
			debug method monitor_trigger			takes string label, trigger				handleToTrack returns nothing
				debug call ThrowError(recycler[this] != -1, "AllocFast", "monitor_trigger", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_trigger(label, handleToTrack)
			debug endmethod
			debug method monitor_triggercondition	takes string label, triggercondition	handleToTrack returns nothing
				debug call ThrowError(recycler[this] != -1, "AllocFast", "monitor_triggercondition", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_triggercondition(label, handleToTrack)
			debug endmethod
			debug method monitor_triggeraction		takes string label, triggeraction		handleToTrack returns nothing
				debug call ThrowError(recycler[this] != -1, "AllocFast", "monitor_triggeraction", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_triggeraction(label, handleToTrack)
			debug endmethod
			debug method monitor_force				takes string label, force				handleToTrack returns nothing
				debug call ThrowError(recycler[this] != -1, "AllocFast", "monitor_force", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_force(label, handleToTrack)
			debug endmethod
			debug method monitor_group				takes string label, group				handleToTrack returns nothing
				debug call ThrowError(recycler[this] != -1, "AllocFast", "monitor_group", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_group(label, handleToTrack)
			debug endmethod
			debug method monitor_location			takes string label, location			handleToTrack returns nothing
				debug call ThrowError(recycler[this] != -1, "AllocFast", "monitor_location", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_location(label, handleToTrack)
			debug endmethod
			debug method monitor_rect				takes string label, rect				handleToTrack returns nothing
				debug call ThrowError(recycler[this] != -1, "AllocFast", "monitor_rect", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_rect(label, handleToTrack)
			debug endmethod
			debug method monitor_boolexpr			takes string label, boolexpr			handleToTrack returns nothing
				debug call ThrowError(recycler[this] != -1, "AllocFast", "monitor_boolexpr", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_boolexpr(label, handleToTrack)
			debug endmethod
			debug method monitor_effect				takes string label, effect				handleToTrack returns nothing
				debug call ThrowError(recycler[this] != -1, "AllocFast", "monitor_effect", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_effect(label, handleToTrack)
			debug endmethod
			debug method monitor_unitpool			takes string label, unitpool			handleToTrack returns nothing
				debug call ThrowError(recycler[this] != -1, "AllocFast", "monitor_unitpool", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_unitpool(label, handleToTrack)
			debug endmethod
			debug method monitor_itempool			takes string label, itempool			handleToTrack returns nothing
				debug call ThrowError(recycler[this] != -1, "AllocFast", "monitor_itempool", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_itempool(label, handleToTrack)
			debug endmethod
			debug method monitor_quest				takes string label, quest				handleToTrack returns nothing
				debug call ThrowError(recycler[this] != -1, "AllocFast", "monitor_quest", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_quest(label, handleToTrack)
			debug endmethod
			debug method monitor_defeatcondition	takes string label, defeatcondition		handleToTrack returns nothing
				debug call ThrowError(recycler[this] != -1, "AllocFast", "monitor_defeatcondition", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_defeatcondition(label, handleToTrack)
			debug endmethod
			debug method monitor_timerdialog		takes string label, timerdialog			handleToTrack returns nothing
				debug call ThrowError(recycler[this] != -1, "AllocFast", "monitor_timerdialog", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_timerdialog(label, handleToTrack)
			debug endmethod
			debug method monitor_leaderboard		takes string label, leaderboard			handleToTrack returns nothing
				debug call ThrowError(recycler[this] != -1, "AllocFast", "monitor_leaderboard", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_leaderboard(label, handleToTrack)
			debug endmethod
			debug method monitor_multiboard			takes string label, multiboard			handleToTrack returns nothing
				debug call ThrowError(recycler[this] != -1, "AllocFast", "monitor_multiboard", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_multiboard(label, handleToTrack)
			debug endmethod
			debug method monitor_multiboarditem		takes string label, multiboarditem		handleToTrack returns nothing
				debug call ThrowError(recycler[this] != -1, "AllocFast", "monitor_multiboarditem", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_multiboarditem(label, handleToTrack)
			debug endmethod
			debug method monitor_dialog				takes string label, dialog				handleToTrack returns nothing
				debug call ThrowError(recycler[this] != -1, "AllocFast", "monitor_dialog", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_dialog(label, handleToTrack)
			debug endmethod
			debug method monitor_button				takes string label, button				handleToTrack returns nothing
				debug call ThrowError(recycler[this] != -1, "AllocFast", "monitor_button", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_button(label, handleToTrack)
			debug endmethod
			debug method monitor_texttag			takes string label, texttag				handleToTrack returns nothing
				debug call ThrowError(recycler[this] != -1, "AllocFast", "monitor_texttag", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_texttag(label, handleToTrack)
			debug endmethod
			debug method monitor_lightning			takes string label, lightning			handleToTrack returns nothing
				debug call ThrowError(recycler[this] != -1, "AllocFast", "monitor_lightning", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_lightning(label, handleToTrack)
			debug endmethod
			debug method monitor_image				takes string label, image				handleToTrack returns nothing
				debug call ThrowError(recycler[this] != -1, "AllocFast", "monitor_image", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_image(label, handleToTrack)
			debug endmethod
			debug method monitor_ubersplat			takes string label, ubersplat			handleToTrack returns nothing
				debug call ThrowError(recycler[this] != -1, "AllocFast", "monitor_ubersplat", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_ubersplat(label, handleToTrack)
			debug endmethod
			debug method monitor_region				takes string label, region				handleToTrack returns nothing
				debug call ThrowError(recycler[this] != -1, "AllocFast", "monitor_region", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_region(label, handleToTrack)
			debug endmethod
			debug method monitor_fogmodifier		takes string label, fogmodifier			handleToTrack returns nothing
				debug call ThrowError(recycler[this] != -1, "AllocFast", "monitor_fogmodifier", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_fogmodifier(label, handleToTrack)
			debug endmethod
			debug method monitor_hashtable			takes string label, hashtable			handleToTrack returns nothing
				debug call ThrowError(recycler[this] != -1, "AllocFast", "monitor_hashtable", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_hashtable(label, handleToTrack)
			debug endmethod
			
			static if DEBUG_MODE then
				//! runtextmacro optional MEMORY_ANALYSIS_STATIC_FIELD_FAST("recycler")
				
				static method calculateMemoryUsage takes nothing returns integer
					return calculateAllocatedMemory__recycler()
				endmethod
				
				static method getAllocatedMemoryAsString takes nothing returns string
					return allocatedMemoryString__recycler()
				endmethod
			endif
		endif
		
		/*
		*	analysis
		*/
		static if LIBRARY_ErrorMessage then
			debug method operator allocated takes nothing returns boolean
				debug return recycler[this] == -1
			debug endmethod
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