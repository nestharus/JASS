Const MY_COMPUTER = &H11&
Const WINDOW_HANDLE = 0
Const OPTIONS = 0

Set objShell = CreateObject("Shell.Application")
Set objFolder = objShell.Namespace(MY_COMPUTER)
Set objFolderItem = objFolder.Self
strPath = objFolderItem.Path

Set objShell = CreateObject("Shell.Application")
Set objFolder = objShell.BrowseForFolder _
    (WINDOW_HANDLE, "Select a folder:", OPTIONS, strPath)
     
If objFolder Is Nothing Then
    Wscript.Quit
End If

Set objFolderItem = objFolder.Self
objPath = objFolderItem.Path

Wscript.Echo objPath