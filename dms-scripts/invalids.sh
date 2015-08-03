:
owners=\'${DBUSER}\',\'${ASTORMDB}\',\'${NETCUSER}\',\'${ADMINDBUSER}\'
OWNERS=`echo $owners |tr [a-z] [A-Z]`
systemConnect=system/Dmssystem11@${DBNAME}

sqlplus -s  $systemConnect << DOFF
set pages 999
set lines 200

select owner, object_type, object_name from all_objects where status = 'INVALID' and owner in (${OWNERS}) ;

exit
DOFF

sqlplus -s  $CTS << SYE
set pages 999
set lines 200

prompt CTS Invalid objects:
select 'CTS', object_type, object_name from user_objects where status = 'INVALID'  ;

exit
SYE

