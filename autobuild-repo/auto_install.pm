#!/usr/bin/perl
# File:       auto_install.pm
# Descr:      Autobuild install routines.
# History:    2011-02-02 Anders Risberg       Initial version (moved from auto_run_all.pl).
#             2011-04-29 Anders Risberg       Added check of data consistency with Avanti-db after popuation.
#             2011-06-17 Anders Risberg       Silent mode for get_install_config().
#
package auto_install;
use strict;
use warnings;
use English qw(-no_match_vars); # Avoids regex performance penalty
use Class::Struct;
use constant {false => 0, true => 1};
use constant {SERVERS_ALL => 0, SERVERS_A => 1, SERVERS_NON_A => 2};
use auto_common qw(printex remote_cmd remote_cmd_outp remote_cp);

# Structure to keep installation server configuration
struct( nodelist => [
  name => '$',
  prodlist => '$',
]);
struct( app_server => [
  name => '$',
  type => '$',
  typegroup => '$',
  account => '$',
  ismaster => '$',
  master => '$',
  mastertype => '$',
  dbi => '$',
  sbi => '$',
  nodelist => '@',
]);
struct( app_server_node => [
  name => '$',
  install => '$',
  aserver => '$',
]);
our @install_app_servers=(); # struct app_server
our @install_app_server_nodes=(); # struct app_server_node
our @install_nodes_included=();

# Descr: Run startinstall.
# Parameters: <ssh command> <host name> <path to startinstall> <config install command>
sub start_install {
  #if(auto_common::debug(@_)){return;}
  my ($ssh_cmd,$remote_host,$auto_init_setup_startinstall_path,$cmd_config_install)=@_;
  printex("Start pre-install on install host $remote_host ...\n");
  remote_cmd(true, $ssh_cmd, $remote_host, "ksh $auto_init_setup_startinstall_path $cmd_config_install --run");
  return;
}

# Descr: Update installation host.
# Parameters: <ssh command> <host name> <sever name> <remove files first> <stop if db-files are missing after install> <config install command> <install path> <product list name>
sub install_update_host {
  #if(auto_common::debug(@_)){return;}
  my ($ssh_cmd,$remote_host,$server_name,$remove,$opt_stop_on_missing_db,$cmd_config_install,$auto_cmd_install_path,$prodlist_name)=@_;
  printex("Update server $server_name on install host $remote_host ...\n");
  remote_cmd(true, $ssh_cmd, $remote_host, "$auto_cmd_install_path $cmd_config_install --update_server -s $server_name -p" . ($prodlist_name ? " ".$prodlist_name : " default") . ($remove ? " --update_server_remove" : "") . ($opt_stop_on_missing_db ? " --stop_on_missing_db" : ""));
  return;
}

# Descr: Set the encryption mode on an installation host.
# Parameters: <ssh command> <host name> <sever name> <mode> <config install command> <install path>
sub install_set_encryption_mode {
  #if(auto_common::debug(@_)){return;}
  my ($ssh_cmd,$remote_host,$server_name,$mode,$cmd_config_install,$auto_cmd_install_path)=@_;
  printex("Turning $mode encryption mode on server $server_name on install host $remote_host ...\n");
  if($mode eq 'on') {
    remote_cmd(true, $ssh_cmd, $remote_host, "$auto_cmd_install_path $cmd_config_install --turnon_encryption -s $server_name");
  }
  elsif($mode eq 'off') {
    remote_cmd(true, $ssh_cmd, $remote_host, "$auto_cmd_install_path $cmd_config_install --turnoff_encryption -s $server_name");
  }
  else {
    die "Trying to set invalid encryption mode ($mode).";
  }
  return;
}

# Descr: Copy the DE400-data files.
# Parameters: <ssh command> <host name> <sever name> <stop if de-files are missing> <config install command> <install path>
sub install_copy_de_data {
  #if(auto_common::debug(@_)){return;}
  my ($ssh_cmd,$remote_host,$server_name,$opt_stop_on_missing_de,$cmd_config_install,$auto_cmd_install_path)=@_;
  printex("Copy DE-data to server $server_name on install host $remote_host ...\n");
  remote_cmd(true, $ssh_cmd, $remote_host, "$auto_cmd_install_path $cmd_config_install --run_copy_de_data -s $server_name" . ($opt_stop_on_missing_de ? " --stop_on_missing_de" : ""));
  return;
}

