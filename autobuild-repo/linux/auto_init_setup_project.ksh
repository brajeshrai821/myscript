#!/bin/ksh
# File:       auto_init_setup_project.ksh
# Descr:      Initialization-script for autobuild environment.
#             Project setup.
# Parameters: Check out die_msg().
# Returns:    0 if ok; otherwise error.
# History:    2009-12-09 Anders Risberg       Initial version. Moved from auto_init_setup.ksh.
#             2010-06-05 Anders Risberg       Release 1.2.19.
#             2010-11-26 Anders Risberg       Incorporated auto_init_project_setup.ksh to project setup.
#                                             Using confm to update DevConf confdb directly instead of
#                                               via templaed and sed.
#                                             Running configProj looped and with parameters from
#                                               configuration.
#             2010-12-13 Anders Risberg       Enhanced die_msg; added line number; partly moved to auto_common.ksh.
#
#_DEBUG="on"
prfx="#[$(basename $(readlink -nf $0))]>";

####### Helper functions #######
. ~/autobuild/auto/auto_common.ksh

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
    echo " --init                 Initiate."
    echo " --build                Build."
  fi
  exit $err_code
}

# Descr: Parse command line into arguments.
# Parameters: <parameter-list>
parse_commandline() {
  [[ $# -lt 1 ]] && die_msg -l $LINENO "Option or parameter missing."

  config_file=""
  show_config=false
  init=false
  build=false

  while true;do
    case $# in 0) break;; esac
    case $1 in
      -c) shift; # Read common settings from configuration file
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && config_file=$1
        [[ -f $config_file ]] && rconf $config_file "main"
        [[ -f $config_file ]] && rconf $config_file "common"
        [[ -f $config_file ]] && rconf $config_file "init_common"
        [[ -f $config_file ]] && rconf $config_file "build_common"
        shift;;
      --show_config) shift; # Show config-file parameters
        show_config=true;;
      --init) shift; # Initiate
        init=true;;
      --build) shift; # Build
        build=true;;

      -|--) shift; break;;
      -h|--help) die_msg -h -e 0;;
      -*) die_msg -e 2 -l $LINENO "Invalid option $1.\nTry $0 --help to see available options.";;
      *) die_msg -e 2 -l $LINENO "Invalid option $1.\nTry $0 --help to see available options.";;
    esac
  done
}

####### Script specific functions #######

