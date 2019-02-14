#! /usr/bin/perl
# use warnings;
#$| = 1;
my %mgResults;
my %mgResults1;
my %mgAccounts;
my $cwd;
my $run_id1 = $ARGV[0];
my $run_id2 = $ARGV[1];

	if ($ARGV[1] ne ""){
		$cwd = $ARGV[1]
	}
	else{
		$cwd = "C:\\GMS_GMI\\wrkdir";
	}
my $mg_file1 = "mg_".$run_id1.".gms";
my $mg_file2 = "mg_".$run_id2.".gms";
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

$diffFile = $cwd."\\".$run_id."SPAN_GMS_DIFF.CSV";
$fileAll = $cwd."\\".$run_id."SPAN_GMS_MATCHED.CSV";


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
		$COMB_MAINT = $COMB_MAINT + $prevResults[0];
		$NOV = $NOV + $prevResults[1];
		$mgResults{$GMSKey} = $COMB_MAINT.",".$NOV;
	}
	else{
		$mgResults{$GMSKey} = $COMB_MAINT.",".$NOV;
	}
		
}
close MGFILE;
# print "Margin file load completed ...\n";
