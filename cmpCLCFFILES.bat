@ECHO OFF
echo .............................................................
echo THIS IS THE UTILITY TO COMPARE TWO GMICLCF DATABASE FILE RESULTS
echo .............................................................
set /p runid1="Enter MARG3AC output Prefix for CLCF file 1 : "
set /p runid2="Enter MARG3AC output Prefix for CLCF file 2 : "
set scriptDir=C:\GMS_GMI
set wrkdir=C:\GMS_GMI\wrkdir
perl %scriptDir%\CompareCLCF1.pl %runid1% %runid2% > %wrkdir%\%runid1%%runid2%CLCF1.log
perl %scriptDir%\CompareCLCF2.pl %runid1% %runid2% > %wrkdir%\%runid1%%runid2%CLCF2.log
echo Completed Successfully
goto :END
:END