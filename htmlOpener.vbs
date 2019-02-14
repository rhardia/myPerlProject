Path = WScript.Arguments.Unnamed(0)
csvFile = WScript.Arguments.Unnamed(1)
csvPath = Path & "\" & csvFile
'msgbox csvPath
outFile=replace(csvPath,".CSV",".htm")
'msgbox outFile
outFile= Trim(outFile)
'outFile="C:\GMS_GMI\NOVCLCF2_DIFF.htm"
Dim objExplorer
Set objExplorer = CreateObject("InternetExplorer.Application")
'Set wshShell = CreateObject("WScript.Shell")
objExplorer.visible = true
objExplorer.Navigate outFile
Set objExplorer = nothing