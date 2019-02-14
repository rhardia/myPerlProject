#!/usr/bin/perl
use warnings;
$| = 1;
my %mgResults;
#my %method = ('9C' => 'CCL','01' => 'CCL','16' => 'CCL','02' => 'CCL','04' => 'CCL','07' => 'CCL','5O' => 'OCX','9E' => 'OCX','9F' => 'OCX','9B' => 'NFX','9O' => 'ELX');
#my %exch = ('9C' => 'CME','01' => 'CBT','16' => 'CME','02' => 'CME','04' => 'CMX','07' => 'NYM');

my %method = ('CA' => 'CDE','9E' => 'OCX','9F' => 'OCX');
my %exch = ('CA' => 'CDE');
my %atype;
#my %atype = ('F1' => 'USD','FK' => 'JPY','FB' => 'GBP','FV' => 'CHF','LC' => 'CAD','LO' => 'ZAR','LU' => 'SEK','M1' => 'EUR','M3' => 'AUD','MA' => 'NOK','MF' => 'NZD','O1' => 'USD',' '=>'USD');

# print "Comparing GMS mg with GMI CSV file...\n";

my $run_id = $ARGV[0];
my $filename = $run_id."PbReq.csv";
my $csv_file = $run_id."CLCF2.csv";
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
my $gmigmst1 = $cwd."\\GMIGMST1.CSV";
my $gmimpsf2 =  $cwd."\\GMIMPSF2.CSV";
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
	$gmsAlgo = $fields[16];
	$gmsAlgo =~ s/^\s+|\s+$//g;
	if ($gmsAlgo eq "CMESPAN") {
		$method{$gmi_ex} = $method_code;
		$exch{$gmi_ex} = $gms_ex;
	}
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
	if (($fields[2] eq "CMESPAN")||($fields[3] eq "")){
		$atype{$t2atyp} = $t2mrgccy;
	}
#	$atype{$t2atyp} = $t2mrgccy;
}
close GMIMPSF;


# print "Loading csv file $csv_file...\n";
my $firm;
my $office;
my $account;
my $subfirm;
my $suboffice;
my $subaccount;
my $actype;
my $combineCode;
my $GMIExCode;
my $currency;
my $dbkey;
my $GMImethod;
my $GMIcomEx;

$csv_file = $cwd."\\".$csv_file;

