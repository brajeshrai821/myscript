#!/bin/ksh
# File:       auto_netman_kits_make.ksh
# Descr:      Checks out, compiles, links, and builds kits.
# Parameters: Check out die_msg().
# Returns:    0 if ok; otherwise error.
# History:    2009-07-01 Anders Risberg       Initial version.
#             2010-06-05 Anders Risberg       Release 1.2.19.
#             2010-11-26 Anders Risberg       Added TFS-checkout.
#                                             Generalized way to find module directories
#                                               in spiroot.
#             2010-12-13 Anders Risberg       Enhanced die_msg; added line number; partly moved to auto_common.ksh.
#             2010-12-16 Anders Risberg       Added parameter mkde_install_nmdms_if for de400_setup.pl.
#                                             Only run make_libs_local when do_make.
#                                             Also do 'moddef -c' when re-linking all modules.
#             2011-01-12 Anders Risberg       Added to $script_path_build to auto_conbld.ksh-path.
#             2011-02-17 Anders Risberg       Always accepting tf EULA before 'get latest'.
#                                             Change dir to user-root in checkout_tfs_cleanup.
#             2011-03-02 Anders Risberg       Encapsulated TFS commandline parameters.
#             2011-04-01 Anders Risberg       TFS: get latest directly to spiroot. Renames old spiroot.
#             2011-04-06 Anders Risberg       Relink spiroot during make only.
#             2011-04-26 Anders Risberg       Removed total/incremental on checkout-logs.
#             2011-08-11 Anders Risberg       Added switch for module creation.
#                                             Moved making of libraries local to build step.
#                                             Removed switch no_module_rebuild.
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
  if [[ $help = true ]]; then
    echo
    echo "Synopsis: $(basename $(readlink -nf $0)) option"
    echo "Options:"
    echo " -c path                Configuration file (overridden by subsequent parameters)."
    echo " --show_config          Show config-file parameters."
    echo " --clean                Perform a make clean before build."
    echo " --crmod                Create modules."
    echo " --cleanmod             Re-create modules (delete first)."
    echo " -o|--co                Perform a checkout."
    echo " -m|--make              Do make."
    echo " -k|--build_kits        Autobuild kits."
    echo " --no_module_rebuild    Not re-build or re-link modules."
    echo " -p|--proj name         Project name."
    echo " -x|--context name      Context name."
    echo " -d|--check_days n      Check n days back for newly checked in code."
  fi
  
  # Clean-up
  [[ $vcs_type = spicm ]] && checkout_spicm_cleanup true
  [[ $vcs_type = tfs ]] && checkout_tfs_cleanup true
  exit $err_code
}

# Descr: Parse command line into arguments.
# Parameters: <parameter-list>
parse_commandline() {
  [[ $# -lt 1 ]] && die_msg -l $LINENO "Option or parameter missing."

  config_file=""
  proj=""
  context=""
  show_config=false
  co_days=10 # Number of days back to test for checkout
  do_clean=false
  do_crmod=false
  do_cleanmod=false
  do_checkout=false
  do_make=false
  do_kitbuild=false

  while true;do
    case $# in 0) break;; esac
    case $1 in
      -c) shift; # Read common settings from configuration file
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && config_file=$1
        [[ -f $config_file ]] && rconf $config_file "main"
        [[ -f $config_file ]] && rconf $config_file "common"
        [[ -f $config_file ]] && rconf $config_file "build_common"
        shift;;
      --show_config) shift; # Show config-file parameters
        show_config=true;;
      --clean) shift; # Clean
        do_clean=true;;
      --crmod) shift; # Create modules
        do_crmod=true;;
      --cleanmod) shift; # Re-create modules (delete first)
        do_cleanmod=true;;
      -o|--co) shift; # Checkout
        do_checkout=true;;
      -m|--make) shift; # Do make
        do_make=true;;
      -k|--build_kits) shift; # Build kits
        do_kitbuild=true;;
      -d|--check_days) shift; # Set checkout days
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && co_days=$1 && shift;;
      -p|--proj) shift; # Project
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && proj=$1 && shift;;
      -x|--context) shift; # Context
        [[ -n $1 && ! "${1:0:1}" = "-" ]] && context=$1 && shift;;
      -|--) shift; break;;
      -h|--help) die_msg -h -e 0;;
      -*) die_msg -e 2 -l $LINENO "Invalid option $1.\nTry $0 --help to see available options.";;
      *) die_msg -e 2 -l $LINENO "Invalid option $1.\nTry $0 --help to see available options.";;
    esac
  done
}

