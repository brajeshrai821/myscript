#!/bin/ksh
# File:       auto_netman_mode.ksh
# Descr:      Change Netman operation mode.
# Parameters: Check out die_msg().
# Returns:    0 if ok; otherwise error.
# History:    2010-04-12 Anders Risberg       Initial version.
#             2010-06-05 Anders Risberg       Release 1.2.19.
#             2010-12-13 Anders Risberg       Enhanced die_msg; added line number; partly moved to auto_common.ksh.
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
    echo " --stop                 Stop Netman."
    echo " --bat                  Run Netman in batch-mode."
    echo " --cold                 Run Netman in run/cold-mode."
    echo " --pass                 Run Netman in run/passive-mode."
    echo " -s name                Application server name."
    echo " -t type                Application server type."
  fi
  exit $err_code
}

# Descr: Parse command line into arguments.
# Parameters: <parameter-list>
parse_commandline() {
  [[ $# -lt 1 ]] && die_msg -l $LINENO "Option or parameter missing."

  run_set_server_mode_stop=false
  run_set_server_mode_bat=false
  run_set_server_mode_cold=false
  run_set_server_mode_pass=false
  appl_server_name=""
  server_type=""
  
  while true;do
    case $# in 0) break;; esac
    case $1 in
      --stop) shift; # Stop Netman
        run_set_server_mode_stop=true;;
      --bat) shift; # Run Netman in batch-mode
        run_set_server_mode_bat=true;;
      --cold) shift; # Run Netman in run/cold-mode
        run_set_server_mode_cold=true;;
      --pass) shift; # Run Netman in run/passive-mode
        run_set_server_mode_pass=true;;
      -s) shift; # Name of application server
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && appl_server_name=$1 && shift;;
      -t) shift; # Application server type
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && server_type=$1 && shift;;
      -|--) shift; break;;
      -h|--help) die_msg -h -e 0;;
      -*) die_msg -e 2 -l $LINENO "Invalid option $1.\nTry $0 --help to see available options.";;
      *) die_msg -e 2 -l $LINENO "Invalid option $1.\nTry $0 --help to see available options.";;
    esac
  done
}

####### Script specific functions #######

####################################################################################################################
src_dir=`dirname $0`
echo "$prfx Started: "`date +%Y%m%d`"T"`date +%H%M%S`
echo "$prfx Command line: $0 $@"

# Parse command line into arguments
parse_commandline $@

# Check some parameters
[[ -z $appl_server_name ]] && die_msg -l $LINENO "No application server name given."
[[ -z $server_type ]] && die_msg -l $LINENO "No server type given."

# Change mode of operation
[[ $run_set_server_mode_stop = true ]] && set_server_mode $appl_server_name $server_type stop
[[ $run_set_server_mode_bat = true ]] && set_server_mode $appl_server_name $server_type bat true
[[ $run_set_server_mode_cold = true ]] && set_server_mode $appl_server_name $server_type cold true
[[ $run_set_server_mode_pass = true ]] && set_server_mode $appl_server_name $server_type pass true

echo "$prfx Ended: "`date +%Y%m%d`"T"`date +%H%M%S`
exit 0