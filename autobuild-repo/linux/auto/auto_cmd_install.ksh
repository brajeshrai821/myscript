#!/bin/ksh
# File:       auto_cmd_install.ksh
# Descr:      Common autobuild installation commands.
#             Run this script as root.
# Parameters: Check out die_msg().
# Returns:    0 if ok; otherwise error.
# History:    2009-04-12 Anders Risberg       Initial version
#             2010-06-05 Anders Risberg       Release 1.2.19.
#             2010-12-13 Anders Risberg       Enhanced die_msg; added line number; partly moved to auto_common.ksh.
#                                             Removed start of Oracle in udw_db_create().
#             2011-03-07 Anders Risberg       Checking for database files by using database index sent as parameter.
#                                             Remove old database files before Avanti database create by using database index sent as parameter.
#             2011-04-29 Anders Risberg       Added data consistency check switch.
#             2011-10-24 Anders Risberg       Changed exit codes on check_oracle.
#             2011-11-16 Anders Risberg       Split populate and approve into two functions.
#             2011-12-01 Anders Risberg       Changed method for sopmode.
#
#_DEBUG="on"
prfx="#[$(basename $(readlink -nf $0))]>";

####### Helper functions #######
. /usr/local/autobuild/auto/auto_common.ksh

# Descr: Show help message and die.
# Parameters: [-h] [-e <err_code>] [-l <line no>] [<text>]
# Returns: Error code.
die_msg() {
  die_msg_ex $@
  if [[ $help = true ]]; then
    echo
    echo "Synopsis: $(basename $(readlink -nf $0)) option"
    echo "Options:"
    echo " -c path                Configuration file (overridden by subsequent parameters)."
    echo " --show_config          Show config-file parameters."
    echo " --update_server        Run update_server."
    echo " --update_server_remove Run remove when updating server."
    echo " --stop_on_missing_db   Stop if database files are missing during check."
    echo " --stop_on_missing_de   Stop if copying DE-files fails."
    echo " --run_copy_de_data     Run copy_de_data."
    echo " --udw_db_create        Run udw_db_create."
    echo " --udw_db_struct_pop    Run udw_db_struct_pop."
    echo " --avanti_db_create     Run create_new_databases (auto_netman_db_create)."
    echo " --avanti_db_pop        Run populate (auto_netman_db_create)."
    echo " --avanti_db_app        Run approve (auto_netman_db_create)."
    echo " --set_server_stop      Stop Netman."
    echo " --set_server_bat       Run Netman in batch-mode."
    echo " --set_server_cold      Run Netman in run/cold-mode."
    echo " --set_server_pass      Run Netman in run/passive-mode."
    echo " --check_installed_files Check installed files."
    echo " --turnoff_encryption   Turn off encryption."
    echo " --turnon_encryption    Turn on encryption."
    echo " --udw_abort            Shutdown Oracle."
    echo " --check_popdata        Check populated data consistency with Avanti database."
    echo " -dcn <number>          Data consistency check number."
    echo " -dcd <date>            Data consistency check date (dd-Mon-yy hh:mm:ss, american style)."
    echo " -k|--kits path         Kit-directory path."
    echo " -s name                Application server name."
    echo " -t type                Server type."
    echo " -tg type group         Server type group."
    echo " -n node                Node name."
    echo " -p name                Productlist line e.g. default."
    echo " -dbi name              Database index."
    echo " -sbi name              Studio database index."
    echo " -d directory           DE-directory."
    echo " -i directory           DE-pictures directory."
    echo " -l directory           DE-logfiles directory."
    echo " --spwd password        SCADA password."
    echo " --upwd password        UDW password."
  fi
  exit $err_code
}

