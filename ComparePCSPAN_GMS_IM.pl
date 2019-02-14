#! /usr/bin/perl
# use warnings;
#$| = 1;
my %mgResults;
my %mgAccounts;
my $cwd;
my $run_id = $ARGV[0];
	if ($ARGV[1] ne ""){
		$cwd = $ARGV[1]
	}
	else{
		$cwd = "C:\\GMS_GMI\\wrkdir";
	}
my $filename = $run_id."PbReq.csv";
my $mg_file = "mg_".$run_id.".gms";
my $diffFile;
my $fileAll;
my $tmpFile;
my $strFind;
my $strReplace;
my $cmd;
my $currency;
my $SPANKey;
# my $scriptDir = "C:\\GMS_GMI";
my @arrValues;
my @arrResults;
chdir($cwd);

$diffFile = $cwd."\\".$run_id."SPAN_GMS_IM_DIFF.CSV";
$fileAll = $cwd."\\".$run_id."SPAN_GMS_IM_MATCHED.CSV";


###########################################################################################################################################################################
###########################################################################################################################################################################
# GMS mg file load
###########################################################################################################################################################################
###########################################################################################################################################################################

my $LINK_NUM;
my $tmpFile;
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

$cmd = "findstr -r \"^[A-Z][A-Z][A-Z]100\" ". $mg_file ." > TMP100.txt";
system($cmd);
$tmpFile = "TMP100.txt";
open (MGFILE, "<$tmpFile");
NEXTLINK: while ( <MGFILE> ){
	chomp;
	$_ =~ s/^\s+|\s+$//g;
	$LINK_NUM = substr($_,6,6);
	chomp($LINK_NUM);
	if(exists $mgAccounts{$LINK_NUM}){
		next NEXTLINK;
	}
	$ACCODE = substr($_,12,20);
	chomp($ACCODE);
	$ACCODE =~ s/^\s+|\s+$//g;
	$strFind = " ";
	$strReplace = "";
	$ACCODE =~ s/$strFind/$strReplace/gi;
	if($ACCODE eq ""){
		$mgAccounts{$LINK_NUM}=$LINK_NUM;
	}
	else{	
		$mgAccounts{$LINK_NUM}=$ACCODE;
	}
}
close MGFILE;
$cmd = "findstr -r \"^[A-Z][A-Z][A-Z]032\" ". $mg_file ." > TMP032.txt";
# print "Creating temporary file TMP032.txt ...\n";
system($cmd);
$mg_file = "TMP032.txt";
open (MGFILE, "<$mg_file");
while ( <MGFILE> ){
	chomp;
	$_ =~ s/^\s+|\s+$//g;
	
	$LINK_NUM = substr($_,6,6);
	chomp($LINK_NUM);
	
	$ACCODE = $mgAccounts{$LINK_NUM};
	
	$METHOD = substr($_,0,3);
	
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
#	if ($METHOD eq "CCL"){$GMSKey = $METHOD.$ACCODE.$COMB_CODE.$CURRCODE.$COMB_EXCH;}
#	else{$GMSKey = $METHOD.$ACCODE.$COMB_CODE.$CURRCODE;}
	$GMSKey = $METHOD.$ACCODE.$COMB_CODE.$CURRCODE;	
	if(exists $mgResults{$GMSKey}){
		my @prevResults=split(',',$mgResults{$GMSKey});
		$COMB_INIT = $COMB_INIT + $prevResults[0];
		$NOV = $NOV + $prevResults[1];
		$mgResults{$GMSKey} = $COMB_INIT.",".$NOV;
	}
	else{
		$mgResults{$GMSKey} = $COMB_INIT.",".$NOV;
	}
		
}
close MGFILE;
# print "Margin file load completed ...\n";

################################################################################################################################################################################################
######################################### READING PC SPAN FILE AND COMPARE ######################################################################
################################################################################################################################################################################################
my $SPANKey;
my $SCANRISK;
my $IMS;
my $ICS;
my $IXS;
my $SOM;

$cmd = "findstr -r -c:dReq ". $filename ." > Req.txt";
system($cmd);
#$cmd = "findstr -v -c:\"Q\" nReq.txt  > Req.txt";
#system($cmd);
#$cmd = "findstr -r -c:gReq ". $filename ." >> Req.txt";
#system($cmd);
$filename = "Req.txt";
open (PCSPANFILE, "<$filename");

open (WRITECSV, "> $diffFile");	#$COMB_INIT.",".$NOV.",".$SCANRISK.",".$IMS.",".$ICS.",".$SOM;
open (WRITECSVALL, "> $fileAll");	#$COMB_INIT.",".$NOV.",".$SCANRISK.",".$IMS.",".$ICS.",".$SOM;

print WRITECSV "SPAN Method Code,Account,Combine Comm Code,Currency,SPAN Init Margin,SPAN NOV,GMS Init Margin,GMS NOV,Diff Init Margin,Diff NOV \n";
print WRITECSVALL "SPAN Method Code,Account,Combine Comm Code,Currency,SPAN Init Margin,SPAN NOV,GMS Init Margin,GMS NOV,Diff Init Margin,Diff NOV \n";

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
	
#	if (($SpanFields[0] eq "nReq")&&($SpanFields[7] eq "Q")){
#		next NEXTLINE;
#	}
	
#	if (($SpanFields[0] eq "nReq")&&($SpanFields[7] eq "O")){
#		next NEXTLINE;
#	}


#	if (($SpanFields[5] eq "CCL")&&($SpanFields[10] ne "MGE")){
#		$METHOD = $SpanFields[5];
#	}
#	else{
		$METHOD = $SpanFields[10];
#	}
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
	
	$COMB_INIT = $SpanFields[17]+0;
	$NOV = $SpanFields[18]+0;
	if ($SpanFields[0] eq "nReq"){
		$SCANRISK = $SpanFields[19]+0;
		$IMS = $SpanFields[20]+0; #inter-month Spread
		$ICS = $SpanFields[22]+0;	#inter-commodity Spread
		$IXS = $SpanFields[23]+0;	#inter-exchange Spread
		$ICS = $ICS+$IXS;
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
			my @arrResults=split(',',$mgResults{$SPANKey});				#$COMB_INIT.",".$NOV.",".$SCANRISK.",".$IMS.",".$ICS.",".$SOM;
			my $diffMaint = $COMB_INIT - $arrResults[0];
			$diffMaint = abs($diffMaint);
			my $diffNOV = $NOV - $arrResults[1];
			$diffNOV = abs($diffNOV);
			#if (($diffTotal>1)||($diffNOV>1)||($diffSOM>1)){
			if ($diffMaint>10){
				print WRITECSV "$METHOD,$ACCODE,$COMB_CODE,$CURRCODE,$COMB_INIT,$NOV,$arrResults[0],$arrResults[1],$diffMaint,$diffNOV \n";
			}
			else{
				print WRITECSVALL "$METHOD,$ACCODE,$COMB_CODE,$CURRCODE,$COMB_INIT,$NOV,$arrResults[0],$arrResults[1],$diffMaint,$diffNOV \n";
			}
			delete $mgResults{$SPANKey};
	}
	else{
			if ($COMB_INIT eq 0) {	
			#print "$SPANKey NOT FOUND UNDER PC Span report \n";
			}
			else{
				print "$SPANKey not found under GMS \n";
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
		my @arrResults=split(',',$value);				#$COMB_INIT.",".$NOV.",".$SCANRISK.",".$IMS.",".$ICS.",".$SOM;
		
		if ($arrResults[0]>0) {
			print "$key not found under PC Span \n";
		}
	}
}