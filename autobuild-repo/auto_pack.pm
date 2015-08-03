#!/usr/bin/perl
# File:       auto_pack.pm
# Descr:      Autobuild packing routines.
# History:    2011-02-02 Anders Risberg       Initial version (moved from auto_run_all.pl).
#
package auto_pack;
use strict;
use warnings;
use English qw(-no_match_vars); # Avoids regex performance penalty
use File::Basename;
use File::Path qw(mkpath);
use constant {false => 0, true => 1};
use auto_common qw(printex remote_cmd remote_cp sys_cmd);
use Cwd;

# Descr: Packs the script-files to a tar-file.
# Parameters: <name of packed script file>
sub pack_scripts {
  #if(auto_common::debug(@_)){return;}
  my ($pack_file_script)=@_;
  printex("Pack scripts to $pack_file_script ...\n");
  my $temp_file="temp.tar";
  sys_cmd(true, "\"".$auto_settings::settings_glob->{tar}."\" -czf \"$pack_file_script\" --exclude .git --exclude .svn -C \"".dirname($auto_settings::settings_glob->{conf_path})."\" ".basename($auto_settings::settings_glob->{conf_path})." -C \"".dirname($auto_settings::settings_glob->{linux_script_path})."\" ".basename($auto_settings::settings_glob->{linux_script_path}));
  return;
}

# Descr: Transfer files from server.
# Parameters: <ssh command> <host name> <source path> <destination path> <y|n remove old files> <excludes>
sub transfer_sync {
  #if(auto_common::debug(@_)){return;}
  my ($ssh_cmd,$scp_cmd,$remote_host,$src_path,$dst_dir,$remove_old_files,$exclude)=@_;
  my $param = "";
  foreach(@$exclude) {
    $param = $param."--exclude $_ ";
  }
  $param = $param."-zchf";
  my $filename = fileparse($src_path);
  my $top_dst_dir = $auto_settings::settings_glob->{logfiles_path}."/$remote_host";
  printex("Transfer files from $remote_host:$src_path to $top_dst_dir/$dst_dir ...\n");
  if($remove_old_files) {
    printex("  Delete old files ...\n");
    if($dst_dir eq "") {
      die "Log-files destination directory name must be defined when removing it.";
    }
    auto_common::remove_dir("$top_dst_dir/$dst_dir");
  }
  
  my $find_param = "-d";
  if($filename ne "") { $find_param = "-f"; }
  my $ret=remote_cmd(false, $ssh_cmd, $remote_host, "\"if [[ $find_param $src_path ]];then exit 0;else exit 1;fi\"");
  if($ret eq 0) {
    if(! -d "$top_dst_dir/$dst_dir") {
      mkpath("$top_dst_dir/$dst_dir", 0, oct(755)) or die "Couldn't create directory $top_dst_dir/$dst_dir.";
    }
    auto_setup::check_and_set_known_hosts("",$ssh_cmd,$remote_host);
    
    # Transfer
    my $temp_file="autobuild_xfer_tmp.tgz";
    if($filename eq "") {
      remote_cmd(true, $ssh_cmd, $remote_host, "\"if [[ -d $src_path ]];then cd $src_path;tar $param ~/$temp_file .;fi\"");
    } else {
      remote_cmd(true, $ssh_cmd, $remote_host, "\"if [[ -f $src_path ]];then cd " . dirname($src_path) . ";tar $param ~/$temp_file $filename;fi\"");
    }
    my @new_cmd=(@$scp_cmd, "-q");
    remote_cp(true, \@new_cmd, "$remote_host:$temp_file", $auto_settings::settings_glob->{temp_path} . "/");
    remote_cmd(true, $ssh_cmd, $remote_host, "\"[[ -f ~/$temp_file ]] && rm -f ~/$temp_file\"");
    sys_cmd(true, "\"" . $auto_settings::settings_glob->{tar} . "\" -C \"$top_dst_dir/$dst_dir\" -zxof \"" . $auto_settings::settings_glob->{temp_path} . "/$temp_file\"");
    unlink $auto_settings::settings_glob->{temp_path}."/$temp_file";
  }
  else {
    printex("Warning! Remote path or file $src_path not found.\n");
  }
  return;
}
1;