#!/usr/bin/perl
use warnings;
$| = 1;

my $run_id = $ARGV[0];
my $posFile;
my $modPosFile;
my $modPos;
my $strFind;
my $strReplace;
my $cwd;
my $delDate;
my $conType;
my $arrLength;
my $scriptDir = "C:\\GMS_GMI";
$cwd = "C:\\GMS_GMI\\wrkdir";
chdir($cwd);

# print "Loading position file  ...\n";

$posFile = $cwd."\\".$run_id."UJCP.txt";
$modPosFile = $cwd."\\".$run_id."MODUJCP.txt";

open (POS, "<$posFile");
open (WRITEPOS, "> $modPosFile");
LINE: while ( <POS> ){
	$_ =~ s/^\s+|\s+$//g;
	@fields = split /;/, $_;
	if ($fields[0] eq "040"){
		$conType = $fields[4];
		$strFind = "\"";
		$strReplace = "";
		$conType =~ s/$strFind/$strReplace/gi;
		chomp;
		if ($conType eq "O") {
			$fields[19] = $fields[7];
			$arrLength = scalar(@fields);
			$modPos = $fields[0];
			for (my $i=1; $i < $arrLength; $i++) {
				$modPos = $modPos.";".$fields[$i];
			}
			print WRITEPOS "$modPos;\n";
		}
		else{
			print WRITEPOS "$_\n";
		}
	}
	else {
		print WRITEPOS "$_\n";
	}
	
}
close WRITEPOS;
close POS;
print "Position modified successfully. \n";

#sleep();