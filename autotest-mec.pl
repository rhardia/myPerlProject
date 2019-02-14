#! /usr/bin/perl
# Written by Peter M. Hollenstein
if ($^O eq "os400") {$ENV{PERL5SHELL} ="qsh";}
use basetool;
use gms;
use File::Basename;
my $bt = basetool->new(cfg=>"gms.cfg",debug=>"gmstest.dbg");
$bt->proc_args(@ARGV);
$bt->get_config_file;
&determine_host();
if ($bt->get_param(parameter=>'MODE') ne "") {$bt->print_log("RUNNING REGRESSION IN ".uc($bt->get_param(parameter=>'MODE'))." MODE",'Y');}
$bt->print_log("Begin processing on Host ".$bt->get_param(parameter=>'HOST')." for Version ".$bt->cfg_param(parameter=>'GMS_VERSION'),'Y');
&diff_source();
&get_testcases();
$bt->print_log("Start Auto Testing now",'Y');
&gen_testing();
&xml_testing();
&java_testing();
&javas_testing();
&inq_testing();
&ice_testing();
$bt->print_log("End Auto Testing now",'Y');
exit;
#------------------------------------------------------------------------------
sub java_testing
{

if ($^O eq "os400") {return;}
 my $run_mode=$bt->get_param(parameter=>'MODE');
 $bt->print_log("Start JAVA Mode Testing now",'Y');
 $bt->get_param(parameter=>'MODE', value=>'JAVA');
 foreach my $directory (@JAVA_DIR)
 {
    $bt->debug_info("Processing now $directory");
    my $testcase=$bt->comb_dir_file(dir=>$bt->cfg_param(parameter=>'TEST_DIR'),file=>$directory);
    $bt->print_log("Start Directory $testcase",'Y');
    
	if ($bt->file_exists(dir=>$bt->cfg_param(parameter=>'TEST_DIR'),file=>$directory,info=>'N') == 0)
	{
		chdir($bt->cfg_param(parameter=>'TEST_DIR'));
		system("mkdir $directory ");
	}
	
	&run_testdir($testcase);
    $bt->print_log("End Directory $testcase",'Y');
 }
 
########################### Inquiry Java testing#################################### 
 foreach my $directory (@INQJ_DIR)
 {
    $bt->debug_info("Processing now $directory");
    my $testcase=$bt->comb_dir_file(dir=>$bt->cfg_param(parameter=>'TEST_DIR'),file=>$directory);
    $bt->print_log("Start Directory $testcase",'Y');
	
	if ($bt->file_exists(dir=>$bt->cfg_param(parameter=>'TEST_DIR'),file=>$directory,info=>'N') == 0)
	{
		chdir($bt->cfg_param(parameter=>'TEST_DIR'));
		system("mkdir $directory ");
	}
	
    &run_inqdir($testcase);
    $bt->print_log("End Directory $testcase",'Y');
 }  
   
 $bt->get_param(parameter=>'MODE', value=>'');
 return;
}

#------------------------------------------------------------------------------
sub javas_testing
{
 foreach my $directory (@JAVAS_DIR)
   {
    $bt->debug_info("Processing now $directory");
    my $testcase=$bt->comb_dir_file(dir=>$bt->cfg_param(parameter=>'TEST_DIR'),file=>$directory);
    $bt->print_log("Start Directory $testcase",'Y');
    &run_javasdir($testcase);
    $bt->print_log("End Directory $testcase",'Y');
   }
 return;
}
#------------------------------------------------------------------------------
sub gen_testing
{
 foreach my $directory (@TEST_DIR)
   {
    $bt->debug_info("Processing now $directory");
    my $testcase=$bt->comb_dir_file(dir=>$bt->cfg_param(parameter=>'TEST_DIR'),file=>$directory);
    $bt->print_log("Start Directory $testcase",'Y');
    
	if ($bt->file_exists(dir=>$bt->cfg_param(parameter=>'TEST_DIR'),file=>$directory,info=>'N') == 0)
	{
		chdir($bt->cfg_param(parameter=>'TEST_DIR'));
		system("mkdir $directory ");
	}
	
	&run_testdir($testcase);
    $bt->print_log("End Directory $testcase",'Y');
   }
 return;
}
#------------------------------------------------------------------------------


sub inq_testing
{
 foreach my $directory (@INQT_DIR)
   {
    $bt->debug_info("Processing now $directory");
    my $testcase=$bt->comb_dir_file(dir=>$bt->cfg_param(parameter=>'TEST_DIR'),file=>$directory);
    $bt->print_log("Start Directory $testcase",'Y');
	
	if ($bt->file_exists(dir=>$bt->cfg_param(parameter=>'TEST_DIR'),file=>$directory,info=>'N') == 0)
	{
		chdir($bt->cfg_param(parameter=>'TEST_DIR'));
		system("mkdir $directory ");
	}
	
    &run_inqdir($testcase);
    $bt->print_log("End Directory $testcase",'Y');
   }
 return;
}
#------------------------------------------------------------------------------

sub ice_testing
{
 foreach my $directory (@ICET_DIR)
   {
    $bt->debug_info("Processing now $directory");
    my $testcase=$bt->comb_dir_file(dir=>$bt->cfg_param(parameter=>'TEST_DIR'),file=>$directory);
    $bt->print_log("Start Directory $testcase",'Y');
	
	if ($bt->file_exists(dir=>$bt->cfg_param(parameter=>'TEST_DIR'),file=>$directory,info=>'N') == 0)
	{
		chdir($bt->cfg_param(parameter=>'TEST_DIR'));
		system("mkdir $directory ");
	}
    &run_icedir($testcase);
    $bt->print_log("End Directory $testcase",'Y');
   }
 return;
}
#------------------------------------------------------------------------------


sub xml_testing
{
 if ($bt->get_param(parameter=>'HOST') eq "adora") { return;}
 $bt->print_log("Start XML Testing now",'Y');
 foreach my $directory (@XMLT_DIR)
   {
    $bt->debug_info("Processing now $directory");
    my $testcase=$bt->comb_dir_file(dir=>$bt->cfg_param(parameter=>'TEST_DIR'),file=>$directory);
    $bt->print_log("Start Directory $testcase",'Y');
	
	if ($bt->file_exists(dir=>$bt->cfg_param(parameter=>'TEST_DIR'),file=>$directory,info=>'N') == 0)
	{
		chdir($bt->cfg_param(parameter=>'TEST_DIR'));
		system("mkdir $directory ");
	}
	
    &run_testdir($testcase);
    $bt->print_log("End Directory $testcase",'Y');
   }
 return;
}
#------------------------------------------------------------------------------


sub run_common_cmds
{
 $bt->print_log("Start $testdir Position File $sequence",'Y');
 my $exch_data=$bt->comb_dir_file(dir=>$testdir,file=>'exch_data');
 my $work_dir =$bt->comb_dir_file(dir=>$testdir,file=>$bt->get_param(parameter=>'HOST'));
 
 if ($bt->file_exists(dir=>$testdir,file=>$bt->get_param(parameter=>'HOST'),info=>'N') == 0) 
    { my $cmd="mkdir ".$bt->get_param(parameter=>'HOST');
      @result=`$cmd`;
    }


 #################### Change the base to corresponding directory, here current Dir replace with work_dir ######################################## 
 	my $spica_base=$bt->comb_dir_file(dir=>$work_dir,file=>'spica_base');
	if ($bt->file_exists(dir=>$work_dir,file=>'spica_base',info=>'N') == 1) 
	{
		my $cmd="rm ".$spica_base;
		@result=`$cmd`;
	}
	
	
	if ($bt->file_exists(dir=>$work_dir,file=>'mizar_base',info=>'N') == 0) 
	{	
		my $mizar_dir=$bt->comb_dir_file(dir=>$testdir,file=>'mizar');
		my $mizar_base_dir=$bt->comb_dir_file(dir=>$mizar_dir,file=>'base');
		my $mizar_base=$bt->comb_dir_file(dir=>$work_dir,file=>'mizar_base');
		$cmd="ln -s ".$mizar_base_dir ." ".$mizar_base;
		#if ($^O ne "MSWin32") {$cmd="ln -s ".$mizar_base_dir ." ".$mizar_base} else {$cmd="ln -s ".$mizar_base_dir." ".$mizar_base;}
		@result=`$cmd`;
	}
	
 my $base_dir =$bt->comb_dir_file(dir=>$work_dir,file=>'mizar_base');
 
 &cleanup_dir($sequence,$work_dir);
 return $exch_data,$work_dir,$base_dir;
}	
#------------------------------------------------------------------------------
sub run_javadir
{
 local($testdir)=$_[0];
 chdir($testdir);
 
 local($sequence)=99999;
 local($exch_data,$work_dir,$base_dir)=&run_common_cmds();
 local($test)=&execute_java_instance('T',32);
 local($prod)=&execute_java_instance('P',32);
 &compare_run_times($testdir);
 local($base)=gms->new_request(bt=>$bt,seq=>$sequence,source=>$DE,exch_data=>$exch_data,work_dir=>$base_dir,license=>$testdir,ctlfile=>'N');
 $base->read_gms_results;
 &determine_verified();
 &compare_amounts();
 my $linediffFull=&compare_reports($testdir,'F');
 $bt->print_log("End $testdir Position File $sequence",'Y');
return;
}

