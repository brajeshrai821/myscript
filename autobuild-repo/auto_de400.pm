#!/usr/bin/perl
# File:       auto_de400.pm
# Descr:      Autobuild DE400 routines.
# History:    2011-02-02 Anders Risberg       Initial version (moved from auto_run_all.pl).
#             2011-04-29 Anders Risberg       Added de400_get_db_value().
#             2011-05-18 Anders Risberg       Parameters $orahome, $orasid now taken from cofiguration instead of the environment.
#                                             Added parameter $orahome32 to setup_de400.pl call.
#                                             Checking Spide project path, $ENV{'DAT'}/cc/proj, when needed instead of initially.
#
package auto_de400;
use strict;
use warnings;
use English qw(-no_match_vars); # Avoids regex performance penalty
use File::Path qw(rmtree);
use constant {false => 0, true => 1};
use auto_common qw(printex remote_cmd remote_cmd_piped sys_cmd sys_cmd_outp);

# Descr: Get the spide zip-file.
# Parameters: <spide packet file name> <spide internal packet file name>
sub de400_get_spide {
  #if(auto_common::debug(@_)){return;}
  my ($pack_file_spide,$spide_file_name)=@_;
  if(-e $auto_settings::settings_glob->{hubfiles_path}."/$pack_file_spide") {
    printex("Get new ".$spide_file_name." ...\n");
    sys_cmd(true, "\"".$auto_settings::settings_glob->{tar}."\" -zxof \"".$auto_settings::settings_glob->{hubfiles_path}."/$pack_file_spide\" -C \"".$auto_settings::settings_glob->{temp_path}."\"");
  }
  else {
    printex("Couldn't find ".$auto_settings::settings_glob->{hubfiles_path}."/$pack_file_spide. Trying $spide_file_name.\n");
  }
  printex("Delete old installation files ...\n");
  my $spidefiles_path=$auto_settings::settings_glob->{temp_path}."/spide";
  if(-d $spidefiles_path) { rmtree($spidefiles_path); rmdir($spidefiles_path); }  
  mkdir($spidefiles_path, 755) or die "Couldn't create directory $spidefiles_path.";
  chdir "$spidefiles_path";
  printex("Unpack ".$spide_file_name." ...\n");
  sys_cmd(true, "\"".$auto_settings::settings_glob->{tar}."\" -xzof \"".$auto_settings::settings_glob->{temp_path}."/$spide_file_name\"");
  chdir $auto_settings::settings_glob->{temp_path};
  return;
}

# Descr: Run setup_de400.pl.
# Parameters: <drive name where spide is installed> <Oracle port number> <Oracle system id> <continue on setup_de400 error>
sub de400_setup_de400 {
  #if(auto_common::debug(@_)){return;}
  my ($spide_drive,$oraport,$orahome,$orahome32,$orasid,$cont_on_setup_de400_error)=@_;
  printex("Run setup_de400.pl ...\n");
  stop_oracle($auto_settings::settings_glob->{perl});
  setup_file_association(".pl","Perl",$auto_settings::settings_glob->{perl});
  my $spidefiles_path=$auto_settings::settings_glob->{temp_path}."/spide";
  if(-d $spidefiles_path) {
    chdir "$spidefiles_path";
    my @args=($auto_settings::settings_glob->{perl}, "setup_de400.pl", $spide_drive, "\"$orahome\"", $orasid, $oraport, "Y", "\"$orahome32\"");
    my $ret=sys_cmd(false, @args);
    $ret>>8==0 or $cont_on_setup_de400_error or die {msg => "Command @args failed ($!).", ret => $ret>>8};
    # Get the environment
    update_environment(false);
  }
  else { die "Couldn't find temporary spide-directory (".$auto_settings::settings_glob->{temp_path}."/$spidefiles_path)."; }
  printex("\nEnded setup_de400.pl\n");
  return;
}

# Descr: Create the DE400 main database.
# Parameters:
sub de400_create_mdb {
  #if(auto_common::debug(@_)){return;}
  printex("Run create_mdb.pl ...\n");
  my $logfiles_de400_path=$auto_settings::settings_glob->{logfiles_path}."/de400";
  unless(-d $logfiles_de400_path) {mkdir($logfiles_de400_path, 755) or die "Couldn't create directory $logfiles_de400_path.";}
  if(defined($ENV{'MDB'}) && $ENV{'MDB'} ne "" && -e "$ENV{'MDB'}\\create_mdb.pl") {
    sys_cmd(true, $auto_settings::settings_glob->{perl}." $ENV{'MDB'}/create_mdb.pl default s - 2>$logfiles_de400_path/create_mdb.log");
  }
  else { die "Couldn't find create_mdb.pl.\nEither this is the first time DE400-installation is run or the environment is not setup correctly.\n"; }
  return;
}

