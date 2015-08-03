#!/bin/sh

# Script for Weekly Upgrade #####
###### usage

export NODE_NAME=`hostname`
 export OS=`uname`
 echo "Workspace $WORKSPACE"
 echo "Deployment host $NODE_NAME"
 export PATH=$PATH:.
 export START_ENGINES=${START_ENGINES=false}
 export DATE=`date +%H%M%S`;
 echo
 echo ENV_DIR $ENV_DIR
 echo BUILDDIR $BUILDDIR
 echo START_ENGINES $START_ENGINES
 echo DBUPGRADE $DBUPGRADE
 echo DBLINK $DBLINK
 echo DBLINK2 $DBLINK2
 echo STOP_ENGINES $STOP_ENGINES

 export DEPLOY_LOC=$HOME/deployment
 export DROPFILE=/tmp/spool.sql
 export dmsbuild=`ls -lrt $BUILDDIR | grep aix |tail -1 | awk '{ print $NF }'`
 export DROPFILE=/tmp/spool.sql

cd $ENV_DIR
 . ./.env_dms_astorm

echo $CADOPS_MAIN

export MYASTORM=$ASTORM
export MYADMIN=$ADMIN 

if [[ $STOP_ENGINES = "true" ]]; then
echo "------ Stoping Engines for $district district"
for district in "aub" "sra";
do
        cd $CADOPS_MAIN
        . .env_dms_$district
        sh $CADOPS_MAIN/stopdms1
        sh $CADOPS_MAIN/cleanshmdms
done
fi

############# update script ######
run_script()
{
  export ADM_CONNECTION=$1
  export ASTORM_CONNECTION=$2
  export ASTATUS_CONNECTION=$3
  export CT_CONNECTION=$4
  export AREA=$5
  export DISTRICT_NUM=$6

  cd $HOME
  echo "------- Removing all invalids before starting upgrade for $ASTATUS_CONNECTION " 
  sh $CADOPS_HOME/upgrade/db/create_db/recompile.sh $ASTATUS_CONNECTION
  sqlplus  $ASTATUS_CONNECTION @$DEPLOY_LOC/preupgrade_drop_invalid.sql
  echo "exit;" >>$DROPFILE
  sqlplus $ASTATUS_CONNECTION @$DROPFILE

  cd $CADOPS_MAIN
  . ./.env_dms_$district
  cd $CADOPS_HOME/upgrade/db/create_db
  echo " --------Running cadops_astatus.sh $ASTATUS_CONNECTION $ADM_CONNECTION "
  sh cadops_astatus.sh $ASTATUS_CONNECTION $ADM_CONNECTION
  echo " --------Running astatus_db.sh $ASTATUS_CONNECTION PROCS "
  sh astatus_db.sh $ASTATUS_CONNECTION PROCS
  echo " --------Running  astatus_db.sh $ASTATUS_CONNECTION TRIGS "
  sh astatus_db.sh $ASTATUS_CONNECTION TRIGS

  cd $CADOPS_HOME/upgrade/distributed/grants
echo "------Running  dist_grantCADOPS.sh $ASTATUS_CONNECTION $ASTORM_CONNECTION $ADM_CONNECTION "$DISTRICT_NUM" $DBLINK1 $DBLINK2 "
  sh dist_grantCADOPS.sh $ASTATUS_CONNECTION $ASTORM_CONNECTION $ADM_CONNECTION "$DISTRICT_NUM" $DBLINK1 $DBLINK2 

  cd $CADOPS_HOME/upgrade/db/create_db/cts/scripts
echo "------Running cts_main_db.sh $ASTATUS_CONNECTION $ASTORM_CONNECTION $ADM_CONNECTION $CT_CONNECTION $CADOPS_MAIN/logs/upgrades/ "
  sh cts_main_db.sh $ASTATUS_CONNECTION $ASTORM_CONNECTION $ADM_CONNECTION $CT_CONNECTION $CADOPS_MAIN/logs/upgrades/

  cd $CADOPS_HOME/upgrade/distributed/astatus/procs
  echo " ---------Running ALL_PROCS.sh $ASTATUS_CONNECTION "
  sh ALL_PROCS.sh $ASTATUS_CONNECTION

  cd $CADOPS_HOME/upgrade/distributed/astatus/views
  echo "--------Running ALL_VIEWS.sh $ASTATUS_CONNECTION "
  sh ALL_VIEWS.sh $ASTATUS_CONNECTION

  cd $CADOPS_HOME/upgrade/db/create_db
  echo " -------Running  astatus_db.sh $ASTATUS_CONNECTION UPDDATA "
  sh astatus_db.sh $ASTATUS_CONNECTION UPDDATA

  cd $CADOPS_HOME/upgrade/distributed/upddata
  echo " -------Running update_outage_repair.sql "
  sqlplus $ASTATUS_CONNECTION @update_outage_repair.sql

  cd $CADOPS_HOME/upgrade/distributed/astatus/modify
  echo " -------Running upd_district_no.sh $ASTATUS_CONNECTION "
  sh upd_district_no.sh $ASTATUS_CONNECTION

  cd $CADOPS_HOME/upgrade/distributed/astatus/upddata
  echo " ----------Running  ALL_UPD.sh $ASTATUS_CONNECTION "$AREA" "
  sh ALL_UPD.sh $ASTATUS_CONNECTION "$AREA"
  
  cd $CADOPS_HOME/upgrade/distributed/grants
  echo " ---------Running DROP_ASTORM_CTS_SYNONYM.sh $ASTORM_CONNECTION "
  sh DROP_ASTORM_CTS_SYNONYM.sh $ASTORM_CONNECTION

  cd $HOME
  echo " --------Running the user_prefs and lang_text_trans"
  sqlplus $ASTORM_CONNECTION @$DEPLOY_LOC/1_user_pref.sql  
  sqlplus $ASTORM_CONNECTION @$DEPLOY_LOC/1_lang_text_trans.sql  
  cd $CADOPS_HOME/stopro/op_state_change_api
  sh build_op_state_change_api.sh $ASTATUS_CONNECTION 
  
  cd $CADOPS_HOME/stopro/tag_api
  build_tag_api.sh $ASTATUS_CONNECTION $CT_CONNECTION
  
  cd $CADOPS_HOME/stopro/crew_api
  build_crew_api.sh $ASTORM_CONNECTION $ASTATUS_CONNECTION

}
##### AUB,SRA,EUR
if [[ $DBUPGRADE = "true" ]]; then
for district in "aub" "sra";
do
    echo "------ Database Upgrade for $district"  
    cd $CADOPS_MAIN
    export UPPER=`echo $district| tr "[:lower:]" "[:upper:]"`
    . ./.env_dms_$district
    export DBLINK1="$DBLINK"_"$UPPER""2ASTORM.LINK"      
    echo "------ Running script with the following parameter $MYADMIN $MYASTORM $ASTATUS $CTS $DBLINK1 $DBLINK2 $AREA $DISTRICT_NUM"  
    run_script $MYADMIN $MYASTORM $ASTATUS $CTS $DBLINK1 $DBLINK2 $AREA $DISTRICT_NUM
    echo "----- Finished upgrade for $district " 
