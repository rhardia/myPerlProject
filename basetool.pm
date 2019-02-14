#--------------------------------------------------------------------------
#	File:		basetool.pm
#       Author:         Peter M. Hollenstein
#
#Job No Date	Author	Description
#--------------------------------------------------------------------------
package basetool;

use strict;
no strict 'refs';
use vars qw($VERSION);

use IO::File;
use IO::Handle;	
use File::Basename;

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
$VERSION = '0.17';
1;

#--------------------------------------------------------------------------
sub new
{
	my $class = shift;
	my %arg   = @_;
	my $self  = {};
	if (defined $arg{cfg})    { $self->{CFG}        = $arg{cfg};     } else { $self->{CFG}        = "default.cfg";  }
	if (defined $arg{ldlevel}){ $self->{LDLEVEL}    = $arg{ldlevel}; } else { $self->{LDLEVEL}    = 0;              }
	if (defined $arg{debug})  { $self->{debug_file} = $arg{debug};   } else { $self->{debug_file} = "basetool.dbg"; }
	$self->{DBG_LOG} = new IO::File;
	$self->{LOG_FIL} = new IO::File;
	$self->{CONFIG_PARAM} = ();
	bless( $self, $class );
	return $self;
}
#--------------------------------------------------------------------------
sub cfg_param
{
 my $self = shift;
 my %arg  = @_;
 my $para = $arg{parameter};
 if (defined $arg{value}) { $self->{CONFIG_PARAM}{$para} = $arg{value} }
 return $self->{CONFIG_PARAM}{$para};
}
#--------------------------------------------------------------------------
sub get_param
{
 my $self = shift;
 my %arg  = @_;
 my $para = $arg{parameter};
 if (defined $arg{value}) { $self->{$para} = $arg{value} }
 return $self->{$para};
}
#--------------------------------------------------------------------------
sub find_param
{
 my $self = shift;
 my %arg  = @_;
 my @result;
 for my $data (keys %{$self}) { if ($data =~ /$arg{pattern}/) { push @result,$data; } }
 return @result;
}
#--------------------------------------------------------------------------
sub find_cfg_param
{
 my $self = shift;
 my %arg  = @_;
 my @result;
 for my $data (keys %{$self->{CONFIG_PARAM}}) { if ($data =~ /$arg{pattern}/) { push @result,$data; } }
 return @result;
}
#--------------------------------------------------------------------------
sub get_cwd
{
 my $self = shift;
 my $cwd;
 if ($^O eq "MSWin32")     { $cwd = `cd`; }
 else                      { $cwd = `pwd`; }
 chop $cwd;
 return $cwd;
}
#------------------------------------------------------------------------------
sub get_env_var
{
 my $self = shift;
 my %arg  = @_;
 my $env  = $arg{env};
 if (defined $arg{value}) { $ENV{$env} = $arg{value} };
 return $ENV{$env};
}
#--------------------------------------------------------------------------
sub file_exists
{
 my $self  = shift;
 my %arg   = @_;
 my $dir;
 if (defined $arg{dir}) {$dir = $arg{dir}; } else  {$dir = $self->get_cwd; }
 my $file  = $arg{file};
 my $info  = uc($arg{info});
 if ( "$info" ne "Y" && "$info" ne "N" ) { $info = "Y"; }
 $self->debug_info("in file_exists for file $dir $file $info");
 my $fullname=$self->comb_dir_file(dir=>$dir,file=>$file);
 if ( -e $fullname ) 
    { if ( "$info" eq "Y" ) { $self->print_log("file $fullname exists")    ; } return 1; } 
 else 
    { if ( "$info" eq "Y" ) { $self->print_log("file $fullname is missing"); } return 0; }
 return 0;
}
#--------------------------------------------------------------------------
sub file_size
{
 my $self = shift;
 my %arg  = @_;
 my $dir;
 if (defined $arg{dir}) {$dir = $arg{dir}; } else  {$dir = $self->get_cwd; }
 my $file  = $arg{file};
 my ($d1,$i1,$m1,$n1,$u1,$g1,$r1,$s1,$a1,$m1,$c1,$b1,$z1);
 $self->debug_info("in file_size for file $dir $file");
 my $fullname=$self->comb_dir_file(dir=>$dir,file=>$file);
 ($d1,$i1,$m1,$n1,$u1,$g1,$r1,$s1,$a1,$m1,$c1,$b1,$z1) = stat($fullname);
 $self->debug_info("File Size for $fullname is $s1");
 return $s1;
}
#--------------------------------------------------------------------------
sub file_remove
{
 my $self = shift;
 my %arg   = @_;
 my $dir   = $arg{dir};
 my $file  = $arg{file};
 my $info  = uc($arg{info});
 if ( "$info" ne "Y" && "$info" ne "N" ) { $info = "Y"; }
 $self->debug_info("in file_remove for file $dir $file $info");
 my $fullname=$self->comb_dir_file(dir=>$dir,file=>$file);
 if ( -e $fullname )
    { unlink $fullname;
      if ( -e $fullname ) { $self->print_log("Error: $fullname remove failed!"); return; } 
      else { if ("$info" eq "Y") { $self->print_log("$fullname removed successfully"); } }
    }
 else
    { if ("$info" eq "Y") { $self->print_log("$fullname not found. Nothing to delete"); } }
 return;
}
#--------------------------------------------------------------------------
sub file_copy
{
 my $self = shift;
 my %arg   = @_;
 my $dir   = $arg{olddir};
 my $file  = $arg{oldname};
 my $ndir;
 if (defined $arg{newdir})    { $ndir=$arg{newdir}; } else { $ndir = $arg{olddir}; }
 my $nfile = $arg{newname};
 my $info  = uc($arg{info});
 my $softLink  = uc($arg{softLink});
 my $tmpfil= uc($arg{tempfile});
 my ($command,$commandend);
 if ( $info ne "Y" && $info ne "N" ) { $info = "Y"; }
 if ( $tmpfil ne "Y" ) { $tmpfil = "N"; }
 $self->debug_info("in file_copy for file $dir $file $ndir $nfile $info $tmpfil");
 my $fullname=$self->comb_dir_file(dir=>$dir,file=>$file);
 my $nullname=$self->comb_dir_file(dir=>$ndir,file=>$nfile);
 my $tempname=$nullname."_tmp";
 if ($tmpfil eq "Y" && -e $tempname ) 
    { unlink $tempname;
      if ( -e $tempname ) { $self->print_log("Error: $tempname remove failed!"); return; }
    }
 if ($^O eq "MSWin32")  { $command = "copy"; $commandend = " >NUL:"; } 
 else{ 
		if ($softLink eq "Y") {$command = "ln -s";}
		else {$command = "cp";}
	}
 if ($tmpfil eq "Y" && -e $fullname)
    { $command=$command." ".$fullname." ".$tempname.$commandend;
      system($command);
      $self->file_rename(olddir=>$ndir,oldname=>$nfile."_tmp",newname=>$nfile);
    }
 if ($tmpfil ne "Y")
    { if ( -e $nullname )
         { unlink $nullname;
           if ( -e $nullname ) { $self->print_log("Error: $nullname remove failed!"); return; }
         }
      if ( -e $fullname ) { }
      else { $self->print_log("$fullname does not exist"); }
      $command=$command." ".$fullname." ".$nullname.$commandend;
      system($command);
    }
 if ( -e $nullname ) { if ("$info" eq "Y") { $self->print_log("$fullname copied to $nullname successfully"); } }
 else                { if ("$info" eq "Y") { $self->print_log("$fullname copied to $nullname failed"); } }
 return;
}
#--------------------------------------------------------------------------
sub file_rename
{
 my $self = shift;
 my %arg   = @_;
 my $dir   = $arg{olddir};
 my $file  = $arg{oldname};
 my $ndir;
 if (defined $arg{newdir})    { $ndir=$arg{newdir}; } else { $ndir = $arg{olddir}; }
 my $nfile = $arg{newname};
 my $info  = uc($arg{info});
 if ( "$info" ne "Y" && "$info" ne "N" ) { $info = "Y"; }
 $self->debug_info("in file_rename for file $dir $file $ndir $nfile $info");
 my $fullname=$self->comb_dir_file(dir=>$dir,file=>$file);
 my $nullname=$self->comb_dir_file(dir=>$ndir,file=>$nfile);
 if ( -e $nullname )
    { unlink $nullname;
      if ( -e $nullname ) { $self->print_log("Error: $nullname remove failed!"); return; }
    }
 if ( -e $fullname )
    { }
     else { $self->print_log("$fullname does not exist"); }
 rename($fullname,$nullname);
 if ( -e $nullname )
      { if ("$info" eq "Y") { $self->print_log("$fullname renamed to $nullname successfully"); } }
 else
      { if ("$info" eq "Y") { $self->print_log("$fullname rename to $nullname failed"); } }
 return;
}
#--------------------------------------------------------------------------
sub comb_dir_file
{
 my $self=shift;
 my %arg = @_;
 my $dir=$arg{dir};
 my $file=$arg{file};
 my $dir_sep="/";
 if ($^O eq "MSWin32")     { $dir_sep  = "\\"; }
 my $dirfile=$dir.$dir_sep.$file;
 return $dirfile;
}
#--------------------------------------------------------------------------
sub calc_busday
{
 my $self = shift;
 my %arg=@_;
 my $calc_base;
 if (defined $arg{day}) { $calc_base = $arg{day}; } else { $calc_base = 0; }
 my ($year,$month,$day,$sqlyear,$sqlmth);
 my %month_trans =("01","JAN","02","FEB","03","MAR","04","APR","05","MAY","06","JUN","07","JUL","08","AUG","09","SEP","10","OCT","11","NOV","12","DEC");
 $self->debug_info("in calc_busday with $calc_base");
 if ($calc_base == 1 || $calc_base == 0)
  { my $seconds_var = time();
    my @time_var;
    @time_var = localtime($seconds_var);
    if ($calc_base == 1) 
       {
        if    ($time_var[6] == 1) { $seconds_var -= (3 * 86400); } # Monday - Subtract 3 days
        elsif ($time_var[6] == 0) { $seconds_var -= (2 * 86400); } # Sunday - Subtract 2 days
        else  {$seconds_var -= 86400; }                            # Subtract 1 day for any other situation
       }
    @time_var = localtime($seconds_var);
    if( $time_var[5] >= 100 ) { $year = substr($time_var[5], 1, 2); } else { $year = $time_var[5]; }
    $month = sprintf("%02d",$time_var[4]+1);
    $day   = sprintf("%02d",$time_var[3]);
  }
 else
  {
    $year  = sprintf("%02d",substr($calc_base,0,2));
    $month = sprintf("%02d",substr($calc_base,2,2));
    $day   = sprintf("%02d",substr($calc_base,4,2));
  }
 $sqlyear = $year+2000;
 $sqlyear = sprintf("%04d",$sqlyear);
 $sqlmth  = sprintf("%3s",$month_trans{$month});
 my ($busdate) = sprintf("%s-%s-%s",$sqlyear,$month,$day);
 $self->debug_info("Date Calculated: Year:<$sqlyear> Month:<$sqlmth> Day:<$day> Busdate:<$busdate>");
 $self->cfg_param(parameter=>"YEAR",value=>$sqlyear);
 $self->cfg_param(parameter=>"SYEAR",value=>substr($sqlyear,2,2));
 $self->cfg_param(parameter=>"MONTH",value=>$sqlmth);
 $self->cfg_param(parameter=>"NMONTH",value=>$month);
 $self->cfg_param(parameter=>"DAY",value=>$day);
 $self->cfg_param(parameter=>"BUSDATE",value=>$busdate);
 return;
}
#------------------------------------------------------------------------------
sub display_time
{
 my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
 $year += 1900;
 $mon  +=    1;
 my $value = sprintf("%04d-%02d-%02d %02d:%02d:%02d",$year,$mon,$mday,$hour,$min,$sec);
 return $value;
}
#------------------------------------------------------------------------------
sub print_log
{
 my $self=shift;
 my $message=shift;
 my $onscreen=uc(shift);
 if ($onscreen ne "Y") { $onscreen = "N"; };
 my $dtime=&display_time();
 my $lh;
 $lh = select("$self->{LOG_FIL}");
 $|  = 1;
 select($lh);
 my $pf = $self->{LOG_FIL};
 printf $pf "$dtime $message\n";
 $pf->autoflush;
 if ($onscreen eq "Y") { print "$dtime $message\n"; }
 return;
}
#--------------------------------------------------------------------------
sub close_log_file
{
 my $self = shift;
 close( $self->{LOG_FIL} );
 return;
}
#--------------------------------------------------------------------------
sub open_log_file
{
 my $self = shift;
 $self->close_log_file;
 my $append = $self->{CONFIG_PARAM}{LOG_APPEND};
 $append = uc($append);
 if ($append ne "Y")
   {
    my $oldfilename=$self->{CONFIG_PARAM}{LOG_FILE}.".bak";
    my $check=$self->file_exists(dir=>$self->{CONFIG_PARAM}{LOG_DIR},file=>$self->{CONFIG_PARAM}{LOG_FILE},info=>"N");
    if ($check == 1)
       {
        $self->file_rename(olddir=>$self->{CONFIG_PARAM}{LOG_DIR},oldname=>$self->{CONFIG_PARAM}{LOG_FILE},newname=>$oldfilename,info=>"N");
       }
   }
 my $fullname=$self->comb_dir_file(dir=>$self->{CONFIG_PARAM}{LOG_DIR},file=>$self->{CONFIG_PARAM}{LOG_FILE});
 $self->{LOG_FIL} = IO::File->new(">>$fullname") || die ("Unable to open Log file ($fullname): $!");
 return;
}
#--------------------------------------------------------------------------
sub close_debug_file
{
 my $self = shift;
 close( $self->{DBG_LOG} );
 return;
}
#--------------------------------------------------------------------------
sub open_debug_file
{
 my $self = shift;
 $self->close_debug_file;
 my $oldfilename=$self->{debug_file}.".bak";
 my $dbg_dir;
 if (defined $self->{CONFIG_PARAM}{DEBUG_DIR}) { $dbg_dir=$self->{CONFIG_PARAM}{DEBUG_DIR}; } else { $dbg_dir=$self->get_cwd; }
 my $check=$self->file_exists(dir=>$dbg_dir,file=>$self->{debug_file},info=>"N");
 if ($check == 1)
    {
     $self->file_rename(olddir=>$dbg_dir,oldname=>$self->{debug_file},newname=>$oldfilename,info=>"N");
    }
 my $debugname=$self->comb_dir_file(dir=>$dbg_dir,file=>$self->{debug_file});
 $self->{DBG_LOG} = IO::File->new(">>$debugname") || die ("Unable to open Debug file ($debugname}): $!");
 return;
}
#--------------------------------------------------------------------------
sub debug_info
{
 my $self = shift;
 my $info = shift;
 my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime(time);
 my $message=sprintf ("%02d.%02d.%02d - %s\n", $hour, $min, $sec, $info);
 my ($package, $filename, $line, $subroutine, $hasargs, $wantarray, $evaltext, $is_require, $hints, $bitmask) = caller(1);
 my $trace_info= sprintf("Package: %s Filename: %s at %d: Routine Name: %s with %d Hash Arguments\n",$package,$filename,$line,$subroutine,$hasargs);
 if($self->{LDLEVEL} == 1 || $self->{LDLEVEL} == 3)
   {
    print $trace_info;   
    print $message;
    return;
   }
 if($self->{LDLEVEL} == 2 || $self->{LDLEVEL} == 3)
   {
	my $fh;
	$fh = select("$self->{DBG_LOG}");
	$|      = 1;
	select($fh);
	my $pf = $self->{DBG_LOG};
	printf $pf "%s", $trace_info;
	printf $pf "%s", $message;
	$pf->autoflush;
   }
 return;
}
#--------------------------------------------------------------------------
sub get_config_file
{
 my $self = shift;
 my $cfgfile = $self->{CFG};
 my $zeile;
 $self->debug_info("in get_config_file for $cfgfile");
 open(FILE_HANDLE, "$cfgfile") || die ("Unable to open $cfgfile: $!");
 while(<FILE_HANDLE>)
 {
        chop;
	s/#.*$//;              # Remove comments from the line
	if (/^\s*$/) {next;}   # Skip blank lines
	s/\s+/ /g;             # Replace one or more whitespace characters with a single space...
	s/\s*$//g;             # Remove Trailing Blanks
	/(\w+)\s+(.*)/;
	$self->debug_info("CFG Values are: <$1>\t\t<$2>");
	$self->{CONFIG_PARAM}{$1} = $2;
 }
 close(FILE_HANDLE) || die ("Unable to close $cfgfile: $!");

 foreach my $id ( keys %{$self->{CONFIG_PARAM}} )  
 { 
  my $found=1;
  my $value = $self->{CONFIG_PARAM}{$id};
  $self->debug_info("CFG Parameter Adjusting: <$value>");
  while ($found)
  {
   if ( $value =~ /-(.*?)-/ ) { $found = 1; } else { undef $found; last; }
   my $recode = $+;
   my ($revalue);
   if (defined ${$recode}) { $revalue = ${$recode}; }
   else
      {
        if   (defined $self->{CONFIG_PARAM}{$recode}) { $revalue = $self->{CONFIG_PARAM}{$recode}; }
        else                                          { undef $found; last; }
      }
   $value =~ s/-$recode-/$revalue/;
  }
  $self->{CONFIG_PARAM}{$id} = $value;
 }

 if (defined $self->{CONFIG_PARAM}{LDLEVEL})
    { 
      my $current_ldlevel=$self->{LDLEVEL};
      my $config_ldlevel =$self->{CONFIG_PARAM}{LDLEVEL};
      if ($config_ldlevel > $current_ldlevel) 
          { 
           $self->{LDLEVEL}=$config_ldlevel;
 	   if ($self->{LDLEVEL} == 2 && $current_ldlevel != 2 )  { $self->open_debug_file; }
 	   if ($self->{LDLEVEL} == 3 && $current_ldlevel != 3 )  { $self->open_debug_file; }
          }
    }

 $self->debug_info("Contents of configuration parameters are as following:"); 
 foreach my $id ( keys %{$self->{CONFIG_PARAM}} )
 {
  $self->debug_info("CFG Parameter: <$id> \t\tValue: <$self->{CONFIG_PARAM}{$id}>");
 }
 $self->open_log_file;
 $self->print_log("loading configuration file $cfgfile complete [$VERSION]");
 return;
}
#--------------------------------------------------------------------------
sub proc_args
{
 my $self   = shift;
 my @input  = @_;
 for my $data (@input)
 {
  my ($param,$value) = split(/=/,$data);
  $param=uc($param);
  $self->{$param} = $value;
 }
 if ($self->{LDLEVEL} != 0 )  { $self->open_debug_file; }
 $self->debug_info("Input Arguments are: @input");
 $self->debug_info("Parameter CFG     :  <$self->{CFG}>");
 $self->debug_info("Parameter LDLEVEL :  <$self->{LDLEVEL}>");
 for my $data (@input)
 {
  my ($param,$value) = split(/=/,$data);
  $param=uc($param);
  $self->debug_info("Parameter $param\t\t: $self->{$param}");
 }
 return;
}
#--------------------------------------------------------------------------

