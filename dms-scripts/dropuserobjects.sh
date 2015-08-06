#!/bin/ksh  
#
if [[ $# != 3 ]] then
  echo "usage: $0 dbConnect dbSchema dbPass"
  echo "warning: All objects will be dropped!"
  exit 7
fi
dbconnect=$1
dbschema=$2
dbschemapass=$3

dropfile=temp_dropObjectdb_"$1"_"$2".sql

echo "
set head off
set echo off
set pages 5000
set lines 80
set verify off
set feedback off

spool $dropfile
select 'DROP table  '||table_name||' ;' from user_tables  ;
--select 'DROP '||object_type||' '||object_name||' ;' from user_objects  ;
select 'select count(*) from user_objects;' from dual;
--select 'select '' ************  Second Try ... ************'' from dual;' from dual;
-- repeat to drop the leftovers!
--select 'DROP table   '||table_name||' ;' from user_tables  ;
--select 'DROP '||object_type||' '||object_name||' ;' from user_objects;

--select 'select count(*) from user_objects;' from dual;
select 'quit;' from dual;
spool off
quit;
" > tempFile_"$1"_"$2".sql
sqlplus $dbschema/$dbschemapass@$dbconnect @tempFile_"$1"_"$2".sql
rm tempFile_"$1"_"$2".sql

sqlplus -s $dbschema/$dbschemapass@$dbconnect @$dropfile
rm $dropfile

echo "
set head off
set echo off
set pages 5000
set lines 80
set verify off
set feedback off

spool $dropfile
select 'DROP table   '||table_name||' ;' from user_tables  ;
--select 'DROP '||object_type||' '||object_name||' ;' from user_objects  ;
select 'select count(*) from user_objects;' from dual;
select 'select '' ************  Second Try ... ************'' from dual;' from dual;
-- repeat to drop the leftovers!
select 'DROP '||object_type||' '||object_name||' ;' from user_objects;

select 'purge recyclebin;' from dual;
select 'select count(*) from user_objects;' from dual;
select 'quit;' from dual;
spool off
quit;
" > tempFile_"$1"_"$2".sql
sqlplus $dbschema/$dbschemapass@$dbconnect @tempFile_"$1"_"$2".sql
rm tempFile_"$1"_"$2".sql

sqlplus -s $dbschema/$dbschemapass@$dbconnect @$dropfile
rm $dropfile





