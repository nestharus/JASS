library Print uses Init
	globals
		private string array tabs
	endglobals
	
	function Print takes string msg returns nothing
		call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60000, msg)
	endfunction
	
	function PrintEx takes integer tabCount, string msg returns nothing
		call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60000, tabs[tabCount] + msg)
	endfunction
	
	private struct oo extends array
		private static method init takes nothing returns nothing
			local integer i = 0
			loop
				set i = i + 1
				set tabs[i] = tabs[i - 1] + "    "
				exitwhen i == 20
			endloop
		endmethod
		
		implement Init
	endstruct
endlibrary