$diffFile = $scriptDir."\\".$run_id."SPAN_CLCF2_DIFF.CSV";
$fileAll = $scriptDir."\\".$run_id."SPAN_CLCF2_MATCHED.CSV";

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
	
		$suboffice=$fields[7];
	chomp($suboffice);
	$suboffice =~ s/^\s+|\s+$//g;  #trim($suboffice)
	
	$office=$fields[1];
	chomp($office);
	$office =~ s/^\s+|\s+$//g;  #trim($suboffice)


	$account=$fields[2];
	$account =~ s/^\s+|\s+$//g;  #trim($account)
	chomp($account);

	$subaccount=$fields[8];
	$subaccount =~ s/^\s+|\s+$//g;  #trim($subaccount)
	chomp($subaccount);
	
	$account = $firm.$office.$account.$subfirm.$suboffice.$subaccount;
	
	$strFind = " ";
	$strReplace = "";
	$account =~ s/$strFind/$strReplace/gi;
	

	
	$combineCode=$fields[10];
	chomp($combineCode);
	$combineCode =~ s/^\s+|\s+$//g;  #trim($combineCode)
	
	$GMIExCode=$fields[9];
	chomp($GMIExCode);
	$GMIExCode =~ s/^\s+|\s+$//g;  #trim($combineCode)
	if ($GMIExCode eq ""){
		print "Exchange code is blank in CLCF2 for combine commodity $combineCode under account $account ...\n";
		next LINE;
	}
	else{
		if(exists $method{$GMIExCode}){
			$GMImethod = $method{$GMIExCode};
		}
		else{
#			print "GMI Exchange $GMIExCode not found under downloaded GMIGMST1 file. Exchange $GMIExCode ignored from comparison ...\n";
			next LINE;
		} 
	#	$GMIcomEx = $exch{$GMIExCode};
	}

	
	$actype=$fields[3];
	$actype =~ s/^\s+|\s+$//g;  #trim($actype)
	chomp($actype);
	my $aChar = substr($actype,0,1);
	if (($aChar =~ /[A-Z]/) |($aChar =~ /[0-9]/)){
		if(exists $atype{$actype}){
			$currency=$atype{$actype};
		}
		else{
			#print "$actype not found in GMIMPSF2 file \n";
			print "Account type $actype not found in GMIMPSF2 file. $GMImethod!$account!$combineCode skipped from comparison \n";
			next LINE;
		}
	}
	else{
		print "Account Type is blank for account $account UNDER CLCF2. Default account type = F1 used \n";
		$actype = "F1";
		$currency=$atype{$actype};
	}
	
	$dbkey = $GMImethod.$account.$combineCode.$currency;

	my $GMIIM = $fields[17]+0;
	my $GMIMM = $fields[18]+0;
	my $GMIRISK = $fields[19]+0;
	my $GMIIMS = $fields[20]+0;
	my $GMIICS = $fields[21]+0;
	my $GMISOM = $fields[22]+0;
	my $GMINOV = $fields[24]+0;
	$GMIIM=~ s/^\s+|\s+$//g;  #trim
	$GMIMM=~ s/^\s+|\s+$//g;  #trim
	$GMIRISK=~ s/^\s+|\s+$//g;  #trim
	$GMIIMS=~ s/^\s+|\s+$//g;  #trim
	$GMIICS=~ s/^\s+|\s+$//g;  #trim
	$GMISOM=~ s/^\s+|\s+$//g;  #trim
	$GMINOV=~ s/^\s+|\s+$//g;  #trim
	
	if(exists $mgResults{$dbkey}){
		my @arrResults=split(',',$mgResults{$dbkey});
		$GMIMM = $GMIMM + $arrResults[0];
		$GMINOV = $GMINOV + $arrResults[1];
		$GMIRISK = $GMIRISK + $arrResults[2];
		$GMIIMS = $GMIIMS + $arrResults[3];
		$GMIICS = $GMIICS + $arrResults[4];
		$GMISOM = $GMISOM + $arrResults[5];
		#print $dbkey ." Exists \n";
	}
	$mgResults{$dbkey} = $GMIMM.",".$GMINOV.",".$GMIRISK.",".$GMIIMS.",".$GMIICS.",".$GMISOM;
}
close CSV;
################################################################################################################################################################################################
######################################### READING PC SPAN FILE AND COMPARE ######################################################################
################################################################################################################################################################################################

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
my $SPANKey;
my $cmd;
my $SCANRISK;
my $IMS;
my $ICS;
my $IEX;
my $SOM;

$cmd = "findstr -r -c:nReq ". $filename ." > Req.txt";
system($cmd);
#$cmd = "findstr -v -c:\"Q\" nReq.txt  > Req.txt";
#system($cmd);
$cmd = "findstr -r -c:gReq ". $filename ." >> Req.txt";
system($cmd);
$filename = "Req.txt";
open (PCSPANFILE, "<$filename");

open (WRITECSV, "> $diffFile");	#$COMB_MAINT.",".$NOV.",".$SCANRISK.",".$IMS.",".$ICS.",".$SOM;
open (WRITECSVALL, "> $fileAll");	#$COMB_MAINT.",".$NOV.",".$SCANRISK.",".$IMS.",".$ICS.",".$SOM;

print WRITECSV "SPAN Method Code,Account,Combine Comm Code,Currency,SPAN Maint Margin,SPAN NOV,SPAN RISK, SPAN IMS,SPAN ICS,SPAN SOM,GMI Maint Margin,GMI NOV,GMI RISK, GMI IMS,GMI ICS,GMI SOM,Diff Maint Margin,Diff NOV,Diff SOM \n";
print WRITECSVALL "SPAN Method Code,Account,Combine Comm Code,Currency,SPAN Maint Margin,SPAN NOV,SPAN RISK, SPAN IMS,SPAN ICS,SPAN SOM,GMI Maint Margin,GMI NOV,GMI RISK, GMI IMS,GMI ICS,GMI SOM,Diff Maint Margin,Diff NOV,Diff SOM \n";