#------------------------------------------------------------------------------
sub run_javasdir
{
 local($testdir)=$_[0];
 chdir($testdir);
 
  local($exch_data,$work_dir,$base_dir)=&run_common_cmds();
 system("rm $work_dir/*.gms $work_dir/*.full");
 system("cp -R -P $testdir/ps_*.gms $work_dir");
 local($test)=&execute_javas_instance('T',32);
 local($prod)=&execute_javas_instance('P',32);
 &gen_reports($testdir);
 return;
}

#------------------------------------------------------------------------------
sub gen_reports
{
 my $testBuild = $ARGV[1].$ARGV[2];
 local($testdir)=$_[0];
 chdir($testdir);
 opendir (DH,".");			# Open the Work Directory
 while ($DE = readdir(DH))		# Read the next entry
 {
  if ($DE ne "." && $DE ne "..")	# Not the Directory Files
      {
	if ($testBuild !~/v2/){
	if (lc($DE) =~ /^ps_[0-99999]\.gms/)		# starts with
	    {
		my ($name,$path,$suffix) = fileparse(lc($DE),'.gms');
		local($sequence)=substr($name,3,length($name)-3);
 		local($exch_data,$work_dir,$base_dir)=&run_common_cmds();
		#$bt->file_copy(olddir=>$bt->get_cwd,oldname=>$DE,newdir=>$work_dir,newname=>$DE,info=>'N',softLink=>'Y');
		local($test)=&report_gms_instance('T',32);
		local($prod)=&report_gms_instance('P',32);
		&compare_run_times($testdir);
		local($base)=gms->new_request(bt=>$bt,seq=>$sequence,source=>$DE,exch_data=>$exch_data,work_dir=>$base_dir,ctlfile=>'N');
		$base->get_param(parameter=>'gms_rpt_full',value=>'rp_'.$sequence.'.full');
		$base->read_gms_results;
		&determine_verified();
		&compare_amounts();
		my $linediffFull=&compare_reports($testdir,'A');
		$bt->print_log("End $testdir Position File $sequence",'Y');
	    }
	 } 
	elsif ($testBuild =~ /--v2/) {
	if (lc($DE) =~ /^ps_csv[0-99999]/)		# starts with
	    {
		my ($name,$path,$suffix) = fileparse(lc($DE),'.gms');
		local($sequence)=substr($name,3,length($name)-3);
 		local($exch_data,$work_dir,$base_dir)=&run_common_cmds();
		#$bt->file_copy(olddir=>$bt->get_cwd,oldname=>$DE,newdir=>$work_dir,newname=>$DE,info=>'N',softLink=>'Y');
		local($test)=&report_gms_instance('T',32);
		local($prod)=&report_gms_instance('P',32);
		&compare_run_times($testdir);
		local($base)=gms->new_request(bt=>$bt,seq=>$sequence,source=>$DE,exch_data=>$exch_data,work_dir=>$base_dir,ctlfile=>'N');
		$base->get_param(parameter=>'gms_rpt_full',value=>'rp_'.$sequence.'.full');
		$base->read_gms_results;
		&determine_verified();
		&compare_amounts();
		my $linediffFull=&compare_reports($testdir,'A');
		$bt->print_log("End $testdir Position File $sequence",'Y');
	    }
	
	}  
	  
	}
 }
 closedir(DH);
 chdir($bt->cfg_param(parameter=>'ROOT_DIR'));
 return;
}

#------------------------------------------------------------------------------
sub run_testdir
{
 local($testdir)=$_[0];
 chdir($testdir);
 my $command;
 my $exch;
 my $loopCount=0;
 my $testBuild = $ARGV[1].$ARGV[2];
 opendir (DH,".");			# Open the Work Directory
 while ($DE = readdir(DH))		# Read the next entry
 {
  if ($DE ne "." && $DE ne "..")	# Not the Directory Files
      {
	
	 if ($testBuild !~/v2/){
	 
	if (lc($DE) =~ /^ps_[0-99999]\.gms/)		# starts with
	    {
		
		if (lc($DE) eq "ps_0.gms"){
			chdir($testdir."/exch_data");
			$command="ls -p | grep -v / | grep -v cst";
			my @result=`$command`;
			for my $line (@result) 
			{ 
				chop($line); if ($line =~ /^\s*$/) {next;}
				$exch=substr($line,0,3);
                $exch=uc($exch);
                last;
			}

                        my $pos_vol=$bt->cfg_param(parameter=>'POS_VOLUME');
                        my $act_vol=$bt->cfg_param(parameter=>'ACT_VOLUME');
                        my $createPosCmd="run_prd.sh gms_create_data -x".$exch." -l".$act_vol." -r".$pos_vol;

			@result=`$createPosCmd`;
			$bt->print_log("Running command $createPosCmd",'Y');
			$bt->print_log("Generating ps_0.gms Position File with $pos_vol positions",'Y');
			if (-e $testdir."/ps_0.gms") { system("rm $testdir/ps_0.gms");}
			$createPosCmd="mv ".$exch.".pos $testdir/ps_0.gms";
			system($createPosCmd);
			system("rm *_0.gms");
			chdir($testdir);
		}
		my ($name,$path,$suffix) = fileparse(lc($DE),'.gms');
		local($sequence)=substr($name,3,length($name)-3);
 		local($exch_data,$work_dir,$base_dir)=&run_common_cmds();
		#$bt->file_copy(olddir=>$bt->get_cwd,oldname=>$DE,newdir=>$work_dir,newname=>$DE,info=>'N',softLink=>'Y');
		$bt->file_copy(olddir=>$bt->get_cwd,oldname=>$DE,newdir=>$work_dir,newname=>$DE,info=>'N');
		local($test)=&execute_gms_instance('T',32);
		local($prod)=&execute_gms_instance('P',32);
		&compare_run_times($testdir);
		local($base)=gms->new_request(bt=>$bt,seq=>$sequence,source=>$DE,exch_data=>$exch_data,work_dir=>$base_dir,ctlfile=>'N');
		$base->get_param(parameter=>'gms_rpt_full',value=>'rp_'.$sequence.'.full');
		$base->read_gms_results;
		&determine_verified();
		&compare_amounts();
		my $linediffFull=&compare_reports($testdir,'A');
		if (($linediffFull==0)&&($sequence eq "0")) {
			$loopCount++;
			if ($loopCount < $bt->cfg_param(parameter=>'RANDOM_ITERATION')) {redo;}
		}
		$bt->print_log("End $testdir Position File $sequence",'Y');
	    }
	}	
	#MEC File reading starts
	elsif ($testBuild =~ /--v2/) {
	if (lc($DE) =~ /^ps_csv[0-99999]/)		# starts with
	    {
		my ($name,$path,$suffix) = fileparse(lc($DE),'.gms');
		local($sequence)=substr($name,3,length($name)-3);
 		local($exch_data,$work_dir,$base_dir)=&run_common_cmds();
		#$bt->file_copy(olddir=>$bt->get_cwd,oldname=>$DE,newdir=>$work_dir,newname=>$DE,info=>'N',softLink=>'Y');
		$bt->file_copy(olddir=>$bt->get_cwd,oldname=>$DE,newdir=>$work_dir,newname=>$DE,info=>'N');
		local($test)=&execute_gms_instance('T',32);
		local($prod)=&execute_gms_instance('P',32);
		&compare_run_times($testdir);
		local($base)=gms->new_request(bt=>$bt,seq=>$sequence,source=>$DE,exch_data=>$exch_data,work_dir=>$base_dir,ctlfile=>'N');
		$base->get_param(parameter=>'gms_rpt_full',value=>'rp_'.$sequence.'.full');
		$base->read_gms_results;
		&determine_verified();
		&compare_amounts();
		my $linediffFull=&compare_reports($testdir,'A');
		if (($linediffFull==0)&&($sequence eq "0")) {
			$loopCount++;
			if ($loopCount < $bt->cfg_param(parameter=>'RANDOM_ITERATION')) {redo;}
		}
		$bt->print_log("End $testdir Position File $sequence",'Y');
				
		}
	}
	else {$bt->print_log("Invalid Position File $sequence");}
	}
 }
 closedir(DH);
 chdir($bt->cfg_param(parameter=>'ROOT_DIR'));
 return;
}
#------------------------------------------------------------------------------

