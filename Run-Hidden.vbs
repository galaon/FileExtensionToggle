' Run-Hidden.vbs
' Launches ToggleFileExt.ps1 with no visible console window.
' Used as the context-menu command so the toggle happens silently.

Dim fso, shell, scriptDir, ps1, cmd
Set fso   = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
ps1       = fso.BuildPath(scriptDir, "ToggleFileExt.ps1")

If Not fso.FileExists(ps1) Then
    MsgBox "ToggleFileExt.ps1 not found:" & vbCrLf & ps1, 16, "File Extension Toggle"
    WScript.Quit 1
End If

cmd = "powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & ps1 & """"

' 0 = hidden window, False = do not wait
shell.Run cmd, 0, False
