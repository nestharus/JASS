library Init
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