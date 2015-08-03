#!/bin/ksh
# File:       auto_common.ksh
# Descr:      Autobuild common routines.
# History:    2010-03-01 Anders Risberg       Initial version.
#             2010-06-05 Anders Risberg       Release 1.2.19.
#             2010-08-26 Anders Risberg       Removed t16-check.
#             2010-11-26 Anders Risberg       Added wait_for_population_done().
#             2010-12-13 Anders Risberg       Added die_msg_ex().
#             2011-04-20 Anders Risberg       Moved part of unlock_oracle_accounts() from auto_init_setup.ksh.
#                                             Moved check_oracle() from auto_init_setup.ksh.
#             2011-04-28 Anders Risberg       Now reads data consistency information from the DE400-database instead of from duspdloff.ver.
#             2011-05-12 Anders Risberg       Generation number in AQL (data consistency check) must be right aligned, space padded, and 6 characters wide.
#             2011-10-24 Anders Risberg       Changed exit codes on check_oracle.
#             2012-04-19 Gunnar Törnblom      SPR-D11120085
#

# Descr: Show debug-text.
#        Set _DEBUG to "on" in order to enable.
# Parameters: <text>
DEBUG() { [ "$_DEBUG" == "on" ] && $@ || :; }

# Descr: Prompts for yes or no.
#        If one character is uppercase it will be the default.
#        If batch_mode is true the funtion will return with the default value without prompting.
# Parameters: <text> <Y/n | y/N | y/n>
# Returns: 0 if no; 1 if yes.
yn() {
  [[ -z "$1" ]] && die_msg "Parameter missing."
  typeset var s="`echo $2|tr '[a-z]' '[A-Z]'`"
  if [[ $batch_mode = true ]];then
    case $s in Y) return 1;; N) return 0;; *) return 1;; esac
  fi
  while true;do
    echo -ne "$1 "
    case $s in Y) p="Y/n";; N) p="y/N";; *) p="y/n";; esac; echo -n "[$p]: "
    read
    case $REPLY in y|Y) return 1;; n|N) return 0;; "") [[ "$s" = "Y" ]] && return 1 || [[ "$s" = "N" ]] && return 0;; *) echo "Just answer y or n";; esac
  done
}

