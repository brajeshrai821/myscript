#!/bin/sh
#AM
# The statusdms reports the status of the dms pocesses
#
#
#serviceN=$1
serviceN=cadops
#clear
echo " `date` "
echo "**********************************************************"


ProcN=`ps -ef |grep $serviceN |grep "$CADOPS_HOME"/bin | grep -v grep |awk '{printf ("%s:%s\n",$2,$8)}' `
if [[ "$ProcN" ]] ; then 
echo " The following dms proceses are running: "
ps -ef |grep $serviceN |grep "$CADOPS_HOME"/bin | grep -v grep |awk '{printf ("%s:%s\n",$2,$8)}' 
else
echo "**********************************************************"
echo " dms processes are not running.  "
echo "**********************************************************"

fi

echo " `date` "
echo "**********************************************************"
ServiceJ=java
javaN=`ps -ef | grep $ServiceJ| grep "$CADOPS_HOME"| grep -v grep |awk '{printf ("%s:%s\n",$2,$14)}'`
if [[ "$javaN" ]] ; then
echo " The following dms java proceses are running: "
ps -ef | grep $ServiceJ| grep "$CADOPS_HOME"| grep -v grep |awk '{printf ("%s:%s\n",$2,$14)}'
else
echo "**********************************************************"
echo " dms java processes are not running.  "
echo "**********************************************************"

fi

