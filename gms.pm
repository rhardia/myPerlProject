#! /usr/bin/perl
# Written by Peter M. Hollenstein
#--------------------------------------------------------------------------
package gms;

use strict;
no strict 'refs';
use vars qw($VERSION @ISA);

use IO::File;
use IO::Handle;	
use File::Basename;
use basetool;

@ISA = qw(basetool);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
$VERSION = '0.27';
1;

#--------------------------------------------------------------------------
sub DESTROY
{
 my $self = shift;
 if ( $self->{ctlfile} eq "Y" )
    {  $self->_write_ctrl;    }
 if ( $self->{ctlfile} eq "D" || $self->{ctlfile} eq "Y" )
    {   $self->_display;      }
 -- ${ $self };
}
#--------------------------------------------------------------------------
sub new_request
{
	my $class = shift;
	my $self  = {};
	my %arg   = @_;
	$self->{basetool}    = $arg{bt};
	$self->{seq}         = $arg{seq};
	$self->{source_file} = $arg{source};
        $self->{gms_pos_file}=sprintf("%s%s%s","ps_",$arg{seq},".gms");
        $self->{gms_gen_file}=sprintf("%s%s%s","gn_",$arg{seq},".gms");
        $self->{gms_mgn_file}=sprintf("%s%s%s","mg_",$arg{seq},".gms");
        $self->{gms_rpt_file}=sprintf("%s%s%s","rp_",$arg{seq},".gms");
        $self->{gms_res_file}=sprintf("%s%s%s","rs_",$arg{seq},".txt");
        $self->{lch_pos_file}=sprintf("%s%s%s","lh_",$arg{seq},".pos");
        $self->{lch_res_file}=sprintf("%s%s%s","lh_",$arg{seq},".csv");
        $self->{job_log_file}=sprintf("%s%s%s","lg_",$arg{seq},".log");
        $self->{job_ctl_file}=sprintf("%s%s%s","rq_",$arg{seq},".ctl");
        $self->{site}  = $arg{site};
        if (defined $arg{ctlfile})   { $self->{ctlfile}=$arg{ctlfile}     } else { $self->{ctlfile}  = "Y"; }
        if (defined $arg{exch_data}) { $self->{exch_data}=$arg{exch_data} } else { $self->{exch_data}=$self->{basetool}->get_cwd; }
        if (defined $arg{addl_data}) { $self->{addl_data}=$arg{addl_data} } else { $self->{addl_data}=$self->{basetool}->get_cwd; }
        if (defined $arg{cust_data}) { $self->{cust_data}=$arg{cust_data} } else { $self->{cust_data}=$self->{basetool}->get_cwd; }
        if (defined $arg{work_dir})  { $self->{work_dir} =$arg{work_dir}  } else { $self->{work_dir} =$self->{basetool}->get_cwd; }
        if (defined $arg{gms_image}) { $self->{gms_image}=$arg{gms_image} } else { $self->{gms_image}="imc"; }
        if (defined $arg{run_mode})   { $self->{run_mode} =$arg{run_mode}  };
		if (defined $arg{report_type})   { $self->{report_type} =$arg{report_type}  };
		if (defined $arg{gms_dir})   { $self->{gms_dir} =$arg{gms_dir}  };
		if (defined $arg{gms_jdir})   { $self->{gms_jdir} =$arg{gms_jdir}  };
        if (defined $arg{gms_library}) { $self->{library}=$arg{gms_library}};
        if (defined $arg{license})     { $self->{license}=$arg{license}};
	bless( $self, $class );
	return $self;
}
#------------------------------------------------------------------------------
sub _display
{
 my $self=shift;
 if (($self->get_param(parameter=>'seq') ne "") && ($self->get_param(parameter=>'source_file') ne ""))
 {
	 $self->{basetool}->print_log("Processing File ".$self->get_param(parameter=>'source_file')." for ".$self->get_param(parameter=>'seq'),"Y");
	 $self->{basetool}->print_log("====================================================================================================================","Y");
	 $self->{basetool}->print_log(" GMS Margin Method ".$self->get_param(parameter=>'gms_method')  ,"Y");
	 $self->{basetool}->print_log(" GMS Position File ".$self->get_param(parameter=>'gms_pos_file'),"Y");
	 $self->{basetool}->print_log(" GMS Margin File   ".$self->get_param(parameter=>'gms_mgn_file'),"Y");
	 $self->{basetool}->print_log(" GMS Report File   ".$self->get_param(parameter=>'gms_rpt_file'),"Y");
	 $self->{basetool}->print_log(" GMS Result File   ".$self->get_param(parameter=>'gms_res_file'),"Y");
	 $self->{basetool}->print_log(" LCH Position File ".$self->get_param(parameter=>'lch_pos_file'),"Y");
	 $self->{basetool}->print_log(" LCH Result File   ".$self->get_param(parameter=>'lch_res_file'),"Y");
	 $self->{basetool}->print_log(" LCH Job Log       ".$self->get_param(parameter=>'job_log_file'),"Y");
	 $self->{basetool}->print_log(" Control File      ".$self->get_param(parameter=>'job_ctl_file'),"Y");
	 $self->{basetool}->print_log(" GMS Image         ".$self->get_param(parameter=>'gms_image')   ,"Y");
	 $self->{basetool}->print_log(" GMS Library       ".$self->get_param(parameter=>'library')     ,"Y");
}
 return;
}
#------------------------------------------------------------------------------
sub _write_ctrl
{
 my $self=shift;
 my $ctrl_file=$self->{basetool}->comb_dir_file(dir=>$self->get_param(parameter=>'work_dir'),file=>$self->get_param(parameter=>'job_ctl_file'));
 open(OUT,">".$ctrl_file) or die "gms::_write_ctrl=>File Open Error: $ctrl_file $!\n";
 my @pars=qw/gms_pos_file gms_mgn_file gms_rpt_file gms_res_file lch_pos_file lch_res_file job_log_file job_ctl_file source_file seq gms_method lch_span_file/;
 foreach my $id (@pars) { my $line=sprintf("%s;%s\n",$id,$self->get_param(parameter=>$id)); print OUT $line; } 
 close(OUT);
 return;
}
#------------------------------------------------------------------------------
sub gen_gms_pos_file
{
 my $self=shift;
 open(FILE,"<".$self->get_param(parameter=>'source_file')) or die "gms::gen_gms_pos_file=>File Open Error: $!\n";
 open(OUT,">".$self->get_param(parameter=>'gms_pos_file')) or die "gms::gen_gms_pos_file=>File Open Error: $!\n";
 while(defined(my $zeile = <FILE>))
 {
  if ( $zeile =~ /^000001/) 
    { chop($zeile);
      my $line=substr($zeile,0,72);
      my $output=sprintf("%s%s\n",$line,$self->get_param(parameter=>'site'));
      print OUT $output;
      next;
    }
  if ( $zeile =~ /^000002/) 
    { chop($zeile);
      my $lsrt=substr($zeile,0,58);
      my $mthd=substr($zeile,58,3);
      my $lend=substr($zeile,61,130);
      $self->_replace_mthd($mthd);
      my $output=sprintf("%s%s%s\n",$lsrt,$self->get_param(parameter=>'gms_method'),$lend);
      print OUT $output;
      next;
     }
  if ($zeile =~ /^000105/ ) 
    { chop($zeile);
      my $lsrt = "000002";
      my $line = substr($zeile, 6, 185);
      my $output=sprintf("%s%s\n",$lsrt,$line);
      print OUT $output;
      next;
    }
 }
 close(FILE);
 close(OUT);
 return;
}
#------------------------------------------------------------------------------
sub gen_lch_pos_file
{
 my $self=shift;
 my $command=$self->{basetool}->cfg_param(parameter=>'GMS_EXP_TO_LCH')." ".$self->get_param(parameter=>'gms_pos_file')." ".$self->get_param(parameter=>'lch_pos_file');
 my @result=`$command`;
 $self->{basetool}->print_log("===> GMS to LCH Position Conversion");
 for my $line (@result) { $self->{basetool}->print_log("$line","Y"); }
 $self->_locate_lch_span_file;
 return;
}

