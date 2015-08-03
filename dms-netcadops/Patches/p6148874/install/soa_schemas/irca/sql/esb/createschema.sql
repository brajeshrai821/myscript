Rem
Rem $Header: createschema.sql 14-jul-2006.12:24:40 sawadhwa Exp $
Rem
Rem createschema.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      createschema.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sawadhwa    07/14/06 - XbranchMerge 
Rem                           sawadhwa_irca_add_esb_topics_5328476 from main 
Rem    gsah        03/21/06 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

@@wfeventc.sql

@@wfeventv.sql

@@seed_service_types.sql

@@seed_default_system.sql

@@create_esb_topics.sql

