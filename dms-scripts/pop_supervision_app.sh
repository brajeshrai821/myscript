:

echo "\
spool pop_supervision_app.log

delete from supervision_app;
delete from system_supervision;
commit;

insert into system_supervision (SUPERVISION_ID,SUPERVISION_NAME,SUPERVISION_VALUE) values (0,'application','opmanager');
insert into system_supervision (SUPERVISION_ID,SUPERVISION_NAME,SUPERVISION_VALUE) values (1,'application','dbmessager');" > pop_supervision_app.sql

if [ ! -z $HAS_OUTAGE_ENGINE ]; then
  if [ $HAS_OUTAGE_ENGINE = "Y" ]; then
    echo "insert into system_supervision (SUPERVISION_ID,SUPERVISION_NAME,SUPERVISION_VALUE) values (2,'application','outageEngine');" >> pop_supervision_app.sql
  fi
fi

echo "\
insert into system_supervision (SUPERVISION_ID,SUPERVISION_NAME,SUPERVISION_VALUE) values (3,'application','filterEngine');
insert into system_supervision (SUPERVISION_ID,SUPERVISION_NAME,SUPERVISION_VALUE) values (7,'application','incrUpd');
insert into system_supervision (SUPERVISION_ID,SUPERVISION_NAME,SUPERVISION_VALUE) values (8,'application','caseserver');
insert into system_supervision (SUPERVISION_ID,SUPERVISION_NAME,SUPERVISION_VALUE) values (9,'application','faultloc');
insert into system_supervision (SUPERVISION_ID,SUPERVISION_NAME,SUPERVISION_VALUE) values (15,'application','incrXref');
insert into system_supervision (SUPERVISION_ID,SUPERVISION_NAME,SUPERVISION_VALUE) values (18,'application','analogChange');" >> pop_supervision_app.sql

if [ ! -z $SIDL_CONTEXT ]; then
  echo "insert into system_supervision (SUPERVISION_ID,SUPERVISION_NAME,SUPERVISION_VALUE) values (20,'application','scadaManager');" >> pop_supervision_app.sql
  echo "insert into system_supervision (SUPERVISION_ID,SUPERVISION_NAME,SUPERVISION_VALUE) values (21,'application','scadaGateway');" >> pop_supervision_app.sql
  echo "insert into system_supervision (SUPERVISION_ID,SUPERVISION_NAME,SUPERVISION_VALUE) values (22,'application','krbRenew');" >> pop_supervision_app.sql
fi

if [ ! -z $SS_MON_VVO ]; then
  if [ $SS_MON_VVO = "Y" ]; then
    echo "insert into system_supervision (SUPERVISION_ID,SUPERVISION_NAME,SUPERVISION_VALUE) values (23,'application','VVO');" >> pop_supervision_app.sql
  fi
fi

if [ ! -z $SS_MON_UBLF ]; then
  if [ $SS_MON_UBLF = "Y" ]; then
    echo "insert into system_supervision (SUPERVISION_ID,SUPERVISION_NAME,SUPERVISION_VALUE) values (24,'application','LF');" >> pop_supervision_app.sql
  fi
fi

if [ ! -z $SS_MON_RSA ]; then
  if [ $SS_MON_RSA = "Y" ]; then
    echo "insert into system_supervision (SUPERVISION_ID,SUPERVISION_NAME,SUPERVISION_VALUE) values (25,'application','RSA');" >> pop_supervision_app.sql
  fi
fi

echo "\

insert into supervision_app (SUPERVISION_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) values (0,'command line','$CADOPS_HOME/bin/opmanager $DBUSER dbpwd dbnam all GLOBAL 1');
insert into supervision_app (SUPERVISION_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) values (0,'critical application','1');
insert into supervision_app (SUPERVISION_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) values (0,'redirect12','$CADOPS_ROOT/logs/opmanager_ss.log');
insert into supervision_app (SUPERVISION_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) values (0,'run in backup mode','1');
insert into supervision_app (SUPERVISION_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) values (1,'command line','$CADOPS_HOME/bin/dbmessager $DBUSER dbatp dbnam 1 GLOBAL');
insert into supervision_app (SUPERVISION_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) values (1,'redirect12','$CADOPS_ROOT/logs/dbmessager_ss.log');" >> pop_supervision_app.sql


if [ ! -z $HAS_OUTAGE_ENGINE ]; then
  if [ $HAS_OUTAGE_ENGINE = "Y" ]; then
    echo "insert into supervision_app (SUPERVISION_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) values (2,'command line','$CADOPS_HOME/bin/outageEngine dbnam Y $DBUSER');" >> pop_supervision_app.sql
    echo "insert into supervision_app (SUPERVISION_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) values (2,'redirect12','$CADOPS_ROOT/logs/outageEngine_ss.log');" >> pop_supervision_app.sql
  fi
fi

