# WARNING: Failure to carefully read and understand these requirements may
# result in your applying a patch that can cause your Oracle Server to
# malfunction, including interruption of service and/or loss of data.
#
# If you do not meet all of the following requirements, please log an
# iTAR, so that an Oracle Support Analyst may review your situation. The
# Oracle analyst will help you determine if this patch is suitable for you
# to apply to your system. We recommend that you avoid applying any
# temporary patch unless directed by an Oracle Support Analyst who has
# reviewed your system and determined that it is applicable.
#
# Requirements:
#
# - You must have located this patch via a Bug Database entry
# and have the exact symptoms described in the bug entry.
#
# - Your system configuration (Oracle Server version and patch
# level, OS Version) must exactly match those in the bug
# database entry - You must have NO OTHER PATCHES installed on
# your Oracle Server since the latest patch set (or base release
# x.y.z if you have no patch sets installed).
#
# - [Oracle 9.2.0.2 & above] You must have Perl 5.00503 (or later)
# installed under the ORACLE_HOME, or elsewhere within the host
# environment. OPatch is no longer included in patches as of 9.2.0.2.
# Refer to the following link for details on Perl and OPatch:
# http://metalink.oracle.com/metalink/plsql/ml2_documents.showDocument?p_database_id=NOT&p_id=189489.1
#
# - [IBM AIX O/S & Java patches for Oracle 9.2]
# In order to apply java class updates to IBM AIX based systems using
# java_131, you must update your java if you are running a version prior
# to Service Refresh build date 20030630a. This is
# necessary to fix IBM Defect#60472.
#
# To identify which java build date you are on, enter the following
# command ;
#
# > $ORACLE_HOME/jdk/bin/java -fullversion
# ... example response ...
# java full version "J2RE 1.3.1 IBM AIX build ca131-20030630a"
#
# The string ends in the date format YYYYMMDD or YYYYMMDDa where 'a'
# indicates an updated release to the original build. You should always
# apply the latest AIX Java SDK 1.3.1 Service Update available from IBM.
# As a minimum, the above service refresh can be found under
# APAR IY47055. The signature for the updated JVM is ca131-20030630a.
# Information on the latest available fixes, as well as how to apply
# the APARs to your AIX systems, is available at the IBM Java site.
#
# If you are running AIX 5L, you can safely ignore any comment against
# the APAR that says (AIXV43 only). The APAR is applicable to
# both AIX 4.3 and AIX 5L.
#
# Once you have updated your java installation you need to copy these
# updated files to Oracle's copies in $ORACLE_HOME/jdk.
# As the Oracle owner, simply issue the following commands;
#
# > cd /usr/java131
# > cp -fpR * $ORACLE_HOME/jdk
#
#
# If you do NOT meet these requirements, or are not certain that you meet
# these requirements, please log an iTAR requesting assistance with this
# patch and Support will make a determination about whether you should
# apply this patch.
#
#-------------------------------------------------------------------------
# Interim Patch for base bug: 6078836 
#-------------------------------------------------------------------------
#
# DATE: 4th October 2007
# ------------------------
# Platform Patch for : Linux-46
# Product Version # : 10.1.3.3.0
# Product Patched : Oracle HTTP Server
#
# Bugs Fixed by this patch:
# -------------------------
# 6078836 - RH5.0 / OEL5.0 CERT : SPECIAL LIBRARY NEEDED TO RUN OHS ON REDHAT5 MACHINE   
# 
# Patch Installation Instructions:
# --------------------------------
# Stop all OHS instances in the iAS instance under repair;
# Note that, each iAS instance may be repaired separately, but the OHS instances cannot be.
#
#
# To apply the patch, unzip the PSE container file:
#
# % unzip p6078836_101330_Linuxx86.zip
#
# Set your current directory to the directory where the patch
# is located:
#
# % cd 6078836 
#
# Important Note:  This file is for RedHat 5 (or later) ONLY.
#
# As the super-user, copy libdb.so.2 to /usr/lib
#
# % mv /usr/lib/libdb.so.2 /usr/lib/libdb.so.2.6078836 (if libdb.so.2 exist already in /usr/lib)
# % cp libdb.so.2 /usr/lib
#
#
# Restart the OHS instances of the iAS instance under repair.
#
# Patch Special Instructions:
# ---------------------------
# If the Oracle inventory is not setup correctly this utility will
# fail. To check accessibility to the inventory you can use the
# command
#
# % opatch lsinventory
#
# If you have any problems installing this PSE or are not sure
# about inventory setup please call Oracle support.
#
# Patch Deinstallation Instructions:
# ----------------------------------
# Use the following command:
#
# As the Super-user
# %  mv /usr/lib/libdb.so.2.6078836 /usr/lib/libdb.so.2



