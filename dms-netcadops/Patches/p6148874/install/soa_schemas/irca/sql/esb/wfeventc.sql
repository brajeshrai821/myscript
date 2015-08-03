REM $Header: wfeventc.sql 09-sep-2006.02:12:36 ssubbaiy Exp $
REM +======================================================================+
REM | Copyright (c) 2006 Oracle Corporation Redwood Shores, California, USA|
REM |                       All rights reserved.                           |
REM +======================================================================+
REM NAME
REM     wfeventc.sql  -  WorkFlow EVENT Manager system Create tables.
REM DESCRIPTION
REM     Creates the tables associated with the Event Manager system.
REM     In case of changes, ensure it is reflected in drop_esb_tables.sql
REM MODIFICATION LOG:
REM     05/2002 VSHANMUG Bug 2353079 - Added new column SECURITY_GROUP_ID 
REM             to all the tables
REM	09/2002 VARRAJAR Modified SECURITY_GROUP_ID to be varchar2
REM			 Bug 2558446 - Added new columns CUSTOMIZATION_LEVEL
REM			 and LICENSED_FLAG
REM     01/2003	VARRAJAR Modified CUSTOMIZASTION_LEVEL and LICENSED_FLAG
REM			 to be NOT NULL
REM     04/2003 VARRAJAR Added new table and indexes WF_BES_SUBSCRIBER_PINGS
REM +======================================================================+

REM Connect to base account
REM (autopatch will run all scripts in apps account)

REM Continue in case of error where tables aready exist
WHENEVER SQLERROR CONTINUE;

-- In most cases, we should not limit the table to have initial extent 10k and
-- next extent 10k.  Use the default value from tablespace is fine.

/*
** WF_EVENTS
* Logical Keys - service - name,owner_guid,system_guid
*/
CREATE TABLE WF_EVENTS
(
 GUID               VARCHAR2(48)   NOT NULL,     -- PK, GUID
 NAME               VARCHAR2(2000)  NOT NULL,     -- UK, names are internal names in ESB hence have to be large for larg system names.
 TYPE               VARCHAR2(16)   NOT NULL,     -- (EVENT)OR OPERATION | (EVENTGROUP) or SERVICE | SERVICEGROUP | MYROLE  | PARTNERROLE
 STATUS             VARCHAR2(8)    NOT NULL,     -- ENABLED | DISABLED | BROKEN
 GENERATE_FUNCTION  VARCHAR2(240)          ,     -- generate function
 JAVA_GENERATE_FUNC   VARCHAR2(240)        ,     -- Java Generate Function
 OWNER_NAME         VARCHAR2(30)           ,     -- owning program
 OWNER_TAG          VARCHAR2(30)           ,     -- owning program tag
 CUSTOMIZATION_LEVEL VARCHAR2(1)   default 'L' , -- Customization Level
 LICENSED_FLAG       VARCHAR2(1)   default 'Y' , -- Licensed Flag
 SECURITY_GROUP_ID  VARCHAR2(32),
 ------- Added for ESB : Begin -------------
 ------- Only applicable for EventGroup [Service] :BEGIN ------------
 IMPLEMENTATION_WSDL_URL       VARCHAR2(4000) ,  -- esb://myesbproject/createItem.wsdl
 IMPLEMENTATION_PORTTYPE_NAME  VARCHAR2(2000) ,
 IMPLEMENTATION_PORTTYPE_NS    VARCHAR2(4000) ,
 PARTNERLINKTYPE_NAME          VARCHAR2(2000) ,    -- FOR SERVICE HAVING TWO ROLES
 PARTNERLINKTYPE_NS            VARCHAR2(2000),   -- FOR SERVICE HAVING TWO ROLES
 SERVICE_TYPE_GUID             VARCHAR2(48),
 SERVICE_PARAMETERS            VARCHAR2(2000), 
 ENDPOINT_PROPERTIES           VARCHAR2(2000),   -- For storing Runtime service end point properties
 SYSTEM_GUID                   VARCHAR2(48) ,    -- owning system for the service
 ISWSDLEDITABLE                VARCHAR2(1) ,     -- YES OR NO [ Y | N ] 
 OWNER_GUID                    VARCHAR2(48),     -- Added to store parent child relationship in this table instead of EVENTGROUP table
 SOAP_ENDPOINT								 VARCHAR2(8),      -- ENABLED | DISABLED for services which can be SOAP end points.
 DESCRIPTION                   VARCHAR2(4000),   -- Description field is not translatable. Hence adding it here.
 ------- Version Info -------------------
 LASTMODIFIED_DATE             VARCHAR2(48),     -- Last modified time, stored as Millis from January 1, 1970, 00:00:00 GMT
 LASTMODIFIED_BY               VARCHAR2(2000),    -- Last modified user name
 VERSION_ID                    VARCHAR2(48),     -- Currently the millis from January 1, 1970, 00:00:00 GMT, but can be changed in the future.
 ------- Only applicable for EventGroup :END ------------ 
 REQ_XML_VALIDATION     VARCHAR2(1),             -- Values will be Y | N ONLY APPLICABLE FOR EVENT [OPERATION]
 REP_XML_VALIDATION     VARCHAR2(1),              -- Values will be Y | N ONLY APPLICABLE FOR EVENT [OPERATION]
 MEP                    VARCHAR2(32)              -- Values will be ONE_WAY | REQUEST_RESPONSE
 -------------- Added for ESB : END -------------
);