#------------------------------------------------------------------------------
sub _locate_lch_span_file
{
 my $self=shift;
 my $mth=lc($self->get_param(parameter=>'gms_method'));
 my $filename;
 opendir (DHS,".");			# Open the Work Directory
 while (my $sp = readdir(DHS))		# Read the next entry
 {
  if ($sp ne "." && $sp ne "..")	# Not the Directory Files
      {
	if (lc($sp) =~ /^${mth}/ && lc($sp) =~ /\.pa[34]$/ )	# start with and ends with
	    { $filename=$sp; last; }
      }
 }
 closedir(DHS);
 my $lch_span_file=substr($filename,0,-3)."lch";
 my $command=$self->{basetool}->cfg_param(parameter=>'UNIX2DOS')." -437 ".$filename." >".$lch_span_file;
 my @result=`$command`;
 $self->get_param(parameter=>'lch_span_file',value=>$lch_span_file);
 return;
}
#------------------------------------------------------------------------------
sub _set_environment
{
 my $self=shift;
 my $orig_ldlp=$self->{basetool}->get_env_var(env=>'LD_LIBRARY_PATH');
 my $ldlp;
 if (defined $self->get_param(parameter=>'library'))
    { $ldlp=$self->get_param(parameter=>'library').":".$orig_ldlp;
      $self->{basetool}->get_env_var(env=>'LD_LIBRARY_PATH',value=>$ldlp);
    }
 if (defined $self->get_param(parameter=>'license'))
    { $self->{basetool}->get_env_var(env=>'SUNGARD_LICENSE',value=>$self->get_param(parameter=>'license')); }
 if (defined $self->get_param(parameter=>'gms_dir'))
    { $self->{basetool}->get_env_var(env=>'GMS_DIR',value=>$self->get_param(parameter=>'gms_dir')); }
 return $orig_ldlp;
}
#------------------------------------------------------------------------------

