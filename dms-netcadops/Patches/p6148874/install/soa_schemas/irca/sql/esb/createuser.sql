Rem Example: @createuser.sql oraesb oraesb <sys_passwd> <connect_String>

define oraesb_user=&1
define oraesb_password=&2

define sys_password=&3
define connect_string=&4

connect sys/&sys_password@&connect_string as sysdba;

drop user &oraesb_user cascade;

create user &oraesb_user identified by &oraesb_password;

GRANT EXECUTE ON DBMS_AQADM TO &oraesb_user;
GRANT AQ_ADMINISTRATOR_ROLE TO &oraesb_user;

/*
** Grant privileges TO user &oraesb_user.
*/

GRANT CONNECT,RESOURCE TO &oraesb_user;
GRANT ALTER SESSION TO &oraesb_user;
GRANT ALTER DATABASE TO &oraesb_user;
GRANT CREATE ANY INDEX TO &oraesb_user;
GRANT CREATE ANY SNAPSHOT TO &oraesb_user;
GRANT CREATE DATABASE LINK TO &oraesb_user;
GRANT CREATE SESSION TO &oraesb_user;
GRANT CREATE SYNONYM TO &oraesb_user;
GRANT CREATE VIEW TO &oraesb_user;

GRANT EXECUTE ANY PROCEDURE TO &oraesb_user;
GRANT IMP_FULL_DATABASE TO &oraesb_user;
