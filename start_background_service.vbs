Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
WshShell.CurrentDirectory = scriptDir

' Launch dashboard server completely hidden in background (0 = hide window)
WshShell.Run "python dashboard_server.py 8088", 0, False

' Wait 1 second then open dashboard in default browser
WScript.Sleep 1000
WshShell.Run "http://localhost:8088/projects_dashboard.html", 1, False