/*
** WF_EVENTS_TL
* DISPLAY_NAME is deprecated for ESB Project
* Logical Keys - GUID + JAVA_LOCALE + (DISPLAY_NAME or DESCRIPTION)
*/
CREATE TABLE WF_EVENTS_TL
(
 GUID               VARCHAR2(48)    NOT NULL,    -- PK, GUID
 LANGUAGE           VARCHAR2(40),                -- language code, changed to a nullable field for ESB
 DISPLAY_NAME       VARCHAR2(2000)    ,
 DESCRIPTION        VARCHAR2(4000),
 SOURCE_LANG	      VARCHAR2(40),                -- changed to a nullable field for ESB
 --------------- Added for ESB : Begin ----------------
 JAVA_LOCALE        VARCHAR2(16),                -- Java locale e.g., en_US or fr_CA_MAC
 --------------- Added for ESB : END ----------------
 SECURITY_GROUP_ID  VARCHAR2(32)
);

/*
** WF_EVENT_GROUPS
*/
CREATE TABLE WF_EVENT_GROUPS
(
 GROUP_GUID         VARCHAR2(48)     NOT NULL,   -- PK, FK to WF_EVENTS, Group
 MEMBER_GUID        VARCHAR2(48)     NOT NULL,   -- PK, FK to WF_EVENTS, Event 
 SECURITY_GROUP_ID  VARCHAR2(32)
);

/*
** WF_SYSTEMS
* Logical Keys - GUID 
*/
CREATE TABLE WF_SYSTEMS
(
 GUID               VARCHAR2(48)   NOT NULL,     -- PK
 NAME               VARCHAR2(2000) NOT NULL,     -- UK
 MASTER_GUID        VARCHAR2(48),                -- FK to WF_SYSTEMS
 -- DISPLAY_NAME       VARCHAR2(2000)   NOT NULL,     -- TL (on base table)
 DESCRIPTION        VARCHAR2(4000),               -- Currenlty not using TL Table
 --------------- Added for ESB : Begin ----------------
 PARAMETERS          VARCHAR2(4000),             -- BPEL Server related information will be stored as NV pair
 STATUS              VARCHAR2(8) ,               -- UP | DOWN | PAUSE
 DEFERRED_AGENT_GUID VARCHAR2(48) ,              -- Points to the default agent in WF_AGENTS table
 ERROR_AGENT_GUID    VARCHAR2(48) ,              -- Points to the default error agent in WF_AGENTS table
 CLUSTER_NAME        VARCHAR2(2000) ,            -- Can be associated with J2EE cluster 
 ------- Version Info -------------------
 LASTMODIFIED_DATE             VARCHAR2(48),     -- Last modified time, stored as Millis from January 1, 1970, 00:00:00 GMT
 LASTMODIFIED_BY               VARCHAR2(2000),   -- Last modified user name
 VERSION_ID                    VARCHAR2(48),     -- Currently the millis from January 1, 1970, 00:00:00 GMT, but can be changed in the future.
 --------------- Added based on feedback from Sachin ----------------
  CONNECTION_CONFIG_DETAILS   VARCHAR2(4000),
 --------------- Added based on feedback from Sachin  : END----------------
 --------------- Added for ESB : END ----------------
 SECURITY_GROUP_ID   VARCHAR2(32)
);

/*
** WF_AGENTS
* Logical Keys - GUID 
*/
CREATE TABLE WF_AGENTS
(
 GUID               VARCHAR2(48)   NOT NULL,     -- PK, GUID
 NAME               VARCHAR2(2000)   NOT NULL,     -- UK1 logical name
 SYSTEM_GUID        VARCHAR2(48)   NOT NULL,     -- FK to WF_SYSTEMS.GUID
 PROTOCOL           VARCHAR2(2000),                -- AQ, SMTP, custom...
 ADDRESS            VARCHAR2(2000),               -- 
 QUEUE_HANDLER      VARCHAR2(2000),               -- queue handler package name
 JAVA_QUEUE_HANDLER   VARCHAR2(2000),             -- Java Queue Handler
 QUEUE_NAME         VARCHAR2(2000),                -- 
 DIRECTION          VARCHAR2(8)    NOT NULL,     -- IN | OUT | ANY
 STATUS             VARCHAR2(8)    NOT NULL,     -- ENABLED | DISABLED
 TYPE               VARCHAR2(8)    DEFAULT 'AGENT' NOT NULL, -- AGENT | GROUP
 --------------- Added for ESB : Begin ----------------
 NUM_OF_LISTENERS   INTEGER ,                    -- -1 FOR AUTOMATIC
 QUEUE_TYPE         VARCHAR2(8),                 -- DEFERRED | ERROR | RETRY | MONITOR | CONTROL
 TCF_JNDI           VARCHAR2(2000),              -- Topic Connection Factory
 --------------- Added for ESB : END ----------------
 -- DISPLAY_NAME       VARCHAR2(2000)   NOT NULL,     -- TL (on base table)
 DESCRIPTION        VARCHAR2(4000),               -- Currently not using the TL Table
 --------------- Added based on feedback from Sachin ----------------
 CATEGORY            VARCHAR2(30),
 --------------- Added based on feedback from Sachin  : END----------------
 SECURITY_GROUP_ID  VARCHAR2(32)
);
 