# Descr: Transfer a file to a host.
# Parameters: <ssh command> <scp command> <host name> <local path to file> <remote path> <new name>
sub install_transfer_file {
  #if(auto_common::debug(@_)){return;}
  my ($ssh_cmd,$scp_cmd,$remote_host,$file_path,$remote_path,$alt_name)=@_;
  printex("Transfer file $file_path to install host $remote_host:$remote_path ...\n");
  if(-e "$file_path") {
    my $ret=remote_cmd(false, $ssh_cmd, $remote_host, "\"if [[ -d $remote_path ]];then exit 0;else exit 1;fi\"");
    if($ret eq 0) {
      print "<#stay>1<#>\n";
      remote_cp(true, $scp_cmd, "\"$file_path\"", "$remote_host:$remote_path/$alt_name");
      print "<#stay>0<#>\n";
    }
    else {
      printex("Warning! File $file_path found but couldn't be copied to server.\n");
    }
  }
  else {
    printex("Warning! File $file_path not found.\n");
  }
  return;
}

# Descr: Create a UDW-database.
# Parameters: <ssh command> <host name> <server name> <config install command> <install path>
sub install_udw_db_create {
  #if(auto_common::debug(@_)){return;}
  my ($ssh_cmd,$remote_host,$server_name,$cmd_config_install,$auto_cmd_install_path)=@_;
  printex("Create UDW-db on server $server_name on install host $remote_host ...\n");
  remote_cmd(true, $ssh_cmd, $remote_host, "$auto_cmd_install_path $cmd_config_install --udw_db_create -s $server_name");
  return;
}

# Descr: Structural populaton of a UDW-database.
# Parameters: <ssh command> <host name> <server name> <config install command> <install path>
sub install_udw_db_struct_pop {
  #if(auto_common::debug(@_)){return;}
  my ($ssh_cmd,$remote_host,$server_name,$cmd_config_install,$auto_cmd_install_path)=@_;
  printex("Structural UDW-population on server $server_name on install host $remote_host ...\n");
  remote_cmd(true, $ssh_cmd, $remote_host, "$auto_cmd_install_path $cmd_config_install --udw_db_struct_pop -s $server_name");
  return;
}

# Descr: Create an Avanti-database.
# Parameters: <ssh command> <host name> <server name> <config install command> <install path> <database index> <study database index>
sub install_avanti_db_create {
  #if(auto_common::debug(@_)){return;}
  my ($ssh_cmd,$remote_host,$server_name,$server_type_group,$server_type,$cmd_config_install,$auto_cmd_install_path,$dbi,$sbi)=@_;
  printex("Create Avanti-db on server $server_name on install host $remote_host ...\n");
  remote_cmd(true, $ssh_cmd, $remote_host, "$auto_cmd_install_path $cmd_config_install --avanti_db_create -s $server_name -tg $server_type_group -t $server_type" . ($dbi ? " -dbi $dbi" : "") . ($sbi ? " -sbi $sbi" : ""));
  return;
}

