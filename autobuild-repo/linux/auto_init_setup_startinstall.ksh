#!/bin/ksh
# File:       auto_init_setup_startinstall.ksh
# Descr:      Initialization-script for autobuild environment.
#             Start install.
# Parameters: Check out die_msg().
# Returns:    0 if ok; otherwise error.
# History:    2009-12-09 Anders Risberg       Initial version. Moved from auto_init_setup.ksh.
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
  if [[ $help = true ]];then
    echo
    echo "Synopsis: $(basename $(readlink -nf $0)) option"
    echo "Options:"
    echo " -c path                Configuration file (overridden by subsequent parameters)."
    echo " --show_config          Show config-file parameters."
    echo " --run                  Run."
  fi
  exit $err_code
}

# Descr: Parse command line into arguments.
# Parameters: <parameter-list>
parse_commandline() {
  [[ $# -lt 1 ]] && die_msg -l $LINENO "Option or parameter missing."

  config_file=""
  show_config=false
  run=false

  while true;do
    case $# in 0) break;; esac
    case $1 in
      -c) shift; # Read common settings from configuration file
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && config_file=$1
        [[ -f $config_file ]] && rconf $config_file "main"
        [[ -f $config_file ]] && rconf $config_file "common"
        [[ -f $config_file ]] && rconf $config_file "init_common"
        [[ -f $config_file ]] && rconf $config_file "install_common"
        shift;;
      --show_config) shift; # Show config-file parameters
        show_config=true;;
      --run) shift; # Run
        run=true;;
      -|--) shift; break;;
      -h|--help) die_msg -h -e 0;;
      -*) die_msg -e 2 -l $LINENO "Invalid option $1.\nTry $0 --help to see available options.";;
      *) die_msg -e 2 -l $LINENO "Invalid option $1.\nTry $0 --help to see available options.";;
    esac
  done
}

####### Script specific functions #######

# Descr: Run startinstall.
# Parameters: 
run_startinstall(){
  [[ -z $tmp_display ]] && echo "Warning: No display set."
  [[ ! -e $runcons_path/startinstall ]] && die_msg -h -l $LINENO "Startinstall-script not found ($runcons_path/startinstall)."
  
  # Clear this one since it will enable spiconf to run otherwise
  tmp_display=$DISPLAY
  export DISPLAY=""

  echo "$prfx Run $runcons_path/startinstall"
  $runcons_path/startinstall

  # Restore to enable spiconf
  export DISPLAY=$tmp_display
}

####################################################################################################################
src_dir=`dirname $0`
echo "$prfx Started: "`date +%Y%m%d`"T"`date +%H%M%S`
echo "$prfx Command line: $0 $@"

# Parse command line into arguments
parse_commandline $@
# Check if config-file exists
[[ (-n $config_file) && (! -r $config_file) ]] && die_msg -e 3 -l $LINENO "Config-file ${config_file} cannot be read."

# Get the current path to the runcons-files
get_runcons_inst_path
[[ -z $runcons_path ]] && die_msg -l $LINENO "No runcons path given."

## Run startinstall
[[ $run = true ]] && run_startinstall

echo "$prfx Ended: "`date +%Y%m%d`"T"`date +%H%M%S`
exit 0