# Descr: Unlock Oracle account.
# Parameters: <Oracle user name> <Oracle user password>
sub de400_unlock_account {
  #if(auto_common::debug(@_)){return;}
  my ($orauser,$orapwd)=@_;
  printex("Unlock Oracle account '$orauser' ...\n");
  if(defined($ENV{'UTL'}) && $ENV{'UTL'} ne "" && -e "$ENV{'UTL'}\\alter_account.pl") {
    sys_cmd(true, $auto_settings::settings_glob->{perl}, "$ENV{'UTL'}/alter_account.pl", 2, $orauser, $orapwd);
  }
  else { die "Couldn't find alter_account.pl.\nEither this is the first time DE400-installation is run or the environment is not setup correctly.\n"; }
  return;
}

# Descr: Generate offset files and pictures for DE400.
# Parameters: <Oracle user name> <Oracle user password>
sub de400_generate_files {
  #if(auto_common::debug(@_)){return;}
  my ($orauser,$orapwd)=@_;
  printex("Start generating offset files and pictures ...\n");
  open my $ora_fh, "|-", "sqlplus -s $orauser/$orapwd" or die "Can't pipe to sqlplus: $!.";
  print($ora_fh "exec pa_common.set_usr_passw_instance('$orauser','$orapwd','mdb');\n");
  print($ora_fh "exec pa_pro_data_proc.de_total_sav('PROJ');\n");
  print($ora_fh "exec pa_pro_nm.set_nm_usr_pwd('dummy','dummy');\n");
  print($ora_fh "exec pa_pro_pic.pic_gen_total_sav('PROJ');\n");
  print($ora_fh "exec pa_mmgr_pic.generate_list_of_pictures_sav('PROJ');\n");
  print($ora_fh "exit\n");
  close $ora_fh;
  return;
}

# Descr: Transfer DE400-files and -pictures.
# Parameters: <offset files packet file name> <pictures packet file name>
sub de400_transfer_files {
  #if(auto_common::debug(@_)){return;}
  my ($pack_file_offset,$pack_file_pictures,$cont_on_error)=@_;
  printex("Pack DE400 offset files to $pack_file_offset ...\n");
  if(defined($ENV{'DAT'}) && $ENV{'DAT'} ne "" && -d "$ENV{'DAT'}\\cc\\proj") {
    chdir "$ENV{'DAT'}/cc/proj";
    my @args=("\"".$auto_settings::settings_glob->{tar}."\" -czf \"".$auto_settings::settings_glob->{hubfiles_path}."/$pack_file_offset\" *dat duspdloff.ver link_de_pictures");
    my $ret=sys_cmd(false, @args);
    $ret>>8==0 or $cont_on_error or die {msg => "Command @args failed ($!).", ret => $?>>8};
    printex("Pack DE400 picture files to $pack_file_pictures ...\n");
    @args=("\"".$auto_settings::settings_glob->{tar}."\" -czf \"".$auto_settings::settings_glob->{hubfiles_path}."/$pack_file_pictures\" *PPI *REF");
    $ret=sys_cmd(false, @args);
    $ret>>8==0 or $cont_on_error or die {msg => "Command @args failed ($!).", ret => $?>>8};
    chdir $auto_settings::settings_glob->{temp_path};
  }
  else { die "Couldn't find Spide project directory.\nEither this is the first time DE400-installation is run or the environment is not setup correctly.\n"; }
  return;
}

# Descr: Approve the DE400-database.
# Parameters: <Oracle user name> <Oracle user password>
sub de400_approve_db {
  #if(auto_common::debug(@_)){return;}
  my ($orauser,$orapwd)=@_;
  printex("Approve the DB to get into normal state ...\n");
  open my $ora_fh, "|-", "sqlplus -s $orauser/$orapwd" or die "Can't pipe to sqlplus: $!.";
  print($ora_fh "exec pa_pro_data_proc.de_approve('PROJ');\n");
  print($ora_fh "exit\n");
  close $ora_fh;
  return;
}

# Descr: Get value from the DE400-database.
# Parameters: <Oracle user name> <Oracle user password> <Oracle system id> <sql-command to run>
sub de400_get_db_value {
  my ($orauser,$orapwd,$orasid,$cmd)=@_;
  my ($ret, $outp)=sys_cmd_outp(true, false, $auto_settings::settings_glob->{perl}, "\"".$auto_settings::settings_glob->{srcdir}."/auto_dbi.pl\"", $orauser, $orapwd, $orasid, "\"$cmd\"");
  return $outp;
}

