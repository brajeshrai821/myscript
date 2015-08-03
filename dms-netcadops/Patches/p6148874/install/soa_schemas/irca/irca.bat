@SETLOCAL
@ECHO OFF

REM $Header: irca.bat 10-may-2006.18:54:55 gsah Exp $
REM
REM Copyright (c) 2005, 2006, Oracle. All rights reserved.  
REM        
REM   DESCRIPTION
REM    IRCA Driver Script
REM    
REM   NOTES
REM    
REM   MODIFIED    (MM/DD/YY)
REM    gsah        05/10/06 - Avoid hardcoding JAVA_HOME 
REM    gsah        03/22/06 - add esb support 
REM    sawadhwa    03/07/05 - Validate sqlldr and sqlplus
REM    sawadhwa    03/03/05 - Require JDK 1.4
REM    sawadhwa    03/01/05 - sawadhwa_bpelpm_install_irca
REM    sawadhwa    02/22/05 - Creation

echo Integration Repository Creation Assistant (IRCA) 10.1.3.1.0
echo (c) Copyright 2006 Oracle Corporation. All rights reserved.

REM SET /P ORACLE_HOME=Enter database ORACLE_HOME: 

IF NOT EXIST %ORACLE_HOME%\jdbc\lib\ojdbc14.jar (
    ECHO ERROR: Cannot find library - %ORACLE_HOME%\jdbc\lib\ojdbc14.jar
    ECHO Please verify that the ORACLE_HOME is set correctly.
    EXIT /B 1
)

IF NOT EXIST %ORACLE_HOME%\bin\sqlplus.exe (
    ECHO ERROR: Cannot find sqlplus at %ORACLE_HOME%\bin\sqlplus.exe
    ECHO Please verify that the ORACLE_HOME is set correctly.
    EXIT /B 1
)

REM IF NOT EXIST %ORACLE_HOME%\bin\sqlldr.exe (
REM    ECHO ERROR: Cannot find sqlldr at %ORACLE_HOME%\bin\sqlldr.exe
REM    ECHO Please verify that the ORACLE_HOME is correct.
REM    EXIT /B 1
REM )

REM SET /P PROMPT_JAVA_HOME=Enter JDK 1.4.x/1.5.x location:
REM ECHO JAVA_HOME=%PROMPT_JAVA_HOME%
REM SET JAVA_HOME=%PROMPT_JAVA_HOME%

IF "%JAVA_HOME%" == "" (
  IF EXIST %ORACLE_HOME%\jdk\bin\java.exe (
    SET JAVA_HOME=%ORACLE_HOME%\jdk
  )
)
REM Validate Java Home
IF NOT EXIST %JAVA_HOME%\bin\java.exe (
  ECHO ERROR: Cannot find java executable - %JAVA_HOME%\bin\java.exe"
  ECHO Please verify that the JAVA_HOME is set correctly.
  EXIT /B 1;
)

REM Set Classpath
set CLASSPATH=lib\bpm-install.jar;%ORACLE_HOME%\jdbc\lib\ojdbc14.jar

REM ############################################################################
REM Usage Syntax:
REM irca.sh [all "<db_host> <db_port> <db_service_name>" <sys_password> overwrite]
REM #############################################################################
REM Example for silent mode run without any prompts:
REM irca.sh all "stadt48.us.oracle.com 1521 orcl" welcome overwrite
REM #############################################################################

REM Run java command
%JAVA_HOME%\bin\java -classpath %CLASSPATH% -DORACLE_HOME=%ORACLE_HOME% oracle.tip.install.tasks.IRCA %*

REM PAUSE

@ECHO ON
@ENDLOCAL

