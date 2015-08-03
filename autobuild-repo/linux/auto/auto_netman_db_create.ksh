#!/bin/ksh
# File:       auto_netman_db_create.ksh
# Descr:      Creates and/or populates a database in the application server.
# Parameters: Check out die_msg().
# Returns:    0 if ok; otherwise error.
# Credits:    Some parts taken from NMTA/Bjorn Berglund.
# History:    2009-08-15 Anders Risberg       Initial version.
#             2010-06-05 Anders Risberg       Release 1.2.19.
#             2010-10-12 Anders Risberg       Moved server type DISTRIBUTED from SCADA to UDW.
#             2010-11-26 Anders Risberg       Added wait for population is done before 
#                                               starting approve.
#             2010-12-13 Anders Risberg       Enhanced die_msg; added line number; partly moved to auto_common.ksh.
#             2011-03-31 Anders Risberg       All server types are SCADA unless otherwise stated.
#             2011-11-16 Anders Risberg       Split populate and approve into two functions.
#             2012-03-01 Lars Axelsson        SPR-D11120075: check if confdb is locked via setuid program confislocked
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
    echo " --avanti_db_create     Run create_new_databases."
    echo " --avanti_db_pop        Run populate."
    echo " --avanti_db_app        Run approve."
    echo " -k|-kits path          Path to kit-directory."
    echo " -s name                Application server name."
    echo " -tg type group         Server type group."
    echo " -t type                Server type."
    echo " --spwd password        SCADA password."
    echo " --upwd password        UDW password."
    echo " --renew_tickets        Old system (until NM v4 and NM v5.0) Kerberos ticket handling."
  fi
  exit $err_code
}

# Descr: Parse command line into arguments.
# Parameters: <parameter-list>
parse_commandline() {
  [[ $# -lt 1 ]] && die_msg -l $LINENO "Option or parameter missing."

  run_avanti_db_create=false
  run_avanti_db_pop=false
  run_avanti_db_app=false
  runcons_path=""
  appl_server_name=""
  server_type_group=""
  server_type=""
  pwd_netman=""
  pwd_hisspd=""
  renew_tickets=false

  while true;do
    case $# in 0) break;; esac
    case $1 in
      --avanti_db_create) shift; # Run create_new_databases
        run_avanti_db_create=true;;
      --avanti_db_pop) shift; # Run populate
        run_avanti_db_pop=true;;
      --avanti_db_app) shift; # Run approve
        run_avanti_db_app=true;;
      -k|-kits) shift; # Kit-directory path
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && runcons_path=$1 && shift;;
      -s) shift; # Name of application server to be installed
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && appl_server_name=$1 && shift;;
      -tg) shift; # Server type group
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && server_type_group=$1 && shift;;
      -t) shift; # Server type
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && server_type=$1 && shift;;
      --spwd) shift; # SCADA password
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && pwd_netman=$1 && shift;;
      --upwd) shift; # UDW password
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && pwd_hisspd=$1 && shift;;
      --renew_tickets) shift; # Renew tickets, or not
        renew_tickets=true;;
      -|--) shift; break;;
      -h|--help) die_msg -h -e 0;;
      -*) die_msg -e 2 -l $LINENO "Invalid option $1.\nTry $0 --help to see available options.";;
      *) die_msg -e 2 -l $LINENO "Invalid option $1.\nTry $0 --help to see available options.";;
    esac
  done
}

####### Script specific functions #######

# Descr: Create a new Avanti-database.
# Parameters: 
create_new_database() {
  printex "Create new database on server $appl_server_name ($user_id) ..."
  printex "  Running as user `id`."
  this_node=`hostname`

  ## Stop Netman server if running
  printex "       Stop Netman server ($appl_server_name/$user_id) ..."
  sopmode=`get_sopmode`
  [[ $sopmode != "error" ]] && printex "         Netman server status: $sopmode"
  [[ $sopmode = "power up"* ]] && die_msg -l $LINENO "Server is powering up. Cannot create new database."
  set_server_mode $appl_server_name $server_type stop

  ## Create empty database
  cre_logfile="${SPI_ROOT}/spierr/create_db_${this_node}_${appl_server_name}_`date +%Y%m%d`_`date +%H%M%S`.log"
  #echo "Create_db errors --- User ${user_id} -- Node $this_node --------------------------">>$auto_cre_logfile
  printex "       Create empty database ($appl_server_name/$user_id) ..."
  ${SPI_ROOT}/spiupd/create_db > $cre_logfile 2>&1

  ## Close the database (started during create_db)
  printex "       Close the database started during create_db ($appl_server_name/$user_id) ..."
  set_server_mode $appl_server_name $server_type stop
}