/*
** WF_EVENT_SUBSCRIPTIONS
* Logical Keys - GUID 
*/
CREATE TABLE WF_EVENT_SUBSCRIPTIONS
(
 GUID               VARCHAR2(48)      NOT NULL, -- PK, GUID
 SYSTEM_GUID        VARCHAR2(48)      NOT NULL, -- FK - WF_SYSTEMS.GUID
 SOURCE_TYPE        VARCHAR2(8)       NOT NULL, -- LOCAL | EXTERNAL | ANY
 SOURCE_AGENT_GUID  VARCHAR2(48),               -- FK to WF_AGENTS
 EVENT_FILTER_GUID  VARCHAR2(48)      NOT NULL, -- FK to WF_EVENTS  
 PHASE              NUMBER,                     -- order in which subs are executed
 STATUS             VARCHAR2(8)       NOT NULL, -- ENABLED | DISABLED | BROKEN
 RULE_DATA          VARCHAR2(8)       NOT NULL, -- KEY | MESSAGE
 OUT_AGENT_GUID     VARCHAR2(48),               -- outbound agent, if sending
 TO_AGENT_GUID      VARCHAR2(48),               -- destination agent, if sending
 PRIORITY           NUMBER,                     -- 1 - 100 priority for message
 RULE_FUNCTION      VARCHAR2(2000),              -- code to run
 STANDARD_TYPE      VARCHAR2(2000),
 STANDARD_CODE      VARCHAR2(2000) ,
 JAVA_RULE_FUNC     VARCHAR2(2000) ,             -- Java Rule Function
 ON_ERROR_CODE      VARCHAR2(2000) ,
 ACTION_CODE        VARCHAR2(2000),
 WF_PROCESS_TYPE    VARCHAR2(2000),               -- workflow process type
 WF_PROCESS_NAME    VARCHAR2(2000),               -- workflow process name
 PARAMETERS         VARCHAR2(4000),             -- other parameters
 OWNER_NAME         VARCHAR2(2000),               -- owning program
 OWNER_TAG          VARCHAR2(2000),               -- owning program tag
 CUSTOMIZATION_LEVEL VARCHAR2(1)   default 'L' , -- Customization Level
 LICENSED_FLAG       VARCHAR2(1)   default 'Y' , -- Licensed Flag
 EXPRESSION         VARCHAR2(4000),             -- sql rule to be evaluated
 -- DESCRIPTION        VARCHAR2(4000),              -- TL (on base table)
 SECURITY_GROUP_ID  VARCHAR2(32),
 INVOCATION_ID      NUMBER,
 MAP_CODE           VARCHAR2(2000),
 --------------- Added for ESB : Begin ---------------- 
 TARGET_EVENT_GUID  VARCHAR2(48),               -- FK to WF_EVENTS TO CAPTURE TARGET EVENT
 -- FILTER_TERM_GUID         VARCHAR2(48)       -- FKKEY TO TERM TABLE FOR SUBSCRIPTION FILTER 
 FILTER_EXPRESSION  VARCHAR2(4000),             -- /Customer/Address/Shipping/ID
                                                -- {namespace ns0="http://www.oracle.com/Customer" 
                                                -- namespace ns1="http://www.oracle.com/Address"}
 --------------- Added for Request-Reply-Fault Handling -------------
 REPLY_HANDLER_GUID           VARCHAR2(48),     -- GUID of the request handler service Operation - FK to WF_EVENTS table
 FAULT_HANDLER_GUID           VARCHAR2(48),     -- GUID of the fault handler service Operation - FK to WF_EVENTS table
 REQUEST_XSL_FILE_LOCATION    VARCHAR2(2000),   -- Request XSL File Location
 REPLY_XSL_FILE_LOCATION      VARCHAR2(2000),   -- Reply XSL File Location
 FAULT_XSL_FILE_LOCATION      VARCHAR2(2000),   -- Fault XSL File Location
 ATTACH_RQ_PAYLOAD_WITH_REPLY  VARCHAR2(1),     -- Y | N to indicate request payload needs to be passed along with reply
 ATTACH_RQ_PAYLOAD_WITH_FAULT  VARCHAR2(1),     -- Y | N to indicate request payload needs to be passed along with fault
 ------- Version Info -------------------
 LASTMODIFIED_DATE            VARCHAR2(48),     -- Last modified time, stored as Millis from January 1, 1970, 00:00:00 GMT
 LASTMODIFIED_BY              VARCHAR2(2000),    -- Last modified user name
 VERSION_ID                   VARCHAR2(48),     -- Currently the millis from January 1, 1970, 00:00:00 GMT, but can be changed in the future.
 -------------- Added for ESB : End Here -----------------
 --------------- Added based on feedback from Sachin ----------------
 EXECUTION_SYSTEM_GUID  VARCHAR2(48)
 --------------- Added based on feedback from Sachin  : END----------------
);