# Descr: Populaton of a Avanti-database.
# Parameters: <ssh command> <host name> <server name> <config install command> <install path>
sub install_avanti_db_pop {
  #if(auto_common::debug(@_)){return;}
  my ($ssh_cmd,$remote_host,$server_name,$server_type_group,$server_type,$cmd_config_install,$auto_cmd_install_path,$orasid)=@_;
  printex("Populate Avanti-db on server $server_name on install host $remote_host ...\n");
  remote_cmd(true, $ssh_cmd, $remote_host, "$auto_cmd_install_path $cmd_config_install --avanti_db_pop -s $server_name -tg $server_type_group -t $server_type");
  printex("Approve Avanti-db on server $server_name on install host $remote_host ...\n");
  remote_cmd(true, $ssh_cmd, $remote_host, "$auto_cmd_install_path $cmd_config_install --avanti_db_app -s $server_name -tg $server_type_group -t $server_type");
  
  my $orauser = "cc_user";
  my $orapwd = "cc_user";
  my $gen_num = auto_de400::de400_get_db_value($orauser,$orapwd,$orasid,"select ltrim(rtrim(old_generation_nr)) from spider_system where spisys_acronym='PROJ'");
  die "Generated number not valid (empty)." if $gen_num eq "";
  my $gen_date = auto_de400::de400_get_db_value($orauser,$orapwd,$orasid,"select to_char(old_load_date,'DD-Mon-YY HH:MI:SS','nls_date_language = AMERICAN') from spider_system where spisys_acronym='PROJ'");
  die "Generated date not valid (empty)." if $gen_date eq "";
  
  printex("Check data consistency with Avanti-db on server $server_name on install host $remote_host ...\n");
  remote_cmd(true, $ssh_cmd, $remote_host, "$auto_cmd_install_path $cmd_config_install --check_popdata -s $server_name -dcn $gen_num -dcd $gen_date");
  return;
}

# Descr: Set the boot option on an installation host.
# Parameters: <ssh command> <host name> <server name> <option> <config install command> <install path>
sub install_set_boot_option {
  #if(auto_common::debug(@_)){return;}
  my ($ssh_cmd,$remote_host,$server_name,$opt,$cmd_config_install,$auto_cmd_install_path)=@_;
  my $param="";
  if($opt eq 'stopped') { $param="stop"; }
  else { die "Wrong option in install_set_boot_option ($opt)."; }
  printex("Change server boot option to '$opt' on server $server_name on install host $remote_host ...\n");
  remote_cmd(true, $ssh_cmd, $remote_host, "$auto_cmd_install_path $cmd_config_install --set_boot_option $param -s $server_name");
  return;
}

# Descr: Set the server mode on an installation host.
# Parameters: <ssh command> <host name> <server name> <mode> <config install command> <install path>
sub install_set_server_mode {
  #if(auto_common::debug(@_)){return;}
  my ($ssh_cmd,$remote_host,$server_name,$server_type,$mode,$cmd_config_install,$auto_cmd_install_path)=@_;
  my $param="";
  if($mode eq 'stop') { $param="--set_server_stop"; }
  elsif($mode eq 'batch') { $param="--set_server_bat"; }
  elsif($mode eq 'cold') { $param="--set_server_cold"; }
  elsif($mode eq 'pass') { $param="--set_server_pass"; }
  else { die "Wrong mode in install_set_server_mode ($mode)."; }
  printex("Change server operation mode to '$mode' on server $server_name on install host $remote_host ...\n");
  remote_cmd(true, $ssh_cmd, $remote_host, "$auto_cmd_install_path $cmd_config_install $param -s $server_name -t $server_type");
  return;
}

# Descr: Check that some of the relevant files were copied during install.
# Parameters: <ssh command> <host name> <server name> <stop if files are missing> <config install command> <install path> <database index> <study database index>
sub install_check_installed_files {
  #if(auto_common::debug(@_)){return;}
  my ($ssh_cmd,$remote_host,$server_name,$opt_stop_on_missing_db,$cmd_config_install,$auto_cmd_install_path,$dbi,$sbi)=@_;
  printex("Checking relevant installed files on install host $remote_host ...\n");
  remote_cmd(true, $ssh_cmd, $remote_host, "$auto_cmd_install_path $cmd_config_install --check_installed_files -s $server_name -dbi $dbi -sbi $sbi" . ($opt_stop_on_missing_db ? " --stop_on_missing_db" : ""));
  return;
}

# Descr: Reboot server host.
# Parameters: <ssh command> <host name> <ssh install super user>
sub install_reboot {
  #if(auto_common::debug(@_)){return;}
  my ($ssh_cmd,$remote_host,$ssh_remote_install_suser,$cmd_config_install,$auto_cmd_install_path)=@_;
  my $retr=120;
  my $tout=10;
  # Shutdown Oracle on UDW-type nodes only
  foreach my $as (find_servers($remote_host)) {
    if($as->type eq "UDW") {
      printex("Shut down Oracle-server before reboot on install host $remote_host ...\n");
      remote_cmd(true, $ssh_cmd, $remote_host, "$auto_cmd_install_path $cmd_config_install --udw_abort -s " . $as->name);
      last;
    }
  }

  printex("Rebooting install host $remote_host; network errors may occur; max waiting time: ".$retr*$tout." s ...\n");
  my $ret=auto_common::reboot_host($ssh_remote_install_suser,$remote_host,$retr,$tout);
  $ret != 0 or die "Re-boot failed - timeout after ".$retr*$tout." seconds.\n";
  printex("  Came back after $ret seconds.\n");
  return;
}

