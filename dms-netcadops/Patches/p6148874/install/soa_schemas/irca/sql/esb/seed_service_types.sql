Rem
Rem $Header: seed_service_types.sql 20-jun-2006.13:01:14 mahnaray Exp $
Rem
Rem seed_service_types.sql
Rem
Rem Copyright (c) 2005, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      seed_service_types.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mahnaray    06/13/06 - Move all ESB Seeding to XML 
Rem    mahnaray    06/01/06 - Add seeding for MQ and DB adapter 
Rem    mahnaray    05/24/06 - Seeding Endpoint Properties for FTP & File adapters
Rem    ssubbaiy    04/24/06 - 
Rem    mahnaray    04/21/06 - Pre-set Guids for service types 
Rem    ssubbaiy    04/24/06 - 
Rem    mahnaray    04/21/06 - Pre-set Guids for service types 
Rem    gsah        03/30/06 - fix typo \ -> / 
Rem    gsah        03/30/06 - add missing \ at the end 
Rem    ramkmeno    03/04/06 - 
Rem    mahnaray    01/17/06 - Modifying Service Types. Adding Service Sub Types.
Rem    asurpur     10/24/05 - 
Rem    mahnaray    10/24/05 - update serviceTypes 
Rem    mahnaray    10/17/05 - Modifying Display names for service types 
Rem    mahnaray    10/07/05 - Adding Service type tl entries
Rem    sanjain     09/01/05 - Changing service type names 
Rem    rsaha       08/27/05 - 
Rem    rsaha       08/25/05 - rsaha_jdev_deployment
Rem    rsaha       08/25/05 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

insert into ESB_SERVICE_TYPE(GUID, BASE_TYPE_GUID, SERVICE_TYPE, JAVA_CLASS_NAME)  values ('AEFB9A91D10411DA9F363341D0AE9ED7',null,'InboundAdapterService','oracle.tip.esb.server.service.impl.inadapter.InboundAdapterService');

insert into ESB_SERVICE_TYPE(GUID, BASE_TYPE_GUID, SERVICE_TYPE, JAVA_CLASS_NAME, IS_TRANSACTIONAL)  values ('AEFB9A92D10411DA9F363341D0AE9ED7','AEFB9A91D10411DA9F363341D0AE9ED7','File','oracle.tip.esb.server.service.impl.inadapter.InboundAdapterService','N');
insert into ESB_SERVICE_TYPE(GUID, BASE_TYPE_GUID, SERVICE_TYPE, JAVA_CLASS_NAME, IS_TRANSACTIONAL)  values ('AEFB9A93D10411DA9F363341D0AE9ED7','AEFB9A91D10411DA9F363341D0AE9ED7','JMS','oracle.tip.esb.server.service.impl.inadapter.InboundAdapterService','Y');
insert into ESB_SERVICE_TYPE(GUID, BASE_TYPE_GUID, SERVICE_TYPE, JAVA_CLASS_NAME, IS_TRANSACTIONAL)  values ('AEFB9A94D10411DA9F363341D0AE9ED7','AEFB9A91D10411DA9F363341D0AE9ED7','MQ','oracle.tip.esb.server.service.impl.inadapter.InboundAdapterService','Y');
insert into ESB_SERVICE_TYPE(GUID, BASE_TYPE_GUID, SERVICE_TYPE, JAVA_CLASS_NAME, IS_TRANSACTIONAL)  values ('AEFB9A95D10411DA9F363341D0AE9ED7','AEFB9A91D10411DA9F363341D0AE9ED7','AQ','oracle.tip.esb.server.service.impl.inadapter.InboundAdapterService','Y');
insert into ESB_SERVICE_TYPE(GUID, BASE_TYPE_GUID, SERVICE_TYPE, JAVA_CLASS_NAME, IS_TRANSACTIONAL)  values ('AEFB9A96D10411DA9F363341D0AE9ED7','AEFB9A91D10411DA9F363341D0AE9ED7','Apps','oracle.tip.esb.server.service.impl.inadapter.InboundAdapterService','Y');
insert into ESB_SERVICE_TYPE(GUID, BASE_TYPE_GUID, SERVICE_TYPE, JAVA_CLASS_NAME, IS_TRANSACTIONAL)  values ('AEFB9A97D10411DA9F363341D0AE9ED7','AEFB9A91D10411DA9F363341D0AE9ED7','DB','oracle.tip.esb.server.service.impl.inadapter.InboundAdapterService','Y');
insert into ESB_SERVICE_TYPE(GUID, BASE_TYPE_GUID, SERVICE_TYPE, JAVA_CLASS_NAME, IS_TRANSACTIONAL)  values ('AEFB9A98D10411DA9F363341D0AE9ED7','AEFB9A91D10411DA9F363341D0AE9ED7','FTP','oracle.tip.esb.server.service.impl.inadapter.InboundAdapterService','N');
insert into ESB_SERVICE_TYPE(GUID, BASE_TYPE_GUID, SERVICE_TYPE, JAVA_CLASS_NAME, IS_TRANSACTIONAL)  values ('AEFB9AA5D10411DA9F363341D0AE9ED7','AEFB9A91D10411DA9F363341D0AE9ED7','InterConnect','oracle.tip.esb.server.service.impl.inadapter.InboundAdapterService','Y');