sub run_inqdir
{
 local($testdir)=$_[0];
 chdir($testdir);
 my $command;
 my $exch;
 my $loopCount=0;
 my $testBuild = $ARGV[1].$ARGV[2]; 
 opendir (DH,".");			# Open the Work Directory
 while ($DE = readdir(DH))		# Read the next entry
 {
  if ($DE ne "." && $DE ne "..")	# Not the Directory Files
      {
	if ($testBuild !~/v2/) {
	if (lc($DE) =~ /^ps_[0-99999]\.gms/)		# starts with
	    {
		
		if (lc($DE) eq "ps_0.gms"){
			chdir($testdir."/exch_data");
			$command="ls -p | grep -v / | grep -v cst";
			my @result=`$command`;
			for my $line (@result) 
			{ 
				chop($line); if ($line =~ /^\s*$/) {next;}
				$exch=substr($line,0,3);
                $exch=uc($exch);
                last;
			}
			my $pos_vol=$bt->cfg_param(parameter=>'POS_VOLUME');
			my $act_vol=$bt->cfg_param(parameter=>'ACT_VOLUME');
			my $createPosCmd="run_prd gms_create_data -x".$exch." -l".$act_vol." -r".$pos_vol;
			@result=`$createPosCmd`;
			$bt->print_log("Running command $createPosCmd",'Y');
			$bt->print_log("Generating ps_0.gms Position File with $pos_vol positions",'Y');	
			if (-e $testdir."/ps_0.gms") { system("rm $testdir/ps_0.gms");}
			$createPosCmd="mv ".$exch.".pos $testdir/ps_0.gms";
			system($createPosCmd);
			system("rm *_0.gms");
			chdir($testdir);
		}
		my ($name,$path,$suffix) = fileparse(lc($DE),'.gms');
		local($sequence)=substr($name,3,length($name)-3);
 		local($exch_data,$work_dir,$base_dir)=&run_common_cmds();
		$bt->file_copy(olddir=>$bt->get_cwd,oldname=>$DE,newdir=>$work_dir,newname=>$DE,info=>'N',softLink=>'Y');
		local($test)=&execute_gms_inq_instance('T',32);
		local($prod)=&execute_gms_inq_instance('P',32);
		&compare_run_times($testdir);
		local($base)=gms->new_request(bt=>$bt,seq=>$sequence,source=>$DE,exch_data=>$exch_data,work_dir=>$base_dir,ctlfile=>'N');
		$base->get_param(parameter=>'gms_rpt_full',value=>'rp_'.$sequence.'.full');
		$base->read_gms_results;
		&determine_verified();
		&compare_amounts();
		my $linediffFull=&compare_reports($testdir,'A');
		if (($linediffFull==0)&&($sequence eq "0")) {
			$loopCount++;
			if ($loopCount < $bt->cfg_param(parameter=>'RANDOM_ITERATION')) {redo;}
		}
		$bt->print_log("End $testdir Position File $sequence",'Y');
	    }
	}	
      
 
 #MEC File reading starts
 elsif ($testBuild =~ /--v2/) {
 if (lc($DE) =~ /^ps_csv[0-99999]/)		# starts with
	    {
		my ($name,$path,$suffix) = fileparse(lc($DE),'.gms');
		local($sequence)=substr($name,3,length($name)-3);
 		local($exch_data,$work_dir,$base_dir)=&run_common_cmds();
		$bt->file_copy(olddir=>$bt->get_cwd,oldname=>$DE,newdir=>$work_dir,newname=>$DE,info=>'N',softLink=>'Y');
		local($test)=&execute_gms_inq_instance('T',32);
		local($prod)=&execute_gms_inq_instance('P',32);
		&compare_run_times($testdir);
		local($base)=gms->new_request(bt=>$bt,seq=>$sequence,source=>$DE,exch_data=>$exch_data,work_dir=>$base_dir,ctlfile=>'N');
		$base->get_param(parameter=>'gms_rpt_full',value=>'rp_'.$sequence.'.full');
		$base->read_gms_results;
		&determine_verified();
		&compare_amounts();
		my $linediffFull=&compare_reports($testdir,'A');
		if (($linediffFull==0)&&($sequence eq "0")) {
			$loopCount++;
			if ($loopCount < $bt->cfg_param(parameter=>'RANDOM_ITERATION')) {redo;}
		}
		$bt->print_log("End $testdir Position File $sequence",'Y');
	    }
 }
 else {$bt->print_log("Invalid Position File $sequence");}
 }
 }
 closedir(DH);
 chdir($bt->cfg_param(parameter=>'ROOT_DIR'));
 return;
}
#------------------------------------------------------------------------------

sub run_icedir
{
 local($testdir)=$_[0];
 chdir($testdir);
 opendir (DH,".");			# Open the Work Directory
 while ($DE = readdir(DH))		# Read the next entry
 {
  if ($DE ne "." && $DE ne "..")	# Not the Directory Files
      {
		if ($testBuild !~/v2/) {
		
		if (lc($DE) =~ /^ps_[0-99999]\.gms/)		# starts with
	    {
			my ($name,$path,$suffix) = fileparse(lc($DE),'.gms');
			local($sequence)=substr($name,3,length($name)-3);
			local($exch_data,$work_dir,$base_dir)=&run_common_cmds();
			$bt->file_copy(olddir=>$bt->get_cwd,oldname=>$DE,newdir=>$work_dir,newname=>$DE,info=>'N',softLink=>'Y');
			local($test)=&execute_gms_ice_instance('T',32);
			local($prod)=&execute_gms_ice_instance('P',32);
			&compare_run_times($testdir);
			local($base)=gms->new_request(bt=>$bt,seq=>$sequence,source=>$DE,exch_data=>$exch_data,work_dir=>$base_dir,ctlfile=>'N');
			$base->get_param(parameter=>'gms_rpt_full',value=>'rp_'.$sequence.'.full');
			$base->read_gms_results;
			&determine_verified();
			&compare_amounts();
			my $linediffFull=&compare_reports($testdir,'A');
			$bt->print_log("End $testdir Position File $sequence",'Y');
		}
      }
	#MEC File reading starts  
	elsif ($testBuild =~ /--v2/) {
	if (lc($DE) =~ /^ps_csv[0-99999]/)		# starts with
		{
			my ($name,$path,$suffix) = fileparse(lc($DE),'.gms');
			local($sequence)=substr($name,3,length($name)-3);
			local($exch_data,$work_dir,$base_dir)=&run_common_cmds();
			$bt->file_copy(olddir=>$bt->get_cwd,oldname=>$DE,newdir=>$work_dir,newname=>$DE,info=>'N',softLink=>'Y');
			local($test)=&execute_gms_ice_instance('T',32);
			local($prod)=&execute_gms_ice_instance('P',32);
			&compare_run_times($testdir);
			local($base)=gms->new_request(bt=>$bt,seq=>$sequence,source=>$DE,exch_data=>$exch_data,work_dir=>$base_dir,ctlfile=>'N');
			$base->get_param(parameter=>'gms_rpt_full',value=>'rp_'.$sequence.'.full');
			$base->read_gms_results;
			&determine_verified();
			&compare_amounts();
			my $linediffFull=&compare_reports($testdir,'A');
			$bt->print_log("End $testdir Position File $sequence",'Y');
	
		}
	}
	
	}
}
 closedir(DH);
 chdir($bt->cfg_param(parameter=>'ROOT_DIR'));
 return;
}


