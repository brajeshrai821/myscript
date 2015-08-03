#!/bin/ksh
# File:       auto_init_setup.ksh
# Descr:      Initialization-script for the autobuild environment.
# Parameters: Check out die_msg().
# Returns:    0 if ok; otherwise error.
# History:    2009-07-30 Anders Risberg       Initial version.
#             2010-06-05 Anders Risberg       Release 1.2.19.
#             2010-10-12 Anders Risberg       Moved server type DISTRIBUTED from SCADA to UDW.
#             2010-11-26 Anders Risberg       Generalized way to find module directories in spiroot.
#             2010-12-13 Anders Risberg       Enhanced die_msg; added line number; partly moved to auto_common.ksh.
#             2011-03-29 Anders Risberg       Fixed bug in unlock_oracle_accounts; did not work at all.
#             2011-03-31 Anders Risberg       All server types are SCADA unless otherwise stated.
#             2011-04-20 Anders Risberg       Moved part of unlock_oracle_accounts() to auto_common.ksh.
#                                             Moved check_oracle() to auto_common.ksh.
#                                             Removed local_build-switch.
#             2011-10-24 Anders Risberg       Changed exit codes on check_oracle.
#             2011-12-01 Anders Risberg       Changed method for sopmode.
#
#_DEBUG="on"
prfx="#[$(basename $(readlink -nf $0))]>";

####### Helper functions #######
if [[ -e ~/autobuild/auto/auto_common.ksh ]];then
  . ~/autobuild/auto/auto_common.ksh
elif [[ -e /usr/local/autobuild/auto/auto_common.ksh ]];then
  . /usr/local/autobuild/auto/auto_common.ksh
elif [[ -e ./autobuild/auto/auto_common.ksh ]];then
  . ./autobuild/auto/auto_common.ksh
fi

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
    echo " --init_build           Copy and initiate scripts on build host."
    echo " --init_install         Copy and initiate scripts install host."
    echo " --remove_build         Remove files and users for build."
    echo " --remove_install       Remove files and users for install."
    echo " --recreate_build       Recreate project and users for build, if not already exist."
    echo " --recreate_install     Recreate users for install, if not already exist."
    echo " --oracheck_build       Check Oracle and Oracle-accounts."
    echo " --precheck_build       Pre-check for build (must be root)."
    echo " --precheck_install     Pre-check for install (must be root)."
    echo " --prep_build           Prepare for build."
    echo " --prep_install         Prepare for install."
    echo " -tg type group         Server type group."
    echo " -t type                Server type."
    echo " -u name                User name."
    echo " -g name                Group name."
    echo " -p|--project-home path Project home."
    echo " -b|--baseline path     Baseline path."
    echo " -k|--kits    path      Kit-directory path."
    echo " -a|--autobuild path    Path to autobuild files."
  fi
  exit $err_code
}

# Descr: Parse command line into arguments.
# Parameters: <parameter-list>
parse_commandline() {
  [[ $# -lt 1 ]] && die_msg -l $LINENO "Option or parameter missing."

  config_file=""
  show_config=false # Used to determine config output 
  proc_build=false # Used to determine output line prefix
  proc_inst=false # Used to determine output line prefix
  oracheck_build=false
  precheck_build=false
  precheck_install=false
  prep_build=false
  prep_install=false
  init_build=false
  init_install=false
  remove_build=false
  remove_install=false
  recreate_build=false
  recreate_install=false
  server_type_group=""
  user_name=""
  group_name=""
  proj_home=""
  baseline_path=""
  
  while true;do
    case $# in 0) break;; esac
    case $1 in
      -c) shift; # Read common settings from configuration file
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && config_file=$1
        [[ -f $config_file ]] && rconf $config_file "main"
        [[ -f $config_file ]] && rconf $config_file "common"
        [[ -f $config_file ]] && rconf $config_file "init_common"
        shift;;
      --show_config) shift; # Show config-file parameters
        show_config=true;;
      --init_build) shift; # Copy and initiate scripts on build host (copy to /project/projectuser/bin etc.)
        init_build=true;proc_build=true;;
      --init_install) shift; # Copy and initiate scripts on install host (copy to /usr/local/... etc.)
        init_install=true;proc_inst=true;;
      --remove_build) shift; # Remove files for build
        remove_build=true;proc_build=true;;
      --remove_install) shift; # Remove files for install
        remove_install=true;proc_inst=true;;
      --recreate_build) shift; # Recreate project and users for build, if not already exist
        recreate_build=true;proc_build=true;
        [[ -f $config_file ]] && rconf $config_file "build_common";;
      --recreate_install) shift; # Recreate users for install, if not already exist
        recreate_install=true;proc_inst=true;
        [[ -f $config_file ]] && rconf $config_file "install_common";;
      --oracheck_build) shift; # Check Oracle and Oracle-accounts."
        oracheck_build=true;
        [[ -f $config_file ]] && rconf $config_file "build_common";;
      --precheck_build) shift; # Pre-check for build (must be root)
        precheck_build=true;proc_build=true;
        [[ -f $config_file ]] && rconf $config_file "build_common";;
      --precheck_install) shift; # Pre-check for install (must be root)
        precheck_install=true;proc_inst=true;
        [[ -f $config_file ]] && rconf $config_file "install_common";;
      --prep_build) shift; # Prepare for build
        prep_build=true;proc_build=true;
        [[ -f $config_file ]] && rconf $config_file "build_common";;
      --prep_install) shift; # Prepare for install
        prep_install=true;proc_inst=true;
        [[ -f $config_file ]] && rconf $config_file "install_common";;
      -tg) shift; # Server type group
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && server_type_group=$1 && shift;;
      -u) shift; # User name
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && user_name=$1 && shift;;
      -g) shift; # Group name
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && group_name=$1 && shift;;
      -p|--project-home) shift; # Project name
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && proj_home=$1 && shift;;
      -b|--baseline) shift; # Baseline path
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && baseline_path=$1 && shift;;
      -|--) shift; break;;
      -h|--help) die_msg -h -e 0;;
      -*) die_msg -e 2 -l $LINENO "Invalid option $1.\nTry $0 --help to see available options.";;
      *) die_msg -e 2 -l $LINENO "Invalid option $1.\nTry $0 --help to see available options.";;
    esac
  done
}