sub _set_ice_environment
{
 my $self=shift;
 my $host;
 my $orig_ldlp;
 my $ldlp;
 my $gms_dir;
 my $classpath;
 my $orig_classpath;
 #my $host=$self->get_param(parameter=>'HOST'); #Changed for windows
 #if ($^O ne "MSWin32")  {$host=`uname -n`; chomp $host; } else { $self->{basetool}->get_env_var(env=>'COMPUTERNAME'); }
 if ($^O ne "MSWin32")  {$host=`uname -n`; chomp $host; } else { $host="windows"; }
 $self->{basetool}->print_log("HOST=$host","Y");
 if ($^O ne "MSWin32")  { $orig_ldlp=$self->{basetool}->get_env_var(env=>'LD_LIBRARY_PATH')}
	else { $orig_ldlp=$self->{basetool}->get_env_var(env=>'PATH');}
 my $ldlp;
 if (defined $self->get_param(parameter=>'library'))
    { if ($^O ne "MSWin32") {$ldlp=$self->get_param(parameter=>'library').":".$orig_ldlp;
      $self->{basetool}->get_env_var(env=>'LD_LIBRARY_PATH',value=>$ldlp);}
	  else 
	  {$ldlp=$self->get_param(parameter=>'library').";".$orig_ldlp;
      $self->{basetool}->get_env_var(env=>'PATH',value=>$ldlp);}
    }
 if ($^O ne "MSWin32") { #$orig_classpath=$self->{basetool}->get_env_var(env=>'CLASSPATH');
  $classpath=$self->get_param(parameter=>'library')."/gmsIceLink.jar";}
 else { #$orig_classpath=$self->{basetool}->get_env_var(env=>'CLASSPATH');
  $classpath=$self->{basetool}->get_env_var(env=>'LIB_DIR');
  $classpath= $classpath."/gmsIceLink.jar";}
 
 $self->{basetool}->get_env_var(env=>'CLASSPATH',value=>$classpath);
 my $extjar=$self->get_param(parameter=>'library')."/extjar";
 $self->{basetool}->get_env_var(env=>'GMS_EXT_JAR',value=>$extjar);
 $self->{basetool}->get_env_var(env=>'GMS_LIB',value=>$self->get_param(parameter=>'library'));
 $self->{basetool}->get_env_var(env=>'GMS_SITEID',value=>$self->get_param(parameter=>'site'));
 if (defined $self->get_param(parameter=>'license'))
    { $self->{basetool}->get_env_var(env=>'SUNGARD_LICENSE',value=>$self->get_param(parameter=>'license')); }
# if (defined $self->get_param(parameter=>'gms_dir'))
#	{
		if ($^O ne "MSWin32")  { $gms_dir="/qa/regression"} else { $gms_dir="E:\\regression";} 
		$self->{basetool}->get_env_var(env=>'GMS_DIR',value=>$gms_dir);
#	}
 if ($host eq "spica"){$ldlp=$ldlp.":/usr/java/jre/lib/sparc";}
 elsif($host eq "vega"){$ldlp=$ldlp.":/usr/java/jre/lib/amd64/server";}
 elsif($host eq "adora"){$ldlp=$ldlp.":/usr/bin/j2sdk1.4.2_05/jre/lib/i386/server";}
 elsif($host eq "arcturus"){$ldlp=$ldlp.":/usr/java/jre/lib/i386/server";}
 elsif($host eq "windows"){$ldlp=$ldlp;}
 else {$ldlp=$ldlp.":/QOpenSys/QIBM/ProdData/JavaVM/jdk60/32bit/jre/lib/ppc/j9vm";}
 $self->{basetool}->get_env_var(env=>'LD_LIBRARY_PATH',value=>$ldlp);
 
 my $env1=$self->{basetool}->get_env_var(env=>'LD_LIBRARY_PATH');
 my $env2=$self->{basetool}->get_env_var(env=>'GMS_SITEID');
 my $env3=$self->{basetool}->get_env_var(env=>'GMS_LIB');
 my $env4=$self->{basetool}->get_env_var(env=>'CLASSPATH');
 my $env5=$self->{basetool}->get_env_var(env=>'GMS_DIR');
 my $env6=$self->{basetool}->get_env_var(env=>'GMS_EXT_JAR');
 
 $self->{basetool}->print_log("LD_LIBRARY_PATH=$env1","Y");
 $self->{basetool}->print_log("GMS_SITEID=$env2","Y");
 $self->{basetool}->print_log("GMS_LIB=$env3","Y");
 $self->{basetool}->print_log("CLASSPATH=$env4","Y");
 $self->{basetool}->print_log("GMS_DIR=$env5","Y");
 $self->{basetool}->print_log("GMS_EXT_JAR=$env6","Y");
 
 
 return $orig_ldlp;
}
#------------------------------------------------------------------------------

