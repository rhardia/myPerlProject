#!/usr/bin/perl
use warnings;
$| = 1;
my %mgResults;
my %mgResults1;

# print "Comparing GMS mg with GMI CSV file...\n";

my $run_id1 = $ARGV[0];
my $run_id2 = $ARGV[1];
my $csv_file;
my $csv_file1 = $run_id1."CLCF2.csv";
my $csv_file2 = $run_id2."CLCF2.csv";
my $strFind;
my $strReplace;
my $cwd;
my $gmi_ex;
my $method_code;
my $gms_ex;
my $gmsAlgo;
my $t2atyp;
my $t2mrgccy;
# print "Loading margin file $filename...\n";
my $scriptDir = "C:\\GMS_GMI";
$cwd = "C:\\GMS_GMI\\wrkdir";
chdir($cwd);

# print "Loading csv file $csv_file...\n";
my $firm;
my $account;
my $subfirm;
my $subaccount;
my $actype;
my $combineCode;
my $GMIExCode;
my $currency;
my $dbkey;
my $GMImethod;
my $GMIcomEx;
my $GMIIM;
my $GMIMM;
my $GMIRIS;
my $GMIIMS;
my $GMIICS;
my $GMISOM;
my $GMINOV;
my $count;
my @arrResults;
my @arrResults1;
my @arrKey;
$csv_file = $cwd."\\".$csv_file1;
my $diffFile = $cwd."\\".$run_id1."_".$run_id2."_CLCF2_DIFF.CSV";
my $fileAll = $cwd."\\".$run_id1."_".$run_id2."_CLCF2_MATCHED.CSV";

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

	$subfirm=$fields[6];
	chomp($subfirm);
	$subfirm =~ s/^\s+|\s+$//g;  #trim($subfirm)
	
	$account=$fields[2];
	$account =~ s/^\s+|\s+$//g;  #trim($account)
	chomp($account);

	$subaccount=$fields[8];
	$subaccount =~ s/^\s+|\s+$//g;  #trim($subaccount)
	chomp($subaccount);
	
#	if ($subfirm ne "*"){
#		$account = $firm.$account.$subfirm.$subaccount;
#	}
#	else{
#	#	$account = $firm.$account.$subfirm;
#		$account = $firm.$account;
#	}

	$account = $firm.$account;
	$strFind = " ";
	$strReplace = "";
	$account =~ s/$strFind/$strReplace/gi;
	
	$actype=$fields[3];
	$actype =~ s/^\s+|\s+$//g;  #trim($actype)
	chomp($actype);

	$combineCode=$fields[10];
	chomp($combineCode);
	$combineCode =~ s/^\s+|\s+$//g;  #trim($combineCode)
	$combineCode =~	s/[[:^print:]\s]//g;
	
	$grpCode=$fields[11];
	chomp($grpCode);
	$grpCode =~ s/^\s+|\s+$//g;  #trim($grpCode)
#	$grpCode =~ s/\A[[:^print:]\s]|[[:^print:]\s]\z/;
	$grpCode =~	s/[[:^print:]\s]//g;
	
	$GMIExCode=$fields[9];
	chomp($GMIExCode);
	$GMIExCode =~ s/^\s+|\s+$//g;  
	my @values= qw(16 9C 9D 9G 9J 9K);
	foreach my $exch (@values){
		if ($GMIExCode eq $exch){
			$GMIExCode="02";
			last;
		}
	}
	if (($GMIExCode eq '9F')||($GMIExCode eq '5O')){
		$GMIExCode="9E";
	}
	
	$dbkey = $GMIExCode."!".$account."!".$combineCode."!".$grpCode;

	$GMIIM = $fields[17]+0;
	$GMIMM = $fields[18]+0;
	$GMIRISK = $fields[19]+0;
	$GMIIMS = $fields[20]+0;
	$GMIICS = $fields[21]+0;
	$GMISOM = $fields[22]+0;
	$GMINOV = $fields[24]+0;
	$GMIIM=~ s/^\s+|\s+$//g;  #trim
	$GMIMM=~ s/^\s+|\s+$//g;  #trim
	$GMIRISK=~ s/^\s+|\s+$//g;  #trim
	$GMIIMS=~ s/^\s+|\s+$//g;  #trim
	$GMIICS=~ s/^\s+|\s+$//g;  #trim
	$GMISOM=~ s/^\s+|\s+$//g;  #trim
	$GMINOV=~ s/^\s+|\s+$//g;  #trim
	
	if(exists $mgResults{$dbkey}){
#		print " $dbkey is repeated under file $csv_file1 \n";
		@arrResults=split(',',$mgResults{$dbkey});
		$GMIMM = $GMIMM + $arrResults[0];
		$GMINOV = $GMINOV + $arrResults[1];
		$GMIRISK = $GMIRISK + $arrResults[2];
		$GMIIMS = $GMIIMS + $arrResults[3];
		$GMIICS = $GMIICS + $arrResults[4];
		$GMISOM = $GMISOM + $arrResults[5];
		$GMIIM = $GMIIM + $arrResults[6];
		#print $dbkey ." Exists \n";
	}
	$mgResults{$dbkey} = $GMIMM.",".$GMINOV.",".$GMIRISK.",".$GMIIMS.",".$GMIICS.",".$GMISOM.",".$GMIIM;
}
close CSV;
################################################################################################################################################################################################
######################################### READING OTHER CLCF2 FILE & COMPARE ######################################################################
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

	$subfirm=$fields[6];
	chomp($subfirm);
	$subfirm =~ s/^\s+|\s+$//g;  #trim($subfirm)
	
	$account=$fields[2];
	$account =~ s/^\s+|\s+$//g;  #trim($account)
	chomp($account);

	$subaccount=$fields[8];
	$subaccount =~ s/^\s+|\s+$//g;  #trim($subaccount)
	chomp($subaccount);
	
