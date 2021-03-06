
' VBScript to write FTP file. 
' ---------------------------------------------------------------' 
'Author- Rohit Hardia
'Description - This script generate a ftp script to login to a given box and transfere some data file to local system
'Date Created - 24 May 2016
' ---------------------------------------------------------------' 

'host = "mira"
'uid = "qa_mgr"
'pwd = "gb1dqa_mgr"

host = WScript.Arguments.Unnamed(0)
uid = WScript.Arguments.Unnamed(1)
pwd = WScript.Arguments.Unnamed(2)
wrkdir = WScript.Arguments.Unnamed(3)
ftpPath = WScript.Arguments.Unnamed(4)
ftpPath = replace(ftpPath,"\","/")
run_id = WScript.Arguments.Unnamed(5)


generateFTPScript host,uid,pwd,wrkdir,ftpPath,run_id

sub generateFTPScript(host,uid,pwd,wrkdir,ftpPath,run_id)
		Dim objFSO, objFolder, objShell, objTextFile, objFile
		Dim strDirectory, strFile, strText
    	strDirectory=wrkdir
		strFile = "\ftp.txt"
		' Create the File System Object
		Set objFSO = CreateObject("Scripting.FileSystemObject")
		
		Set objFile = objFSO.CreateTextFile(strDirectory & strFile)
		set objFile = nothing
		set objFolder = nothing
		' OpenTextFile Method needs a Const value
		' ForAppending = 8 ForReading = 1, ForWriting = 2
		Const ForAppending = 8
		
		Set objTextFile = objFSO.OpenTextFile _
		(strDirectory & strFile, ForAppending, True)
		
		objTextFile.WriteLine("open " & host)
		objTextFile.WriteLine(uid)
		objTextFile.WriteLine(pwd)
		objTextFile.WriteLine("cd " & ftpPath)
		objTextFile.WriteLine("ascii")
		objTextFile.WriteLine("get ps_" & run_id & ".gms")
		objTextFile.WriteLine("get mg_" & run_id & ".gms")
		'objTextFile.WriteLine("get mg_" & run_id & ".gms")
		objTextFile.WriteLine("get GMIGMST1.CSV")
		objTextFile.WriteLine("get GMIMPSF2.CSV")
		objTextFile.WriteLine("get " & run_id & "CLCF1.CSV")
		objTextFile.WriteLine("get " & run_id & "CLCF2.CSV")
		objTextFile.WriteLine("quit")
		objTextFile.Close
		
		strFile = "\getReport.bat"
		If objFSO.FileExists(strDirectory & strFile)=false Then
			Set objTextFile = objFSO.OpenTextFile(strDirectory & strFile, ForAppending, True)
			objTextFile.WriteLine("ftp -s:ftp.txt")
			objTextFile.Close
		end if
		'strDir=strPath & "\gms_Driver\" & strUsername
		
		dim shell
		set shell=createobject("wscript.shell")
		shell.run strDirectory & "\getReport.bat"
		set shell=nothing
		
		strFTP = strDirectory & "\getReport.bat"
		SystemUtil.Run strFTP,"",strDirectory,"open"
		
		WScript.Quit
end sub
