dirPath = WScript.Arguments.Unnamed(0)
csvFilename = WScript.Arguments.Unnamed(1)
runid = WScript.Arguments.Unnamed(2)
generateHTMLReport dirPath,csvFilename,runid

sub generateHTMLReport(strDir,filename,runid)
		csvPath=strDir & "\" & Filename
		Set objFSO = CreateObject("Scripting.FileSystemObject")
		Const ForReading = 1
		Dim txtNext,txtHTML
		txtNext=""
		i = 0
		count = 0
		''''''''''''''''''''''''''''''''''''''''''''''Generate HTML content''''''''''''''''''''''''''''''''''''''''''''''''''
		txtHTML = ""
		Set objFile = objFSO.OpenTextFile(csvPath, ForReading)
		
		If (instr(Filename,"CLCF2_DIFF")) Then
			'txtHTML=txtHTML & "<TABLE ><TR><TD><b><center>Following is the Difference Report for " & runid & "CLCF2 and GMS</center></TD></TR><TR><TD>&nbsp;</TD></TR></TABLE>"
			txtHTML=txtHTML & "<TABLE ><TR><TD><b><center>Note: Account = [Firm][Office][AccountCode][Sub-AccountCode]</center></TD></TR><TR><TD>&nbsp;</TD></TR></TABLE>"
		else
			txtHTML=txtHTML & "<TABLE ><TR><TD><b><center>Following is the Difference Report for " & runid & "CLCF1 and GMS</center></TD></TR><TR><TD>&nbsp;</TD></TR></TABLE>"
		end if		
		txtHTML=txtHTML & "<TABLE border=1>"
		Do Until objFile.AtEndOfStream
			txtNext=objFile.ReadLine
			'txtHTML = txtHTML &" " &  txtNext
			fields=split(txtNext,",")
			index=ubound(fields)
			If (instr(txtNext,"Account")) Then
					' Print Header
					txtHTML=txtHTML & "<TR bgcolor='blue'>"
					for i=0 to index
						If (instr(fields(i),"Diff")) Then
							txtHTML=txtHTML & "<TD><font color=red><center><b>" & fields(i) & "</center></font></TD>"
						else
							txtHTML=txtHTML & "<TD><font color=white><center><b>" & fields(i) & "</center></font></TD>"
						end if	
					next		
					txtHTML=txtHTML & "</TR>"
			else	
					txtHTML=txtHTML & "<TR>"
					for i=0 to index
						if (i=index-1) or  (i=index) then
								if (fields(i) > 0)	then
									txtHTML=txtHTML & "<TD><font color=blue><right><p style=padding:0; margin:0;>" & fields(i) & "</p></right></font></TD>"
								else
									txtHTML=txtHTML & "<TD><font color=blue><right><p style=padding:0; margin:0;>" & fields(i) & "</p></right></font></TD>"
								end if	
						else
							txtHTML=txtHTML & "<TD><font color=blue><right><p style=padding:0; margin:0;>" & fields(i) & "</p></right></font></TD>"
						end if	
					next
					txtHTML=txtHTML & "</TR>"
			count = count+1
			end if
		Loop
		txtHTML=txtHTML & "<TABLE ><TR><TD><b>" & count & " Differences found</TD></TR><TR><TD>&nbsp;</TD></TR>"
		txtHTML=txtHTML & "</TR><TR><TD>&nbsp;</TD></TR>"
		objFile.Close
		set objFile = nothing
		If (instr(Filename,"CLCF1_DIFF")) Then
			logPath=strDir & "\CLCF1.log"
		elseif (instr(Filename,"GMS_DIFF")) Then
			logPath=strDir & "\CLCF1.log"
		else	
			logPath=strDir & "\CLCF2.log"
		end if

		Set objFile = objFSO.OpenTextFile(logPath, ForReading)
		Do Until objFile.AtEndOfStream
			txtNext=objFile.ReadLine
			txtHTML=txtHTML & "</TR><TR><TD>" & txtNext & "</TD></TR>"
		Loop
		txtHTML=txtHTML & "</TABLE>"
		objFile.Close
		set objFile = nothing
		outFile=replace(csvPath,"CSV","htm")
		'outFile=strDir & "\MIXCLCF1_DIFF.htm"
		Set objFile = objFSO.CreateTextFile(outFile,True)
		objFile.Write txtHTML
		objFile.Close
		set objFile = nothing
		set objFSO = nothing

		Dim objExplorer
		Set objExplorer = CreateObject("InternetExplorer.Application")
		'Set wshShell = CreateObject("WScript.Shell")
		objExplorer.visible = true
		objExplorer.Navigate outFile
		Set objExplorer = nothing

		'Dim wshShell
		'Set wshShell = CreateObject("WScript.Shell")
		'wshShell.Run outFile
		'Set wshShell = nothing
End sub