# Descr: Reads configuration files.
#        If show_config is true parameters and their values will be shown.
# Parameters: <file name> <group name>
rconf() {
  [[ $# -lt 2 ]] && return 0
  [[ $show_config = true ]] && echo "$prfx Configuration file: $1, group: $2"
  typeset var match=0
  while read line;do
    [[ $line = ^[\ ]{0,}[\#\;] ]] && continue # Skip comments
    [[ $line = ^$ ]] && echo && continue # Skip empty lines
    if [[ $match == 0 ]];then
      # Check for opening tag
      if [[ ${line:$((${#line}-1))} == "{" ]];then
        group=${line:0:$((${#line}-1))} # Strip "{"
        group=${group// /} # Strip whitespace
        [[ "$group" == "$2" ]] && match=1
        continue
      fi
    elif [[ ${line:0} == "}" && $match == 1 ]];then # Closing tag
      break
    else # Got a config line
      eval $line
      [[ $show_config = true ]] && echo "$prfx  $line"
    fi
  done <"$1"
  [[ $match == 0 ]] && die_msg "Couldn't find group $2 in config-file $1"
  [[ $show_config = true ]] && echo "$prfx Configuration file: $1 - end"
}

# Descr: Prepare for die_msg.
# Parameters: [-h] [-e <err_code>] [-l <line no>] [-f <file to tail>] [<text>]
die_msg_ex() {
  err_code=1
  while true;do
    case $1 in
      -h) shift;help=true;;
      -e) shift;[[ -n $1 && ! "${1:0:1}" = "-" ]];err_code=$1;shift;;
      -l) shift;[[ -n $1 && ! "${1:0:1}" = "-" ]];line_no=$1;shift;;
      -f) shift;[[ -n $1 && ! "${1:0:1}" = "-" ]];tail_file=$1;shift;;
      *) msg=$@;break;;
    esac
  done
  if [[ -n $msg ]];then
    echo -en "$prfx Error: $msg "
    [[ -n $line_no ]] && echo -en "Line: $line_no. "
    [[ -n $err_code ]] && echo -e "Error code: $err_code."
    if [[ -n $tail_file && -f $tail_file ]];then
      echo -e "$prfx Last lines of '$tail_file':"
      echo -e "$prfx ---------------"
      tail --lines=5 $tail_file
      echo -e "$prfx ---------------"
    fi
    echo
  fi
}

# Descr: Setup mail file for logging.
# Parameters: <mail file path> <subject> [truncate] <mail receivers file path>
mail_report_setup() {
  mail_receivers=""
  if [[ $# -gt 1 ]];then
    mail_file=$1
    mail_subject=$2
    [[ $# -gt 2 && $3 = true ]] && mail_report_trunc && touch $mail_file
    [[ $# -gt 3 && -e $4 ]] && (mail_receivers="`cat $4`"; printex "Mail will be sent to $mail_receivers")
  fi
}

# Descr: Truncates mail file.
# Parameters: 
mail_report_trunc() {
  [[ -e $mail_file ]] && rm -f $mail_file
}

# Descr: Add text to mail file.
# Parameters: <text> <text> ... <text>
mail_report() {
  if [[ -e $mail_file ]];then
    if [[ $# -gt 0 ]];then
      echo $@ >>$mail_file
    else while read inp;do echo $inp >>$mail_file; done
    fi
  fi
}

# Descr: Send mail file to recipients in receivers file.
# Parameters: 
mail_report_send() {
  [[ -n "$mail_receivers" && -e $mail_file ]] && mail -s "$mail_subject" $mail_receivers < $mail_file
}

# Descr: Initiates the log file.
# Parameters: <log file name>
auto_logfile=""
init_log() {
  auto_logfile=$1;
  rm -f $auto_logfile
  touch $auto_logfile
}

# Descr: Extended print-function with prefix and printing to log-file.
#        If not_on_scr is true the text will show up in the log-file only.
# Parameters: <text> <not_on_scrn>
printex() {
  typeset var str=$1
  typeset var not_on_scr=$2
  [[ -f $auto_logfile ]] && echo "`date +%H%M%S` $prfx $str" >$auto_logfile
  [[ ! $not_on_scr -eq 1 ]] && echo "$prfx $str"
}

# Descr: Checks if Oracle is running.
# Parameters: SID; if omitted the default ORACLE_SID will be used.
# Returns: 0 if running ok; 1 if not running daemon; 15 if SID is missing; 16 if SID is down.
check_oracle() {
  [[ $# -gt 0 ]] && sid=$1
  su - oracle <<EOD
    [[ -z "\$sid" ]] && sid=\$ORACLE_SID
    [[ -z "\$sid" ]] && exit 15
    check_stat=\`ps -ef|grep \${sid}|grep pmon|wc -l\`
    oracle_num=\`expr \$check_stat\`
    [[ \$oracle_num -lt 1 ]] && exit 1
    \$ORACLE_HOME/bin/sqlplus -s /<<! > /tmp/check_\$sid.ora
      select * from v\\\$database;
      exit
!
    # Check number of errors from above sql-session
    check_stat=\`cat /tmp/check_\$sid.ora|grep -i error|wc -l\`
    rm -f /tmp/check_\$sid.ora
    oracle_num=\`expr \$check_stat\`
    [[ \$oracle_num -ne 0 ]] && exit 16 || exit 0
EOD
  return $?
}

# Descr: Stops Oracle.
# Parameters: 
stop_oracle() {
  printex "Stopping Oracle ..."
  printex "  Looking for running Oracle ..."
  check_oracle;sts=$?
  if [[ $sts -eq 0 ]];then
    printex "    Found."
    su - oracle -c udwstop
    check_oracle;sts=$?
    [[ $sts -ne 0 ]] && printex "  Oracle stopped OK" || die_msg -e $sts "  Failed to stop Oracle - return code: $sts"
  else
    printex "    None found ($sts)."
  fi
}

# Descr: Starts Oracle.
# Parameters: 
start_oracle() {
  printex "Starting Oracle ..."
  printex "  Looking for running Oracle ..."
  check_oracle;sts=$?
  if [[ $sts -eq 0 ]];then
    printex "    Found."
  else
    printex "    None found ($sts)."
    su - oracle -c udwstart
    check_oracle;sts=$?
    [[ $sts -eq 0 ]] && printex "  Oracle started OK" || die_msg -e $sts "  Failed to start Oracle - return code: $sts"
  fi
}

# Descr: Unlock locked Oracle-accounts.
# Parameters: 
unlock_oracle_accounts() {
  echo "$prfx Checking and unlocking Oracle-accounts ..."
  # Check paths
  [[ -z $baseline_path ]] && die_msg -h -l $LINENO "No baseline path given."
  [[ ! -d $baseline_path ]] && die_msg -h -l $LINENO "Baseline path $baseline_path not accessible."
  [[ -z $pwd_oracle_system ]] && die_msg -h -l $LINENO "No password given for Oracle-user system."
  
  his_dir=`find $baseline_path/spiroot/ -maxdepth 3 -type d -name 'his'`
  num=`echo $his_dir|wc -l`
  if [[ $num -gt 1 ]];then
    echo "$prfx   Too many directories found when looking for 'his'."
    return 1
  fi
  if [[ $num -lt 1 ]];then
    echo "$prfx   Directory 'his' not found."
    return 1
  fi
  cmd=$his_dir/source/alter_account.sh
  if [[ ! -d $his_dir/source || ! -f $cmd ]];then
    echo "$prfx   Cannot find $cmd."
    return 1
  fi

  su - oracle <<EOD
    $cmd 1 | grep "SYSTEM" | grep "EXPIRED";sts=\$?
    if [[ \$sts -eq 0 ]];then
      echo "$prfx   Unlocking Oracle-account SYSTEM ..."
      $cmd 2 "SYSTEM" $pwd_oracle_system
    else
      echo "$prfx   Oracle-account is already unlocked"
    fi
	exit 0
EOD
  return $?
}

# Descr: Gets the path to the runcons-files at the install machine. Updates $runcons_path.
# Parameters: 
get_runcons_inst_path() {
  [[ -z $autobuild_hub_path_install ]] && die_msg "No hub path given in get_runcons_inst_path."
  [[ -z $runcons_name ]] && die_msg "No runcons name given in get_runcons_inst_path."
  runcons_path="$autobuild_hub_path_install/$runcons_name"
}

# Descr: Makes changes to the kernel (added to /etc/sysctl.conf).
# Parameters: 
update_kernel_settings() {
  printex "Make changes to the kernel"
  sysctl -p >/dev/null 2>&1; sts=$?
  [[ $sts -eq 0 ]] && printex "  Changes to the kernel OK" || die_msg -e $sts "  Failed to make changes to the kernel - return code: $sts"
}

# Descr: Gets information about a application server.
#        Used for status retrieval; must use silent-flag on all printouts except one.
# Parameters: <server name> <silent>
get_server_info() {
  typeset var _as_name=$1
  typeset var _silent=$2
  if [[ -n $_as_name ]];then
    _app_srv_test=`$CONFM -f $CONFDB get appl_server/$_as_name/`
    [[ $? -ne 0 || -z $_app_srv_test ]] && die_msg "The $_as_name-section cannot be read from $CONFDB."
    server_type=`$CONFM get appl_server/$_as_name/server_type`
    nodes=`$CONFM -f $CONFDB get appl_server/$_as_name/normal_nodes`
    master_node=`$CONFM -f $CONFDB get master`
    master=`$CONFM -f $CONFDB get appl_server/$_as_name/master`
    uid=`$CONFM -f $CONFDB get appl_server/$_as_name/account`
    gid=`id -ng $uid`
    uhome=`getent passwd $uid|sed "s/:/\n/g"|sed -n 6,6p`
    _tn=`hostname`
    _tn=`echo $_tn|awk -F. '{printf("%s",$_as_name)}'`
    in_nodes=`echo $nodes|grep "$_tn"`
    [[ $_silent = false ]] && printex "___________________________"
    [[ $_silent = false ]] && printex "         application server:$_as_name"
    [[ $_silent = false ]] && printex "               with account:$uid:$gid"
    [[ $_silent = false ]] && printex "                  user home:$uhome"
    x=`for n in $nodes;do echo -n "$n ";done;echo`
    [[ $_silent = false ]] && printex " distributed on these nodes:$x"
    [[ $_silent = false && -n $in_nodes ]] && printex "   this node is one of them:$_tn"
    [[ $_silent = false ]] && printex "        and has this master:$master"
  fi
}

# Descr: Finds master and distributed application servers in this node.
#        Used for status retrieval; must use silent-flag on all printouts.
# Parameters: <server name> <silent>
find_app_servers() {
  typeset var __as_name=$1
  typeset var __silent=$2
  [[ -n $2 ]] && __silent=$2 || __silent=false
  [[ $__silent = false ]] && printex "________________________________________________________________"
  [[ $__silent = false ]] && printex "Find master and distributed application servers in this node ..."
  this_node=`hostname`
  this_node=`echo $this_node|awk -F. '{printf("%s",$1)}'`
  [[ $__silent = false ]] && printex "               this node is:$this_node"

  # Get application servers such as NM_SCADA, NM_UDW, etc. (remove trailing /)
  appl_servers=`$CONFM -f $CONFDB get appl_server/|sed -e "s!/!!"`
  x=`for n in $appl_servers;do echo -n "$n ";done;echo`
  [[ $__silent = false ]] && printex "  found application servers:$x"
  
  # Parse the application servers
  [[ $__silent = false ]] && printex "Parse the application servers ..."
  found_appl_master_servers="";found_appl_servers="";
  for as in $appl_servers;do
    get_server_info $as $__silent

    # Add this server to the list of found servers, if not already there
    if [[ $(expr "$found_appl_servers" : ".*${as}.*") -le 0 ]];then
      [[ -n $found_appl_servers ]] && spc=" " || spc=""
      found_appl_servers=$found_appl_servers$spc$as
    fi

    # Add this server's master to the list of found master servers, if not already there
    if [[ $(expr "$found_appl_master_servers" : ".*${master}.*") -le 0 ]];then
      [[ -n $found_appl_master_servers ]] && spc=" " || spc=""
      found_appl_master_servers=$found_appl_master_servers$spc$master
    fi
  done
  
  [[ $__silent = false ]] && printex "___________________________"
  [[ $__silent = false ]] && printex "                   >servers:$found_appl_servers"
  [[ $__silent = false ]] && printex "            >master servers:$found_appl_master_servers"
  [[ $__silent = false ]] && printex "All application servers on this node (masters first)"
  all_appl_servers="`echo $found_appl_master_servers|sed -e \"s!^ !!\"` `echo $found_appl_servers|sed -e \"s!^ !!\"`"
  [[ $__silent = false ]] && printex " all_appl_servers:$all_appl_servers"
}

# Descr: Set the running mode of an application server.
# Parameters: <application server> <server type> <mode> <wait for start>
set_server_mode() {
  typeset var _as=$1
  typeset var _stype=$2
  typeset var _mode=$3
  typeset var _wait=$4
  typeset var _sopm=`get_sopmode`
  typeset var _req_status=online
  typeset var _req_check_queues=true
  printex "         Netman server status (in): $_sopm"

  case $_mode in
    stop) # Stop
      if [[ $_sopm != "stopped" && $_sopm != "error" ]];then
        printex "           Stopping ..."
        netman_stop
        spiclean
      else
        printex "           Already stopped or non-existing."
      fi
      return;;
    bat) # Batch-mode
      _req_status=batch
      netman_start bat;;
    run) # Run-mode
      netman_start run;;
    pass) # Run/passive-mode
      _req_status=passive
      _req_check_queues=false
      netman_start pas;;
    cold) # Run/cold-mode
      cat >~/run_cold_temp <<!
con
run
cold
yes
yes
int
!
      netman_start -f ~/run_cold_temp
      rm -f ~/run_cold_temp;;
    *) die_msg "Invalid set_server_mode option $1.";;
  esac

  if [[ $_wait = true ]];then
    ## Check the status of the server until it's ok
    printex "       Check the status of the server ($_as) until it's ok ..."
    wait_for_server_start ${_as} ${_stype} 30 10 $_req_status $_req_check_queues
    [[ $sts_ret = true ]] && die_msg "         $sts_txt"
  else
    _sopm=`get_sopmode`
    printex "         Netman server status: $_sopm"
  fi
}

# Descr: Get current server operation mode.
# Parameters: 
get_sopmode() {
  if [[ -d $SPI_ROOT && -e $SPI_ROOT/../spicommon/spiexe/sopmode ]];then
    typeset var _sopm=`sopmode`;sts=$?
    echo $_sopm
  else
    echo "error"
  fi
}

# Descr: Waits until an application server has started.
# Parameters: <server name> <server type> <retries> <timeout>
# Returns: sts_ret = true, sts_txt = error message if error; sts_ret = false if ok
wait_for_server_start() {
  typeset var _as=$1
  typeset var _srv_type=$2
  typeset var _retries=$3
  typeset var _timeout=$4
  typeset var _req_status=$5
  typeset var _check_queues=$6
  
  # Get lowercase version of application server name, excl. "_"
  typeset -l las=`echo "$_as"|sed -e "s!_!!g"`
  typeset -i cnt_checks_left=$_retries
  while [[ true ]];do
    failed=false
    printex "         Check operation mode for $_as (required: $_req_status) ... "
    sopmode=`get_sopmode`
    printex "           $sopmode"
    if [[ $sopmode != *online && $sopmode != *batch && $sopmode != *passive && $sopmode != *stopped ]];then
      sts_ret=true;sts_txt="Wrong status: $sopmode";return
    fi
    [[ $sopmode != *$_req_status ]] && failed=true
    if [[ $failed = false && $_check_queues = false ]];then
      sts_ret=false;return
    fi
    if [[ $failed = false ]];then
      printex "         Check process $las"
      sts_las=`QM "l,,$las" | grep "State = executing">/dev/null 2>&1;sts=$?;[[ $sts = 0 ]] && echo "executing"`
      printex "           $sts_las"
      [[ $sts_las != executing ]] && failed=true
    fi
    if [[ $failed = false ]];then
      sts_ret=false;return
    else
      cnt_checks_left=cnt_checks_left-1
      if [[ $cnt_checks_left < 1 ]];then
        sts_ret=true;sts_txt="Failed to start Netman server in batch mode ($_as). Giving up.";return
      fi
      printex "         Netman server not yet executing. Will retry after a while ($cnt_checks_left checks left) ..."
      sleep $_timeout
    fi
  done
}

# Descr: Waits until population has finished.
# Parameters: <retries> <timeout>
# Returns: sts_ret = true, sts_txt = error message if error; sts_ret = false if ok
wait_for_population_done() {
  typeset var _retries=$1
  typeset var _timeout=$2
  
  typeset -i cnt_checks_left=$_retries
  while [[ true ]];do
    failed=false
    printex "         Check queue 416"
    sts_las=`QM "l,416,,enqueued" | grep "Enqueued = 0">/dev/null 2>&1;sts=$?;[[ $sts = 0 ]] && echo "done"`
    printex "           $sts_las"
    [[ $sts_las != done ]] && failed=true
    if [[ $failed = false ]];then
      sts_ret=false;return
    else
      cnt_checks_left=cnt_checks_left-1
      if [[ $cnt_checks_left < 1 ]];then
        sts_ret=true;sts_txt="Failed to start Netman server in batch mode ($_as). Giving up.";return
      fi
      printex "         Netman server not yet executing. Will retry after a while ($cnt_checks_left checks left) ..."
      sleep $_timeout
    fi
  done
}

# Descr: Check the duspdloff-file for errors. Die on error.
# Parameters: <error message>
check_duspdloff() {
  printex "Checking $SPI_ROOT/spipdl/duspdloff.ver for errors ..."
  total=`grep TOTAL $SPI_ROOT/spipdl/duspdloff.ver`
  [[ -z $total ]] && total="<empty>"
  build_error=`grep ERROR $SPI_ROOT/spipdl/duspdloff.ver`
  [[ -z $build_error ]] && build_error="<empty>"
  printex "  TOTAL=$total, ERROR=$build_error"
  [[ $build_error = "ERROR" ]] && die_msg "$1 in $SPI_ROOT/spipdl/duspdloff.ver."
}

# Descr: Check the DE400-database and Avanti-database for data consistency errors. Die on error.
# Parameters: <generation number to compare> <generation date to compare>
check_dataconsistency() {
  typeset var gen_number=$1;shift
  typeset var upd_date=$1;shift
  printex "Checking the the Avanti-database for data consistency errors with $gen_number, $upd_date ..."

  # Regex'es for six character, space padded number + two spaces + date + time
  regx_num="^\ \{0,5\}[0-9]\{1,6\}"
  regx_date="[0-9][0-9]-[a-zA-Z]\{3\}-[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9]"

  typeset -i count=1
  while true;do
    # Get the current date and number from the Avanti-database
    # Generation number is six characters padded with spaces
    gen_number_db=`AQL "select GENERATIONNUMBER from dataconsistency"|sed 5,1p`
    gen_number_db=`echo $gen_number_db | sed 's/^[ \t]*//;s/[ \t]*$//'` # Remove whitespace
    chk=`echo "$gen_number_db"|grep "$regx_num"`
    if [[ -z $chk ]];then
      echo "Avanti-database read error."
      exit 1
    fi
    # Update date format is dd-mmm-yy hh:mm:ss
    upd_date_db=`AQL "select UPDATEDATE from dataconsistency"|sed 5,1p`
    upd_date_db=`echo $upd_date_db | sed 's/^[ \t]*//;s/[ \t]*$//'` # Remove whitespace
    chk=`echo "$upd_date_db"|grep "$regx_date"`
    if [[ -z $chk ]];then
      echo "Avanti-database read error."
      exit 1
    fi
    echo "  Avanti database:$gen_number_db, $upd_date_db"
  
    # Check if any of generation number or update date is different; in that case update the Avanti-database
    if [[ $gen_number != $gen_number_db || $upd_date != $upd_date_db ]];then
      if [[ $count > 0 ]];then
        echo "    Different. Updating ..."
        gn=`printf "%6s" "$gen_number"` # Right aligned; space padded; 6 characters
        AQL "update dataconsistency set GENERATIONNUMBER='$gn'"
        AQL "update dataconsistency set UPDATEDATE='$upd_date'"
	      count=count-1 # Check a second time that the write was ok
	    else
	      echo "Failed to update Avanti-database with new data consistency values."
        exit 1
	    fi
    else
      echo "    Matching"
      break
    fi
  done
  exit 0
}
