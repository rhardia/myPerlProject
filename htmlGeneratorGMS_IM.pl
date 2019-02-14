#!/usr/bin/perl
use warnings;
$| = 1;

my $strDir = $ARGV[0];
my $filename = $ARGV[1];
my $runid = $ARGV[2];
my $lineCount = 0;
my $logPath;
my $csvPath = $strDir."\\".$filename;
my %csvIndex;
open (CSVFILE, "<$csvPath");
my $htmlFile = $csvPath;
my $strFind = "CSV";
my $strReplace = "htm";
$htmlFile=~ s/$strFind/$strReplace/gi;

open (HTMFILE, "> $htmlFile");

my $i = 0;
#''''''''''''''''''''''''''''''''''''''''''''''Generate HTML content''''''''''''''''''''''''''''''''''''''''''''''''''
my $txtHTML = "";

print HTMFILE "<TABLE ><TR><TD><b><center>Following is the Difference Report for PCSpan and GMS for <TD bgcolor=yellow><font color=red><b> $runid </b></font></TD></center></TD></TR><TR><TD>&nbsp;</TD></TR></TABLE>";
# print HTMFILE "<TABLE ><TR><TD><b><center>Note: Account = [Firm][Office][AccountCode][Sub-AccountCode]</center></TD></TR><TR><TD>&nbsp;</TD></TR></TABLE>";
$logPath = $strDir."\\GMSDIFF.log" ;

print HTMFILE "<TABLE border=1>";
my @fields;
while ( <CSVFILE> ){
	$_ =~ s/^\s+|\s+$//g;
	@fields = split(',',$_);
	if (index($_,"Account") != -1) {
		print HTMFILE "<TR bgcolor='blue'>";
		foreach $field (@fields){
			$field =~ s/^\s+|\s+$//g;
			print HTMFILE "<TD><font color=white><center><b> $field </center></font></TD>";
			$csvIndex{$field}=$i;
			$i=$i+1;
		}
		print HTMFILE "</TR>";
	}
	else{
		print HTMFILE "<TR>";
		my $ubound = $#fields;
		for($i=0;$i<=$ubound;$i++){
			
			if(($i eq $csvIndex{"SPAN Init Margin"})||($i eq $csvIndex{"GMS Init Margin"})){
				if ($fields[$csvIndex{"Diff Init Margin"}]>0){print HTMFILE "<TD bgcolor=yellow><font color=black><right><p style=padding:0; margin:0;> $fields[$i] </p></right></font></TD>" ;}
				else {print HTMFILE "<TD><font color=blue><right><p style=padding:0; margin:0;> $fields[$i] </p></right></font></TD>" ;}
			}
			elsif(($i eq $csvIndex{"SPAN NOV"})||($i eq $csvIndex{"GMS NOV"})){
				if ($fields[$csvIndex{"Diff NOV"}]>0){print HTMFILE "<TD bgcolor='#FF6699'><font color=black><right><p style=padding:0; margin:0;> $fields[$i] </p></right></font></TD>" ;}
				else {print HTMFILE "<TD><font color=blue><right><p style=padding:0; margin:0;> $fields[$i] </p></right></font></TD>" ;}
			}
			elsif($i eq $csvIndex{"Diff NOV"}){
				if ($fields[$csvIndex{"Diff NOV"}]>0){print HTMFILE "<TD bgcolor='#FF6699'><font color=black><right><p style=padding:0; margin:0;> $fields[$i] </p></right></font></TD>" ;}
				else {print HTMFILE "<TD><font color=blue><right><p style=padding:0; margin:0;> $fields[$i] </p></right></font></TD>" ;}
			}
			elsif($i eq $csvIndex{"Diff Init Margin"}){
				if ($fields[$csvIndex{"Diff Init Margin"}]>0){print HTMFILE "<TD bgcolor=yellow><font color=black><right><p style=padding:0; margin:0;> $fields[$i] </p></right></font></TD>" ;}
				else {print HTMFILE "<TD><font color=blue><right><p style=padding:0; margin:0;> $fields[$i] </p></right></font></TD>" ;}
			}			
			else {
				print HTMFILE "<TD><font color=blue><right><p style=padding:0; margin:0;> $fields[$i] </p></right></font></TD>" ;
			}
		
		}
		print HTMFILE "</TR>";
		$lineCount = $lineCount + 1 ;
	}
}
print HTMFILE "</TABLE>";

print HTMFILE "<TABLE ><TR><TD><b> $lineCount Differences found</TD></TR><TR><TD>&nbsp;</TD></TR>";
close CSVFILE ;
open (CSVFILE, "<$logPath");
while ( <CSVFILE> ){
	$_ =~ s/^\s+|\s+$//g;
	print HTMFILE "<TR><TD> $_ </TD></TR>"
}
print HTMFILE "</TABLE>";
close HTMFILE ;
close CSVFILE ;