# Descr: Get application servers from configuration on install host.
# Note: Streamed. Do not output anything else than configuration information, e.g. debug, etc.
# Parameters: <ssh install super user> <host name> <config install command> <install path> <conf_master> <installation hosts> <temp-dir path> <silent mode>
sub get_install_config {
  my ($ssh_cmd,$remote_host,$cmd_config_install,$auto_find_app_servers_path,$remote_inst_config_master_host,$remote_inst_hosts,$temp_path,$opt_silent)=@_;
  my @args=();
  if(!$opt_silent) {printex("Get configuration master node from configuration on install host $remote_host ...\n");}
  my ($ret1, $conf_master_node)=remote_cmd_outp(true, false, $ssh_cmd, $remote_host, "$auto_find_app_servers_path $cmd_config_install --get_conf_master_node");
  if(!$opt_silent) {printex("  Found: $conf_master_node\n");}
  $conf_master_node eq $remote_inst_config_master_host or die "The retrieved configuration master node (conf_master_node) doesn't match the given node ($remote_inst_config_master_host).";
  if(!$opt_silent) {printex("Get application servers from configuration on install host $remote_host ...\n");}
  my ($ret2, $app_srv)=remote_cmd_outp(true, false, $ssh_cmd, $remote_host, "$auto_find_app_servers_path $cmd_config_install --get_servers");

  # Put the list of servers into a temporary array
  my @app_srv = split(' ', $app_srv);

  # Setup list of included installation hosts
  if($remote_inst_hosts ne "") {
    if($remote_inst_hosts=~tr/A-Za-z0-9 _\-/!/c) {die "Can't handle special characters except ' _-' in install_hosts-parameter.\n";}
    @install_nodes_included=split(' ', $remote_inst_hosts);
  }

  # Go through the temporary array of servers and fetch needed info
  my @app_servers=(); # struct app_server
  foreach my $as (@app_srv) {
    # Initiate a new app_server item
    my $app_server = app_server->new;
    $app_server->name($as);
    $app_server->ismaster(false);
    # Get server type
    my ($ret, $retval)=remote_cmd_outp(true, false, $ssh_cmd, $remote_host, "$auto_find_app_servers_path $cmd_config_install --get_server_type -s $as");
    $app_server->type($retval);
    # Set server type group
    if(@{$auto_settings::settings_glob->{non_scada_types}} && (grep {$_ eq $app_server->type} @{$auto_settings::settings_glob->{non_scada_types}}) eq 0) { $app_server->typegroup("SCADA"); }
    else { $app_server->typegroup("OTHER"); }
    # Get server account name
    ($ret, $retval)=remote_cmd_outp(true, false, $ssh_cmd, $remote_host, "$auto_find_app_servers_path $cmd_config_install --get_account -s $as");
    $app_server->account($retval);
    # Get server master
    ($ret, $retval)=remote_cmd_outp(true, false, $ssh_cmd, $remote_host, "$auto_find_app_servers_path $cmd_config_install --get_master -s $as");
    $app_server->master($retval);
    # Get server database index
    ($ret, $retval)=remote_cmd_outp(true, false, $ssh_cmd, $remote_host, "$auto_find_app_servers_path $cmd_config_install --get_dbi -s $as");
    $app_server->dbi($retval);
    # Get server studio database index
    ($ret, $retval)=remote_cmd_outp(true, false, $ssh_cmd, $remote_host, "$auto_find_app_servers_path $cmd_config_install --get_sbi -s $as");
    $app_server->sbi($retval);
    
    # Get server nodes
    ($ret, $retval)=remote_cmd_outp(true, false, $ssh_cmd, $remote_host, "$auto_find_app_servers_path $cmd_config_install --get_nodes -s $as");
    # Create lists of nodes of various types    
    my @srv_nodes = split(' ', $retval);
    my $i=0;
    foreach my $n (@srv_nodes) {
      my $app_server_node = find_name($n, @install_app_server_nodes);
      if($app_server_node eq '') {
        # Initiate a new app_server_node item
        $app_server_node = app_server_node->new;
        $app_server_node->name($n);
        $app_server_node->install(true);
        $app_server_node->aserver(false);
        push(@install_app_server_nodes,$app_server_node);
      }

      # Check if this node was excluded; must still be in the lists
      if(@install_nodes_included && (grep {$_ eq $n} @install_nodes_included) eq 0) {
        $app_server_node->install(false);
      }
      
      my $nl = nodelist->new;
      $nl->name($n);
      # Get the name of the product list, if it exists
      $nl->prodlist(lc("$as"));
      if(! -e "$temp_path/prodlist/".$nl->prodlist.".prodlist") {
        $nl->prodlist($nl->prodlist."_".lc($n));
        if(! -e "$temp_path/prodlist/".$nl->prodlist.".prodlist") {
          if(-e "$temp_path/prodlist/autobuild.prodlist") {
            $nl->prodlist("autobuild");
          }
          else {
            $nl->prodlist("");
          }
        }
      }
    
      $app_server->nodelist($i++,$nl);
      
      if($i eq 1) {
        # A-server node
        $app_server_node->aserver(true);
      }
    }
    push(@app_servers,$app_server);
  }
  
  # Go through all servers to find the masters
  foreach my $as (@app_servers) {
    foreach my $asi (@app_servers) {
      if($asi->master eq $as->name) {
        $as->ismaster(true);
        last;
      }
    }
  }
  
  # Go through all servers to find their master's type
  foreach my $as (@app_servers) {
    # Get server master type
    my $retval = find_name($as->master,@app_servers);
    if($retval ne '') { $as->mastertype($retval->type); }
  }

  # Resort servers so that the configuration master is the first one
  my $found_cmaster=false;
  foreach my $as (@app_servers) {
    foreach my $asi (@app_servers) {
      foreach my $nl (@{$asi->nodelist}) {
        if($nl->name eq $remote_host) {
          my $retval = find_name($nl->name,@install_app_server_nodes);
          if($retval ne '' && $retval->aserver) { 
            # Found configuration master; put it first in list
            push(@install_app_servers,$asi);
            $found_cmaster=true;
            last;
          }
        }
      }
      if($found_cmaster) {last;}
    }
    if($found_cmaster) {last;}
  }
  # Push in the rest of the servers
  if(scalar @install_app_servers > 0) {
    foreach my $as (@app_servers) {
      if($as->name ne $install_app_servers[0]->name) {
        push(@install_app_servers,$as);
      }
    }
  }
  
  # Go through all server nodes
  if(!$opt_silent) {
    printex("Found nodes:\n");
    foreach my $as (@install_app_server_nodes) {
      printex("  ".$as->name." - ");
      if($as->install) {print "install ";}
      if($as->aserver) {print "a-server";}
      print "\n";
    }
    printex("\n");
  }
  return;
}

