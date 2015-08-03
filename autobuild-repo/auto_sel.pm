#!/usr/bin/perl -w
# File:       auto_sel.pm
# Descr:      
# History:    2011-04-27 Anders Risberg       Initial version.
#
package auto_sel;
use strict;
use warnings;
use English qw(-no_match_vars); # Avoids regex performance penalty
use POSIX qw(strftime);
use File::Basename;
use constant {false => 0, true => 1};
use auto_common qw(printex);
use auto_settings;
use auto_setup;
use auto_build;
use auto_install;
use auto_de400;
use auto_pack;

# Non-exported package globals
use auto_glob_class;
our $properties;

# Descr: Initialize.
# Parameters: <name of script file ($0)> <name of optional signal handler function or 0> <silent mode> <input hash reference>
# Returns: Array of input parameters (whats left of them after this routine).
sub usage { print "Usage: perl ",$auto_common::common_glob->{this_app}, " param01 [param02 ... param0n]\n"; return; }
sub init {
  my($script_file,$sighandler_func,$input)=@_;

  # Initialize signal handler
  auto_common::sighandler_init($sighandler_func);

  # Command line parameters
  my ($this_file, $this_dir)=fileparse($script_file);
  $auto_common::common_glob->{this_app}=$this_file;
  if(@ARGV==0) { usage(); exit(); }
  
  # Check the max configuration file version number
  die "Wrong version number format of max configuration file version: ".$auto_settings::settings_glob->{max_config_version} unless auto_common::check_version_format($auto_settings::settings_glob->{max_config_version});
  my @max_config_version=split(/\./, $auto_settings::settings_glob->{max_config_version});

  ### NOTE! Must be silent to here! Then use $auto_common::common_glob->{silent_mode} to decide if it should be silent or not ###
  
  # Pre-read some of the command-line parameters (switches)
  $auto_common::common_glob->{silent_mode}=(exists $$input{'-silent_mode'}) ? true : false; # Silent mode (true = on; false = off)
  if(exists $$input{'-silent_mode'}) {delete $$input{'-silent_mode'};}
  $auto_common::common_glob->{debug_mode}=(exists $$input{'-debug_mode'}) ? true : false; # Debug mode (true = on; false = off)
  if(exists $$input{'-debug_mode'}) {delete $$input{'-debug_mode'};}
  $auto_common::common_glob->{debug_ret}=(exists $$input{'-debug_ret'}) ? true : false; # Return value from debug (true = skip rest of function; false = run as normal)
  if(exists $$input{'-debug_ret'}) {delete $$input{'-debug_ret'};}
  $auto_common::common_glob->{print_formatted}=(exists $$input{'-print_formatted'}) ? true : false; # true=Print formatted text; defined in auto_common.pm
  if(exists $$input{'-print_formatted'}) {delete $$input{'-print_formatted'};}
  #$auto_common::common_glob->{send_mail}=(exists $$input{'-send_mail'}) ? true : false;
  #if(exists $$input{'-send_mail'}) {delete $$input{'-send_mail'};}
  $auto_settings::settings_glob->{temp_path}=(exists $$input{'-t'}) ? $$input{'-t'} : $auto_settings::settings_glob->{temp_path};$auto_settings::settings_glob->{temp_path}=~tr!\\!/!s;
  if(exists $$input{'-t'}) {delete $$input{'-t'};}
  $auto_settings::settings_glob->{logfiles_path}=(exists $$input{'-l'}) ? $$input{'-l'} : $auto_settings::settings_glob->{logfiles_path};$auto_settings::settings_glob->{logfiles_path}=~tr!\\!/!s;
  if(exists $$input{'-l'}) {delete $$input{'-l'};}
  $auto_settings::settings_glob->{hubfiles_path}=(exists $$input{'-hub'}) ? $$input{'-hub'} : $auto_settings::settings_glob->{hubfiles_path};$auto_settings::settings_glob->{hubfiles_path}=~tr!\\!/!s;
  if(exists $$input{'-hub'}) {delete $$input{'-hub'};}

  if(!$auto_common::common_glob->{silent_mode}) {
    printex("Started ".$auto_common::common_glob->{this_app}." ".(strftime "%Y-%m-%dT%H:%M:%S", localtime)."\n");
    #printex("Command line: ".$auto_common::common_glob->{this_app}." @ARGV\n");
  }

  # Read install configuration, if available
  my $iconf=(exists $$input{'-iconf'}) ? $$input{'-iconf'} : "";
  if(exists $$input{'-iconf'}) {delete $$input{'-iconf'};}
  if($iconf ne "") {
    # Parse installation configuration data and restore it in its arrays
    $iconf=~s/\@eq\@/=/g; # Restore equal signs from @eq@
    
    # Temporary arrays
    my @install_app_servers;
    my @install_app_server_nodes;
    my @install_nodes_included;
    eval $iconf;
    # Restore to original arrays
    @auto_install::install_app_servers = @install_app_servers;
    @auto_install::install_app_server_nodes = @install_app_server_nodes;
    @auto_install::install_nodes_included = @install_nodes_included;
  }
  
  # Read the config-file
  $properties=auto_glob_class->new;
  $properties->add(config_file_path => "");
  if(exists $$input{'-c'}){$properties->{config_file_path}=$$input{'-c'};delete $$input{'-c'};}
  if(! -r $properties->{config_file_path}) {
    if(! -r $auto_settings::settings_glob->{temp_path}."\\".$properties->{config_file_path}) {
      die "Config file ".$properties->{config_file_path}." cannot be read. Tried both set and local path and ".$auto_settings::settings_glob->{temp_path};
    }
    $properties->{config_file_path}=$auto_settings::settings_glob->{temp_path}."\\".$properties->{config_file_path};
  }
  my %config=();
  auto_common::rconf($properties->{config_file_path}, \%config, "_stat", false, false);
  auto_common::rconf($properties->{config_file_path}, \%config, "main", false, false);
  auto_common::rconf($properties->{config_file_path}, \%config, "common", false, false);
  auto_common::rconf($properties->{config_file_path}, \%config, "build_common", false, false);
  auto_common::rconf($properties->{config_file_path}, \%config, "install_common", false, false);
  #auto_common::sconf(\%config);

  # Properties from config-file
  $auto_common::common_glob->{config_version}=$config{"version"}; # Version of configuration file
  die "Wrong version number format of configuration file version: ",$auto_common::common_glob->{config_version} unless auto_common::check_version_format($auto_common::common_glob->{config_version});
  my @config_version=split(/\./, $auto_common::common_glob->{config_version});

  # Configuration file version check: major and minor must be equal; build rev my differ
  die "The configuration file format is outdated or too new: version is ",$auto_common::common_glob->{config_version},"; need ",$auto_settings::settings_glob->{max_config_version} unless($config_version[0] eq $max_config_version[0] && $config_version[1] eq $max_config_version[1]);

  # Get script version
  $auto_common::common_glob->{script_version}=auto_common::get_version($auto_settings::settings_glob->{srcdir});
  
  # Set properties
  $properties->add(proj_desc => $config{"proj_desc"});
  $properties->add(remote_build_suser => $config{"suser_build"});
  $properties->add(remote_build_spwd => $config{"suserpwd_build"});
  $properties->add(remote_inst_suser => $config{"suser_install"});
  $properties->add(remote_inst_spwd => $config{"suserpwd_install"});
  $properties->add(renew_tickets => $config{"renew_tickets"});
  $properties->add(use_install_pwd => $config{"use_install_pwd"});
  $properties->add(remote_build_host => $config{"build_host"});
  $properties->add(remote_build_proj => $config{"proj"});
  $properties->add(remote_build_projhome => $config{"proj_home"});
  $properties->add(remote_build_projuser => $config{"user_name"});
  $properties->add(remote_build_projpwd => $config{"userpwd"});
  $properties->add(remote_inst_config_master_host => $config{"conf_master_host"});
  $properties->add(remote_inst_user => $config{"user_install"});
  $properties->add(remote_inst_pwd => $config{"userpwd_install"});
  $properties->add(remote_inst_hosts => $config{"install_hosts"});
  $properties->add(remote_inst_oracle_pwd => $config{"pwd_oracle_install"});
  $properties->add(remote_hub_dst_path => $config{"autobuild_hub_path_install"});
  $properties->add(remote_script_path_build => $config{"script_path_build"});
  $properties->add(remote_install_bin => $config{"script_path_install"});
  $properties->add(runcons_name => $config{"runcons_name"});
  $properties->add(server_start_delay => $config{"server_start_delay"});
  $properties->add(offsetfiles_name => $config{"de_data_dir"});
  $properties->add(pictures_name => $config{"de_pict_dir"});
  $properties->add(logfiles_name => $config{"de_log_dir"});
  $properties->add(mail_recipients => $config{"mail_recipients"});
  $properties->add(host_mail => $config{"host_mail"});
  $properties->add(user_mail => $config{"user_mail"});
  $properties->add(pwd_mail => $config{"pwd_mail"});
  $properties->add(spide_file_name => $config{"spide_kit_file"});
  $properties->add(spide_drive => $config{"spide_drive"});
  # DE400-specific
  $properties->add(orahome => $config{"ora_home"});
  $properties->add(orahome32 => $config{"ora_home32"});
  $properties->add(orasid => $config{"ora_sid"});
  $properties->add(oraport => $config{"ora_port"});
  $properties->add(orauser => $config{"ora_user"});
  $properties->add(orapwd => $config{"ora_pwd"});

  # Set settings
  my ($config_file, $config_dir)=fileparse($properties->{config_file_path});
  $properties->add(config_file => $config_file);
  $properties->add(config_dir => $config_dir);
  
  # References to ssh/scp-commands
  $properties->add(ssh_remote_build => ["\"".$auto_settings::settings_glob->{ssh}."\"", "-l", $properties->{remote_build_projuser}, "-pw", $properties->{remote_build_projpwd}]);
  $properties->add(ssh_remote_build_suser => ["\"".$auto_settings::settings_glob->{ssh}."\"", "-l", $properties->{remote_build_suser}, "-pw", $properties->{remote_build_spwd}]);
  $properties->add(ssh_remote_install => ["\"".$auto_settings::settings_glob->{ssh}."\"", "-l", $properties->{remote_inst_user}, "-pw", $properties->{remote_inst_pwd}]);
  $properties->add(ssh_remote_install_suser => ["\"".$auto_settings::settings_glob->{ssh}."\"", "-l", $properties->{remote_inst_suser}, "-pw", $properties->{remote_inst_spwd}]);
  $properties->add(ssh_remote_install_oracle => ["\"".$auto_settings::settings_glob->{ssh}."\"", "-l", "oracle", "-pw", $properties->{remote_inst_oracle_pwd}]);
  $properties->add(scp_remote_build => ["\"".$auto_settings::settings_glob->{scp}."\"", "-r", "-l", $properties->{remote_build_projuser}, "-pw", $properties->{remote_build_projpwd}]);
  $properties->add(scp_remote_install => ["\"".$auto_settings::settings_glob->{scp}."\"", "-r", "-l", $properties->{remote_inst_user}, "-pw", $properties->{remote_inst_pwd}]);
  $properties->add(scp_remote_install_suser => ["\"".$auto_settings::settings_glob->{scp}."\"", "-r", "-l", $properties->{remote_inst_suser}, "-pw", $properties->{remote_inst_spwd}]);
  
  # Paths
  $properties->add(auto_init_setup_project_path => $properties->{remote_script_path_build}."/auto_init_setup_project.ksh");
  $properties->add(auto_init_setup_startinstall_path => $properties->{remote_install_bin}."/auto_init_setup_startinstall.ksh");
  $properties->add(auto_netman_kits_make_path => $properties->{remote_script_path_build}."/auto/auto_netman_kits_make.ksh");
  $properties->add(auto_cmd_install_path => $properties->{remote_install_bin}."/auto/auto_cmd_install.ksh");
  $properties->add(auto_find_app_servers_path => $properties->{remote_install_bin}."/auto/auto_find_app_servers.ksh");
  $properties->add(auto_create_de400_path => $auto_settings::settings_glob->{win_script_path}."/auto_create_de400.pl");
  $properties->add(cmd_config_build => "-c ".$properties->{remote_script_path_build}."/conf/".$properties->{config_file});
  $properties->add(cmd_config_install => "-c ".$properties->{remote_install_bin}."/conf/".$properties->{config_file});
  
  # Make sure temporary-, log-, and hub-directories exist
  unless(-d $auto_settings::settings_glob->{temp_path}) { mkdir($auto_settings::settings_glob->{temp_path}, 755) or die "Couldn't create directory ".$auto_settings::settings_glob->{temp_path}; }
  chdir $auto_settings::settings_glob->{temp_path};
  auto_common::init_log($auto_settings::settings_glob->{logfiles_path}."/autobuild.log");
  unless(-d $auto_settings::settings_glob->{hubfiles_path}) { mkdir($auto_settings::settings_glob->{hubfiles_path}, 755) or die "Couldn't create directory ".$auto_settings::settings_glob->{hubfiles_path}; }
  return $input;
}

