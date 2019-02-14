#!/usr/bin/perl
use warnings;
$| = 1;
my %mgResults;
my %method = ('CA' => 'CDE','9E' => 'OCX','9F' => 'OCX');
my %exch = ('CA' => 'CDE');
my %atype;
my $run_id = $ARGV[0];
my $strFind;
my $strReplace;
my $cwd;
my $gmi_ex;
my $method_code;
my $gms_ex;
my $t2atyp;
my $t2mrgccy;
my $scriptDir = "C:\\GMS_GMI";
$cwd = "C:\\GMS_GMI\\wrkdir";
my $gmigmst1 = $cwd."\\GMIGMST1.CSV";
my $gmimpsf2 =  $cwd."\\GMIMPSF2.CSV";
my $filename = "mg_".$run_id.".gms";
my $csv_file = $run_id."CLCF2.csv";
chdir($cwd);

open (GMIGMST, "<$gmigmst1");
while ( <GMIGMST> ){
	$strFind = "\"";
	$strReplace = "";
	$_ =~ s/$strFind/$strReplace/gi;
	chomp;
	
	$_ =~ s/^\s+|\s+$//g;
	@fields = split /,/, $_;
	$gmi_ex=$fields[1];
	$gmi_ex =~ s/^\s+|\s+$//g;  #trim($gmi_ex)
	$method_code=$fields[2];
	$method_code =~ s/^\s+|\s+$//g;  #trim($method_code)
	$gms_ex=$fields[3];
	$gms_ex =~ s/^\s+|\s+$//g;  #trim($gms_ex)	
	$method{$gmi_ex} = $method_code;
	$exch{$gmi_ex} = $gms_ex;
}
close GMIGMST;

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

#my %method = ('9C' => 'CCL','01' => 'CCL','16' => 'CCL','02' => 'CCL','04' => 'CCL','07' => 'CCL','5O' => 'OCX','9E' => 'OCX','9F' => 'OCX','9B' => 'NFX','9O' => 'ELX');
#my %exch = ('9C' => 'CME','01' => 'CBT','16' => 'CME','02' => 'CME','04' => 'CMX','07' => 'NYM');
#my %atype = ('F1' => 'USD','FK' => 'JPY','FB' => 'GBP','FV' => 'CHF','LC' => 'CAD','LO' => 'ZAR','LU' => 'SEK','M1' => 'EUR','M3' => 'AUD','MA' => 'NOK','MF' => 'NZD','O1' => 'USD','F9' => 'CAD',' '=>'USD');

my $METHOD; # 0 +3
my $ACCODE; # 12 +20
my $COMB_CODE; # 42 +10
my $CURRCODE; # 139 +12
my $COMB_EXCH; # 151 +6
my $COMB_MAINT; #52 +15
my $COMB_INIT; #67 +15
my $SH_OPT_LIQ; #82 +15
my $LG_OPT_LIQ; #97 +15
my $NOV;
my $GMStotal;
my $GMItotal;
my $GMSKey;
my $cmd;

#$cmd= "grep \'^[A-Z][A-Z][A-Z]032\' $filename > TMP032.txt";
$cmd = "findstr -r \"^[A-Z][A-Z][A-Z]032\" ". $filename ." > TMP032.txt";
# print "Creating temporary file TMP032.txt ...\n";
system($cmd);
$filename = "TMP032.txt";
open (MGFILE, "<$filename");
while ( <MGFILE> ){
	chomp;
	$_ =~ s/^\s+|\s+$//g;
	
	$METHOD = substr($_,0,3);
	
	$ACCODE = substr($_,12,20);
	chomp($ACCODE);		
	$ACCODE =~ s/^\s+|\s+$//g;
	$strFind = " ";
	$strReplace = "";
	$ACCODE =~ s/$strFind/$strReplace/gi;
	
	$COMB_CODE = substr($_,42,10);
	chomp($COMB_CODE);		
	$COMB_CODE =~ s/^\s+|\s+$//g;
	
	$CURRCODE = substr($_,139,12);
	chomp($CURRCODE);		
	$CURRCODE =~ s/^\s+|\s+$//g;
	
	$COMB_EXCH = substr($_,151,6);
	chomp($COMB_EXCH);		
	$COMB_EXCH =~ s/^\s+|\s+$//g;
	
	$COMB_MAINT = substr($_,52,15);
	$COMB_INIT = substr($_,67,15);
	
	$SH_OPT_LIQ = substr($_,82,15)+0;
	$LG_OPT_LIQ = substr($_,97,15)+0;
	$COMB_MAINT = $COMB_MAINT + 0;
	$COMB_INIT = $COMB_INIT + 0;
	$NOV = $LG_OPT_LIQ;
	$GMStotal = $COMB_MAINT + $COMB_INIT;
	if ($METHOD eq "CCL"){$GMSKey = $METHOD.$ACCODE.$COMB_CODE.$CURRCODE.$COMB_EXCH;}
	else{$GMSKey = $METHOD.$ACCODE.$COMB_CODE.$CURRCODE;}
		
#	if(exists $mgResults{$GMSKey}){$mgResults{$GMSKey} = $mgResults{$GMSKey}+$GMStotal;}
#	else{$mgResults{$GMSKey} = $GMStotal;}
	$mgResults{$GMSKey} = $GMStotal.",".$COMB_MAINT.",".$COMB_INIT.",".$NOV;	
}
close MGFILE;