__END__

=head1 basetool

basetool is a basic tool PM Module containing simple generic functions
often used with perl.

=head1 SYNOPSIS
      use basetool;
      $basetool=new;
      $basetool->get_config_file;

=head1 AVAILABLE METHODS

=over 8

=item  1.

B<new>

=item  2.

B<proc_args>

=item  3.

B<get_config_file>

=item  4.

B<get_param>

=item  5.

B<cfg_param>

=item  6.

B<find_param>

=item  7.

B<find_cfg_param>

=item  8.

B<calc_busday>

=item  9.

B<print_log>

=item 10.

B<get_cwd>

=item 11.

B<get_env_var>

=item 12.

B<file_exists>

=item 13.

B<file_size>

=item 14.

B<file_rename>

=item 15.

B<file_copy>

=item 16.

B<file_remove>

=item 17.

B<open_log_file>

=item 18.

B<close_log_file>

=item 19.

B<open_debug_file>

=item 20.

B<close_debug_file>

=back

=head1 new
  Constructor; Initializes a new instance.

=head2 Syntax
  my $basetool=new(cfg=>"cfgfile",debug=>"debugfile",ldlevel=>0);

=head2 Parameters
      cfg = configfile, if not specified, assign default.cfg
    debug = debugfile, if not specified, assigns basetool.dbg
  ldlevel = debuglevel, 0 = none
                        1 = display to screen
                        2 = write to debugfile
                        3 = display to screen and write to debugfile
  