sub execute_gms
{
 my $exchCode;
 my $testDir;
 my $reversed;
 my $command;
 my $comPrefix;
 my $comPostfix;
 my $file;
 my $line;
 my $self=shift;
 my $orig_dir=$self->{basetool}->get_cwd;
 my $testBuild = $ARGV[1].$ARGV[2];
# my $orig_ldlp=$self->_set_environment;
 my $mode=$self->get_param(parameter=>'run_mode'); 
 chomp $mode;
 chdir($self->get_param(parameter=>'work_dir'));
 $self->get_param(parameter=>'gms_success',value=>1);
 my $cmd_prefix;
 if ($^O ne "MSWin32")  { $cmd_prefix=" 2>&1 time";$comPostfix="";}
 if ($^O eq "os400")  { $cmd_prefix="qsh -c 'exec 2>out.log;time";$comPostfix=">out.log'"; }
 if ("$ENV{'DATA_MODEL'}" eq 64) {$comPrefix = "-d64"} else {$comPrefix = " "};
 if (uc($mode) eq "J" || uc($mode) eq "JAVA"){
	$self->{basetool}->get_env_var(env=>'SITE_ID',value=>$self->get_param(parameter=>'site'));
	 my $gmsJava_image=$self->get_param(parameter=>'gms_image');
	 $gmsJava_image=~ s/imc/java/g;
	 if ($testBuild =~ /--v2/){$command=$cmd_prefix." ".$gmsJava_image." ".$comPrefix." com.sungard.gms.client.gmsIMC_V2 -u".$self->get_param(parameter=>'seq')." -e".$self->get_param(parameter=>'exch_data')." -o".$self->get_cwd." -rCR -".lc($self->get_param(parameter=>'report_type'));}
	 else {$command=$cmd_prefix." ".$gmsJava_image." ".$comPrefix." com.sungard.gms.client.gmsIMC -u".$self->get_param(parameter=>'seq')." -e".$self->get_param(parameter=>'exch_data')." -o".$self->get_cwd." -rCR -".lc($self->get_param(parameter=>'report_type'));}
 }
 else{
		$command=$cmd_prefix." ".$self->get_param(parameter=>'gms_image')." -u".$self->get_param(parameter=>'seq')." -e".$self->get_param(parameter=>'exch_data')." -c".$self->get_param(parameter=>'exch_data')." -l".$self->get_cwd." -rC -rR -".lc($self->get_param(parameter=>'report_type')).$comPostfix;
 }
 my @result=`$command`;
 if ($^O eq "os400")
{
  $file=$self->{basetool}->comb_dir_file(dir=>$self->get_param(parameter=>'work_dir'),file=>'out.log');
 open(FILE,"<".$file) or die "main::execute_gms => File Open Error: $!\n";
foreach $line (<FILE>)  
{
	chop($line); if ($line =~ /^\s*$/) {next;}
      	$self->{basetool}->print_log("$line","Y");
	if ($line =~ /^user*/) { $line =~ s/\s+/ /g; my ($value,$timer) = split (/ /,$line); $self->get_param(parameter=>'gms_run_time',value=>$timer); }
	elsif ($line =~ /(\d*)\.(\d*)user/) { my $timer=sprintf ("%s.%s",$1,$2); $self->get_param(parameter=>'gms_run_time',value=>$timer);  }
}
close(FILE);
}
system("rm gn_*.gms"); 
$self->{basetool}->print_log("===> GMS Execution");
 for $line (@result) 
    { chop($line); if ($line =~ /^\s*$/) {next;}
      $self->{basetool}->print_log("$line","Y");
      if ($line =~ /^user*/) { $line =~ s/\s+/ /g; my ($value,$timer) = split (/ /,$line); $self->get_param(parameter=>'gms_run_time',value=>$timer); }
      elsif ($line =~ /(\d*)\.(\d*)user/) { my $timer=sprintf ("%s.%s",$1,$2); $self->get_param(parameter=>'gms_run_time',value=>$timer);  }
    }
 $self->_collect_logs;
 $self->_gen_res_file;
# $self->{basetool}->get_env_var(env=>'LD_LIBRARY_PATH',value=>$orig_ldlp);
 chdir($orig_dir);
 return;
}

