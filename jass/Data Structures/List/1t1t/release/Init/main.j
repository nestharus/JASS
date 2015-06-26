library Init /* v1.0.0.0
************************************************************************************
*
*	module Init
*
*		interface private static method init takes nothing returns nothing
*			-	Runs at map init
*
*************************************************************************************
*
*	module InitTimer
*
*		interface private static method init takes nothing returns nothing
*			-	Runs after a one-shot timer with a period of 0
*
************************************************************************************/
	module Init
		static if thistype.init.exists then
			private static method onInit takes nothing returns nothing
				call init()
			endmethod
		endif
	endmodule
	
	module InitTimer
		static if thistype.init.exists then
			private static method initex takes nothing returns nothing
				call DestroyTimer(GetExpiredTimer())
				call init()
			endmethod
			private static method onInit takes nothing returns nothing
				call TimerStart(CreateTimer(), 0, false, function thistype.initex)
			endmethod
		endif
	endmodule
endlibrary