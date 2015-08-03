#!/bin/sh

export NODE_NAME=`hostname`
export PATH=$PATH:.
export DISABLE_SUPERVISION=${DISABLE_SUPERVISION:=false}
export ENABLE_SUPERVISION=${ENABLE_SUPERVISION:=false}
export STOP_ENGINES=${STOP_ENGINES=false}
export START_ENGINES=${START_ENGINES=false}
export UNTAR=${UNTAR:=false}
export DBUPGRADE=${DBUPGRADE:=false}
export ENABLESOI=${ENABLESOI:=false}
export ENABLEAMI=${ENABLEAMI:=false}
export DB_OPTION_ISR=${DB_OPTION_ISR:=false}
export DB_OPTION_UFT8=${DB_OPTION_UFT8:=false}
#
# There can be only MWM triggers (ComED date) or MDT triggers not both
# 
export DB_OPTION_MWM_triggers=${DB_OPTION_MWM_triggers:=false}
export DB_OPTION_MDT_triggers=${DB_OPTION_MDT_triggers:=false}



export DATE=`date +%H%M%S`;

function testcmd {
    "$@"
    status=$?
    if [ $status -ne 0 ]; then
        echo "error with $1"
        exit $status
    fi
    return $status
}


if [[ $DB_OPTION_MWM_triggers = "true" ]] && [[ $DB_OPTION_MDT_triggers = "true" ]];then
  echo both trigger options cannot be true
  exit 1
fi



export uname_os=`uname`
if [[ "AIX" = $uname_os ]]
then
    export OS=aix
elif [[ "Linux" = $uname_os ]]
then
    export OS=linux
elif [[ "HP-UX" = $uname_os ]]
then
    export OS=HP-UX
else
    echo Error $uname_os not programmed yet
fi

if [ ! -e $BUILD_ROOT/cm/$ENV_FILE ]
then
   echo ENV_FILE $BUILD_ROOT/cm/$ENV_FILE not found
   exit 1
fi
. $BUILD_ROOT/cm/$ENV_FILE


export string=`grep build.version $BUILD_ROOT/java/build.properties`
export VERSION=$(echo "$string"|sed 's/^build.version=\(DMS.*[0-9].[0-9].[0-9].[0-9].[0-9]*\).*/\1/')
echo Current VERSION is $VERSION
export VERSION_NUMBER=$(echo "$VERSION"|sed 's/\(.*\).[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9].*/\1/')
echo Current VERSION_NUMBER is $VERSION_NUMBER 

export VERSION_ONLY=$(echo "$VERSION_NUMBER"|sed 's/\DMS\.\(.*\)/\1/')
echo Current VERSION_ONLY is $VERSION_ONLY

export DATESTRING=$(echo "$VERSION"|sed 's/.*.\([0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\).*/\1/')
echo DATESTRING is $DATESTRING

export dmsbuild=`ls -ltr $SHIPDIR/ABB-NMDMS-SERVER-${OS}-${VERSION_ONLY}.*.tar.Z | tail -1 | awk '{ print $NF }'`
export dmstestbuild=`ls -lrt $SHIPDIR/test*${VERSION_ONLY}*.tar |tail -1 | awk '{ print $NF }'`
export dms3rdparty=`ls -lrt $SHIPDIR/../ABB-NMDMS-THIRDPARTY-${VERSION_ONLY}.*.tar | tail -1 | awk '{ print $NF }'`

echo "Server tar file $dmsbuild"
echo "test binaries file $dmstestbuild"
echo "thirdparty file $dms3rdparty"

#  This doesn't always work.  
#export diskusage=`df -h $ENV_DIR| tail -1|awk '{ print $4}'|sed 's/%//'`

function log_notice {

  echo
  echo
  echo "========================================"
  echo " $1   `date` "
  echo "========================================"
  echo

}

echo Deployment step variables.  
 
echo
echo ENV_DIR $ENV_DIR
echo ENV_FILE $ENV_FILE
echo SHIPDIR $SHIPDIR
echo DISABLE_SUPERVISION $DISABLE_SUPERVISION
echo ENABLE_SUPERVISION $ENABLE_SUPERVISION
echo STOP_ENGINES $STOP_ENGINES
echo START_ENGINES $START_ENGINES
echo UNTAR $UNTAR
echo DBUPGRADE $DBUPGRADE
echo ENABLESOI $ENABLESOI
echo ENABLEJAVA $ENABLEJAVA