#------------------------------------------------------------------------------

sub report_gms
{
 my $self=shift;
 my $type=$_[0];
 my $exchCode;
 my $testDir;
 my $reversed;
 my $orig_dir=$self->{basetool}->get_cwd;
 chdir($self->get_param(parameter=>'work_dir'));
 $self->get_param(parameter=>'gms_success',value=>1);
 my $command="mv ".$self->get_cwd."/".$type."/*_".$self->get_param(parameter=>'seq').".gms ".$self->get_cwd;
 opendir (DIR,$self->get_cwd."/".$type);
 while(my $entry = readdir(DIR)) {
	if ($entry ne "." && $entry ne "..")	# Not the Directory Files
		{
			if (lc($entry) =~ /^gn_[1-99999]|^mg_[1-99999]|^rp_[1-99999]/){
				my @result=`$command`;
				last;
			}			
		}
    }
 closedir(DIR);
 # $self->_gen_res_file;
 chdir($orig_dir);
 return;
}

#------------------------------------------------------------------------------
sub execute_inq_gms
{
 my $exchCode;
 my $testDir;
 my $reversed;
 my $self=shift;
 my @arrTemp;
 my $orig_dir=$self->{basetool}->get_cwd;
 my $comPrefix;
 my $testBuild = $ARGV[1].$ARGV[2];
# my $orig_ldlp=$self->_set_environment;
 chdir($self->get_param(parameter=>'work_dir'));
 $self->get_param(parameter=>'gms_success',value=>1);
 my $cmd_prefix;
 my $mode=$self->get_param(parameter=>'run_mode'); 
  if ($^O ne "MSWin32")  { $cmd_prefix="2>&1 time "; }
  if ($^O eq "os400")  { $cmd_prefix=" time"; }
  if ("$ENV{'DATA_MODEL'}" eq 64) {$comPrefix = "-d64"} else {$comPrefix = " "};
 
 	if (uc($mode) eq "J" || uc($mode) eq "JAVA"){
		$self->{basetool}->get_env_var(env=>'SITE_ID',value=>$self->get_param(parameter=>'site'));
		my $gmsJava_image=$self->get_param(parameter=>'gms_image');
		$gmsJava_image=~ s/imc/java/g;
		 if ($testBuild =~ /--v2/){$cmd_prefix=$cmd_prefix." ".$gmsJava_image." ".$comPrefix." com.sungard.gms.client.gmsIMC_V2";}
		 else {$cmd_prefix=$cmd_prefix." ".$gmsJava_image." ".$comPrefix." com.sungard.gms.client.gmsIMC";}
		#$command=$cmd_prefix." ".$gmsJava_image." com.sungard.gms.client.gmsIMC -u".$self->get_param(parameter=>'seq')." -e".$self->get_param(parameter=>'exch_data')." -o".$self->get_cwd." -rCR -".lc($self->get_param(parameter=>'report_type'));
	}
 else{ 
		$cmd_prefix=$cmd_prefix." ".$self->get_param(parameter=>'gms_image');
		#my $command=$cmd_prefix." ".$self->get_param(parameter=>'gms_image')." -u".$self->get_param(parameter=>'seq')." -e".$self->get_param(parameter=>'exch_data')." -c".$self->get_param(parameter=>'exch_data')." -l".$self->get_cwd." -rCR -f";
 }
 my $command=$cmd_prefix." -u".$self->get_param(parameter=>'seq')." -e".$self->get_param(parameter=>'exch_data')." -c".$self->get_param(parameter=>'exch_data')." -l".$self->get_cwd." -rCR -f";
 my @result=`$command`;
 system("rm gn_*.gms"); 
 ################### Inquiry Mode################
	@arrTemp = split('/',$orig_dir);
	$testDir = pop(@arrTemp);
	$exchCode = substr($testDir,0,3);
	$exchCode = uc($exchCode);
	open(REP,">rp_".$self->get_param(parameter=>'seq').".gms");
	
	my $command=$cmd_prefix." -u".$self->get_param(parameter=>'seq')." -RI".$exchCode." -RT >> rp_".$self->get_param(parameter=>'seq').".gms";
	open(REP,">>rp_".$self->get_param(parameter=>'seq').".gms"); 
	print REP "\n##################################################################################################\n";
	print REP "RUNNING COMMAND--> imc -u".$self->get_param(parameter=>'seq')." -RI".$exchCode." -RT\n";
	print REP "##################################################################################################\n\n";
	$self->{basetool}->print_log("INQ RUN --> $command","Y");
	my @result=`$command`;
	
	my $command=$cmd_prefix." -u".$self->get_param(parameter=>'seq')." -RI".$exchCode." -RTTOTALS >> rp_".$self->get_param(parameter=>'seq').".gms";
	print REP "\n\n##################################################################################################\n";
	print REP "RUNNING COMMAND --> imc -u".$self->get_param(parameter=>'seq')." -RI".$exchCode." -RTTOTALS\n";
	print REP "##################################################################################################\n\n";
	$self->{basetool}->print_log("INQ RUN --> $command","Y");
	my @result=`$command`;

	my $command=$cmd_prefix." -u".$self->get_param(parameter=>'seq')." -RI".$exchCode." -RTSTD_WAR >> rp_".$self->get_param(parameter=>'seq').".gms";
	print REP "\n\n##################################################################################################\n";
	print REP "RUNNING COMMAND --> imc -u".$self->get_param(parameter=>'seq')." -RI".$exchCode." -RTSTD_WAR\n";
	print REP "##################################################################################################\n\n";
	$self->{basetool}->print_log("INQ RUN --> $command","Y");
	my @result=`$command`;

	################################################
 
 $self->{basetool}->print_log("===> GMS Execution");
 for my $line (@result) 
    { chop($line); if ($line =~ /^\s*$/) {next;}
      $self->{basetool}->print_log("$line","Y");

      if ($line =~ /^user*/) { $line =~ s/\s+/ /g; my ($value,$timer) = split (/ /,$line); $self->get_param(parameter=>'gms_run_time',value=>$timer); }
      elsif ($line =~ /(\d*)\.(\d*)user/) { my $timer=sprintf ("%s.%s",$1,$2); $self->get_param(parameter=>'gms_run_time',value=>$timer);  }
    } 
 $self->_collect_logs;
 $self->_gen_res_file;
# $self->{basetool}->get_env_var(env=>'LD_LIBRARY_PATH',value=>$orig_ldlp);
 chdir($orig_dir);
 return;
}

