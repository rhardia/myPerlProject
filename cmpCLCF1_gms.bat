@ECHO OFF
echo .............................................................
echo THIS IS THE UTILITY TO COMPARE GMICLCF DATABASE FILE RESULTS WITH GMS
echo .............................................................
set /p runid="Enter MARG3AC output Prefix : "
set scriptDir=C:\GMS_GMI
set wrkdir=C:\GMS_GMI\wrkdir
set /p ftpFlag="Would you like to FTP files from iSeries Box(Y/N) : "
if /I %ftpFlag%==N goto :IMC_RUN
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

:IMC_RUN
set /p gmsFlag="Would you like to run standalone GMS(Y/N) : "
if /I %gmsFlag%==N goto :FILE_COMPARE
echo Running GMS over %runid%
set PATH=C:\appsdev\scripts;C:\appsdev\prdadmin\gmsdev\trunk;%PATH%
set cwd=%cd%
call setup_gms.bat GCC
cd C:\appsdev\prdadmin\gmsdev\trunk
call setworkspace_gcc64.bat R v2
call run_prd imc -u%runid% -p%wrkdir% -o%wrkdir% -l%wrkdir% -e%wrkdir% -rE
call run_prd imc -u%runid% -p%wrkdir% -o%wrkdir% -l%wrkdir% -e%wrkdir% -f

:FILE_COMPARE
echo Comparing GMS results with GMICLCF* files
if exist %wrkdir%\TMP*.* del %wrkdir%\TMP*.*
if exist %scriptDir%\%runid%CLCF1_DIFF.CSV del %scriptDir%\%runid%CLCF1_DIFF.CSV
if exist %scriptDir%\%runid%CLCF2_DIFF.CSV del %scriptDir%\%runid%CLCF2_DIFF.CSV
if exist %scriptDir%\%runid%CLCF1_DIFF.htm del %scriptDir%\%runid%CLCF1_DIFF.htm
if exist %scriptDir%\%runid%CLCF2_DIFF.htm del %scriptDir%\%runid%CLCF2_DIFF.htm
if exist %scriptDir%\CLCF*.log del %scriptDir%\CLCF*.log
cd %scriptDir%
perl %scriptDir%\CompareGMS_GMI.pl %runid% > %scriptDir%\CLCF1.log
perl %scriptDir%\CompareGMS_GMI_Detailed.pl %runid% > %scriptDir%\CLCF2.log
echo Generating mismatch report
echo Generating log file
echo .....................
set csvfile=%runid%CLCF1_DIFF.CSV
cscript.exe %scriptDir%\htmlGenerator.vbs %scriptDir% %csvfile% %runid%
set csvfile=%runid%CLCF2_DIFF.CSV
perl %scriptDir%\htmlGenerator.pl %scriptDir% %csvfile% %runid%
cscript.exe %scriptDir%\htmlOpener.vbs %scriptDir% %csvfile%
REM cscript.exe %scriptDir%\htmlGenerator.vbs %scriptDir% %csvfile% %runid%
echo Completed Successfully
goto :END
:END