# Descr: Parse command line into arguments.
# Parameters: <parameter-list>
parse_commandline() {
  [[ $# -lt 1 ]] && die_msg -l $LINENO "Option or parameter missing."

  config_file=""
  show_config=false
  run_update_server=false
  stop_on_missing_db=false
  stop_on_missing_de=false
  run_update_server_remove=false
  run_copy_de_data=false
  run_udw_db_create=false
  run_udw_db_struct_pop=false
  run_avanti_db_create=false
  run_avanti_db_pop=false
  run_turnoff_encryption=false
  run_turnon_encryption=false
  run_set_boot_option=false
  boot_option=""
  run_set_server_mode_stop=false
  run_set_server_mode_bat=false
  run_set_server_mode_cold=false
  run_set_server_mode_pass=false
  run_check_installed_files=false
  run_udw_abort=false
  run_check_popdata=false
  runcons_path=""
  appl_server_name=""
  server_type=""
  server_type_group=""
  product_list=""
  dbi=""
  sbi=""
  de_data_dir=""
  de_pict_dir=""
  de_log_dir=""
  pwd_scada=""
  pwd_udw=""
  dc_num=""
  dc_date=""
  
  while true;do
    case $# in 0) break;; esac
    case $1 in
      -c) shift; # Read common settings from configuration file
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && config_file=$1
        [[ -f $config_file ]] && rconf $config_file "main"
        [[ -f $config_file ]] && rconf $config_file "common"
        [[ -f $config_file ]] && rconf $config_file "install_common"
        shift;;
      --show_config) shift; # Show config-file parameters
        show_config=true;;
      --update_server) shift; # Run update_server
        run_update_server=true;;
      --update_server_remove) shift; # Run remove when updating server
        run_update_server_remove=true;;
      --stop_on_missing_db) shift; # Stop if database files are missing during check
        stop_on_missing_db=true;;
      --stop_on_missing_de) shift; # Stop if copying DE-files fails
        stop_on_missing_de=true;;
      --run_copy_de_data) shift; # Run copy_de_data
        run_copy_de_data=true;;
      --udw_db_create) shift; # Run udw_db_create
        run_udw_db_create=true;;
      --udw_db_struct_pop) shift; # Run udw_db_struct_pop
        run_udw_db_struct_pop=true;;
      --avanti_db_create) shift; # Run create_new_databases (auto_netman_db_create)
        run_avanti_db_create=true;;
      --avanti_db_pop) shift; # Run populate (auto_netman_db_create)
        run_avanti_db_pop=true;;
      --avanti_db_app) shift; # Run approve (auto_netman_db_create)
        run_avanti_db_app=true;;
      --turnoff_encryption) shift; # Turn off encryption."
        run_turnoff_encryption=true;;
      --turnon_encryption) shift; # Turn on encryption."
        run_turnon_encryption=true;;
      --set_boot_option) shift; # Set boot option."
        run_set_boot_option=true
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && boot_option=$1 && shift;;
      --set_server_stop) shift; # Stop Netman
        run_set_server_mode_stop=true;;
      --set_server_bat) shift; # Run Netman in batch-mode
        run_set_server_mode_bat=true;;
      --set_server_cold) shift; # Run Netman in run/cold-mode
        run_set_server_mode_cold=true;;
      --set_server_pass) shift; # Run Netman in run/passive-mode
        run_set_server_mode_pass=true;;
      --check_installed_files) shift; # Check installed files
        run_check_installed_files=true;;
      --udw_abort) shift; # Shutdown Oracle
        run_udw_abort=true;;
      --check_popdata) shift; # Check populated data consistency with Avanti database
        run_check_popdata=true;;
      -dcn) shift; # Data consistency check number
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && dc_num=$1 && shift;;
      -dcd) shift; # Data consistency check date (dd-Mon-yy hh:mm:ss)
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && dc_date="$1 $2" && shift;shift;;
      -k|--kits) shift; # Kit-directory path
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && runcons_path=$1 && shift;;
      -s) shift; # Name of application server to be installed
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && appl_server_name=$1 && shift;;
      -t) shift; # Server type
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && server_type=$1 && shift;;
      -tg) shift; # Server type group
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && server_type_group=$1 && shift;;
      -n) shift; # Node name
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && node_name=$1 && shift;;
      -p) shift; # Productlist line e.g. default
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && product_list=$1 && shift;;
      -dbi) shift; # Database index
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && dbi=$1 && shift;;
      -sbi) shift; # Studio database index
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && sbi=$1 && shift;;
      -d) shift; # DE-directory
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && de_data_dir=$1 && shift;;
      -i) shift; # DE-pictures directory
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && de_pict_dir=$1 && shift;;
      -l) shift; # DE-logfiles directory
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && de_log_dir=$1 && shift;;
      --spwd) shift; # SCADA password
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && pwd_scada=$1 && shift;;
      --upwd) shift; # UDW password
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && pwd_udw=$1 && shift;;
      -|--) shift; break;;
      -h|--help) die_msg -h -e 0;;
      -*) die_msg -e 2 -l $LINENO "Invalid option $1.\nTry $0 --help to see available options.";;
      *) die_msg -e 2 -l $LINENO "Invalid option $1.\nTry $0 --help to see available options.";;
    esac
  done
}

