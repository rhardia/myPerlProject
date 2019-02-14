#! /usr/bin/perl
# use warnings;
#$| = 1;
my %mgResults;
my %atype;

#my %atype = ('F1' => 'USD','FK' => 'JPY','FB' => 'GBP','FV' => 'CHF','LC' => 'CAD','LO' => 'ZAR','LU' => 'SEK','M1' => 'EUR','M3' => 'AUD','MA' => 'NOK','MF' => 'NZD','O1' => 'USD',' '=>'USD','F9' => 'CAD');

# print "Comparing GMS mg with GMI CSV file...\n";
my $run_id = $ARGV[0];
my $filename = "mg_".$run_id.".gms";
my $csv_file = $run_id."CLCF1.csv";
my $diffFile;
my $tmpFile;
my $dbkey;
my $strFind;
my $strReplace;
my $cmd;
my $currency;
my $scriptDir = "C:\\GMS_GMI";
my $cwd = "C:\\GMS_GMI\\wrkdir";
my @arrValues;
my @arrResults;
chdir($cwd);

my $gmimpsf2 =  $cwd."\\GMIMPSF2.CSV";

open (GMIMPSF, "<$gmimpsf2");
while ( <GMIMPSF> ){
	$strFind = "\"";
	$strReplace = "";
	$_ =~ s/$strFind/$strReplace/gi;
	chomp;
	$_ =~ s/^\s+|\s+$//g;
	@fields = split /,/, $_;
	$t2atyp=$fields[5];
	$t2mrgccy=$fields[4];
	$atype{$t2atyp} = $t2mrgccy;
}
close GMIMPSF;


# print "Loading mg file $filename...\n";
#$filename = $cwd."\\".$filename;
$tmpFile = "TMP100.txt";
#$cmd= "grep \'^[A-Z][A-Z][A-Z]100\' $filename > TMP100.txt";
$cmd = "findstr -r \"^[A-Z][A-Z][A-Z]100\" ".$filename." > ".$tmpFile;
# print "Creating temporary file TMP100.txt ...\n";
system($cmd);
my $ACCODE;
my $CURRCODE;
my $GMItotal;
open (MGFILE, "<$tmpFile");
LINE: while ( <MGFILE> ){
	chomp;
	$_ =~ s/^\s+|\s+$//g;
	$ACCODE = substr($_,12,9);
	chomp($ACCODE);		
	$strFind = " ";
	$strReplace = "";
	$ACCODE =~ s/$strFind/$strReplace/gi;
	$CURRCODE = substr($_,59,3);
	my $T_MARGIN = substr($_,69,15);
	#my $PORT_MAINT = substr($_,136,15);
	my $PORT_SH_LIQ = substr($_,198,15);
	my $PORT_LG_LIQ = substr($_,213,15);
	my $T_NOV = $PORT_LG_LIQ + $PORT_SH_LIQ;
	my $GMStotal=$T_MARGIN+0;
	my $GMSKey=$ACCODE.$CURRCODE;
	if(exists $mgResults{$GMSKey}){
		@arrValues=split(',',$mgResults{$GMSKey});
		$GMStotal = $arrValues[0] + $GMStotal;
		$T_NOV = $arrValues[1] + $T_NOV;
		$mgResults{$GMSKey} = $GMStotal.",".$T_NOV;
	}
	else{
		$mgResults{$GMSKey} = $GMStotal.",".$T_NOV;
	}
	
}
close MGFILE;
# print "Margin file load completed ...\n";

###########################################################################################################################################################################

# print "Loading csv file $csv_file...\n";

#$csv_file = $cwd."\\".$csv_file;
$diffFile = $scriptDir."\\".$run_id."CLCF1_DIFF.CSV";
open (CSV, "<$csv_file");
open (WRITECSV, "> $diffFile");
print WRITECSV "Firm,Account,Currency,GMS Initial Margin,GMS NOV,GMI Initial Margin,GMI NOV,Diff IM,Diff NOV \n";
while ( <CSV> ){
	$strFind = "\"";
	$strReplace = "";
	$_ =~ s/$strFind/$strReplace/gi;
	chomp;
	$_ =~ s/^\s+|\s+$//g;
	@fields = split /,/, $_;
	
	my $firm=$fields[0];
	chomp($firm);
	$firm =~ s/^\s+|\s+$//g;  #trim($firm)

	my $account=$fields[2];
	$account =~ s/^\s+|\s+$//g;  #trim($account)
	chomp($account);

	my $GMINOV=$fields[10];
	$GMINOV =~ s/^\s+|\s+$//g;  #trim($actype)
	$GMINOV = -1*$GMINOV;
	my $actype=$fields[3];
	$actype =~ s/^\s+|\s+$//g;  #trim($actype)
	my $aChar = substr($actype,0,1);
	if (($aChar =~ /[A-Z]/) |($aChar =~ /[0-9]/)){
		$currency=$atype{$actype};
	}
	else{
		print "Account Type is blank for account $account UNDER CLCF1. Default account type = F1 used \n";
		$actype = "F1";
		$currency=$atype{$actype};
	}
	my $IM=$fields[8];
	my $MM=$fields[9];
	my $totalM=$IM+0;
	$dbkey=$firm.$account.$currency;

	if(exists $mgResults{$dbkey}){	
		@arrResults=split(',',$mgResults{$dbkey});
		my $diffTotal = $totalM - $arrResults[0];
		$diffTotal = abs($diffTotal);
		my $diffNOV = $GMINOV - $arrResults[1];
		$diffNOV = abs($diffNOV);
		#print WRITECSV "$firm,$account,$currency,$arrResults[0],$arrResults[1],$totalM,$GMINOV,$diffTotal,$diffNOV \n";
		if(($diffTotal>1)||($diffNOV>1)){print WRITECSV "$firm,$account,$currency,$arrResults[0],$arrResults[1],$totalM,$GMINOV,$diffTotal,$diffNOV \n";}
		delete $mgResults{$dbkey};
	}
	else{
			if ($totalM ne 0) {
				print "$dbkey ACCOUNT NOT FOUND UNDER MG file \n";
			}
	}
}

close WRITECSV;
close CSV;

my $count = scalar(keys %mgResults);
if ($count >0){
	print "$count ACCOUNTS NOT FOUND UNDER CLCF1 \n";
	while( my( $key, $value ) = each %mgResults ){
		print "$key: $value NOT FOUND UNDER CLCF1 \n";
	}
}
print "Compare completed successfully. \n";
#sleep();