#------------------------------------------------------------------------------
sub execute_ice_gms
{
 my $exchCode;
 my $testDir;
 my $reversed;
 my $self=shift;
 my $orig_dir=$self->{basetool}->get_cwd;
 my $orig_ldlp=$self->_set_ice_environment;
 chdir($self->get_param(parameter=>'work_dir'));
 $self->get_param(parameter=>'gms_success',value=>1);
 my $cmd_prefix;
 if ($^O ne "MSWin32")  { $cmd_prefix="2>&1 time "; }
 if ($^O eq "os400")  { $cmd_prefix=" time"; }
 my $command=$cmd_prefix." ".$self->get_param(parameter=>'gms_image')." -u".$self->get_param(parameter=>'seq')." -e".$self->get_param(parameter=>'exch_data')." -l".$self->get_cwd." -rC -rR -F";
 my @result=`$command`;
  
 $self->{basetool}->print_log("===> GMS Execution");
 for my $line (@result) 
    { chop($line); if ($line =~ /^\s*$/) {next;}
      $self->{basetool}->print_log("$line","Y");
      if ($line =~ /^user*/) { $line =~ s/\s+/ /g; my ($value,$timer) = split (/ /,$line); $self->get_param(parameter=>'gms_run_time',value=>$timer); }
      elsif ($line =~ /(\d*)\.(\d*)user/) { my $timer=sprintf ("%s.%s",$1,$2); $self->get_param(parameter=>'gms_run_time',value=>$timer);  }
    }
 $self->_collect_logs;
 $self->_gen_res_file;
 $self->{basetool}->get_env_var(env=>'LD_LIBRARY_PATH',value=>$orig_ldlp);
 chdir($orig_dir);
 return;
}
#------------------------------------------------------------------------------
sub gen_summary_rpt
{
 my $self=shift;
 my $command;
 my $orig_dir=$self->{basetool}->get_cwd;
 my $comPrefix;
 my $testBuild = $ARGV[1].$ARGV[2];
# my $orig_ldlp=$self->_set_environment;
 my $mode=$self->get_param(parameter=>'run_mode'); 
 chomp $mode;
 chdir($self->get_param(parameter=>'work_dir'));
 $self->get_param(parameter=>'gms_success',value=>1);
 my $cmd_prefix;
 if ($^O ne "MSWin32")  { $cmd_prefix="time"; }
 if ($^O eq "os400")  { $cmd_prefix=" time"; }
 if ("$ENV{'DATA_MODEL'}" eq 64) {$comPrefix = "-d64"} else {$comPrefix = " "};
if (uc($mode) eq "J" || uc($mode) eq "JAVA"){
	$self->{basetool}->get_env_var(env=>'SITE_ID',value=>$self->get_param(parameter=>'site'));
	 my $gmsJava_image=$self->get_param(parameter=>'gms_image');
	  $gmsJava_image=~ s/imc/java/g;
		if ($testBuild =~ /--v2/){$command=$cmd_prefix. " ".$gmsJava_image." ".$comPrefix." com.sungard.gms.client.gmsIMC_V2 -u".$self->get_param(parameter=>'seq')." -e".$self->get_param(parameter=>'exch_data')." -o".$self->get_cwd." -rR -t";}
		else {$command=$cmd_prefix. " ".$gmsJava_image." ".$comPrefix." com.sungard.gms.client.gmsIMC -u".$self->get_param(parameter=>'seq')." -e".$self->get_param(parameter=>'exch_data')." -o".$self->get_cwd." -rR -t";}
 }
else {
	$command=$cmd_prefix." ".$self->get_param(parameter=>'gms_image')." -u".$self->get_param(parameter=>'seq')." -l".$self->get_cwd." -rR -t";
}
 my @result=`$command`;
 $self->{basetool}->print_log("===> GMS RPT Execution");
 for my $line (@result) 
    { chop($line); if ($line =~ /^\s*$/) {next;}
      $self->{basetool}->print_log("$line","Y"); 
      if ($line =~ /^user*/) { $line =~ s/\s+/ /g; my ($value,$timer) = split (/ /,$line); $self->get_param(parameter=>'gms_rpt_time',value=>$timer); }
      elsif ($line =~ /(\d*)\.(\d*)user/) { my $timer=sprintf ("%s.%s",$1,$2); $self->get_param(parameter=>'gms_rpt_time',value=>$timer);  }
    }
 $self->_collect_logs;
 # $self->{basetool}->get_env_var(env=>'LD_LIBRARY_PATH',value=>$orig_ldlp);
 chdir($orig_dir);
 return;
}
#------------------------------------------------------------------------------