####### Script specific functions #######

# Descr: Update an application server in this node.
# Parameters: 
update_server() {
  this_node=`hostname`
  printex "Update application server $appl_server_name on node $this_node ..."
  
  # Handle this server if in this node and if the user home exists
  if [[ -n "$in_nodes" ]];then
    if [[ -d $uhome && -f $uhome/.profile ]];then
      # Stop netman if running (renewing ticket, if needed)
      printex "Stopping Netman for user $uid on $appl_server_name ..."
      nmcmd $appl_server_name sopmode;sts=$?
      printex "      Netman server status: $sts"
      [[ $sts -ne 254 ]] && su - $uid -c "cd; . .profile;netman_stop;spiclean" || echo "$prfx   Already stopped."
    else
      printex "    Attempting to stop netman but user $uid on $appl_server_name does not yet exist."
    fi

    # Renew ticket
    if [[ $renew_tickets = true ]];then
      echo "$prfx   Renew ticket for user netman ..."
      echo $pwd_scada | /usr/kerberos/bin/kinit netman
    fi
  
    # Needed by ProdInstCmd from ver 4.2
    #export DISPLAY=:0.0

    if [[ $run_update_server_remove = true ]];then
      # Remove old application server (must be run before installing new server, regardless)
      printex "    Remove old application server $appl_server_name ..."
      #rm -rf ${uhome} # Done in auto_init_setup (--remove_install)
      # This must be done even if we run rm, otherwise install will fail ...
      cmd="/usr/bin/java -DCONFDB=$CONFDB ProdInstCmd -s $appl_server_name remove"
      printex "      $cmd"
      $cmd;sts=$?
      [[ $sts -ne 0 ]] && die_msg -l $LINENO "Application removal failed."
    fi

    # Install new application server
    printex "    Install updated application server $appl_server_name ..."
    if [[ $use_install_pwd = true ]];then
      cmd="/usr/bin/java -DCONFDB=$CONFDB ProdInstCmd -d $runcons_path -f $product_list -s $appl_server_name -p $pwd_scada install"
    else
      cmd="/usr/bin/java -DCONFDB=$CONFDB ProdInstCmd -d $runcons_path -f $product_list -s $appl_server_name install"
    fi  
    printex "      $cmd"
    $cmd;sts=$?
    [[ $sts -ne 0 ]] && die_msg -l $LINENO "Application installation failed."
  else
    die_msg -l $LINENO "This application server is not part of node $this_node."
  fi

  printex "Done updating application server $appl_server_name on node $this_node."

  # Make changes to the kernel (added to /etc/sysctl.conf)
  #update_kernel_settings
}

