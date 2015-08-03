Rem
Rem $Header: create_esb_topics.sql 21-jun-2006.18:03:48 apatel Exp $
Rem
Rem create_esb_topics.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      create_esb_topics.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apatel      06/21/06 - Created
Rem


CREATE OR REPLACE PROCEDURE create_queue (qname VARCHAR2)
AS
  qtablename VARCHAR2(110) := qname;

BEGIN

  BEGIN
    dbms_aqadm.stop_queue (queue_name => qname);
  EXCEPTION
  WHEN OTHERS THEN
    null;
  END;

  BEGIN
    dbms_aqadm.drop_queue (queue_name => qname);
  EXCEPTION
  WHEN OTHERS THEN
    null;
  END;

  BEGIN
    dbms_aqadm.drop_queue_table (Queue_table => qtablename);
  EXCEPTION
  WHEN OTHERS THEN
    null;
  END;

  dbms_aqadm.create_queue_table(Queue_table => qtablename,
 			        Queue_payload_type => 'SYS.AQ$_JMS_TEXT_MESSAGE',
				multiple_consumers => true,
                        	compatible => '8.1');
  dbms_aqadm.create_queue (Queue_name => qname,
			   Queue_table => qtablename);
  dbms_aqadm.start_queue(qname);
END;
/

BEGIN
  create_queue('ESB_JAVA_DEFERRED');
  create_queue('ESB_CONTROL');
  create_queue('ESB_ERROR');
  create_queue('ESB_ERROR_RETRY');
  create_queue('ESB_MONITOR');
END;
/