####### General functions #######

# Descr: Show debug-text.
#        Set _DEBUG to "on" in order to enable.
# Parameters: <text>
DEBUG() { [ "$_DEBUG" == "on" ] && $@ || :; }

# Descr: Reads configuration files.
#        If show_config is true parameters and their values will be shown.
# Parameters: <file name> <group name>
# Returns: Nothing.
rconf() {
  [[ $# -lt 2 ]] && return 0
  [[ $show_config = true ]] && echo "$prfx Configuration file: $1, group: $2"
  match=0
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
      [[ $show_config = true ]] && echo "$prfx   $line"
    fi
  done <"$1"
  [[ $match == 0 ]] && die_msg -l $LINENO "Couldn't find group $2 in config-file $1"
  [[ $show_config = true ]] && echo "$prfx   Configuration file: $1 - end"
}

####### Script specific functions #######

# Descr: Checks whether an  AD (Active Directory) account exists.
# Parameters: <user name> <group name> <password>
check_ad_account() {
  usr=$1;grp=$2;pw=$3
  echo "$prfx Checking AD-account $usr ... "
  getent passwd | grep $usr >/dev/null 2>&1;sts=$?
  [[ $sts -eq 0 ]] && echo "$prfx  User $usr found in password list." || die_msg -l $LINENO "User $usr not found in password list. Is AD started? Error code: $sts."
  getent group | grep $grp >/dev/null 2>&1;sts=$?
  [[ $sts -eq 0 ]] && echo "$prfx  Group $grp found in group list." || die_msg -l $LINENO "Group $grp not found in group list. Is AD started? Error code: $sts." 
}

# Descr: Checks the status of Netmanager.
# Parameters: 
check_netman() {
  echo "$prfx Checking Netman ..."
  user_home=`getent passwd $1|sed "s/:/\n/g"|sed -n 6,6p`
  if [[ -d $user_home && -f $user_home/.profile ]];then
    appsrv=`grep APPL_SERVER_NAME $user_home/.profile | awk -F= '{print $2}'`
    [[ -z $appsrv ]] && die_msg -l $LINENO  "Non existing Netman."
    echo "$prfx   Checking Netman for server $appsrv, user $1 ..."
    nmcmd $appsrv sopmode;sts=$?
    echo "$prfx   Netman-server status: $sts"
    [[ $sts -ne 254 ]] && die_msg -l $LINENO "Netman is still running or in an undefined state. Aborting." || echo "$prfx   Already stopped."
  else
    echo "$prfx   Non existing. Cannot find user."
  fi
}

# Descr: Remove a user at an installation host.
# Parameters: <user name>
remove_user() {
  echo "$prfx Removing user $1 ..."
  [[ -d /usr/users/$1 ]] && rm -rf /usr/users/$1
}

# Descr: Remove project files in a home directory.
# Parameters: 
remove_proj_files() {
  echo "$prfx Removing project files in $proj_home/$user_name ..."
  [[ -z $proj_home ]] && die_msg -h -l $LINENO "No project path given."
  [[ -z $user_name ]] && die_msg -h -l $LINENO "No user name given."
  [[ -z $script_path_build ]] && die_msg -h -l $LINENO "No build script path given."
  if [[ -d $proj_home/$user_name ]];then
    echo "    Forced removal of non-hidden files in $proj_home/$user_name"
    #rm -rf $proj_home/$user_name/*)
    find $proj_home/$user_name/* -maxdepth 0 -type d ! -name '.*' -and ! -samefile "$script_path_build" -exec rm -rf {} \;
  fi
}

# Descr: Create an installation host user.
# Parameters: <user name> <group>
create_user_install() {
  ## E.g. netman and hisspd
  usr=$1;grp=$2
  echo "$prfx Create home for user $usr with group $grp ..."
  [[ -d /usr/users/$usr ]] && echo "$prfx   User $usr already exist."
  [[ ! -d /usr/users/$usr ]] && mkdir -p /usr/users/$usr
  chown $usr:$grp /usr/users/$usr
  [[ $? -gt 0 ]] && die_msg -l $LINENO "Failed setting user $usr's permissions. Is the AD-machine running?"
}

# Descr: General scripts setup.
# Parameters: 
setup_scripts() {
  echo "$prfx Setup scripts ..."
  
  # Set the executable-bits for init-scripts
  init_apps=`/bin/ls $src_dir/*ksh | xargs -n1 basename`
  for f in $init_apps; do
    chmod +rx $src_dir/$f
  done
  
  # Set the executable-bits for auto-scripts
  auto_apps=`/bin/ls $src_dir/auto/*ksh | xargs -n1 basename`
  for f in $auto_apps; do
    chmod +rx $src_dir/auto/$f
  done 
}

# Descr: Setup scripts on a build host.
# Parameters: 
setup_scripts_build() {
  echo "$prfx Setup scripts on build host ..."
  
  # Create .profile if not exists
  [[ ! -f ~/.profile ]] && echo "PS1=\"\`hostname\`:\`whoami\`> \"" > ~/.profile
}

# Descr: Setup scripts on an installation host.
# Parameters: 
setup_scripts_install() {
  echo "$prfx Setup scripts on install host ..."
  [[ -z $script_path_install ]] && die_msg -h -l $LINENO "No script path given."
}

####################################################################################################################
src_dir=`dirname $0`
echo "$prfx Started: "`date +%Y%m%d`"T"`date +%H%M%S`
echo "$prfx Command line: $0 $@"

# Parse command line into arguments
parse_commandline $@
# Check if config-file exists
[[ (-n $config_file) && (! -r $config_file) ]] && die_msg -e 3 -l $LINENO "Config-file ${config_file} cannot be read."
[[ -z $vcs_type ]] && vcs_type="spicm"

## Add extra info to prefix  
[[ $proc_inst = true || $proc_build -eq true ]] && prfx=$prfx"["
[[ $proc_inst = true ]] && prfx=$prfx"I"
[[ $proc_build = true ]] && prfx=$prfx"B"
[[ $proc_inst = true || $proc_build -eq true ]] && prfx=$prfx"] "

## Make sure admin has a matching project directory name
if [[ $user_name = *adm ]];then
  [[ ${proj_home##/*/} != ${user_name%adm} ]] && die_msg -e 2 -l $LINENO "Project-dir must be ${user_name%adm} for project admin $user_name."