sub determine_verified
{
 my $vf_file="vf_".$sequence.".verified";
 $base->get_param(parameter=>'VERIFIED',value=>$bt->file_exists(dir=>$base_dir,file=>$vf_file,info=>'N'));
 return;
}
#------------------------------------------------------------------------------
sub compare_reports
{
 my $testdir=$_[0];
 my $linediffFull,$linediff;
 my $rpt_type=uc($_[1]);
 if (($rpt_type eq "A")&&($bt->cfg_param(parameter=>'COMPARE_FULL') eq "Y")) { $linediffFull=&compare_rpt_actual($testdir,"gms_rpt_full","Full"); }
 $linediff=&compare_rpt_actual($testdir,"gms_mgn_file","Margin");
 #$linediff=&compare_rpt_actual($testdir,"job_log_file","log");
 $linediff=&compare_rpt_actual($testdir,"gms_rpt_file","Total");
 return $linediffFull;
}
#------------------------------------------------------------------------------
sub compare_rpt_actual
{
 my $testdir=$_[0];
 my $variable=$_[1];
 my $type=$_[2];
 my $linediff;
 my $bf;
 if ($^O ne "MSWin32")  { $bf=$bt->comb_dir_file(dir=>$base->get_param(parameter=>'work_dir'),file=>$base->get_param(parameter=>$variable))}
 else { $bf=$bt->comb_dir_file(dir=>$testdir."\\mizar\\base",file=>$base->get_param(parameter=>$variable));}
 my $tf=$bt->comb_dir_file(dir=>$test->get_param(parameter=>'work_dir'),file=>$test->get_param(parameter=>$variable));
 my $pf=$bt->comb_dir_file(dir=>$prod->get_param(parameter=>'work_dir'),file=>$prod->get_param(parameter=>$variable));
 if (($type ne "log")&&($bt->cfg_param(parameter=>'COMPARE_BASE') eq "Y")&&($sequence ne "0")) { $linediff=&run_rpt_compare($bf,$tf,"tst","base",$testdir,$type);}
 $linediff=&run_rpt_compare($tf,$pf,"tst","prd",$testdir,$type);
 return $linediff;
}
#------------------------------------------------------------------------------
sub run_rpt_compare
{
 my $sf=$_[0];
 my $tf=$_[1];
 my $sn=$_[2];
 my $tn=$_[3];
 my $testdir=$_[4];
 my $type=$_[5];
 my $sq=$base->get_param(parameter=>'seq');
 my $findDir;
 my $cmd;
 my $thisTestName;
#if ($tn eq "base") {if ($sf=~/csv/){$sf=~ s/csv//g;}} 
 #if ($sf=~/csv/){$sf=~ s/csv//g;}
 if ($sq eq "") {$sq=0;}
 if ($^O ne "MSWin32")  {
	 @arrStr=split('/',$testdir);
	 $thisTestName=pop(@arrStr);
			
	#### FOR EMPTY TST REPORT
	if ($tn eq "prd"){
		@arrStr=split('/',$sf);
		$findDir=$testdir."/".$bt->get_param(parameter=>'HOST');
		if(-e $sf){
		  if (-z $sf){
			$bt->print_log("REPORT ERROR $thisTestName --> THE TST REPORT $type IS EMPTY FOR $sq(Report)",'Y');
		  }
		}
	else{
			$bt->print_log("REPORT ERROR $thisTestName --> THE TST $type REPORT NOT CREATED FOR $sq(Report)",'Y');
		}
	}
}
else{
	@arrStr=split(/\\/,$testdir);
	 $thisTestName=pop(@arrStr);
	#### FOR EMPTY TST REPORT
		if ($tn eq "prd"){
			@arrStr=split(/\\/,$sf);
			$findDir=$testdir."\\".$bt->get_param(parameter=>'HOST');
			if(-e $sf){
				$cmd="for %I in ($sf) do %~zI";
				$result=`$cmd`;
				 chomp($result);
				 @result = (split(/>/, $result));
				 my $arrPop=pop(@result);
					if($arrPop==0){
						$bt->print_log("REPORT ERROR $arrStr[5] --> THE REPORT $arrStr[7] IS EMPTY FOR $sq(Report)",'Y');
					}
			}	
			else{
					$bt->print_log("REPORT ERROR $arrStr[5] --> THE TST $type REPORT NOT CREATED FOR $sq(Report)",'Y');
				}
		}
};
#### FOR EMPTY PRD REPORT 
 if ($^O ne "MSWin32")  {
 @arrStr=split("/",$tf);
if(-e $tf){
	if (-z $tf){
		$bt->print_log("REPORT ERROR $thisTestName --> THE PRD REPORT $type IS EMPTY FOR $sq(Report)",'Y');
	}
}

else{
		$bt->print_log("REPORT ERROR $thisTestName --> THE PRD $type REPORT  NOT CREATED FOR $sq(Report)",'Y');
	}
}
else{
	@arrStr=split(/\\/,$tf);
	$findDir=$testdir."\\".$bt->get_param(parameter=>'HOST');
		if(-e $sf){
		$cmd="for %I in ($tf) do %~zI";
		$result=`$cmd`;
		chomp($result);
		@result = (split(/>/, $result));
		my $arrPop=pop(@result);
		if($arrPop==0){
		$bt->print_log("REPORT ERROR $arrStr[5] --> THE REPORT $arrStr[7] IS EMPTY FOR $sq(Report)",'Y');
			}
		}	
		else{
		$bt->print_log("REPORT ERROR $arrStr[5] --> THE TST $type REPORT NOT CREATED FOR $sq(Report)",'Y');
			}
}
##Grep does not work on windows. Script updated	
 if ($type eq "Margin"){	
 	if ($^O ne "MSWin32") {$cmd="diff $sf $tf | grep -v \"^> 000105\" | grep -v \"^> 000004\" | grep -v \"^< 000105\" | grep -v \"^< 000004\" |  grep -v 000001[0-9][0-9][0-9][0-9][0-9][0-9]GMSGMI | grep -v \"INFORMATION 0041\" | egrep \"<|>\" | wc -l";
		$nd=`$cmd`;
		chomp($nd);
	}
	else {$cmd="fc $sf $tf > diff.txt";
		$nd=`$cmd`;
		$cmd = "find /c /i \"$tf\" \"$testdir\\diff.txt\"";
		$output=`$cmd`;
		$output =~ /:\s(\d{1,})\s/;
		$nd = $1-1;};
	}
 else{
	if ($^O ne "MSWin32") {$cmd="diff $sf $tf | grep -v \"End of Report\" |  grep -v 000001[0-9][0-9][0-9][0-9][0-9][0-9]GMSGMI | grep -v \"INFORMATION 0041\"  | egrep -v \"PRD_WS|BRN_WS|PRD_VER|BRN_VER|PRD_HOME|BRN_HOME|PRD_BUILD|BRN_BUILD|GMS_DIR|IMAGE|CLASSPATH|LD_LIBRARY_PATH|INFORMATION\" | egrep \"<|>\" | wc -l";
		$nd=`$cmd`;
		chomp($nd);
	}
	else {$cmd="fc $sf $tf > diff.txt";
		$nd=`$cmd`;
		$cmd = "find /c /i \"$tf\" \"$testdir\\diff.txt\"";
		$output=`$cmd`;
		$output =~ /:\s(\d{1,})\s/;
		$nd = $1-1;};
	 };
 my $line=sprintf("Test (%4s/%4s %-5s) %s %s has %d lines with differences",$sn,$tn,$type,$testdir,$sq,$nd);
 my $pref="INFO:";
 my $diff_today=$findDir."/today_".$sq.".diff";
 my $diff_yesterday=$findDir."/yesterday_".$sq.".diff";
if ($nd > 0) { 
	if ($base->get_param(parameter=>'VERIFIED') != 0) { 
		$pref="ERROR VERIFIED:"; 
		$bt->print_log("$pref $line",'Y');
	} 
	$pref="ERROR:"; 
	if (($type eq "Full")&&($tn eq "prd")) {
		if(-e $diff_today){
			$cmd="mv $diff_today $diff_yesterday";
			system($cmd);
		}
		if((-s $sf)&&(-s $tf)){
			$cmd="diff $sf $tf | grep -v \"End of Report\" | grep -v 000001[0-9][0-9][0-9][0-9][0-9][0-9]GMSGMI | grep -v \"INFORMATION 0041\" > $diff_today";
			system($cmd);
		}
		if(-e $diff_yesterday){
			$cmd="diff $diff_today $diff_yesterday | egrep \"<|>\" | wc -l";
			my $nd1=`$cmd`;
			chomp($nd1);
			if ($nd1 > 0) {
				my $sq_new= $sq."(new)";
				$line=sprintf("Test (%4s/%4s %-5s) %s %s has %d lines with differences",$sn,$tn,$type,$testdir,$sq_new,$nd);
				my $diff_archive=$findDir."/".$bt->cfg_param(parameter=>'BUSDATE')."_yesterday_".$sq.".diff";
				system("cp $diff_yesterday $diff_archive");
			}
		}
	}
}
if (($nd == 0)&&($tn eq "prd")&&(-e $diff_today)&&($type eq "Full")) {	
	$cmd="rm ".$findDir."/*_".$sq.".diff";
	system($cmd);
}
$bt->print_log("$pref $line",'Y');
 return $nd;
}
#------------------------------------------------------------------------------
sub compare_amounts
{
 my $trs=$test->get_param(parameter=>'RESULT');
 my $prs=$prod->get_param(parameter=>'RESULT');
 my $brs=$base->get_param(parameter=>'RESULT');
 for my $ac (keys %{$trs}) 
   { for my $mt (keys %{${$trs}{$ac}})
       {  for my $cy (keys %{${$trs}{$ac}{$mt}})
            { $tamt= ${$trs}{$ac}{$mt}{$cy};
              $pamt= ${$prs}{$ac}{$mt}{$cy};
              $bamt= ${$brs}{$ac}{$mt}{$cy};
              if ($bamt ne $tamt) { &gen_diff_line('T',$bamt,$tamt,$ac,$mt,$cy); }
              if ($bamt ne $pamt) { &gen_diff_line('P',$bamt,$pamt,$ac,$mt,$cy); }
            }
        }
   }
 return;
}
#------------------------------------------------------------------------------
sub gen_diff_line
{
 my $base_amt=sprintf("%15.2f",$_[1]);
 my $test_amt=sprintf("%15.2f",$_[2]);
 my $diff_amt=$base_amt-$test_amt;
 $diff_amt=sprintf("%15.2f",$diff_amt);
 my $bap=&fmt_amount_print($base_amt);
 my $tap=&fmt_amount_print($test_amt);
 my $dap=&fmt_amount_print($diff_amt);
 my $ftype;
 my ($tc,$dir,$sf) = fileparse($testdir,'');
 if ($_[0] eq "T") { $ftype = "TEST"; }
 if ($_[0] eq "P") { $ftype = "PROD"; }
 my $pref="ERROR:";
 if ($base->get_param(parameter=>'VERIFIED') == 1) { $pref="ERROR VERIFIED:"; }
 my $line=sprintf("%s BASE vs %4s DIFF:%18s %s S:%5s A:%-20s M:%3s C:%3s B:%18s %s:%18s",$pref,$ftype,$dap,$tc,$sequence,$_[3],$_[4],$_[5],$bap,uc($_[0]),$tap);
 $bt->print_log($line);
}
#------------------------------------------------------------------------------
sub fmt_amount_print
{
 my $text = reverse $_[0];
 $text =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
 return reverse $text;
}
#------------------------------------------------------------------------------
sub run_java_gms
{
 my $jdir=$_[0];
 if ($^O ne "MSWin32") 
		{ 	 $orig_ldlp=$bt->get_env_var(env=>'LD_LIBRARY_PATH');
			 $orig_classpath=$bt->get_env_var(env=>'CLASSPATH')}
		else {$orig_ldlp=$bt->get_env_var(env=>'PATH');
		 $orig_classpath=$bt->get_env_var(env=>'LIB_DIR');}
 
 my $ldlp;
 if (defined $req->get_param(parameter=>'library'))
    { $ldlp=$req->get_param(parameter=>'library').":".$orig_ldlp;
      
	  if ($^O ne "MSWin32") 
		{$bt->get_env_var(env=>'LD_LIBRARY_PATH',value=>$ldlp)}
		else { $bt->get_env_var(env=>'PATH',value=>$ldlp);}
	  
      $bt->get_env_var(env=>'LIBPATH',value=>$ldlp);
    }
 $bt->get_env_var(env=>'GMS_SITEID',value=>$req->get_param(parameter=>'site'));
 if (defined $req->get_param(parameter=>'license'))
    { $bt->get_env_var(env=>'SUNGARD_LICENSE',value=>$req->get_param(parameter=>'license')); }
 my $cwd=$req->get_param(parameter=>'work_dir');
 chdir($cwd);
 $req->get_param(parameter=>'gms_success',value=>1);
 my $cmd_prefix;
 if ($^O ne "MSWin32")  { $cmd_prefix="2>&1 time "; 
  $command=$cmd_prefix." java -classpath ". $orig_classpath.":".$jdir."/gmsAPI.jar:".$cwd." sampleIMC"; }
 else {  $command=$cmd_prefix." java -classpath ". $orig_classpath.";".$orig_classpath."\\gmsIceLink.jar;".$orig_classpath."\\gmsAPI.jar;".$cwd."\\sampleIMC";}
 my @result=`$command`;
 $bt->print_log("===> GMS Execution");
 for my $line (@result) 
    { chop($line); if ($line =~ /^\s*$/) {next;}
      $bt->print_log("$line","Y");
      if ($line =~ /^sys*/) { $line =~ s/\s+/ /g; my ($value,$timer) = split (/ /,$line); $req->get_param(parameter=>'gms_run_time',value=>$timer); }
      elsif ($line =~ /system (\d*):(\d*)\.(\d*)/) { my $timer=sprintf ("%s:%s.%s",$1,$2,$3); $req->get_param(parameter=>'gms_run_time',value=>$timer); }
    }
 $req->_collect_logs;
 $req->_gen_res_file;
 $bt->get_env_var(env=>'LD_LIBRARY_PATH',value=>$orig_ldlp);
 chdir($orig_dir);
 return;
}
#------------------------------------------------------------------------------
sub run_javas_gms
{
 my $type=$_[0];
 my $jdir=$req->get_param(parameter=>'gms_dir');
 my $orig_ldlp=$bt->get_env_var(env=>'LD_LIBRARY_PATH');
 my $orig_classpath=$bt->get_env_var(env=>'CLASSPATH');
 my $ldlp;
 my $testBuild = $ARGV[1].$ARGV[2];
 if (defined $req->get_param(parameter=>'library'))
    { $ldlp=$req->get_param(parameter=>'library').":".$orig_ldlp;
      $bt->get_env_var(env=>'LD_LIBRARY_PATH',value=>$ldlp);
      $bt->get_env_var(env=>'LIBPATH',value=>$ldlp);
    }
 my $classpath=$orig_classpath.":".$jdir."/gmsAPI.jar:".$req->get_param(parameter=>'library')."/gmsIMC.jar";
 $bt->get_env_var(env=>'GMS_SITEID',value=>$req->get_param(parameter=>'site'));
 $bt->get_env_var(env=>'SITE_ID',value=>$req->get_param(parameter=>'site'));
 if (defined $req->get_param(parameter=>'license'))
    { $bt->get_env_var(env=>'SUNGARD_LICENSE',value=>$req->get_param(parameter=>'license')); }
 my $cwd=$req->get_param(parameter=>'work_dir');
 chdir($cwd);
 
 #### Full report creation #######
 if ($bt->file_exists(dir=>$bt->get_cwd,file=>$type,info=>'N') == 0) { system("mkdir $type");} 
 system("cp -R -P $cwd/ps_*.gms $cwd/$type/.");
 $req->get_param(parameter=>'gms_success',value=>1);
 my $cmd_prefix;
 if ($type eq "P")  { 
	 	if ($^O eq "MSWin32") {$cmd_prefix="run_prd.bat" ;}
		else {$cmd_prefix="2>&1 time run_prd.sh" ;}
		if ($^O eq "os400") {$cmd_prefix=". /appsdev/prdadmin/scripts/run_prd_400.sh" ;}
 } 
 else{
 	if ($^O eq "MSWin32") {$cmd_prefix="run_brn.bat" ;}
	else {$cmd_prefix="2>&1 time run_brn.sh" ;}
	if ($^O eq "os400") {$cmd_prefix=". /appsdev/prdadmin/scripts/run_brn_400.sh" ;}
 }
 if ("$ENV{'DATA_MODEL'}" eq 64) {$comPrefix = "-d64"} else {$comPrefix = " "};
 if ($testBuild =~ /--v2/){
	#my $command=$cmd_prefix." java -classpath ". $classpath. " com.sungard.gms.client.gmsIMC -p".$cwd." -e".$req->get_param(parameter=>'exch_data')." -a".$req->get_param(parameter=>'addl_data')." -c".$req->get_param(parameter=>'cust_data')." -o".$cwd."/".$type." -rCR -f";
	$command=$cmd_prefix." java ".$comPrefix." com.sungard.gms.client.gmsIMC_V2 -p".$cwd."/csv -e".$req->get_param(parameter=>'exch_data')." -a".$req->get_param(parameter=>'addl_data')." -c".$req->get_param(parameter=>'cust_data')." -o".$cwd."/".$type." -rCR -f";}
else {$command=$cmd_prefix." java ".$comPrefix." com.sungard.gms.client.gmsIMC -p".$cwd." -e".$req->get_param(parameter=>'exch_data')." -a".$req->get_param(parameter=>'addl_data')." -c".$req->get_param(parameter=>'cust_data')." -o".$cwd."/".$type." -rCR -f";}
my @result=`$command`;
$bt->print_log("===> GMS Execution");
 for my $line (@result) 
    { chop($line); if ($line =~ /^\s*$/) {next;}
      $bt->print_log("$line","Y");
      if ($line =~ /^sys*/) { $line =~ s/\s+/ /g; my ($value,$timer) = split (/ /,$line); $req->get_param(parameter=>'gms_run_time',value=>$timer); }
      elsif ($line =~ /system (\d*):(\d*)\.(\d*)/) { my $timer=sprintf ("%s:%s.%s",$1,$2,$3); $req->get_param(parameter=>'gms_run_time',value=>$timer); }
    }
 $req->_collect_logs;
 $req->_gen_res_file;

 #### Total report creation #######
 chdir($cwd."/".$type);
 if ($bt->file_exists(dir=>$bt->get_cwd,file=>'total',info=>'N') == 0) { system("mkdir total");} 
   system("ln -s $cwd/$type/mg_*.gms $cwd/$type/total/.");
chdir($cwd);
#my $command=$cmd_prefix." java -classpath ". $classpath. " com.sungard.gms.client.gmsIMC -p".$cwd."/".$type." -e".$req->get_param(parameter=>'exch_data')." -a".$req->get_param(parameter=>'addl_data')." -c".$req->get_param(parameter=>'cust_data')." -o".$cwd."/".$type."/total -rR -t";
 if ($testBuild =~ /--v2/){my $command=$cmd_prefix." java ".$comPrefix." com.sungard.gms.client.gmsIMC_V2 -p".$cwd."/".$type." -e".$req->get_param(parameter=>'exch_data')." -a".$req->get_param(parameter=>'addl_data')." -c".$req->get_param(parameter=>'cust_data')." -o".$cwd."/".$type."/total -rR -t";}
 else {my $command=$cmd_prefix." java ".$comPrefix." com.sungard.gms.client.gmsIMC -p".$cwd."/".$type." -e".$req->get_param(parameter=>'exch_data')." -a".$req->get_param(parameter=>'addl_data')." -c".$req->get_param(parameter=>'cust_data')." -o".$cwd."/".$type."/total -rR -t";}
my @result=`$command`;
system("rm $cwd/$type/total/mg_*.gms");
#system("rm $cwd/$type/total/ps_*.gms");
$bt->print_log("===> GMS Execution");
 for my $line (@result) 
    { chop($line); if ($line =~ /^\s*$/) {next;}
      $bt->print_log("$line","Y");
      if ($line =~ /^sys*/) { $line =~ s/\s+/ /g; my ($value,$timer) = split (/ /,$line); $req->get_param(parameter=>'gms_run_time',value=>$timer); }
      elsif ($line =~ /system (\d*):(\d*)\.(\d*)/) { my $timer=sprintf ("%s:%s.%s",$1,$2,$3); $req->get_param(parameter=>'gms_run_time',value=>$timer); }
    }
 $req->_collect_logs;
####################################
 $bt->get_env_var(env=>'LD_LIBRARY_PATH',value=>$orig_ldlp);
 chdir($orig_dir);
 return;
}

