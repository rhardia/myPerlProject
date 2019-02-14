#!/usr/bin/perl
use warnings;
$| = 1;

my $runID = lc($ARGV[0]);
my $dir = uc($ARGV[0]);
my $filename = $ARGV[1]."\\ftp.txt";

if ($runID eq "smx") {$dir = "SIMX";}
if ($runID eq "tfx") {$dir = "TIFF";}
#''''''''''''''''''''''''''''''''''''''''''''''Generate FTP content''''''''''''''''''''''''''''''''''''''''''''''''''
open (FTPFILE, "> $filename");
	print FTPFILE "open ieshop1\n";
	print FTPFILE "WSGCSUSA\n";
	print FTPFILE "1cesh0m1nc\n";
	print FTPFILE "bin\n";
	print FTPFILE "mget $dir/yesterday/$runID.*-z\n";
	print FTPFILE "Y\n";
	print FTPFILE "Y\n";
	print FTPFILE "Y\n";
	print FTPFILE "Y\n";
	print FTPFILE "quit";
close FTPFILE ;