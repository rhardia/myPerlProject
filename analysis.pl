#!/usr/bin/perl
my $logDay=uc($ARGV[0]);
my $logVersion=uc($ARGV[1]);
my $logServer=$ARGV[2];
my $logDate;
my $logAutoPath="/qa_svn/regression/gms/log".$logVersion."/";
my $logDirPath=$logAutoPath."analysis";
my $tstprdTotal= '"ERROR: Test ( tst/ prd Total)"';
my $tstprdFull='"ERROR: Test ( tst/ prd Full )"';
my $errorVerified='"ERROR VERIFIED"';
my $tstbaseTotal='"ERROR: Test ( tst/base Total)"';
my $tstbaseFull='"ERROR: Test ( tst/base Full )"';
my $tstprdMargin='"ERROR: Test ( tst/ prd Margin)"';
my $tstbaseMargin='"ERROR: Test ( tst/base Margin)"';
my $emptyReport='"REPORT ERROR"';
my $moduleDiff='"DIFFERENCE->"';


####Get log Date#########
my $command="ls -lrt ".$logAutoPath."gmshopvega_*_autotest.log";
my @result=`$command`;
my $myLogFile=pop(@result);
if ($logDay eq 'PREV'){$myLogFile=pop(@result);}
my @arrLogFiles=split('/',$myLogFile);
$myLogFile=pop(@arrLogFiles);
my @logName=split('_',$myLogFile);
$logDate=$logName[1];
##########################


open (MYFILE, ">$logDirPath/file_$logDay.txt");
if($logServer eq ''){
	my @serverArr=("gmihopvega","NEWSYS03","mizar","gmshopvega");
	#@serverArr=("NEWSYS03");
	my $logFile=$logAutoPath.$serverArr[0]."_".$logDate."_autotest.log";
	&writeTestListToFile($moduleDiff,$logFile,'$serverArr[0]');
	my $size=@serverArr;
	for($i=0;$i<$size;$i++){
		if ($serverArr[$i] eq "windows") { 
		#$command = "perl -pi -e 's/\\\\/\\//gi;' /otmsdev/s_gms_p/regression/gms/log/windows_".$logDate."_autotest.log";
		$command = "perl -pi -e 's/\\\\/\\//gi;' ".$logAutoPath."windows_".$logDate."_autotest.log";
		#$command = "perl -pi -e 's/\\\\/\\//gi;' /qa_svn/regression/gms/log/windows_2014-04-08_autotest.log";
		@result = `$command`;}
		my $logFile=$logAutoPath.$serverArr[$i]."_".$logDate."_autotest.log";
		if (-e $logFile){
			open (LOGFILE, ">$logDirPath/$serverArr[$i]_$logDay.txt");
			&writeTestListToFile($errorVerified,$logFile,'$serverArr[$i]');
			&writeTestListToFile($tstbaseFull,$logFile,'$serverArr[$i]');
			&writeTestListToFile($tstbaseTotal,$logFile,'$serverArr[$i]');
			&writeTestListToFile($tstbaseMargin,$logFile,'$serverArr[$i]');
			&writeTestListToFile($tstprdFull,$logFile,'$serverArr[$i]');
			&writeTestListToFile($tstprdTotal,$logFile,'$serverArr[$i]');
			&writeTestListToFile($tstprdMargin,$logFile,'$serverArr[$i]');
			&writeTestListToFile($emptyReport,$logFile,'$serverArr[$i]');
			close (LOGFILE);
		}
	}
}
else{
		my $logFile=$logAutoPath.$logServer."_".$logDate."_autotest.log";
		if (-e $logFile){
			open (LOGFILE, ">$logDirPath/$logServer.txt_$logDay.txt");
			&writeTestListToFile($moduleDiff,$logFile,'$logServer');
			&writeTestListToFile($errorVerified,$logFile,'$logServer');
			&writeTestListToFile($tstbaseFull,$logFile,'$logServer');
			&writeTestListToFile($tstbaseTotal,$logFile,'$logServer');
			&writeTestListToFile($tstbaseMargin,$logFile,'$logServer');
			&writeTestListToFile($tstprdFull,$logFile,'$logServer');
			&writeTestListToFile($tstprdTotal,$logFile,'$logServer');
			&writeTestListToFile($tstprdMargin,$logFile,'$logServer');
			&writeTestListToFile($emptyReport,$logFile,'$logServer');
			close (LOGFILE);
		}
}
sub writeTestListToFile
{
my $command= "grep $_[0] $_[1]";
my $testList="";
my $writeLine="";
if(($_[0] ne '"DIFFERENCE->"')&&($_[0] ne '"REPORT ERROR"')){$writeLine="$_[0]\n";}
my @result=`$command`;
if (scalar(@result) eq 0 ){$testList="None"; }
for my $line (@result){ 
    	chop($line); if ($line =~ /^\s*$/) {next;}
	 if(rindex($line,'DIFF:')>0) {next;}
	if($_[0] eq '"DIFFERENCE->"'){
		@arrStr=split('>',$line);
		@moduleNameArr=split(' ',$arrStr[1]);
		$testList="$testList, $moduleNameArr[0] ";
		next;
	}
	elsif($_[0] eq '"REPORT ERROR"'){
		@arrStr=split('-->',$line);
		@testNameArr=split(' ',$arrStr[0]);
		$testName=pop(@testNameArr);
		@testPosArr=split(' ',$arrStr[1]);
		$testPos=pop(@testPosArr);	
				
	}
	else{
		$writeLine="$writeLine\n$line";	
		@arrStr=split('/',$line);
		@testNameArr=split(' ',pop(@arrStr));
		$testName=$testNameArr[0];
		$testPos=$testNameArr[1];	
	}
	if(rindex($testList,$testName) eq -1) {
		$testList="$testList, $testName pos $testPos ";			
	}
	else{
		$searchPos=rindex(reverse($testList),reverse($testName));
		if(rindex(reverse($testList),reverse($testPos),$searchPos) eq -1) {
			$str1=", $testName pos ";
			$str2=", $testName pos $testPos ";
			$testList=~s/$str1/$str2/;
		}
	}
}
$writeLine="$writeLine\n\n";
#open (LOGFILE, ">>$_[2].txt");
print(LOGFILE "$writeLine");
        open (MYFILE, ">>$logDirPath/file_$logDay.txt");
        if($_[0] eq '"ERROR VERIFIED"'){
		@logNameArr=split('/',$_[1]);
		$serverLogName=pop(@logNameArr);
		print(MYFILE "=======================================================$serverLogName====================================\n");
		
	}

@tempArr=split(' ',$testList);
if (scalar(@result) ne 0 ){shift @tempArr; }
$testList=join ' ',@tempArr;
print(MYFILE "$_[0]\n");
print(MYFILE "$testList\n");
print(MYFILE "\n\n");
close (MYFILE); 
return ;
}