# Descr: Copy DE-data and pictures to the application server.
# Parameters: 
copy_de_data() {
  printex "Copy DE-data and pictures to $appl_server_name ($uid) ..."

  su - $uid <<EOD
  cd
  . ~/.profile
  echo "$prfx   SPI_ROOT is \$SPI_ROOT" # Should be <uhome>/spi0
  [[ ! -d \$SPI_ROOT ]] && exit 1

  # Copy DE-data for populate
  echo "$prfx   Copy DE-data from $de_data_dir to \$SPI_ROOT/spipdl"
  mkdir -p \$SPI_ROOT/spipdl
  rm -f \$SPI_ROOT/spipdl/*
  cp $de_data_dir/* \$SPI_ROOT/spipdl

  # Copy DE-pictures
  echo "$prfx   Copy picture files from $de_pict_dir to \$SPI_ROOT/spipictemp"
  if [[ -n "$de_pict_dir" && -d $de_pict_dir ]];then
    cp $de_pict_dir/*.PPI \$SPI_ROOT/spipictemp
    cp $de_pict_dir/*.REF \$SPI_ROOT/spipictemp
  fi
EOD

  ret=$?
  if [[ $ret -ne 0 ]];then
    err="Failed copying DE-data and pictures."
    #mail_report $err
    [[ $stop_on_missing_de = true ]] && die_msg -e $ret -l $LINENO $err || printex "$err"
  fi
  printex "Done copying DE-data and pictures."
}

# Descr: Create an UDW Oracle database.
# Parameters: 
udw_db_create() {
  printex "Create UDW Oracle database ..."
  log_file="/back_fs/udwbackup/exp_source/his_cre.log"
  
  # ToDo: Check this!
  inithis="/back_fs/udwbackup/exp_source/inithis.ora"
  inithis2="/clu_fs/his/oracle/admin/his/pfile/inithis.ora"
  if [[ $env_64bit = false && -f $inithis ]];then
    printex "  Disabling optimizer_features_enable in $inithis"
    sed -i "s/optimizer_features_enable/\#optimizer_features_enable/g" $inithis
    sed -i "s/optimizer_features_enable/\#optimizer_features_enable/g" $inithis2
  fi
  #start_oracle
  printex "  Run his_cre.sh. Check $log_file for status ..."
  su - oracle <<EOF
    cd /back_fs/udwbackup/exp_source
    ./his_cre.sh single his > $log_file 2>\&1;sts_his=\$?
    # Check for Oracle error codes "ORA-*"
    grep -q ORA- $log_file;sts_grep=\$?
    [[ \$sts_grep -eq 0 || (-z \$sts_his && \$sts_his -gt 0) ]] && (echo " Error: sts_grep:\$sts_grep, sts_his:\$sts_his."; exit 1)
    exit 0
EOF

  ret=$?
  if [[ $ret -ne 0 ]];then
    err="Failed running his_cre.sh."
    #mail_report $err
    die_msg -e $ret -l $LINENO -f $log_file $err
  else
    printex "Done running his_cre.sh with success."
  fi
  printex "Done creating UDW Oracle database."
}

# Descr: Do structural UDW population (Oracle database); requires an open DE database.
# Parameters: 
udw_db_struct_pop() {
  printex "Start structural UDW population (Oracle database) ..."

  start_oracle
  
  printex "  Start the structural population ..."
  su - oracle <<EOF
    sqlplus -s /nolog <<SQLPLUS_EOF
      whenever sqlerror exit sql.sqlcode;
      connect his/his
      execute de.populate;
      execute de.approve_population;
SQLPLUS_EOF
    exit \$?
EOF

  ret=$?
  if [[ $ret -ne 0 ]];then
    err="Failed running structural population."
    #mail_report $err
    die_msg -e $ret -l $LINENO $err
  else
    printex "Ready with structural population"
  fi
  printex "Done structural population."
}

# Descr: Create an Avanti database.
# Parameters: 
avanti_db_create() {
  [[ -z "$dbi" ]] && die_msg -l $LINENO "No database index given."
  [[ -z $script_path_install ]] && die_msg -h -l $LINENO "No script path given."
  printex "Run Avanti database create on server $appl_server_name ($uid) ..."
  
  su - $uid <<EOD
  cd
  . ~/.profile
  echo "$prfx   SPI_ROOT is \$SPI_ROOT" # Should be <uhome>/spi0
  [[ ! -d \$SPI_ROOT ]] && exit 1

  # Renew ticket
  if [[ $renew_tickets = true ]];then
    echo "$prfx   Renew ticket for user $uid ..."
    echo $pwd_scada | /usr/kerberos/bin/kinit -l 7d $uid@$KerberosDomain # Needed for populate
  fi

  # Remove old database files
  echo "$prfx   Remove old database files."
  cd \${SPI_ROOT}/spiexe
  rm -f adf.lock
  rm -f dbdir
  [[ -n "$dbi" ]] && (rm -f ${dbi}_?; rm -f ${dbi}_??;)
  [[ -n "$sbi" ]] && (rm -f ${sbi}_?; rm -f ${sbi}_??;)
  cd
  
  # Create an empty database
  echo "$prfx   Run Avanti database create (create an empty database)."
  params="-k $runcons_path -s $appl_server_name -t $server_type -tg $server_type_group --spwd $pwd_scada --upwd $pwd_udw --avanti_db_create"
  [[ $renew_tickets = true ]] && params="\$params --renew_tickets"
  ksh $script_path_install/auto/auto_netman_db_create.ksh \$params;err=\$?
  echo "$prfx   Ended Avanti database create (\$err)"
  exit \$err
EOD

  ret=$?
  if [[ $ret -ne 0 ]];then
    err="Failed running auto_netman_db_create.ksh."
    #mail_report $err
    die_msg -e $ret -l $LINENO $err
  else
    printex "Done running auto_netman_db_create.ksh with success."
  fi
  printex "Done running Avanti database create."
}

# Descr: Populate an Avanti database.
# Parameters: 
avanti_db_pop() {
  [[ -z $script_path_install ]] && die_msg -h -l $LINENO "No script path given."
  printex "Run Avanti database population on server $appl_server_name ($uid) ..."

  su - $uid <<EOD
  cd
  . ~/.profile
  echo "$prfx   SPI_ROOT is \$SPI_ROOT" # Should be <uhome>/spi0
  [[ ! -d \$SPI_ROOT ]] && exit 1

  # Renew ticket
  if [[ $renew_tickets = true ]];then
    echo "$prfx   Renew ticket for user $uid ..."
    echo $pwd_scada | /usr/kerberos/bin/kinit -l 7d $uid@$KerberosDomain # Needed for populate
  fi
  
  # Populate the Avanti database with DE-data
  echo "$prfx   Run Avanti database populate (populate with DE-data)."
  params="-k $runcons_path -s $appl_server_name -t $server_type -tg $server_type_group --spwd $pwd_scada --upwd $pwd_udw --avanti_db_pop"
  [[ $renew_tickets = true ]] && params="\$params --renew_tickets"
  ksh $script_path_install/auto/auto_netman_db_create.ksh \$params;err=\$?
  echo "$prfx   Ended Avanti database populate (\$err)"
  exit \$err
EOD

  ret=$?
  if [[ $ret -ne 0 ]];then
    err="Failed running auto_netman_db_create.ksh."
    #mail_report $err
    die_msg -e $ret -l $LINENO $err
  else
    printex "Done running auto_netman_db_create.ksh with success."
  fi
  printex "Done running Avanti database population."
}

# Descr: Approve an Avanti database.
# Parameters: 
avanti_db_app() {
  [[ -z $script_path_install ]] && die_msg -h -l $LINENO "No script path given."
  printex "Run Avanti database approve on server $appl_server_name ($uid) ..."

  su - $uid <<EOD
  cd
  . ~/.profile
  echo "$prfx   SPI_ROOT is \$SPI_ROOT" # Should be <uhome>/spi0
  [[ ! -d \$SPI_ROOT ]] && exit 1

  # Renew ticket
  if [[ $renew_tickets = true ]];then
    echo "$prfx   Renew ticket for user $uid ..."
    echo $pwd_scada | /usr/kerberos/bin/kinit -l 7d $uid@$KerberosDomain # Needed for approve
  fi
  
  # Approve the Avanti database with DE-data
  echo "$prfx   Run Avanti database approve (populated with DE-data)."
  params="-k $runcons_path -s $appl_server_name -t $server_type -tg $server_type_group --spwd $pwd_scada --upwd $pwd_udw --avanti_db_app"
  [[ $renew_tickets = true ]] && params="\$params --renew_tickets"
  ksh $script_path_install/auto/auto_netman_db_create.ksh \$params;err=\$?
  echo "$prfx   Ended Avanti database approve (\$err)"
  exit \$err
EOD

  ret=$?
  if [[ $ret -ne 0 ]];then
    err="Failed running auto_netman_db_create.ksh."
    #mail_report $err
    die_msg -e $ret -l $LINENO $err
  else
    printex "Done running auto_netman_db_create.ksh with success."
  fi
  printex "Done running Avanti database approve."
}

# Descr: Check populated data consistency with Avanti database.
# Parameters: 
check_popdata() {
  printex "Check Avanti database population on server $appl_server_name ($uid) ..."

  su - $uid <<EOD
  cd
  . ~/.profile
  . /usr/local/autobuild/auto/auto_common.ksh
  echo "$prfx   SPI_ROOT is \$SPI_ROOT" # Should be <uhome>/spi0
  [[ ! -d \$SPI_ROOT ]] && exit 1

  # Renew ticket
  if [[ $renew_tickets = true ]];then
    echo "$prfx   Renew ticket for user $uid ..."
    echo $pwd_scada | /usr/kerberos/bin/kinit -l 7d $uid@$KerberosDomain # Needed for populate
  fi
  
  # Check populated data consistency with Avanti database
  echo "$prfx   Check populated data consistency with Avanti database."
  check_dataconsistency $dc_num "$dc_date";err=\$?
  echo "$prfx   Ended checking populated data consistency with Avanti database (\$err)"
  exit \$err
EOD

  ret=$?
  if [[ $ret -ne 0 ]];then
    err="Failed running check_dataconsistency."
    #mail_report $err
    die_msg -e $ret -l $LINENO $err
  else
    printex "Done running check_dataconsistency with success."
  fi
  printex "Done checking populated data consistency with Avanti database."
}

# Descr: Set encryption mode on server.
# Parameters: <mode>
set_encryption_mode() {
  printex "Set encryption mode on server $appl_server_name to \"$1\" ..."

  # Get application servers such as NM_SCADA, NM_UDW, etc. (remove trailing /)
  appl_servers=`$CONFM -f $CONFDB get appl_server/|sed -e "s!/!!"`
  for _as in $appl_servers;do
    orig_enc_mode=`$CONFM get appl_server/$_as/authentication/mode`
    $CONFM set appl_server/$_as/authentication/mode "$1"
    orig_enc_mode=`$CONFM get appl_server/$_as/authentication/mode`
  done
}

# Descr: Set the boot option on an application server.
# Parameters: [stop]
set_boot_option() {
  printex "Set boot option on server $appl_server_name to \"$1\" ..."
  if [[ $1 = "stop" ]];then
    rm -f /usr/users/$uid/spi0/spiexe/startmode.dat
  fi
}

# Descr: Set the operation mode on an application server.
# Parameters: 
set_server_mode() {
  [[ -z $script_path_install ]] && die_msg -h -l $LINENO "No script path given."
  printex "Set operation mode on server $appl_server_name ($uid) ..."
  if [[ ! -d /usr/users/$uid ]];then
    printex "  Directory /usr/users/$uid is missing; apparently also Netman is missing."
    return
  fi
  
  su - $uid <<EOD
  cd
  [[ -f ~/.profile ]] && . ~/.profile
  # Exit with success if account is empty
  if [[ ! -d ~/spicommon ]];then
    echo "$prfx   Directory spicommon is missing; apparently also Netman is missing."
    exit 0
  fi
  echo "$prfx   SPI_ROOT is \$SPI_ROOT" # Should be <uhome>/spi0
  [[ ! -d \$SPI_ROOT ]] && exit 1

  # Renew ticket
  if [[ $renew_tickets = true ]];then
    echo "$prfx   Renew ticket for user $uid ..."
    echo $pwd_scada | /usr/kerberos/bin/kinit -l 7d $uid@$KerberosDomain # Needed for populate
  fi
  
  # Set operation mode on server
  params="-s $appl_server_name -t $server_type"
  [[ $run_set_server_mode_stop = true ]] && params="\$params --stop"
  [[ $run_set_server_mode_bat = true ]] && params="\$params --bat"
  [[ $run_set_server_mode_cold = true ]] && params="\$params --cold"
  [[ $run_set_server_mode_pass = true ]] && params="\$params --pass"
  ksh $script_path_install/auto/auto_netman_mode.ksh \$params;err=\$?
  exit \$err
EOD

  ret=$?
  if [[ $ret -ne 0 ]];then
    err="Failed running auto_netman_mode.ksh."
    #mail_report $err
    die_msg -e $ret -l $LINENO $err
  else
    printex "Done running auto_netman_mode.ksh with success."
  fi
  printex "Done setting operation mode on server."
}

# Descr: Check that a few relevant files exist after installation.
# Parameters:
check_installed_files() {
  [[ -z "$dbi" ]] && die_msg -l $LINENO "No database index given."
  if [[ -z "$sbi" ]];then
    str_files="dbdir + ${dbi}_*"
  else str_files="dbdir, ${dbi}_* + ${sbi}_*"
  fi
  printex "Check that a few relevant files ($str_files) exist after installation on server $appl_server_name ($uid) ..."
  
  su - $uid <<EOD
  cd
  . ~/.profile
  echo "$prfx   SPI_ROOT is \$SPI_ROOT" # Should be <uhome>/spi0
  [[ ! -d \$SPI_ROOT ]] && exit 1

  cd \${SPI_ROOT}/spiexe
  err=1
  [[ -f dbdir && -f ${dbi}_0 && -f ${dbi}_1 ]] && err=0
  [[ -n "$sbi" && -f ${sbi}_0 && -f ${sbi}_1 ]] && err=0
  cd
  exit \$err
EOD

  ret=$?
  if [[ $ret -ne 0 ]];then
    err="Failed checking relevant files after installation. None or too few of the database files were found."
    #mail_report $err
    if [[ $stop_on_missing_db = true ]];then
      die_msg -e $ret -l $LINENO $err
    else
      printex "$err"
    fi
  else
    printex "Done checking relevant files after installation."
  fi
}

# Descr: Shutdown Oracle.
# Parameters:
udw_abort() {
  printex "Shutdown Oracle"
  printex "  Looking for running Oracle ..."
  check_oracle;sts=$?
  if [[ $sts -eq 0 ]];then
    printex "    Found."
    su - oracle <<EOF
    udwabort
EOF
  else
    printex "    None found ($sts)."
  fi
  
  ret=$?
  if [[ $ret -ne 0 ]];then
    err="Failed running shutdown Oracle."
    die_msg -e $ret -l $LINENO $err
  else
    printex "Done running shutdown Oracle with success."
  fi
}

# Descr: Wait for the kits to build.
# Parameters: 
wait_for_kit_build() {
  typeset -i i max zz
  i=0

  # Wait max 60*5=300 minutes for kit build job to complete
  max=300
  zz=$max-$i
  while [[ -e $kit_bld_lock_file && $zz != 0 ]];do
    sleep 60
    printex "Slept 1 minute `date` for waiting kit_build to complete"
    i=i+1
    zz=$max-$i
  done
  [[ $i > 0 ]] && printex "Waited $i minutes for kit build to complete"
  [[ -e $kit_bld_lock_file ]] && die_msg -l $LINENO "Netman Install stopped. Lock file still exists."
}

####################################################################################################################
src_dir=`dirname $0`
echo "$prfx Started: "`date +%Y%m%d`"T"`date +%H%M%S`
echo "$prfx Command line: $0 $@"

# Change the exit code to something else
#trap 'sts=$?; echo "Normal exit ($sts)."; [[ $sts -eq 0 ]] && exit 0 || exit $sts' EXIT
#trap 'sts=$?; echo "Trapped error ($sts)."' ERR
#trap 'echo "Exit with HUP ($?) HUP"' HUP
#trap 'echo "Exit with INT ($?) INT"' INT
#trap 'echo "Exit with QUIT ($?) QUIT"' QUIT
#trap 'echo "Exit with TERM ($?) TERM"' TERM

# Parse command line into arguments
parse_commandline $@
# Check if config-file exists
[[ (-n "$config_file") && (! -r $config_file) ]] && die_msg -e 3 -l $LINENO "Config-file ${config_file} cannot be read."

# Setup paths to Java
CONFM=/usr/local/bin/confm
export CONFDB=/usr/local/config/db/confdb
export CLASSPATH=/usr/local/config/java/SpiConf.jar:/usr/local/config/java

# Initialize the kinit-command for ticket renewals
if [[ $renew_tickets = true ]];then
  DNSDomain=`$CONFM get networkServices/Inhouse/DNSDomain`
  KerberosDomain=`$CONFM get networkServices/Inhouse/KerberosDomain`
  [[ -f /etc/netman.keytab ]] && kinit_cmd="/usr/kerberos/bin/kinit -k -t /etc/netman.keytab" || die_msg -l $LINENO "  No /etc/netman.keytab found."
fi

# Check the confdb lock file
[[ -f /usr/local/config/db/\#confdb\# ]] && die_msg -l $LINENO "Confdb-file is locked. Close the application that uses confdb, or wait until it is unlocked, or remove /usr/local/config/db/#confdb#."

if [[ $run_update_server = true || $run_copy_de_data = true || $run_udw_db_create = true || $run_udw_db_struct_pop = true || $run_avanti_db_create = true || $run_avanti_db_pop = true || $run_avanti_db_app = true ]];then
  # Get the current path to the hub-files
  [[ -z "$autobuild_hub_path_install" ]] && die_msg -l $LINENO "No hub path given."
  de_data_dir="$autobuild_hub_path_install/$de_data_dir"
  de_pict_dir="$autobuild_hub_path_install/$de_pict_dir"
  de_log_dir="$autobuild_hub_path_install/$de_log_dir"
  [[ ! -d $de_data_dir ]] && die_msg -l $LINENO "No DE-data directory found."
  [[ ! -r $de_data_dir/duspdloff.ver ]] && die_msg -l $LINENO "No $de_data_dir/duspdloff.ver found."
  [[ ! -d $de_pict_dir ]] && die_msg -l $LINENO "No DE-picture directory found."
  #[[ ! -d $de_log_dir ]] && die_msg -l $LINENO "No DE-logfiles directory found."

  # Get the current path to the runcons-files
  get_runcons_inst_path
  [[ -z "$runcons_path" ]] && die_msg -l $LINENO "No runcons path given."
  [[ ! -d $runcons_path ]] && die_msg -l $LINENO "Runcons path is invalid."
  [[ -d $runcons_path ]] && kit_bld_lock_file=$runcons_path/kit_bld.lock
  #[[ ! -r $runcons_path/${product_list}.prodlist ]] && die_msg -l $LINENO "$runcons_path/${product_list}.prodlist cannot be found or is unreadable."

  # Find DE auto generation of offset files
  de_logfile_name=""
  [[ -e $de_log_dir/de_server_install_OK.log ]] && de_logfile_name="de_server_install_OK.log"
  [[ -e $de_log_dir/de_server_install_ERROR.log ]] && de_logfile_name="de_server_install_ERROR.log"
  #[[ -z "$de_logfile_name" ]] && die_msg -l $LINENO "No logfile from DE auto generation found."
fi

# Check the application server name
## ToDo: Check if needed now!
[[ -z "$appl_server_name" ]] && die_msg -l $LINENO "No application server name given."
get_server_info $appl_server_name true

[[ $uid = "" ]] && die_msg -l $LINENO "Incorrect parameters uid=$uid, appl_server_name=$appl_server_name."
[[ ! -d $uhome ]] && echo "$prfx Warning: User $uid on $appl_server_name does not seem to exist. Home directory $uhome is missing."

## ToDo: Move these ...
# Wait for kit build job to complete
#wait_for_kit_build
# Remove spiconf history
#rm -f /usr/local/config/spiconf.log

# Update server (this is where /back_fs is created)
[[ $run_update_server = true ]] && update_server

# Copy DE-data and pictures
[[ $run_copy_de_data = true ]] && copy_de_data

# Start to create UDW Oracle database. This assumes that the UDW kit is installed, i.e. hisspd netman is created.
[[ $run_udw_db_create = true ]] && udw_db_create

# Do structural UDW population (Oracle database).
[[ $run_udw_db_struct_pop = true ]] && udw_db_struct_pop

# Run Avanti database create
[[ $run_avanti_db_create = true ]] && avanti_db_create

# Run Avanti database population
[[ $run_avanti_db_pop = true ]] && avanti_db_pop

# Run Avanti database approve
[[ $run_avanti_db_app = true ]] && avanti_db_app

# Set encryption mode on server
[[ $run_turnoff_encryption = true ]] && set_encryption_mode ""
[[ $run_turnon_encryption = true ]] && set_encryption_mode "kerberos"

# Set boot option on server
[[ $run_set_boot_option = true ]] && set_boot_option $boot_option

# Change mode of operation
[[ $run_set_server_mode_stop = true ]] && set_server_mode stop
[[ $run_set_server_mode_bat = true ]] && set_server_mode bat true
[[ $run_set_server_mode_cold = true ]] && set_server_mode cold true
[[ $run_set_server_mode_pass = true ]] && set_server_mode pass true

# Check installed files
[[ $run_check_installed_files = true ]] && check_installed_files

# Shutdown Oracle
[[ $run_udw_abort = true ]] && udw_abort

# Check data consistency with Avanti database
[[ $run_check_popdata = true ]] && check_popdata
  
echo "$prfx Ended: "`date +%Y%m%d`"T"`date +%H%M%S`
exit 0