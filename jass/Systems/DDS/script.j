library DDS /* v2.0.0.0
*************************************************************************************
*
*	*/	uses	/*
*
*		*/	TriggerRefresh	/*
*		*/	Init			/*
*
************************************************************************************
*
*   SETTINGS
*/
globals
	/*************************************************************************************
	*
	*   How many units can refresh at a given moment (when a trigger is rebuilt).
	*   larger size means less triggers but harder refreshes.
	*
	*************************************************************************************/
	private constant integer TRIGGER_SIZE = 80
endglobals
/*
*************************************************************************************
*
*	struct DDS extends array
*
*	module DDS
*
*		boolean enabled
*			-	enables and disables the system for a given unit
*
*			Examples:	DDS[unit index].enabled = true			
*
*************************************************************************************/
	private keyword RefreshTrigger

	/*
	*	DamageEvent
	*/
	private keyword DAMAGE_EVENT_API	
	private keyword DAMAGE_EVENT_RESPONSE_LOCALS
	private keyword DAMAGE_EVENT_RESPONSE_BEFORE
	private keyword DAMAGE_EVENT_RESPONSE
	private keyword DAMAGE_EVENT_RESPONSE_AFTER
	private keyword DAMAGE_EVENT_RESPONSE_CLEANUP
	private keyword DAMAGE_EVENT_INTERFACE
	private keyword DAMAGE_EVENT_INIT
	
	/*
	*	DamageEventModification
	*/
	private keyword DAMAGE_EVENT_MODIFICATION_API
	private keyword DAMAGE_EVENT_MODIFICATION_RESPONSE_LOCALS
	private keyword DAMAGE_EVENT_MODIFICATION_RESPONSE_BEFORE
	private keyword DAMAGE_EVENT_MODIFICATION_RESPONSE
	private keyword DAMAGE_EVENT_MODIFICATION_RESPONSE_AFTER
	private keyword DAMAGE_EVENT_MODIFICATION_RESPONSE_CLEANUP
	private keyword DAMAGE_EVENT_MODIFICATION_INTERFACE
	private keyword DAMAGE_EVENT_MODIFICATION_INIT
	
	/*
	*	DamageEventArchetype
	*/
	private keyword DAMAGE_EVENT_ARCHETYPE_API
	private keyword DAMAGE_EVENT_ARCHETYPE_RESPONSE_LOCALS
	private keyword DAMAGE_EVENT_ARCHETYPE_RESPONSE_BEFORE
	private keyword DAMAGE_EVENT_ARCHETYPE_RESPONSE
	private keyword DAMAGE_EVENT_ARCHETYPE_RESPONSE_AFTER
	private keyword DAMAGE_EVENT_ARCHETYPE_RESPONSE_CLEANUP
	private keyword DAMAGE_EVENT_ARCHETYPE_INTERFACE
	private keyword DAMAGE_EVENT_ARCHETYPE_INIT

	//! runtextmacro optional DAMAGE_EVENT_CODE()
	//! runtextmacro optional DAMAGE_EVENT_MODIFICATION_CODE()
	//! runtextmacro optional DAMAGE_EVENT_ARCHETYPE_CODE()
	
	private keyword DDS_onDamage
	struct DDS extends array
		method operator enabled takes nothing returns boolean
			return IsTriggerEnabled(RefreshTrigger(this).parent.trigger)
		endmethod
		static if not ENABLED_EXISTS then
			method operator enabled= takes boolean b returns nothing
				if (b) then
					call EnableTrigger(RefreshTrigger(this).parent.trigger)
				else
					call DisableTrigger(RefreshTrigger(this).parent.trigger)
				endif
			endmethod
		else
			implement optional DAMAGE_EVENT_ENABLE
		endif
	
		implement optional DAMAGE_EVENT_API
		implement optional DAMAGE_EVENT_MODIFICATION_API
		implement optional DAMAGE_EVENT_ARCHETYPE_API
	
		static method DDS_onDamage takes nothing returns nothing
			implement optional DAMAGE_EVENT_RESPONSE_LOCALS
			implement optional DAMAGE_EVENT_MODIFICATION_RESPONSE_LOCALS
			implement optional DAMAGE_EVENT_ARCHETYPE_RESPONSE_LOCALS
			
			implement optional DAMAGE_EVENT_RESPONSE_BEFORE
			implement optional DAMAGE_EVENT_MODIFICATION_RESPONSE_BEFORE
			implement optional DAMAGE_EVENT_ARCHETYPE_RESPONSE_BEFORE
			
			implement optional DAMAGE_EVENT_RESPONSE
			implement optional DAMAGE_EVENT_MODIFICATION_RESPONSE
			implement optional DAMAGE_EVENT_ARCHETYPE_RESPONSE
			
			implement optional DAMAGE_EVENT_RESPONSE_AFTER
			implement optional DAMAGE_EVENT_MODIFICATION_RESPONSE_AFTER
			implement optional DAMAGE_EVENT_ARCHETYPE_RESPONSE_AFTER
			
			implement optional DAMAGE_EVENT_RESPONSE_CLEANUP
			implement optional DAMAGE_EVENT_MODIFICATION_RESPONSE_CLEANUP
			implement optional DAMAGE_EVENT_ARCHETYPE_RESPONSE_CLEANUP
		endmethod
	endstruct
	
	module DDS
		private static delegate DDS dds = 0
		
		implement optional DAMAGE_EVENT_INTERFACE
		implement optional DAMAGE_EVENT_MODIFICATION_INTERFACE
		implement optional DAMAGE_EVENT_ARCHETYPE_INTERFACE
	endmodule

	//! runtextmacro TRIGGER_REFRESH("TRIGGER_SIZE", "EVENT_UNIT_DAMAGED", "function DDS.DDS_onDamage")
	
	private struct DDS_Init extends array
		private static method init takes nothing returns nothing
			implement optional DAMAGE_EVENT_INIT
			implement optional DAMAGE_EVENT_MODIFICATION_INIT
			implement optional DAMAGE_EVENT_ARCHETYPE_INIT
		endmethod
	
		implement Init
	endstruct
endlibrary