=head1 proc_args
  Processes the input arguments param=value and stores them in memory

=head2 Syntax
  $basetool->proc_args(@ARGV);

=head2 Accessing Parameters  
  The parameters are named param and accessable using get_param method
      i.e. $file=get_param(parameter=>"INPUT");

=head1 get_param
  Method to store or retrieve parameters for this instance which are
  stored using proc_args.

=head2 Syntax
  $self->get_param(parameter=>"parameter",value=>"value");
  
=head2 Optional
  value is optional and used to update/change/add a new parameter

=head1 get_config_file
  Loads configuration file into memory.

=head2 Syntax
  $basetool->get_config_file;

=head2 Accessing Parameters  
  The parameters are named param and accessable using cfg_param method
      i.e. $file=cfg_param(parameter=>"EXCH_FILE");
  
=head1 cfg_param
  Method to store or retrieve parameters for this instance which are
  stored using calc_busday or get_config_file.

=head2 Syntax
  $self->cfg_param(parameter=>"parameter",value=>"value");

=head2 Optional
  value is optional and used to update/change/add a new parameter
  
=head1 find_param
  Method of getting a list of parameters which match pattern
  
=head2 Syntax
  @parameters=$self->find_param(pattern=>"value");
  
  Returns array with the parameter keys containing "value".