# Descr: Check the application servers configuration.
# Parameters: <configuration master host>
sub check_install_config {
  #if(auto_common::debug(@_)){return;}
  my ($remote_inst_config_master_host)=@_;
  # Check number of servers found
  scalar @install_app_servers > 0 or die "Installation configuration check failed. No application servers found.";
  # Check number of configuration master server nodes found
  scalar @{$install_app_servers[0]->nodelist} > 0 or die "Installation configuration check failed. No master nodes found (",scalar @{$install_app_servers[0]->nodelist},").";
  # Check first master server node name (configuration master)
  @{$install_app_servers[0]->nodelist}[0]->name eq $remote_inst_config_master_host or die "Installation configuration check failed. Wrong master node (",@{$install_app_servers[0]->nodelist}[0]->name,").";
  #print "Size: ",scalar @install_app_servers,"\n";
  my $i=0;
  foreach my $as (@install_app_servers) {
    $i++;
    printex("---- App server: ".$as->name);
    if($i eq 1) { print(" (Configuration master)"); }
    if($as->ismaster) { print(" (Master)"); }
    print("\n");
    printex("           Type: ".$as->type."\n");
    printex("     Type group: ".$as->typegroup."\n");
    printex("        Account: ".$as->account."\n");
    printex("         Master: ".$as->master."\n");
    printex("    Master type: ".$as->mastertype."\n");
    printex("       DB-index: ".$as->dbi."\n") unless($as->dbi eq "");
    printex("      SDB-index: ".$as->sbi."\n") unless($as->sbi eq "");
    foreach my $nl (@{$as->nodelist}) {
      printex("           Node: ".$nl->name."\n");
      printex("   Product list: ".$nl->prodlist."\n") unless($nl->prodlist eq "");
    }
  }
  return;
}

