@ECHO OFF
echo .............................................................
echo THIS IS THE UTILITY TO COMPARE GMS RESULTS WITH PC SPAN
echo .............................................................
echo Note all the Exchange data should be copied to C:\GMS_GMI\wrkdir Directory
echo .............................................................
set /p runid="Enter runid : "
set scriptDir=C:\GMS_GMI
set wrkdir=C:\GMS_GMI\wrkdir
set SPANPATH=C:\Span4\Bin
set /p gmsFlag="Would you like to export PC Span format Postion(Y/N) : "
if /I %gmsFlag%==N goto :RUNGMS
echo Exporting File to PCSPAN format using GMS over runid %runid%
set THISPATH=%PATH%
set PATH=C:\appsdev\scripts;C:\appsdev\prdadmin\gmsdev\trunk;C:\glassfish3\jdk\jre\bin\server;%PATH%
set cwd=%cd%
cd C:\appsdev\prdadmin\gmsdev\trunk
call run_rel imc -u%runid% -p%wrkdir% -o%wrkdir% -l%wrkdir% -e%wrkdir% -rE
set PATH=%THISPATH%
cd %wrkdir%

:RUNGMS
set /p gmsFlag="Would you like to run GMS and generate margin reports(Y/N) : "
if /I %gmsFlag%==N goto :PC_SPAN
echo Running GMS over runid %runid%
set THISPATH=%PATH%
set PATH=C:\appsdev\scripts;C:\appsdev\prdadmin\gmsdev\trunk;C:\glassfish3\jdk\jre\bin\server;%PATH%
set cwd=%cd%
cd C:\appsdev\prdadmin\gmsdev\trunk
call run_rel imc -u%runid% -p%wrkdir% -o%wrkdir% -l%wrkdir% -e%wrkdir% -f
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
if exist %wrkdir%\%runid%SPAN_GMS_DIFF.CSV del %wrkdir%\%runid%SPAN_GMS_DIFF.CSV
if exist %wrkdir%\%runid%SPAN_GMS_MATCHED.CSV del %wrkdir%\%runid%SPAN_GMS_MATCHED.CSV
if exist %wrkdir%\GMSDIFF.log del %wrkdir%\GMSDIFF.log
perl %scriptDir%\ComparePCSPAN_GMS_Detailed.pl %runid% > %wrkdir%\GMSDIFF.log
echo Comparing GMI results with PC Span .....
echo Generating mismatch report
echo Generating log file
echo .....................
set csvfile=%runid%SPAN_GMS_DIFF.CSV
set csvfileAll=%runid%SPAN_GMS_MATCHED.CSV
REM cscript.exe %scriptDir%\htmlGenerator.vbs %scriptDir% %csvfile% %runid%
REM set csvfile=%runid%CLCF2_DIFF.CSV
perl %scriptDir%\htmlGeneratorGMS.pl %wrkdir% %csvfile% %runid%
perl %scriptDir%\htmlGeneratorGMS.pl %wrkdir% %csvfileAll% %runid%
cscript.exe %scriptDir%\htmlOpener.vbs %wrkdir% %csvfile%
REM cscript.exe %scriptDir%\htmlOpener.vbs %scriptDir% %csvfileAll%
REM cscript.exe %scriptDir%\htmlGenerator.vbs %scriptDir% %csvfile% %runid%
echo Completed Successfully
goto :END
:END