=head1 find_cfg_param
  Method of getting a list of cfg parameters which match pattern
  
=head2 Syntax
  @parameters=$self->find_cfg_param(pattern=>"value");
  
  Returns array with the cfg parameter keys containing "value".

=head1 debug_info
  Prints debug information into debug file

=head2 Syntax
 $basetool->debug_info("text");
  
=head1 get_cwd
  Returns current working directory

=head2 Syntax
  $ORIG_DIR=$basetool->get_cwd;

=head1 get_env_var
  Method to retrieve or set an environment variable.

=head2 Syntax
  $ORIG_DIR=$basetool->get_env_var(env=>"ENVAR",value=>"value");
  
=head2 optional
  value is optional and used to change/add an environment variable.

=head1 open_log_file
  Opens a new log file

=head2 Syntax  
  $basetool->open_log_file;

=head1 close_log_file
  Closes the current log file

=head2 Syntax
  $basetool->close_log_file;
  
=head1 open_debug_file
  Opens a new debug file

=head2 Syntax
  $basetool->open_debug_file;

=head1 close_debug_file
  Closes the current log file

=head2 Syntax
  $basetool->close_debug_file;
  
=head1 comb_dir_file
  Combines the Directory Name with the Filename to a string
  regardless of operating system

=head2 Syntax
  $fullname=$basetool->comb_dir_file(dir=>directory,file=>filename);
  
  $fullname is on unix:      directory/filename
  $fullname is on windows:   directory\\filename
  