sub report_gms_summary
{
 my $self=shift;
 my $type=$_[0];
 my $exchCode;
 my $testDir;
 my $reversed;
 my $orig_dir=$self->{basetool}->get_cwd;
 chdir($self->get_param(parameter=>'work_dir'));
 $self->get_param(parameter=>'gms_success',value=>1);
 my $command="mv ".$self->get_cwd."/".$type."/total/rp_".$self->get_param(parameter=>'seq').".gms ".$self->get_cwd;
 opendir (DIR,$self->get_cwd."/".$type."/total");
 while(my $entry = readdir(DIR)) {
	if ($entry ne "." && $entry ne "..")	# Not the Directory Files
		{
			if (lc($entry) =~ /^gn_[1-99999]|^mg_[1-99999]|^rp_[1-99999]/){
				my @result=`$command`;
				last;
			}			
		}
    }
 closedir(DIR);
 chdir($orig_dir);
 return;
}

#------------------------------------------------------------------------------

sub read_gms_results
{
 my $self=shift;
 my $file=$self->{basetool}->comb_dir_file(dir=>$self->get_param(parameter=>'work_dir'),file=>$self->get_param(parameter=>'gms_res_file'));
 open(FILE,"<$file") or $self->{basetool}->print_log("gms::read_gms_results => File Open Error: $file $!\n");
 while(defined(my $zeile = <FILE>))
 {
 if ( $zeile =~ /^...100/) 
    {chop($zeile);
     my $account=substr($zeile,12,20);
     $account   =~ s/\s+//g;
     my $mth    =substr($zeile,0,3);
     my $ccy    =substr($zeile,59,3);
     my $amt    =substr($zeile,84,15);
     my $prev_amount=$self->{RESULT}{$account}{$mth}{$ccy};
     my $new_amount=$amt+$prev_amount;
     $self->{RESULT}{$account}{$mth}{$ccy}=$new_amount;
    }
 }
 close(FILE);
 return;
}
#------------------------------------------------------------------------------
sub _gen_res_file
{
 my $self=shift;
 if ($self->{basetool}->file_exists(dir=>$self->get_param(parameter=>'work_dir'),file=>$self->get_param(parameter=>'gms_mgn_file'),info=>'N') == 1)
    { $self->get_param(parameter=>'gms_success',value=>0);
      open(FILE,"<".$self->get_param(parameter=>'gms_mgn_file')) or die "gms::execute_gms=>File Open Error: $!\n";
      open(OUT,">".$self->get_param(parameter=>'gms_res_file')) or die "gms::execute_gms=>File Open Error: $!\n";
      while(defined(my $zeile = <FILE>)) { if ( $zeile =~ /^...100/) { print OUT $zeile; } }
      close(FILE);
      close(OUT);
    }
 return;
}
#------------------------------------------------------------------------------
sub _collect_logs
{
 my $self=shift;
 for my $file (qw/gms_imc.log err_imc.gms/)
   {
    if ($self->{basetool}->file_exists(dir=>$self->get_param(parameter=>'work_dir'),file=>$file,info=>'N') == 1)
       {
        if ($file eq "err_imc.gms") { $self->{basetool}->print_log("===> GMS Error"); }
        if ($file eq "gms_imc.log") { $self->{basetool}->print_log("===> GMS Log"); }
        open(LFILE,"<".$file) or die "gms::_collect_logs=>File Open Error: $file $!\n";
        while(defined(my $line = <LFILE>)) { chop($line); if ($line =~ /^\s*$/) {next;} $self->{basetool}->print_log($line); }
        close(LFILE);
        $self->{basetool}->file_remove(dir=>$self->get_cwd,file=>$file,info=>'N');
       }
   }
 return;
}
#------------------------------------------------------------------------------
sub _replace_mthd
{
 my $self=shift;
 my $method=shift;
 if ($method eq "00I") { $method="IPE" };
 if ($method eq "00L") { $method="LIF" };
 if ($method eq "00O") { $method="OPT" };
 if ($method eq "00X") { $method="FOX" };
 $self->get_param(parameter=>'gms_method',value=>$method);
 return;
}
#------------------------------------------------------------------------------
__END__