# Descr: Packs the built DE400 files to a tar-file.
# Parameters: <ssh command> <host name> <spide packet file name> <spide internal packet file name>
sub pack_files_de400 {
  #if(auto_common::debug(@_)){return;}
  my ($ssh_cmd,$remote_host,$pack_file_spide,$spide_file_name)=@_;
  printex("Pack spide kit files to $pack_file_spide ...\n");
  my $cmd="find ~/spiroot/ -maxdepth 3 -type d -name 'de'";
  remote_cmd_piped(true, $ssh_cmd, $remote_host, "\"if [[ `eval $cmd|wc -l` > 1 ]];then exit 1;else de_dir=`eval $cmd`; if [[ -d \$de_dir/source ]];then cd \$de_dir/source;tar zcf - $spide_file_name;exit 0;else exit 1;fi fi\"", "\"" . $auto_settings::settings_glob->{hubfiles_path} . "/$pack_file_spide\"");
  return;
}

# Descr: Analyze log-files from DE400-machine.
# Parameters: 
sub analyze_logfiles_de400 {
  #if(auto_common::debug(@_)){return;}
  my $logfiles_de400_path=$auto_settings::settings_glob->{logfiles_path}."/de400";
  my $top_dst_dir="$logfiles_de400_path";
  unless(-d $logfiles_de400_path) {mkdir($logfiles_de400_path, 755) or die "Couldn't create directory $logfiles_de400_path.";}
  printex("Analyze log-files in $top_dst_dir ...\n");
  auto_common::analyze_latest("$top_dst_dir", $auto_settings::settings_glob->{diff_path}."/de400_create_mdb.orig", "create_mdb", $auto_settings::settings_glob->{conf_path}, "create_mdb", "", $auto_settings::settings_glob->{diff}, "");
  return;
}

# Descr: Stops Oracle.
# Params: <perl command>
sub stop_oracle {
  my ($perl)=@_;
  printex("Try to stop Oracle ...\n");
  if(defined($ENV{'MDB'}) && $ENV{'MDB'} ne "" && -e "$ENV{'MDB'}\\shutdown_mdb.pl") {
    sys_cmd(true, $perl, "$ENV{'MDB'}\\shutdown_mdb.pl");
  }
  else { print "Couldn't find shutdown_mdb.pl.\nEither this is the first time DE400-installation is run or the environment is not setup correctly.\n"; }
  return;
}

# Descr: Starts Oracle.
# Params: <perl command>
sub start_oracle {
  my ($perl)=@_;
  printex("Try to start Oracle ...\n");
  if(defined($ENV{'MDB'}) && $ENV{'MDB'} ne "" && -e "$ENV{'MDB'}\\startup_mdb.pl") {
    sys_cmd(true, $perl, "$ENV{'MDB'}\\startup_mdb.pl");
  }
  else { print "Couldn't find startup_mdb.pl.\nEither this is the first time DE400-installation is run or the environment is not setup correctly.\n"; }
  return;
}

# Descr: Setup file association.
# Parameters: <extension with .> <name> <path to application>
sub setup_file_association {
  my ($ext,$name,$path)=@_;
  printex("Setup file association $ext to $name ...\n");
  untie(*STDOUT) if tied(*STDOUT); # Needed by debugger before opening
  untie(*STDERR) if tied(*STDERR); # Needed by debugger before opening
  open STDERR, q{>}, '/dev/null'; # Temporarily disable errors
  sys_cmd(true, "assoc $ext=");
  close STDERR; # Turn back on
  sys_cmd(true, "assoc $ext=$name");
  sys_cmd(true, "ftype $name=\"$path\" \"%1\" %*");
  return;
}

# Descr: Update environment.
# Parameters: 
sub update_environment {
  my ($silent_mode)=@_;
  if(!$silent_mode) {
    #printex("Update DE400-environment ...\n");
  }
  chdir $auto_settings::settings_glob->{temp_path};
  # Refresh environment variables.
  # New global environment variables will be available in this session only or when the
  # script has been restarted in a new command environment.
  #open OENV, '>', "updenv_1.txt" or die $!;
  #foreach(sort keys %ENV) { print OENV "* $_ = $ENV{$_}\n"; }
  #close OENV;
  # Create "unique" file name since require may only be done once per file
  my $env_script=$auto_settings::settings_glob->{temp_path}."/updenv_senv.pm";
  sys_cmd(true, $auto_settings::settings_glob->{setenv}." \"$env_script\""); # Get all variables (global and user) and create a temporary script with them.
  require "$env_script" or die("Can't require"); # Incorporate variables into this session.
  #open OENV, '>', "updenv_2.txt" or die $!;
  #foreach(sort keys %ENV) { print OENV "* $_ = $ENV{$_}\n"; }
  #close OENV;  
  unlink "$env_script";
  return;
}
1;
