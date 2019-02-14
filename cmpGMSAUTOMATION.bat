@ECHO OFF
echo .............................................................
echo THIS IS THE UTILITY TO COMPARE GMS RESULTS WITH PC SPAN
echo .............................................................
echo Note all the Exchange data should be copied to C:\GMS_GMI\wrkdir Directory
echo .............................................................
set /p runid="Enter Exchange Method Code : "
set scriptDir=C:\GMS_GMI
set $date=%date:~4%
set $date=%$date:/=-%
set wrkdir=C:\GMS_GMI\%runid%_wrkdir_%$date%
if exist %wrkdir% del /q %wrkdir%
mkdir %wrkdir%

set SPANPATH=C:\Span4\Bin
set THISPATH=%PATH%
set PATH=C:\appsdev\scripts;C:\appsdev\prdadmin\gmsdev\trunk;C:\glassfish3\jdk\jre\bin\server;C:\GMS_GMI\7-Zip;%PATH%
set cwd=%cd%
cd %wrkdir%

perl %scriptDir%\ftpGenerator.pl %runid% %scriptDir%

copy C:\GMS_GMI\ftp.txt %wrkdir%
ftp -s:ftp.txt
call 7z e %wrkdir%\*-z -o%wrkdir%
call run_rel gms_create_data -x%runid% -l1000 -r10000
if exist %wrkdir%\ps_%runid%.gms del %wrkdir%\ps_%runid%.gms
perl -i.old -n -e "s/030;\"C\";/030;\"S\";/g; print " %runid%_csv.pos
rename %runid%_csv.pos ps_%runid%.gms
call run_rel imc -u%runid% -p%wrkdir% -o%wrkdir% -l%wrkdir% -e%wrkdir% -rE
call run_rel imc -u%runid% -p%wrkdir% -o%wrkdir% -l%wrkdir% -e%wrkdir% -f
set PATH=%THISPATH%
cd %wrkdir%

set exchfile=%runid%.par
echo Loading PC Span .....
if exist %wrkdir%\SPAN.xml del %wrkdir%\SPAN.xml
if exist %wrkdir%\%runid%PbReq.csv del %wrkdir%\%runid%PbReq.csv
perl %scriptDir%\PCSpanLoadDate.pl %runid% %wrkdir% %exchfile%
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

cd %scriptDir%
if exist %wrkdir%\TMP*.* del %wrkdir%\TMP*.*
if exist %scriptDir%\%runid%SPAN_GMS_DIFF.CSV del %scriptDir%\%runid%SPAN_GMS_DIFF.CSV
if exist %scriptDir%\%runid%SPAN_GMS_MATCHED.CSV del %scriptDir%\%runid%SPAN_GMS_MATCHED.CSV
if exist %scriptDir%\GMSDIFF.log del %scriptDir%\GMSDIFF.log
perl %scriptDir%\ComparePCSPAN_GMS_Detailed.pl %runid% %wrkdir% > %wrkdir%\GMSDIFF.log
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
cd %cwd%
REM cscript.exe %scriptDir%\htmlOpener.vbs %scriptDir% %csvfileAll%
REM cscript.exe %scriptDir%\htmlGenerator.vbs %scriptDir% %csvfile% %runid%
echo Completed Successfully
goto :END
:END