echo "\
insert into supervision_app (SUPERVISION_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) values (3,'command line','$CADOPS_HOME/bin/filterEngine $DBUSER dbpwd dbnam all 1000');
insert into supervision_app (SUPERVISION_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) values (3,'redirect12','$CADOPS_ROOT/logs/filterEngine_ss.log');

insert into supervision_app (SUPERVISION_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) values (7,'command line','$CADOPS_HOME/bin/incrUpd -u GLOBAL $DBUSER');
insert into supervision_app (SUPERVISION_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) values (7,'redirect12','$CADOPS_ROOT/logs/incrUpd_ss.log');
insert into supervision_app (SUPERVISION_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) values (8,'command line','$CADOPS_HOME/bin/caseserver $DBUSER dbpwd dbnam GLOBAL');
insert into supervision_app (SUPERVISION_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) values (8,'redirect12','$CADOPS_ROOT/logs/caseserver_ss.log');
insert into supervision_app (SUPERVISION_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) values (9,'command line','$CADOPS_HOME/bin/faultlocation Y $DBUSER dbpwd dbnam fl all GLOBAL');
insert into supervision_app (SUPERVISION_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) values (9,'redirect12','$CADOPS_ROOT/logs/faultlocation_ss.log');
insert into supervision_app (SUPERVISION_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) values (15,'command line','$CADOPS_HOME/bin/incrXref -u GLOBAL -d $DBUSER');
insert into supervision_app (SUPERVISION_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) values (15,'redirect12','$CADOPS_ROOT/logs/incrXref_ss.log');
insert into supervision_app (SUPERVISION_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) values (18,'command line','$CADOPS_HOME/bin/analogChange -u GLOBAL -s 10');
insert into supervision_app (SUPERVISION_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) values (18,'redirect12','$CADOPS_ROOT/logs/analogChange_ss.log');" >> pop_supervision_app.sql

if [ ! -z $SIDL_CONTEXT ]; then
  echo "insert into supervision_app (SUPERVISION_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) values (20,'command line','$CADOPS_HOME/bin/scadaManager $DBUSER dbpwd dbnam all GLOBAL 500');" >> pop_supervision_app.sql
  echo "insert into supervision_app (SUPERVISION_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) values (20,'redirect12','$CADOPS_ROOT/logs/scadaManager_ss.log');" >> pop_supervision_app.sql
  echo "insert into supervision_app (SUPERVISION_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) values (21,'command line','$CADOPS_HOME/bin/scadaGateway -context $SIDL_CONTEXT -chunk 10000 -link 1');" >> pop_supervision_app.sql
  echo "insert into supervision_app (SUPERVISION_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) values (21,'redirect12','$CADOPS_ROOT/logs/scadaGateway_ss.log');" >> pop_supervision_app.sql
  echo "insert into supervision_app (SUPERVISION_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) values (22,'command line','$CADOPS_HOME/bin/krbRenew 30 60');" >> pop_supervision_app.sql
  echo "insert into supervision_app (SUPERVISION_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) values (22,'redirect12','$CADOPS_ROOT/logs/krbRenew_ss.log');" >> pop_supervision_app.sql
fi

if [ ! -z $SS_MON_VVO ]; then
  if [ $SS_MON_VVO = "Y" ]; then
    echo "insert into supervision_app (SUPERVISION_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) values (23,'windows server','1');" >> pop_supervision_app.sql
    echo "insert into supervision_app (SUPERVISION_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) values (23,'heartbeat age','30');" >> pop_supervision_app.sql
    echo "insert into supervision_app (SUPERVISION_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) values (23,'redirect12','$CADOPS_ROOT/logs/windowsVVO_ss.log');" >> pop_supervision_app.sql
  fi
fi

if [ ! -z $SS_MON_UBLF ]; then
  if [ $SS_MON_UBLF = "Y" ]; then
    echo "insert into supervision_app (SUPERVISION_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) values (24,'windows server','1');" >> pop_supervision_app.sql
    echo "insert into supervision_app (SUPERVISION_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) values (24,'heartbeat age','30');" >> pop_supervision_app.sql
    echo "insert into supervision_app (SUPERVISION_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) values (24,'redirect12','$CADOPS_ROOT/logs/windowsUBLF_ss.log');" >> pop_supervision_app.sql
  fi
fi

if [ ! -z $SS_MON_RSA ]; then
  if [ $SS_MON_RSA = "Y" ]; then
    echo "insert into supervision_app (SUPERVISION_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) values (25,'windows server','1');" >> pop_supervision_app.sql
    echo "insert into supervision_app (SUPERVISION_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) values (25,'heartbeat age','30');" >> pop_supervision_app.sql
    echo "insert into supervision_app (SUPERVISION_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE) values (25,'redirect12','$CADOPS_ROOT/logs/windowsRSA_ss.log');" >> pop_supervision_app.sql
  fi
fi

echo "\

set pages 9999
set lines 150
col attribute_value format a80
select * from supervision_app order by supervision_id, attribute_name;

col SUPERVISION_VALUE format a80
select * from system_supervision order by SUPERVISION_ID;

spool off
exit
" >> pop_supervision_app.sql