# Descr: Find a name in an array of structure objects.
# Parameters: <name> <array>
# Returns: The object or empty if not found,
sub find_name {
  #if(auto_common::debug(@_)){return;}
  my($name,@arr)=@_;
  my $retval='';
  foreach my $n (@arr) {
    if($n->name eq $name) {
      $retval = $n;
      last;
    }
  }
  return $retval;
}

# Descr: Find all application servers containing the given node name.
# Parameters: <name>
# Returns: An array of application servers; or empty if not found,
sub find_servers {
  #if(auto_common::debug(@_)){return;}
  my($name)=@_;
  my @ret=();
  foreach my $as (@install_app_servers) {
    foreach my $nl (@{$as->nodelist}) {
      if($nl->name eq $name) { push(@ret,$as); }
    }
  }
  return @ret;
}

# Descr: Get the nodes, included for installation, of a server.
# Parameters: <server types to return, SERVERS_ALL=all,SERVERS_A=a-servers,SERVERS_NON_A=non a-servers>
# Returns: A list of nodes
sub get_nodes_included {
  #if(auto_common::debug(@_)){return;}
  my ($server_type)=@_;
  my @ret=();
  foreach my $as (@install_app_server_nodes) {
    if($as->install && 
        ($server_type eq SERVERS_ALL || 
        ($server_type eq SERVERS_A && $as->aserver) || 
        ($server_type eq SERVERS_NON_A && !$as->aserver))) {
      push(@ret,$as->name);
    }
  }
  return @ret;
}

# Descr: Get the inner, and included for installation, nodes of a server.
# Parameters: <server> <server types to return, SERVERS_ALL=all,SERVERS_A=a-servers,SERVERS_NON_A=non a-servers>
# Returns: A list of nodes
sub get_inner_nodes_included {
  #if(auto_common::debug(@_)){return;}
  my ($node,$server_type)=@_;
  my @ret=();
  foreach my $nl (@{$node->nodelist}) {
    my $retval = find_name($nl->name,@install_app_server_nodes);
    if($retval ne '' && $retval->install && 
        ($server_type eq SERVERS_ALL || 
        ($server_type eq SERVERS_A && $retval->aserver) || 
        ($server_type eq SERVERS_NON_A && !$retval->aserver))) {
      push(@ret,$nl->name);
    }
  }
  return @ret;
}

# Descr: Get the inner, and included for installation, node lists of a server.
# Parameters: <server> <server types to return, SERVERS_ALL=all,SERVERS_A=a-servers,SERVERS_NON_A=non a-servers>
# Returns: A list of nodes lists
sub get_inner_nodelists_included {
  #if(auto_common::debug(@_)){return;}
  my ($node,$server_type)=@_;
  my @ret=();
  foreach my $nl (@{$node->nodelist}) {
    my $retval = find_name($nl->name,@install_app_server_nodes);
    if($retval ne '' && $retval->install && 
        ($server_type eq SERVERS_ALL || 
        ($server_type eq SERVERS_A && $retval->aserver) || 
        ($server_type eq SERVERS_NON_A && !$retval->aserver))) {
      push(@ret,$nl);
    }
  }
  return @ret;
}

