#!/bin/sh

 export NODE_NAME=`hostname`
 export OS=`uname`
 export PATH=$PATH:.
 echo "Workspace $WORKSPACE"
 echo "Deployment host $NODE_NAME"
 export DBCLEANUP=${DBCLEANUP:=false}
 export RUNTESTCASES=${RUNTESTCASES:=false}
 export CHECKPROCESS=${CHECKPROCESS:=false}

 cd $BUILD_ROOT/cm
 . $ENV_FILE
 
 echo DBCLEANUP $DBCLEANUP 
 echo CHECKPROCESS $CHECKPROCESS
 echo CHECKMDSPROCESS $CHECKMDSPROCESS
 echo RUNTESTCASES $RUNTESTCASES
 echo ENV_DIR $ENV_DIR
 echo ENV_FILE $ENV_FILE
 echo TESTCASEDIR $TESTCASEDIR
 export build=`ls -lrt $TESTCASEDIR |grep DMSAutoTest |tail -1 | awk '{ print $NF }'` 
 

export PATH=$PATH:.

if [[ $CHECKPROCESS = "true" ]]; then
 export CheckEngines=`ps -ef |grep cadops |grep "$CADOPS_HOME"/bin | grep -v grep |awk '{printf ("%s:%s\n",$2,$8)}' `
if [[ "$CheckEngines" ]] ; then
  echo " ####################################"
  echo "      The dms engines are running: "
  echo " ####################################"
else

  echo " ####################################"
  echo " Engines's are not running, no test runs"
  echo " ####################################"
  exit 1;
fi
fi

if [[ $CHECKMDSPROCESS = "true" ]]; then
 export Checkmds=`ps -ef |grep mds |grep "$CADOPS_HOME" | grep -v grep |awk '{printf ("%s:%s\n",$2,$8)}' `
if [[ "$Checkmds" ]] ; then
  echo " ####################################"
  echo "      The mds engines are running: "
  echo " ####################################"
else

  echo " ####################################"
  echo " mds Engines's are not running, no test run"
  echo " ####################################"
  exit 1;
fi
fi
 echo "CADOPS DIR $CADOPS_MAIN"
 
if [[ $DBCLEANUP = "true" ]]; then 
 echo " CI ENVironment Database going to normal state "
 cd $CADOPS_MAIN/scripts
 echo "------------------Cleaning $ADMIN data-------------------"
 sqlplus $ADMIN @reset_admin_data.sql
 echo "------------------Cleaning $ASTORM data-------------------"
 sqlplus $ASTORM @reset_astorm_data.sql
 echo "------------------Cleaning $ASTATUS data-------------------"
 sqlplus $ASTATUS @reset_astatus_data.sql
fi
 
if [[ $RUNTESTCASES = "true" ]]; then 
 echo " untaring $TESTCASEDIR to $CADOPS_HOME/java/dist "
 if [ -d $CADOPS_HOME/java/dist/DMSAutoTest ]
 then
    echo "removing $CADOPS_HOME/java/dist/DMSAutoTest" 
    rm -rf $CADOPS_HOME/java/dist/DMSAutoTest 
 fi
 echo "creating $CADOPS_HOME/java/dist/DMSAutoTest"
 mkdir $CADOPS_HOME/java/dist/DMSAutoTest
 cd $CADOPS_HOME/java/dist/DMSAutoTest
 tar -xvf $TESTCASEDIR/$build .
 cp $CADOPS_MAIN/config_autotest_ci.properties $CADOPS_HOME/java/dist/DMSAutoTest/etc/config.properties

 cd $CADOPS_HOME/java/dist/DMSAutoTest/
 ant Test -Dignore.lock=1 -Dtest.file=etc/tests/DmsBaselineOutageTest.txt
 ant Test -Dignore.lock=1 -Dtest.file=etc/tests/TestHighestCriticalFacilityCode.txt
 ant Test -Dignore.lock=1 -Dtest.file=etc/tests/DmsCrewRestoresCustomerOutage.txt 
 ant Test -Dignore.lock=1 -Dtest.file=etc/tests/SoiNonCustomerCall.txt

 ant Test -Dignore.lock=1 -Dtest.file=etc/tests/SoiCrewRestoresCustomerOutage.txt 
 ant Test -Dignore.lock=1 -Dtest.file=etc/tests/SoiCrewRestoreDeviceOutage.txt -Dtest.data=etc/tests/SoiCrewRestoreDeviceOutage.csv
 ant Test -Dignore.lock=1 -Dtest.file=etc/tests/CustomerOutagePriorityTest.txt -Dtest.data=etc/tests/CustomerOutagePriorityTest.csv
 ant Test -Dignore.lock=1 -Dtest.file=etc/tests/SoiBlockOutageUpdates.txt -Dtest.data=etc/tests/SoiBlockOutageUpdates.csv

 # Rename all junit-noframes.html to its test name
 # and copy to the out directory
 echo 'Collecting report files...'
 for file in `find out -name '*.html'`; do
   report=`echo $file | awk  'BEGIN {FS="/"}; {print $4}'`
   report=`echo $report | sed -e s/\.txt//`
   cp -p $file out/$report.html
   echo " $report.html"
 done

fi

