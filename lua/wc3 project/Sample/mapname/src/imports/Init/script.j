library Init
	module Init
		static if thistype.init.exists then
			private static method onInit takes nothing returns nothing
				call init()
			endmethod
		endif
	endmodule
endlibrary