#------------------------------------------------------------------------------
sub execute_java_instance
{
 my $type=$_[0];
 my $bit =$_[1];
my $orig_ldlp;
 local($rt) = basetool->new;
 my $gms_image,$gms_library,$gms_jdir;
 if (uc($type) eq "T")
    { 	
		if ($^O eq "MSWin32") {$gms_image="run_brn.bat imc" ;}
			else {$gms_image="run_brn.sh imc" ;}
			if ($^O eq "os400") {$gms_image=". /appsdev/prdadmin/scripts/run_brn_400.sh imc" ;}
		$gms_jdir=$bt->cfg_param(parameter=>'TST_JAR_DIR'); 
	}
      
 if (uc($type) eq "P")
    { 	
		if ($^O eq "MSWin32") {$gms_image="run_prd.bat imc" ;}
			else {$gms_image="run_prd.sh imc" ;}
			if ($^O eq "os400") {$gms_image=". /appsdev/prdadmin/scripts/run_prd_400.sh imc" ;}
		$gms_jdir=$bt->cfg_param(parameter=>'PRD_JAR_DIR');
	}
local($req)=gms->new_request(bt=>$rt,seq=>$sequence,source=>'sampleIMC.java',exch_data=>$exch_data,work_dir=>$work_dir,gms_image=>$gms_image,gms_library=>$gms_library,site=>$bt->cfg_param(parameter=>'GMS_API_SITEID'),license=>$bt->cfg_param(parameter=>'CFG_DIR'));
&manage_log_files($type);
$orig_ldlp=$req->_set_ice_environment;
 &run_java_gms($gms_jdir);

 my $testLog=$work_dir."/".$req->get_param(parameter=>'job_log_file');
 my $cmd="grep ".$bt->cfg_param(parameter=>'BUSDATE')." ".$testLog." | grep ERROR | wc -l";
 my $nd=`$cmd`;
 chomp($nd);
 if ($nd > 0) {
        @arrStr=split('/',$testdir);
        my $thisTestName=pop(@arrStr);
        $bt->print_log("REPORT ERROR $thisTestName --> THE LOG IS SHOWING $nd ERRORS FOR RUNID $sequence(LOG)",'Y');
 }

 if ($req->get_param(parameter=>'gms_success') == 1)
    { $bt->print_log("ERROR: GMS failed for $DE $testdir $sequence ".$bt->get_param(parameter=>'HOST'));
      $bt->print_log("ERROR: Check ".$work_dir." ".$req->get_param(parameter=>'job_log_file')); }
 else
    { $req->read_gms_results; }
 &rename_work_files(type=>$type,files=>'all',adjust=>'y');
 return $req;
}

