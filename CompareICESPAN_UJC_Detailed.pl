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
my $filename = $run_id."_results_ICE.csv";
my $csv_file = "SPA_rp_dtl_cctot_".$run_id.".csv";
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

$diffFile = $cwd."\\".$run_id."SPAN_UJC_DIFF.CSV";
$fileAll = $cwd."\\".$run_id."SPAN_UJC_MATCHED.CSV";

open (CSV, "<$csv_file");

LINE: while ( <CSV> ){
	$strFind = "\"";
	$strReplace = "";
	$_ =~ s/$strFind/$strReplace/gi;
	chomp;
	
	$_ =~ s/^\s+|\s+$//g;
	@fields = split /;/, $_;

	$account=$fields[3].$fields[4];
	$account =~ s/^\s+|\s+$//g;  #trim($account)
	chomp($account);

	
	$strFind = " ";
	$strReplace = "";
	$account =~ s/$strFind/$strReplace/gi;
	
	if (($account eq "AcctcodeSubPort")||($account eq "")){
		next LINE;
	}
	
	$combineCode=$fields[8];
	chomp($combineCode);
	$combineCode =~ s/^\s+|\s+$//g;  #trim($combineCode)
	

	$currency=$fields[9];
				

	$dbkey = $account.$combineCode.$currency;

	my $GMIIM = $fields[27]+0;
	my $GMIMM = $fields[25]+0;
	my $GMIRISK = $fields[10]+0;
	my $GMIIMS = $fields[12]+0;
	my $GMIICS = $fields[14]+0;
	my $GMISOM = $fields[15]+0;
	my $GMINOV = $fields[18]+0;
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
		$GMIIM = $GMIIM + $arrResults[1];
		$GMIRISK = $GMIRISK + $arrResults[2];
		$GMIIMS = $GMIIMS + $arrResults[3];
		$GMIICS = $GMIICS + $arrResults[4];
		$GMISOM = $GMISOM + $arrResults[5];
		#print $dbkey ." Exists \n";
	}
	$mgResults{$dbkey} = $GMIMM.",".$GMIIM.",".$GMIRISK.",".$GMIIMS.",".$GMIICS.",".$GMISOM;
}
close CSV;
################################################################################################################################################################################################
######################################### READING ICE SPAN FILE AND COMPARE ######################################################################
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


open (ICESPANFILE, "<$filename");

open (WRITECSV, "> $diffFile");	#$COMB_MAINT.",".$NOV.",".$SCANRISK.",".$IMS.",".$ICS.",".$SOM;
open (WRITECSVALL, "> $fileAll");	#$COMB_MAINT.",".$NOV.",".$SCANRISK.",".$IMS.",".$ICS.",".$SOM;

print WRITECSV "Account,Combine Comm Code,Currency,SPAN Maint Margin,SPAN Init Margin, SPAN RISK, SPAN IMS,SPAN ICS,SPAN SOM,GMI Maint Margin,GMI Init Margin,GMI RISK, GMI IMS,GMI ICS,GMI SOM,Diff Maint Margin,Diff Init Margin,Diff SOM \n";
print WRITECSVALL "Account,Combine Comm Code,Currency,SPAN Maint Margin,SPAN Init Margin, SPAN RISK, SPAN IMS,SPAN ICS,SPAN SOM,GMI Maint Margin,GMI Init Margin,GMI RISK, GMI IMS,GMI ICS,GMI SOM,Diff Maint Margin,Diff Init Margin,Diff SOM \n";


