Integration Repository Creation Assistant (IRCA) 10.1.3.1.0
===========================================================

The Integration Repository Creation Assistant (IRCA) utility must be
used to create and load Orabpel and Esb schemas into an Oracle database.
IRCA is required if you plan to install Oracle BPEL Process Manager on
an OracleAS 10.1.3.1.0 middle tier.


REQUIREMENTS
------------
- Oracle Database 9.2.0.7 or
  Oracle Database 10.1.0.5.0 and higher, or
  Oracle Database 10.2.0.2.0 and higher
- JDK 1.4 or 1.5(typically bundled with Oracle 10g database)
- 120 MB disk space for tablespaces


GLOBALIZATION REQUIREMENTS
--------------------------
If you will be running the Oracle BPEL Process Manager in a 
multi-lingual environment or need multi-byte support, it is 
recommended that your database character set encoding be Unicode.
This means that the database character set encoding should be 
'AL32UTF8'.  If the character set encoding is not Unicode, there 
may be possible loss or misinterpretation of data.


RUNNING IRCA
------------
IRCA must be run on the machine where your Oracle database is 
installed or from a remote Oracle Client having sqlplus installation.

  - Set ORACLE_HOME containing sqlplus(under <ORACLE_HOME>/bin) in 
    your environment from where sqlplus can be used to connect to 
    local/remote Oracle DB: 

      set ORACLE_HOME=c:\oracle10g    [on Windows]
      setenv ORACLE_HOME ~/oracle10g  [on Unix]

    Make sure you can connect to your Oracle using "SYS" DB user using:
    $ORACLE_HOME/bin/sqlplus "sys/<sysPassword>@<serviceName> as sysdba"

  - NOTE: If using DB 9.2.0.7 or any others that dont have the correct
          version of Java then you *MUST* set your JAVA_HOME. If your
          ORACLE_HOME has a JDK with the right version you may skip
          this step.

    Set JAVA_HOME to a JDK version that is 1.4.x or higher.

  - Unzip the irca.zip distribution into a temporary directory, if 
    required. SOA shiphome contains irca scripts under
        <shiphome>/Disk1/install/soa_schemas/irca

  - Command Usage:
    irca[.sh] [options]
    where following options can be added to run irca in silent mode:

    all|orabpel|oraesb|orawsm "<db_host> <db_port> <db_service_name>" 
    <sys_password> -overwrite ORABPEL <ORABPEL_PASSWD> ORAESB <ORAESB_PASSWD>
ORAWSM <ORAWSM_PASSWD>

  - Example for silent mode run without any prompts:

    irca[.sh] all "localhost 1521 orcl" welcome -overwrite ORABPEL ORABPEL123 ORAESB ORAESB123 ORAWSM ORAWSM123

NOTE: If you already have BPEL/ESB/WSM users in the target database,
      please ensure that all database activity for the users is 
      stopped. IRCA will prompt you before overwriting existing data.

LOADING INDIVIDUAL SCHEMAS
--------------------------

In some cases, it might be preferable to load just one schema, e.g
ORABPEL/ORAESB/ORAWSM. For example, you might have to recreate the ESB
schema without overwriting the others. If that suits your needs, you may
specify the schema that you want loaded as a command-line argument while
running irca.

Example:
The following command will only load the orabpel schema.
  irca[.sh] orabpel

The following command will only load the oraesb schema.
  irca[.sh] oraesb

The following command will only load the orawsm schema.
  irca[.sh] orawsm

If you do not specify any options as below, all schemas will be loaded 
into the target database.

  irca[.sh] [all]


SAMPLE SESSION(INTERACTIVE MODE)
================================
./irca.sh
Integration Repository Creation Assistant (IRCA) 10.1.3.1.0
(c) Copyright 2006 Oracle Corporation. All rights reserved.

Enter database "host port serviceName" [localhost 1521 orcl]: stadt48.us.oracle.com 1521 stadt48.us.oracle.com
Enter sys password:  
Running IRCA for all product(s):
 connection="stadt48.us.oracle.com 1521 stadt48.us.oracle.com", ,
orabpelUser=ORABPEL, esbUser=ORAESB, orawsmUser=ORAWSM

Validating database ...
Validating database character set ...
WARNING: The target database character set is WE8ISO8859P1
For multi-byte support, the AL32UTF8 character set is recommended.


Running prerequisite checks for ORABPEL ...
WARNING: This script will overwrite the existing ORABPEL schema.
Do you wish to continue? (y/n) y
Enter password for ORABPEL:  
Loading ORABPEL schema (this may take a few minutes) ...


Running prerequisite checks for ORAESB ...
WARNING: This script will overwrite the existing ORAESB schema.
Do you wish to continue? (y/n) y
Enter password for ORAESB:  
Loading ORAESB schema (this may take a few minutes) ...


Running prerequisite checks for ORAWSM ...
WARNING: This script will overwrite the existing ORAWSM schema.
Do you wish to continue? (y/n) y
Enter password for ORAWSM:  
Loading ORAWSM schema (this may take a few minutes) ...


INFO: ORABPEL schema contains 236 valid objects.

INFO: ORAESB schema contains 28 valid objects.

INFO: ORAWSM schema contains 90 valid objects.

IRCA completed.
Please check for any ERROR message above and also check the log file 
irca2006-06-06_02-49-49PM.log for any error or other information.



SAMPLE SESSION(SILENT MODE)
===========================
./irca.sh all "stadt48.us.oracle.com 1521 stadt48.us.oracle.com" welcome1 -overwrite ORABPEL ORABPEL1 ORAESB ORAESB1 ORAWSM ORAWSM1

Integration Repository Creation Assistant (IRCA) 10.1.3.1.0
(c) Copyright 2006 Oracle Corporation. All rights reserved.

Running IRCA for all product(s):
 connection="stadt48.us.oracle.com 1521 stadt48.us.oracle.com", -overwrite,
orabpelUser=ORABPEL, esbUser=ORAESB, orawsmUser=ORAWSM

Validating database ...
Validating database character set ...
WARNING: The target database character set is WE8ISO8859P1
For multi-byte support, the AL32UTF8 character set is recommended.


Running prerequisite checks for ORABPEL ...
WARNING: This script will overwrite the existing ORABPEL schema.
Loading ORABPEL schema (this may take a few minutes) ...


Running prerequisite checks for ORAESB ...
WARNING: This script will overwrite the existing ORAESB schema.
Loading ORAESB schema (this may take a few minutes) ...


Running prerequisite checks for ORAWSM ...
WARNING: This script will overwrite the existing ORAWSM schema.
Loading ORAWSM schema (this may take a few minutes) ...


INFO: ORABPEL schema contains 236 valid objects.

INFO: ORAESB schema contains 28 valid objects.

INFO: ORAWSM schema contains 90 valid objects.

IRCA completed.
Please check for any ERROR message above and also check the log file 
irca2006-06-06_01-55-48PM.log for any error or other information.