#	if ($subfirm ne "*"){
#		$account = $firm.$account.$subfirm.$subaccount;
#	}
#	else{
##		$account = $firm.$account.$subfirm;
#		$account = $firm.$account;	
#	}

	$account = $firm.$account;	
	$strFind = " ";
	$strReplace = "";
	$account =~ s/$strFind/$strReplace/gi;
	
	$actype=$fields[3];
	$actype =~ s/^\s+|\s+$//g;  #trim($actype)
	chomp($actype);

	$combineCode=$fields[10];
	chomp($combineCode);
	$combineCode =~ s/^\s+|\s+$//g;  #trim($combineCode)
	$combineCode =~	s/[[:^print:]\s]//g;
	
	$grpCode=$fields[11];
	chomp($grpCode);
	$grpCode =~ s/^\s+|\s+$//g;  #trim($grpCode)
	$grpCode =~	s/[[:^print:]\s]//g;
	
	$GMIExCode=$fields[9];
	chomp($GMIExCode);
	$GMIExCode =~ s/^\s+|\s+$//g;  
	my @values= qw(16 9C 9D 9G 9J 9K);
	foreach my $exch (@values){
		if ($GMIExCode eq $exch){
			$GMIExCode="02";
			last;
		}
	}
	if (($GMIExCode eq '9F')||($GMIExCode eq '5O')){
		$GMIExCode="9E";
	}

	$dbkey = $GMIExCode."!".$account."!".$combineCode."!".$grpCode;

	$GMIIM = $fields[17]+0;
	$GMIMM = $fields[18]+0;
	$GMIRISK = $fields[19]+0;
	$GMIIMS = $fields[20]+0;
	$GMIICS = $fields[21]+0;
	$GMISOM = $fields[22]+0;
	$GMINOV = $fields[24]+0;
	$GMIIM=~ s/^\s+|\s+$//g;  #trim
	$GMIMM=~ s/^\s+|\s+$//g;  #trim
	$GMIRISK=~ s/^\s+|\s+$//g;  #trim
	$GMIIMS=~ s/^\s+|\s+$//g;  #trim
	$GMIICS=~ s/^\s+|\s+$//g;  #trim
	$GMISOM=~ s/^\s+|\s+$//g;  #trim
	$GMINOV=~ s/^\s+|\s+$//g;  #trim
	
	if(exists $mgResults1{$dbkey}){
#		print " $dbkey is repeated under file $csv_file1 \n";
		@arrResults=split(',',$mgResults1{$dbkey});
		$GMIMM = $GMIMM + $arrResults[0];
		$GMINOV = $GMINOV + $arrResults[1];
		$GMIRISK = $GMIRISK + $arrResults[2];
		$GMIIMS = $GMIIMS + $arrResults[3];
		$GMIICS = $GMIICS + $arrResults[4];
		$GMISOM = $GMISOM + $arrResults[5];
		$GMIIM = $GMIIM + $arrResults[6];
		#print $dbkey ." Exists \n";
	}
	$mgResults1{$dbkey} = $GMIMM.",".$GMINOV.",".$GMIRISK.",".$GMIIMS.",".$GMIICS.",".$GMISOM.",".$GMIIM;

}

close CSV;

$count = scalar(keys %mgResults);
print "$csv_file1 count = $count \n";
$count = scalar(keys %mgResults1);
print "$csv_file2 count = $count \n";


open (WRITECSV, "> $diffFile");	#$COMB_MAINT.",".$NOV.",".$SCANRISK.",".$IMS.",".$ICS.",".$SOM;
open (WRITECSVALL, "> $fileAll");	#$COMB_MAINT.",".$NOV.",".$SCANRISK.",".$IMS.",".$ICS.",".$SOM;

