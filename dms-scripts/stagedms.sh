#!/bin/ksh

###################################
ThisReleaseDir=/nmdata/dmsrelease/Releases/${DMS_VERSION}
ThisCADOPSWClient=/nmdata/dmsrelease/Releases/${DMS_VERSION}/msi-11g-32bit


CADOPS_TARZ_FILE=dms7.1_linux64.tar.Z
#THIRDPARTY_TAR_FILE=ngrid_third_party_11gR2.tar Not needed in 7.1
###################################
CurrentReleaseDir=/nmdata/dmsrelease/current
PreviousReleaseDir=/nmdata/dmsrelease/PrevRelease

if [ "$(id -u)" = "0" ] ; then
   uid=`id`
   msg="Attempted to run dms upgrade as user {$uid}"
   logger -p auth.notice -t "$0" "$msg"
   echo "Must not be privileged user to install dms upgrade."
   echo "Run the dms upgrade as the dms unix owner such as dms, cadops, ..."
   exit 1
fi


if [ -z $DMS_UPGRADE_PROFILE ]; then
   echo "Setting up envirment ... "
   . $DMS_UPGRADE_PROFILE

   echo "DMS_VERSION is: $DMS_VERSION "
   echo " "
else
   echo " DMS_UPGRADE_PROFILE environment variable is not set! "
   echo " Exiting ... "
   exit 1

fi

if [ -z $DMS_VERSION ]; then
   echo "DMS_VERSION is: $DMS_VERSION "
else
   echo "DMS_VERSION environment variable is not set! "
   echo " Exiting ... "
   exit 1
   echo " "
fi

mkdir -p $ThisReleaseDir
mkdir -p $ThisCADOPSWClient
mkdir -p $CurrentReleaseDir
mkdir -p $PreviousReleaseDir

# Get current DMS Version
if [ -f "$CurrentReleaseDir"/dms_release_version.txt ]; then
 . "$CurrentReleaseDir"/dms_release_version.txt
else
 DMS_RELEASE_VERSION=Null
fi



# Check if versions match
# If they do then exist, we shouldn't be upgrading to the same version
if [ $DMS_RELEASE_VERSION == $DMS_VERSION ]; then
  echo The new DMS Version \(${DMS_VERSION}\) matches the previously installed version \(${DMS_RELEASE_VERSION}\)
  echo Please update the DMS_VERSION variable in the script and re-run
  exit
fi



rm -rf ${PreviousReleaseDir}
mv $CurrentReleaseDir ${PreviousReleaseDir}
mkdir -p $CurrentReleaseDir

cp -p ${ThisReleaseDir}/${CADOPS_TARZ_FILE} ${CurrentReleaseDir}/cadops.tar.Z

#cp -p ${ThisReleaseDir}/${THIRDPARTY_TAR_FILE} ${CurrentReleaseDir}/third_party.tar

cp -rp ${ThisCADOPSWClient} ${CurrentReleaseDir}/.



echo "DMS_RELEASE_VERSION=$DMS_VERSION" > ${CurrentReleaseDir}/dms_release_version.txt
echo " "
echo " The following is the contents of the 'current' directory "
ls -l $CurrentReleaseDir

cat  ${CurrentReleaseDir}/dms_release_version.txt