=head1 gms

gms a PM Module containing functions to run gms from within perl

=head1 SYNOPSIS
      use gms;
      $gms = gms->new_request(bt=>$basetool,
                              seq=>'1',
                              source=>source_file_name,
                              exch_data=>exch_data);
      $gms->gen_gms_pos_file;
      $gms->execute_gms;

=head1 AVAILABLE METHODS

=over 8

=item  1.

B<new_request>

=item  2.

B<gen_gms_pos_file>

=item  3.

B<execute_gms>

=item  4.

B<gen_lch_pos_file>

=back

=head1 new_request
  Constructor; Initializes a new instance.

=head2 Syntax
      $gms = gms->new_request(bt=>$basetool,
                              seq=>'1',
                              source=>source_file_name,
                              exch_data=>exch_data_dir,
                              addl_data=>addl_data_dir,
                              work_dir=>work_dir,
                              gms_dir=>gms_dir,
                              site=>site_id,
                              license=>license_dir,
                              ctlfile=>Y|N|D);

=head2 Parameters
 bt  = basetool class, required
 seq = Sequence Number to be used for this request for all file names, required
 source = input source file name, for example a position or a gen file for gms, required
 site   = GMS Site ID, required
 exch_data = optional location of exch data files
 addl_data = optional location of additional data files
 work_dir  = optional location of where execution should occour [all temp files are created there]
 gms_dir   = optional location of where the XML files are to be found
 license   = optional location of where the license file is located
 ctlfile   = optional if a control file should be created in the work-directory.
                      Y = Yes
                      N = No
                      D = No workfile but a display
  
=head1 gen_gms_pos_file
  convert a gen file into a gms position file.
  
=head2 Syntax
  $gms->gen_gms_pos_file;

=head1 execute_gms
  Runs gms

=head2 Syntax
  $gms->exec_gms;
  
=head1 gen_lch_pos_file
  convert a gms position file into a lch position file and generate the necessary
  lch span file.
  
=head2 Syntax
  $gms->gen_lch_pos_file;
  
=head1 Example
  my $bt = basetool->new(cfg=>"gmslch.cfg",debug=>"gmslch.dbg");
  $bt->get_config_file;
  local($req)= gms->new_request(bt=>$bt,seq=>$SEQUENCE,source=>$INPUT,site=>'OCTPMH');
  $req->gen_gms_pos_file;
  $req->execute_gms;
  $req->gen_lch_pos_file;

=head2 Description
  Execute GMS against the passed in parameter SEQUENCE and input file INPUT.
  The perl command would be: perl mygms.pl SEQUENCE=1 INPUT=gen_abc.gms

=head1  SEE ALSO

http://de.selfhtml.org/perl/module/intro.htm

=cut