####### Script specific functions #######

# Descr: Keep a number of the latest logfiles
# Parameters: <path> [<num_to_keep>]
#             path         Directory path and matching part of file name .Use '@' as wildcard in pattern to match.
#             num_to_keep  Nr to keep of latest.
prune_log() {
  typeset -l tokeep lcount heads
  tokeep=3
  typeset var filemask=`echo "$1" | sed -e "s!@!*!g"`
  [[ -n $2 ]] && tokeep=$2
  [ -f $filemask ] || return
  /bin/ls -tr $filemask >~/prune_log.tmp
  lcount=`cat ~/prune_log.tmp | wc -l | sed -e "s/ //g"`
  let heads=$lcount-$tokeep
  if [[ $heads > 0 ]];then
    echo "$prfx Remove `cat ~/prune_log.tmp | head -$heads | wc -l` files of $lcount"
    [[ $heads >0 ]] && cat ~/prune_log.tmp | head -$heads | awk '{printf("rm %s \n",$1)}' | ksh
  fi
  rm ~/prune_log.tmp
}

# Descr: Setup log-file and file-mask to be used when comparing post-make.
# Parameters: 
setup_logging() {
  make_date=`date +%C%y%m%dT%H%M`
  
  # Setup make log-file name
  if [[ $do_make = true ]];then
    if [[ $do_clean = true ]];then
      make_logfile=total_${make_date}.log
      file_mask="auto_make_total_@.log"
    else
      make_logfile=incremental_${make_date}.log
      file_mask="auto_make_incremental_@.log"
    fi
    log_make=$logfile_path/auto_make_$make_logfile
  fi

  # Setup other log-file names
  [[ $do_checkout = true ]] && log_checkout=$logfile_path/auto_checkout_${make_date}.log
  [[ $do_kitbuild = true ]] && log_conbld=$logfile_path/auto_conbld_${make_date}.log

  # Keep only a few generations of log-files
  echo "$prfx Pruning old logs ..."
  prune_log $logfile_path/auto_make_total_@.log 3
  prune_log $logfile_path/auto_make_incremental_@.log 3
  prune_log $logfile_path/auto_checkout_@.log 2
  prune_log $logfile_path/auto_conbld_@.log 2
}

# Descr: Re-create spiroot modules in case we are not admin.
# Parameters: 
recreate_modules() {
  echo "$prfx Re-create spiroot modules in case we are not admin ..."
  if [[ $do_cleanmod = true ]];then
    echo "$prfx   Re-creating all modules due to clean ..."
    for mod_name in $(/bin/ls $SPI_TOP);do
      echo "$mod_name"
      echo "$mod_name" | awk '{printf("moddef -d %s;moddef -c %s;moddef -ll %s\n",$1,$1,$1)}'| ksh
    done
    echo "$prfx     Done re-creating all modules"
  else
    echo "$prfx   Creating all modules ..."
    for mod_name in $(/bin/ls $SPI_TOP);do
      echo "$mod_name"
      echo "$mod_name" | awk '{printf("moddef -c %s;moddef -ll %s\n",$1,$1)}'| ksh
    done
    echo "$prfx     Done creating all modules."
  fi
}

# Descr: Make libraries local.
# Parameters: 
make_libs_local() {
  echo "$prfx   Make libraries local ..."
  if [[ $is_admin = true ]];then
    lib_dir=`find $projadm_path/spiroot/ -maxdepth 3 -type d -name 'lib'`
    num=`echo $lib_dir|wc -l`
    [[ $num -gt 1 ]] && die_msg -l $LINENO "Too many directories found when looking for 'lib'."
    [[ $num -lt 1 ]] && die_msg -l $LINENO "Directory 'lib' not found."
    rm -f $lib_dir/library/mandesc
  fi
  moddef -d lib
  moddef -c lib
  moddef -ll lib
  cd ../library && mklocal *.so *.a
  echo "$prfx     Done making libraries local"
}