/*
** WF_AGENT_GROUPS
*/
CREATE TABLE WF_AGENT_GROUPS
(
  GROUP_GUID          VARCHAR2(48) NOT NULL,
  MEMBER_GUID         VARCHAR2(48) NOT NULL,
  SECURITY_GROUP_ID  VARCHAR2(32)
);

/*
** WF_BES_SUBSCRIBER_PINGS
*/
CREATE TABLE WF_BES_SUBSCRIBER_PINGS
(
   PING_NUMBER        NUMBER NOT NULL,
   PING_TIME          DATE NOT NULL,
   QUEUE_NAME         VARCHAR2(30) NOT NULL,
   SUBSCRIBER_NAME    VARCHAR2(30) NOT NULL,
   STATUS             VARCHAR2(30) NOT NULL,
   ACTION_TIME        DATE NOT NULL,
   SECURITY_GROUP_ID  VARCHAR2(32)
);

------------------------------------------------
------------ESB New Tables Begin Here-----------
------------------------------------------------ 
 
--
-- ESB_TERM
--
--CREATE TABLE ESB_TERM
--(
-- GUID          VARCHAR2(48) NOT NULL,
-- NAME          VARCHAR2(240), -- field name 
-- OWNER_TAG     VARCHAR2(32) NOT NULL,
-- SECURITY_GROUP_ID  VARCHAR2(32)
--);

--
-- ESB_TERM_TL
--
--CREATE TABLE ESB_TERM_TL
--(
-- TERM_GUID          VARCHAR2(48)   NOT NULL,     -- PK, GUID
-- LANGUAGE           VARCHAR2(8)    NOT NULL,     -- language code
-- DISPLAY_NAME       VARCHAR2(2000)   NOT NULL,
-- DESCRIPTION        VARCHAR2(4000)         ,
-- SOURCE_LANG        VARCHAR2(4)    NOT NULL
--);

--
--TERM IMPLEMENTATION INTERSECTION TABLE
--
--CREATE TABLE ESB_TERM_IMPL
--(
-- TERM_GUID         VARCHAR2(48)   NOT NULL, -- FK TERM GUID
-- EVENT_GUID        VARCHAR2(48)   NOT NULL, -- FK CONTEXT EVENT GUID
-- XPATH             VARCHAR2(4000) NOT NULL, -- XPATH BIND PARAMETER
-- NS_PREFIX_MAPPING VARCHAR2(4000)           -- XPATH NAMESPACE PREFIX MAPPING COMMA SEPERATED
--);


--
-- ESB_SERVICE_TYPE
-- Logical Keys - GUID 
--
CREATE TABLE ESB_SERVICE_TYPE
(
 GUID                VARCHAR2(48) NOT NULL,
 BASE_TYPE_GUID			 VARCHAR2(48), -- Refers to its parent Service Type
 SERVICE_TYPE        VARCHAR2(2000), -- LIST OF PREDEFINED STRINGS i.e. INBOUND ADAPTERSERVICE , O/BADAPTERSERVICE , ROUTINGSERVICE
 JAVA_CLASS_NAME     VARCHAR2(2000),
 IS_TRANSACTIONAL    VARCHAR2(1) DEFAULT 'N' NOT NULL
);

/**
 * ESB_ENDPOINT_PROPERTIES
 * To store parameters related to service types.
 * Logical Keys - SERVICETYPE_GUID 
 */
-- CREATE TABLE ESB_ENDPOINT_PROPERTIES
-- (
--  SERVICETYPE_GUID    VARCHAR2(48) NOT NULL,
--  PARAMETER_NAME	     VARCHAR2(32),
--  DISPLAY_NAME_KEY		 VARCHAR2(32),  -- Resource Bundle Key
--  DESCRIPTION_KEY		 VARCHAR2(32),  -- Resource Bundle Key
--  ISEDITABLE					 VARCHAR2(1) DEFAULT 'N'
-- );

/**
* ESB_INVOCATION
* Logical Keys - GUID 
*/
CREATE TABLE ESB_INVOCATION
(
 OWNING_SERVICE_GUID VARCHAR2(48) NOT NULL, -- THIS CAN BE ONLY SERVICE FKKEY TO WF_EVENT GUID WITH TYPE SERVICE
 TARGET_SERVICE_GUID VARCHAR2(48),          -- THIS CAN BE SERVICE OR OPERATION FKKEY TO WF_EVENT GUID NULLABLE
 ---- THIS WSDL INFORMATION FOR INBOUND SERVICE WHICH DOESN'T IMPLEMENT ANY WSDL BUT USES SOME INTERFACE TO TALK TO ESB ------
 INTERFACE_WSDL_URL   VARCHAR2(4000) ,      -- esb://myesbproject/createItem.wsdl
 INTERFACE_PORTTYPE_NAME  VARCHAR2(2000) ,
 INTERFACE_PORTTYPE_NS    VARCHAR2(4000),
 PARTNERLINKTYPE_NAME  VARCHAR2(2000) ,       -- FOR SERVICE HAVING TWO ROLES
 PARTNERLINKTYPE_NS    VARCHAR2(4000)       -- FOR SERVICE HAVING TWO ROLES 
);