#------------------------------------------------------------------------------
sub execute_javas_instance
{
 my $type=$_[0];
 my $bit =$_[1];
my $orig_ldlp;
 local($rt) = basetool->new;
 my $gms_image,$gms_library,$gms_jdir;
 if (uc($type) eq "T")
    { #
	 $gms_image=$bt->cfg_param(parameter=>'TST_EXE');
      $gms_library=$bt->cfg_param(parameter=>'TST_LIBRARY_PATH');
      $gms_jdir=$bt->cfg_param(parameter=>'TST_JAR_DIR');} 
 if (uc($type) eq "P")
    { $gms_image=$bt->cfg_param(parameter=>'PRD_EXE');
      $gms_library=$bt->cfg_param(parameter=>'PRD_LIBRARY_PATH');
      $gms_jdir=$bt->cfg_param(parameter=>'PRD_JAR_DIR');}
 local($req)=gms->new_request(bt=>$rt,source=>$DE,exch_data=>$exch_data,addl_data=>$exch_data,cust_data=>$exch_data,work_dir=>$work_dir,gms_image=>$gms_image,gms_library=>$gms_library,site=>$bt->cfg_param(parameter=>'GMS_SITEID'),license=>$bt->cfg_param(parameter=>'CFG_DIR'),gms_dir=>$gms_jdir);
 &manage_log_files($type);
 &run_javas_gms($type);

 my $testLog=$work_dir."/".$req->get_param(parameter=>'job_log_file');
 my $cmd="grep ".$bt->cfg_param(parameter=>'BUSDATE')." ".$testLog." | grep ERROR | wc -l";
 my $nd=`$cmd`;
 chomp($nd);
 if ($nd > 0) {
        @arrStr=split('/',$testdir);
        my $thisTestName=pop(@arrStr);
        $bt->print_log("REPORT ERROR $thisTestName --> THE LOG IS SHOWING $nd ERRORS FOR RUNID 0(LOG)",'Y');
 }

 return $req;
}
#------------------------------------------------------------------------------
sub execute_gms_instance
{
 my $type=$_[0];
 my $bit =$_[1];
 local($rt) = basetool->new;
 my $gms_image,$gms_library;
 if (uc($type) eq "T"){  
		if ($^O eq "MSWin32") {$gms_image="run_brn.bat imc" ;}
		else {$gms_image="run_brn.sh imc" ;}
		if ($^O eq "os400") {$gms_image=". /appsdev/prdadmin/scripts/run_brn_400.sh imc" ;}
			$gms_jdir=$bt->cfg_param(parameter=>'TST_JAR_DIR'); 
			$gms_dir=$bt->cfg_param(parameter=>'TST_XML_STYLES'); 
			#$gms_library=$bt->cfg_param(parameter=>'TST_LIBRARY_PATH');
			$gms_dir=$bt->cfg_param(parameter=>'TST_XML_STYLES');	
	}	
 if (uc($type) eq "P"){  
	if ($^O eq "MSWin32") {$gms_image="run_prd.bat imc" ;}
	else {$gms_image="run_prd.sh imc" ;}
	if ($^O eq "os400") {$gms_image=". /appsdev/prdadmin/scripts/run_prd_400.sh imc" ;}
	$gms_jdir=$bt->cfg_param(parameter=>'PRD_JAR_DIR');
      #$gms_library=$bt->cfg_param(parameter=>'PRD_LIBRARY_PATH');
      $gms_dir=$bt->cfg_param(parameter=>'PRD_XML_STYLES'); 
 }
 local($req)=gms->new_request(bt=>$rt,seq=>$sequence,source=>$DE,exch_data=>$exch_data,addl_data=>$exch_data,cust_data=>$exch_data,work_dir=>$work_dir,gms_image=>$gms_image,gms_library=>$gms_library,site=>$bt->cfg_param(parameter=>'GMS_SITEID'),license=>$bt->cfg_param(parameter=>'CFG_DIR'),report_type=>$bt->cfg_param(parameter=>'REPORT_TYPE'),run_mode=>$bt->get_param(parameter=>'MODE'),gms_dir=>$gms_dir,gms_jdir=>$gms_jdir);
 &manage_log_files($type);
 $req->execute_gms;

 my $testLog=$work_dir."/".$req->get_param(parameter=>'job_log_file');
 my $cmd="grep ".$bt->cfg_param(parameter=>'BUSDATE')." ".$testLog." | grep ERROR | wc -l";
 my $nd=`$cmd`;
 chomp($nd);
 if ($nd > 0) { 
	@arrStr=split('/',$testdir);
	my $thisTestName=pop(@arrStr);
	$bt->print_log("REPORT ERROR $thisTestName --> THE LOG IS SHOWING $nd ERRORS FOR RUNID $sequence(Log)",'Y');
 }

 if ($req->get_param(parameter=>'gms_success') == 1)
    { $bt->print_log("ERROR: GMS failed for $DE $testdir $sequence ".$bt->get_param(parameter=>'HOST'));
      $bt->print_log("ERROR: Check ".$work_dir." ".$req->get_param(parameter=>'job_log_file')); }
 else
    { $req->read_gms_results;
      &rename_work_files(type=>$type,files=>'rpt',adjust=>'n');
      $req->gen_summary_rpt; }
 &rename_work_files(type=>$type,files=>'all',adjust=>'y');
 return $req;
}
#------------------------------------------------------------------------------

sub report_gms_instance
{
 my $type=$_[0];
 my $bit =$_[1];
 local($rt) = basetool->new;
 my $gms_image,$gms_library;
 local($req)=gms->new_request(bt=>$rt,seq=>$sequence,source=>$DE,exch_data=>$exch_data,addl_data=>$exch_data,cust_data=>$exch_data,work_dir=>$work_dir,gms_image=>$gms_image,gms_library=>$gms_library,site=>$bt->cfg_param(parameter=>'GMS_SITEID'),license=>$bt->cfg_param(parameter=>'CFG_DIR'),gms_dir=>$gms_dir);
 #&manage_log_files($type);
 $req->report_gms($type);
	$req->read_gms_results;
      &rename_work_files(type=>$type,files=>'rpt',adjust=>'n');
      $req->report_gms_summary($type); 
 &rename_work_files(type=>$type,files=>'all',adjust=>'y');
 return $req;
}
#------------------------------------------------------------------------------