# Descr: Check out all files from spicm-repository.
# Parameters: 
checkout_spicm() {
  echo "$prfx Checkout files from spicm-repository ..."
  
  # Disallow kit build before checkout is done.
  echo "# Checkout latest version - started "`date +%Y%m%d`"T"`date +%H%M%S` >$check_out_lock_file
  echo -e "# Checkout latest version - started "`date +%Y%m%d`"T"`date +%H%M%S` | tee -a $log_checkout
  echo "$prfx   Check $log_checkout for status ..."

  # Checkout to already checked out dirs
  co_dirs=`/bin/ls $cmrep_path/CVSTOP|grep -v -E "CVSROOT|SPICM"`
  for mod_name in $(echo $co_dirs);do
    if [[ -d $admcm_path/$mod_name/source ]];then
      moddef $mod_name
      #echo "-------- Checkout module $mod_name ---- "`date +%Y%m%d`"T"`date +%H%M%S`" " >>$log_checkout
      spicm co "*" >>$log_checkout 2>&1
    fi
  done

  echo "# Checkout latest version - ended "`date +%Y%m%d`"T"`date +%H%M%S` | tee -a $log_checkout
  checkout_spicm_cleanup
}

# Descr: Clean up after checkout from spicm-repository.
# Parameters: <true> if originated from exception; otherwise empty
checkout_spicm_cleanup() {
  [[ $# -lt 1 ]] && excep=false || excep=true
  # Allow kit build
  rm -f $check_out_lock_file
}

# Descr: Get all latest files from TFS-repository.
# Parameters: 
checkout_tfs() {
  echo "$prfx Get latest files from TFS-repository ..."
  [[ -z $tfs_cmdpath ]] && die_msg -h -l $LINENO "No TFS command path given."
  [[ ! -e $tfs_cmdpath ]] && die_msg -h -l $LINENO "TFS command ($tfs_cmdpath) cannot be found."
  [[ -z $tfs_url ]] && die_msg -h -l $LINENO "No TFS URL given."
  [[ -z $tfs_domain ]] && die_msg -h -l $LINENO "No TFS user domain name given."
  [[ -z $tfs_user ]] && die_msg -h -l $LINENO "No TFS user name given."
  [[ -z $tfs_pwd ]] && die_msg -h -l $LINENO "No TFS user password given."
  [[ -z $tfs_project ]] && die_msg -h -l $LINENO "No TFS project given."
  [[ -z $tfs_root ]] && die_msg -h -l $LINENO "No TFS root directory given."
  [[ -z $tfs_branch ]] && die_msg -h -l $LINENO "No TFS branch name given."

  # Disallow kit build before checkout is done.
  echo "# Get latest version (TFS) - started "`date +%Y%m%d`"T"`date +%H%M%S` >$check_out_lock_file
  echo -e "# Get latest version (TFS) - started "`date +%Y%m%d`"T"`date +%H%M%S` | tee -a $log_checkout
  
  # Prepare to get the latest files
  tfs_login="$tfs_user@$tfs_domain,$tfs_pwd -noprompt"
  tfs_path="$tfs_root/$tfs_branch"
  tfs_time=`date +%Y%m%d`T`date +%H%M%S%z`
  # Replace spaces with underscore in project-name
  tfs_project=$(echo $tfs_project|sed 's/ /_/g')
  tfs_workspace="`hostname`_${tfs_project}_${tfs_branch}_${tfs_time}"
  tfs_spiroot="spiroot"
  tfs_bak_inx="spiroot_"
  tfs_label="${tfs_domain}_${tfs_user}_${tfs_branch}_${tfs_time}"
  
  echo "$prfx TFS parameters:"
  echo "$prfx   url:                 $tfs_url"
  echo "$prfx   user:                $tfs_user@$tfs_domain"
  echo "$prfx   path (r/b):          $tfs_path"
  echo "$prfx     root:              $tfs_root"
  echo "$prfx     branch:            $tfs_branch"
  echo "$prfx   project:             $tfs_project"
  echo "$prfx   workspace (h_p_b_t): $tfs_workspace"
  echo "$prfx   label (d_u_b_t):     $tfs_label"
  
  # Create a workspace area
  [[ -e "$tfs_spiroot" ]] && mv "$tfs_spiroot" "${tfs_bak_inx}${tfs_time}"
  mkdir "$tfs_spiroot"
  
  # Get the files
  cd "$tfs_spiroot"
  $tfs_cmdpath eula -accept >/dev/null 2>&1;sts=$?
  [[ $sts -ne 0 && $sts -ne 1 ]] && die_msg -l $LINENO "Accepting EULA failed."
  $tfs_cmdpath workspace -new    -s:"$tfs_url" -login:$tfs_login "$tfs_workspace" -comment:"Workspace created by Autobuild "`date +%Y%m%d`"T"`date +%H%M%S%z`". Proj/branch: ${tfs_project}/${tfs_branch}";sts=$?
  [[ $sts -ne 0 ]] && die_msg -l $LINENO "Creating workspace failed."
  tfs_workspace_created=true
  $tfs_cmdpath workfold  -map    -s:"$tfs_url" -login:$tfs_login -workspace:"$tfs_workspace" "$tfs_path" .;sts=$?
  [[ $sts -ne 0 ]] && die_msg -l $LINENO "Mapping workspace failed."
  tfs_workspace_mapped=true
  $tfs_cmdpath label             -s:"$tfs_url" -login:$tfs_login "$tfs_label" "$tfs_path" -child:replace -recursive -comment:"Created by Autobuild. Proj/branch: ${tfs_project}/${tfs_branch}";sts=$?
  [[ $sts -ne 0 ]] && die_msg -l $LINENO "Creating label failed."
  echo "$prfx Get latest source code. Check $log_checkout for status ..."
  $tfs_cmdpath get                           -login:$tfs_login -version:"L$tfs_label">>$log_checkout 2>&1;sts=$?
  [[ $sts -ne 0 ]] && die_msg -l $LINENO -f $log_checkout "Getting latest source failed."
  cd
  
  # Create link to workspace area
  ### ToDo: NOTE! Temporary until TFS scripts are changed not to use spitop
  [[ -h spitop ]] && unlink spitop
  ln -s "$tfs_spiroot" spitop
  
  echo "# Checkout latest version (TFS) - ended "`date +%Y%m%d`"T"`date +%H%M%S` | tee -a $log_checkout
  checkout_tfs_cleanup
}

# Descr: Clean up after checkout from TFS-repository.
# Parameters: <true> if originated from exception; otherwise empty
checkout_tfs_cleanup() {
  [[ $# -lt 1 ]] && excep=false || excep=true
  cd
  if [[ $tfs_workspace_created = true ]];then
    cd "$tfs_spiroot"
    $tfs_cmdpath workfold  -unmap  -s:"$tfs_url" -login:$tfs_login -workspace:"$tfs_workspace" "$tfs_path";sts=$?
    if [[ $sts -ne 0 ]];then
      if [[ $excep = true ]];then
        echo "$prfx Unmapping workspace failed (line $LINENO)."
      else
        die_msg -l $LINENO "Unmapping workspace failed."
      fi
    fi
    tfs_workspace_created=false
    cd
  fi
  if [[ $tfs_workspace_mapped = true ]];then
    cd "$tfs_spiroot"
    $tfs_cmdpath workspace -delete -s:"$tfs_url" -login:$tfs_login "$tfs_workspace";sts=$?
    if [[ $sts -ne 0 ]];then
      if [[ $excep = true ]];then
        echo "$prfx Deleting workspace failed (line $LINENO)."
      else
        die_msg -l $LINENO "Deleting workspace failed."
      fi
    fi
    tfs_workspace_mapped=false
    cd
  fi
  
  # Allow kit build
  rm -f $check_out_lock_file
}

# Descr: Build projects ie. compile and link all source.
# Parameters: 
build_project() {
  echo "$prfx Build the projects (make) ..."
  # Who is project master in two-part project (NEEDED?)
  pname=""
  if [[ -e $projadm_path/bin/projmaster ]];then
    pmaster=`/bin/ls -l $projadm_path/bin/projmaster | awk '{printf("%s\n",$11)}'`

    # Assume that checkout user is the same that build kits although user operates on different projects
    pname=`basename $pmaster`
    check_out_lock_file=$pmaster/$USER/$check_out_lock_file_name
    echo "$prfx   Lockfile for checkout another project: $check_out_lock_file"
  fi

  # Wait for check out ready if it occurs in another machine (NEEDED?)
  typeset -i iMax iWaited
  iMax=5 # Wait for max 5 minutes
  iWaited=0
  while [[ -e $check_out_lock_file && iWaited -lt iMax ]];do
    sleep 60
    DEBUG echo "$prfx   Slept 1 minute "`date +%Y%m%d`"T"`date +%H%M%S`" waiting for check_out lock to go away"
    iWaited=iWaited+1
  done
  [[ iWaited -gt 0 ]] && echo "$prfx   Waited $iWaited minutes for previous checkout job to complete"
  [[ -e $check_out_lock_file ]] && (echo "$prfx   Kit build stopped. Lock file exists.";exit 1)

  # Make libs local
  [[ $vcs_type = spicm && $do_make = true ]] && make_libs_local
  
  # Move to the right place
  moddef jctools
  
  ### Clean ###
  if [[ $do_clean = true ]];then
    echo "$prfx   Make clean - started "`date +%Y%m%d`"T"`date +%H%M%S`
    make -i clean >/dev/null 2>&1
    echo "$prfx   Make clean - ended "`date +%Y%m%d`"T"`date +%H%M%S`
  fi

  echo "$prfx   Make - started "`date +%Y%m%d`"T"`date +%H%M%S`
  echo "$prfx     Check $log_make for status ..."
  make -k >$log_make 2>&1;sts=$?
  #make >$log_make 2>&1;sts=$?
  #[[ $sts -ne 0 ]] && die_msg -l $LINENO -f $log_make "Make failed."
  echo "$prfx   Make - ended "`date +%Y%m%d`"T"`date +%H%M%S`
  
  rm -f $check_out_lock_file
}

# Descr: Build all kits.
# Parameters: 
build_kits() {
  echo "$prfx Build the kits ..."
  # Check some parameters
  #### ToDo NOTE! HARD CODED PRODUCT LIST #####
  product_list="default"
  [[ -z $runcons_name ]] && die_msg -h -l $LINENO "No runcons name given."
  [[ -z $product_list ]] && die_msg -h -l $LINENO "No product list given."
  [[ -z $script_path_build ]] && die_msg -h -l $LINENO "No script path given."

  echo "$prfx Build kits - started "`date +%Y%m%d`"T"`date +%H%M%S`
  echo "$prfx Check $log_conbld for status ..."
  $script_path_build/auto/auto_conbld.ksh $runcons_name $product_list all>$log_conbld 2>&1;sts=$?
  [[ $sts -ne 0 ]] && die_msg -l $LINENO -f $log_conbld "Running auto_conbld.ksh failed."

  # Spide_kit
  echo "$prfx Create spide kit ..."
  moddef de
  rm -f spide_kit_AUTO*.dat
  # Remove spide-dir if it exists. This is normally done interactively in make_de400.pl
  de_dir=`find $projadm_path/spiroot/ -maxdepth 3 -type d -name 'de'`
  num=`echo $de_dir|wc -l`
  [[ $num -gt 1 ]] && die_msg -l $LINENO "Too many directories found when looking for 'de'."
  [[ $num -lt 1 ]] && die_msg -l $LINENO "Directory 'de' not found."
  [[ -d $de_dir/source/spide ]] && rm -rf $de_dir/de/source/spide
  [[ $mkde_install_cadops = true ]] && mkde_install_cadops='y' || mkde_install_cadops='n'
  [[ $mkde_install_facil_plus_if = true ]] && mkde_install_facil_plus_if='y' || mkde_install_facil_plus_if='n'
  [[ $mkde_install_cim_if = true ]] && mkde_install_cim_if='y' || mkde_install_cim_if='n'
  [[ $mkde_install_nmdms_if = true ]] && mkde_install_nmdms_if='y' || mkde_install_nmdms_if='n'
  make_de400="$PROJHOME/${PRIVCTX}root $mkde_install_cadops $mkde_install_facil_plus_if AUTO $mkde_install_cim_if $mkde_use_db $mkde_install_nmdms_if"
  echo "$prfx Running make_de400.pl $make_de400 ..."
  make_de400.pl $make_de400

  echo "$prfx Build kits - ended "`date +%Y%m%d`"T"`date +%H%M%S`
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

[[ -f ~/.profile && -f ~/bin/grplogin ]] && . ~/.profile
export PATH=$PATH:/usr/kerberos/bin:$script_path_build/auto:.

# Check existence of a few parameters
[[ -z $proj ]] && die_msg -h -l $LINENO "No project given."
[[ -z $user_name ]] && die_msg -h -l $LINENO "No user name given."
[[ -z $runcons_name ]] && die_msg -h -l $LINENO "No runcons name given."
[[ -z $mkde_install_cadops ]] && die_msg -h -l $LINENO "No Install Cadopts parameter given."
[[ -z $mkde_install_facil_plus_if ]] && die_msg -h -l $LINENO "No Install Facil Plus parameter given."
[[ -z $mkde_install_cim_if ]] && die_msg -h -l $LINENO "No Install CIM Interface parameter given."
[[ -z $mkde_use_db ]] && die_msg -h -l $LINENO "No Database use parameter given."
[[ -z $script_path_build ]] && die_msg -h -l $LINENO "No script path given."
[[ -z $logfile_path ]] && die_msg -h -l $LINENO "No log-files path given."

# Check if we are running on the admin-account
[[ ${proj}adm = $user_name ]] && is_admin=true || is_admin=false
eval projadm_path=~${proj}adm

# Get the environment if we are not on the admin-account
[[ $is_admin = false ]] && . $projadm_path/bin/grplogin

# Check existence of a few parameters
if [[ $vcs_type = spicm ]];then
  [[ -z $PROJHOME ]] && die_msg -h -l $LINENO "No PROJHOME given. File grplogin missing?"
  [[ -z $PRIVCTX ]] && die_msg -h -l $LINENO "No PRIVCTX given. File grplogin missing?"
fi

# Set a few paths
if [[ $vcs_type = spicm ]];then
  admcm_path=$projadm_path/.${PRIVCTX}cm
  cmrep_path=$projadm_path/CMREP # Path to repository
  runcons_dir=$PROJHOME/$runcons_name # Path to own runcons-dir
fi

# Setup lock file names
if [[ $do_checkout = true || $do_make = true ]];then
  check_out_lock_file_name=autobuild_check_out.lock
  check_out_lock_file=~/$check_out_lock_file_name
fi

# Check if CMSREP exists
if [[ $do_checkout = true ]];then
  if [[ $vcs_type = spicm ]];then
    [[ ! -e $cmrep_path/CVSTOP ]] && die_msg -l $LINENO "CMSREP: $cmrep_path does not exist"
  fi
fi

# Check if runcons-dir exists, otherwise create it
if [[ $vcs_type = spicm ]];then
  [[ ! -e $runcons_dir ]] && mkdir -p $runcons_dir
fi

# Check if log-files-dir exists, otherwise create it
[[ ! -e $logfile_path ]] && mkdir -p $logfile_path

# Setup logging
setup_logging

### Switch to project
if [[ $vcs_type = spicm ]];then
  if [[ -n "$context" ]];then
    echo "$prfx Switch to context $context in project $proj ..."
    [[ ${PROJ} -ne $proj || ${PRIVCTX} -ne $context ]] && proj $kopt -c $context $proj
  else
    echo "$prfx Switch to project $proj ..."
    [[ ${PROJ} -ne $proj ]] && proj $kopt $proj
  fi
fi

### Re-create modules
if [[ $vcs_type = spicm && $do_crmod = true ]];then
  # Re-create spiroot modules in case we are not admin
  recreate_modules
fi

### Checkout ###
if [[ $do_checkout = true ]];then
  [[ $vcs_type = spicm ]] && checkout_spicm
  [[ $vcs_type = tfs ]] && checkout_tfs
  
  # Run initial project setup
  if [[ $vcs_type = tfs ]]; then
    nmtools_dir=`find $projadm_path/spiroot/ -maxdepth 3 -type d -name 'nmtools'`
    num=`echo $nmtools_dir|wc -l`
    [[ $num -gt 1 ]] && die_msg -l $LINENO "Too many directories found when looking for 'nmtools'."
    [[ $num -lt 1 ]] && die_msg -l $LINENO "Directory 'nmtools' not found."
    proj_setup_path=$nmtools_dir/source/initial_project_setup
    [[ ! -x $proj_setup_path ]] && die_msg -l $LINENO "Cannot setup project. Could not find $proj_setup_path."
    $proj_setup_path
    . ~/.profile
  fi
fi

### Make ###
[[ $do_make = true ]] && build_project

### Kits build ###
[[ $do_kitbuild = true ]] && build_kits

echo "$prfx Ended: "`date +%Y%m%d`"T"`date +%H%M%S`
exit 0