# Descr: De-initialize.
# Parameters: <silent mode>
sub deinit {
  # Finished
  if(!$auto_common::common_glob->{silent_mode}) {printex("Finished ".$auto_common::common_glob->{this_app}." ".(strftime "%Y-%m-%dT%H:%M:%S", localtime)."\n");}
  auto_common::deinit_log();
  #auto_common::send_log_mail();
  return;
}

# Descr: Show info.
# Parameters: 
sub show_info {
  printex("-------------------------------------------------\n");
  printex("           Script version: ".$auto_common::common_glob->{script_version}."\n") unless($auto_common::common_glob->{script_version} eq "");
  printex("    Configuration version: ".$auto_common::common_glob->{config_version}."\n") unless($auto_common::common_glob->{config_version} eq "");
  printex("                  Project: ".$properties->{remote_build_proj}."\n");
  printex("              Description: ".$properties->{proj_desc}."\n") unless($properties->{proj_desc} eq "");
  printex("               Build host: ".$properties->{remote_build_host}."\n");
  printex("Configuration master host: ".$properties->{remote_inst_config_master_host}."\n");
  printex("            Install hosts: ".$properties->{remote_inst_hosts}."\n") unless($properties->{remote_inst_hosts} eq "");
  printex("-------------------------------------------------\n");
  return;
}

