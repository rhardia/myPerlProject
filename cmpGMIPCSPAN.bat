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
if /I %ftpFlag%==N goto :FILE_EXPORT
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


:FILE_EXPORT
set /p gmsFlag="Would you like to Export PC Span position(Y/N) : "
if /I %gmsFlag%==N goto :PC_SPAN
echo Exporting File to PCSPAN format using GMS over runid %runid%
set THISPATH=%PATH%
set PATH=C:\appsdev\scripts;C:\appsdev\prdadmin\gmsdev\trunk;C:\glassfish3\jdk\jre\bin\server;%PATH%
set cwd=%cd%
call setup_gms.bat GCC
cd C:\appsdev\prdadmin\gmsdev\trunk
call setworkspace_gcc64.bat R v2
call run_rel imc -u%runid% -p%wrkdir% -o%wrkdir% -l%wrkdir% -e%wrkdir% -rE
set PATH=%THISPATH%
cd %wrkdir%

:PC_SPAN
set /p spanFlag="Would you like to Generate PC Span results(Y/N) : "
if /I %spanFlag%==N goto :FILE_COMPARE
set /p exchfile="Enter Exchange Data file to Load : "
echo Loading PC Span .....
if exist %wrkdir%\SPAN.xml del %wrkdir%\SPAN.xml
if exist %wrkdir%\%runid%PbReq.csv del %wrkdir%\%runid%PbReq.csv
perl %scriptDir%\PCSpanLoad.pl %runid% %exchfile%
%SPANPATH%\spanit %wrkdir%\spanScript.txt
%SPANPATH%\RiskReporter.exe %wrkdir%\SPAN.xml /PbReq_CSV
cd %wrkdir%
perl -i.old -n -e "s/,SGX,/,SMX,/g; print " PbReq.csv
perl -i.old -n -e "s/,CCE,/,CEE,/g; print " PbReq.csv
perl -i.old -n -e "s/,TIF,/,TFX,/g; print " PbReq.csv
perl -i.old -n -e "s/,CFX,/,CFE,/g; print " PbReq.csv
perl -i.old -n -e "s/,CME,/,CCL,/g; print " PbReq.csv
perl -i.old -n -e "s/,BMDC,/,BMD,/g; print " PbReq.csv
perl -i.old -n -e "s/,JCCH,/,TCE,/g; print " PbReq.csv
perl -i.old -n -e "s/,ASXCLF,/,ASF,/g; print " PbReq.csv
perl -i.old -n -e "s/,CDC,/,CDE,/g; print " PbReq.csv
rename PbReq.csv %runid%PbReq.csv

:FILE_COMPARE
cd %scriptDir%
if exist %wrkdir%\TMP*.* del %wrkdir%\TMP*.*
if exist %scriptDir%\%runid%SPAN_CLCF2_DIFF.CSV del %scriptDir%\%runid%SPAN_CLCF2_DIFF.CSV
if exist %scriptDir%\%runid%SPAN_CLCF2_LOG.log del %scriptDir%\%runid%SPAN_CLCF2_LOG.log
perl %scriptDir%\ComparePCSPAN_GMI_Detailed.pl %runid% > %scriptDir%\%runid%SPAN_CLCF2_LOG.log
echo Comparing GMI results with PC Span .....
echo Generating mismatch report
echo Generating log file
echo .....................
set csvfile=%runid%SPAN_CLCF2_DIFF.CSV
set csvfileAll=%runid%SPAN_CLCF2_ALL.CSV
REM cscript.exe %scriptDir%\htmlGenerator.vbs %scriptDir% %csvfile% %runid%
REM set csvfile=%runid%CLCF2_DIFF.CSV
perl %scriptDir%\htmlGenerator.pl %scriptDir% %csvfile% %runid%
REM perl %scriptDir%\htmlGenerator.pl %scriptDir% %csvfileAll% %runid%
cscript.exe %scriptDir%\htmlOpener.vbs %scriptDir% %csvfile%
REM cscript.exe %scriptDir%\htmlOpener.vbs %scriptDir% %csvfileAll%
REM cscript.exe %scriptDir%\htmlGenerator.vbs %scriptDir% %csvfile% %runid%
echo Completed Successfully
goto :END
:END