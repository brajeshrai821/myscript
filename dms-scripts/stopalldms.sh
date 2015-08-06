#!/bin/sh

# The stopdms stops the dms pocesses
#
#
#serviceN=$1
serviceN=dms
#clear
echo "`date`" 
echo "**********************************************************"
stopdms1
cleanshmdms
stopmds
echo "**********************************************************"
echo "**********************************************************"
echo " dms processes and shared memories are stopped. "
echo "**********************************************************"