=head1 calc_busday
  Calculates the current or previous business day

=head2 Syntax  
  $basetool->calc_busday(day=>0|1|yymmdd);

=head2 Parameters
    0 = current business day
    1 = previous business day
    yymmdd = use the specified business day
  if no argument, will calculate current day.

=head2 Retrieving/Updating Parameters

  The values are stored and can be retrieved as following:

  $basetool->cfg_param(parameter=>"YEAR")    = 4 digit year (2008)
  $basetool->cfg_param(parameter=>"SYEAR")   = 2 digit year (08)
  $basetool->cfg_param(parameter=>"MONTH")   = 3 char Month (FEB)
  $basetool->cfg_param(parameter=>"NMONTH")  = 2 digit month (02)
  $basetool->cfg_param(parameter=>"DAY")     = 2 digit day (14)
  $basetool->cfg_param(parameter=>"BUSDATE") = 9 char field (year, month, day)
  
=head1 file_exists
  Checks if specified file exists

=head2 Syntax
  $return=$basetool->file_exists(dir=>$directory,file=>$file,info=>"N|Y");

=head2 Parameters
  info    = "N|Y" = if information should be displayed 
            in the log file or not, parameter is optional
  dir  = parameter is optional, if not specified, current directory is used

=head2 return value
     0 = file does not exist
     1 = file exists
  	