--
-- ESB_XREF_META - Table holding all XRef tables [i.e. virtual tables].
--
--CREATE TABLE ESB_XREF
--(
--   GUID          VARCHAR2(48) NOT NULL, 
--   NAME          VARCHAR2(32), -- XRef  name. each user defined XRef  corresponds to a new entry in this table
--   OWNER_TAG     VARCHAR2(32) NOT NULL
--);

--
-- ESB_XREF_TL - Table holding i8n'ed metadata for all XRef tables [i.e. virtual tables].
--
--create table ESB_XREF_TL
--(
--   XREF_GUID          VARCHAR2(48)   NOT NULL,  -- FK to ESB_XREF.GUID
--   LANGUAGE           VARCHAR2(8)    NOT NULL,  -- language code
--   DISPLAY_NAME       VARCHAR2(2000)   NOT NULL,
--   DESCRIPTION        VARCHAR2(4000)         ,
--   SOURCE_LANG	    VARCHAR2(4)    NOT NULL,
--   SECURITY_GROUP_ID  VARCHAR2(32)
--);

--
-- ESB_XREF_ COLUMNS - Holds row-major metadata of all particupating systems  for an XRef, classified by XRef.
--
--create table ESB_XREF_COLUMNS
--(
-- SYSTEM_NAME VARCHAR2(100)  NOT NULL, -- The name of the Systems being cross referenced
-- XREF_GUID   VARCHAR2(48) NOT NULL -- The GUID of the XRef FK To ESB_XREF
--);

------------------------------------------------
------------ESB TL Tables ----------------
------------------------------------------------ 
/*
* DISPLAY_NAME is deprecated for ESB Project
*/
CREATE TABLE ESB_SYSTEMS_TL
(
 GUID               VARCHAR2(48)    NOT NULL,    -- PK, GUID
 LANGUAGE           VARCHAR2(40),                -- language code
 DISPLAY_NAME       VARCHAR2(2000)    ,
 DESCRIPTION        VARCHAR2(4000),
 --SOURCE_LANG	      VARCHAR2(40)    NOT NULL,
 JAVA_LOCALE        VARCHAR2(16),                -- The Java locale code
 SECURITY_GROUP_ID  VARCHAR2(32)
);
/*
* DISPLAY_NAME is deprecated for ESB Project
*/
CREATE TABLE ESB_AGENTS_TL
(
 GUID               VARCHAR2(48)    NOT NULL,    -- PK, GUID
 LANGUAGE           VARCHAR2(40),                -- language code
 DISPLAY_NAME       VARCHAR2(2000)    NOT NULL,
 DESCRIPTION        VARCHAR2(4000),
 --SOURCE_LANG	      VARCHAR2(40)    NOT NULL,
 JAVA_LOCALE        VARCHAR2(16),                -- The Java locale code
 SECURITY_GROUP_ID  VARCHAR2(32)
);

/*
* DISPLAY_NAME is deprecated for ESB Project
*/
CREATE TABLE ESB_SUBSCRIPTIONS_TL
(
 GUID               VARCHAR2(48)    NOT NULL,    -- PK, GUID
 LANGUAGE           VARCHAR2(40),                -- language code
 DISPLAY_NAME       VARCHAR2(2000)    NOT NULL,
 DESCRIPTION        VARCHAR2(4000),
 -- SOURCE_LANG	      VARCHAR2(40)    NOT NULL,
 JAVA_LOCALE        VARCHAR2(16),                -- The Java locale code
 SECURITY_GROUP_ID  VARCHAR2(32)
);

/*
* DISPLAY_NAME is deprecated for ESB Project
*/
CREATE TABLE ESB_SERVICE_TYPE_TL
(
 GUID               VARCHAR2(48)    NOT NULL,    -- PK, GUID
 LANGUAGE           VARCHAR2(40),                -- language code
 DISPLAY_NAME       VARCHAR2(2000)    NOT NULL,
 DESCRIPTION        VARCHAR2(4000),
 -- SOURCE_LANG	      VARCHAR2(40)    NOT NULL,
 JAVA_LOCALE        VARCHAR2(16),                -- The Java locale code
 SECURITY_GROUP_ID  VARCHAR2(32)
);

------------------------------------------------
------------ESB Instance Tables ----------------
------------------------------------------------ 

CREATE TABLE ESB_ACTIVITY
(
 ID                     NUMBER         NOT NULL, 
 FLOW_ID                VARCHAR2(256)   NOT NULL,     
 SUB_FLOW_ID            VARCHAR2(48),
 SEQ                    NUMBER,
 SUB_FLOW_SEQ           NUMBER(3),
 BATCH_ID               VARCHAR2(48),     
 SOURCE                 VARCHAR2(48),              -- SERVICE_GUID | 'SOAP' | 'Java'
 OPERATION_GUID         VARCHAR2(48),              -- SUBSCRIPTION_GUID for RS
                                                   -- OPERATION_GUID for other services        
 TIMESTAMP              NUMBER         NOT NULL,
 TYPE                   NUMBER(2)      NOT NULL,   -- MESSAGE_RAISED | MESSAGE_REJECTED | OPERATION_FAILED | ...                                                     
 RR_OUTPUT_STATUS       NUMBER(2),                 -- NO_OUTPUT  | RR_FILTERED | RR_OUTPUT_ROUTED_TO_SOURCE |  RR_OUTPUT_ROUTED_TO_HANDLER
 ADDI_INFO              VARCHAR2(500),   
 IS_STALE               VARCHAR2(1)   
);