sub execute_gms_inq_instance
{
 my $type=$_[0];
 my $bit =$_[1];
 local($rt) = basetool->new;
 my $gms_image,$gms_library;
 if (uc($type) eq "T")
    { 
	 	if ($^O eq "MSWin32") {$gms_image="run_brn.bat imc" ;}
		else {$gms_image="run_brn.sh imc" ;}
		if ($^O eq "os400") {$gms_image=". /appsdev/prdadmin/scripts/run_brn_400.sh imc" ;}
	  #$gms_image=$bt->cfg_param(parameter=>'TST_EXE');
      #$gms_library=$bt->cfg_param(parameter=>'TST_LIBRARY_PATH');
      $gms_dir=$bt->cfg_param(parameter=>'TST_XML_STYLES'); }
 if (uc($type) eq "P")
    { 
	 	if ($^O eq "MSWin32") {$gms_image="run_prd.bat imc" ;}
		else {$gms_image="run_prd.sh imc" ;}
		if ($^O eq "os400") {$gms_image=". /appsdev/prdadmin/scripts/run_prd_400.sh imc" ;}
	  #$gms_image=$bt->cfg_param(parameter=>'PRD_EXE');
      #$gms_library=$bt->cfg_param(parameter=>'PRD_LIBRARY_PATH');
      $gms_dir=$bt->cfg_param(parameter=>'PRD_XML_STYLES'); 
	}
 local($req)=gms->new_request(bt=>$rt,seq=>$sequence,source=>$DE,exch_data=>$exch_data,addl_data=>$exch_data,cust_data=>$exch_data,work_dir=>$work_dir,gms_image=>$gms_image,gms_library=>$gms_library,site=>$bt->cfg_param(parameter=>'GMS_SITEID'),license=>$bt->cfg_param(parameter=>'CFG_DIR'),run_mode=>$bt->get_param(parameter=>'MODE'),gms_dir=>$gms_dir);
 &manage_log_files($type);
 $req->execute_inq_gms;

 my $testLog=$work_dir."/".$req->get_param(parameter=>'job_log_file');
 my $cmd="grep ".$bt->cfg_param(parameter=>'BUSDATE')." ".$testLog." | grep ERROR | wc -l";
 my $nd=`$cmd`;
 chomp($nd);
 if ($nd > 0) {
        @arrStr=split('/',$testdir);
        my $thisTestName=pop(@arrStr);
        $bt->print_log("REPORT ERROR $thisTestName--> THE LOG IS SHOWING $nd ERRORS FOR RUNID $sequence(LOG)",'Y');
 }

  
 if ($req->get_param(parameter=>'gms_success') == 1)
    { $bt->print_log("ERROR: GMS failed for $DE $testdir $sequence ".$bt->get_param(parameter=>'HOST'));
      $bt->print_log("ERROR: Check ".$work_dir." ".$req->get_param(parameter=>'job_log_file')); }
 else
    { $req->read_gms_results;
      &rename_work_files(type=>$type,files=>'rpt',adjust=>'n');
      $req->gen_summary_rpt; }
 &rename_work_files(type=>$type,files=>'all',adjust=>'y');
 return $req;
}

#------------------------------------------------------------------------------
sub execute_gms_ice_instance
{
 my $type=$_[0];
 my $bit =$_[1];
 local($rt) = basetool->new;
 my $gms_image,$gms_library;
 if (uc($type) eq "T")
    { $gms_image=$bt->cfg_param(parameter=>'TST_EXE');
      $gms_library=$bt->cfg_param(parameter=>'TST_LIBRARY_PATH');
      $gms_dir=$bt->cfg_param(parameter=>'TST_XML_STYLES'); }
 if (uc($type) eq "P")
    { $gms_image=$bt->cfg_param(parameter=>'PRD_EXE');
      $gms_library=$bt->cfg_param(parameter=>'PRD_LIBRARY_PATH');
      $gms_dir=$bt->cfg_param(parameter=>'PRD_XML_STYLES'); }
 local($req)=gms->new_request(bt=>$rt,seq=>$sequence,source=>$DE,exch_data=>$exch_data,addl_data=>$exch_data,cust_data=>$exch_data,work_dir=>$work_dir,gms_image=>$gms_image,gms_library=>$gms_library,site=>$bt->cfg_param(parameter=>'GMS_SITEID'),license=>$bt->cfg_param(parameter=>'CFG_DIR'),gms_dir=>$gms_dir);
 &manage_log_files($type);
 $req->execute_ice_gms;

 my $testLog=$work_dir."/".$req->get_param(parameter=>'job_log_file');
 my $cmd="grep ".$bt->cfg_param(parameter=>'BUSDATE')." ".$testLog." | grep ERROR | wc -l";
 my $nd=`$cmd`;
 chomp($nd);
 if ($nd > 0) {
        @arrStr=split('/',$testdir);
        my $thisTestName=pop(@arrStr);
        $bt->print_log("REPORT ERROR $thisTestName--> THE LOG IS SHOWING $nd ERRORS FOR RUNID $sequence(LOG)",'Y');
 }

 if ($req->get_param(parameter=>'gms_success') == 1)
    { $bt->print_log("ERROR: GMS failed for $DE $testdir $sequence ".$bt->get_param(parameter=>'HOST'));
      $bt->print_log("ERROR: Check ".$work_dir." ".$req->get_param(parameter=>'job_log_file')); }
 else
    { $req->read_gms_results;
      &rename_work_files(type=>$type,files=>'rpt',adjust=>'n');
      $req->gen_summary_rpt; }
 &rename_work_files(type=>$type,files=>'all',adjust=>'y');
 return $req;
}

