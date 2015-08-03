#!/bin/sh

# $Header: irca.sh 10-may-2006.18:54:56 gsah Exp $
#
# Copyright (c) 2005, 2006, Oracle. All rights reserved.  
#        
#   DESCRIPTION
#    IRCA Driver Script
#    
#   NOTES
#    
#   MODIFIED    (MM/DD/YY)
#    gsah        05/10/06 - Avoid hardcoding JAVA_HOME 
#    sawadhwa    03/07/05 - Verify sqlplus and sqlldr
#    sawadhwa    03/03/05 - Require JDK 1.4
#    sawadhwa    03/01/05 - sawadhwa_bpelpm_install_irca
#    sawadhwa    02/22/05 - Creation

# Find the right echo.
if [ "X`/bin/echo -e`" = "X-e" ]; then
  ECHO=/bin/echo
else
  ECHO="/bin/echo -e"
fi

$ECHO "Integration Repository Creation Assistant (IRCA) 10.1.3.1.0"
$ECHO "(c) Copyright 2006 Oracle Corporation. All rights reserved."
$ECHO ""

#$ECHO "Enter database Oracle Home: \c" 
#read ORACLE_HOME
export ORACLE_HOME

if [ ! -f $ORACLE_HOME/jdbc/lib/ojdbc14.jar ]; then
  $ECHO "ERROR: Cannot find library - $ORACLE_HOME/jdbc/lib/ojdbc14.jar"
  $ECHO "Please verify that the ORACLE_HOME is set correctly."
  exit 1;
fi

if [ ! -x $ORACLE_HOME/bin/sqlplus ]; then
  $ECHO "ERROR: Cannot find sqlplus at $ORACLE_HOME/bin/sqlplus"
  $ECHO "Please verify that the ORACLE_HOME is set correctly."
  exit 1;
fi

#if [ ! -x $ORACLE_HOME/bin/sqlldr ]; then
#  $ECHO "ERROR: Cannot find sqlldr at $ORACLE_HOME/bin/sqlldr"
#  $ECHO "Please verify that the Oracle Home is correct."
#  exit 1;
#fi

if [ "$JAVA_HOME" = "" ]; then
  if [ -x "$ORACLE_HOME/jdk/bin/java" ] ; then
    JAVA_HOME=$ORACLE_HOME/jdk
  else
    $ECHO "Enter JDK 1.4.x/1.5.x location: \c"
    read JAVA_HOME
  fi
fi
export JAVA_HOME

# Validate Java Home
if [ ! -x $JAVA_HOME/bin/java ]; then
  $ECHO "ERROR: Cannot find java executable - $JAVA_HOME/bin/java"
  $ECHO "Please verify that the JAVA_HOME is set correctly."
  exit 1;
fi

# Set Classpath
CLASSPATH=lib/bpm-install.jar:$ORACLE_HOME/jdbc/lib/ojdbc14.jar
export CLASSPATH

################################################################################
# Usage Syntax:
# irca.sh [all "<db_host> <db_port> <db_service_name>" <sys_password> overwrite]
################################################################################
# Example for silent mode run without any prompts:
# irca.sh all "stadt48.us.oracle.com 1521 orcl" welcome overwrite
################################################################################

# Run java command
$JAVA_HOME/bin/java -classpath $CLASSPATH -DORACLE_HOME=$ORACLE_HOME oracle.tip.install.tasks.IRCA "$@"
