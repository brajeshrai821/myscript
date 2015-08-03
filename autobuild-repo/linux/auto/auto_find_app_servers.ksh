#!/bin/ksh
# File:       auto_find_app_servers.ksh
# Descr:      Finds master and distributed application servers.
# Parameters: Check out die_msg().
# Returns:    0 if ok; otherwise error.
# History:    2010-03-01 Anders Risberg       Initial version.
#             2010-06-05 Anders Risberg       Release 1.2.19.
#             2010-12-13 Anders Risberg       Enhanced die_msg; added line number; partly moved to auto_common.ksh.
#             2011-03-03 Anders Risberg       New option: get master for server.
#             2011-03-07 Anders Risberg       New option: get database index.
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
    echo " --get_servers          Get application server names."
    echo " --get_conf_master_node Get configuration master node."
    echo " --get_nodes            Get nodes in server."
    echo " --get_account          Get account name for server."
    echo " --get_master           Get master for server."
    echo " --get_server_type      Get type of server."
    echo " --get_dbi              Get database index."
    echo " --get_sbi              Get studio database index."
    echo " -s server              Server name."
  fi
  exit $err_code
}

# Descr: Parse command line into arguments.
# Parameters: <parameter-list>
parse_commandline() {
  [[ $# -lt 1 ]] && die_msg -l $LINENO "Option or parameter missing."

  config_file=""
  show_config=false
  get_servers=false
  get_conf_master_node=false
  get_nodes=false
  get_account=false
  get_server_type=false
  get_dbi=false
  get_sbi=false
  server_name=""
  
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
      --get_servers) shift; # Get application server names
        get_servers=true;;
      --get_conf_master_node) shift; # Get configuration master node
        get_conf_master_node=true;;
      --get_nodes) shift; # Get nodes in server
        get_nodes=true;;
      --get_account) shift; # Get account name for server
        get_account=true;;
      --get_master) shift; # Get master for server
        get_master=true;;
      --get_server_type) shift; # Get type of server
        get_server_type=true;;
      --get_dbi) shift; # Get database index
        get_dbi=true;;
      --get_sbi) shift; # Get studio database index
        get_sbi=true;;
      -s) shift; # Server name
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && server_name=$1
        shift;;
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
#echo "$prfx Started: "`date +%Y%m%d`"T"`date +%H%M%S`
#echo "$prfx Command line: $0 $@"

# Parse command line into arguments
parse_commandline $@
# Check if config-file exists
[[ (-n $config_file) && (! -r $config_file) ]] && die_msg -e 3 -l $LINENO "Config-file ${config_file} cannot be read."

CONFM=/usr/local/bin/confm
export CONFDB=/usr/local/config/db/confdb

# Find master and distributed application servers
if [[ $get_servers = true ]];then
  all_appl_servers=`$CONFM -f $CONFDB get appl_server/|sed -e "s!/!!"`
  echo -n $all_appl_servers
fi

# Find master node
if [[ $get_conf_master_node = true ]];then
  conf_master_node=`$CONFM -f $CONFDB get master`
  echo -n $conf_master_node
fi

# Find nodes in given server
if [[ $get_nodes = true && -n $server_name ]];then
  nodes=`$CONFM -f $CONFDB get appl_server/$server_name/normal_nodes`
  echo -n $nodes
fi

# Find account for given server
if [[ $get_account = true && -n $server_name ]];then
  account=`$CONFM -f $CONFDB get appl_server/$server_name/account`
  echo -n $account
fi

# Find master for given server
if [[ $get_master = true && -n $server_name ]];then
  master=`$CONFM -f $CONFDB get appl_server/$server_name/master`
  echo -n $master
fi

# Find type of given server
if [[ $get_server_type = true && -n $server_name ]];then
  server_type=`$CONFM -f $CONFDB get appl_server/$server_name/server_type`
  echo -n $server_type
fi

# Find database index for given server
if [[ $get_dbi = true && -n $server_name ]];then
  dbi=`$CONFM -f $CONFDB get appl_server/$server_name/dbi`
  # Convert to lowercase
  typeset -l ldbi=`echo "$dbi"|sed -e "s!_!!"`
  echo -n $ldbi
fi

# Find studio database index for given server
if [[ $get_sbi = true && -n $server_name ]];then
  sbi=`$CONFM -f $CONFDB get appl_server/$server_name/study_db_templates`
  # Convert to lowercase
  typeset -l lsbi=`echo "$sbi"|sed -e "s!_!!"`
  echo -n $lsbi
fi

#echo "$prfx Ended: "`date +%Y%m%d`"T"`date +%H%M%S`
exit 0