#------------------------------------------------------------------------------
sub rename_work_files
{
 my %arg=@_;
 my $type =uc($arg{type});
 my $files=uc($arg{files});
 my $adjust=uc($arg{adjust});
 $bt->debug_info("in rename_work_files for $workfile for $type and $files");
 my @pars;
 if ($files eq "ALL")     { @pars=qw/gms_mgn_file gms_rpt_file gms_res_file job_ctl_file/; }
 elsif ($files eq "RPT")  { @pars=qw/gms_rpt_file/; }
 else                     { $bt->debug_info("incorrect call to rename_work_files"); }
 foreach my $id (@pars)
    { my $nfn=$type."_".$bt->cfg_param(parameter=>'GMS_VERSION')."_".$req->get_param(parameter=>$id);
      if ($id ne "gms_rpt_file")
         { #if ($id eq "job_log_file") { $rt->close_log_file; }
           if ($id ne "job_ctl_file") {$bt->file_rename(olddir=>$work_dir,oldname=>$req->get_param(parameter=>$id),newname=>$nfn,info=>'N'); }
           #if ($id eq "job_log_file") { $rt->cfg_param(parameter=>'LOG_FILE',value=>$nfn); $rt->open_log_file; }
         }
      else
         { my $orig_dir=$bt->get_cwd;
           chdir($work_dir);
           if ($adjust eq "N") { $nfn=substr($nfn,0,-3)."full"; }
           my $cmd=sprintf("cat %s | sed -e \'s/ [0-9][0-9]-[A-Z][a-z][a-z]-[0-9][0-9][0-9][0-9] / dd-Mmm-yyyy /g\' | sed -e \'s/..:..:../hh:mm:ss/g\' >%s",$req->get_param(parameter=>$id),$nfn);
           my @return=`$cmd`;
           $bt->file_remove(dir=>$work_dir,file=>$req->get_param(parameter=>$id),info=>'N');
           if ($adjust eq "N") { $req->get_param(parameter=>'gms_rpt_full',value=>$nfn); }
           else                { $req->get_param(parameter=>'gms_rpt_file',vlaue=>$nfn); }
           chdir($orig_dir);
         }
      if ($adjust eq "Y") { $req->get_param(parameter=>$id,value=>$nfn); }
    }
return;
}
#------------------------------------------------------------------------------
sub keep_history_in_log
{
 my $logfile=$_[0];
 my $workdir=$_[1];
 my $tmpname="temp.log";
 my $lines_to_keep=$bt->cfg_param(parameter=>'LINES_TO_KEEP');
 my $cmd="tail -".$lines_to_keep." ".$logfile." >".$tmpname;
 my @rtn_value=`$cmd`;
 $bt->file_remove(file=>$logfile,dir=>$workdir,info=>'N');
 $bt->file_rename(olddir=>$workdir,oldname=>$tmpname,newname=>$logfile,info=>'N');
 return;
}
#------------------------------------------------------------------------------
sub cleanup_dir
{
 my $workfile =lc($_[0]);
 my $workdir  =$_[1];
 $bt->debug_info("in cleanup_dir for $workfile in $workdir");
 my $FK;
 my $orig_dir=$bt->get_cwd;
 my $gms_ver=$bt->cfg_param(parameter=>'GMS_VERSION');
 chdir ("$workdir");
 opendir (DC,".");
 while ($FK = readdir(DC))		# Read the next entry
  { if ($FK ne "." && $FK ne "..")	# Not the Directory Files
      { $bt->debug_info("Processing file code: $FK");
        if (lc($FK) =~ /^._${gms_ver}_.._${workfile}\..../ )   # contains
	  { if (lc($FK) =~ /^._${gms_ver}_lg_${workfile}\.log/ )   # is the log file
	       { $bt->debug_info("Keep History in log File $FK");
	         &keep_history_in_log($FK,$workdir);
	         next;
	       }
	    $bt->debug_info("File to be deleted: $FK");
            $bt->file_remove(file=>$FK,dir=>$workdir,info=>'N');
          }
      }
  }
 closedir(DC);
 chdir ($orig_dir);
 return;
}
#------------------------------------------------------------------------------
sub manage_log_files
{
 my $type=$_[0];
 my $nfn=$type."_".$bt->cfg_param(parameter=>'GMS_VERSION')."_".$req->get_param(parameter=>'job_log_file');
 $req->get_param(parameter=>'job_log_file',value=>$nfn);
 $rt->cfg_param(parameter=>'LOG_FILE',value=>$req->get_param(parameter=>'job_log_file'));
 $rt->cfg_param(parameter=>'LOG_DIR', value=>$req->get_param(parameter=>'work_dir'));
 $rt->cfg_param(parameter=>'LOG_APPEND',value=>'Y');
 $rt->open_log_file;
 if (($req->get_param(parameter=>'seq') ne "") && ($req->get_param(parameter=>'source_file') ne ""))
 { $rt->print_log("Processing File ".$req->get_param(parameter=>'source_file')." for ".$req->get_param(parameter=>'seq'),"Y");}
 $rt->print_log("====================================================================================================================","Y");
 return;
}
#------------------------------------------------------------------------------
sub compare_run_times
{
 &compare_actual($_[0],"gms_run_time","Run");
 &compare_actual($_[0],"gms_rpt_time","Rpt");
 return;
}
#------------------------------------------------------------------------------
sub compare_actual
{
 my $id=$_[1];
 if ($test->get_param(parameter=>$id) ne $prod->get_param(parameter=>$id))
  { $bt->print_log("TIME ERROR: $_[2] Times $_[0] $sequence between Production and Test are not the same"); }
 else
  { $bt->print_log("TIME  INFO: $_[2] Times $_[0] $sequence between Production and Test are the same"); }
 $bt->print_log("TIME: $_[2] Test: ".$test->get_param(parameter=>$id)." Prod: ".$prod->get_param(parameter=>$id));
 return; 
}
#------------------------------------------------------------------------------
sub get_testcases
{
 @TEST_DIR;
 @JAVA_DIR;
 @XMLT_DIR;
 @INQT_DIR;
 @ICET_DIR;
 @JAVAS_DIR;
 my $file=$bt->comb_dir_file(dir=>$bt->cfg_param(parameter=>'CFG_DIR'),file=>$bt->cfg_param(parameter=>'TEST_LIST'));
 open(FILE,"<".$file) or die "main::get_testcases => File Open Error: $!\n";
 while(<FILE>)
 { chop;
   s/#.*$//;     
   if (/^\s*$/) {next;}
   s/\s+/ /g;
   s/\s*$//g;
   /(\w+)\s+(.*)/;
   $bt->debug_info("Values are: <$1>\t\t<$2>");
   if    ($2 eq "J") { push (@JAVA_DIR,$1); }
   elsif ($2 eq "X") { push (@XMLT_DIR,$1); }
   elsif  ($2 eq "I") { push (@INQT_DIR,$1); }
   elsif  ($2 eq "IJ") { push (@INQJ_DIR,$1); }
   elsif  ($2 eq "L") { push (@ICET_DIR,$1); }
   elsif ($2 eq "S") { push (@JAVAS_DIR,$1); }
   else { push (@TEST_DIR,$1); }
 }
 close(FILE) || die ("Unable to close $file: $!");
 return;
}
#------------------------------------------------------------------------------
sub determine_host
{
 my $host;
 #if ($^O ne "MSWin32")  { $host=`uname -n`; chomp $host; } else { $bt->get_env_var(env=>'COMPUTERNAME'); } ##Hardcoded $host="windows"
 if ($^O ne "MSWin32")  { $host=`uname -n`; chomp $host; } else { $host="windows"; }
 #if ($host eq "mizar") { $host = $host."$ENV{'DATA_MODEL'}"; chomp $host;}
 $bt->get_param(parameter=>'HOST',value=>$host);
 $bt->calc_busday;
 $bt->close_log_file;
 my $logfile=$bt->get_param(parameter=>'HOST')."_".$bt->cfg_param(parameter=>'BUSDATE')."_".$bt->cfg_param(parameter=>'LOG_FILE');
 $bt->cfg_param(parameter=>'LOG_FILE',value=>$logfile);
 $bt->open_log_file;
 return;
}
#------------------------------------------------------------------------------
sub diff_source
{
 if ($bt->cfg_param(parameter=>'COMPARE_SOURCE') eq "Y")
 {
	 my $tstSource1=$bt->get_env_var(env=>'BRN_HOME')."/".$bt->get_param(parameter=>'BRANCH')."/src";
	 my $prdSource1=$bt->get_env_var(env=>'PRD_HOME')."/trunk/src";
	 my $tstSource2=$bt->get_env_var(env=>'BRN_HOME')."/".$bt->get_param(parameter=>'BRANCH')."/xml/gms/xsl";
	 my $prdSource2=$bt->get_env_var(env=>'PRD_HOME')."/trunk/xml/gms/xsl";
	 my $tstSource3=$bt->get_env_var(env=>'BRN_HOME')."/".$bt->get_param(parameter=>'BRANCH')."/vmc";
	 my $prdSource3=$bt->get_env_var(env=>'PRD_HOME')."/trunk/vmc";
     my $tstSource4=$bt->get_env_var(env=>'BRN_HOME')."/".$bt->get_param(parameter=>'BRANCH')."/java/gmsapi/com/sungard/gms/api";
	 my $prdSource4=$bt->get_env_var(env=>'PRD_HOME')."/trunk/java/gmsapi/com/sungard/gms/api";
     my $tstSource5=$bt->get_env_var(env=>'BRN_HOME')."/".$bt->get_param(parameter=>'BRANCH')."/java/icelink/com/sungard/gms/icelink";
	 my $prdSource5=$bt->get_env_var(env=>'PRD_HOME')."/trunk/java/icelink/com/sungard/gms/icelink";	
   
    $bt->print_log("====================================================================================================================","Y");
     $bt->print_log("Comparing Source TST vs PRD start",'Y');
     &compare_source1 ($tstSource1,$prdSource1,"gms","c|h");
     &compare_source1 ($tstSource1,$prdSource1,"license","c|h");
	 &compare_source1 ($tstSource1,$prdSource1,"gms","cpp");
     &compare_source1 ($tstSource2,$prdSource2,"","xsl");
#    &compare_source1 ($tstSource3,$prdSource3,"vm","c|h");
#	 &compare_source1 ($tstSource3,$prdSource3,"vmgn","c|p");
	 &compare_source1 ($tstSource4,$prdSource4,"","java");
	 &compare_source1 ($tstSource5,$prdSource5,"","java");
     $bt->print_log("Comparing Source TST vs PRD complete","Y");
     $bt->print_log("====================================================================================================================","Y");
   }
 return;
}
#------------------------------------------------------------------------------
sub compare_source2
{
 my $tdir=$_[0];
 my $pdir=$_[1];
 my $p_s =$_[2];
 opendir (CS,$tdir);			# Open the Work Directory
 while (my $DE = readdir(CS))		# Read the next entry
 { if ($DE eq "." || $DE eq "..")         { next; }
   if ( $DE =~ /($p_s)/ ) { &diff_file($DE,$tdir,$pdir); }
 }
 closedir(CS);
 return;
}
#------------------------------------------------------------------------------
sub compare_source1
{
 my $tdir=$_[0];
 my $pdir=$_[1];
 my $p_s =$_[2];
 my $p_e =$_[3];
 opendir (CS,$tdir);			# Open the Work Directory
 while (my $DE = readdir(CS))		# Read the next entry
 { if ($DE eq "." || $DE eq "..")         { next; }
   if ( $DE =~ /^($p_s)(.*)($p_e)$/ ) { &diff_file($DE,$tdir,$pdir); }
 }
 closedir(CS);
 return;
}
#------------------------------------------------------------------------------
sub diff_file
{
 my $file=$_[0];
 my $tfile=$bt->comb_dir_file(dir=>$_[1],file=>$file);
 my $pfile=$bt->comb_dir_file(dir=>$_[2],file=>$file);
 my $cmd="diff $tfile $pfile 2>&1";
 my $rtn=`$cmd`;
 if (length($rtn) > 0) { $bt->print_log("DIFFERENCE->$file is different between tst and prd","Y"); }
 return; 
}
#------------------------------------------------------------------------------
