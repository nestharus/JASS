library AllocT /* v1.2.0.1
*************************************************************************************
*
*	*/ uses /*
*
*		*/ Table					/*		http://www.hiveworkshop.com/forums/jass-resources-412/snippet-new-table-188084/
*		*/ optional ErrorMessage	/*		https://github.com/nestharus/JASS/tree/master/jass/Systems/ErrorMessage
*		*/ optional MemoryAnalysis	/*		
*
*************************************************************************************
*
*	Uses hashtable instead of array, which drastically reduces performance
*	but uncaps the instance limit. Should use with table fields instead of
*	array fields.
*
*	Due to hashtable usage, this uses an array stack recycler instead of a linked
*	stack. This is to reduce hashtable reads.
*
*		local thistype this = recycler[0]
*
*		if (recyclerCount == 0) then
*			set this = instanceCount + 1
*			set instanceCount = this
*		else
*			set recyclerCount = recyclerCount - 1
*			set this = recycler[recyclerCount]
*		endif
*
************************************************************************************
*
*	module AllocT
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
	private keyword globalAddress
	
	module AllocT
		/*
		*	stack
		*/
		private static Table recycler
		
		private static integer instanceCount = 0
		private static integer recyclerCount = 0
		
		static if LIBRARY_MemoryAnalysis then
			debug private static Table p_globalAddress
			
			debug public method operator globalAddress takes nothing returns MemoryMonitor
				debug return p_globalAddress[this]
			debug endmethod
			debug public method operator globalAddress= takes integer value returns nothing
				debug set p_globalAddress[this] = value
			debug endmethod
			
			debug method operator address takes nothing returns integer
				debug call ThrowError(not p_globalAddress.has(this), "Alloc", "address", "thistype", this, "Attempted To Access Null Instance.")
				debug return globalAddress
			debug endmethod
		elseif LIBRARY_ErrorMessage then
			debug private static Table p_allocated
		endif
		
		/*
		*	allocation
		*/
		static method allocate takes nothing returns thistype
			local thistype this
			
			if (recyclerCount == 0) then
				set this = instanceCount + 1
				set instanceCount = this
				
				static if LIBRARY_ErrorMessage then
					debug call ThrowError(this < 0, "AllocT", "allocate", "thistype", 0, "Overflow.")
				endif
			else
				set recyclerCount = recyclerCount - 1
				
				set this = recycler[recyclerCount]
			endif
			
			static if LIBRARY_MemoryAnalysis then
				debug set globalAddress = MemoryMonitor.allocate("thistype")
			elseif LIBRARY_ErrorMessage then
				debug set p_allocated.boolean[this] = true
			endif
			
			return this
		endmethod
		
		method deallocate takes nothing returns nothing
			static if LIBRARY_MemoryAnalysis then
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "deallocate", "thistype", this, "Attempted To Deallocate Null Instance.")
			elseif LIBRARY_ErrorMessage then
				debug call ThrowError(not p_allocated.has(this), "AllocT", "deallocate", "thistype", this, "Attempted To Deallocate Null Instance.")
			endif
			
			static if LIBRARY_MemoryAnalysis then
				debug call globalAddress.deallocate()
				debug call p_globalAddress.remove(this)
			elseif LIBRARY_ErrorMessage then
				debug call p_allocated.remove(this)
			endif
			
			set recycler[recyclerCount] = this
			set recyclerCount = recyclerCount + 1
		endmethod
		
		static if LIBRARY_MemoryAnalysis then
			debug method monitor takes string label, integer address returns nothing
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "monitor", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor(label, address)
			debug endmethod
			debug method stopMonitor takes integer address returns nothing
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "stopMonitor", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.stopMonitor(address)
			debug endmethod
			debug method stopMonitorValue takes handle monitoredHandle returns nothing
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "stopMonitorValue", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.stopMonitorValue(monitoredHandle)
			debug endmethod
			
			debug method operator monitorCount takes nothing returns integer
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "monitorCount", "thistype", this, "Attempted To Access Null Instance.")
				debug return globalAddress.monitorCount
			debug endmethod
			debug method operator monitorString takes nothing returns string
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "monitorString", "thistype", this, "Attempted To Access Null Instance.")
				debug return globalAddress.monitorString
			debug endmethod
			
			debug method monitor_widget				takes string label, widget				handleToTrack returns nothing
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "monitor_widget", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_widget(label, handleToTrack)
			debug endmethod
			debug method monitor_destructable		takes string label, destructable		handleToTrack returns nothing
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "monitor_destructable", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_destructable(label, handleToTrack)
			debug endmethod
			debug method monitor_item				takes string label, item				handleToTrack returns nothing
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "monitor_item", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_item(label, handleToTrack)
			debug endmethod
			debug method monitor_unit				takes string label, unit				handleToTrack returns nothing
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "monitor_unit", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_unit(label, handleToTrack)
			debug endmethod
			debug method monitor_timer				takes string label, timer				handleToTrack returns nothing
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "monitor_timer", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_timer(label, handleToTrack)
			debug endmethod
			debug method monitor_trigger			takes string label, trigger				handleToTrack returns nothing
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "monitor_trigger", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_trigger(label, handleToTrack)
			debug endmethod
			debug method monitor_triggercondition	takes string label, triggercondition	handleToTrack returns nothing
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "monitor_triggercondition", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_triggercondition(label, handleToTrack)
			debug endmethod
			debug method monitor_triggeraction		takes string label, triggeraction		handleToTrack returns nothing
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "monitor_triggeraction", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_triggeraction(label, handleToTrack)
			debug endmethod
			debug method monitor_force				takes string label, force				handleToTrack returns nothing
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "monitor_force", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_force(label, handleToTrack)
			debug endmethod
			debug method monitor_group				takes string label, group				handleToTrack returns nothing
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "monitor_group", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_group(label, handleToTrack)
			debug endmethod
			debug method monitor_location			takes string label, location			handleToTrack returns nothing
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "monitor_location", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_location(label, handleToTrack)
			debug endmethod
			debug method monitor_rect				takes string label, rect				handleToTrack returns nothing
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "monitor_rect", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_rect(label, handleToTrack)
			debug endmethod
			debug method monitor_boolexpr			takes string label, boolexpr			handleToTrack returns nothing
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "monitor_boolexpr", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_boolexpr(label, handleToTrack)
			debug endmethod
			debug method monitor_effect				takes string label, effect				handleToTrack returns nothing
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "monitor_effect", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_effect(label, handleToTrack)
			debug endmethod
			debug method monitor_unitpool			takes string label, unitpool			handleToTrack returns nothing
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "monitor_unitpool", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_unitpool(label, handleToTrack)
			debug endmethod
			debug method monitor_itempool			takes string label, itempool			handleToTrack returns nothing
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "monitor_itempool", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_itempool(label, handleToTrack)
			debug endmethod
			debug method monitor_quest				takes string label, quest				handleToTrack returns nothing
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "monitor_quest", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_quest(label, handleToTrack)
			debug endmethod
			debug method monitor_defeatcondition	takes string label, defeatcondition		handleToTrack returns nothing
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "monitor_defeatcondition", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_defeatcondition(label, handleToTrack)
			debug endmethod
			debug method monitor_timerdialog		takes string label, timerdialog			handleToTrack returns nothing
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "monitor_timerdialog", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_timerdialog(label, handleToTrack)
			debug endmethod
			debug method monitor_leaderboard		takes string label, leaderboard			handleToTrack returns nothing
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "monitor_leaderboard", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_leaderboard(label, handleToTrack)
			debug endmethod
			debug method monitor_multiboard			takes string label, multiboard			handleToTrack returns nothing
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "monitor_multiboard", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_multiboard(label, handleToTrack)
			debug endmethod
			debug method monitor_multiboarditem		takes string label, multiboarditem		handleToTrack returns nothing
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "monitor_multiboarditem", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_multiboarditem(label, handleToTrack)
			debug endmethod
			debug method monitor_dialog				takes string label, dialog				handleToTrack returns nothing
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "monitor_dialog", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_dialog(label, handleToTrack)
			debug endmethod
			debug method monitor_button				takes string label, button				handleToTrack returns nothing
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "monitor_button", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_button(label, handleToTrack)
			debug endmethod
			debug method monitor_texttag			takes string label, texttag				handleToTrack returns nothing
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "monitor_texttag", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_texttag(label, handleToTrack)
			debug endmethod
			debug method monitor_lightning			takes string label, lightning			handleToTrack returns nothing
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "monitor_lightning", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_lightning(label, handleToTrack)
			debug endmethod
			debug method monitor_image				takes string label, image				handleToTrack returns nothing
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "monitor_image", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_image(label, handleToTrack)
			debug endmethod
			debug method monitor_ubersplat			takes string label, ubersplat			handleToTrack returns nothing
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "monitor_ubersplat", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_ubersplat(label, handleToTrack)
			debug endmethod
			debug method monitor_region				takes string label, region				handleToTrack returns nothing
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "monitor_region", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_region(label, handleToTrack)
			debug endmethod
			debug method monitor_fogmodifier		takes string label, fogmodifier			handleToTrack returns nothing
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "monitor_fogmodifier", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_fogmodifier(label, handleToTrack)
			debug endmethod
			debug method monitor_hashtable			takes string label, hashtable			handleToTrack returns nothing
				debug call ThrowError(not p_globalAddress.has(this), "AllocT", "monitor_hashtable", "thistype", this, "Attempted To Access Null Instance.")
				debug call globalAddress.monitor_hashtable(label, handleToTrack)
			debug endmethod
			
			static if DEBUG_MODE then
				//! runtextmacro optional MEMORY_ANALYSIS_STATIC_FIELD_STACK_ARRAY("recycler", "instanceCount", "recyclerCount")
				
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
		static if LIBRARY_MemoryAnalysis then
			debug method operator allocated takes nothing returns boolean
				debug return p_globalAddress.has(this)
			debug endmethod
		elseif LIBRARY_ErrorMessage then
			debug method operator allocated takes nothing returns boolean
				debug return p_allocated.has(this)
			debug endmethod
		endif
		
		/*
		*	initialization
		*/
		private static method onInit takes nothing returns nothing
			set recycler = Table.create()
			
			static if LIBRARY_MemoryAnalysis then
				debug set p_globalAddress = Table.create()
			elseif LIBRARY_ErrorMessage then
				debug set p_allocated = Table.create()
			endif
		endmethod
	endmodule
endlibrary