done
fi

if [[ $START_ENGINES = "true" ]]; then
echo "------ Starting Engines for $district district"
for district in "aub" "sra";
   do
        cd $CADOPS_MAIN
        . ./.env_dms_$district
        startdms1
done
 export MAILFILE=/tmp/mailfile_$project_user.txt
export OMI='\\ccsl02\dmsship\ship722\win'
export PSE='\\ccsl02\dmsrelease\PSE'

if [ -e "$MAILFILE" ]
then
   echo " Remvoing mail file $MAILFILE " 
   rm -rf $MAILFILE
fi
echo "|--------------------------------------------------------------------------------------" >> $MAILFILE
echo "|    Today's Build is done and the below changes are included                          " >> $MAILFILE
echo "|    http://jks-bld.ventyx.us.abb.com:8080/job                                        " >> $MAILFILE
echo "|--------------------------------------------------------------------------------------" >> $MAILFILE
echo "|--------------------------------------------------------------------------------------" >> $MAILFILE
echo "|    Today's Build is done and available at $BUILDDIR/$dmsbuild                        " >> $MAILFILE
echo "|    Today's OMI Build is done and available at $OMI                                   " >> $MAILFILE
echo "|    Today's PSE Build is done and available at $PSE                                   " >> $MAILFILE
echo "|--------------------------------------------------------------------------------------" >> $MAILFILE
echo "|--------------------------------------------------------------------------------------" >> $MAILFILE
echo "|    Today's Build for is successfully deployed on $ENV_NAME                           " >> $MAILFILE
echo "|--------------------------------------------------------------------------------------" >> $MAILFILE
echo "|    Network Model Server and Database schemas Updated                                 " >> $MAILFILE
echo "|--------------------------------------------------------------------------------------" >> $MAILFILE
echo "|    URL INFO :- http://jks-bld.ventyx.us.abb.com/dmsenvironment.html                   " >> $MAILFILE
echo "|--------------------------------------------------------------------------------------" >> $MAILFILE

echo " Finished Script successfully "

for district in "aub" "sra" ;
do
 cd $CADOPS_MAIN
 . ./.env_dms_$district
sqlplus $ASTATUS @$DEPLOY_LOC/2_drop_invalids_astatus.sql
done

echo "Recompiling invalid objects" 
sh $CADOPS_HOME/upgrade/db/create_db/recompile.sh $MYASTORM
sh $CADOPS_HOME/upgrade/db/create_db/recompile.sh $MYADMIN

for list in "aub" "sra" 
    do
        cd $CADOPS_MAIN
        echo "Recompiling invalid objects" 
        . ./.env_dms_$list
        sh $CADOPS_HOME/upgrade/db/create_db/recompile.sh $ASTATUS
        sh $CADOPS_HOME/upgrade/db/create_db/recompile.sh $CTS
done
for list in "aub" "sra" "astorm";
    do
        cd $CADOPS_MAIN
        echo " Invalid Objects for $list" >> $MAILFILE
        . ./.env_dms_$list
        sh $CADOPS_MAIN/scripts/invalids.sh >> $MAILFILE
done

cat $MAILFILE | mail -s "Distributed DB Environment deployed with today build $dmsbuild" -c cms.dms.build@ventyx.abb.com dms.scrumteam@ventyx.abb.com 
fi
echo "######################### ALL Finished successfully ################"
