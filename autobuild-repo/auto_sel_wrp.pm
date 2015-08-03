#!/usr/bin/perl
# File:       auto_sel_wrp.pm
# Descr:      Wrapper for auto_sel.
# History:    2011-05-25 Anders Risberg       Initial version.
#
package auto_sel_wrp;
use strict;
use warnings;
use English qw(-no_match_vars); # Avoids regex performance penalty
use constant {false => 0, true => 1};
use auto_sel;
use auto_setup;
use auto_build;
use auto_install;
use auto_de400;
use auto_pack;

# Descr: Handle command-line parameters (switches).
# Parameters: <input parameter array with <key,value> where value is a hash of parameters>
sub run_cmds {
  #if(auto_common::debug(@_)){return;}
  my ($c, $v)=@_;
  
  # Indent text from now on
  $auto_common::common_glob->{print_indent}=1;
    
  ## Run-switches
  if($c eq '-run_remove_temp_scripts') {
    # Descr: Remove temporary scripts package file.
    # Parameters: none
    auto_common::remove_file($auto_settings::settings_glob->{pack_file_script},"Remove temporary scripts pack");
  }
  elsif($c eq '-run_delay') {
    # Descr: Issue a delay.
    # Parameters: <delay in seconds>
    my $opt_delay=$v->{delay};
    auto_common::delay($opt_delay);
  }
  elsif($c eq '-test') {
    # Descr: Test.
    # Parameters: 
    my $opt_test_param_1=defined $v->{-test_param_1} ? $v->{-test_param_1} : "undef";
    my $opt_test_param_2=defined $v->{-test_param_2} ? $v->{-test_param_2} : "undef";
    my $opt_test_param_3=defined $v->{-test_param_3} ? $v->{-test_param_3} : "undef";
    my $opt_test_choise_1=$v->{-test_choise_1} ? true : false;
    my $opt_test_choise_2=$v->{-test_choise_2} ? true : false;
    my $opt_test_choise_3=$v->{-test_choise_3} ? true : false;
    print "Running test:\n\topt_test_param_1:$opt_test_param_1\n\topt_test_param_2:$opt_test_param_2\n\topt_test_param_3:$opt_test_param_3\n\topt_test_choise_1:$opt_test_choise_1\n\topt_test_choise_2:$opt_test_choise_2\n\topt_test_choise_3:$opt_test_choise_3\n";
  }
  elsif($c eq '-test_store_data') {
    # Descr: Test data streaming; store.
    # Parameters: 
    # Print a streamed version of the configuration arrays (this is the only thing that is allowed to be printed!)
    use Class::Struct;
    struct( tlist => [
      name => '$',
      address => '$',
    ]);
    struct( tserver => [
      name => '$',
      type => '$',
      tlist => '@',
    ]);
    my @test_t_servers=();
    my $ts1 = tlist->new;
    $ts1->name("myname_1");
    $ts1->address("myaddr_1");
    my $ts2 = tlist->new;
    $ts2->name("myname_2");
    $ts2->address("myaddr_2");
    my $i=0;
    my $t_server = tserver->new;
    $t_server->name("serv_name");
    $t_server->type("serv_type");
    $t_server->tlist($i++,$ts1);
    $t_server->tlist($i++,$ts2);
    push(@test_t_servers, $t_server);

    use Data::Dumper;
    my $dd=Data::Dumper->new([\@test_t_servers],[qw(*test_t_servers)]);
    $dd->Indent(0)->Purity(1)->Deepcopy(1);#->Useqq(1);
    my $iconf=$dd->Dump;
    $iconf=~s/\ \=\ /\=/g;
    $iconf=~s/\,\ /\,/g;
    $iconf=~s/\(\ /\(/g;
    $iconf=~s/\ \)/\)/g;
    $iconf=~s/=/\@eq\@/g;
    print $iconf;
  }
  elsif($c eq '-test_restore_data') {
    # Descr: Test data streaming; restore.
    # Parameters: 
    print "Restoring data.\n";
  }
  
  ## Build-switches ##
  elsif($c eq '-build_log_transfer') {
    # Descr: Transfer build log-files to the log-directory.
    # Parameters: none
    auto_sel::run_cmds('-build_transfer_sync',{host => $auto_sel::properties->{remote_build_host},src_path => "autobuild_logs/",dst_dir => $auto_sel::properties->{remote_build_projuser},remove_old_files => true,exclude => \@{$auto_settings::settings_glob->{rsync_exclude}}});
  }

  ## Installation-switches ##
  elsif($c eq '-install_set_boot_option_multi') {
    # Descr: Set the boot option for several installation hosts.
    # Parameters: <option> <server type> <set for A-servers only>
    my $opt_option=$v->{option};
    my $opt_stype=$v->{stype};
    my $opt_asrv=$v->{asrv} ? true : false;
    my $found=false;
    foreach my $as (@auto_install::install_app_servers) {
      if($opt_stype eq "" || $as->type eq $opt_stype) {
        my @nodes=();
        @nodes=auto_install::get_inner_nodes_included($as,$opt_asrv ? auto_install::SERVERS_A : auto_install::SERVERS_ALL);
        foreach my $n (@nodes) {
          auto_sel::run_cmds('-install_set_boot_option',{host => $n,name => $as->name,option => $opt_option});
          $found=true;
        }
      }
    }
    if(!$found) { print "No affected server found.\n"; }
  }
  elsif($c eq '-install_set_server_mode_multi') {
    # Descr: Set the server mode for several installation hosts.
    # Parameters: <mode> <server type group> <server type (all if empty)> <excluded server types> <set for A-servers/non A-servers only> <skip if this type of master>
    my $opt_mode=$v->{mode};
    my $opt_stype_group=$v->{stype_group};
    my $opt_stype=$v->{stype};
    my $opt_stype_exclude=$v->{stype_exclude};
    my $opt_asrv=$v->{asrv} ? true : false;
    my $opt_skip_if_master_type=$v->{skip_if_master_type};
    my $found=false;
    foreach my $as (@auto_install::install_app_servers) {
      if(($opt_stype_group         eq "" || $opt_stype_group         eq $as->typegroup) &&
         ($opt_stype               eq "" || $opt_stype               eq $as->type) &&
         ($opt_stype_exclude       eq "" || $opt_stype_exclude       ne $as->type) &&
         ($opt_skip_if_master_type eq "" || $opt_skip_if_master_type ne $as->mastertype)) {
        my @nodes=();
        @nodes=auto_install::get_inner_nodes_included($as,$opt_asrv ? auto_install::SERVERS_A : auto_install::SERVERS_NON_A);
        foreach my $n (@nodes) {
          auto_sel::run_cmds('-install_set_server_mode',{host => $n,name => $as->name,mode => $opt_mode,stype => $opt_stype});
          $found=true;
        }
      }
    }
    if(!$found) { print "No affected server found.\n"; }
  }
  elsif($c eq '-install_check_and_setup_non_config_master') {
    # Descr: Check and setup the non-configuration master servers, if any.
    # Parameters: <always check and set known hosts>
    my $opt_force_check_and_set_known_hosts=$v->{force_check_and_set_known_hosts} ? true : false;
    my $found=false;
    foreach my $n (auto_install::get_nodes_included(auto_install::SERVERS_ALL)) {
      if($n eq $auto_sel::properties->{remote_inst_config_master_host}) { next; }
      if($n ne $auto_sel::properties->{remote_build_host} || $opt_force_check_and_set_known_hosts) {
        auto_sel::run_cmds('-install_check_and_set_known_hosts',{host => $n});
      }
      auto_sel::run_cmds('-install_setup_scripts_on_host',{host => $n});
      $found=true;
    }
    if(!$found) { print "No affected server found.\n"; }
  } 
  elsif($c eq '-install_setup_environment') {
    # Descr: Set up and check environment on servers.
    # Parameters: <a-servers only> <remove old installations on servers>
    my $opt_asrv=$v->{asrv} ? true : false;
    my $opt_remove_all=$v->{remove_all} ? true : false;
    my $found=false;
    foreach my $as (@auto_install::install_app_servers) {
      my $i=0;
      foreach my $n (auto_install::get_inner_nodes_included($as,$opt_asrv ? auto_install::SERVERS_A : auto_install::SERVERS_NON_A)) {
        if($i++ > 0 || $opt_asrv) { # TODO: Check why this is needed
          auto_sel::run_cmds('-install_setup_environment',{host => $n,account => $as->account,name => $as->name,remove_all => $opt_remove_all});
          auto_sel::run_cmds('-install_check_environment',{host => $n,account => $as->account,name => $as->name,typegroup => $as->typegroup});
          $found=true;
        }
      }
    }
    if(!$found) { print "No affected server found.\n"; }
  }
  elsif($c eq '-install_reboot_server') {
    # Descr: Reboot servers.
    # Parameters: <a-servers only>
    my $opt_asrv=$v->{asrv} ? true : false;
    my $found=false;
    foreach my $n (auto_install::get_nodes_included($opt_asrv ? auto_install::SERVERS_A : auto_install::SERVERS_NON_A)) {
      auto_sel::run_cmds('-install_reboot_server',{host => $n});
      $found=true;
    }
    if(!$found) { print "No affected server found.\n"; }
  }
  elsif($c eq '-install_transfer_product_files') {
    # Descr: Transfer product files to servers.
    # Parameters: <a-servers only>
    my $opt_asrv=$v->{asrv} ? true : false;
    my $found=false;
    foreach my $as (@auto_install::install_app_servers) {
      foreach my $nl (auto_install::get_inner_nodelists_included($as,$opt_asrv ? auto_install::SERVERS_A : auto_install::SERVERS_NON_A)) {
        if($nl->prodlist) {
          auto_sel::run_cmds('-install_transfer_file',{host => $nl->name,file_path => $auto_settings::settings_glob->{temp_path}."/prodlist/".$nl->prodlist.".prodlist",remote_path => $auto_sel::properties->{remote_hub_dst_path}."/".$auto_sel::properties->{runcons_name},alt_name => ""});
          $found=true;
        }
      }
    }
    if(!$found) { print "No affected server found.\n"; }
  }
  elsif($c eq '-install_transfer_hub_files_to_host') {
    # Descr: Transfer hub files to servers.
    # Parameters: <a-servers only> <transfer files to install host hub> <unpack files on install host hub>
    my $opt_asrv=$v->{asrv} ? true : false;
    my $opt_transfer_hub=$v->{transfer_hub} ? true : false;
    my $opt_unpack_hub=$v->{unpack_hub} ? true : false;
    my $found=false;
    foreach my $n (auto_install::get_nodes_included($opt_asrv ? auto_install::SERVERS_A : auto_install::SERVERS_NON_A)) {
      auto_sel::run_cmds('-install_transfer_hub_files_to_host',{host => $n,transfer_hub => $opt_transfer_hub,unpack_hub => $opt_unpack_hub});
      $found=true;
    }
    if(!$found) { print "No affected server found.\n"; }
  }
  elsif($c eq '-install_start_install') {
    # Descr: Run start install.
    # Parameters: <a-servers only>
    my $opt_asrv=$v->{asrv} ? true : false;
    my $found=false;
    foreach my $n (auto_install::get_nodes_included($opt_asrv ? auto_install::SERVERS_A : auto_install::SERVERS_NON_A)) {
      auto_sel::run_cmds('-install_start_install',{host => $n});
      $found=true;
    }
    if(!$found) { print "No affected server found.\n"; }
  }
  elsif($c eq '-install_update_host') {
    # Descr: Update servers. 
    # Parameters: <a-servers only> <stop on missing database files> <stop on missing de400-files>
    my $opt_asrv=$v->{asrv} ? true : false;
    my $opt_stop_on_missing_db=$v->{stop_on_missing_db};
    my $opt_stop_on_missing_de=$v->{stop_on_missing_de};
    my $found=false;
    foreach my $as (@auto_install::install_app_servers) {
      foreach my $nl (auto_install::get_inner_nodelists_included($as,$opt_asrv ? auto_install::SERVERS_A : auto_install::SERVERS_NON_A)) {
        if(!$opt_asrv && $auto_sel::properties->{renew_tickets} eq "true" && $auto_sel::properties->{use_install_pwd} eq "false") {
          auto_sel::run_cmds('-install_set_encryption_mode',{host => $auto_sel::properties->{remote_inst_config_master_host},name => $auto_install::install_app_servers[0]->name,mode => 'off'});
          auto_sel::run_cmds('-install_set_encryption_mode',{host => $nl->name,name => $as->name,mode => 'off'});
        }
        auto_sel::run_cmds('-install_update_host',{host => $nl->name,server_name => $as->name,remove => true,stop_on_missing_db => $opt_stop_on_missing_db,prodlist => $nl->prodlist});
        if(!$opt_asrv && $auto_sel::properties->{renew_tickets} eq "true" && $auto_sel::properties->{use_install_pwd} eq "false") {
          # TODO: Make sure this is done despite errors, die_msg, etc.
          auto_sel::run_cmds('-install_set_encryption_mode',{host => $auto_sel::properties->{remote_inst_config_master_host},name => $auto_install::install_app_servers[0]->name,mode => 'on'});
          auto_sel::run_cmds('-install_set_encryption_mode',{host => $nl->name,name => $as->name,mode => 'on'});
        }
        if(!$opt_asrv) {
          auto_sel::run_cmds('-install_check_installed_files',{host => $nl->name,name => $as->name,stop_on_missing_db => $opt_stop_on_missing_db,dbi => $as->dbi,sbi => $as->sbi});
        }
        if($as->typegroup eq "SCADA") {
          if ($opt_asrv) {
            auto_sel::run_cmds('-install_copy_de_data',{host => $nl->name,server_name => $as->name,stop_on_missing_db => $opt_stop_on_missing_de});
          }
          auto_sel::run_cmds('-install_transfer_file',{host => $nl->name,file_path => $auto_settings::settings_glob->{temp_path}."/".$auto_settings::settings_glob->{file_ws500_license},remote_path => "/usr/users/".$as->account."/spi0/spimgr/",alt_name => ""});
          auto_sel::run_cmds('-install_transfer_file',{host => $nl->name,file_path => $auto_settings::settings_glob->{temp_path}."/".$auto_settings::settings_glob->{file_ws500_licence},remote_path => "/usr/users/".$as->account."/spi0/spimgr/",alt_name => ""});
        }
        auto_sel::run_cmds('-install_transfer_sync',{host => $nl->name,src_path => "/usr/local/config/spiconf.log",dst_dir => "",remove_old_files => false,exclude => \@{$auto_settings::settings_glob->{rsync_exclude}}});
        auto_sel::run_cmds('-install_transfer_sync',{host => $nl->name,src_path => "/usr/users/".$as->account."/spi0/spierr/",dst_dir => $as->account,remove_old_files => true,exclude => \@{$auto_settings::settings_glob->{rsync_exclude}}});
        $found=true;
      }
    }
    if(!$found) { print "No affected server found.\n"; }
  }
  elsif($c eq '-install_create_udw_db') {
    # Descr: Create the UDW-databases on A-servers.
    # Parameters: 
    my $found=false;
    foreach my $as (@auto_install::install_app_servers) {
      foreach my $n (auto_install::get_inner_nodes_included($as,auto_install::SERVERS_A)) {
        if($as->type eq "UDW") {
          auto_sel::run_cmds('-install_udw_db_create',{host => $n,name => $as->name});
          auto_sel::run_cmds('-install_transfer_sync',{host => $n,src_path => "/usr/local/config/spiconf.log",dst_dir => "",remove_old_files => false,exclude => \@{$auto_settings::settings_glob->{rsync_exclude}}});
          auto_sel::run_cmds('-install_transfer_sync',{host => $n,src_path => "/usr/users/".$as->account."/spi0/spierr/",dst_dir => $as->account,remove_old_files => false,exclude => \@{$auto_settings::settings_glob->{rsync_exclude}}});
          $found=true;
        }
      }
    }
    if(!$found) { print "No affected server found.\n"; }
  }
  elsif($c eq '-install_pop_udw_db') {
    # Descr: Populate the UDW-databases on A-servers.
    # Parameters: 
    my $found=false;
    foreach my $as (@auto_install::install_app_servers) {
      foreach my $n (auto_install::get_inner_nodes_included($as,auto_install::SERVERS_A)) {
        if($as->type eq "UDW") {
          auto_sel::run_cmds('-install_udw_db_struct_pop',{host => $n,name => $as->name});
          auto_sel::run_cmds('-install_transfer_sync',{host => $n,src_path => "/usr/local/config/spiconf.log",dst_dir => "",remove_old_files => false,exclude => \@{$auto_settings::settings_glob->{rsync_exclude}}});
          auto_sel::run_cmds('-install_transfer_sync',{host => $n,src_path => "/usr/users/".$as->account."/spi0/spierr/",dst_dir => $as->account,remove_old_files => false,exclude => \@{$auto_settings::settings_glob->{rsync_exclude}}});
          $found=true;
        }
      }
    }
    if(!$found) { print "No affected server found.\n"; }
  }
  elsif($c eq '-install_create_avanti_db') {
    # Descr: Create the Avanti-databases on A-servers.
    # Parameters: <stop on missing database files>
    my $opt_stop_on_missing_db=$v->{stop_on_missing_db};
    my $found=false;
    foreach my $as (@auto_install::install_app_servers) {
      foreach my $n (auto_install::get_inner_nodes_included($as,auto_install::SERVERS_A)) {
        auto_sel::run_cmds('-install_avanti_db_create',{host => $n,name => $as->name,typegroup => $as->typegroup,type => $as->type,dbi => $as->dbi,sbi => $as->sbi});
        auto_sel::run_cmds('-install_check_installed_files',{host => $n,name => $as->name,stop_on_missing_db => $opt_stop_on_missing_db,dbi => $as->dbi,sbi => $as->sbi});
        auto_sel::run_cmds('-install_transfer_sync',{host => $n,src_path => "/usr/local/config/spiconf.log",dst_dir => "",remove_old_files => false,exclude => \@{$auto_settings::settings_glob->{rsync_exclude}}});
        auto_sel::run_cmds('-install_transfer_sync',{host => $n,src_path => "/usr/users/".$as->account."/spi0/spierr/",dst_dir => $as->account,remove_old_files => false,exclude => \@{$auto_settings::settings_glob->{rsync_exclude}}});
        $found=true;
      }
    }
    if(!$found) { print "No affected server found.\n"; }
  }
  elsif($c eq '-install_pop_avanti_db') {
    # Descr: Populate the Avanti-database on A-servers.
    # Parameters: none
    my $found=false;
    foreach my $as (@auto_install::install_app_servers) {
      foreach my $n (auto_install::get_inner_nodes_included($as,auto_install::SERVERS_A)) {
        if($as->typegroup eq "SCADA") {
          auto_sel::run_cmds('-install_avanti_db_pop',{host => $n,name => $as->name,typegroup => $as->typegroup,type => $as->type});
        }
        auto_sel::run_cmds('-install_transfer_sync',{host => $n,src_path => "/usr/local/config/spiconf.log",dst_dir => "",remove_old_files => false,exclude => \@{$auto_settings::settings_glob->{rsync_exclude}}});
        auto_sel::run_cmds('-install_transfer_sync',{host => $n,src_path => "/usr/users/".$as->account."/spi0/spierr/",dst_dir => $as->account,remove_old_files => false,exclude => \@{$auto_settings::settings_glob->{rsync_exclude}}});
        $found=true;
      }
    }
    if(!$found) { print "No affected server found.\n"; }
  }
  elsif($c eq '-install_standby_servers') {
    # Descr: Install standby servers.
    # Parameters: none
    # Find the first UDW-type server (should be the one that was populated)
    my $first_udw_host="";
    foreach my $as (@auto_install::install_app_servers) {
      if($as->type eq "UDW") {
        # Find the first node for this application server type
        foreach my $nl (@{$as->nodelist}) {
          my $retval = auto_install::find_name($nl->name,@auto_install::install_app_server_nodes);
          if($retval ne '' && $retval->aserver) {
            $first_udw_host=$nl->name;
            last;
          }
        }
        if($first_udw_host) {last;}
      }
    }
    # First create list of UDW-servers to setup
    my $nodeList="";
    foreach my $as (@auto_install::install_app_servers) {
      foreach my $n (auto_install::get_inner_nodes_included($as,auto_install::SERVERS_ALL)) {
        if($as->type eq "UDW") {
          $nodeList=$nodeList.$n." ";
        }
      }
    }
    $nodeList=~ s/^\s+//;
    $nodeList=~ s/\s+$//;
    auto_sel::run_cmds('-install_standby_servers',{first_udw_host => $first_udw_host,nodelist => $nodeList});
  }
  elsif($c eq '-install_log_transfer') {
    # Descr: Transfer installation log-files to the log-directory.
    # Parameters: none
    my $found=false;
    foreach my $as (@auto_install::install_app_servers) {
      foreach my $n (auto_install::get_inner_nodes_included($as,auto_install::SERVERS_ALL)) {
        auto_sel::run_cmds('-install_transfer_sync',{host => $n,src_path => "/usr/local/config/spiconf.log",dst_dir => "",remove_old_files => false,exclude => \@{$auto_settings::settings_glob->{rsync_exclude}}});
        auto_sel::run_cmds('-install_transfer_sync',{host => $n,src_path => "/usr/users/".$as->account."/spi0/spierr/",dst_dir => $as->account,remove_old_files => false,exclude => \@{$auto_settings::settings_glob->{rsync_exclude}}});
        $found=true;
      }
    }
    if(!$found) { print "No affected server found.\n"; }
  }
  elsif($c eq '-install_log_analysis') {
    # Descr: Analyze installation log-files.
    # Parameters: none
    my $cnt = 0;
    my $found=false;
    foreach my $n (auto_install::get_nodes_included(auto_install::SERVERS_ALL)) {
      $cnt++; ## TODO - counter probably unaligned after change to get_nodes_included
      auto_sel::run_cmds('-install_log_analysis',{host => $n,count => $cnt});
      $found=true;
    }
    foreach my $as (@auto_install::install_app_servers) {
      my $cnt = 0;
      foreach my $n (auto_install::get_inner_nodes_included($as,auto_install::SERVERS_ALL)) {
        $cnt++; ## TODO - counter probably unaligned after change to get_nodes_included
        auto_sel::run_cmds('-install_log_analysis_sub',{host => $n,account => $as->account,type => $as->type,count => $cnt});
        $found=true;
      }
    }
    if(!$found) { print "No affected server found.\n"; }
  }
  
  ## Other switches ##
  else {
    # Pass on ...
    auto_sel::run_cmds($c, $v);
  }
  
  # Reset indentation
  $auto_common::common_glob->{print_indent}=0;
  return;
}
1;