fi

##
## Handle switches
##

if [[ $oracheck_build = true ]];then  
  # Check Oracle
  check_oracle;sts=$?
  [[ $sts -eq 0 ]] && echo "$prfx   Oracle is running OK" || die_msg -e $sts -l $LINENO "Oracle isn't running - return code: $sts"

  # Unlock locked Oracle-accounts
  unlock_oracle_accounts;sts=$?
  [[ $sts -ne 0 ]] && die_msg -e $sts -l $LINENO "Failed unlocking Oracle-accounts."
fi

if [[ $precheck_build = true ]];then  
  # Need include file here
  [[ -e $proj_home/$user_name/autobuild/auto/auto_common.ksh ]] && . $proj_home/$user_name/autobuild/auto/auto_common.ksh

  # Check accounts on build machine
  check_ad_account oracle dba $pwd_oracle_build
  
  # Check Oracle
  check_oracle;sts=$?
  [[ $sts -eq 0 ]] && echo "$prfx   Oracle is running OK" || die_msg -e $sts -l $LINENO "Oracle isn't running - return code: $sts"
fi

if [[ $prep_build = true ]];then
  ## Setup scripts on build machine
  setup_scripts_build
fi

if [[ $precheck_install = true ]];then
  # Check accounts on install machine
  check_ad_account oracle dba $pwd_oracle_install
  pwd=""
  [[ $server_type_group = SCADA ]] && pwd=$pwd_scada || pwd=$pwd_udw
  check_ad_account $user_name $group_name $pwd

  # Check the confdb lock file
  [[ -f /usr/local/config/db/\#confdb\# ]] && die_msg -l $LINENO "Confdb-file is locked. Close the application that uses confdb, or wait until it is unlocked, or remove /usr/local/config/db/#confdb#."
fi

if [[ $prep_install = true ]];then
  ## Setup script on install machine
  setup_scripts_install
fi

if [[ $init_build = true ]];then
  setup_scripts
  #setup_scripts_build
fi

if [[ $init_install = true ]];then
  setup_scripts
  setup_scripts_install
fi

if [[ $remove_build = true ]];then
  ## Remove project directory-files
  remove_proj_files
fi

if [[ $remove_install = true ]];then
  ## Check if Netman is stopped
  check_netman $user_name

  ## Remove Netman-users
  remove_user $user_name
fi

if [[ $recreate_build = true ]];then
:;
fi

if [[ $recreate_install = true ]];then
  ## Re-create Netman-user directories
  create_user_install $user_name $group_name
fi
  
echo "$prfx Ended: "`date +%Y%m%d`"T"`date +%H%M%S`
exit 0