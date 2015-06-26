library ErrorMessage /* v1.0.2.0
*************************************************************************************
*
*	Issue Compliant Error Messages
*
************************************************************************************
*
*	function ThrowError takes boolean expression, string libraryName, string functionName, string objectName, integer objectInstance, string description returns nothing
*		-	In the event of an error the game will be permanently paused
*
*	function ThrowWarning takes boolean expression, string libraryName, string functionName, string objectName, integer objectInstance, string description returns nothing
*
************************************************************************************/
	private struct Fields extends array
		static constant string COLOR_RED = "|cffff0000"
		static constant string COLOR_YELLOW = "|cffffff00"
		static string lastError = null
	endstruct
	
	private function Pause takes nothing returns nothing
		call PauseGame(true)
	endfunction
	
	private function ThrowMessage takes string libraryName, string functionName, string objectName, integer objectInstance, string description, string errorType, string color returns nothing
		local string str
		
		local string color_braces = "|cff66FF99"
		local string orange = "|cffff6600"
		
		set str = "->\n-> " + color_braces + "{|r " + "Library" + color_braces + "(" + orange + libraryName + color_braces + ")"
		if (objectName != null) then
			if (objectInstance != 0) then
				set str = str + "|r.Object" + color_braces + "(" + orange + objectName + color_braces + " (|rinstance = " + orange + I2S(objectInstance) + color_braces + ") )" + "|r." + "Method" + color_braces + "(" + orange + functionName + color_braces + ")"
			else
				set str = str + "|r.Object" + color_braces + "(" + orange + objectName + color_braces + ")|r." + "Method" + color_braces + "(" + orange + functionName + color_braces + ")"
			endif
		else
			set str = str + "|r." + "Function" + color_braces + "(" + orange + functionName + color_braces + ")"
		endif
		
		set str = str + color_braces + " }|r " + "has thrown an exception of type " + color_braces + "(" + color + errorType + color_braces + ")|r."
		
		set Fields.lastError = str + "\n->\n" + "->	" + color + description + "|r\n->"
	endfunction
	
	function ThrowError takes boolean expression, string libraryName, string functionName, string objectName, integer objectInstance, string description returns nothing
		if (Fields.lastError != null) then
			set objectInstance = 1/0
		endif
	
		if (expression) then
			call ThrowMessage(libraryName, functionName, objectName, objectInstance, description, "Error", Fields.COLOR_RED)
			call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,Fields.lastError)
			call TimerStart(CreateTimer(), 0, true, function Pause)
			set objectInstance = 1/0
		endif
	endfunction

	function ThrowWarning takes boolean expression, string libraryName, string functionName, string objectName, integer objectInstance, string description returns nothing
		if (Fields.lastError != null) then
			set objectInstance = 1/0
		endif
	
		if (expression) then
			call ThrowMessage(libraryName, functionName, objectName, objectInstance, description, "Warning", Fields.COLOR_YELLOW)
			call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,Fields.lastError)
			set Fields.lastError = null
		endif
	endfunction
endlibrary