print WRITECSV "Exchange Code,Account,Combine Comm Code,$run_id1 Maint Margin,$run_id1 Init Margin,$run_id1 NOV,$run_id1 Scan Risk,$run_id1 IMS,$run_id1 ICS,$run_id1 SOM,$run_id2 Maint Margin,$run_id2 Init Margin,$run_id2 NOV,$run_id2 Scan Risk,$run_id2 IMS,$run_id2 ICS,$run_id2 SOM,Diff Maint Margin,Diff Init Margin,Diff NOV,Diff SOM \n";
print WRITECSVALL "Exchange Code,Account,Combine Comm Code,$run_id1 Maint Margin,$run_id1 Init Margin,$run_id1 NOV,$run_id1 Scan Risk,$run_id1 IMS,$run_id1 ICS,$run_id1 SOM,$run_id2 Maint Margin,$run_id2 Init Margin,$run_id2 NOV,$run_id2 Scan Risk,$run_id2 IMS,$run_id2 ICS,$run_id2 SOM,Diff Maint Margin,Diff Init Margin,Diff NOV,Diff SOM \n";
$count = scalar(keys %mgResults);
if ($count >0){
	while( my( $key, $value ) = each %mgResults ){
		if(exists $mgResults1{$key}){
			@arrResults=split(',',$mgResults{$key});				#$GMIMM.",".$GMINOV.",".$GMIRISK.",".$GMIIMS.",".$GMIICS.",".$GMISOM;
			@arrResults1=split(',',$mgResults1{$key});				#$GMIMM.",".$GMINOV.",".$GMIRISK.",".$GMIIMS.",".$GMIICS.",".$GMISOM;
			my $diffMM = $arrResults[0] - $arrResults1[0];
			$diffMM = abs($diffMM);
			my $diffIM = $arrResults[6] - $arrResults1[6];
			$diffIM = abs($diffIM);
			my $diffNOV = $arrResults[1] - $arrResults1[1];
			$diffNOV = abs($diffNOV);
			my $diffSOM = $arrResults[5] - $arrResults1[5];
			$diffSOM = abs($diffSOM);
			@arrKey = split('!',$key);
			if (($diffMM>10)||($diffIM>10)){
				print WRITECSV "$arrKey[0],$arrKey[1],$arrKey[2],$arrResults[0],$arrResults[6],$arrResults[1],$arrResults[2],$arrResults[3],$arrResults[4],$arrResults[5],$arrResults1[0],$arrResults1[6],$arrResults1[1],$arrResults1[2],$arrResults1[3],$arrResults1[4],$arrResults1[5],$diffMM,$diffIM,$diffNOV,$diffSOM \n";
			}
			else{
				print WRITECSVALL "$arrKey[0],$arrKey[1],$arrKey[2],$arrResults[0],$arrResults[6],$arrResults[1],$arrResults[2],$arrResults[3],$arrResults[4],$arrResults[5],$arrResults1[0],$arrResults1[6],$arrResults1[1],$arrResults1[2],$arrResults1[3],$arrResults1[4],$arrResults1[5],$diffMM,$diffIM,$diffNOV,$diffSOM \n";
			}
			delete $mgResults{$key};
			delete $mgResults1{$key};	
		}
		else{
			#print "$key not found under $csv_file2 \n";
		}
	}	
}

close WRITECSV;
close WRITECSVALL;
$count = scalar(keys %mgResults);
if ($count >0){
	print "---------------------------------------------------------------- \n";
	while( my( $key, $value ) = each %mgResults ){
			@arrResults=split(',',$mgResults{$key});	
			if ($arrResults[0] ne 0){
				print "$key not found under $csv_file2. Maintenance Margin under $csv_file1 --- $arrResults[0] \n";
				delete $mgResults{$key};
			}
	}
}

$count = scalar(keys %mgResults1);
if ($count >0){
	print "---------------------------------------------------------------- \n";
	while( my( $key, $value ) = each %mgResults1 ){
			@arrResults=split(',',$mgResults1{$key});	
			if ($arrResults[0] ne 0){
				print "$key not found under $csv_file1. Maintenance Margin under $csv_file2 --- $arrResults[0] \n";
				delete $mgResults1{$key};
			}
	}
}

print "---------------------------------------------------------------- \n";
print "Following are the zero margin records of $csv_file1 \n";	
print "---------------------------------------------------------------- \n";
		
$count = scalar(keys %mgResults);
if ($count >0){
	while( my( $key, $value ) = each %mgResults ){
			@arrResults=split(',',$mgResults{$key});	
				print "$key not found under $csv_file2. Maintenance Margin under $csv_file1 --- $arrResults[0] \n";
	}
}

print "---------------------------------------------------------------- \n";
print "Following are the zero margin records of $csv_file2 \n";	
print "---------------------------------------------------------------- \n";

$count = scalar(keys %mgResults1);
if ($count >0){
	while( my( $key, $value ) = each %mgResults1 ){
			@arrResults=split(',',$mgResults1{$key});	
				print "$key not found under $csv_file1. Maintenance Margin under $csv_file2 --- $arrResults[0] \n";
	}
}


print "Compare completed successfully. \n";

#sleep();