CREATE TABLE ESB_TRACKING_FIELD_VALUE 
(
 ACTIVITY_ID            NUMBER         NOT NULL,   -- FK to ESB_ACTIVITY.ID
 NAME                   VARCHAR2(2000)   NOT NULL,
 VALUE                  VARCHAR2(2000)  
);

CREATE TABLE ESB_FAULTED_INSTANCE 
(
 ACTIVITY_ID            NUMBER          NOT NULL,  -- FK to ESB_ACTIVITY.ID
 SOURCE_NAME            VARCHAR2(1000),
 INVOKED_OPERATION_NAME VARCHAR2(1000)  NOT NULL,
 MESSAGE                VARCHAR2(2000)  NOT NULL,  -- Error message   
 EXCEPTION              VARCHAR2(4000),            -- Stacktrace
 IN_PAYLOAD             BLOB,                      -- Request payload
 OUT_PAYLOAD            BLOB,                      -- Response | Fault payload                                                             
 RETRYABLE              VARCHAR2(1)     DEFAULT 'N'
);

CREATE TABLE ESB_SYSTEM_ACTIVITY 
(
 ACTIVITY_ID            NUMBER          NOT NULL,  -- FK to ESB_ACTIVITY.ID
 SYSTEM_GUID            VARCHAR(48)      NOT NULL
);

CREATE TABLE ESB_ALERT
(
 TYPE                   NUMBER         NOT NULL, -- WARNING | FATAL_ERROR
 SOURCE                 VARCHAR2(48)   NOT NULL, -- Inbound Adapter Service GUID
 MESSAGE                VARCHAR2(1000) NOT NULL, -- Alert message
 TIMESTAMP              NUMBER(20)     NOT NULL, 
 EXCEPTION              VARCHAR2(2000)           -- Stacktrace  
);

CREATE TABLE ESB_TRANSACTION_STATUS 
(
 FLOW_ID                VARCHAR2(256)   NOT NULL,     
 SUB_FLOW_ID            VARCHAR2(48), 
 IS_COMMITTED           VARCHAR2(1)    DEFAULT 'Y',   
 TIMESTAMP              NUMBER(20)     NOT NULL, 
 IS_STALE               VARCHAR2(1) 
);

CREATE TABLE ESB_TRACKING_FIELD
(
 OPERATION_GUID         VARCHAR2(48)    NOT NULL,
 NAME                   VARCHAR2(2000)    NOT NULL,
 BINDING_TO             VARCHAR2(8)     NOT NULL,  -- REQUEST | REPLY | FAULT
 EXPRESSION             VARCHAR2(4000)  NOT NULL,  -- XPath Expression
 STATUS                 VARCHAR2(8)     DEFAULT 'ENABLED'  -- ENABLED | DISABLED
 );
 
 CREATE TABLE ESB_RELATION_XML
(
 ID                     NUMBER   NOT NULL,
 SERVICE_GUID           VARCHAR2(48),
 OPERATION_GUID         VARCHAR2(48)   NOT NULL,
 XML                    BLOB     NOT NULL,
 IS_STALE               VARCHAR(1) DEFAULT 'N'
); 
 
CREATE TABLE ESB_SERVICE_RELATION
(
 SERVICE_GUID           VARCHAR2(48)   NOT NULL,
 RELATION_XML_ID        NUMBER   NOT NULL
); 

CREATE TABLE ESB_INSTANCE_RELATION_XML
(
 FLOW_ID                VARCHAR2(256)   NOT NULL,
 RELATION_XML_ID        NUMBER   NOT NULL
); 

CREATE INDEX ESB_FLOW_ID ON ESB_ACTIVITY (FLOW_ID);
CREATE INDEX ESB_ACTIVITY_TIMESTAMP ON ESB_ACTIVITY (TIMESTAMP);

--
-- ESB Owner Tags
--
CREATE TABLE ESB_OWNERTAG
(
 OWNERTAG VARCHAR2(32) NOT NULL,  -- OWNER TAG ESB , FND etc.
 OWNERNAME VARCHAR2(32) NOT NULL, -- OWNER NAME ORACLE APPS etc.
 DESCRIPTION VARCHAR2(4000)
);

--
-- ESB Parameters
--
CREATE TABLE ESB_PARAMETER
(
 PARAM_NAME VARCHAR2(4000), -- PARAM NAME
 PARAM_VALUE VARCHAR2(4000) -- PARAM VALUE
); 

------------------------------------------------
------------ESB New Tables End Here-----------
------------------------------------------------ 

/*
 * Sequences
 */
