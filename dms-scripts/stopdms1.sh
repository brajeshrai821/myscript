#!/bin/sh

# The stopdms stops the dms pocesses
#
#
#serviceN=$1
serviceN=dms
#clear
echo "`date`"
echo "**********************************************************"

ProcID=`ps -ef |grep $serviceN |grep "$CADOPS_HOME"/bin | grep -v grep |awk '{printf ("%s\n",$2)}' `
ProcN=`ps -ef |grep $serviceN |grep "$CADOPS_HOME"/bin | grep -v grep |awk '{printf ("%s:%s\n",$2,$8)}' `
#echo $ProcN
let nn=0
for ii in $ProcN
do
  let nn=nn+1
  #echo $ii
  idd=`echo $ii |cut -d ":" -f1`
  idm=`echo  $ii |cut -d ":" -f2`
  #echo $idd
  echo "Stopping $idm ... "
  kill -9 $idd
  
done

ProcN=`ps -ef |grep $serviceN |grep "$CADOPS_HOME"/bin | grep -v grep |awk '{printf ("%s:%s\n",$2,$8)}' `
if [[ "$ProcN" ]] ; then 
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "WARNING:   The following processes are still running: "
ps -ef |grep $serviceN |grep "$CADOPS_HOME"/bin | grep -v grep |awk '{printf ("%s:%s\n",$2,$8)}' 
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
else
echo "**********************************************************"
echo " dms processes are successfully stopped. "
echo "**********************************************************"

fi
