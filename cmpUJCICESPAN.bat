@ECHO OFF
echo .............................................................
echo THIS IS THE UTILITY TO COMPARE GMICLCF DATABASE FILE RESULTS WITH PC SPAN
echo .............................................................
echo Note all the Exchange data should be copied to C:\GMS_GMI\wrkdir Directory
echo .............................................................
set /p runid="Enter MARG3AC output Prefix : "
set scriptDir=C:\GMS_GMI
set wrkdir=C:\GMS_GMI\wrkdir
set SPANPATH=C:\Span4\Bin
set /p ftpFlag="Would you like to FTP files from iSeries Box(Y/N) : "
if /I %ftpFlag%==N goto :ICE_SPAN
set /p host="Enter iSeries Box Name: "
set /p id="Enter USERID: "
set /P pwd="Password : "
set /P ftppath="iSeries IFS Directory Path : "
set word=\
call set ftppath=%%ftppath:/=%word%%%
echo Downloading files from %host%
call cscript.exe %scriptDir%\generateFTP.vbs %host% %id% %pwd% %wrkdir% %ftppath% %runid%
cd %wrkdir%
call getReport.bat


:ICE_SPAN
set /p spanFlag="Would you like to Generate ICE Span results(Y/N) : "
if /I %spanFlag%==N goto :FILE_COMPARE
set /p exchfile="Enter Exchange Data file to Load : "
echo Loading ICE Span .....
if exist %wrkdir%\%runid%_ICESPAN_LOG.log del %wrkdir%\%runid%_ICESPAN_LOG.log
if exist %wrkdir%\%runid%_results_ICE.csv del %wrkdir%\%runid%_results_ICE.csv
%scriptDir%\marbat -pf %wrkdir%\export_ice_%runid%.csv -rf %wrkdir%\%exchfile% -of %wrkdir%\%runid%_results_ICE -wt 2000000 -wfprcap > %wrkdir%\%runid%_ICESPAN_LOG.log

:FILE_COMPARE
cd %scriptDir%
if exist %wrkdir%\TMP*.* del %wrkdir%\TMP*.*
if exist %wrkdir%\%runid%SPAN_UJC_DIFF.CSV del %wrkdir%\%runid%SPAN_UJC_DIFF.CSV
if exist %wrkdir%\%runid%SPAN_UJC_LOG.log del %wrkdir%\%runid%SPAN_UJC_LOG.log
perl %scriptDir%\CompareICESPAN_UJC_Detailed.pl %runid% > %wrkdir%\%runid%SPAN_UJC_LOG.log
echo Comparing GMI results with Span for ICE Tool.....
echo Generating mismatch report
echo Generating log file
echo .....................
set csvfile=%runid%SPAN_UJC_DIFF.CSV
set csvfileAll=%runid%SPAN_UJC_ALL.CSV
REM cscript.exe %scriptDir%\htmlGenerator.vbs %scriptDir% %csvfile% %runid%
REM set csvfile=%runid%UJC_DIFF.CSV
perl %scriptDir%\htmlGenerator_ICE.pl %wrkdir% %csvfile% %runid%
REM perl %scriptDir%\htmlGenerator.pl %scriptDir% %csvfileAll% %runid%
cscript.exe %scriptDir%\htmlOpener.vbs %wrkdir% %csvfile%
REM cscript.exe %scriptDir%\htmlOpener.vbs %scriptDir% %csvfileAll%
REM cscript.exe %scriptDir%\htmlGenerator.vbs %scriptDir% %csvfile% %runid%
echo Completed Successfully
goto :END
:END