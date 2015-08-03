#!/usr/bin/perl
# File:       auto_setup.pm
# Descr:      Autobuild setup routines.
# History:    2011-02-02 Anders Risberg       Initial version (moved from auto_run_all.pl).
#
package auto_setup;
use strict;
use warnings;
use English qw(-no_match_vars); # Avoids regex performance penalty
use constant {false => 0, true => 1};
use auto_common qw(printex remote_cmd remote_cmd_outp remote_cmd_outp_inject remote_cp);

# Descr: Setup scripts on a host.
# Parameters: <build|install> <ssh command> <scp command> <host name> <path to setup files on remote host> <script packet file name> <path to config file> <name of config file>
sub setup_scripts_on_host {
  #if(auto_common::debug(@_)){return;}
  my ($prefix,$ssh_cmd,$scp_cmd,$remote_host,$script_init_dir,$pack_file_script,$config_file_path,$config_file)=@_;
  
  # Remove old scripts
  printex("  Remove script-dir $script_init_dir on remote $prefix host $remote_host ...\n");
  remote_cmd(true, $ssh_cmd, $remote_host, "\"[[ -d $script_init_dir ]] && rm -rf $script_init_dir || exit 0\"");

  # Create destinations directories
  printex("  Create script-dir $script_init_dir on remote $prefix host $remote_host ...\n");
  remote_cmd(true, $ssh_cmd, $remote_host, "\"[[ ! -d $script_init_dir ]] && mkdir -p $script_init_dir\"");

  # Copy scripts to destination directories
  printex("  Copy autobuild scripts to remote $prefix host $remote_host ...\n");
  print "<#stay>1<#>\n";
  remote_cp(true, $scp_cmd, "\"$pack_file_script\"", "$remote_host:./");
  print "<#stay>0<#>\n";

  # Unpack files on destination host (remove packet file afterwards)
  printex("  Unpack script files on remote $prefix host $remote_host ...\n");
  my @args=($ssh_cmd, $remote_host, "rm -rf $script_init_dir; mkdir -p $script_init_dir; tar -C $script_init_dir -zxf $pack_file_script conf linux; if [[ -d $script_init_dir/linux/conf ]];then mv $script_init_dir/linux/conf/* $script_init_dir/conf; rm -rf $script_init_dir/linux/conf; fi; mv $script_init_dir/linux/* $script_init_dir;  rm -rf $script_init_dir/linux;  rm -f $pack_file_script");
  remote_cmd(false, @args);$?>>8==0 or $?>>8==1 or die {msg => "Command @args failed ($!).", ret => $?>>8};

  # Copy config file to destination host
  printex("  Copy $config_file_path to remote $prefix host $remote_host ...\n");
  remote_cp(true, $scp_cmd, "\"$config_file_path\"", "$remote_host:$script_init_dir/conf");
  
  # To be on the safe side: convert all script-files to unix-format
  printex("  Convert autobuild scripts to Unix-format on remote $prefix host $remote_host ...\n");
  @args=($ssh_cmd, $remote_host, "find $script_init_dir -type f -exec dos2unix -q -k {} \\;");
  remote_cmd(false, @args);$?>>8==0 or $?>>8==1 or die {msg => "Command @args failed ($!).", ret => $?>>8};
  
  # Set script as executables
  printex("  Set autobuild scripts as executables on remote $prefix host $remote_host ...\n");
  @args=($ssh_cmd, $remote_host, "chmod -R +x $script_init_dir");
  remote_cmd(false, @args);$?>>8==0 or $?>>8==1 or die {msg => "Command @args failed ($!).", ret => $?>>8};

  # Do the rest of the script-initiation in the host
  printex("  Initiate scripts on remote $prefix host $remote_host ...\n");
  remote_cmd(true, $ssh_cmd, $remote_host, "ksh $script_init_dir/auto_init_setup.ksh -c $script_init_dir/conf/$config_file --init_$prefix");
  return;
}