NEXTLINE: while ( <ICESPANFILE> ){
	chomp;
	$_ =~ s/^\s+|\s+$//g;

#	$strFind = " ";
#	$strReplace = "";
#	$_ =~ s/$strFind/$strReplace/gi;
#	chomp;
	
	@SpanFields = split /,/, $_;
	

#	$METHOD = $SpanFields[10];
#	$METHOD =~ s/^\s+|\s+$//g;
	

	if ($SpanFields[1] eq "CombinedContract") {
		next NEXTLINE;
	}
	$ACCODE = $SpanFields[0];
	chomp($ACCODE);		
	$ACCODE =~ s/^\s+|\s+$//g;
	$strFind = " ";
	$strReplace = "";
	$ACCODE =~ s/$strFind/$strReplace/gi;
	$strReplace = "";
	$ACCODE =~ s/\*/$strReplace/gi;

	$COMB_CODE = $SpanFields[1];
	chomp($COMB_CODE);		
	$COMB_CODE =~ s/^\s+|\s+$//g;
	
	$CURRCODE = $SpanFields[2];
	chomp($CURRCODE);		
	$CURRCODE =~ s/^\s+|\s+$//g;
	
#	$COMB_EXCH = substr($_,151,6);
#	chomp($COMB_EXCH);		
#	$COMB_EXCH =~ s/^\s+|\s+$//g;
	
	$COMB_MAINT = abs($SpanFields[10]+0);
	$COMB_INIT = abs($SpanFields[14]+0);
		$SCANRISK = abs($SpanFields[4]+0);
		$IMS = abs($SpanFields[6]+0); #inter-month Spread
		$ICS = abs($SpanFields[8]+0);	#inter-commodity Spread
		$SOM = abs($SpanFields[9]+0);	#Short Option Minimum
	
	$SPANKey = $ACCODE.$COMB_CODE.$CURRCODE;
	$strReplace = "";
	$SPANKey =~ s/\*/$strReplace/gi;	



	if(exists $mgResults{$SPANKey}){
			my @arrResults=split(',',$mgResults{$SPANKey});				#$COMB_MAINT.",".$NOV.",".$SCANRISK.",".$IMS.",".$ICS.",".$SOM;
			my $diffMaint = $COMB_MAINT - $arrResults[0];
			$diffMaint = abs($diffMaint);
			my $diffIM = $COMB_INIT - $arrResults[1];
			$diffIM = abs($diffIM);
			my $diffSOM = $SOM - $arrResults[5];
			$diffSOM = abs($diffSOM);				
			#if (($diffTotal>1)||($diffNOV>1)||($diffSOM>1)){
			if ($diffMaint>10){
				print WRITECSV "$ACCODE,$COMB_CODE,$CURRCODE,$COMB_MAINT,$COMB_INIT,$SCANRISK,$IMS,$ICS,$SOM,$arrResults[0],$arrResults[1],$arrResults[2],$arrResults[3],$arrResults[4],$arrResults[5],$diffMaint,$diffIM,$diffSOM \n";
			}
			else{
				print WRITECSVALL "$ACCODE,$COMB_CODE,$CURRCODE,$COMB_MAINT,$COMB_INIT,$SCANRISK,$IMS,$ICS,$SOM,$arrResults[0],$arrResults[1],$arrResults[2],$arrResults[3],$arrResults[4],$arrResults[5],$diffMaint,$diffIM,$diffSOM \n";
			}
			delete $mgResults{$SPANKey};
	}
	else{
			
			
			if ($COMB_MAINT eq 0) {	
			#print "$SPANKey NOT FOUND UNDER PC Span report \n";
			}
			else{
				print "$SPANKey not found under ".$csv_file."\n";
			}
			
	}
}
close WRITECSV;
close WRITECSVALL;
close ICESPANFILE;


my $count = scalar(keys %mgResults);
if ($count >0){
	print "---------------------------------------------------------------- \n";
	while( my( $key, $value ) = each %mgResults ){
		my @arrResults=split(',',$value);				#$COMB_MAINT.",".$NOV.",".$SCANRISK.",".$IMS.",".$ICS.",".$SOM;
		
		if ($arrResults[0]>0) {
			print "$key not found under SPAN for ICE \n";
		}
	}
}
print "Compare completed successfully. \n";

#sleep();