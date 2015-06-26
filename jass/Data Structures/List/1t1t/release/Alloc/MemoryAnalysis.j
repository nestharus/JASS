library MemoryAnalysis /* v1.1.0.1
*************************************************************************************
*
*	*/ uses /*
*
*		*/ ErrorMessage	/*		github.com/nestharus/JASS/tree/master/jass/Systems/ErrorMessage
*
*************************************************************************************
*
*	Provides tools for checking memory. Useful for checking for memory leaks.
*
************************************************************************************
*
*	debug struct MemoryMonitor extends array
*
*		Description
*		-------------
*
*			Dynamic memory analysis. Whenever memory creates more temporary memory, make
*			that memory monitor the new memory. When the original memory is destroyed, if
*			that new memory still exists, that new memory has leaked.
*
*		API
*		-------------
*
*			debug readonly boolean allocated
*			debug readonly string id
*			-	an id assigned to this memory by the user for easy identification
*			debug readonly integer monitorCount
*			-	how much memory is currently being monitored by this memory
*			-	potential leaks
*			debug readonly string monitorString
*			-	a string representation of the memory being monitored by this memory
*
*			debug static method allocate takes string id returns MemoryMonitor
*			debug static method create takes string id returns MemoryMonitor
*			-	id is used to easily identify memory
*			debug method deallocate takes nothing returns nothing
*			debug method destroy takes nothing returns nothing
*			-	if memory is deallocated while monitored memory is still alive, this will
*			-	throw an error and warn of leaks
*
*			debug method monitor takes string id, thistype address returns nothing
*			-	starts monitoring memory
*			-	the address should be a MemoryMonitor address
*			debug method stopMonitor takes thistype address returns nothing
*			-	stops monitoring an address
*			debug method stopMonitorValue takes handle monitoredHandle returns nothing
*			-	stops monitoring a handle value
*
*		The following are used to monitor handle values
*
*			debug method monitor_widget				takes string label, widget				handleToTrack returns nothing
*			debug method monitor_destructable		takes string label, destructable		handleToTrack returns nothing
*			debug method monitor_item				takes string label, item				handleToTrack returns nothing
*			debug method monitor_unit				takes string label, unit				handleToTrack returns nothing
*			debug method monitor_timer				takes string label, timer				handleToTrack returns nothing
*			debug method monitor_trigger			takes string label, trigger				handleToTrack returns nothing
*			debug method monitor_triggercondition	takes string label, triggercondition	handleToTrack returns nothing
*			debug method monitor_triggeraction		takes string label, triggeraction		handleToTrack returns nothing
*			debug method monitor_force				takes string label, force				handleToTrack returns nothing
*			debug method monitor_group				takes string label, group				handleToTrack returns nothing
*			debug method monitor_location			takes string label, location			handleToTrack returns nothing
*			debug method monitor_rect				takes string label, rect				handleToTrack returns nothing
*			debug method monitor_boolexpr			takes string label, boolexpr			handleToTrack returns nothing
*			debug method monitor_effect				takes string label, effect				handleToTrack returns nothing
*			debug method monitor_unitpool			takes string label, unitpool			handleToTrack returns nothing
*			debug method monitor_itempool			takes string label, itempool			handleToTrack returns nothing
*			debug method monitor_quest				takes string label, quest				handleToTrack returns nothing
*			debug method monitor_defeatcondition	takes string label, defeatcondition		handleToTrack returns nothing
*			debug method monitor_timerdialog		takes string label, timerdialog			handleToTrack returns nothing
*			debug method monitor_leaderboard		takes string label, leaderboard			handleToTrack returns nothing
*			debug method monitor_multiboard			takes string label, multiboard			handleToTrack returns nothing
*			debug method monitor_multiboarditem		takes string label, multiboarditem		handleToTrack returns nothing
*			debug method monitor_dialog				takes string label, dialog				handleToTrack returns nothing
*			debug method monitor_button				takes string label, button				handleToTrack returns nothing
*			debug method monitor_texttag			takes string label, texttag				handleToTrack returns nothing
*			debug method monitor_lightning			takes string label, lightning			handleToTrack returns nothing
*			debug method monitor_image				takes string label, image				handleToTrack returns nothing
*			debug method monitor_ubersplat			takes string label, ubersplat			handleToTrack returns nothing
*			debug method monitor_region				takes string label, region				handleToTrack returns nothing
*			debug method monitor_fogmodifier		takes string label, fogmodifier			handleToTrack returns nothing
*			debug method monitor_hashtable			takes string label, hashtable			handleToTrack returns nothing
*
*	Static Allocator Stack Analysis
*
*	Generated Macro Members (for below macros)
*
*		debug private calculateFreeMemory__$STACK$ takes nothing returns integer
*
*			May be a static method or a function
*
*			Returns how much memory is remaining in the stack assuming that the
*			maximum memory is 8191. Should not be used with tables as tables have
*			no bound on memory.
*
*			Useful for helping to determine whether to stick with arrays or use
*			tables.
*
*		debug private calculateAllocatedMemory__$STACK$ takes nothing returns integer
*
*			May be a static method or a function
*
*			Returns how much memory is currently allocated by analyzing the stack
*			and total accessed memory.
*
*			Useful for helping to determine if a resource or map has memory leaks.
*
*		debug private allocatedMemoryString__$STACK$ takes nothing returns string
*
*			May be a static method or a function
*
*			Returns a string containing a list of all allocated instances.
*
*			Useful for debugging a resource or map when that resource or map has
*			memory leaks.
*
*	Macros
*
*		//! textmacro MEMORY_ANALYSIS_FIELD_OLD takes STACK, INSTANCE_COUNT
*
*			Takes an old style allocator with a stack and an instance count
*
*			Must be implemented within a struct
*
*			STACK must be of type "thistype" and must not be static
*
*		//! textmacro MEMORY_ANALYSIS_FIELD_NEW takes STACK
*
*			Takes a new style allocator where the bottom of the STACK always
*			contains the highest possible instance.
*
*			Must be implemented within a struct
*
*			STACK must be of type "thistype" and must not be static
*
*		//! textmacro MEMORY_ANALYSIS_FIELD_FAST takes STACK
*
*			Takes a fast style allocator where the STACK is completely filled
*			at map initialization.
*
*			Must be implemented within a struct
*
*			STACK must be of type "thistype" and must not be static
*
*		//! textmacro MEMORY_ANALYSIS_STATIC_FIELD_OLD takes STACK, INSTANCE_COUNT
*
*			Takes an old style allocator with a stack and an instance count
*
*			Must be implemented within a struct
*
*			STACK must be a static array
*
*		//! textmacro MEMORY_ANALYSIS_STATIC_FIELD_NEW takes STACK
*
*			Takes a new style allocator where the bottom of the STACK always
*			contains the highest possible instance.
*
*			Must be implemented within a struct
*
*			STACK must be a static array
*
*		//! textmacro MEMORY_ANALYSIS_STATIC_FIELD_FAST takes STACK
*
*			Takes a fast style allocator where the STACK is completely filled
*			at map initialization.
*
*			Must be implemented within a struct
*
*			STACK must be a static array
*
*		//! textmacro MEMORY_ANALYSIS_STATIC_FIELD_STACK_ARRAY takes STACK, INSTANCE_COUNT, RECYCLE_COUNT
*
*			The first style of allocation ever created. Uses an array for the stack
*			and two counters. INSTANCE_COUNT and RECYCLE_COUNT should be initialized to 0
*			and RECYCLE_COUNT should refer to the top of the array.
*
*			Must be implemented within a struct
*
*			STACK must be an array
*
*		//! textmacro MEMORY_ANALYSIS_VARIABLE_OLD takes STACK, INSTANCE_COUNT
*
*			Takes an old style allocator with a stack and an instance count
*
*			Must be implemented within a library or scope
*
*			STACK must be an array
*
*		//! textmacro MEMORY_ANALYSIS_VARIABLE_NEW takes STACK
*
*			Takes a new style allocator where the bottom of the STACK always
*			contains the highest possible instance.
*
*			Must be implemented within a library or scope
*
*			STACK must be an array
*
*		//! textmacro MEMORY_ANALYSIS_VARIABLE_FAST takes STACK
*
*			Takes a fast style allocator where the STACK is completely filled
*			at map initialization.
*
*			Must be implemented within a library or scope
*
*			STACK must be an array
*
*		//! textmacro MEMORY_ANALYSIS_VARIABLE_STACK_ARRAY takes STACK, INSTANCE_COUNT, RECYCLE_COUNT
*
*			The first style of allocation ever created. Uses an array for the stack
*			and two counters. INSTANCE_COUNT and RECYCLE_COUNT should be initialized to 0
*			and RECYCLE_COUNT should refer to the top of the array.
*
*			Must be implemented within a library or scope
*
*			STACK must be an array
*
************************************************************************************/
	globals
		private constant boolean TRACE = false
	endglobals
	
	static if DEBUG_MODE then
	
	private module doInit
		private static method onInit takes nothing returns nothing
			call init()
		endmethod
	endmodule
	
	private struct ValueTracker extends array
		private static hashtable table = InitHashtable()
		private static integer instanceCount = 0
		private static integer recycleCount = 0
		
		private static trigger loader = null
		private static boolexpr array eval
		private static integer toLoad = 0
		private static handle loaded = null
		
		static constant integer widget = 1
		static constant integer destructable = 2
		static constant integer item = 3
		static constant integer unit = 4
		static constant integer timer = 5
		static constant integer trigger = 6
		static constant integer triggercondition = 7
		static constant integer triggeraction = 8
		static constant integer force = 9
		static constant integer group = 10
		static constant integer location = 11
		static constant integer rect = 12
		static constant integer boolexpr = 13
		static constant integer effect = 14
		static constant integer unitpool = 15
		static constant integer itempool = 16
		static constant integer quest = 17
		static constant integer defeatcondition = 18
		static constant integer timerdialog = 19
		static constant integer leaderboard = 20
		static constant integer multiboard = 21
		static constant integer multiboarditem = 22
		static constant integer dialog = 23
		static constant integer button = 24
		static constant integer texttag = 25
		static constant integer lightning = 26
		static constant integer image = 27
		static constant integer ubersplat = 28
		static constant integer region = 29
		static constant integer fogmodifier = 30
		static constant integer hashtable = 31
		
		//owner		0
		//type		1
		//label		2
		//handle	3
		//handleid	4
		//index		5
		
		private static method allocate takes integer handleId, integer owner, integer typeId, string label returns thistype
			local thistype this
			
			if (recycleCount == 0) then
				set this = instanceCount + 1
				set instanceCount = this
			else
				set recycleCount = recycleCount - 1
				set this = LoadInteger(table, 0, recycleCount)
			endif
			
			call SaveInteger(table, -handleId, owner, this)
			call SaveInteger(table, this, 0, owner)
			call SaveInteger(table, this, 1, typeId)
			call SaveStr(table, this, 2, label)
			call SaveInteger(table, this, 4, handleId)
			
			static if TRACE then
				call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60000, "Create ValueTracker(" + I2S(handleId) + ", " + I2S(owner) + ").label = " + label)
			endif
			
			return this
		endmethod
		
		method destroy takes nothing returns nothing
			if (HaveSavedInteger(table, this, 0)) then
				static if TRACE then
					call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60000, "Destroy ValueTracker(" + I2S(LoadInteger(table, this, 4)) + ", " + I2S(LoadInteger(table, this, 0)) + ").label = " + LoadStr(table, this, 2))
				endif
			
				call RemoveSavedInteger(table, -LoadInteger(table, this, 4), LoadInteger(table, this, 0))
				call RemoveSavedInteger(table, this, 0)
				call RemoveSavedInteger(table, this, 1)
				call RemoveSavedInteger(table, this, 2)
				call RemoveSavedHandle(table, this, 3)
				call RemoveSavedInteger(table, this, 4)
				call RemoveSavedInteger(table, this, 5)
				
				call SaveInteger(table, 0, recycleCount, this)
				set recycleCount = recycleCount + 1
			endif
		endmethod
		
		static method operator [] takes handle h returns thistype
			return GetHandleId(h)
		endmethod
		
		method operator [] takes integer owner returns thistype
			if (HaveSavedInteger(table, -this, owner)) then
				return LoadInteger(table, -this, owner)
			endif
			
			return 0
		endmethod
		
		method operator owner takes nothing returns integer
			return LoadInteger(table, this, 0)
		endmethod
		
		method operator index takes nothing returns integer
			return LoadInteger(table, this, 5)
		endmethod
		method operator index= takes integer index returns nothing
			static if TRACE then
				call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60000, "ValueTracker(" + I2S(this) + ").index = " + I2S(index))
			endif
			call SaveInteger(table, this, 5, index)
		endmethod
		
		method operator label takes nothing returns string
			return LoadStr(table, this, 2)
		endmethod
		
		method operator valid takes nothing returns boolean
			return HaveSavedInteger(table, this, 0)
		endmethod
		
		method operator allocated takes nothing returns boolean
			local integer owner
			local triggercondition tc
			local boolean success
			
			if (not valid) then
				return false
			endif
			
			set owner = this.owner
			set tc = TriggerAddCondition(loader, eval[LoadInteger(table, this, 1)])
			
			set toLoad = this
			call TriggerEvaluate(loader)
			call TriggerRemoveCondition(loader, tc)
			set tc = null
			set success = loaded != null
			set loaded = null
			
			return success
		endmethod
		
		static method relation takes integer handleId, integer owner returns boolean
			return HaveSavedInteger(table, -handleId, owner)
		endmethod
		
		static method createWidget takes string label, integer owner, widget h returns thistype
			local thistype this = allocate(GetHandleId(h), owner, widget, label)
			
			call SaveWidgetHandle(table, this, 3, h)
			
			return this
		endmethod
		
		static method createDestructable takes string label, integer owner, destructable h returns thistype
			local thistype this = allocate(GetHandleId(h), owner, destructable, label)
			
			call SaveDestructableHandle(table, this, 3, h)
			
			return this
		endmethod
		
		static method createItem takes string label, integer owner, item h returns thistype
			local thistype this = allocate(GetHandleId(h), owner, item, label)
			
			call SaveItemHandle(table, this, 3, h)
			
			return this
		endmethod
		
		static method createUnit takes string label, integer owner, unit h returns thistype
			local thistype this = allocate(GetHandleId(h), owner, unit, label)
			
			call SaveUnitHandle(table, this, 3, h)
			
			return this
		endmethod
		
		static method createTimer takes string label, integer owner, timer h returns thistype
			local thistype this = allocate(GetHandleId(h), owner, timer, label)
			
			call SaveTimerHandle(table, this, 3, h)
			
			return this
		endmethod
		
		static method createTrigger takes string label, integer owner, trigger h returns thistype
			local thistype this = allocate(GetHandleId(h), owner, trigger, label)
			
			call SaveTriggerHandle(table, this, 3, h)
			
			return this
		endmethod
		
		static method createTriggerCondition takes string label, integer owner, triggercondition h returns thistype
			local thistype this = allocate(GetHandleId(h), owner, triggercondition, label)
			
			call SaveTriggerConditionHandle(table, this, 3, h)
			
			return this
		endmethod
		
		static method createTriggerAction takes string label, integer owner, triggeraction h returns thistype
			local thistype this = allocate(GetHandleId(h), owner, triggeraction, label)
			
			call SaveTriggerActionHandle(table, this, 3, h)
			
			return this
		endmethod
		
		static method createForce takes string label, integer owner, force h returns thistype
			local thistype this = allocate(GetHandleId(h), owner, force, label)
			
			call SaveForceHandle(table, this, 3, h)
			
			return this
		endmethod
		
		static method createGroup takes string label, integer owner, group h returns thistype
			local thistype this = allocate(GetHandleId(h), owner, group, label)
			
			call SaveGroupHandle(table, this, 3, h)
			
			return this
		endmethod
		
		static method createLocation takes string label, integer owner, location h returns thistype
			local thistype this = allocate(GetHandleId(h), owner, location, label)
			
			call SaveLocationHandle(table, this, 3, h)
			
			return this
		endmethod
		
		static method createRect takes string label, integer owner, rect h returns thistype
			local thistype this = allocate(GetHandleId(h), owner, rect, label)
			
			call SaveRectHandle(table, this, 3, h)
			
			return this
		endmethod
		
		static method createBooleanExpr takes string label, integer owner, boolexpr h returns thistype
			local thistype this = allocate(GetHandleId(h), owner, boolexpr, label)
			
			call SaveBooleanExprHandle(table, this, 3, h)
			
			return this
		endmethod
		
		static method createEffect takes string label, integer owner, effect h returns thistype
			local thistype this = allocate(GetHandleId(h), owner, effect, label)
			
			call SaveEffectHandle(table, this, 3, h)
			
			return this
		endmethod
		
		static method createUnitPool takes string label, integer owner, unitpool h returns thistype
			local thistype this = allocate(GetHandleId(h), owner, unitpool, label)
			
			call SaveUnitPoolHandle(table, this, 3, h)
			
			return this
		endmethod
		
		static method createItemPool takes string label, integer owner, itempool h returns thistype
			local thistype this = allocate(GetHandleId(h), owner, itempool, label)
			
			call SaveItemPoolHandle(table, this, 3, h)
			
			return this
		endmethod
		
		static method createQuest takes string label, integer owner, quest h returns thistype
			local thistype this = allocate(GetHandleId(h), owner, quest, label)
			
			call SaveQuestHandle(table, this, 3, h)
			
			return this
		endmethod
		
		static method createDefeatCondition takes string label, integer owner, defeatcondition h returns thistype
			local thistype this = allocate(GetHandleId(h), owner, defeatcondition, label)
			
			call SaveDefeatConditionHandle(table, this, 3, h)
			
			return this
		endmethod
		
		static method createTimerDialog takes string label, integer owner, timerdialog h returns thistype
			local thistype this = allocate(GetHandleId(h), owner, timerdialog, label)
			
			call SaveTimerDialogHandle(table, this, 3, h)
			
			return this
		endmethod
		
		static method createLeaderboard takes string label, integer owner, leaderboard h returns thistype
			local thistype this = allocate(GetHandleId(h), owner, leaderboard, label)
			
			call SaveLeaderboardHandle(table, this, 3, h)
			
			return this
		endmethod
		
		static method createMultiboard takes string label, integer owner, multiboard h returns thistype
			local thistype this = allocate(GetHandleId(h), owner, multiboard, label)
			
			call SaveMultiboardHandle(table, this, 3, h)
			
			return this
		endmethod
		static method createMultiboardItem takes string label, integer owner, multiboarditem h returns thistype
			local thistype this = allocate(GetHandleId(h), owner, multiboarditem, label)
			
			call SaveMultiboardItemHandle(table, this, 3, h)
			
			return this
		endmethod
		
		static method createDialog takes string label, integer owner, dialog h returns thistype
			local thistype this = allocate(GetHandleId(h), owner, dialog, label)
			
			call SaveDialogHandle(table, this, 3, h)
			
			return this
		endmethod
		
		static method createButton takes string label, integer owner, button h returns thistype
			local thistype this = allocate(GetHandleId(h), owner, button, label)
			
			call SaveButtonHandle(table, this, 3, h)
			
			return this
		endmethod
		
		static method createTextTag takes string label, integer owner, texttag h returns thistype
			local thistype this = allocate(GetHandleId(h), owner, texttag, label)
			
			call SaveTextTagHandle(table, this, 3, h)
			
			return this
		endmethod
		
		static method createLightning takes string label, integer owner, lightning h returns thistype
			local thistype this = allocate(GetHandleId(h), owner, lightning, label)
			
			call SaveLightningHandle(table, this, 3, h)
			
			return this
		endmethod
		
		static method createImage takes string label, integer owner, image h returns thistype
			local thistype this = allocate(GetHandleId(h), owner, image, label)
			
			call SaveImageHandle(table, this, 3, h)
			
			return this
		endmethod
		
		static method createUbersplat takes string label, integer owner, ubersplat h returns thistype
			local thistype this = allocate(GetHandleId(h), owner, ubersplat, label)
			
			call SaveUbersplatHandle(table, this, 3, h)
			
			return this
		endmethod
		
		static method createRegion takes string label, integer owner, region h returns thistype
			local thistype this = allocate(GetHandleId(h), owner, region, label)
			
			call SaveRegionHandle(table, this, 3, h)
			
			return this
		endmethod
		
		static method createFogModifier takes string label, integer owner, fogmodifier h returns thistype
			local thistype this = allocate(GetHandleId(h), owner, fogmodifier, label)
			
			call SaveFogModifierHandle(table, this, 3, h)
			
			return this
		endmethod
		
		static method createHashtable takes string label, integer owner, hashtable h returns thistype
			local thistype this = allocate(GetHandleId(h), owner, hashtable, label)
			
			call SaveHashtableHandle(table, this, 3, h)
			
			return this
		endmethod
		
		private static method evalWidget takes nothing returns boolean
			set loaded = LoadWidgetHandle(table, toLoad, 3)
			return false
		endmethod
		private static method evalDestructable takes nothing returns boolean
			set loaded = LoadDestructableHandle(table, toLoad, 3)
			return false
		endmethod
		private static method evalItem takes nothing returns boolean
			set loaded = LoadItemHandle(table, toLoad, 3)
			return false
		endmethod
		private static method evalUnit takes nothing returns boolean
			set loaded = LoadUnitHandle(table, toLoad, 3)
			return false
		endmethod
		private static method evalTimer takes nothing returns boolean
			set loaded = LoadTimerHandle(table, toLoad, 3)
			return false
		endmethod
		private static method evalTrigger takes nothing returns boolean
			set loaded = LoadTriggerHandle(table, toLoad, 3)
			return false
		endmethod
		private static method evalTriggerCondition takes nothing returns boolean
			set loaded = LoadTriggerConditionHandle(table, toLoad, 3)
			return false
		endmethod
		private static method evalTriggerAction takes nothing returns boolean
			set loaded = LoadTriggerActionHandle(table, toLoad, 3)
			return false
		endmethod
		private static method evalForce takes nothing returns boolean
			set loaded = LoadForceHandle(table, toLoad, 3)
			return false
		endmethod
		private static method evalGroup takes nothing returns boolean
			set loaded = LoadGroupHandle(table, toLoad, 3)
			return false
		endmethod
		private static method evalLocation takes nothing returns boolean
			set loaded = LoadLocationHandle(table, toLoad, 3)
			return false
		endmethod
		private static method evalRect takes nothing returns boolean
			set loaded = LoadRectHandle(table, toLoad, 3)
			return false
		endmethod
		private static method evalBooleanExpr takes nothing returns boolean
			set loaded = LoadBooleanExprHandle(table, toLoad, 3)
			return false
		endmethod
		private static method evalEffect takes nothing returns boolean
			set loaded = LoadEffectHandle(table, toLoad, 3)
			return false
		endmethod
		private static method evalUnitPool takes nothing returns boolean
			set loaded = LoadUnitPoolHandle(table, toLoad, 3)
			return false
		endmethod
		private static method evalItemPool takes nothing returns boolean
			set loaded = LoadItemPoolHandle(table, toLoad, 3)
			return false
		endmethod
		private static method evalQuest takes nothing returns boolean
			set loaded = LoadQuestHandle(table, toLoad, 3)
			return false
		endmethod
		private static method evalDefeatCondition takes nothing returns boolean
			set loaded = LoadDefeatConditionHandle(table, toLoad, 3)
			return false
		endmethod
		private static method evalTimerDialog takes nothing returns boolean
			set loaded = LoadTimerDialogHandle(table, toLoad, 3)
			return false
		endmethod
		private static method evalLeaderboard takes nothing returns boolean
			set loaded = LoadLeaderboardHandle(table, toLoad, 3)
			return false
		endmethod
		private static method evalMultiboard takes nothing returns boolean
			set loaded = LoadMultiboardHandle(table, toLoad, 3)
			return false
		endmethod
		private static method evalMultiboardItem takes nothing returns boolean
			set loaded = LoadMultiboardItemHandle(table, toLoad, 3)
			return false
		endmethod
		private static method evalDialog takes nothing returns boolean
			set loaded = LoadDialogHandle(table, toLoad, 3)
			return false
		endmethod
		private static method evalTextTag takes nothing returns boolean
			set loaded = LoadTextTagHandle(table, toLoad, 3)
			return false
		endmethod
		private static method evalLightning takes nothing returns boolean
			set loaded = LoadLightningHandle(table, toLoad, 3)
			return false
		endmethod
		private static method evalImage takes nothing returns boolean
			set loaded = LoadImageHandle(table, toLoad, 3)
			return false
		endmethod
		private static method evalUbersplat takes nothing returns boolean
			set loaded = LoadUbersplatHandle(table, toLoad, 3)
			return false
		endmethod
		private static method evalRegion takes nothing returns boolean
			set loaded = LoadRegionHandle(table, toLoad, 3)
			return false
		endmethod
		private static method evalFogModifier takes nothing returns boolean
			set loaded = LoadFogModifierHandle(table, toLoad, 3)
			return false
		endmethod
		private static method evalHashtable takes nothing returns boolean
			set loaded = LoadHashtableHandle(table, toLoad, 3)
			return false
		endmethod
		private static method evalButton takes nothing returns boolean
			set loaded = LoadButtonHandle(table, toLoad, 3)
			return false
		endmethod
		
		private static method init takes nothing returns nothing
			set loader = CreateTrigger()
			
			set toLoad = 0
			set loaded = null
			
			set eval[widget] = Condition(function thistype.evalWidget)
			set eval[destructable] = Condition(function thistype.evalDestructable)
			set eval[item] = Condition(function thistype.evalItem)
			set eval[unit] = Condition(function thistype.evalUnit)
			set eval[timer] = Condition(function thistype.evalTimer)
			set eval[trigger] = Condition(function thistype.evalTrigger)
			set eval[triggercondition] = Condition(function thistype.evalTriggerCondition)
			set eval[triggeraction] = Condition(function thistype.evalTriggerAction)
			set eval[force] = Condition(function thistype.evalForce)
			set eval[group] = Condition(function thistype.evalGroup)
			set eval[location] = Condition(function thistype.evalLocation)
			set eval[rect] = Condition(function thistype.evalRect)
			set eval[boolexpr] = Condition(function thistype.evalBooleanExpr)
			set eval[effect] = Condition(function thistype.evalEffect)
			set eval[unitpool] = Condition(function thistype.evalUnitPool)
			set eval[itempool] = Condition(function thistype.evalItemPool)
			set eval[quest] = Condition(function thistype.evalQuest)
			set eval[defeatcondition] = Condition(function thistype.evalDefeatCondition)
			set eval[timerdialog] = Condition(function thistype.evalTimerDialog)
			set eval[leaderboard] = Condition(function thistype.evalLeaderboard)
			set eval[multiboard] = Condition(function thistype.evalMultiboard)
			set eval[multiboarditem] = Condition(function thistype.evalMultiboardItem)
			set eval[dialog] = Condition(function thistype.evalDialog)
			set eval[button] = Condition(function thistype.evalButton)
			set eval[texttag] = Condition(function thistype.evalTextTag)
			set eval[lightning] = Condition(function thistype.evalLightning)
			set eval[image] = Condition(function thistype.evalImage)
			set eval[ubersplat] = Condition(function thistype.evalUbersplat)
			set eval[region] = Condition(function thistype.evalRegion)
			set eval[fogmodifier] = Condition(function thistype.evalFogModifier)
			set eval[hashtable] = Condition(function thistype.evalHashtable)
		endmethod
		
		implement doInit
	endstruct

	private struct Memory extends array
	
		//memoryTable	-4, [-x, -1]			value count
		//memoryTable	-2, [-x, -1]			instance label
		//memoryTable	-1, [-x, -1]			parent array count
		//memoryTable	-1, [1, x]				child array count
		//memoryTable	0, [0, x]				recycler
				
		//monitorTable	[1, x], [0, x]			child array
		//monitorTable	[-x, -1], [-x, -1]		child->parent

		//monitorTable	[-x, -1], [0, x]		parent array
		//monitorTable	[-x, -1], [-x, -1]		parent->child
		//monitorTable	[1, x], [-x, -1]		label of parent->child
		
		//memoryTable	[1, x], [0, x]			tracked values
		
	
		public static hashtable memoryTable = InitHashtable()
		public static hashtable monitorTable = InitHashtable()
																	
		public static thistype recycleCount = 0
		public static thistype instanceCount = 0					//negative
		
		//memoryTable	-2, [-x, -1]				instance label
		public method operator allocated takes nothing returns boolean
			return HaveSavedString(memoryTable, -2, this)
		endmethod
		public method operator id takes nothing returns string
			return LoadStr(memoryTable, -2, this)
		endmethod
		public method operator id= takes string str returns nothing
			if (str == null) then
				call RemoveSavedString(memoryTable, -2, this)
			else
				call SaveStr(memoryTable, -2, this, str)
			endif
		endmethod
	endstruct
	
	private struct InstancePool extends array
		public static method operator size takes nothing returns integer
			return Memory.instanceCount
		endmethod
		
		public static method increase takes nothing returns integer
			set Memory.instanceCount = Memory.instanceCount - 1
			return Memory.instanceCount
		endmethod
	endstruct
	
	private struct Recycler extends array
		public static method operator count takes nothing returns integer
			return Memory.recycleCount
		endmethod
		public static method operator count= takes integer i returns nothing
			set Memory.recycleCount = i
		endmethod
		
		public static method operator empty takes nothing returns boolean
			return count == 0
		endmethod
		
		//memoryTable	0, [0, x]					recycler
		public static method operator [] takes integer i returns integer
			return LoadInteger(Memory.memoryTable, 0, i)
		endmethod
		public static method operator []= takes integer i, integer value returns nothing
			call SaveInteger(Memory.memoryTable, 0, i, value)
		endmethod
		public static method clear takes integer i returns nothing
			call RemoveSavedInteger(Memory.memoryTable, 0, i)
		endmethod
		
		public static method push takes integer i returns nothing
			set thistype[count] = i
			set count = count + 1
		endmethod
		public static method pop takes nothing returns integer
			set count = count - 1
			return thistype[count]
		endmethod
	endstruct
	
	private struct ChildArray extends array
		//memoryTable	-1, [1, x]					child array count
		public method operator count takes nothing returns integer
			return LoadInteger(Memory.memoryTable, -1, -this)
		endmethod
		public method clearCount takes nothing returns nothing
			call RemoveSavedInteger(Memory.memoryTable, -1, -this)
		endmethod
		public method operator count= takes integer newCount returns nothing
			static if TRACE then
				call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60000, "ChildArray(" + I2S(this) + ").count = " + I2S(newCount))
			endif
			
			if (newCount == 0) then
				call clearCount()
			else
				call SaveInteger(Memory.memoryTable, -1, -this, newCount)
			endif
		endmethod
		public method operator last takes nothing returns integer
			return count - 1
		endmethod
		
		//monitorTable	[-x, -1], [-x, -1]			child->parent
		public method hasParent takes integer parent returns boolean
			return HaveSavedInteger(Memory.monitorTable, this, parent)
		endmethod
		public method getParentIndex takes integer parent returns integer
			return LoadInteger(Memory.monitorTable, this, parent)
		endmethod
		public method clearParent takes integer parent returns nothing
			static if TRACE then
				call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60000, "ChildArray(" + I2S(this) + ").parent(" + I2S(parent) + ") = null")
			endif
			
			call RemoveSavedInteger(Memory.monitorTable, this, parent)
		endmethod
		public method setParent takes integer parent, integer index returns nothing
			if (parent != 0) then
				static if TRACE then
					call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60000, "ChildArray(" + I2S(this) + ").parent(" + I2S(parent) + ") = " + I2S(index))
				endif
				
				call SaveInteger(Memory.monitorTable, this, parent, index)
			endif
		endmethod
		
		//monitorTable	[1, x], [0, x]				child array
		public method operator [] takes integer index returns integer
			return LoadInteger(Memory.monitorTable, -this, index)
		endmethod
		public method clearIndex takes integer index returns nothing
			static if TRACE then
				call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60000, "ChildArray(" + I2S(this) + ")[" + I2S(index) + "] = null")
			endif
			
			call RemoveSavedInteger(Memory.monitorTable, -this, index)
		endmethod
		public method operator []= takes integer index, integer parent returns nothing
			if (parent != 0) then
				static if TRACE then
					call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60000, "ChildArray(" + I2S(this) + ")[" + I2S(index) + "] = " + I2S(parent))
				endif
				
				call SaveInteger(Memory.monitorTable, -this, index, parent)
				call setParent(parent, index)
			endif
		endmethod
		
		public method remove takes integer index returns nothing
			local integer last = count - 1
			
			call clearParent(this[index])
			
			if (index != last) then
				set this[index] = this[last]
			endif
			
			set count = last
			
			call clearIndex(last)
		endmethod
		
		public method add takes integer parent returns nothing
			local integer last = count
			
			set this[last] = parent
			set count = last + 1
		endmethod
	endstruct
	
	private struct ParentArray extends array
		//memoryTable	-1, [-x, -1]				parent array count
		public method operator count takes nothing returns integer
			return LoadInteger(Memory.memoryTable, -1, this)
		endmethod
		public method clearCount takes nothing returns nothing
			call RemoveSavedInteger(Memory.memoryTable, -1, this)
		endmethod
		public method operator count= takes integer newCount returns nothing
			static if TRACE then
				call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60000, "ParentArray(" + I2S(this) + ").count = " + I2S(newCount))
			endif
			
			if (newCount == 0) then
				call clearCount()
			else
				call SaveInteger(Memory.memoryTable, -1, this, newCount)
			endif
		endmethod
		public method operator last takes nothing returns integer
			return count - 1
		endmethod
		
		//monitorTable	[-x, -1], [-x, -1]			parent->child
		//monitorTable	[1, x], [-x, -1]			label
		public method hasChild takes integer child returns boolean
			return HaveSavedInteger(Memory.monitorTable, this, child)
		endmethod
		public method getChildIndex takes integer child returns integer
			return LoadInteger(Memory.monitorTable, this, child)
		endmethod
		public method getLabel takes ChildArray child returns string
			return LoadStr(Memory.monitorTable, -this, child)
		endmethod
		public method clearChild takes ChildArray child returns nothing
			static if TRACE then
				call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60000, "ParentArray(" + I2S(this) + ").child(" + I2S(child) + ") = null")
				call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60000, "ParentArray(" + I2S(this) + ").label(" + I2S(child) + ") = null")
			endif
			
			call child.remove(child.getParentIndex(this))
			call RemoveSavedInteger(Memory.monitorTable, this, child)
			call RemoveSavedString(Memory.monitorTable, -this, child)
		endmethod
		public method setChild takes string label, ChildArray child, integer index returns nothing
			if (child != 0) then
				static if TRACE then
					call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60000, "ParentArray(" + I2S(this) + ").child(" + I2S(child) + ") = " + I2S(index))
					call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60000, "ParentArray(" + I2S(this) + ").label(" + I2S(child) + ") = " + label)
				endif
				
				call SaveInteger(Memory.monitorTable, this, child, index)
				call SaveStr(Memory.monitorTable, -this, child, label)
				call child.add(this)
			endif
		endmethod
		public method setChildSimple takes integer child, integer index returns nothing
			if (child != 0) then
				static if TRACE then
					call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60000, "ParentArray(" + I2S(this) + ").child(" + I2S(child) + ") = " + I2S(index))
				endif
				
				call SaveInteger(Memory.monitorTable, this, child, index)
			endif
		endmethod

		//monitorTable	[-x, -1], [0, x]			parent array
		public method operator [] takes integer index returns integer
			return LoadInteger(Memory.monitorTable, this, index)
		endmethod
		public method clearIndex takes integer index returns nothing
			static if TRACE then
				call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60000, "ParentArray(" + I2S(this) + ")[" + I2S(index) + "] = null")
			endif
			
			call RemoveSavedInteger(Memory.monitorTable, this, index)
		endmethod
		public method setIndex takes integer index, string label, integer child returns nothing
			if (child != 0) then
				static if TRACE then
					call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60000, "ParentArray(" + I2S(this) + ")[" + I2S(index) + "] = " + I2S(child))
				endif
				
				call SaveInteger(Memory.monitorTable, this, index, child)
				call setChild(label, child, index)
			endif
		endmethod
		public method operator []= takes integer index, integer child returns nothing
			if (child != 0) then
				static if TRACE then
					call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60000, "ParentArray(" + I2S(this) + ")[" + I2S(index) + "] = " + I2S(child))
				endif
				
				call SaveInteger(Memory.monitorTable, this, index, child)
				call setChildSimple(child, index)
			endif
		endmethod
		
		public method remove takes integer index returns nothing
			local integer last = count - 1
			
			call clearChild(this[index])
			
			if (index != last) then
				set this[index] = this[last]
			endif
			
			set count = last
			
			call clearIndex(last)
		endmethod
		
		public method add takes string label, ChildArray child returns nothing
			local integer last = count
			
			call setIndex(last, label, child)
			set count = last + 1
		endmethod
	endstruct
	
	private struct ValueArray extends array
		//memoryTable	-4, [-x, -1]			value count
		private static integer counter = 0
		public method operator count takes nothing returns integer
			set counter = this
			call updateCount()
			return LoadInteger(Memory.memoryTable, -4, this)
		endmethod
		public method clearCount takes nothing returns nothing
			call RemoveSavedInteger(Memory.memoryTable, -4, this)
		endmethod
		public method operator count= takes integer newCount returns nothing
			static if TRACE then
				call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60000, "ValueArray(" + I2S(this) + ").count = " + I2S(newCount))
			endif
			
			if (newCount == 0) then
				call clearCount()
			else
				call SaveInteger(Memory.memoryTable, -4, this, newCount)
			endif
		endmethod
		public method operator last takes nothing returns integer
			return count - 1
		endmethod
		
		//memoryTable	[1, x], [0, x]			tracked values
		public method operator [] takes integer index returns integer
			return LoadInteger(Memory.memoryTable, -this, index)
		endmethod
		public method clearIndex takes integer index returns nothing
			static if TRACE then
				call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60000, "ValueArray(" + I2S(this) + ")[" + I2S(index) + "] = null")
			endif
			
			call RemoveSavedInteger(Memory.memoryTable, -this, index)
		endmethod
		public method operator []= takes integer index, ValueTracker child returns nothing
			if (child != 0) then
				static if TRACE then
					call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60000, "ValueArray(" + I2S(this) + ")[" + I2S(index) + "] = " + I2S(child))
				endif
				
				set child.index = index
				call SaveInteger(Memory.memoryTable, -this, index, child)
			endif
		endmethod
		
		public method remove takes integer index returns nothing
			local integer last = count - 1
			
			call ValueTracker(this[index]).destroy()
			
			if (index != last) then
				set this[index] = this[last]
			endif
			
			set count = last
			
			call clearIndex(last)
		endmethod
		
		public method add takes ValueTracker child returns nothing
			local integer last = count
			
			set this[last] = child
			set count = last + 1
		endmethod
		
		private static method updateCount takes nothing returns nothing
			local thistype this = counter
			local integer i = LoadInteger(Memory.memoryTable, -4, this)
			local integer count = i
			local boolean updateCount = false
			local integer last
			local ValueTracker value
			
			loop
				exitwhen i == 0
				set i = i - 1
				
				set value = this[i]
				
				if (not value.allocated) then
					set last = count - 1
					set count = last
					
					call value.destroy()
					
					if (i != last) then
						set this[i] = this[last]
					endif
					
					call clearIndex(last)
					
					set updateCount = true
				endif
			endloop
			
			if (updateCount) then
				set this.count = count
			endif
		endmethod
	endstruct
	
	struct MemoryMonitor extends array
		method operator allocated takes nothing returns boolean
			return Memory(this).allocated
		endmethod
		
		method operator id takes nothing returns string
			call ThrowError(not allocated, "MemoryAnalysis", "id", "thistype", this, "Attempted To Access Null Instance.")
			return Memory(this).id
		endmethod
		
		static method allocate takes string id returns thistype
			local Memory this
		
			if (Recycler.empty) then
				set this = InstancePool.increase()
			else
				set this = Recycler.pop()
			endif
			
			set Memory(this).id = id
			
			return this
		endmethod
		
		static method create takes string id returns thistype
			return allocate(id)
		endmethod
		
		method deallocate takes nothing returns nothing
			local integer count
			local ParentArray parent
			
			call ThrowError(not allocated, "MemoryAnalysis", "deallocate", "thistype", this, "Attempted To Deallocate Null Instance.")
			
			call Recycler.push(this)
			
			call ThrowError(ParentArray(this).count + ValueArray(this).count != 0, "MemoryAnalysis", "deallocate", id, this, "Memory Leaks Detected (" + I2S(ParentArray(this).count + ValueArray(this).count) + ") -> Memory {" + monitorString + "}")
			
			/*
			*	back indexed array
			*/
			set count = ChildArray(this).count
			
			/*
			*	iterate over all memory monitoring this memory and clear it out
			*/
			loop
				exitwhen count == 0
				set count = count - 1
				
				set parent = ChildArray(this)[count]
				
				call parent.remove(parent.getChildIndex(this))
			endloop
			
			set Memory(this).id = null
		endmethod
		
		method destroy takes nothing returns nothing
			call deallocate()
		endmethod
		
		method stopMonitorValue takes handle h returns nothing
			call ThrowError(not allocated, "MemoryAnalysis", "stopMonitorValue", "thistype", this, "Attempted To Monitor From Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(h == null, "MemoryAnalysis", "stopMonitorValue", "thistype", this, "Attempted To Monitor Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(not ValueTracker.relation(GetHandleId(h), this), "MemoryAnalysis", "stopMonitorValue", "(" + id + ")", this, "Attempted To Stop Monitoring An Instance Not Being Monitored (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
		
			call ValueArray(this).remove(ValueTracker[h][this].index)
		endmethod
		
		method monitor takes string id, thistype address returns nothing
			call ThrowError(not allocated, "MemoryAnalysis", "monitor", "thistype", this, "Attempted To Monitor From Null Instance (" + I2S(this) + ", " + I2S(address) + ").")
			call ThrowError(not address.allocated, "MemoryAnalysis", "monitor", "thistype", this, "Attempted To Monitor Null Instance (" + I2S(this) + ", " + I2S(address) + ").")
			call ThrowError(ParentArray(this).hasChild(address), "MemoryAnalysis", "monitor", "(" + id + ", " + address.id + ")", this, "Attempted To Monitor An Instance Already Being Monitored (" + I2S(this) + ", " + I2S(address) + ").")
		
			call ParentArray(this).add(id, address)
		endmethod
		
		method stopMonitor takes thistype address returns nothing
			call ThrowError(not allocated, "MemoryAnalysis", "stopMonitor", "thistype", this, "Attempted To Monitor From Null Instance (" + I2S(this) + ", " + I2S(address) + ").")
			call ThrowError(not address.allocated, "MemoryAnalysis", "stopMonitor", "thistype", this, "Attempted To Monitor Null Instance (" + I2S(this) + ", " + I2S(address) + ").")
			call ThrowError(not ParentArray(this).hasChild(address), "MemoryAnalysis", "stopMonitor", "(" + id + ", " + address.id + ")", this, "Attempted To Stop Monitoring An Instance Not Being Monitored (" + I2S(this) + ", " + I2S(address) + ").")
		
			call ParentArray(this).remove(ParentArray(this).getChildIndex(address))
		endmethod
		
		method operator monitorCount takes nothing returns integer
			call ThrowError(not allocated, "MemoryAnalysis", "monitorCount", "thistype", this, "Attempted To Access Null Instance.")
		
			return ParentArray(this).count + ValueArray(this).count
		endmethod
		
		private static string string
		private static ParentArray monitorStringArray
		private static integer monitorIndexString
		private static integer monitorIndexString2
		method operator monitorString takes nothing returns string
			call ThrowError(not allocated, "MemoryAnalysis", "monitorCount", "thistype", this, "Attempted To Access Null Instance.")
			
			set string = null
			set monitorStringArray = this
			set monitorIndexString = ParentArray(this).count
			set monitorIndexString2 = ValueArray(this).count
			
			call monitorStringLoop__main()
			
			return string
		endmethod
		
		private static method monitorStringLoop__main takes nothing returns nothing
			loop
				exitwhen monitorIndexString == 0
				call monitorStringLoop()
			endloop
			
			loop
				exitwhen monitorIndexString2 == 0
				call monitorStringLoop2()
			endloop
		endmethod
		
		private static method monitorStringLoop takes nothing returns nothing
			local integer current = monitorIndexString
			set monitorIndexString = current - 500
			
			if (monitorIndexString < 0) then
				set monitorIndexString = 0
			endif
			
			loop
				exitwhen current == 0
				set current = current - 1
				
				if (string == null) then
					set string = "(" + monitorStringArray.getLabel(monitorStringArray[current]) + " = " + I2S(monitorStringArray[current]) + ")"
				else
					set string = "(" + monitorStringArray.getLabel(monitorStringArray[current]) + " = " + I2S(monitorStringArray[current]) + ")" + ", " + string
				endif
			endloop
		endmethod
		
		private static method monitorStringLoop2 takes nothing returns nothing
			local integer current = monitorIndexString2
			set monitorIndexString2 = current - 500
			
			if (monitorIndexString2 < 0) then
				set monitorIndexString2 = 0
			endif
			
			loop
				exitwhen current == 0
				set current = current - 1
				
				if (string == null) then
					set string = "(" + ValueTracker(ValueArray(monitorStringArray)[current]).label + " = " + I2S(ValueArray(monitorStringArray)[current]) + ")"
				else
					set string = "(" + ValueTracker(ValueArray(monitorStringArray)[current]).label + " = " + I2S(ValueArray(monitorStringArray)[current]) + ")" + ", " + string
				endif
			endloop
		endmethod
		
		method monitor_widget takes string label, widget h returns nothing
			call ThrowError(not Memory(this).allocated,						"MemoryAnalysis", "widget", "thistype", this, "Attempted To Monitor From Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(h == null,										"MemoryAnalysis", "widget", "thistype", this, "Attempted To Monitor Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(ValueTracker.relation(GetHandleId(h), this),	"MemoryAnalysis", "widget", "(" + Memory(this).id + ", " + ValueTracker[h][this].label + ")", this, "Attempted To Monitor An Instance Already Being Monitored (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			
			call ValueArray(this).add(ValueTracker.createWidget(label, this, h))
		endmethod
		
		method monitor_destructable takes string label, destructable h returns nothing
			call ThrowError(not Memory(this).allocated,						"MemoryAnalysis", "destructable", "thistype", this, "Attempted To Monitor From Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(h == null,										"MemoryAnalysis", "destructable", "thistype", this, "Attempted To Monitor Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(ValueTracker.relation(GetHandleId(h), this),	"MemoryAnalysis", "destructable", "(" + Memory(this).id + ", " + ValueTracker[h][this].label + ")", this, "Attempted To Monitor An Instance Already Being Monitored (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			
			call ValueArray(this).add(ValueTracker.createDestructable(label, this, h))
		endmethod
		
		method monitor_item takes string label, item h returns nothing
			call ThrowError(not Memory(this).allocated,						"MemoryAnalysis", "item", "thistype", this, "Attempted To Monitor From Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(h == null,										"MemoryAnalysis", "item", "thistype", this, "Attempted To Monitor Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(ValueTracker.relation(GetHandleId(h), this),	"MemoryAnalysis", "item", "(" + Memory(this).id + ", " + ValueTracker[h][this].label + ")", this, "Attempted To Monitor An Instance Already Being Monitored (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			
			call ValueArray(this).add(ValueTracker.createItem(label, this, h))
		endmethod
		
		method monitor_unit takes string label, unit h returns nothing
			call ThrowError(not Memory(this).allocated,						"MemoryAnalysis", "unit", "thistype", this, "Attempted To Monitor From Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(h == null,										"MemoryAnalysis", "unit", "thistype", this, "Attempted To Monitor Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(ValueTracker.relation(GetHandleId(h), this),	"MemoryAnalysis", "unit", "(" + Memory(this).id + ", " + ValueTracker[h][this].label + ")", this, "Attempted To Monitor An Instance Already Being Monitored (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			
			call ValueArray(this).add(ValueTracker.createUnit(label, this, h))
		endmethod
		
		method monitor_timer takes string label, timer h returns nothing
			call ThrowError(not Memory(this).allocated,						"MemoryAnalysis", "timer", "thistype", this, "Attempted To Monitor From Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(h == null,										"MemoryAnalysis", "timer", "thistype", this, "Attempted To Monitor Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(ValueTracker.relation(GetHandleId(h), this),	"MemoryAnalysis", "timer", "(" + Memory(this).id + ", " + ValueTracker[h][this].label + ")", this, "Attempted To Monitor An Instance Already Being Monitored (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			
			call ValueArray(this).add(ValueTracker.createTimer(label, this, h))
		endmethod
		
		method monitor_trigger takes string label, trigger h returns nothing
			call ThrowError(not Memory(this).allocated,						"MemoryAnalysis", "trigger", "thistype", this, "Attempted To Monitor From Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(h == null,										"MemoryAnalysis", "trigger", "thistype", this, "Attempted To Monitor Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(ValueTracker.relation(GetHandleId(h), this),	"MemoryAnalysis", "trigger", "(" + Memory(this).id + ", " + ValueTracker[h][this].label + ")", this, "Attempted To Monitor An Instance Already Being Monitored (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			
			call ValueArray(this).add(ValueTracker.createTrigger(label, this, h))
		endmethod
		
		method monitor_triggercondition takes string label, triggercondition h returns nothing
			call ThrowError(not Memory(this).allocated,						"MemoryAnalysis", "triggercondition", "thistype", this, "Attempted To Monitor From Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(h == null,										"MemoryAnalysis", "triggercondition", "thistype", this, "Attempted To Monitor Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(ValueTracker.relation(GetHandleId(h), this),	"MemoryAnalysis", "triggercondition", "(" + Memory(this).id + ", " + ValueTracker[h][this].label + ")", this, "Attempted To Monitor An Instance Already Being Monitored (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			
			call ValueArray(this).add(ValueTracker.createTriggerCondition(label, this, h))
		endmethod
		
		method monitor_triggeraction takes string label, triggeraction h returns nothing
			call ThrowError(not Memory(this).allocated,						"MemoryAnalysis", "triggeraction", "thistype", this, "Attempted To Monitor From Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(h == null,										"MemoryAnalysis", "triggeraction", "thistype", this, "Attempted To Monitor Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(ValueTracker.relation(GetHandleId(h), this),	"MemoryAnalysis", "triggeraction", "(" + Memory(this).id + ", " + ValueTracker[h][this].label + ")", this, "Attempted To Monitor An Instance Already Being Monitored (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			
			call ValueArray(this).add(ValueTracker.createTriggerAction(label, this, h))
		endmethod
		
		method monitor_force takes string label, force h returns nothing
			call ThrowError(not Memory(this).allocated,						"MemoryAnalysis", "force", "thistype", this, "Attempted To Monitor From Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(h == null,										"MemoryAnalysis", "force", "thistype", this, "Attempted To Monitor Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(ValueTracker.relation(GetHandleId(h), this),	"MemoryAnalysis", "force", "(" + Memory(this).id + ", " + ValueTracker[h][this].label + ")", this, "Attempted To Monitor An Instance Already Being Monitored (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			
			call ValueArray(this).add(ValueTracker.createForce(label, this, h))
		endmethod
		
		method monitor_group takes string label, group h returns nothing
			call ThrowError(not Memory(this).allocated,						"MemoryAnalysis", "group", "thistype", this, "Attempted To Monitor From Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(h == null,										"MemoryAnalysis", "group", "thistype", this, "Attempted To Monitor Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(ValueTracker.relation(GetHandleId(h), this),	"MemoryAnalysis", "group", "(" + Memory(this).id + ", " + ValueTracker[h][this].label + ")", this, "Attempted To Monitor An Instance Already Being Monitored (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			
			call ValueArray(this).add(ValueTracker.createGroup(label, this, h))
		endmethod
		
		method monitor_location takes string label, location h returns nothing
			call ThrowError(not Memory(this).allocated,						"MemoryAnalysis", "location", "thistype", this, "Attempted To Monitor From Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(h == null,										"MemoryAnalysis", "location", "thistype", this, "Attempted To Monitor Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(ValueTracker.relation(GetHandleId(h), this),	"MemoryAnalysis", "location", "(" + Memory(this).id + ", " + ValueTracker[h][this].label + ")", this, "Attempted To Monitor An Instance Already Being Monitored (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			
			call ValueArray(this).add(ValueTracker.createLocation(label, this, h))
		endmethod
		
		method monitor_rect takes string label, rect h returns nothing
			call ThrowError(not Memory(this).allocated,						"MemoryAnalysis", "rect", "thistype", this, "Attempted To Monitor From Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(h == null,										"MemoryAnalysis", "rect", "thistype", this, "Attempted To Monitor Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(ValueTracker.relation(GetHandleId(h), this),	"MemoryAnalysis", "rect", "(" + Memory(this).id + ", " + ValueTracker[h][this].label + ")", this, "Attempted To Monitor An Instance Already Being Monitored (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			
			call ValueArray(this).add(ValueTracker.createRect(label, this, h))
		endmethod
		
		method monitor_boolexpr takes string label, boolexpr h returns nothing
			call ThrowError(not Memory(this).allocated,						"MemoryAnalysis", "boolexpr", "thistype", this, "Attempted To Monitor From Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(h == null,										"MemoryAnalysis", "boolexpr", "thistype", this, "Attempted To Monitor Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(ValueTracker.relation(GetHandleId(h), this),	"MemoryAnalysis", "boolexpr", "(" + Memory(this).id + ", " + ValueTracker[h][this].label + ")", this, "Attempted To Monitor An Instance Already Being Monitored (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			
			call ValueArray(this).add(ValueTracker.createBooleanExpr(label, this, h))
		endmethod
		
		method monitor_effect takes string label, effect h returns nothing
			call ThrowError(not Memory(this).allocated,						"MemoryAnalysis", "effect", "thistype", this, "Attempted To Monitor From Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(h == null,										"MemoryAnalysis", "effect", "thistype", this, "Attempted To Monitor Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(ValueTracker.relation(GetHandleId(h), this),	"MemoryAnalysis", "effect", "(" + Memory(this).id + ", " + ValueTracker[h][this].label + ")", this, "Attempted To Monitor An Instance Already Being Monitored (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			
			call ValueArray(this).add(ValueTracker.createEffect(label, this, h))
		endmethod
		
		method monitor_unitpool takes string label, unitpool h returns nothing
			call ThrowError(not Memory(this).allocated,						"MemoryAnalysis", "unitpool", "thistype", this, "Attempted To Monitor From Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(h == null,										"MemoryAnalysis", "unitpool", "thistype", this, "Attempted To Monitor Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(ValueTracker.relation(GetHandleId(h), this),	"MemoryAnalysis", "unitpool", "(" + Memory(this).id + ", " + ValueTracker[h][this].label + ")", this, "Attempted To Monitor An Instance Already Being Monitored (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			
			call ValueArray(this).add(ValueTracker.createUnitPool(label, this, h))
		endmethod
		
		method monitor_itempool takes string label, itempool h returns nothing
			call ThrowError(not Memory(this).allocated,						"MemoryAnalysis", "itempool", "thistype", this, "Attempted To Monitor From Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(h == null,										"MemoryAnalysis", "itempool", "thistype", this, "Attempted To Monitor Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(ValueTracker.relation(GetHandleId(h), this),	"MemoryAnalysis", "itempool", "(" + Memory(this).id + ", " + ValueTracker[h][this].label + ")", this, "Attempted To Monitor An Instance Already Being Monitored (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			
			call ValueArray(this).add(ValueTracker.createItemPool(label, this, h))
		endmethod
		
		method monitor_quest takes string label, quest h returns nothing
			call ThrowError(not Memory(this).allocated,						"MemoryAnalysis", "quest", "thistype", this, "Attempted To Monitor From Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(h == null,										"MemoryAnalysis", "quest", "thistype", this, "Attempted To Monitor Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(ValueTracker.relation(GetHandleId(h), this),	"MemoryAnalysis", "quest", "(" + Memory(this).id + ", " + ValueTracker[h][this].label + ")", this, "Attempted To Monitor An Instance Already Being Monitored (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			
			call ValueArray(this).add(ValueTracker.createQuest(label, this, h))
		endmethod
		
		method monitor_defeatcondition takes string label, defeatcondition h returns nothing
			call ThrowError(not Memory(this).allocated,						"MemoryAnalysis", "defeatcondition", "thistype", this, "Attempted To Monitor From Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(h == null,										"MemoryAnalysis", "defeatcondition", "thistype", this, "Attempted To Monitor Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(ValueTracker.relation(GetHandleId(h), this),	"MemoryAnalysis", "defeatcondition", "(" + Memory(this).id + ", " + ValueTracker[h][this].label + ")", this, "Attempted To Monitor An Instance Already Being Monitored (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			
			call ValueArray(this).add(ValueTracker.createDefeatCondition(label, this, h))
		endmethod
		
		method monitor_timerdialog takes string label, timerdialog h returns nothing
			call ThrowError(not Memory(this).allocated,						"MemoryAnalysis", "timerdialog", "thistype", this, "Attempted To Monitor From Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(h == null,										"MemoryAnalysis", "timerdialog", "thistype", this, "Attempted To Monitor Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(ValueTracker.relation(GetHandleId(h), this),	"MemoryAnalysis", "timerdialog", "(" + Memory(this).id + ", " + ValueTracker[h][this].label + ")", this, "Attempted To Monitor An Instance Already Being Monitored (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			
			call ValueArray(this).add(ValueTracker.createTimerDialog(label, this, h))
		endmethod
		
		method monitor_leaderboard takes string label, leaderboard h returns nothing
			call ThrowError(not Memory(this).allocated,						"MemoryAnalysis", "leaderboard", "thistype", this, "Attempted To Monitor From Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(h == null,										"MemoryAnalysis", "leaderboard", "thistype", this, "Attempted To Monitor Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(ValueTracker.relation(GetHandleId(h), this),	"MemoryAnalysis", "leaderboard", "(" + Memory(this).id + ", " + ValueTracker[h][this].label + ")", this, "Attempted To Monitor An Instance Already Being Monitored (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			
			call ValueArray(this).add(ValueTracker.createLeaderboard(label, this, h))
		endmethod
		
		method monitor_multiboard takes string label, multiboard h returns nothing
			call ThrowError(not Memory(this).allocated,						"MemoryAnalysis", "multiboard", "thistype", this, "Attempted To Monitor From Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(h == null,										"MemoryAnalysis", "multiboard", "thistype", this, "Attempted To Monitor Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(ValueTracker.relation(GetHandleId(h), this),	"MemoryAnalysis", "multiboard", "(" + Memory(this).id + ", " + ValueTracker[h][this].label + ")", this, "Attempted To Monitor An Instance Already Being Monitored (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			
			call ValueArray(this).add(ValueTracker.createMultiboard(label, this, h))
		endmethod
		
		method monitor_multiboarditem takes string label, multiboarditem h returns nothing
			call ThrowError(not Memory(this).allocated,						"MemoryAnalysis", "multiboarditem", "thistype", this, "Attempted To Monitor From Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(h == null,										"MemoryAnalysis", "multiboarditem", "thistype", this, "Attempted To Monitor Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(ValueTracker.relation(GetHandleId(h), this),	"MemoryAnalysis", "multiboarditem", "(" + Memory(this).id + ", " + ValueTracker[h][this].label + ")", this, "Attempted To Monitor An Instance Already Being Monitored (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			
			call ValueArray(this).add(ValueTracker.createMultiboardItem(label, this, h))
		endmethod
		
		method monitor_dialog takes string label, dialog h returns nothing
			call ThrowError(not Memory(this).allocated,						"MemoryAnalysis", "dialog", "thistype", this, "Attempted To Monitor From Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(h == null,										"MemoryAnalysis", "dialog", "thistype", this, "Attempted To Monitor Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(ValueTracker.relation(GetHandleId(h), this),	"MemoryAnalysis", "dialog", "(" + Memory(this).id + ", " + ValueTracker[h][this].label + ")", this, "Attempted To Monitor An Instance Already Being Monitored (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			
			call ValueArray(this).add(ValueTracker.createDialog(label, this, h))
		endmethod
		
		method monitor_button takes string label, button h returns nothing
			call ThrowError(not Memory(this).allocated,						"MemoryAnalysis", "button", "thistype", this, "Attempted To Monitor From Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(h == null,										"MemoryAnalysis", "button", "thistype", this, "Attempted To Monitor Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(ValueTracker.relation(GetHandleId(h), this),	"MemoryAnalysis", "button", "(" + Memory(this).id + ", " + ValueTracker[h][this].label + ")", this, "Attempted To Monitor An Instance Already Being Monitored (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			
			call ValueArray(this).add(ValueTracker.createButton(label, this, h))
		endmethod
		
		method monitor_texttag takes string label, texttag h returns nothing
			call ThrowError(not Memory(this).allocated,						"MemoryAnalysis", "texttag", "thistype", this, "Attempted To Monitor From Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(h == null,										"MemoryAnalysis", "texttag", "thistype", this, "Attempted To Monitor Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(ValueTracker.relation(GetHandleId(h), this),	"MemoryAnalysis", "texttag", "(" + Memory(this).id + ", " + ValueTracker[h][this].label + ")", this, "Attempted To Monitor An Instance Already Being Monitored (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			
			call ValueArray(this).add(ValueTracker.createTextTag(label, this, h))
		endmethod
		
		method monitor_lightning takes string label, lightning h returns nothing
			call ThrowError(not Memory(this).allocated,						"MemoryAnalysis", "lightning", "thistype", this, "Attempted To Monitor From Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(h == null,										"MemoryAnalysis", "lightning", "thistype", this, "Attempted To Monitor Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(ValueTracker.relation(GetHandleId(h), this),	"MemoryAnalysis", "lightning", "(" + Memory(this).id + ", " + ValueTracker[h][this].label + ")", this, "Attempted To Monitor An Instance Already Being Monitored (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			
			call ValueArray(this).add(ValueTracker.createLightning(label, this, h))
		endmethod
		
		method monitor_image takes string label, image h returns nothing
			call ThrowError(not Memory(this).allocated,						"MemoryAnalysis", "image", "thistype", this, "Attempted To Monitor From Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(h == null,										"MemoryAnalysis", "image", "thistype", this, "Attempted To Monitor Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(ValueTracker.relation(GetHandleId(h), this),	"MemoryAnalysis", "image", "(" + Memory(this).id + ", " + ValueTracker[h][this].label + ")", this, "Attempted To Monitor An Instance Already Being Monitored (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			
			call ValueArray(this).add(ValueTracker.createImage(label, this, h))
		endmethod
		
		method monitor_ubersplat takes string label, ubersplat h returns nothing
			call ThrowError(not Memory(this).allocated,						"MemoryAnalysis", "ubersplat", "thistype", this, "Attempted To Monitor From Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(h == null,										"MemoryAnalysis", "ubersplat", "thistype", this, "Attempted To Monitor Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(ValueTracker.relation(GetHandleId(h), this),	"MemoryAnalysis", "ubersplat", "(" + Memory(this).id + ", " + ValueTracker[h][this].label + ")", this, "Attempted To Monitor An Instance Already Being Monitored (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			
			call ValueArray(this).add(ValueTracker.createUbersplat(label, this, h))
		endmethod
		
		method monitor_region takes string label, region h returns nothing
			call ThrowError(not Memory(this).allocated,						"MemoryAnalysis", "region", "thistype", this, "Attempted To Monitor From Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(h == null,										"MemoryAnalysis", "region", "thistype", this, "Attempted To Monitor Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(ValueTracker.relation(GetHandleId(h), this),	"MemoryAnalysis", "region", "(" + Memory(this).id + ", " + ValueTracker[h][this].label + ")", this, "Attempted To Monitor An Instance Already Being Monitored (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			
			call ValueArray(this).add(ValueTracker.createRegion(label, this, h))
		endmethod
		
		method monitor_fogmodifier takes string label, fogmodifier h returns nothing
			call ThrowError(not Memory(this).allocated,						"MemoryAnalysis", "fogmodifier", "thistype", this, "Attempted To Monitor From Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(h == null,										"MemoryAnalysis", "fogmodifier", "thistype", this, "Attempted To Monitor Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(ValueTracker.relation(GetHandleId(h), this),	"MemoryAnalysis", "fogmodifier", "(" + Memory(this).id + ", " + ValueTracker[h][this].label + ")", this, "Attempted To Monitor An Instance Already Being Monitored (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			
			call ValueArray(this).add(ValueTracker.createFogModifier(label, this, h))
		endmethod
		
		method monitor_hashtable takes string label, hashtable h returns nothing
			call ThrowError(not Memory(this).allocated,						"MemoryAnalysis", "hashtable", "thistype", this, "Attempted To Monitor From Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(h == null,										"MemoryAnalysis", "hashtable", "thistype", this, "Attempted To Monitor Null Instance (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			call ThrowError(ValueTracker.relation(GetHandleId(h), this),	"MemoryAnalysis", "hashtable", "(" + Memory(this).id + ", " + ValueTracker[h][this].label + ")", this, "Attempted To Monitor An Instance Already Being Monitored (" + I2S(this) + ", " + I2S(GetHandleId(h)) + ").")
			
			call ValueArray(this).add(ValueTracker.createHashtable(label, this, h))
		endmethod
	endstruct
	
	endif

	//! textmacro MEMORY_ANALYSIS_FIELD_OLD takes STACK, INSTANCE_COUNT
		static if DEBUG_MODE then
			private static integer p__index__$STACK$
			private static integer p__length__$STACK$
			private static string p__string__$STACK$
			private static Table p__table__$STACK$
			private static thistype p__node__$STACK$
			private static integer p__instanceCount__$STACK$
			
			private static method calculateFreeMemory__$STACK$ takes nothing returns integer
				call calculateFreeMemoryLoop__$STACK$__main()
				
				return 8191 + p__length__$STACK$ - $INSTANCE_COUNT$
			endmethod
			
			private static method calculateAllocatedMemory__$STACK$ takes nothing returns integer
				call calculateFreeMemoryLoop__$STACK$__main()
				
				return $INSTANCE_COUNT$ - p__length__$STACK$
			endmethod
			
			private static method calculateFreeMemoryLoop__$STACK$__main takes nothing returns nothing
				set p__length__$STACK$ = 0
				set p__node__$STACK$ = thistype(0).$STACK$
				
				loop
					exitwhen p__node__$STACK$ == 0
					call calculateFreeMemoryLoop__$STACK$()
				endloop
			endmethod
			
			private static method calculateFreeMemoryLoop__$STACK$ takes nothing returns nothing
				set p__index__$STACK$ = 500
				
				loop
					exitwhen p__index__$STACK$ == 0 or p__node__$STACK$ == 0
					
					set p__length__$STACK$ = p__length__$STACK$ + 1
					set p__index__$STACK$ = p__index__$STACK$ - 1
					set p__node__$STACK$ = p__node__$STACK$.$STACK$
				endloop
			endmethod
			
			private static method allocatedMemoryString__$STACK$ takes nothing returns string
				call calculateAllocatedMemoryStringLoop__$STACK$__main()
				
				return p__string__$STACK$
			endmethod
			
			private static method calculateAllocatedMemoryStringLoop__$STACK$__main takes nothing returns nothing
				set p__table__$STACK$ = Table.create()
				set p__instanceCount__$STACK$ = $INSTANCE_COUNT$
				
				set p__string__$STACK$ = null
				
				set p__node__$STACK$ = thistype(0).$STACK$
				
				loop
					exitwhen p__node__$STACK$ == 0
					call calculateAllocatedMemoryStringLoop__$STACK$()
				endloop
				
				set p__length__$STACK$ = 0
				set p__index__$STACK$ = 0
				loop
					exitwhen p__length__$STACK$ == p__instanceCount__$STACK$
					call calculateAllocatedMemoryStringLoop__$STACK$__2()
				endloop
				
				call p__table__$STACK$.destroy()
			endmethod
			
			private static method calculateAllocatedMemoryStringLoop__$STACK$ takes nothing returns nothing
				set p__index__$STACK$ = 500
				
				loop
					exitwhen p__index__$STACK$ == 0 or p__node__$STACK$ == 0
					
					set p__index__$STACK$ = p__index__$STACK$ - 1
					set p__table__$STACK$.boolean[p__node__$STACK$] = true
					set p__node__$STACK$ = p__node__$STACK$.$STACK$
				endloop
			endmethod
			
			private static method calculateAllocatedMemoryStringLoop__$STACK$__2 takes nothing returns nothing
				set p__length__$STACK$ = p__index__$STACK$ + 500
				
				if (p__length__$STACK$ > p__instanceCount__$STACK$) then
					set p__length__$STACK$ = $INSTANCE_COUNT$
				endif
				
				loop
					exitwhen p__index__$STACK$ == p__length__$STACK$
					
					set p__index__$STACK$ = p__index__$STACK$ + 1
					
					if (not p__table__$STACK$.boolean.has(p__index__$STACK$)) then
						if (p__string__$STACK$ == null) then
							set p__string__$STACK$ = I2S(p__index__$STACK$)
						else
							set p__string__$STACK$ = p__string__$STACK$ + ", " + I2S(p__index__$STACK$)
						endif
					endif
				endloop
			endmethod
		endif
	//! endtextmacro

	//! textmacro MEMORY_ANALYSIS_FIELD_NEW takes STACK
		static if DEBUG_MODE then
			private static integer p__index__$STACK$
			private static integer p__length__$STACK$
			private static string p__string__$STACK$
			private static Table p__table__$STACK$
			private static thistype p__node__$STACK$
			private static integer p__instanceCount__$STACK$
			
			private static method calculateFreeMemory__$STACK$ takes nothing returns integer
				call calculateFreeMemoryLoop__$STACK$__main()
				
				return 8191 + p__length__$STACK$ - p__instanceCount__$STACK$
			endmethod
			
			private static method calculateAllocatedMemory__$STACK$ takes nothing returns integer
				call calculateFreeMemoryLoop__$STACK$__main()
				
				return p__instanceCount__$STACK$ - p__length__$STACK$
			endmethod
			
			private static method calculateFreeMemoryLoop__$STACK$__main takes nothing returns nothing
				set p__length__$STACK$ = 0
				set p__node__$STACK$ = thistype(0).$STACK$
				
				loop
					exitwhen p__node__$STACK$ == 0
					call calculateFreeMemoryLoop__$STACK$()
				endloop
			endmethod
			
			private static method calculateFreeMemoryLoop__$STACK$ takes nothing returns nothing
				set p__index__$STACK$ = 500
				
				loop
					exitwhen p__index__$STACK$ == 0 or p__node__$STACK$ == 0
					
					set p__length__$STACK$ = p__length__$STACK$ + 1
					set p__index__$STACK$ = p__index__$STACK$ - 1
					set p__instanceCount__$STACK$ = p__node__$STACK$
					set p__node__$STACK$ = p__node__$STACK$.$STACK$
				endloop
			endmethod
			
			private static method allocatedMemoryString__$STACK$ takes nothing returns string
				call calculateAllocatedMemoryStringLoop__$STACK$__main()
				
				return p__string__$STACK$
			endmethod
			
			private static method calculateAllocatedMemoryStringLoop__$STACK$__main takes nothing returns nothing
				set p__table__$STACK$ = Table.create()
				
				set p__string__$STACK$ = null
				
				set p__node__$STACK$ = thistype(0).$STACK$
				
				loop
					exitwhen p__node__$STACK$ == 0
					call calculateAllocatedMemoryStringLoop__$STACK$()
				endloop
				
				call p__table__$STACK$.boolean.remove(p__instanceCount__$STACK$)
				set p__instanceCount__$STACK$ = p__instanceCount__$STACK$ - 1
				
				set p__length__$STACK$ = 0
				set p__index__$STACK$ = 0
				loop
					exitwhen p__length__$STACK$ == p__instanceCount__$STACK$
					call calculateAllocatedMemoryStringLoop__$STACK$__2()
				endloop
				
				call p__table__$STACK$.destroy()
			endmethod
			
			private static method calculateAllocatedMemoryStringLoop__$STACK$ takes nothing returns nothing
				set p__index__$STACK$ = 500
				
				loop
					exitwhen p__index__$STACK$ == 0 or p__node__$STACK$ == 0
					
					set p__index__$STACK$ = p__index__$STACK$ - 1
					set p__table__$STACK$.boolean[p__node__$STACK$] = true
					set p__instanceCount__$STACK$ = p__node__$STACK$
					set p__node__$STACK$ = p__node__$STACK$.$STACK$
				endloop
			endmethod
			
			private static method calculateAllocatedMemoryStringLoop__$STACK$__2 takes nothing returns nothing
				set p__length__$STACK$ = p__index__$STACK$ + 500
				
				if (p__length__$STACK$ > p__instanceCount__$STACK$) then
					set p__length__$STACK$ = p__instanceCount__$STACK$
				endif
				
				loop
					exitwhen p__index__$STACK$ == p__length__$STACK$
					
					set p__index__$STACK$ = p__index__$STACK$ + 1
					
					if (not p__table__$STACK$.boolean.has(p__index__$STACK$)) then
						if (p__string__$STACK$ == null) then
							set p__string__$STACK$ = I2S(p__index__$STACK$)
						else
							set p__string__$STACK$ = p__string__$STACK$ + ", " + I2S(p__index__$STACK$)
						endif
					endif
				endloop
			endmethod
		endif
	//! endtextmacro

	//! textmacro MEMORY_ANALYSIS_FIELD_FAST takes STACK
		static if DEBUG_MODE then
			private static integer p__index__$STACK$
			private static integer p__length__$STACK$
			private static string p__string__$STACK$
			private static Table p__table__$STACK$
			private static thistype p__node__$STACK$
			
			private static method calculateFreeMemory__$STACK$ takes nothing returns integer
				call calculateFreeMemoryLoop__$STACK$__main()
				
				return p__length__$STACK$
			endmethod
			
			private static method calculateAllocatedMemory__$STACK$ takes nothing returns integer
				call calculateFreeMemoryLoop__$STACK$__main()
				
				return 8191 - p__length__$STACK$
			endmethod
			
			private static method calculateFreeMemoryLoop__$STACK$__main takes nothing returns nothing
				set p__length__$STACK$ = 0
				set p__node__$STACK$ = thistype(0).$STACK$
				
				loop
					exitwhen p__node__$STACK$ == 0
					call calculateFreeMemoryLoop__$STACK$()
				endloop
			endmethod
			
			private static method calculateFreeMemoryLoop__$STACK$ takes nothing returns nothing
				set p__index__$STACK$ = 500
				
				loop
					exitwhen p__index__$STACK$ == 0 or p__node__$STACK$ == 0
					
					set p__length__$STACK$ = p__length__$STACK$ + 1
					set p__index__$STACK$ = p__index__$STACK$ - 1
					set p__node__$STACK$ = p__node__$STACK$.$STACK$
				endloop
			endmethod
			
			private static method allocatedMemoryString__$STACK$ takes nothing returns string
				call calculateAllocatedMemoryStringLoop__$STACK$__main()
				
				return p__string__$STACK$
			endmethod
			
			private static method calculateAllocatedMemoryStringLoop__$STACK$__main takes nothing returns nothing
				set p__table__$STACK$ = Table.create()
				
				set p__string__$STACK$ = null
				
				set p__node__$STACK$ = thistype(0).$STACK$
				
				loop
					exitwhen p__node__$STACK$ == 0
					call calculateAllocatedMemoryStringLoop__$STACK$()
				endloop
				
				set p__length__$STACK$ = 0
				set p__index__$STACK$ = 0
				loop
					exitwhen p__length__$STACK$ == 8191
					call calculateAllocatedMemoryStringLoop__$STACK$__2()
				endloop
				
				call p__table__$STACK$.destroy()
			endmethod
			
			private static method calculateAllocatedMemoryStringLoop__$STACK$ takes nothing returns nothing
				set p__index__$STACK$ = 500
				
				loop
					exitwhen p__index__$STACK$ == 0 or p__node__$STACK$ == 0
					
					set p__index__$STACK$ = p__index__$STACK$ - 1
					set p__table__$STACK$.boolean[p__node__$STACK$] = true
					set p__node__$STACK$ = p__node__$STACK$.$STACK$
				endloop
			endmethod
			
			private static method calculateAllocatedMemoryStringLoop__$STACK$__2 takes nothing returns nothing
				set p__length__$STACK$ = p__index__$STACK$ + 500
				
				if (p__length__$STACK$ > 8191) then
					set p__length__$STACK$ = 8191
				endif
				
				loop
					exitwhen p__index__$STACK$ == p__length__$STACK$
					
					set p__index__$STACK$ = p__index__$STACK$ + 1
					
					if (not p__table__$STACK$.boolean.has(p__index__$STACK$)) then
						if (p__string__$STACK$ == null) then
							set p__string__$STACK$ = I2S(p__index__$STACK$)
						else
							set p__string__$STACK$ = p__string__$STACK$ + ", " + I2S(p__index__$STACK$)
						endif
					endif
				endloop
			endmethod
		endif
	//! endtextmacro

	//! textmacro MEMORY_ANALYSIS_STATIC_FIELD_OLD takes STACK, INSTANCE_COUNT
		static if DEBUG_MODE then
			private static integer p__index__$STACK$
			private static integer p__length__$STACK$
			private static string p__string__$STACK$
			private static Table p__table__$STACK$
			private static integer p__node__$STACK$
			private static integer p__instanceCount__$STACK$
			
			private static method calculateFreeMemory__$STACK$ takes nothing returns integer
				call calculateFreeMemoryLoop__$STACK$__main()
				
				return 8191 + p__length__$STACK$ - $INSTANCE_COUNT$
			endmethod
			
			private static method calculateAllocatedMemory__$STACK$ takes nothing returns integer
				call calculateFreeMemoryLoop__$STACK$__main()
				
				return $INSTANCE_COUNT$ - p__length__$STACK$
			endmethod
			
			private static method calculateFreeMemoryLoop__$STACK$__main takes nothing returns nothing
				set p__length__$STACK$ = 0
				set p__node__$STACK$ = $STACK$[0]
				
				loop
					exitwhen p__node__$STACK$ == 0
					call calculateFreeMemoryLoop__$STACK$()
				endloop
			endmethod
			
			private static method calculateFreeMemoryLoop__$STACK$ takes nothing returns nothing
				set p__index__$STACK$ = 500
				
				loop
					exitwhen p__index__$STACK$ == 0 or p__node__$STACK$ == 0
					
					set p__length__$STACK$ = p__length__$STACK$ + 1
					set p__index__$STACK$ = p__index__$STACK$ - 1
					set p__node__$STACK$ = $STACK$[p__node__$STACK$]
				endloop
			endmethod
			
			private static method allocatedMemoryString__$STACK$ takes nothing returns string
				call calculateAllocatedMemoryStringLoop__$STACK$__main()
				
				return p__string__$STACK$
			endmethod
			
			private static method calculateAllocatedMemoryStringLoop__$STACK$__main takes nothing returns nothing
				set p__table__$STACK$ = Table.create()
				set p__instanceCount__$STACK$ = $INSTANCE_COUNT$
				
				set p__string__$STACK$ = null
				
				set p__node__$STACK$ = $STACK$[0]
				
				loop
					exitwhen p__node__$STACK$ == 0
					call calculateAllocatedMemoryStringLoop__$STACK$()
				endloop
				
				set p__length__$STACK$ = 0
				set p__index__$STACK$ = 0
				loop
					exitwhen p__length__$STACK$ == p__instanceCount__$STACK$
					call calculateAllocatedMemoryStringLoop__$STACK$__2()
				endloop
				
				call p__table__$STACK$.destroy()
			endmethod
			
			private static method calculateAllocatedMemoryStringLoop__$STACK$ takes nothing returns nothing
				set p__index__$STACK$ = 500
				
				loop
					exitwhen p__index__$STACK$ == 0 or p__node__$STACK$ == 0
					
					set p__index__$STACK$ = p__index__$STACK$ - 1
					set p__table__$STACK$.boolean[p__node__$STACK$] = true
					set p__node__$STACK$ = $STACK$[p__node__$STACK$]
				endloop
			endmethod
			
			private static method calculateAllocatedMemoryStringLoop__$STACK$__2 takes nothing returns nothing
				set p__length__$STACK$ = p__index__$STACK$ + 500
				
				if (p__length__$STACK$ > p__instanceCount__$STACK$) then
					set p__length__$STACK$ = $INSTANCE_COUNT$
				endif
				
				loop
					exitwhen p__index__$STACK$ == p__length__$STACK$
					
					set p__index__$STACK$ = p__index__$STACK$ + 1
					
					if (not p__table__$STACK$.boolean.has(p__index__$STACK$)) then
						if (p__string__$STACK$ == null) then
							set p__string__$STACK$ = I2S(p__index__$STACK$)
						else
							set p__string__$STACK$ = p__string__$STACK$ + ", " + I2S(p__index__$STACK$)
						endif
					endif
				endloop
			endmethod
		endif
	//! endtextmacro

	//! textmacro MEMORY_ANALYSIS_STATIC_FIELD_NEW takes STACK
		static if DEBUG_MODE then
			private static integer p__index__$STACK$
			private static integer p__length__$STACK$
			private static string p__string__$STACK$
			private static Table p__table__$STACK$
			private static integer p__node__$STACK$
			private static integer p__instanceCount__$STACK$
			
			private static method calculateFreeMemory__$STACK$ takes nothing returns integer
				call calculateFreeMemoryLoop__$STACK$__main()
				
				return 8191 + p__length__$STACK$ - p__instanceCount__$STACK$
			endmethod
			
			private static method calculateAllocatedMemory__$STACK$ takes nothing returns integer
				call calculateFreeMemoryLoop__$STACK$__main()
				
				return p__instanceCount__$STACK$ - p__length__$STACK$
			endmethod
			
			private static method calculateFreeMemoryLoop__$STACK$__main takes nothing returns nothing
				set p__length__$STACK$ = 0
				set p__node__$STACK$ = $STACK$[0]
				
				loop
					exitwhen p__node__$STACK$ == 0
					call calculateFreeMemoryLoop__$STACK$()
				endloop
			endmethod
			
			private static method calculateFreeMemoryLoop__$STACK$ takes nothing returns nothing
				set p__index__$STACK$ = 500
				
				loop
					exitwhen p__index__$STACK$ == 0 or p__node__$STACK$ == 0
					
					set p__length__$STACK$ = p__length__$STACK$ + 1
					set p__index__$STACK$ = p__index__$STACK$ - 1
					set p__instanceCount__$STACK$ = p__node__$STACK$
					set p__node__$STACK$ = $STACK$[p__node__$STACK$]
				endloop
			endmethod
			
			private static method allocatedMemoryString__$STACK$ takes nothing returns string
				call calculateAllocatedMemoryStringLoop__$STACK$__main()
				
				return p__string__$STACK$
			endmethod
			
			private static method calculateAllocatedMemoryStringLoop__$STACK$__main takes nothing returns nothing
				set p__table__$STACK$ = Table.create()
				
				set p__string__$STACK$ = null
				
				set p__node__$STACK$ = $STACK$[0]
				
				loop
					exitwhen p__node__$STACK$ == 0
					call calculateAllocatedMemoryStringLoop__$STACK$()
				endloop
				
				call p__table__$STACK$.boolean.remove(p__instanceCount__$STACK$)
				set p__instanceCount__$STACK$ = p__instanceCount__$STACK$ - 1
				
				set p__length__$STACK$ = 0
				set p__index__$STACK$ = 0
				loop
					exitwhen p__length__$STACK$ == p__instanceCount__$STACK$
					call calculateAllocatedMemoryStringLoop__$STACK$__2()
				endloop
				
				call p__table__$STACK$.destroy()
			endmethod
			
			private static method calculateAllocatedMemoryStringLoop__$STACK$ takes nothing returns nothing
				set p__index__$STACK$ = 500
				
				loop
					exitwhen p__index__$STACK$ == 0 or p__node__$STACK$ == 0
					
					set p__index__$STACK$ = p__index__$STACK$ - 1
					set p__table__$STACK$.boolean[p__node__$STACK$] = true
					set p__instanceCount__$STACK$ = p__node__$STACK$
					set p__node__$STACK$ = $STACK$[p__node__$STACK$]
				endloop
			endmethod
			
			private static method calculateAllocatedMemoryStringLoop__$STACK$__2 takes nothing returns nothing
				set p__length__$STACK$ = p__index__$STACK$ + 500
				
				if (p__length__$STACK$ > p__instanceCount__$STACK$) then
					set p__length__$STACK$ = p__instanceCount__$STACK$
				endif
				
				loop
					exitwhen p__index__$STACK$ == p__length__$STACK$
					
					set p__index__$STACK$ = p__index__$STACK$ + 1
					
					if (not p__table__$STACK$.boolean.has(p__index__$STACK$)) then
						if (p__string__$STACK$ == null) then
							set p__string__$STACK$ = I2S(p__index__$STACK$)
						else
							set p__string__$STACK$ = p__string__$STACK$ + ", " + I2S(p__index__$STACK$)
						endif
					endif
				endloop
			endmethod
		endif
	//! endtextmacro

	//! textmacro MEMORY_ANALYSIS_STATIC_FIELD_FAST takes STACK
		static if DEBUG_MODE then
			private static integer p__index__$STACK$
			private static integer p__length__$STACK$
			private static string p__string__$STACK$
			private static Table p__table__$STACK$
			private static integer p__node__$STACK$
			
			private static method calculateFreeMemory__$STACK$ takes nothing returns integer
				call calculateFreeMemoryLoop__$STACK$__main()
				
				return p__length__$STACK$
			endmethod
			
			private static method calculateAllocatedMemory__$STACK$ takes nothing returns integer
				call calculateFreeMemoryLoop__$STACK$__main()
				
				return 8191 - p__length__$STACK$
			endmethod
			
			private static method calculateFreeMemoryLoop__$STACK$__main takes nothing returns nothing
				set p__length__$STACK$ = 0
				set p__node__$STACK$ = $STACK$[0]
				
				loop
					exitwhen p__node__$STACK$ == 0
					call calculateFreeMemoryLoop__$STACK$()
				endloop
			endmethod
			
			private static method calculateFreeMemoryLoop__$STACK$ takes nothing returns nothing
				set p__index__$STACK$ = 500
				
				loop
					exitwhen p__index__$STACK$ == 0 or p__node__$STACK$ == 0
					
					set p__length__$STACK$ = p__length__$STACK$ + 1
					set p__index__$STACK$ = p__index__$STACK$ - 1
					set p__node__$STACK$ = $STACK$[p__node__$STACK$]
				endloop
			endmethod
			
			private static method allocatedMemoryString__$STACK$ takes nothing returns string
				call calculateAllocatedMemoryStringLoop__$STACK$__main()
				
				return p__string__$STACK$
			endmethod
			
			private static method calculateAllocatedMemoryStringLoop__$STACK$__main takes nothing returns nothing
				set p__table__$STACK$ = Table.create()
				
				set p__string__$STACK$ = null
				
				set p__node__$STACK$ = $STACK$[0]
				
				loop
					exitwhen p__node__$STACK$ == 0
					call calculateAllocatedMemoryStringLoop__$STACK$()
				endloop
				
				set p__length__$STACK$ = 0
				set p__index__$STACK$ = 0
				loop
					exitwhen p__length__$STACK$ == 8191
					call calculateAllocatedMemoryStringLoop__$STACK$__2()
				endloop
				
				call p__table__$STACK$.destroy()
			endmethod
			
			private static method calculateAllocatedMemoryStringLoop__$STACK$ takes nothing returns nothing
				set p__index__$STACK$ = 500
				
				loop
					exitwhen p__index__$STACK$ == 0 or p__node__$STACK$ == 0
					
					set p__index__$STACK$ = p__index__$STACK$ - 1
					set p__table__$STACK$.boolean[p__node__$STACK$] = true
					set p__node__$STACK$ = $STACK$[p__node__$STACK$]
				endloop
			endmethod
			
			private static method calculateAllocatedMemoryStringLoop__$STACK$__2 takes nothing returns nothing
				set p__length__$STACK$ = p__index__$STACK$ + 500
				
				if (p__length__$STACK$ > 8191) then
					set p__length__$STACK$ = 8191
				endif
				
				loop
					exitwhen p__index__$STACK$ == p__length__$STACK$
					
					set p__index__$STACK$ = p__index__$STACK$ + 1
					
					if (not p__table__$STACK$.boolean.has(p__index__$STACK$)) then
						if (p__string__$STACK$ == null) then
							set p__string__$STACK$ = I2S(p__index__$STACK$)
						else
							set p__string__$STACK$ = p__string__$STACK$ + ", " + I2S(p__index__$STACK$)
						endif
					endif
				endloop
			endmethod
		endif
	//! endtextmacro
	
	//! textmacro MEMORY_ANALYSIS_STATIC_FIELD_STACK_ARRAY takes STACK, INSTANCE_COUNT, RECYCLE_COUNT
		static if DEBUG_MODE then
			private static integer p__index__$STACK$
			private static string p__string__$STACK$
			private static Table p__table__$STACK$
			
			private static method calculateFreeMemory__$STACK$ takes nothing returns integer
				return $RECYCLE_COUNT$
			endmethod
			
			private static method calculateAllocatedMemory__$STACK$ takes nothing returns integer
				return $INSTANCE_COUNT$ - $RECYCLE_COUNT$
			endmethod
			
			private static method allocatedMemoryString__$STACK$ takes nothing returns string
				call calculateAllocatedMemoryStringLoop__$STACK$__main()
				
				return p__string__$STACK$
			endmethod
			
			private static method calculateAllocatedMemoryStringLoop__$STACK$__main takes nothing returns nothing
				set p__table__$STACK$ = Table.create()
				set p__string__$STACK$ = null
				set p__index__$STACK$ = 0
				
				loop
					exitwhen p__index__$STACK$ == $RECYCLE_COUNT$
					call calculateAllocatedMemoryStringLoop__$STACK$()
				endloop
				
				set p__index__$STACK$ = 0
				loop
					exitwhen p__index__$STACK$ == $INSTANCE_COUNT$
					call calculateAllocatedMemoryStringLoop__$STACK$__2()
				endloop
				
				call p__table__$STACK$.destroy()
			endmethod
			
			private static method calculateAllocatedMemoryStringLoop__$STACK$ takes nothing returns nothing
				local integer index = p__index__$STACK$
				set p__index__$STACK$ = index + 500
				
				if (p__index__$STACK$ > $RECYCLE_COUNT$) then
					set p__index__$STACK$ = $RECYCLE_COUNT$
				endif
				
				loop
					exitwhen index == p__index__$STACK$
					
					set p__table__$STACK$.boolean[$STACK$[index]] = true
					
					set index = index + 1
				endloop
			endmethod
			
			private static method calculateAllocatedMemoryStringLoop__$STACK$__2 takes nothing returns nothing
				local integer index = p__index__$STACK$
				set p__index__$STACK$ = index + 500
				
				if (p__index__$STACK$ > $INSTANCE_COUNT$) then
					set p__index__$STACK$ = $INSTANCE_COUNT$
				endif
				
				loop
					exitwhen index == p__index__$STACK$
					
					set index = index + 1
					
					if (not p__table__$STACK$.boolean.has(index)) then
						if (p__string__$STACK$ == null) then
							set p__string__$STACK$ = I2S(index)
						else
							set p__string__$STACK$ = p__string__$STACK$ + ", " + I2S(index)
						endif
					endif
				endloop
			endmethod
		endif
	//! endtextmacro
	
	//! textmacro MEMORY_ANALYSIS_VARIABLE_OLD takes STACK, INSTANCE_COUNT
		globals
			private integer p__index__$STACK$
			private integer p__length__$STACK$
			private string p__string__$STACK$
			private Table p__table__$STACK$
			private integer p__node__$STACK$
			private integer p__instanceCount__$STACK$
		endglobals
		
		private keyword calculateFreeMemoryLoop__$STACK$__main
		private keyword calculateFreeMemoryLoop__$STACK$
		private keyword calculateAllocatedMemoryStringLoop__$STACK$__main
		private keyword calculateAllocatedMemoryStringLoop__$STACK$
		private keyword calculateAllocatedMemoryStringLoop__$STACK$__2
		
		static if DEBUG_MODE then
			private function calculateFreeMemory__$STACK$ takes nothing returns integer
				call calculateFreeMemoryLoop__$STACK$__main.evaluate()
				
				return 8191 + p__length__$STACK$ - $INSTANCE_COUNT$
			endfunction
			
			private function calculateAllocatedMemory__$STACK$ takes nothing returns integer
				call calculateFreeMemoryLoop__$STACK$__main.evaluate()
				
				return $INSTANCE_COUNT$ - p__length__$STACK$
			endfunction
			
			private function calculateFreeMemoryLoop__$STACK$__main takes nothing returns nothing
				set p__length__$STACK$ = 0
				set p__node__$STACK$ = $STACK$[0]
				
				loop
					exitwhen p__node__$STACK$ == 0
					call calculateFreeMemoryLoop__$STACK$.evaluate()
				endloop
			endfunction
			
			private function calculateFreeMemoryLoop__$STACK$ takes nothing returns nothing
				set p__index__$STACK$ = 500
				
				loop
					exitwhen p__index__$STACK$ == 0 or p__node__$STACK$ == 0
					
					set p__length__$STACK$ = p__length__$STACK$ + 1
					set p__index__$STACK$ = p__index__$STACK$ - 1
					set p__node__$STACK$ = $STACK$[p__node__$STACK$]
				endloop
			endfunction
			
			private function allocatedMemoryString__$STACK$ takes nothing returns string
				call calculateAllocatedMemoryStringLoop__$STACK$__main.evaluate()
				
				return p__string__$STACK$
			endfunction
			
			private function calculateAllocatedMemoryStringLoop__$STACK$__main takes nothing returns nothing
				set p__table__$STACK$ = Table.create()
				set p__instanceCount__$STACK$ = $INSTANCE_COUNT$
				
				set p__string__$STACK$ = null
				
				set p__node__$STACK$ = $STACK$[0]
				
				loop
					exitwhen p__node__$STACK$ == 0
					call calculateAllocatedMemoryStringLoop__$STACK$.evaluate()
				endloop
				
				set p__length__$STACK$ = 0
				set p__index__$STACK$ = 0
				loop
					exitwhen p__length__$STACK$ == p__instanceCount__$STACK$
					call calculateAllocatedMemoryStringLoop__$STACK$__2.evaluate()
				endloop
				
				call p__table__$STACK$.destroy()
			endfunction
			
			private function calculateAllocatedMemoryStringLoop__$STACK$ takes nothing returns nothing
				set p__index__$STACK$ = 500
				
				loop
					exitwhen p__index__$STACK$ == 0 or p__node__$STACK$ == 0
					
					set p__index__$STACK$ = p__index__$STACK$ - 1
					set p__table__$STACK$.boolean[p__node__$STACK$] = true
					set p__node__$STACK$ = $STACK$[p__node__$STACK$]
				endloop
			endfunction
			
			private function calculateAllocatedMemoryStringLoop__$STACK$__2 takes nothing returns nothing
				set p__length__$STACK$ = p__index__$STACK$ + 500
				
				if (p__length__$STACK$ > p__instanceCount__$STACK$) then
					set p__length__$STACK$ = $INSTANCE_COUNT$
				endif
				
				loop
					exitwhen p__index__$STACK$ == p__length__$STACK$
					
					set p__index__$STACK$ = p__index__$STACK$ + 1
					
					if (not p__table__$STACK$.boolean.has(p__index__$STACK$)) then
						if (p__string__$STACK$ == null) then
							set p__string__$STACK$ = I2S(p__index__$STACK$)
						else
							set p__string__$STACK$ = p__string__$STACK$ + ", " + I2S(p__index__$STACK$)
						endif
					endif
				endloop
			endfunction
		endif
	//! endtextmacro

	//! textmacro MEMORY_ANALYSIS_VARIABLE_NEW takes STACK
		globals
			private integer p__index__$STACK$
			private integer p__length__$STACK$
			private string p__string__$STACK$
			private Table p__table__$STACK$
			private integer p__node__$STACK$
			private integer p__instanceCount__$STACK$
		endglobals
		
		private keyword calculateFreeMemoryLoop__$STACK$__main
		private keyword calculateFreeMemoryLoop__$STACK$
		private keyword calculateAllocatedMemoryStringLoop__$STACK$__main
		private keyword calculateAllocatedMemoryStringLoop__$STACK$
		private keyword calculateAllocatedMemoryStringLoop__$STACK$__2
		
		static if DEBUG_MODE then
			private function calculateFreeMemory__$STACK$ takes nothing returns integer
				call calculateFreeMemoryLoop__$STACK$__main.evaluate()
				
				return 8191 + p__length__$STACK$ - p__instanceCount__$STACK$
			endfunction
			
			private function calculateAllocatedMemory__$STACK$ takes nothing returns integer
				call calculateFreeMemoryLoop__$STACK$__main.evaluate()
				
				return p__instanceCount__$STACK$ - p__length__$STACK$
			endfunction
			
			private function calculateFreeMemoryLoop__$STACK$__main takes nothing returns nothing
				set p__length__$STACK$ = 0
				set p__node__$STACK$ = $STACK$[0]
				
				loop
					exitwhen p__node__$STACK$ == 0
					call calculateFreeMemoryLoop__$STACK$.evaluate()
				endloop
			endfunction
			
			private function calculateFreeMemoryLoop__$STACK$ takes nothing returns nothing
				set p__index__$STACK$ = 500
				
				loop
					exitwhen p__index__$STACK$ == 0 or p__node__$STACK$ == 0
					
					set p__length__$STACK$ = p__length__$STACK$ + 1
					set p__index__$STACK$ = p__index__$STACK$ - 1
					set p__instanceCount__$STACK$ = p__node__$STACK$
					set p__node__$STACK$ = $STACK$[p__node__$STACK$]
				endloop
			endfunction
			
			private function allocatedMemoryString__$STACK$ takes nothing returns string
				call calculateAllocatedMemoryStringLoop__$STACK$__main.evaluate()
				
				return p__string__$STACK$
			endfunction
			
			private function calculateAllocatedMemoryStringLoop__$STACK$__main takes nothing returns nothing
				set p__table__$STACK$ = Table.create()
				
				set p__string__$STACK$ = null
				
				set p__node__$STACK$ = $STACK$[0]
				
				loop
					exitwhen p__node__$STACK$ == 0
					call calculateAllocatedMemoryStringLoop__$STACK$.evaluate()
				endloop
				
				call p__table__$STACK$.boolean.remove(p__instanceCount__$STACK$)
				set p__instanceCount__$STACK$ = p__instanceCount__$STACK$ - 1
				
				set p__length__$STACK$ = 0
				set p__index__$STACK$ = 0
				loop
					exitwhen p__length__$STACK$ == p__instanceCount__$STACK$
					call calculateAllocatedMemoryStringLoop__$STACK$__2.evaluate()
				endloop
				
				call p__table__$STACK$.destroy()
			endfunction
			
			private function calculateAllocatedMemoryStringLoop__$STACK$ takes nothing returns nothing
				set p__index__$STACK$ = 500
				
				loop
					exitwhen p__index__$STACK$ == 0 or p__node__$STACK$ == 0
					
					set p__index__$STACK$ = p__index__$STACK$ - 1
					set p__table__$STACK$.boolean[p__node__$STACK$] = true
					set p__instanceCount__$STACK$ = p__node__$STACK$
					set p__node__$STACK$ = $STACK$[p__node__$STACK$]
				endloop
			endfunction
			
			private function calculateAllocatedMemoryStringLoop__$STACK$__2 takes nothing returns nothing
				set p__length__$STACK$ = p__index__$STACK$ + 500
				
				if (p__length__$STACK$ > p__instanceCount__$STACK$) then
					set p__length__$STACK$ = p__instanceCount__$STACK$
				endif
				
				loop
					exitwhen p__index__$STACK$ == p__length__$STACK$
					
					set p__index__$STACK$ = p__index__$STACK$ + 1
					
					if (not p__table__$STACK$.boolean.has(p__index__$STACK$)) then
						if (p__string__$STACK$ == null) then
							set p__string__$STACK$ = I2S(p__index__$STACK$)
						else
							set p__string__$STACK$ = p__string__$STACK$ + ", " + I2S(p__index__$STACK$)
						endif
					endif
				endloop
			endfunction
		endif
	//! endtextmacro

	//! textmacro MEMORY_ANALYSIS_VARIABLE_FAST takes STACK
		globals
			private integer p__index__$STACK$
			private integer p__length__$STACK$
			private string p__string__$STACK$
			private Table p__table__$STACK$
			private integer p__node__$STACK$
		endglobals
		
		private keyword calculateFreeMemoryLoop__$STACK$__main
		private keyword calculateFreeMemoryLoop__$STACK$
		private keyword calculateAllocatedMemoryStringLoop__$STACK$__main
		private keyword calculateAllocatedMemoryStringLoop__$STACK$
		private keyword calculateAllocatedMemoryStringLoop__$STACK$__2
		
		static if DEBUG_MODE then
			private function calculateFreeMemory__$STACK$ takes nothing returns integer
				call calculateFreeMemoryLoop__$STACK$__main.evaluate()
				
				return p__length__$STACK$
			endfunction
			
			private function calculateAllocatedMemory__$STACK$ takes nothing returns integer
				call calculateFreeMemoryLoop__$STACK$__main.evaluate()
				
				return 8191 - p__length__$STACK$
			endfunction
			
			private function calculateFreeMemoryLoop__$STACK$__main takes nothing returns nothing
				set p__length__$STACK$ = 0
				set p__node__$STACK$ = $STACK$[0]
				
				loop
					exitwhen p__node__$STACK$ == 0
					call calculateFreeMemoryLoop__$STACK$.evaluate()
				endloop
			endfunction
			
			private function calculateFreeMemoryLoop__$STACK$ takes nothing returns nothing
				set p__index__$STACK$ = 500
				
				loop
					exitwhen p__index__$STACK$ == 0 or p__node__$STACK$ == 0
					
					set p__length__$STACK$ = p__length__$STACK$ + 1
					set p__index__$STACK$ = p__index__$STACK$ - 1
					set p__node__$STACK$ = $STACK$[p__node__$STACK$]
				endloop
			endfunction
			
			private function allocatedMemoryString__$STACK$ takes nothing returns string
				call calculateAllocatedMemoryStringLoop__$STACK$__main.evaluate()
				
				return p__string__$STACK$
			endfunction
			
			private function calculateAllocatedMemoryStringLoop__$STACK$__main takes nothing returns nothing
				set p__table__$STACK$ = Table.create()
				
				set p__string__$STACK$ = null
				
				set p__node__$STACK$ = $STACK$[0]
				
				loop
					exitwhen p__node__$STACK$ == 0
					call calculateAllocatedMemoryStringLoop__$STACK$.evaluate()
				endloop
				
				set p__length__$STACK$ = 0
				set p__index__$STACK$ = 0
				loop
					exitwhen p__length__$STACK$ == 8191
					call calculateAllocatedMemoryStringLoop__$STACK$__2.evaluate()
				endloop
				
				call p__table__$STACK$.destroy()
			endfunction
			
			private function calculateAllocatedMemoryStringLoop__$STACK$ takes nothing returns nothing
				set p__index__$STACK$ = 500
				
				loop
					exitwhen p__index__$STACK$ == 0 or p__node__$STACK$ == 0
					
					set p__index__$STACK$ = p__index__$STACK$ - 1
					set p__table__$STACK$.boolean[p__node__$STACK$] = true
					set p__node__$STACK$ = $STACK$[p__node__$STACK$]
				endloop
			endfunction
			
			private function calculateAllocatedMemoryStringLoop__$STACK$__2 takes nothing returns nothing
				set p__length__$STACK$ = p__index__$STACK$ + 500
				
				if (p__length__$STACK$ > 8191) then
					set p__length__$STACK$ = 8191
				endif
				
				loop
					exitwhen p__index__$STACK$ == p__length__$STACK$
					
					set p__index__$STACK$ = p__index__$STACK$ + 1
					
					if (not p__table__$STACK$.boolean.has(p__index__$STACK$)) then
						if (p__string__$STACK$ == null) then
							set p__string__$STACK$ = I2S(p__index__$STACK$)
						else
							set p__string__$STACK$ = p__string__$STACK$ + ", " + I2S(p__index__$STACK$)
						endif
					endif
				endloop
			endfunction
		endif
	//! endtextmacro
	
	//! textmacro MEMORY_ANALYSIS_VARIABLE_STACK_ARRAY takes STACK, INSTANCE_COUNT, RECYCLE_COUNT
		globals
			private integer p__index__$STACK$
			private string p__string__$STACK$
			private Table p__table__$STACK$
		endglobals
		
		private keyword calculateAllocatedMemoryStringLoop__$STACK$__main
		private keyword calculateAllocatedMemoryStringLoop__$STACK$
		private keyword calculateAllocatedMemoryStringLoop__$STACK$__2
		
		static if DEBUG_MODE then
			private function calculateFreeMemory__$STACK$ takes nothing returns integer
				return $RECYCLE_COUNT$
			endfunction
			
			private function calculateAllocatedMemory__$STACK$ takes nothing returns integer
				return $INSTANCE_COUNT$ - $RECYCLE_COUNT$
			endfunction
			
			private function allocatedMemoryString__$STACK$ takes nothing returns string
				call calculateAllocatedMemoryStringLoop__$STACK$__main.evaluate()
				
				return p__string__$STACK$
			endfunction
			
			private function calculateAllocatedMemoryStringLoop__$STACK$__main takes nothing returns nothing
				set p__table__$STACK$ = Table.create()
				set p__string__$STACK$ = null
				set p__index__$STACK$ = 0
				
				loop
					exitwhen p__index__$STACK$ == $RECYCLE_COUNT$
					call calculateAllocatedMemoryStringLoop__$STACK$.evaluate()
				endloop
				
				set p__index__$STACK$ = 0
				loop
					exitwhen p__index__$STACK$ == $INSTANCE_COUNT$
					call calculateAllocatedMemoryStringLoop__$STACK$__2.evaluate()
				endloop
				
				call p__table__$STACK$.destroy()
			endfunction
			
			private function calculateAllocatedMemoryStringLoop__$STACK$ takes nothing returns nothing
				local integer index = p__index__$STACK$
				set p__index__$STACK$ = index + 500
				
				if (p__index__$STACK$ > $RECYCLE_COUNT$) then
					set p__index__$STACK$ = $RECYCLE_COUNT$
				endif
				
				loop
					exitwhen index == p__index__$STACK$
					
					set p__table__$STACK$.boolean[$STACK$[index]] = true
					
					set index = index + 1
				endloop
			endfunction
			
			private function calculateAllocatedMemoryStringLoop__$STACK$__2 takes nothing returns nothing
				local integer index = p__index__$STACK$
				set p__index__$STACK$ = index + 500
				
				if (p__index__$STACK$ > $INSTANCE_COUNT$) then
					set p__index__$STACK$ = $INSTANCE_COUNT$
				endif
				
				loop
					exitwhen index == p__index__$STACK$
					
					set index = index + 1
					
					if (not p__table__$STACK$.boolean.has(index)) then
						if (p__string__$STACK$ == null) then
							set p__string__$STACK$ = I2S(index)
						else
							set p__string__$STACK$ = p__string__$STACK$ + ", " + I2S(index)
						endif
					endif
				endloop
			endfunction
		endif
	//! endtextmacro
endlibrary