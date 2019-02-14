#!/usr/bin/perl
use warnings;
$| = 1;
my %mgResults;
my %mgResults1;


my $run_id1 = $ARGV[0];
my $run_id2 = $ARGV[1];
my $csv_file;
my $csv_file1 = $run_id1."CLCF1.csv";
my $csv_file2 = $run_id2."CLCF1.csv";
my $strFind;
my $strReplace;
my $cwd;
# print "Loading margin file $filename...\n";
my $scriptDir = "C:\\GMS_GMI";
$cwd = "C:\\GMS_GMI\\wrkdir";
chdir($cwd);

# print "Loading csv file $csv_file...\n";
my $firm;
my $account;
my $actype;
my $dbkey;
my $GMIIM;
my $GMIMM;
my $GMINOV;
my $count;
my @arrResults;
my @arrResults1;
my @arrKey;
$csv_file = $cwd."\\".$csv_file1;
my $diffFile = $cwd."\\".$run_id1."_".$run_id2."_CLCF1_DIFF.CSV";
my $fileAll = $cwd."\\".$run_id1."_".$run_id2."_CLCF1_MATCHED.CSV";

open (CSV, "<$csv_file");

LINE: while ( <CSV> ){
	$strFind = "\"";
	$strReplace = "";
	$_ =~ s/$strFind/$strReplace/gi;
	chomp;
	
	$_ =~ s/^\s+|\s+$//g;
	@fields = split /,/, $_;
	
	$firm=$fields[0];
	chomp($firm);
	$firm =~ s/^\s+|\s+$//g;  #trim($firm)


	
	$account=$fields[2];
	$account =~ s/^\s+|\s+$//g;  #trim($account)
	chomp($account);
	$strFind = " ";
	$strReplace = "";
	$account =~ s/$strFind/$strReplace/gi;
	
	$actype=$fields[3];
	$actype =~ s/^\s+|\s+$//g;  #trim($actype)
	chomp($actype);

	
	$dbkey = $firm."-".$account."-".$actype;

	$GMIIM = $fields[8]+0;
	$GMIMM = $fields[9]+0;
	$GMINOV = $fields[10]+0;
	
	if(exists $mgResults{$dbkey}){
		@arrResults=split(',',$mgResults{$dbkey});
		$GMIIM = $GMIIM + $arrResults[0];
		$GMIMM = $GMIMM + $arrResults[1];
		$GMINOV = $GMINOV + $arrResults[2];
	}
	$mgResults{$dbkey} = $GMIIM.",".$GMIMM.",".$GMINOV;
}
close CSV;
################################################################################################################################################################################################
######################################### READING OTHER CLCF1 FILE & COMPARE ######################################################################
################################################################################################################################################################################################

$csv_file = $cwd."\\".$csv_file2;

open (CSV, "<$csv_file");



LINE: while ( <CSV> ){
	$strFind = "\"";
	$strReplace = "";
	$_ =~ s/$strFind/$strReplace/gi;
	chomp;
	
	$_ =~ s/^\s+|\s+$//g;
	@fields = split /,/, $_;
	
	$firm=$fields[0];
	chomp($firm);
	$firm =~ s/^\s+|\s+$//g;  #trim($firm)


	
	$account=$fields[2];
	$account =~ s/^\s+|\s+$//g;  #trim($account)
	chomp($account);
	$strFind = " ";
	$strReplace = "";
	$account =~ s/$strFind/$strReplace/gi;
	
	$actype=$fields[3];
	$actype =~ s/^\s+|\s+$//g;  #trim($actype)
	chomp($actype);

	
	$dbkey = $firm."-".$account."-".$actype;

	$GMIIM = $fields[8]+0;
	$GMIMM = $fields[9]+0;
	$GMINOV = $fields[10]+0;
	
	if(exists $mgResults1{$dbkey}){
		@arrResults=split(',',$mgResults1{$dbkey});
		$GMIIM = $GMIIM + $arrResults[0];
		$GMIMM = $GMIMM + $arrResults[1];
		$GMINOV = $GMINOV + $arrResults[2];
	}
	$mgResults1{$dbkey} = $GMIIM.",".$GMIMM.",".$GMINOV;

}

close CSV;

$count = scalar(keys %mgResults1);
print "$csv_file2 count = $count \n";
$count = scalar(keys %mgResults);
print "$csv_file1 count = $count \n";

open (WRITECSV, "> $diffFile");	#$COMB_MAINT.",".$NOV.",".$SCANRISK.",".$IMS.",".$ICS.",".$SOM;
open (WRITECSVALL, "> $fileAll");	#$COMB_MAINT.",".$NOV.",".$SCANRISK.",".$IMS.",".$ICS.",".$SOM;

print WRITECSV "Firm,Account,Account Type,$run_id1 IM,$run_id1 MM ,$run_id1 NOV,$run_id2 IM,$run_id2 MM ,$run_id2 NOV,Diff IM,Diff MM,Diff NOV \n";
print WRITECSVALL "Firm,Account,Account Type,$run_id1 IM,$run_id1 MM ,$run_id1 NOV,$run_id2 IM,$run_id2 MM ,$run_id2 NOV,Diff IM,Diff MM,Diff NOV \n";

$count = scalar(keys %mgResults);
if ($count >0){
	while( my( $key, $value ) = each %mgResults ){
		if(exists $mgResults1{$key}){
			@arrResults=split(',',$mgResults{$key});				#$GMIMM.",".$GMINOV.",".$GMIRISK.",".$GMIIMS.",".$GMIICS.",".$GMISOM;
			@arrResults1=split(',',$mgResults1{$key});				#$GMIMM.",".$GMINOV.",".$GMIRISK.",".$GMIIMS.",".$GMIICS.",".$GMISOM;
			my $diffIM = $arrResults[0] - $arrResults1[0];
			$diffIM = abs($diffIM);
			my $diffMM = $arrResults[1] - $arrResults1[1];
			$diffMM = abs($diffMM);
			my $diffNOV = $arrResults[2] - $arrResults1[2];
			$diffNOV = abs($diffNOV);
			@arrKey = split('-',$key);
			if (($diffIM>10)||($diffMM>10)||($diffNOV>10)){
				print WRITECSV "$arrKey[0],$arrKey[1],$arrKey[2],$arrResults[0],$arrResults[1],$arrResults[2],$arrResults1[0],$arrResults1[1],$arrResults1[2],$diffIM,$diffMM,$diffNOV \n";
			}
			else{
				print WRITECSVALL "$arrKey[0],$arrKey[1],$arrKey[2],$arrResults[0],$arrResults[1],$arrResults[2],$arrResults1[0],$arrResults1[1],$arrResults1[2],$diffIM,$diffMM,$diffNOV \n";
			}
			delete $mgResults{$key};
			delete $mgResults1{$key};	
		}
	}	
}

close WRITECSV;
close WRITECSVALL;
$count = scalar(keys %mgResults);
if ($count >0){
	print "---------------------------------------------------------------- \n";
	while( my( $key, $value ) = each %mgResults ){
			print "$key not found under $csv_file2 \n";
	}
}

$count = scalar(keys %mgResults1);
if ($count >0){
	print "---------------------------------------------------------------- \n";
	while( my( $key, $value ) = each %mgResults1 ){
			print "$key not found under $csv_file1 \n";
	}
}
print "Compare completed successfully. \n";

#sleep();