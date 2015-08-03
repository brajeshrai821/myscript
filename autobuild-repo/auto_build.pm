#!/usr/bin/perl
# File:       auto_build.pm
# Descr:      Autobuild build routines.
# History:    2011-02-02 Anders Risberg       Initial version (moved from auto_run_all.pl).
#
package auto_build;
use strict;
use warnings;
use English qw(-no_match_vars); # Avoids regex performance penalty
use constant {false => 0, true => 1};
use auto_common qw(printex remote_cmd remote_cmd_piped remote_cp);

# Descr: Run project setup.
# Parameters: <ssh command> <host name> <remote project path> <command to run initiation on remote host>
sub project_setup {
  #if(auto_common::debug(@_)){return;}
  my ($ssh_cmd,$remote_host,$auto_init_setup_project_path,$cmd_config_build)=@_;
  printex("Start project setup on host $remote_host ...\n");
  remote_cmd(true, $ssh_cmd, $remote_host, "ksh $auto_init_setup_project_path $cmd_config_build --init");
  remote_cmd(true, $ssh_cmd, $remote_host, "ksh $auto_init_setup_project_path $cmd_config_build --build");
  return;
}

# Descr: Build the kits.
# Parameters: <ssh command> <host name> <remote make path for netman> <command to run initiation on remote host> <run make clean> <create modules> <run clean modules> <checkout> <run make> <build kits>
sub build_kits {
  #if(auto_common::debug(@_)){return;}
  my ($ssh_cmd,$remote_host,$auto_netman_kits_make_path,$cmd_config_build,$opt_build_clean,$opt_build_crmod,$opt_build_cleanmod,$opt_build_co,$opt_build_make,$opt_build_kits)=@_;
  printex("Build kits on host $remote_host ...\n");
  remote_cmd(true, $ssh_cmd, $remote_host, "ksh '$auto_netman_kits_make_path $cmd_config_build" . ($opt_build_clean ? " --clean" : "") . ($opt_build_crmod ? " --crmod" : "") . ($opt_build_cleanmod ? " --cleanmod" : "") . ($opt_build_co ? " --co" : "") . ($opt_build_make ? " --make" : "") . ($opt_build_kits ? " --build_kits" : "") . "'");
  return;
}

# Descr: Packs the built files to a tar-file.
# Parameters: <ssh command> <scp command> <host name> <copy kits to a local packet instead of streaming> <use local kits packet if it exists> <runcons packet file name> <remote build project home> <remote build project user> <runcons directory name>
sub pack_files_build {
  #if(auto_common::debug(@_)){return;}
  my ($ssh_cmd,$scp_cmd,$remote_host,$opt_copy_kits_local,$opt_copy_kits_local_ifexists,$pack_file_runcons,$remote_build_projhome,$remote_build_projuser,$runcons_name)=@_;
  if(!$opt_copy_kits_local && !$opt_copy_kits_local_ifexists) {
    # Pack runcons files (standard way)
    printex("Pack build files to $pack_file_runcons ...\n");
    remote_cmd_piped(true, $ssh_cmd, $remote_host, "\"if [[ -d $remote_build_projhome/$remote_build_projuser/$runcons_name ]];then cd $remote_build_projhome/$remote_build_projuser/$runcons_name;tar zcf - .;exit 0;else exit 1;fi\"", "\"" . $auto_settings::settings_glob->{hubfiles_path} . "/$pack_file_runcons\"");
  }
  else {
    if($opt_copy_kits_local) {
      # Local zip + copy to hub
      printex("Pack build files to $pack_file_runcons - leave on server ...\n");
      remote_cmd(true, $ssh_cmd, $remote_host, "\"if [[ -d $remote_build_projhome/$remote_build_projuser/$runcons_name ]];then cd $remote_build_projhome/$remote_build_projuser; tar -C $remote_build_projhome/$remote_build_projuser/$runcons_name -zcf $pack_file_runcons .; exit 0; else exit 1; fi\"");
    }
    if($opt_copy_kits_local_ifexists || $opt_copy_kits_local) {
      # Copy package file to hub
      printex("Copy $pack_file_runcons from $remote_host to hub ...\n");
      print "<#stay>1<#>\n";
      remote_cp(true, $scp_cmd, "$remote_host:$remote_build_projhome/$remote_build_projuser/$pack_file_runcons", "\"" . $auto_settings::settings_glob->{hubfiles_path} . "\"");
      print "<#stay>0<#>\n";
    }
  }
  return;
}

# Descr: Analyze log-files from build machine.
# Parameters: <host name> <log-files path name> <remote build project user>
sub analyze_logfiles_build {
  #if(auto_common::debug(@_)){return;}
  my ($remote_src_host,$dst_dir,$remote_build_projuser)=@_;
  my $top_dst_dir = $auto_settings::settings_glob->{logfiles_path}."/$remote_src_host";
  printex("Analyze log-files in $top_dst_dir/$dst_dir ...\n");
  auto_common::analyze_latest("$top_dst_dir/$dst_dir", $auto_settings::settings_glob->{diff_path}."/auto_conbld.orig", "auto_conbld", $auto_settings::settings_glob->{conf_path}, "conbld", "", $auto_settings::settings_glob->{diff}, ("s/$remote_build_projuser/uuu/i"));
  auto_common::analyze_latest("$top_dst_dir/$dst_dir", $auto_settings::settings_glob->{diff_path}."/auto_make_total.orig", "auto_make_total", $auto_settings::settings_glob->{conf_path}, "make", "", $auto_settings::settings_glob->{diff}, ("s/$remote_build_projuser/uuu/i"));
  auto_common::analyze_latest("$top_dst_dir/$dst_dir", $auto_settings::settings_glob->{diff_path}."/auto_make_incremental.orig", "auto_make_incremental", $auto_settings::settings_glob->{conf_path}, "make", "", $auto_settings::settings_glob->{diff}, ("s/$remote_build_projuser/uuu/i"));
  auto_common::analyze_latest("$top_dst_dir/$dst_dir", $auto_settings::settings_glob->{diff_path}."/auto_checkout_total.orig", "auto_checkout_total", $auto_settings::settings_glob->{conf_path}, "checkout", "", $auto_settings::settings_glob->{diff}, ("s/$remote_build_projuser/uuu/i"));
  auto_common::analyze_latest("$top_dst_dir/$dst_dir", $auto_settings::settings_glob->{diff_path}."/auto_checkout_incremental.orig", "auto_checkout_incremental", $auto_settings::settings_glob->{conf_path}, "checkout", "", $auto_settings::settings_glob->{diff}, ("s/$remote_build_projuser/uuu/i"));
  return;
}
1;