CREATE SEQUENCE WF_CONTROL_JMS_SUBSCRIBER_ID_S
 NOMAXVALUE
 NOMINVALUE
/

CREATE SEQUENCE WF_BES_PING_NUMBER_S
 NOMAXVALUE
 NOMINVALUE
/


------------------------------------------------
------------Slide Tables Start Here-----------
------------------------------------------------
CREATE TABLE "URI" (
	"URI_ID" NUMBER(10) NOT NULL,
    	"URI_STRING" VARCHAR2(4000) NOT NULL,
	PRIMARY KEY("URI_ID"),
    	UNIQUE("URI_STRING")
) CACHE NOLOGGING;

CREATE TABLE "OBJECT" (
	"URI_ID" NUMBER(10),
    	"CLASS_NAME" VARCHAR2(255) NOT NULL,
	PRIMARY KEY("URI_ID"),
    	FOREIGN KEY("URI_ID") REFERENCES "URI"("URI_ID")
) CACHE NOLOGGING;

-- node name max length: 512

CREATE TABLE "BINDING" (
	"URI_ID" NUMBER(10) NOT NULL,
	"NAME" VARCHAR2(4000) NOT NULL,
	"CHILD_UURI_ID" NUMBER(10) NOT NULL,
	PRIMARY KEY("URI_ID", "NAME", "CHILD_UURI_ID"),
	FOREIGN KEY("URI_ID") REFERENCES "URI"("URI_ID"),
	FOREIGN KEY("CHILD_UURI_ID") REFERENCES "URI"("URI_ID")
) CACHE NOLOGGING;

CREATE TABLE "PARENT_BINDING" (
	"URI_ID" NUMBER(10) NOT NULL,
	"NAME" VARCHAR2(4000) NOT NULL,
    	"PARENT_UURI_ID" NUMBER(10) NOT NULL,
	PRIMARY KEY("URI_ID", "NAME", "PARENT_UURI_ID"),
	FOREIGN KEY("URI_ID") REFERENCES "URI"("URI_ID"),
	FOREIGN KEY("PARENT_UURI_ID") REFERENCES "URI"("URI_ID")
) CACHE NOLOGGING;

CREATE TABLE "LINKS" (
	"URI_ID" NUMBER(10) NOT NULL,
	"LINK_TO_ID" NUMBER(10) NOT NULL,
	PRIMARY KEY("URI_ID", "LINK_TO_ID"),
	FOREIGN KEY("URI_ID") REFERENCES "URI"("URI_ID"),
	FOREIGN KEY("LINK_TO_ID") REFERENCES "URI"("URI_ID")
) CACHE NOLOGGING;

CREATE TABLE "LOCKS" (
	"LOCK_ID" NUMBER(10) NOT NULL, 
    	"OBJECT_ID" NUMBER(10) NOT NULL, 
	"SUBJECT_ID" NUMBER(10) NOT NULL, 
	"TYPE_ID" NUMBER(10) NOT NULL, 
	"EXPIRATION_DATE" NUMBER(14) NOT NULL,
	"IS_INHERITABLE" NUMBER(1) NOT NULL, 
    	"IS_EXCLUSIVE" NUMBER(1) NOT NULL, 
	"OWNER" VARCHAR2(4000), 
	PRIMARY KEY("LOCK_ID"), 
	FOREIGN KEY("LOCK_ID") REFERENCES "URI"("URI_ID"),
	FOREIGN KEY("OBJECT_ID") REFERENCES "URI"("URI_ID"),
	FOREIGN KEY("SUBJECT_ID") REFERENCES "URI"("URI_ID"),
	FOREIGN KEY("TYPE_ID") REFERENCES "URI"("URI_ID")
) CACHE NOLOGGING;

CREATE TABLE "BRANCH" (
	"BRANCH_ID" NUMBER(10) NOT NULL, 
    	"BRANCH_STRING" VARCHAR2(4000) NOT NULL, 
	PRIMARY KEY("BRANCH_ID"), 
	UNIQUE("BRANCH_STRING")
) CACHE NOLOGGING;

CREATE TABLE "LABEL" (
	"LABEL_ID" NUMBER(10) NOT NULL, 
    	"LABEL_STRING" VARCHAR2(4000) NOT NULL, 
	PRIMARY KEY("LABEL_ID")
) CACHE NOLOGGING;

CREATE TABLE "VERSION" (
	"URI_ID" NUMBER(10) NOT NULL, 
    	"IS_VERSIONED" NUMBER(1) NOT NULL, 
	PRIMARY KEY("URI_ID"), 
    	FOREIGN KEY("URI_ID") REFERENCES "URI"("URI_ID")
) CACHE NOLOGGING;

CREATE TABLE "VERSION_HISTORY" (
	"VERSION_ID" NUMBER(10) NOT NULL, 
	"URI_ID" NUMBER(10) NOT NULL, 
	"BRANCH_ID" NUMBER(10) NOT NULL, 
	"REVISION_NO" VARCHAR2(255) NOT NULL, 
    	PRIMARY KEY("VERSION_ID"), 
	UNIQUE("URI_ID", "BRANCH_ID", "REVISION_NO"), 
	FOREIGN KEY("URI_ID") REFERENCES "URI"("URI_ID"), 
	FOREIGN KEY("BRANCH_ID") REFERENCES "BRANCH"("BRANCH_ID")
) CACHE NOLOGGING;

