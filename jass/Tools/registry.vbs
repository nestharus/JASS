function ReadReg(path)
	Dim WSHShell, value

	On Error Resume Next
	Set WSHShell = CreateObject("WScript.Shell")
	value = WSHShell.RegRead(path)

	if err.number <> 0 then
		value=Null
	end if

	set WSHShell = Nothing
	
	ReadReg = value
end function

'Regtype should be “REG_SZ” for string, "REG_DWORD" for a integer,…
'”REG_BINARY” for a binary or boolean, and “REG_EXPAND_SZ” for an expandable string
Function WriteReg(path, value, valueType)
	Dim WSHShell, Key
	
	On Error Resume Next
	Set WSHShell = CreateObject("Wscript.shell")
	Key = WSHShell.RegWrite(path, value, valueType)
	
	set WSHShell = Nothing
	
	WriteReg = Key
End Function

Function DeleteReg(path)
	Dim WSHShell, Key
	
	On Error Resume Next
	Set WSHShell = CreateObject("Wscript.shell")
	Key = WSHShell.RegDelete(path)
	
	set WSHShell = Nothing
	
	DeleteReg = Key
End Function

if (WScript.Arguments(0) = "read") then
	Wscript.Echo ReadReg(WScript.Arguments(1))
elseif (WScript.Arguments(0) = "write") then
	Wscript.Echo WriteReg(WScript.Arguments(1), WScript.Arguments(2), WScript.Arguments(3))
elseif (WScript.Arguments(0) = "delete") then
	Wscript.Echo DeleteReg(WScript.Arguments(1))
end if