# Descr: Populate an existing Avanti-database.
# Parameters: 
populate_database() {
  printex "Populate database on `hostname` ..."
  printex "  Running as user `id`."

  # Renew ticket
  if [[ $renew_tickets = true ]];then
    printex "  Renew ticket ..."
    echo $pwd_netman | /usr/kerberos/bin/kinit -l 7d netman@$KerberosDomain
  fi

  ## Check that Netman server is running in batch mode
  printex "  Check that Netman server is running in batch mode ($appl_server_name/$user_id) ..."
  sopmode=`get_sopmode`
  [[ $sopmode != "error" ]] && printex "         Netman server status: $sopmode"
  [[ $sopmode = "power up"* ]] && die_msg -l $LINENO "Server is powering up. Cannot populate database."
  [[ $sopmode != "batch" ]] && die_msg -l $LINENO "Server is not running in batch-mode. Cannot populate database."

  # Check if config db is locked (also done silently in control_pop_db_de)
  if [[ -e /usr/local/bin/confislocked ]];then
    printex "  Check if config db is locked ..."
    locked=`/usr/local/bin/confislocked -t 2>&1`
    sts=$?
    printex "    Returned: $locked"
    [[ $sts -ne 0 ]] && die_msg -l $LINENO "$CONFDB is locked or other error."
  fi

  # Populate
  logfile="$SPI_ROOT/spierr/control_pop_db_de_`date +%Y%m%d`_`date +%H%M%S`.log"
  cmd="$SPI_ROOT/spiupd/control_pop_db_de"
  printex "  Populating ($cmd). Check $logfile for status ..."
  $cmd >$logfile 2>&1;sts=$?
  [[ $sts -ne 0 ]] && die_msg -l $LINENO -f $logfile "    Population failed."
  printex "    Done populating ($sts)."

  # Wait for population to finish
  printex "  Wait for population to finish ..."
  sleep 20
  wait_for_population_done 30 10
  [[ $sts_ret = true ]] && die_msg -l $LINENO -f $logfile "         $sts_txt"
  printex "    Population finished."
  
  printex "Populate `hostname` done `date`"
}

# Descr: Approve an existing Avanti-database.
# Parameters: 
approve_database() {
  printex "Approve database on `hostname` ..."
  printex "  Running as user `id`."

  # Renew ticket
  if [[ $renew_tickets = true ]];then
    printex "  Renew ticket ..."
    echo $pwd_netman | /usr/kerberos/bin/kinit -l 7d netman@$KerberosDomain
  fi

  ## Check that Netman server is running in batch mode
  printex "  Check that Netman server is running in batch mode ($appl_server_name/$user_id) ..."
  sopmode=`get_sopmode`
  [[ $sopmode != "error" ]] && printex "         Netman server status: $sopmode"
  [[ $sopmode = "power up"* ]] && die_msg -l $LINENO "Server is powering up. Cannot approve database."
  [[ $sopmode != "batch" ]] && die_msg -l $LINENO "Server is not running in batch-mode. Cannot approve database."

  # Approve if population was ok
  printex "  Approve (if population was ok)."
  pop_ok=`grep POPOK $SPI_ROOT/spipdl/duspdloff.ver`
  [[ -n $pop_ok ]] && printex "    pop_ok: $pop_ok" || printex "    pop_ok: <empty>"
  [[ -n $pop_ok ]] && approval="APPROVAL" || approval="REJECTION"
  cmd=$SPI_ROOT/spiupd/batch_approval_de
  printex "  Approve with with $approval ($cmd) ..."
  echo $approval | $cmd;sts=$?
  printex "    Done approving. Status: $sts"

  check_duspdloff "Found build error after approval"
  printex "Approve `hostname` done `date`"
}

####################################################################################################################
scrdir=`dirname $0`
script=$0
echo "$prfx Started: "`date +%Y%m%d`"T"`date +%H%M%S`
echo "$prfx Command line: $0 $@"

# Parse command line into arguments
parse_commandline $@

. ~/.profile
init_log "$(basename $(readlink -nf $0)).log"
#auto_cre_logfile="$SPI_ROOT/spierr/auto_create_db_`date +%Y%m%d`_`date +%H%M%S`.log"

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
#echo "-- create_db errors -------------------------------" >$auto_cre_logfile

# Check the application server name
[[ -z $appl_server_name ]] && die_msg -l $LINENO "No application server name given."
app_srv_test=`$CONFM -f $CONFDB get appl_server/$appl_server_name/`
[[ $? -ne 0 || -z app_srv_test ]] && die_msg -l $LINENO "The $appl_server_name-section cannot be read from $CONFDB."
user_id=`$CONFM -f $CONFDB get appl_server/$appl_server_name/account`
[[ -z $user_id ]] && die_msg -l $LINENO "Incorrect parameters user_id=$user_id, appl_server_name=$appl_server_name."
user_home=`getent passwd $user_id|sed "s/:/\n/g"|sed -n 6,6p`
[[ ! -d $user_home ]] && die_msg -l $LINENO "User $user_id on $appl_server_name does not exist."
[[ $server_type_group = SCADA ]] && check_duspdloff "Found initial build error"

# Create new database on all servers
[[ $run_avanti_db_create = true ]] && create_new_database

# Populate Database
[[ $run_avanti_db_pop = true ]] && populate_database

# Approve Database
[[ $run_avanti_db_app = true ]] && approve_database

echo "$prfx Ended: "`date +%Y%m%d`"T"`date +%H%M%S`
exit 0