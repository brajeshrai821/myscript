#!/bin/sh
 export NODE_NAME=`hostname`
 export OS=`uname`
 echo "Workspace $WORKSPACE"
 echo "Deployment host $NODE_NAME"
 export PATH=$PATH:.
 export STOP_ENGINES=${STOP_ENGINES=false}
 export START_ENGINES=${START_ENGINES=false}
 export UNTAR=${UNTAR:=false}
 export DBUPGRADE=${DBUPGRADE:=false}
 export DATE=`date +%H%M%S`;
 echo



 . $BUILD_ROOT/cm/$ENV_FILE
 cd $ENV_DIR

 echo ENV_DIR $ENV_DIR
 echo BUILDDIR $BUILDDIR
 echo STOP_ENGINES $STOP_ENGINES
 echo START_ENGINES $START_ENGINES
 echo UNTAR $UNTAR
 echo DBUPGRADE $DBUPGRADE

 export DEPLOY_LOC=$HOME/deployment
 export DROPFILE=/tmp/spool.sql
 export dmsbuild=`ls -lrt $BUILDDIR | grep aix |tail -1 | awk '{ print $NF }'`
###ASTORM



if [[ $STOP_ENGINES = "true" ]]; then
echo "------- Stoping dbmessanger for $HOSTNAME"
mail -s "Environment with $ENV_NAME going down for deployment" -c cms.dms.build@ventyx.abb.com  dms.scrumteam@ventyx.abb.com
sh $CADOPS_MAIN/stopdms1
sh $CADOPS_MAIN/cleanshmdms
fi

if [[ $UNTAR = "true" ]]; then
echo "------- Running the deploy  DMS $dmsbuild Environment "
mv $CADOPS_HOME $CADOPS_HOME"_prevRel_"$DATE
mkdir $CADOPS_MAIN/logs/oldlogs_$DATE
mv $CADOPS_MAIN/logs/*log ${CADOPS_MAIN}/logs/oldlogs_$DATE
mkdir -p $CADOPS_HOME
rm -rf $CADOPS_HOME"_PrevRel_"$DATE
cd $CADOPS_HOME
tar -xvf $BUILDDIR/$dmsbuild  > $CADOPS_MAIN/logs/cadops_tar.log
fi

if [[ $DBUPGRADE = "true" ]]; then
cd $HOME
echo "------- Removing all invalids before starting upgrade for $ASTORM "
#sh $CADOPS_HOME/upgrade/db/create_db/recompile.sh $ASTORM
sqlplus  $ASTORM @$DEPLOY_LOC/preupgrade_drop_invalid.sql
echo "exit;" >>$DROPFILE
sqlplus $ASTORM @$DROPFILE

cd $CADOPS_HOME/upgrade/db/create_db
echo "------ Running cadops_astorm for $ASTORM " 
sh cadops_astorm.sh $ASTORM      # example : ps271_pg_a/demo@psed1103

cd $CADOPS_HOME/upgrade/distributed/views
echo "------- Running ALL_VIEWS for $ASTORM " 
sh ALL_VIEWS.sh $ASTORM                    #example : ps271_pg_a/demo@psed1103 

cd $CADOPS_HOME/upgrade/distributed/astorm/procs
echo "------- Running ALL_PROCS for $ASTORM " 
sh ALL_PROCS.sh $ASTORM

cd $CADOPS_HOME/upgrade/distributed/astorm/trigs
echo "------- Running ALL_TRIGS for $ASTORM " 
sh ALL_TRIGS_ABB.sh $ASTORM                #ps271_pg_a/demo@psed1103

cd $CADOPS_HOME/upgrade/distributed/astorm/stopro
echo "------ Running trouble_rpt.sql call_pkg.sql outage_api.pkg"
sqlplus $ASTORM @trouble_rpt.sql
sqlplus $ASTORM @call_pkg.sql
sqlplus $ASTORM @outage_api.pkg

echo "------ Finished ASTORM database upgrade script "

echo "------ Droping invalids after upgrade"
cd $CADOPS_MAIN
sqlplus $ASTORM @$DEPLOY_LOC/1_drop_invalids_astorm.sql
fi

echo "------- Starting dbmessanger for $HOSTNAME"
nohup $CADOPS_HOME/bin/dbmessager $ASTORMDB $ASTORMDB_PASSWD $DBNAME 1 GLOBAL > $CADOPS_MAIN/logs/"$ASTORMDB"_dbmessager_log 2>&1 &
