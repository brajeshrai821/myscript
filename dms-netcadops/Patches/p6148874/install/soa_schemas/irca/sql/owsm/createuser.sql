Rem Example: @createuser.sql orawsm orawsm <sys_passwd> <connect_String>

define orawsm_user=&1
define orawsm_password=&2

define sys_password=&3
define connect_string=&4

connect sys/&sys_password@&connect_string as sysdba;

drop user &orawsm_user cascade;

create user &orawsm_user identified by &orawsm_password;


GRANT CONNECT,RESOURCE TO &orawsm_user;