=head1 file_size
  Returns the filesize

=head2 Syntax
  $size=$basetool->file_size(dir=>$directory,file=>$file);

=head2 Parameters
  dir  = parameter is optional, if not specified, current directory is used

=head2 return value
     file size in bytes
  	
=head1 file_copy
  Copy file

=head2 Syntax
  $basetool->file_copy(olddir=>$directory,
                      oldname=>$oldfile,
                       newdir=>$directory,
                      newname=>$newfile,
                         info=>"N|Y",
                     tempfile=>"N|Y");
  
=head2 Parameters
  info    = "N|Y" = if information should be displayed 
            in the log file or not, parameter is optional
  newdir  = parameter is optional, if not specified, directory oldir is used
  tempfile= Indicator, if the file copy process should be done via a temporary file
            and not directly.

=head1 file_remove
  Removes file if exists

=head2 Syntax
  $basetool->file_remove(dir=>$directory,file=>$file,info=>"N|Y");
  
=head2 Parameters
  info    = "N|Y" = if information should be displayed 
            in the log file or not, parameter is optional

=head1 file_rename
  Renames file if exists

=head2 Syntax
 $basetool->file_rename(olddir=>$directory,
                       oldname=>$oldfile,
                        newdir=>$directory,
                       newname=>$newfile,
                          info=>"N|Y");
  
=head2 Parameters
  info    = "N|Y" = if information should be displayed 
            in the log file or not, parameter is optional
  newdir  = parameter is optional, if not specified, directory oldir is used

=head1 print_log
  Prints to the log file specified with LOG_DIR and LOG_FILE

=head2 Syntax
 $basetool->print_log("text","y");

=head2 Parameters
  text   = Message to be put into the log file
  y      = optional parameter, if set to y, message will be displayed to screen as well.

=head1  SEE ALSO

http://de.selfhtml.org/perl/module/intro.htm

=cut