# print "Margin file load completed ...\n";
#print "Removing temporary file TMP032.txt ...\n";
#$cmd= "del TMP032.txt";
#system($cmd);

###########################################################################################################################################################################

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
my $GMIcomEx="";

$csv_file = $cwd."\\".$csv_file;

$diffFile = $scriptDir."\\".$run_id."CLCF2_DIFF.CSV";
open (CSV, "<$csv_file");

open (WRITECSV, "> $diffFile");
print WRITECSV "GMS Method Code,Account,Combine Comm Code,Currency,GMS Ex Code,GMS Maint Margin,GMS Initial Margin,GMS NOV,GMI Maint Margin,GMI Initial Margin,GMI NOV,Diff IM, Diff NOV \n";
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
	
	$account = $firm.$account.$subfirm.$subaccount;
	
	$strFind = " ";
	$strReplace = "";
	$account =~ s/$strFind/$strReplace/gi;
	
	$actype=$fields[3];
	$actype =~ s/^\s+|\s+$//g;  #trim($actype)
	chomp($actype);
	my $aChar = substr($actype,0,1);
	if (($aChar =~ /[A-Z]/) |($aChar =~ /[0-9]/)){
		if(exists $atype{$actype}){
			$currency=$atype{$actype};
		}
		else{
			print "GMI Account Type  $actype not defined under MMCLR. This is ignored from comparison ...\n";
			next LINE;
		}
		
	}
	else{
	print "Account Type is blank for account $account UNDER CLCF2. Default account type = F1 used \n";
	$actype = "F1";
	$currency=$atype{$actype};
	}
	$combineCode=$fields[10];
	chomp($combineCode);
	$combineCode =~ s/^\s+|\s+$//g;  #trim($combineCode)
	
	$GMIExCode=$fields[9];
	chomp($GMIExCode);
	$GMIExCode =~ s/^\s+|\s+$//g;  #trim($GMIExCode)
	if ($GMIExCode eq ""){
		print "Exchange code is blank in CLCF2 for combine commodity $combineCode under account $account ...\n";
		next LINE;
	}
	else{
		if(exists $method{$GMIExCode}){
			$GMImethod = $method{$GMIExCode};
		}
		else{
			print "GMI Exchange $GMIExCode not found under downloaded GMIGMST1 file. Exchange $GMIExCode ignored from comparison ...\n";
			next LINE;
		} 
		if ($GMImethod ne "CCL"){$GMIcomEx = $GMImethod; }
		else {$GMIcomEx = $exch{$GMIExCode};}
	}

	
	
	if ($GMImethod eq "CCL"){$dbkey = $GMImethod.$account.$combineCode.$currency.$GMIcomEx;}
	else{$dbkey = $GMImethod.$account.$combineCode.$currency;}
	

	my $IM = $fields[17];
	my $MM = $fields[18];
	my $GMINOV = $fields[24];
	my $totalM = $IM+$MM;
	$IM=~ s/^\s+|\s+$//g;  #trim
	$MM=~ s/^\s+|\s+$//g;  #trim
	$GMINOV=~ s/^\s+|\s+$//g;  #trim

	if(exists $mgResults{$dbkey}){
			my @arrResults=split(',',$mgResults{$dbkey});
			my $diffTotal = $totalM - $arrResults[0];
			$diffTotal = abs($diffTotal);
			$diffTotal = $diffTotal/2;
			my $diffNOV = $GMINOV - $arrResults[3];
			$diffNOV = abs($diffNOV);
			if(($diffTotal>1)||($diffNOV>1)){print WRITECSV "$GMImethod,$account,$combineCode,$currency,$GMIcomEx,$arrResults[1],$arrResults[2],$arrResults[3],$MM,$IM,$GMINOV,$diffTotal,$diffNOV \n";}
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
	print "$count ACCOUNTS NOT FOUND UNDER CLCF2 \n";
	while( my( $key, $value ) = each %mgResults ){
		print "$key NOT FOUND UNDER CLCF2 \n";
	}
}
print "Compare completed successfully. \n";

#sleep();