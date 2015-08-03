#!/bin/sh
export PATH=$PATH:.
export HOSTNAME=`hostname`
export ENV_FILE=$1

. $ENV_FILE

echo ENV_DIR $ENV_DIR
echo ENV_FILE $ENV_FILE
echo "------- Disable running system supervision on $HOSTNAME"
crontab -l| sed '/^*/s/^/#/' | crontab -


echo "------- Stoping All running Engines on $HOSTNAME"
sh $CADOPS_MAIN/stopdms1
sh $CADOPS_MAIN/cleanshmdms
