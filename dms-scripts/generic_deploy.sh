#!/bin/sh

function log_notice {

  echo
  echo
  echo "========================================"
  echo " $1   `date` "
  echo "========================================"
  echo

}


if [ ! -d $BUILD_ROOT ]
then
  echo Cannot find BUILD_ROOT: $BUILD_ROOT
  exit 1
fi

if [ ! -d $BUILD_ROOT/cm ]
then
  echo Cannot find cm directory: $BUILD_ROOT/cm
  exit 1
fi

if [ ! -f $BUILD_ROOT/cm/$ENV_FILE ]
then
  echo Cannot find ENV_FILE: $BUILD_ROOT/cm/$ENV_FILE
  exit 1
fi


#Source the env file
log_notice "sourcing the env file $BUILD_ROOT/cm/$ENV_FILE"
. $BUILD_ROOT/cm/$ENV_FILE


export OS=`uname`
export PATH=$PATH:.
export SUPERVISION_NODE=${SUPERVISION_NODE=false]
export STOP_ENGINES=${STOP_ENGINES=false}
export START_ENGINES=${START_ENGINES=false}
export UNTAR=${UNTAR:=false}
export DBUPGRADE=${DBUPGRADE:=false}
export ENABLESOI=${ENABLESOI:=false}
export ENABLEAMI=${ENABLEAMI:=false}
export DATE=`date +%H%M%S`;



if [ $OS = 'Linux' ]
then 
  export dmsbuild=`ls -lrt $SHIPDIR |grep linux |tail -1 | awk '{ print $NF }'`
fi
if [ $OS = 'HP-UX' ]
then
  export dmsbuild=`ls -lrt $SHIPDIR |grep HP-UX |tail -1 | awk '{ print $NF }'`
fi

if [ ! -f $SHIPDIR/$dmsbuild ]
then
  echo Cannot find deployment tar: $SHIPDIR/$dmsbuild
  exit 1
fi



echo Deployment step variables.  
 
echo
echo ENV_DIR $ENV_DIR
echo ENV_FILE $ENV_FILE
echo SHIPDIR $SHIPDIR
echo SUPERVISION_NODE $SUPERVISION_NODE
echo STOP_ENGINES $STOP_ENGINES
echo START_ENGINES $START_ENGINES
echo UNTAR $UNTAR
echo DBUPGRADE $DBUPGRADE
echo ENABLESOI $ENABLESOI
echo ENABLEAMI $ENABLEAMI
echo DISKUSAGE $diskusage 


if [ ! -d $CADOPS_MAIN ]
then
  echo Cannot find dir CADOPS_MAIN: $CADOPS_MAIN
  exit 1
fi

#Updating sym links to script and env file
if [ -f $CADOPS_MAIN/ENV_PROFILE ]; then
  rm $CADOPS_MAIN/ENV_PROFILE
fi
ln -s $BUILD_ROOT/cm/$ENV_FILE $CADOPS_MAIN/ENV_PROFILE 

for file in startdms1.sh statusdms.sh stopmds.sh stopdms1.sh stopalldms.sh cleanshmdms.sh; do
 if [ -f $CADOPS_MAIN/$file ]; then
   rm $CADOPS_MAIN/$file
 fi
 ln -s $BUILD_ROOT/cm/$file $CADOPS_MAIN/$file 
done

if [[ $STOP_ENGINES = "true" ]]; then
 log_notice " Stoping All running Engines for $HOSTNAME"

  sh $CADOPS_MAIN/stopdms1.sh
  sh $CADOPS_MAIN/cleanshmdms.sh
  sh $CADOPS_MAIN/stopmds.sh

fi

if [[ $UNTAR = "true" ]]; then

 log_notice "------- untaring $dmsbuild to $HOSTNAME "
 mv $CADOPS_HOME $CADOPS_HOME"_PrevRel_"$DATE
 mkdir $CADOPS_MAIN/logs/oldlogs_$DATE
 mv $CADOPS_MAIN/logs/*log ${CADOPS_MAIN}/logs/oldlogs_$DATE
 mkdir -p $CADOPS_HOME
 tar xvf $SHIPDIR/$dmsbuild -C ${CADOPS_HOME}/  > $CADOPS_MAIN/logs/cadops_tar.log
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
   log_notice "------ Running the database upgrade for $ENV_DIR "
   sh $CADOPS_HOME/upgrade/db/create_db/upgrade_dms.sh
   log_notice " ---- Database upgrade completed for $ENV_DIR"
fi

#don't start engines if system supervision enabled
if [[ $SUPERVISION_NODE = "false" ]]; then

  if [[ $START_ENGINES = "true" ]]; then
    log_notice "------- Starting All Engines for $HOSTNAME"
    cd $CADOPS_MAIN

    sh $CADOPS_MAIN/startdms1.sh
    export CheckEngines=`ps -ef |grep $USER |grep "$CADOPS_HOME"/bin | grep -v grep |awk '{printf ("%s:%s\n",$2,$8)}' `
    if [[ "$CheckEngines" ]] ; then
      echo " ####################################"
      echo "      The dms engines are running: "
      echo " ####################################"
    else
      echo " ####################################"
      echo " Engines's are not running, lets start"
      echo " ####################################"
      cd $CADOPS_MAIN
      sh $CADOPS_MAIN/startdms1.sh
    fi
  fi
fi

#sh $CADOPS_MAIN/scripts/invalids.sh >> $MAILFILE



