Rem
Rem $Header: seed_default_system.sql 29-jun-2006.21:02:11 mahnaray Exp $
Rem
Rem seed_default_system.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      seed_default_system.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mahnaray    02/13/06 - Seed Default System through a SQL instead of 
Rem                           importing it 
Rem    mahnaray    02/13/06 - Created
Rem

insert into wf_systems (  NAME, DESCRIPTION,  GUID, STATUS, VERSION_ID, 
 LASTMODIFIED_BY, LASTMODIFIED_DATE  , MASTER_GUID, PARAMETERS, 
 DEFERRED_AGENT_GUID , ERROR_AGENT_GUID, CLUSTER_NAME  )  
 values ('DefaultSystem', 'The Default System for ESB Seeded with ESB Install', '96DD76C0971311DABF1A87858E4395A7', 'ENABLED', '1139232135202', 'JDev', '1151595055125', null, null, null, null, 'esb');
 
 insert into wf_agents ( GUID, NAME, SYSTEM_GUID, JAVA_QUEUE_HANDLER,
  DESCRIPTION,QUEUE_NAME, QUEUE_TYPE, DIRECTION, STATUS, NUM_OF_LISTENERS, TYPE, TCF_JNDI )  
 values ('96DD76C1971311DABF1A87858E4395A7', 'OracleASjms/ESBDeferredTopic', '96DD76C0971311DABF1A87858E4395A7', 'oracle.apps.fnd.wf.bes.JMSQueueHandler', null, 'OracleASjms/ESBDeferredTopic', 'DEFERRED', 'IN', 'ENABLED', 1, 'AGENT', 'OracleASjms/MyXATCF');

commit;