CREATE TABLE "VERSION_PREDS" (
	"VERSION_ID" NUMBER(10) NOT NULL, 
	"PREDECESSOR_ID" NUMBER(10) NOT NULL, 
	FOREIGN KEY("VERSION_ID") REFERENCES "VERSION_HISTORY"("VERSION_ID"), 
	FOREIGN KEY("PREDECESSOR_ID") REFERENCES "VERSION_HISTORY"("VERSION_ID"), 
    	UNIQUE("VERSION_ID", "PREDECESSOR_ID")
) CACHE NOLOGGING;

CREATE TABLE "VERSION_LABELS" (
	"VERSION_ID" NUMBER(10) NOT NULL, 
	"LABEL_ID" NUMBER(10) NOT NULL, 
	UNIQUE("VERSION_ID", "LABEL_ID"), 
	FOREIGN KEY("VERSION_ID") REFERENCES "VERSION_HISTORY"("VERSION_ID"), 
	FOREIGN KEY("LABEL_ID") REFERENCES "LABEL"("LABEL_ID")
) CACHE NOLOGGING;

CREATE TABLE "VERSION_CONTENT" (
	"VERSION_ID" NUMBER(10) NOT NULL, 
	"CONTENT" BLOB, 
	PRIMARY KEY("VERSION_ID"), 
	FOREIGN KEY("VERSION_ID") REFERENCES "VERSION_HISTORY"("VERSION_ID")
) CACHE NOLOGGING
LOB ("CONTENT") STORE AS (NOCACHE NOLOGGING STORAGE(MAXEXTENTS UNLIMITED));

CREATE TABLE "PROPERTIES" (
	"VERSION_ID" NUMBER(10) NOT NULL, 
	"PROPERTY_NAMESPACE" VARCHAR2(255) NOT NULL, 
	"PROPERTY_NAME" VARCHAR2(255) NOT NULL, 
	"PROPERTY_VALUE" VARCHAR2(4000), 
	"PROPERTY_TYPE" VARCHAR2(255),
	"IS_PROTECTED" NUMBER(1) NOT NULL, 
	UNIQUE("VERSION_ID", "PROPERTY_NAMESPACE", "PROPERTY_NAME"), 
	FOREIGN KEY("VERSION_ID") REFERENCES "VERSION_HISTORY"("VERSION_ID")
) CACHE NOLOGGING;
	
CREATE TABLE "PERMISSIONS" (
	"OBJECT_ID" NUMBER(10) NOT NULL, 
	"SUBJECT_ID" NUMBER(10) NOT NULL, 
	"ACTION_ID" NUMBER(10) NOT NULL, 
	"VERSION_NO" VARCHAR2(255), 
	"IS_INHERITABLE" NUMBER(1) NOT NULL, 
	"IS_NEGATIVE" NUMBER(1) NOT NULL, 
	"SUCCESSION" NUMBER(10) NOT NULL, 
	FOREIGN KEY("OBJECT_ID") REFERENCES "URI"("URI_ID"), 
	FOREIGN KEY("SUBJECT_ID") REFERENCES "URI"("URI_ID"), 
	FOREIGN KEY("ACTION_ID") REFERENCES "URI"("URI_ID"), 
	UNIQUE("OBJECT_ID", "SUBJECT_ID", "ACTION_ID"), 
	UNIQUE("OBJECT_ID", "SUCCESSION")
) CACHE NOLOGGING;

CREATE SEQUENCE "URI-URI_ID-SEQ" START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE "BRANCH-BRANCH_ID-SEQ" START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE "LABEL-LABEL_ID-SEQ" START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE "VERSION_HISTORY-VERSION_ID-SEQ" START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE TRIGGER "URI-URI_ID-TRG" BEFORE INSERT ON "URI" FOR EACH ROW 
BEGIN 
SELECT "URI-URI_ID-SEQ".nextval INTO :new.URI_ID from dual; 
END;
/

CREATE TRIGGER "BRANCH-BRANCH_ID-TRG" BEFORE INSERT ON "BRANCH" FOR EACH ROW 
BEGIN 
SELECT "BRANCH-BRANCH_ID-SEQ".nextval INTO :new.BRANCH_ID from dual; 
END;
/

CREATE TRIGGER "LABEL-LABEL_ID-TRG" BEFORE INSERT ON "LABEL" FOR EACH ROW 
BEGIN 
SELECT "LABEL-LABEL_ID-SEQ".nextval INTO :new.LABEL_ID from dual; 
END;
/

CREATE TRIGGER "VERSION_HISTORY-VERSION_ID-TRG" BEFORE INSERT ON "VERSION_HISTORY" FOR EACH ROW 
BEGIN 
SELECT "VERSION_HISTORY-VERSION_ID-SEQ".nextval INTO :new.VERSION_ID from dual; 
END;
/


------------------------------------------------
------------Slide Tables END Here-----------
------------------------------------------------

commit;
Rem exit;