# Descr: Install standby server from master.
# Parameters: <ssh command> <host name> <oracle user password>
sub install_standby_servers {
  #if(auto_common::debug(@_)){return;}
  my ($ssh_cmd,$remote_host,$nodelist,$remote_inst_oracle_pwd)=@_;
  printex("Install standby servers \"$nodelist\" from master install host $remote_host ...\n");
  remote_cmd(true, $ssh_cmd, $remote_host, "su - oracle -c '/clu_fs/his/oracle/admin/his/cre_guard.sh 1 1 $remote_inst_oracle_pwd \\\"$nodelist\\\"'");
  printex("Check installation of standby servers \"$nodelist\" from master install host $remote_host ...\n");
  remote_cmd(true, $ssh_cmd, $remote_host, "su - oracle -c '/clu_fs/his/oracle/admin/his/cre_guard.sh 6'");
  return;
}

# Descr: Unpack hubfiles on an installation host.
# Parameters: <ssh command> <host name> <path to hub> <file to unpack> <convert files to Unix-format> <remove after unpacking>
sub unpack_on_host {
  #if(auto_common::debug(@_)){return;}
  my ($ssh_cmd,$remote_host,$remote_path,$pack_file_name,$conv_to_unix,$remove)=@_;
  my $param = "";
  if($remove) {
    $param = $param."rm -f ~/$pack_file_name";
  }
  printex("Unpacking hub files, $pack_file_name, on install host $remote_host ...\n");
  remote_cmd(true, $ssh_cmd, $remote_host, "\"mkdir -p $remote_path;cd $remote_path;tar zxf ~/$pack_file_name;[[ `ls -1|wc -l` != 0 ]] && chmod -R +r *;$param\"");
  if(defined($conv_to_unix) && $conv_to_unix) {
    printex("Make sure files are in Unix-format ...\n");
    # Note: Will convert one directory-level only.
    remote_cmd(true, $ssh_cmd, $remote_host, "\"dos2unix -q -k $remote_path/*\"");
  }
  return;
}

# Descr: Transfer hub-files to an installation host.
# Parameters: <ssh command> <scp command> <host name> <transfer files to install host hub> <unpack files on install host hub> <runcons package file name> <runcons name> <offsetfiles directory name> <pictures directory name> <remote hub path> <offsetfiles package file name> <pictures package file name>
sub transfer_hub_files_to_host {
  #if(auto_common::debug(@_)){return;}
  my ($ssh_cmd,$scp_cmd,$remote_dst_host,$transfer_hub,$unpack_hub,$pack_file_runcons,$runcons_name,$offsetfiles_name,$pictures_name,$remote_hub_dst_path,$pack_file_offset,$pack_file_pictures)=@_;
  my @args=();
  if($transfer_hub) {
    # Transfer files to install host
    printex("Transfer hub files to install host $remote_dst_host ...\n");
    remote_cmd(true, $ssh_cmd, $remote_dst_host, "\"rm -rf $remote_hub_dst_path;mkdir -p $remote_hub_dst_path\"");
    print "<#stay>1<#>\n";
    remote_cp(true, $scp_cmd, "\"" . $auto_settings::settings_glob->{hubfiles_path} . "/$pack_file_runcons\"", "$remote_dst_host:.");
    print "<#stay>0<#>\n";
    print "<#stay>1<#>\n";
    remote_cp(true, $scp_cmd, "\"" . $auto_settings::settings_glob->{hubfiles_path} . "/$pack_file_offset\"", "$remote_dst_host:.");
    print "<#stay>0<#>\n";
    print "<#stay>1<#>\n";
    remote_cp(true, $scp_cmd, "\"" . $auto_settings::settings_glob->{hubfiles_path} . "/$pack_file_pictures\"", "$remote_dst_host:.");
    print "<#stay>0<#>\n";
  }
  if($unpack_hub) {
    unpack_on_host($ssh_cmd,$remote_dst_host,"$remote_hub_dst_path/$runcons_name",$pack_file_runcons,false,$transfer_hub);
    unpack_on_host($ssh_cmd,$remote_dst_host,"$remote_hub_dst_path/$offsetfiles_name",$pack_file_offset,true,$transfer_hub);
    unpack_on_host($ssh_cmd,$remote_dst_host,"$remote_hub_dst_path/$pictures_name",$pack_file_pictures,false,$transfer_hub);
  }
  return;
}