# Descr: Setup server environment.
# Parameters: <build|install> <ssh command> <host name> <run command remove all> <account name> <server name> <path to setup files on remote host> <name of config file>
sub setup_environment {
  #if(auto_common::debug(@_)){return;}
  my ($prefix,$ssh_cmd,$remote_host,$run_remove_all,$account,$server_name,$script_init_dir,$config_file)=@_;
  my $param="";
  if(!$server_name) {$server_name="<config master>";}
  if($account ne "") {$param=$param."-u $account -g NMAdministrators"}
  if($run_remove_all) {
    printex("Run initiation script (remove) on server $server_name on $prefix host $remote_host ...\n");
    remote_cmd(true, $ssh_cmd, $remote_host, "ksh $script_init_dir/auto_init_setup.ksh -c $script_init_dir/conf/$config_file --remove_$prefix $param");
  }
  printex("Run re-creation of environment and users on server $server_name on $prefix host $remote_host ...\n");
  remote_cmd(true, $ssh_cmd, $remote_host, "ksh $script_init_dir/auto_init_setup.ksh -c $script_init_dir/conf/$config_file --recreate_$prefix $param");
  printex("Run initiation script on server $server_name on $prefix host $remote_host ...\n");
  remote_cmd(true, $ssh_cmd, $remote_host, "ksh $script_init_dir/auto_init_setup.ksh -c $script_init_dir/conf/$config_file --prep_$prefix");
  return;
}

# Descr: Check server environment.
# Parameters: <build|install> <ssh command> <host name> <configuration command> <account name> <server type group> <server name> <path to initiation scripts dir>
sub check_environment {
  #if(auto_common::debug(@_)){return;}
  my ($prefix,$ssh_cmd,$remote_host,$cmd_config,$account,$srv_type_group,$server_name,$script_init_dir)=@_;
  my $param="";
  if(!$server_name) {$server_name="<config master>";}
  if($account ne "") {$param=$param."-u $account -g NMAdministrators -tg $srv_type_group"}
  printex("Run checkup script on server $server_name on $prefix host $remote_host ...\n");
  remote_cmd(true, $ssh_cmd, $remote_host, "ksh $script_init_dir/auto_init_setup.ksh $cmd_config --precheck_$prefix $param");
  return;
}

# Descr: Setup server environment.
# Parameters: <build|install> <ssh command> <host name>
sub check_and_set_known_hosts {
  #if(auto_common::debug(@_)){return;}
  my ($prefix,$ssh_cmd,$remote_host)=@_;
  printex("Check and set 'known_hosts' for $prefix host $remote_host ...\n");
  
  my @new_cmd=(@$ssh_cmd, "-batch");
  my ($ret, $cret)=remote_cmd_outp(true, true, \@new_cmd, $remote_host, ":;");
  if($cret =~ m/abandoned/) {
    printex("  Updating key\n");
    ($ret, $cret)=remote_cmd_outp_inject(true, true, $ssh_cmd, $remote_host, ":;", "echo y |");
  }
  if($cret ne "") {print "$cret\n";}
  print("\n");
  return;
}

# Descr: Check Oracle-accounts.
# Parameters: <build|install> <ssh command> <host name> <configuration command> <path to initiation scripts dir>
sub check_oracle_accounts {
  #if(auto_common::debug(@_)){return;}
  my ($prefix,$ssh_cmd,$remote_host,$cmd_config,$script_init_dir,$remote_build_projhome,$remote_build_projuser)=@_;
  
  printex("Run checkup Oracle-accounts on $prefix host $remote_host ...\n");
  remote_cmd(true, $ssh_cmd, $remote_host, "\"cd $remote_build_projhome/$remote_build_projuser; ksh $script_init_dir/auto_init_setup.ksh $cmd_config --oracheck_$prefix;\"");
  return;
}
1;