NEXTLINE: while ( <PCSPANFILE> ){
	chomp;
	$_ =~ s/^\s+|\s+$//g;

	$strFind = "\"";
	$strReplace = "";
	$_ =~ s/$strFind/$strReplace/gi;
	chomp;
	
	@SpanFields = split /,/, $_;
	
	if ($SpanFields[0] eq "node"){
		next NEXTLINE;
	}
	
	if (($SpanFields[0] eq "nReq")&&($SpanFields[7] eq "Q")){
		next NEXTLINE;
	}
	if (($SpanFields[0] eq "nReq")&&($SpanFields[7] eq "O")){
		next NEXTLINE;
	}
#	if ($SpanFields[5] eq "CCL"){
#		$METHOD = $SpanFields[5];
#	}
#	else{
#		$METHOD = $SpanFields[10];
#	}
	$METHOD = $SpanFields[10];
	$METHOD =~ s/^\s+|\s+$//g;
	


	$ACCODE = $SpanFields[6];
	chomp($ACCODE);		
	$ACCODE =~ s/^\s+|\s+$//g;
	$strFind = " ";
	$strReplace = "";
	$ACCODE =~ s/$strFind/$strReplace/gi;


	$COMB_CODE = $SpanFields[11];
	chomp($COMB_CODE);		
	$COMB_CODE =~ s/^\s+|\s+$//g;
	
	$CURRCODE = $SpanFields[12];
	chomp($CURRCODE);		
	$CURRCODE =~ s/^\s+|\s+$//g;
	
#	$COMB_EXCH = substr($_,151,6);
#	chomp($COMB_EXCH);		
#	$COMB_EXCH =~ s/^\s+|\s+$//g;
	
	$COMB_MAINT = $SpanFields[17]+0;
	$NOV = $SpanFields[18]+0;
	if ($SpanFields[0] eq "nReq"){
		$SCANRISK = $SpanFields[19]+0;
		$IMS = $SpanFields[20]+0; #inter-month Spread
		$ICS = $SpanFields[22]+0;	#inter-commodity Spread
		$IEX = $SpanFields[23]+0;
		$ICS = $ICS+$IEX;
		$SOM = $SpanFields[24]+0;	#Short Option Minimum
	}
	else{
		$SCANRISK = 0;
		$IMS = 0; #inter-month Spread
		$ICS = 0;	#inter-commodity Spread
		$SOM = 0;	#Short Option Minimum
	}
	
	$SPANKey = $METHOD.$ACCODE.$COMB_CODE.$CURRCODE;
		



	if(exists $mgResults{$SPANKey}){
			my @arrResults=split(',',$mgResults{$SPANKey});				#$COMB_MAINT.",".$NOV.",".$SCANRISK.",".$IMS.",".$ICS.",".$SOM;
			my $diffTotal = $COMB_MAINT - $arrResults[0];
			$diffTotal = abs($diffTotal);
			my $diffNOV = $NOV - $arrResults[1];
			$diffNOV = abs($diffNOV);
			my $diffSOM = $SOM - $arrResults[5];
			$diffSOM = abs($diffSOM);				
			#if (($diffTotal>1)||($diffNOV>1)||($diffSOM>1)){
			if ($diffTotal>10){
				print WRITECSV "$METHOD,$ACCODE,$COMB_CODE,$CURRCODE,$COMB_MAINT,$NOV,$SCANRISK,$IMS,$ICS,$SOM,$arrResults[0],$arrResults[1],$arrResults[2],$arrResults[3],$arrResults[4],$arrResults[5],$diffTotal,$diffNOV,$diffSOM \n";
			}
			else{
				print WRITECSVALL "$METHOD,$ACCODE,$COMB_CODE,$CURRCODE,$COMB_MAINT,$NOV,$SCANRISK,$IMS,$ICS,$SOM,$arrResults[0],$arrResults[1],$arrResults[2],$arrResults[3],$arrResults[4],$arrResults[5],$diffTotal,$diffNOV,$diffSOM \n";
			}
			delete $mgResults{$SPANKey};
	}
	else{
			
			
			if ($COMB_MAINT eq 0) {	
			#print "$SPANKey NOT FOUND UNDER PC Span report \n";
			}
			else{
				print "$SPANKey not found under ".$run_id."CLCF2 \n";
			}
			
	}
}
close WRITECSV;
close WRITECSVALL;
close PCSPANFILE;


my $count = scalar(keys %mgResults);
if ($count >0){
	print "---------------------------------------------------------------- \n";
	while( my( $key, $value ) = each %mgResults ){
		my @arrResults=split(',',$value);				#$COMB_MAINT.",".$NOV.",".$SCANRISK.",".$IMS.",".$ICS.",".$SOM;
		
		if ($arrResults[0]>0) {
			print "$key not found under PC SPAN \n";
		}
	}
}
print "Compare completed successfully. \n";

#sleep();