echo DB_OPTION_ISR ${DB_OPTION_ISR}
echo DB_OPTION_UFT8 ${DB_OPTION_UFT8}
echo DB_OPTION_MWM_triggers ${DB_OPTION_MWM_triggers}
echo DB_OPTION_MDT_triggers ${DB_OPTION_MDT_triggers}


if [[ $DISABLE_SUPERVISION = "true" ]]; then
  log_notice "Disable running system supervision on $HOSTNAME"
  crontab -l| sed '/^*/s/^/#/' | crontab -
  cd $CADOPS_MAIN
  sh $CADOPS_MAIN/stopdms1
  sh $CADOPS_MAIN/cleanshmdms
  sh $CADOPS_MAIN/stopmds
  log_notice " Stopped all Engines  $HOSTNAME"
fi

if [[ $STOP_ENGINES = "true" ]]; then
  log_notice " Stoping All running Engines for $HOSTNAME"
  cd $CADOPS_MAIN
  sh $CADOPS_MAIN/stopdms1
  sh $CADOPS_MAIN/cleanshmdms
  sh $CADOPS_MAIN/stopmds
  log_notice " Stopped all Engines on $HOSTNAME"
fi

if [[ $UNTAR = "true" ]]; then

#  if [ $diskusage -gt 95 ]
#  then
#     log_notice "Running out of space "
#     mail -s "!!!!!!!!!!!!! WARNING $ENV_DIR running out of space !!!!!!!!!!!!!!!!!!!" cms.dms.build@ventyx.abb.com
#     exit 1
#  fi

  log_notice "------- untaring $dmsbuild to $HOSTNAME "
  mv $CADOPS_HOME $CADOPS_HOME"_PrevRel_"$DATE
  mkdir $CADOPS_MAIN/logs/oldlogs_$DATE
  mv $CADOPS_MAIN/logs/*log ${CADOPS_MAIN}/logs/oldlogs_$DATE
  mkdir -p $CADOPS_HOME
  testcmd tar xzvf $dmsbuild -C ${CADOPS_HOME}/ > $CADOPS_MAIN/logs/cadops_tar.log
  log_notice "------- untaring $dmstestbuild to $HOSTNAME "
  testcmd tar xvf $dmstestbuild -C ${CADOPS_HOME}/ >> $CADOPS_MAIN/logs/cadops_tar.log
  log_notice "------- untaring $dms3rdparty to $HOSTNAME "
  testcmd tar xvf $dms3rdparty -C ${CADOPS_HOME}/ >> $CADOPS_MAIN/logs/cadops_tar.log
  log_notice "------- untaring completed "
  rm -rf $CADOPS_HOME"_PrevRel_"$DATE
fi

if [[ $ENABLESOI = "true" ]]; then
 if [ -e $BUILD_ROOT/cm/$project_user/mdsproxy_config.properties ]
 then
   log_notice "------ Copying config.properties for SOI "
   cp $BUILD_ROOT/cm/$project_user/mdsproxy_config.properties $CADOPS_HOME/java/dist/mdsProxy/config.properties
 fi
fi

if [[ $ENABLEJAVA = "true" ]]; then
 log_notice "------------- Copying java config files to there locations"
 if [ -e $BUILD_ROOT/cm/$project_user/ami_rv_config.properties ]
 then
   log_notice "------ Copying ami_rv_config.properties for AMI "
   cp $BUILD_ROOT/cm/$project_user/ami_rv_config.properties $CADOPS_HOME/java/dist/ami/config.properties
 fi
 if [ -e $BUILD_ROOT/cm/$project_user/ami_unsol_config.properties ]
 then
   log_notice "------ Copying ami_unsol_config.properties for AMI "
   cd $CADOPS_HOME/java/dist/
   cp -rpf ami ami2
   cp $BUILD_ROOT/cm/$project_user/ami_unsol_config.properties $CADOPS_HOME/java/dist/ami2/config.properties
 fi
 if [ -e $BUILD_ROOT/cm/$project_user/avl_config.properties ]
 then
   log_notice "------ Copying avl_config.properties for AVL "
   cp $BUILD_ROOT/cm/$project_user/avl_config.properties $CADOPS_HOME/java/dist/avl/config.properties
 fi
 if [ -e $BUILD_ROOT/cm/$project_user/s2d_config.properties ]
 then
   log_notice "------ Copying s2d_config.properties for S2D "
   cp $BUILD_ROOT/cm/$project_user/s2d_config.properties $CADOPS_HOME/java/dist/s2d/config.properties
 fi
 if [ -e $BUILD_ROOT/cm/$project_user/load_profile_config.properties ]
 then
   log_notice "------ Copying load_profile_config.properties  for LOADPROFILE "
   cp $BUILD_ROOT/cm/$project_user/load_profile_config.properties $CADOPS_HOME/java/dist/LoadProfile/config.properties
 fi
 if [ -e $BUILD_ROOT/cm/$project_user/weather_config.properties ]
 then
   log_notice "------ Copying weather_config.properties  for WEATHER "
   cp $BUILD_ROOT/cm/$project_user/weather_config.properties $CADOPS_HOME/java/dist/weather/config.properties
 fi
fi



if [[ $DBUPGRADE = "true" ]]; then
  log_notice "------- Removing all invalids before starting upgrade"
  export DROPFILE=/tmp/spool.sql
  for connection in "$ASTORM" "$ASTATUS" "$ADMIN" "$NETC" "$CTS";
  do
    sh $CADOPS_HOME/upgrade/db/create_db/recompile.sh $connection
    sqlplus  $connection @$BUILD_ROOT/cm/preupgrade_drop_invalid.sql
    echo "exit;" >>$DROPFILE
    sqlplus $connection @$DROPFILE
  done

  if [[ $DB_OPTION_ISR = "true" ]];then
    sh $CADOPS_HOME/upgrade/db/create_db/recompile.sh ${ISR}
    sqlplus  ${ISR} @$BUILD_ROOT/cm/preupgrade_drop_invalid.sql
    echo "exit;" >>$DROPFILE
    sqlplus ${ISR} @$DROPFILE
  fi

  if [[ $DB_OPTION_MWM_triggers = "true" ]];then
    echo " ======================================================================================= "
    echo "Applying mobile integration triggers <md_link> ...  "
    echo " "
    cd $CADOPS_HOME/upgrade/db/create_db/astorm/features/MWM_support/trigs
    sh uninstall_MWM.sh ${ASTORM}
    sh install_MWM.sh ${ASTORM}
  fi

  if [[ $DB_OPTION_MDT_triggers = "true" ]];then
    echo " ======================================================================================= "
    echo "Applying mobile integration triggers <md_link> ...  "
    echo " "
    cd ${CADOPS_HOME}/upgrade/db/create_db/astorm/features/mds_link/trigs
    uninstall_mds_link.sh ${ASTORM}
    install_mds_link.sh ${ASTORM}
  fi

  log_notice "------ Running the database upgrade for $ENV_DIR "
  sh $BUILD_ROOT/cm/upgrade_dms.sh
  log_notice " ---- Database upgrade completed for $ENV_DIR"
fi

if [[ $ENABLE_SUPERVISION = "true" ]]; then
  log_notice "------- Enable running system supervision on $HOSTNAME "
  crontab -l | sed "/^#/s/^#//" | crontab -
fi

if [[ $START_ENGINES = "true" ]]; then
  log_notice "------- Starting All Engines for $HOSTNAME"
  cd $CADOPS_MAIN
  sh $CADOPS_MAIN/startdms1
  export CheckEngines=`ps -ef |grep dms1 |grep "$CADOPS_HOME"/bin | grep -v grep |awk '{printf ("%s:%s\n",$2,$8)}' `
  if [[ "$CheckEngines" ]] ; then
    echo " ####################################"
    echo "      The dms engines are running: "
    echo " ####################################"
  else
    echo " ####################################"
    echo " Engines's are not running, lets start"
    echo " ####################################"
    cd $CADOPS_MAIN
    sh $CADOPS_MAIN/startdms1
  fi
fi


export MAILFILE=$WORKSPACE/invalids.txt
if [ -e "$MAILFILE" ]
then
   rm -rf $MAILFILE
fi

echo 
echo "|--------------------------------------------------------------------------------------" >> $MAILFILE
echo "###### Invalid Objects after upgrade for $dmsbuild Build ###### " >> $MAILFILE
sh $CADOPS_MAIN/scripts/invalids.sh >> $MAILFILE
cat $MAILFILE 


