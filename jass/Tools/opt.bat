@echo OFF

set path=%~1
set pathType=NUL
set pathName=NUL
set pathExt=NUL
set selectedFolder=NUL
set value=NUL

call:getPathType "%path%" pathType
call:getPathName "%path%" pathName
call:getPathExtension "%path%" pathExt

echo path:      %path%
echo type:      %pathType%
echo name:      %pathName%
echo extension: %pathExt%

set concat=%pathName%%pathExt%
echo %concat%

::call:selectFolder selectedFolder
::echo %selectedFolder%

::call:readReg "HKEY_CURRENT_USER\Software\Grimoire\Disable vJass syntax" value
::echo value: %value%

::"REG_SZ" for string
::"REG_DWORD" for integer (32-bit)
::"REG_QWORD" for integer (64-bit)
::"REG_BINARY" for binary or boolean
::"REG_EXPAND_SZ" for expandable string
::call:writeReg "HKEY_CURRENT_USER\Software\Grimoire\Custom" "test" "REG_SZ"

::call:deleteReg "HKEY_CURRENT_USER\Software\Grimoire\Custom"

pause
goto:eof

:: directories in current directory
:: for /D %%s in (%~1\*) do @echo %%~s

:: all files in current directory
:: for %%f in (.\*) do @echo %%~f

:getPathType
::					-- %~1: path
::					-- %~2: return INVALID, FILE, DIRECTORY
SETLOCAL ENABLEEXTENSIONS
set pathType="Invalid"

if not exist "%~1" (
	set pathType=INVALID
) else (
	set attribute=%~a1
	set dirAttribute=%attribute:0,1%
	
	if "%dirAttribute%"=="d" (
		set pathType=DIRECTORY
	) else (
		set pathType=FILE
	)
)

(ENDLOCAL & REM -- RETURN VALUES
	set %~2=%pathType%
)
GOTO:EOF

:getPathName
::					-- %~1: path
::					-- %~2: return name
set %~2=%~n1
GOTO:EOF

:getPathExtension
::					-- %~1: path
::					-- %~2: return extension
set %~2=%~x1
GOTO:EOF

:selectFolder
::					-- %~1: return value
	for /F "Tokens=1 Delims=" %%I in ('C:\windows\system32\cscript.exe //nologo "%cd%\browseFolder.vbs"') do set %~1=%%I
GOTO:EOF

:readReg
::					-- %~1: path
::					-- %~2: return value
	for /F "Tokens=1 Delims=" %%I in ('C:\windows\system32\cscript.exe //nologo "%cd%\registry.vbs" "read" "%~1"') do set %~2=%%I
GOTO:EOF

:writeReg
::					-- %~1: path
::					-- %~2: value
::					-- %~3: valueType
	C:\windows\system32\cscript.exe "//nologo" "%cd%\registry.vbs" "write" "%~1" "%~2" "%~3"
GOTO:EOF

:deleteReg
::					-- %~1: path
	C:\windows\system32\cscript.exe "//nologo" "%cd%\registry.vbs" "delete" "%~1"
GOTO:EOF