insert into ESB_SERVICE_TYPE(GUID, BASE_TYPE_GUID, SERVICE_TYPE, JAVA_CLASS_NAME)  values ('AEFB9A99D10411DA9F363341D0AE9ED7',null,'OutboundAdapterService','oracle.tip.esb.server.service.impl.outadapter.OutboundAdapterService');

insert into ESB_SERVICE_TYPE(GUID, BASE_TYPE_GUID, SERVICE_TYPE, JAVA_CLASS_NAME, IS_TRANSACTIONAL)  values ('AEFB9A9AD10411DA9F363341D0AE9ED7','AEFB9A99D10411DA9F363341D0AE9ED7','File','oracle.tip.esb.server.service.impl.outadapter.OutboundAdapterService','N');
insert into ESB_SERVICE_TYPE(GUID, BASE_TYPE_GUID, SERVICE_TYPE, JAVA_CLASS_NAME, IS_TRANSACTIONAL)  values ('AEFB9A9BD10411DA9F363341D0AE9ED7','AEFB9A99D10411DA9F363341D0AE9ED7','JMS','oracle.tip.esb.server.service.impl.outadapter.OutboundAdapterService','Y');

insert into ESB_SERVICE_TYPE(GUID, BASE_TYPE_GUID, SERVICE_TYPE, JAVA_CLASS_NAME, IS_TRANSACTIONAL)  values ('AEFB9A9CD10411DA9F363341D0AE9ED7','AEFB9A99D10411DA9F363341D0AE9ED7','MQ','oracle.tip.esb.server.service.impl.outadapter.OutboundAdapterService','Y');

insert into ESB_SERVICE_TYPE(GUID, BASE_TYPE_GUID, SERVICE_TYPE, JAVA_CLASS_NAME, IS_TRANSACTIONAL)  values ('AEFB9A9DD10411DA9F363341D0AE9ED7','AEFB9A99D10411DA9F363341D0AE9ED7','AQ','oracle.tip.esb.server.service.impl.outadapter.OutboundAdapterService','Y');
insert into ESB_SERVICE_TYPE(GUID, BASE_TYPE_GUID, SERVICE_TYPE, JAVA_CLASS_NAME, IS_TRANSACTIONAL)  values ('AEFB9A9ED10411DA9F363341D0AE9ED7','AEFB9A99D10411DA9F363341D0AE9ED7','Apps','oracle.tip.esb.server.service.impl.outadapter.OutboundAdapterService','Y');
insert into ESB_SERVICE_TYPE(GUID, BASE_TYPE_GUID, SERVICE_TYPE, JAVA_CLASS_NAME, IS_TRANSACTIONAL)  values ('AEFB9A9FD10411DA9F363341D0AE9ED7','AEFB9A99D10411DA9F363341D0AE9ED7','DB','oracle.tip.esb.server.service.impl.outadapter.OutboundAdapterService','Y');
insert into ESB_SERVICE_TYPE(GUID, BASE_TYPE_GUID, SERVICE_TYPE, JAVA_CLASS_NAME, IS_TRANSACTIONAL)  values ('AEFB9AA0D10411DA9F363341D0AE9ED7','AEFB9A99D10411DA9F363341D0AE9ED7','FTP','oracle.tip.esb.server.service.impl.outadapter.OutboundAdapterService','N');
insert into ESB_SERVICE_TYPE(GUID, BASE_TYPE_GUID, SERVICE_TYPE, JAVA_CLASS_NAME, IS_TRANSACTIONAL)  values ('AEFB9AA4D10411DA9F363341D0AE9ED7','AEFB9A99D10411DA9F363341D0AE9ED7', 'InterConnect','oracle.tip.esb.server.service.impl.outadapter.OutboundAdapterService','Y');

insert into ESB_SERVICE_TYPE(GUID, BASE_TYPE_GUID, SERVICE_TYPE, JAVA_CLASS_NAME)  values ('AEFB9AA1D10411DA9F363341D0AE9ED7', null,'RoutingService','oracle.tip.esb.server.service.EsbRoutingService');

insert into ESB_SERVICE_TYPE(GUID, BASE_TYPE_GUID, SERVICE_TYPE, JAVA_CLASS_NAME)  values ('AEFB9AA2D10411DA9F363341D0AE9ED7', null,'ExternalService','oracle.tip.esb.server.service.impl.outadapter.OutboundAdapterService');

insert into ESB_SERVICE_TYPE(GUID, BASE_TYPE_GUID, SERVICE_TYPE, JAVA_CLASS_NAME)  values ('AEFB9AA3D10411DA9F363341D0AE9ED7', null,'BPELService','oracle.tip.esb.server.service.impl.bpel.BPELService');

commit;
end;

/
