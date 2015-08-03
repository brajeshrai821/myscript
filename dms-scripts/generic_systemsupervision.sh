pwd
hostname

echo BUILD_ROOT is $BUILD_ROOT
echo ENV_FILE is $ENV_FILE
echo DISABLE_SUPERVISION $DISABLE_SUPERVISION
echo ENABLE_SUPERVISION $ENABLE_SUPERVISION

. $BUILD_ROOT/cm/$ENV_FILE




if [[ $SS_STOP = "1" ]]; then
  
  echo commenting out crontab
  crontab -l| sed '/^*/s/^/#/' | crontab -
  #mail -s "Environment $ENV_NAME going down for deployment in 5 minutes"  -c cms.dms.build@ventyx.abb.com  dms.scrumteam@ventyx.abb.com
  echo sleeping 300 seconds
  sleep 300
  echo shuting down engines
  sh $BUILD_ROOT/cm/stopdms1.sh
  sh $BUILD_ROOT/cm/cleanshmdms.sh
  sh $BUILD_ROOT/cm/stopmds.sh

fi



if [[ $SS_START = "1" ]]; then
  
  echo removing comments in crontab
  crontab -l | sed "/^#/s/^#//" | crontab -

fi