# Descr: Start project setup - initialization.
# Parameters: 
project_setup_init() {
  echo "$prfx  Project setup - init ..."  
  [[ -z $user_name ]] && die_msg -h -l $LINENO "No user name given."
  #[[ -z $script_init_path ]] && die_msg -h -l $LINENO "No script initiation path given."
  [[ -z $script_path_build ]] && die_msg -h -l $LINENO "No build script path given."
  [[ -z $runcons_path ]] && die_msg -h -l $LINENO "No runcons dconf path given."
  [[ ! -d $runcons_path ]] && die_msg -h -l $LINENO "No runcons dconf found ($runcons_path)."
  [[ -z $confdb_prod_path ]] && die_msg -h -l $LINENO "No confdb product file path given."
  [[ ! -f $confdb_prod_path ]] && die_msg -h -l $LINENO "No confdb product file found ($confdb_prod_path)."
  [[ -z $oracle_base_path ]] && die_msg -h -l $LINENO "No oracle base path given."
  [[ -z $oracle_prod_path ]] && die_msg -h -l $LINENO "No oracle product directory given."
  [[ ! -d $oracle_base_path/$oracle_prod_path ]] && die_msg -h -l $LINENO "No oracle product directory found ($oracle_base_path/$oracle_prod_path)."
  [[ -z $baseline_path ]] && die_msg -h -l $LINENO "No baseline path given."
  [[ ! -d $baseline_path ]] && die_msg -h -l $LINENO "No baseline found ($baseline_path)."
  [[ -z $de400_db_name ]] && die_msg -h -l $LINENO "No DE400 database name given."
  [[ -z $de400_db_user ]] && die_msg -h -l $LINENO "No DE400 database user given."
  [[ -z $de400_db_pwd ]] && die_msg -h -l $LINENO "No DE400 database password given."
  [[ -z $his_db_name ]] && die_msg -h -l $LINENO "No HIS database name given."
  [[ -z $his_db_user ]] && die_msg -h -l $LINENO "No HIS database user given."
  [[ -z $his_db_pwd ]] && die_msg -h -l $LINENO "No HIS database password given."

  # Parts below taken from the 'project_setup'- and 'dconf_configure'-scripts
  prod_anchor=$HOME
  [[ -n ${PROJHOME} ]] && prod_anchor=$PROJHOME
  [[ ! -d $prod_anchor/config ]] && mkdir $prod_anchor/config
  SPILD=$runcons_path/TOOL/usr/local/config/scripts/spild
  #CONFIG=`eval echo $script_init_path/auto_init_dconf_configure.ksh`
  CONFIG=`eval echo $script_path_build/auto_init_dconf_configure.ksh`
  kitname=`basename \`ls -d $runcons_path/KITS/*_DCONF_*\``
  $SPILD -m install -k $runcons_path/KITS -n $kitname -a $prod_anchor -p config
  # Clean up and remove dummy files
  rm -f $prod_anchor/config/*/DUMMY
  # Perform the configure phase
  $CONFIG false # Do not run devconf
  # End of 'project_setup'- and 'dconf_configure'-scripts
  
  CONFM=/usr/local/bin/confm
  CONFDB=~/config/db/confdb
  cp -f $confdb_prod_path $CONFDB
  trdprods=`$CONFM -f $CONFDB get release/trdprod/`
  for i in ${trdprods[@]};do
    echo "TrdProd - $i"
    $CONFM -f $CONFDB add release/trdprod/${i}pathname $oracle_base_path/$oracle_prod_path
    pn=`$CONFM -f $CONFDB get release/trdprod/${i}pathname`
    echo "pathname=$pn"
  done

  $CONFM -f $CONFDB add release/path/PROJRELPATH $proj_home/$user_name/spiroot
  $CONFM -f $CONFDB add release/path/BASERELPATH $baseline_path/spiroot
  $CONFM -f $CONFDB add release/params/DE400DATABASE $de400_db_name
  $CONFM -f $CONFDB add release/params/DE400PASSWD $de400_db_pwd
  $CONFM -f $CONFDB add release/params/DE400USERNAME $de400_db_user
  $CONFM -f $CONFDB add release/params/HISDATABASE $his_db_name
  $CONFM -f $CONFDB add release/params/HISPASSWD $his_db_pwd
  $CONFM -f $CONFDB add release/params/HISUSERNAME $his_db_user
  
  ~/config/scripts/editAndLinkProjFiles $baseline_path
  trdprods=`$CONFM -f $CONFDB get release/trdprod/`
  for i in ${trdprods[@]};do
    echo "${i%?}"
    ~/config/scripts/configProj -a ${i%?} $oracle_base_path/$oracle_prod_path
  done

  sed -i "s/IRDE_DATABASE=$/IRDE_DATABASE="$de400_db_name"/g" ~/bin/grplogin
  sed -i "s/IRDE_USER=$/IRDE_USER="$de400_db_user"/g" ~/bin/grplogin
  sed -i "s/IRDE_PASSWD=$/IRDE_PASSWD="$de400_db_pwd"/g" ~/bin/grplogin
  sed -i "s/HIS_DATABASE=$/HIS_DATABASE="$his_db_name"/g" ~/bin/grplogin ## Här var his
  sed -i "s/HIS_USER=$/HIS_USER="$his_db_user"/g" ~/bin/grplogin
  sed -i "s/HIS_PASSWD=$/HIS_PASSWD="$his_db_pwd"/g" ~/bin/grplogin
}

# Descr: Start project setup - build modules.
# Parameters: 
project_setup_build() {
  echo "$prfx  Project setup - build modules ..."
  [[ -z $baseline_path ]] && die_msg -h -l $LINENO "No baseline path given."

  . ~/.profile
  BASEREL=$baseline_path/spiroot/
  export BASEREL
  ~/config/scripts/build_all_modules.ksh db_new_selection
  ~/config/scripts/build_spitop.ksh db_new_selection
  ~/config/scripts/create_spiroot.ksh
}

####################################################################################################################
src_dir=`dirname $0`
echo "$prfx Started: "`date +%Y%m%d`"T"`date +%H%M%S`
echo "$prfx Command line: $0 $@"

# Parse command line into arguments
parse_commandline $@
# Check if config-file exists
[[ (-n $config_file) && (! -r $config_file) ]] && die_msg -e 3 -l $LINENO "Config-file ${config_file} cannot be read."

## Start Project Setup - init
[[ $init = true ]] && project_setup_init

## Start Project Setup - build modules
[[ $build = true ]] && project_setup_build

echo "$prfx Ended: "`date +%Y%m%d`"T"`date +%H%M%S`
exit 0