# Descr: Handle command-line parameters (switches).
# Parameters: <input parameter array with <key,value> where value is a hash of parameters>
sub run_cmds {
  #if(auto_common::debug(@_)){return;}
  my ($c, $v)=@_;

  ## Run-switches ##
  if($c eq '-run_pack_scripts') {
    auto_pack::pack_scripts($auto_settings::settings_glob->{pack_file_script});
  }
  elsif($c eq '-run_show_info') {
    show_info();
  }
  
  ## Build-switches ##
  elsif($c eq '-build_setup') {
    my $opt_remove_all_build=$v->{remove_all_build} ? true : false;
    # Check and set known hosts
    auto_setup::check_and_set_known_hosts("build",$properties->{ssh_remote_build},$properties->{remote_build_host});
    # Set up scripts
    auto_setup::setup_scripts_on_host("build",$properties->{ssh_remote_build},$properties->{scp_remote_build},$properties->{remote_build_host},$properties->{remote_script_path_build},$auto_settings::settings_glob->{pack_file_script},$properties->{config_file_path},$properties->{config_file});
    # Set up environment
    auto_setup::setup_environment("build",$properties->{ssh_remote_build},$properties->{remote_build_host},$opt_remove_all_build,"","",$properties->{remote_script_path_build},$properties->{config_file});
  }
  elsif($c eq '-build_check_and_set_known_hosts') {
    # Check and set known hosts
    auto_setup::check_and_set_known_hosts("build",$properties->{ssh_remote_build},$properties->{remote_build_host});
  }
  elsif($c eq '-build_setup_scripts_on_host') {
    # Set up scripts
    auto_setup::setup_scripts_on_host("build",$properties->{ssh_remote_build},$properties->{scp_remote_build},$properties->{remote_build_host},$properties->{remote_script_path_build},$auto_settings::settings_glob->{pack_file_script},$properties->{config_file_path},$properties->{config_file});
  }
  elsif($c eq '-build_setup_environment') {
    my $opt_remove_all_build=$v->{remove_all_build} ? true : false;
    # Set up environment
    auto_setup::setup_environment("build",$properties->{ssh_remote_build},$properties->{remote_build_host},$opt_remove_all_build,"","",$properties->{remote_script_path_build},$properties->{config_file});
  }
  elsif($c eq '-build_project_setup') {
    # Set up project
    auto_build::project_setup($properties->{ssh_remote_build},$properties->{remote_build_host},$properties->{auto_init_setup_project_path},$properties->{cmd_config_build});
  }
  elsif($c eq '-build') {
    my $opt_build_clean=$v->{build_clean} ? true : false;
    my $opt_build_crmod=$v->{build_crmod} ? true : false;
    my $opt_build_cleanmod=$v->{build_cleanmod} ? true : false;
    my $opt_build_co=$v->{build_co} ? true : false;
    my $opt_build_make=$v->{build_make} ? true : false;
    my $opt_build_kits=$v->{build_kits} ? true : false;
    my $opt_check_env=$v->{check_env} ? true : false;
    my $opt_check_oracle=$v->{check_oracle} ? true : false;
    # Check environment
    if($opt_check_env) {
      auto_setup::check_environment("build",$properties->{ssh_remote_build_suser},$properties->{remote_build_host},$properties->{cmd_config_build},"","","",$properties->{remote_script_path_build});
    }
    if($opt_check_oracle) {
      auto_setup::check_oracle_accounts("build",$properties->{ssh_remote_build_suser},$properties->{remote_build_host},$properties->{cmd_config_build},$properties->{remote_script_path_build},$properties->{remote_build_projhome},$properties->{remote_build_projuser});
    }
    # Build kits
    auto_build::build_kits($properties->{ssh_remote_build},$properties->{remote_build_host},$properties->{auto_netman_kits_make_path},$properties->{cmd_config_build},$opt_build_clean,$opt_build_crmod,$opt_build_cleanmod,$opt_build_co,$opt_build_make,$opt_build_kits);
  }
  elsif($c eq '-build_copy_kits') {
    my $opt_copy_kits_local=$v->{copy_kits_local} ? true : false;
    my $opt_copy_kits_local_ifexists=$v->{copy_kits_local_ifexists} ? true : false;
    # Pack built kits
    auto_build::pack_files_build($properties->{ssh_remote_build},$properties->{scp_remote_build},$properties->{remote_build_host},$opt_copy_kits_local,$opt_copy_kits_local_ifexists,$auto_settings::settings_glob->{pack_file_runcons},$properties->{remote_build_projhome},$properties->{remote_build_projuser},$properties->{runcons_name});
    # Pack built spide files
    auto_de400::pack_files_de400($properties->{ssh_remote_build},$properties->{remote_build_host},$auto_settings::settings_glob->{pack_file_spide},$properties->{spide_file_name});
  }
  elsif($c eq '-build_transfer_sync') {
    my $opt_host=$v->{host};
    my $opt_src_path=$v->{src_path};
    my $opt_dst_dir=$v->{dst_dir};
    my $opt_remove_old_files=$v->{remove_old_files} ? true : false;
    my $opt_exclude=$v->{exclude};
    # Transfer files
    auto_pack::transfer_sync($properties->{ssh_remote_build},$properties->{scp_remote_build},$opt_host,$opt_src_path,$opt_dst_dir,$opt_remove_old_files,$opt_exclude);
  }
  elsif($c eq '-build_log_analysis') {
    # Analyze log-files
    auto_build::analyze_logfiles_build($properties->{remote_build_host},$properties->{remote_build_projuser},$properties->{remote_build_projuser});
  }

  ## DE400 installation-switches ##
  elsif($c eq '-de400_get_spide') {
    # Get spide-files
    auto_de400::de400_get_spide($auto_settings::settings_glob->{pack_file_spide},$properties->{spide_file_name});
  }
  elsif($c eq '-de400_setup_de400') {
    my $opt_cont_on_setup_de400_error=$v->{cont_on_setup_de400_error};
    # Run setup_de400.pl
    auto_de400::de400_setup_de400($properties->{spide_drive},$properties->{oraport},$properties->{orahome},$properties->{orahome32},$properties->{orasid},$opt_cont_on_setup_de400_error);
  }
  elsif($c eq '-de400_create_mdb') {
    # Run create_mdb.pl
    auto_de400::update_environment($auto_common::common_glob->{silent_mode});
    auto_de400::de400_create_mdb();
  }
  elsif($c eq '-de400_unlock_account') {
    # Unlock Oracle-account
    auto_de400::update_environment($auto_common::common_glob->{silent_mode});
    auto_de400::de400_unlock_account($properties->{orauser},$properties->{orapwd});
  }
  elsif($c eq '-de400_generate_files') {
    # Generate offset files and pictures
    auto_de400::update_environment($auto_common::common_glob->{silent_mode});
    auto_de400::de400_generate_files($properties->{orauser},$properties->{orapwd});
  }
  elsif($c eq '-de400_approve_db') {
    # Approve the Avanti-database
    auto_de400::update_environment($auto_common::common_glob->{silent_mode});
    auto_de400::de400_approve_db($properties->{orauser},$properties->{orapwd});
  }
  elsif($c eq '-de400_transfer_files') {
    # Package DE400 offset- and picture files
    my $opt_cont_on_xfer_de400_error=$v->{cont_on_xfer_de400_error} ? true : false;
    auto_de400::update_environment($auto_common::common_glob->{silent_mode});
    auto_de400::de400_transfer_files($auto_settings::settings_glob->{pack_file_offset},$auto_settings::settings_glob->{pack_file_pictures},$opt_cont_on_xfer_de400_error);
  }
  elsif($c eq '-de400_restart_oracle') {
    # Restart Oracle
    auto_de400::update_environment($auto_common::common_glob->{silent_mode});
    auto_de400::stop_oracle($auto_settings::settings_glob->{perl});
    auto_de400::start_oracle($auto_settings::settings_glob->{perl});
  }
  elsif($c eq '-de400_log_analysis') {
    # Analyze DE400 log-files
    auto_de400::update_environment($auto_common::common_glob->{silent_mode});
    auto_de400::analyze_logfiles_de400();
  }
  
  ## Installation-switches ##
  elsif($c eq '-install_setup_scripts') {
    # Check configuration master server
    auto_setup::check_and_set_known_hosts("install",$properties->{ssh_remote_install},$properties->{remote_inst_config_master_host});

    # Send scripts to configuration master server
    auto_setup::setup_scripts_on_host("install",$properties->{ssh_remote_install_suser},$properties->{scp_remote_install},$properties->{remote_inst_config_master_host},$properties->{remote_install_bin},$auto_settings::settings_glob->{pack_file_script},$properties->{config_file_path},$properties->{config_file});
  }
  elsif($c eq '-install_get_config') {
    my $opt_streamed=$v->{streamed} ? true : false; # Streamed output that can be eval'ed back later.
    # Get configuration from configuration master server
    auto_install::get_install_config($properties->{ssh_remote_install_suser},$properties->{remote_inst_config_master_host},$properties->{cmd_config_install},$properties->{auto_find_app_servers_path},$properties->{remote_inst_config_master_host},$properties->{remote_inst_hosts},$auto_settings::settings_glob->{temp_path},$opt_streamed);
    
    if($opt_streamed) {
      # Print a streamed version of the configuration arrays (this is the only thing that is allowed to be printed!)
      use Data::Dumper;
      my $dd=Data::Dumper->new([\@auto_install::install_app_servers,\@auto_install::install_app_server_nodes,\@auto_install::install_nodes_included],[qw(*install_app_servers *install_app_server_nodes *install_nodes_included)]);
      $dd->Indent(0)->Purity(1)->Deepcopy(1);#->Useqq(1);
      my $iconf=$dd->Dump;
      $iconf=~s/\ \=\ /\=/g;
      $iconf=~s/\,\ /\,/g;
      $iconf=~s/\(\ /\(/g;
      $iconf=~s/\ \)/\)/g;
      $iconf=~s/=/\@eq\@/g;
      print $iconf;
    }
  }
  elsif($c eq '-install_check_config') {
    auto_install::check_install_config($properties->{remote_inst_config_master_host});
  }
  elsif($c eq '-install_check_and_set_known_hosts') {
    my $opt_host=$v->{host};
    # Check and set known hosts
    auto_setup::check_and_set_known_hosts("install",$properties->{ssh_remote_install},$opt_host);
  }
  elsif($c eq '-install_setup_scripts_on_host') {
    my $opt_host=$v->{host};
    # Set up scripts
    auto_setup::setup_scripts_on_host("install",$properties->{ssh_remote_install_suser},$properties->{scp_remote_install},$opt_host,$properties->{remote_install_bin},$auto_settings::settings_glob->{pack_file_script},$properties->{config_file_path},$properties->{config_file});
  }
  elsif($c eq '-install_setup_environment') {
    my $opt_host=$v->{host};
    my $opt_account=$v->{account};
    my $opt_name=$v->{name};
    my $opt_remove_all=$v->{remove_all} ? true : false;
    # Set up environment
    auto_setup::setup_environment("install",$properties->{ssh_remote_install_suser},$opt_host,$opt_remove_all,$opt_account,$opt_name,$properties->{remote_install_bin},$properties->{config_file});
  }
  elsif($c eq '-install_check_environment') {
    my $opt_host=$v->{host};
    my $opt_account=$v->{account};
    my $opt_name=$v->{name};
    my $opt_typegroup=$v->{typegroup};
    # Check environment
    auto_setup::check_environment("install",$properties->{ssh_remote_install_suser},$opt_host,$properties->{cmd_config_install},$opt_account,$opt_typegroup,$opt_name,$properties->{remote_install_bin});
  }
  elsif($c eq '-install_set_server_mode') {
    my $opt_host=$v->{host};
    my $opt_name=$v->{name};
    my $opt_mode=$v->{mode};
    my $opt_stype=$v->{stype};
    # Start Netman-server in selected mode
    auto_install::install_set_server_mode($properties->{ssh_remote_install},$opt_host,$opt_name,$opt_stype,$opt_mode,$properties->{cmd_config_install},$properties->{auto_cmd_install_path});
  }
  elsif($c eq '-install_reboot_server') {
    my $opt_host=$v->{host};
    # Reboot server
    auto_install::install_reboot($properties->{ssh_remote_install},$opt_host,$properties->{ssh_remote_install_suser},$properties->{cmd_config_install},$properties->{auto_cmd_install_path});
  }
  elsif($c eq '-install_transfer_hub_files_to_host') {
    my $opt_host=$v->{host};
    my $opt_transfer_hub=$v->{transfer_hub} ? true : false;
    my $opt_unpack_hub=$v->{unpack_hub} ? true : false;
    # Transfer hub files
    auto_install::transfer_hub_files_to_host($properties->{ssh_remote_install_suser},$properties->{scp_remote_install_suser},$opt_host,$opt_transfer_hub,$opt_unpack_hub,$auto_settings::settings_glob->{pack_file_runcons},$properties->{runcons_name},$properties->{offsetfiles_name},$properties->{pictures_name},$properties->{remote_hub_dst_path},$auto_settings::settings_glob->{pack_file_offset},$auto_settings::settings_glob->{pack_file_pictures});
  }
  elsif($c eq '-install_transfer_file') {
    my $opt_host=$v->{host};
    my $opt_file_path=$v->{file_path};
    my $opt_remote_path=$v->{remote_path};
    my $opt_alt_name=$v->{alt_name};
    # Transfer file
    auto_install::install_transfer_file($properties->{ssh_remote_install_suser},$properties->{scp_remote_install_suser},$opt_host,$opt_file_path,$opt_remote_path,$opt_alt_name);
  }
  elsif($c eq '-install_start_install') {
    my $opt_host=$v->{host};
    # Run start install
    auto_install::start_install($properties->{ssh_remote_install},$opt_host,$properties->{auto_init_setup_startinstall_path},$properties->{cmd_config_install});
  }
  elsif($c eq '-install_update_host') {
    my $opt_host=$v->{host};
    my $opt_server_name=$v->{server_name};
    my $opt_remove=$v->{remove};
    my $opt_stop_on_missing_db=$v->{stop_on_missing_db};
    my $opt_prodlist=$v->{prodlist};
    # Update server
    auto_install::install_update_host($properties->{ssh_remote_install},$opt_host,$opt_server_name,$opt_remove,$opt_stop_on_missing_db,$properties->{cmd_config_install},$properties->{auto_cmd_install_path},$opt_prodlist);
  }
  elsif($c eq '-install_copy_de_data') {
    my $opt_host=$v->{host};
    my $opt_server_name=$v->{server_name};
    my $opt_stop_on_missing_de=$v->{stop_on_missing_de};
    # Copy DE-data to server
    auto_install::install_copy_de_data($properties->{ssh_remote_install},$opt_host,$opt_server_name,$opt_stop_on_missing_de,$properties->{cmd_config_install},$properties->{auto_cmd_install_path});
  }
  elsif($c eq '-install_transfer_sync') {
    my $opt_host=$v->{host};
    my $opt_src_path=$v->{src_path};
    my $opt_dst_dir=$v->{dst_dir};
    my $opt_remove_old_files=$v->{remove_old_files} ? true : false;
    my $opt_exclude=$v->{exclude};
    # Transfer files
    auto_pack::transfer_sync($properties->{ssh_remote_install_suser},$properties->{scp_remote_install_suser},$opt_host,$opt_src_path,$opt_dst_dir,$opt_remove_old_files,$opt_exclude);
  }
  elsif($c eq '-install_set_boot_option') {
    my $opt_host=$v->{host};
    my $opt_name=$v->{name};
    my $opt_option=$v->{option};
    # Change Netman-server boot option
    auto_install::install_set_boot_option($properties->{ssh_remote_install},$opt_host,$opt_name,$opt_option,$properties->{cmd_config_install},$properties->{auto_cmd_install_path});
  }
  elsif($c eq '-install_udw_db_create') {
    my $opt_host=$v->{host};
    my $opt_name=$v->{name};
    # Create UDW-database
    auto_install::install_udw_db_create($properties->{ssh_remote_install},$opt_host,$opt_name,$properties->{cmd_config_install},$properties->{auto_cmd_install_path});
  }
  elsif($c eq '-install_udw_db_struct_pop') {
    my $opt_host=$v->{host};
    my $opt_name=$v->{name};
    # Perform structural UDW-population
    auto_install::install_udw_db_struct_pop($properties->{ssh_remote_install},$opt_host,$opt_name,$properties->{cmd_config_install},$properties->{auto_cmd_install_path});
  }
  elsif($c eq '-install_avanti_db_create') {
    my $opt_host=$v->{host};
    my $opt_name=$v->{name};
    my $opt_typegroup=$v->{typegroup};
    my $opt_type=$v->{type};
    my $opt_dbi=$v->{dbi};
    my $opt_sbi=$v->{sbi};
    # Create Avanti-database
    auto_install::install_avanti_db_create($properties->{ssh_remote_install},$opt_host,$opt_name,$opt_typegroup,$opt_type,$properties->{cmd_config_install},$properties->{auto_cmd_install_path},$opt_dbi,$opt_sbi);
  }
  elsif($c eq '-install_check_installed_files') {
    my $opt_host=$v->{host};
    my $opt_name=$v->{name};
    my $opt_stop_on_missing_db=$v->{stop_on_missing_db} ? true : false;
    my $opt_dbi=$v->{dbi};
    my $opt_sbi=$v->{sbi};
    # Check relevant installed files
    auto_install::install_check_installed_files($properties->{ssh_remote_install},$opt_host,$opt_name,$opt_stop_on_missing_db,$properties->{cmd_config_install},$properties->{auto_cmd_install_path},$opt_dbi,$opt_sbi);
  }  
  elsif($c eq '-install_avanti_db_pop') {
    my $opt_host=$v->{host};
    my $opt_name=$v->{name};
    my $opt_typegroup=$v->{typegroup};
    my $opt_type=$v->{type};
    # Populate Avanti-database
    auto_de400::update_environment($auto_common::common_glob->{silent_mode});
    auto_install::install_avanti_db_pop($properties->{ssh_remote_install},$opt_host,$opt_name,$opt_typegroup,$opt_type,$properties->{cmd_config_install},$properties->{auto_cmd_install_path},$properties->{orasid});
  }
  elsif($c eq '-install_set_encryption_mode') {
    my $opt_host=$v->{host};
    my $opt_name=$v->{name};
    my $opt_mode=$v->{mode};
    # Change encryption mode
    auto_install::install_set_encryption_mode($properties->{ssh_remote_install},$opt_host,$opt_name,$opt_mode,$properties->{cmd_config_install},$properties->{auto_cmd_install_path});
  }
  elsif($c eq '-install_standby_servers') {
    my $opt_first_udw_host=$v->{first_udw_host};
    my $opt_nodelist=$v->{nodelist};
    # Install standby server
    auto_install::install_standby_servers($properties->{ssh_remote_install_suser},$opt_first_udw_host,$opt_nodelist,$properties->{remote_inst_oracle_pwd});
  }
  elsif($c eq '-install_log_analysis') {
    my $opt_host=$v->{host};
    my $opt_count=$v->{count};
    # Analyze log-files
    auto_install::analyze_logfiles_inst($opt_host,$opt_count);
  }
  elsif($c eq '-install_log_analysis_sub') {
    my $opt_host=$v->{host};
    my $opt_account=$v->{account};
    my $opt_type=$v->{type};
    my $opt_count=$v->{count};
    # Analyze log-files for a user
    auto_install::analyze_logfiles_inst_sub($opt_host,$opt_account,$opt_type,$opt_count);
  }
     
  ## Invalid switches ##
  else {
    printex("Invalid switch $c\n");
  }
  return;
}
1;