# Descr: Analyze log-files from installation machine.
# Parameters: <host name> <node counter>
sub analyze_logfiles_inst {
  #if(auto_common::debug(@_)){return;}
  my ($remote_src_host,$cnt)=@_;
  my $top_dst_dir = $auto_settings::settings_glob->{logfiles_path}."/$remote_src_host";
  $cnt = sprintf("%02d", $cnt);
  printex("Analyze log-files in $top_dst_dir ...\n");
  auto_common::analyze_latest("$top_dst_dir", $auto_settings::settings_glob->{diff_path}."/n".$cnt."_spiconf.orig", "spiconf", $auto_settings::settings_glob->{conf_path}, "spiconf", "", $auto_settings::settings_glob->{diff}, "");
  return;
}

# Descr: Analyze log-files from installation machine.
# Parameters: <host name> <node counter>
sub analyze_logfiles_inst_sub {
  #if(auto_common::debug(@_)){return;}
  my ($remote_src_host,$dst_dir,$type,$cnt)=@_;
  my $top_dst_dir = $auto_settings::settings_glob->{logfiles_path}."/$remote_src_host";
  $type = lc($type);
  $cnt = sprintf("%02d", $cnt);
  printex("Analyze log-files in $top_dst_dir/$dst_dir ...\n");
  auto_common::analyze_latest("$top_dst_dir/$dst_dir", $auto_settings::settings_glob->{diff_path}."/n".$cnt.$type."_create_db.orig", "create_db", $auto_settings::settings_glob->{conf_path}, "create_db", "", $auto_settings::settings_glob->{diff}, "");
  auto_common::analyze_latest("$top_dst_dir/$dst_dir", $auto_settings::settings_glob->{diff_path}."/n".$cnt.$type."_control_pop_db_de.orig", "control_pop_db_de", $auto_settings::settings_glob->{conf_path}, "control_pop_db_de", "", $auto_settings::settings_glob->{diff}, "");
  auto_common::analyze_latest("$top_dst_dir/$dst_dir", $auto_settings::settings_glob->{diff_path}."/n".$cnt.$type."_linkref_rdb.orig", "linkref_rdb", $auto_settings::settings_glob->{conf_path}, "linkref_rdb", "", $auto_settings::settings_glob->{diff}, "");
  auto_common::analyze_latest("$top_dst_dir/$dst_dir", $auto_settings::settings_glob->{diff_path}."/n".$cnt.$type."_linkref_sb1.orig", "linkref_sb1", $auto_settings::settings_glob->{conf_path}, "linkref_sb1", "", $auto_settings::settings_glob->{diff}, "");
  auto_common::analyze_latest("$top_dst_dir/$dst_dir", $auto_settings::settings_glob->{diff_path}."/n".$cnt.$type."_pdlinfo.orig", "pdlinfo", $auto_settings::settings_glob->{conf_path}, "pdlinfo", "", $auto_settings::settings_glob->{diff}, "");
  auto_common::analyze_latest("$top_dst_dir/$dst_dir", $auto_settings::settings_glob->{diff_path}."/n".$cnt.$type."_post.out.orig", "post.out", $auto_settings::settings_glob->{conf_path}, "post_out", "", $auto_settings::settings_glob->{diff}, "");
  auto_common::analyze_latest("$top_dst_dir/$dst_dir", $auto_settings::settings_glob->{diff_path}."/n".$cnt.$type."_runlinkpaf.err.orig", "runlinkpaf.err", $auto_settings::settings_glob->{conf_path}, "runlinkpaf_err", "", $auto_settings::settings_glob->{diff}, "");
  auto_common::analyze_latest("$top_dst_dir/$dst_dir", $auto_settings::settings_glob->{diff_path}."/n".$cnt.$type."_runlinkpaf.out.orig", "runlinkpaf.out", $auto_settings::settings_glob->{conf_path}, "runlinkpaf_out", "", $auto_settings::settings_glob->{diff}, "");
  return;
}
1;
