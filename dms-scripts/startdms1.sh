#!/bin/sh

# The startdms starts the dms pocesses
#
#
#serviceN=$1
serviceN=dms
#clear
echo "**********************************************************"
echo " `date `"
echo " Starting the DMS processes ... "
echo " Wait ... "
echo



LOGDIR=$CADOPS_ROOT/logs



echo " Running shminit ... "
shminit $DBUSER $DBPASSWORD $DBNAME > "$LOGDIR"/"$DBUSER"_shminit_log 2>&1

echo " Starting opmanager ... "
nohup $CADOPS_HOME/bin/opmanager $DBUSER $DBPASSWORD $DBNAME all GLOBAL 0 > "$LOGDIR"/"$DBUSER"_opmanager_log 2>&1 &

echo " Starting dbmessager ... "
nohup $CADOPS_HOME/bin/dbmessager $ASTORMDB $ASTORMDB_PASSWD $DBNAME 1 GLOBAL > "$LOGDIR"/"$DBUSER"_dbmessager_log 2>&1 &

if [ ! -z $HAS_OUTAGE_ENGINE ]; then
  if [ $HAS_OUTAGE_ENGINE = "Y" ]; then
      echo " Starting outageEngine ... "
      nohup $CADOPS_HOME/bin/outageEngine $DBNAME Y $DBUSER > "$LOGDIR"/"$DBUSER"_outageEngine_log 2>&1 &
  fi
fi

echo " Starting faultlocation ... "
nohup $CADOPS_HOME/bin/faultlocation Y $DBUSER $DBPASSWORD $DBNAME fl all GLOBAL > "$LOGDIR"/"$DBUSER"_faultlocation_log 2>&1 &

echo " Starting incrUpd ... "
nohup $CADOPS_HOME/bin/incrUpd -u GLOBAL -d $DBUSER  > "$LOGDIR"/"$DBUSER"_incrUpd_log 2>&1 &

echo " Starting incrXref ... "
nohup $CADOPS_HOME/bin/incrXref -u GLOBAL -d $DBUSER > "$LOGDIR"/"$DBUSER"_incrXref_log 2>&1 &

echo " Starting caseserver ... "
nohup $CADOPS_HOME/bin/caseserver $CSUSER $CSPASSWORD $DBNAME GLOBAL > "$LOGDIR"/"$DBUSER"_caseserver_log 2>&1 &

echo " Starting filterEngine ... "
nohup $CADOPS_HOME/bin/filterEngine $DBUSER $DBPASSWORD $DBNAME all 1000 > "$LOGDIR"/"$DBUSER"_filterEngine 2>&1 &

echo " Starting alertEngine ... "
nohup $CADOPS_HOME/bin/alertEngine $DBUSER $DBPASSWORD $DBNAME all GLOBAL 60 > "$LOGDIR"/"$DBUSER"_alertEngine 2>&1 &

if [ ! -z $SIDL_CONTEXT ]; then

   echo " Starting scadaManager ... "
   nohup $CADOPS_HOME/bin/scadaManager $DBUSER $DBPASSWORD $DBNAME all GLOBAL 500 > "$LOGDIR"/"$DBUSER"_scadaManager_log 2>&1 &

   #export DEBUG=1
   echo " Starting scadaGateway with SIDL Context $SIDL_CONTEXT ... "
   nohup $CADOPS_HOME/bin/scadaGateway -context $SIDL_CONTEXT -chunk 10000 -link 1 > "$LOGDIR"/"$DBUSER"_scadaGateway_log 2>&1 &

   echo " Starting krbRenew ... "
   nohup $CADOPS_HOME/bin/krbRenew 30 60 > "$LOGDIR"/"$DBUSER"_krbRenew_log 2>&1 &

fi

sleep 3

ProcN=`ps -ef |grep $serviceN |grep "$CADOPS_HOME"/bin | grep -v grep |awk '{printf ("%s:%s\n",$2,$8)}' `
if [[ "$ProcN" ]] ; then
echo "**********************************************************"
echo " The following dms proceses are started: "
ps -ef |grep $serviceN |grep "$CADOPS_HOME"/bin | grep -v grep |awk '{printf ("%s:%s\n",$2,$8)}'
echo "**********************************************************"
else
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!!!  WARNING: dms processes could not start !!!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

fi
