alter table PREFERENCES
   drop primary key cascade;

drop table PREFERENCES cascade constraints;



create table PREFERENCES  (
   NAME                 VARCHAR2(255)                    not null,
   VALUE                VARCHAR2(4000)
);

alter table PREFERENCES
   add constraint PK_PREFERENCES primary key (NAME);

alter table APPLICATION_RESOURCES
   drop primary key cascade;

drop table APPLICATION_RESOURCES cascade constraints;



create table APPLICATION_RESOURCES  (
   APPLICATION_ID       VARCHAR2(30)                     not null,
   RESOURCE_PATH        VARCHAR2(255)                    not null,
   RESOURCE_NAME        VARCHAR2(255)                    not null,
   RESOURCE_OBJECT      BLOB
);

alter table APPLICATION_RESOURCES
   add constraint PK_APPLICATION_RESOURCES primary key (APPLICATION_ID, RESOURCE_PATH, RESOURCE_NAME);

alter table ROLE_OPERATION_MAPPINGS
   drop constraint FK_ROLE_OPERATION__OPERATIONS;

alter table ROLE_OPERATION_MAPPINGS
   drop constraint FK_ROLE_OPERATION__ROLES;

alter table COMPONENT_GROUP_MAPPINGS
   drop primary key cascade;

alter table GROUP_ROLE_MAPPINGS
   drop primary key cascade;

alter table OPERATIONS
   drop primary key cascade;

alter table ROLES
   drop primary key cascade;

alter table ROLE_OPERATION_MAPPINGS
   drop primary key cascade;

alter table SERVICE_GROUP_MAPPINGS
   drop primary key cascade;

drop table COMPONENT_GROUP_MAPPINGS cascade constraints;

drop table GROUP_ROLE_MAPPINGS cascade constraints;

drop table OPERATIONS cascade constraints;

drop table ROLES cascade constraints;

drop table ROLE_OPERATION_MAPPINGS cascade constraints;

drop table SERVICE_GROUP_MAPPINGS cascade constraints;



create table COMPONENT_GROUP_MAPPINGS  (
   COMPONENT_ID         VARCHAR2(30)                     not null,
   GROUP_ID             VARCHAR2(100)                    not null
);

alter table COMPONENT_GROUP_MAPPINGS
   add constraint PK_COMPONENT_GROUP_MAPPINGS primary key (GROUP_ID, COMPONENT_ID);



create table GROUP_ROLE_MAPPINGS  (
   GROUP_ID             VARCHAR2(100)                    not null,
   ROLE_ID              NUMBER(8)                        not null,
   ENABLED              CHAR(1)                          not null
);

alter table GROUP_ROLE_MAPPINGS
   add constraint PK_GROUP_ROLE_MAPPINGS primary key (GROUP_ID, ROLE_ID);



create table OPERATIONS  (
   OPERATION_ID         NUMBER(8)                        not null,
   OPERATION_DESC       VARCHAR2(100)                    not null,
   OPERATION_VALUE      NUMBER(19)                       not null
);

alter table OPERATIONS
   add constraint PK_OPERATIONS primary key (OPERATION_ID);



create table ROLES  (
   ROLE_ID              NUMBER(8)                        not null,
   ROLE_DESC            VARCHAR2(100),
   ENABLED              CHAR(1)
);

alter table ROLES
   add constraint PK_ROLES primary key (ROLE_ID);



create table ROLE_OPERATION_MAPPINGS  (
   ROLE_ID              NUMBER(8)                        not null,
   OPERATION_ID         NUMBER(8)                        not null
);

alter table ROLE_OPERATION_MAPPINGS
   add constraint PK_ROLE_OPERATION_MAPPINGS primary key (ROLE_ID, OPERATION_ID);



create table SERVICE_GROUP_MAPPINGS  (
   SERVICE_ID           VARCHAR2(10)                     not null,
   GROUP_ID             VARCHAR2(100)                    not null
);

alter table SERVICE_GROUP_MAPPINGS
   add constraint PK_SERVICE_GROUP_MAPPINGS primary key (GROUP_ID, SERVICE_ID);

alter table ROLE_OPERATION_MAPPINGS
   add constraint FK_ROLE_OPERATION__OPERATIONS foreign key (OPERATION_ID)
      references OPERATIONS (OPERATION_ID);

alter table ROLE_OPERATION_MAPPINGS
   add constraint FK_ROLE_OPERATION__ROLES foreign key (ROLE_ID)
      references ROLES (ROLE_ID);

alter table CROUTER_RULESETS
   drop primary key cascade;

alter table FOUNDATION_OBJECTS
   drop primary key cascade;

alter table FOUNDATION_SERVICES
   drop primary key cascade;

drop table CROUTER_RULESETS cascade constraints;

drop table FOUNDATION_OBJECTS cascade constraints;

drop table FOUNDATION_SERVICES cascade constraints;



create table CROUTER_RULESETS  (
   FOUNDATION_SERVICE_ID VARCHAR2(30)                     not null,
   GATEWAY_ID           VARCHAR2(30)                     not null,
   CROUTER_RULESET_ORDER NUMBER(4)                        not null,
   CROUTER_RULESET_NAME VARCHAR2(50),
   CROUTER_RULESET_VERSION NUMBER(4),
   CROUTER_RULESET_DESC VARCHAR2(1024),
   FOUNDATION_OBJECT_ID NUMBER(12)
);

alter table CROUTER_RULESETS
   add constraint PK_CROUTER_RULESETS primary key (CROUTER_RULESET_ORDER, GATEWAY_ID, FOUNDATION_SERVICE_ID);



create table FOUNDATION_OBJECTS  (
   FOUNDATION_OBJECT_ID NUMBER(12)                       not null,
   FOUNDATION_OBJECT_DOCUMENT CLOB
);

alter table FOUNDATION_OBJECTS
   add constraint PK_FOUNDATION_OBJECTS primary key (FOUNDATION_OBJECT_ID);



create table FOUNDATION_SERVICES  (
   FOUNDATION_SERVICE_ID VARCHAR2(30)                     not null,
   GATEWAY_ID           VARCHAR2(30)                     not null,
   FOUNDATION_SERVICE_NAME VARCHAR2(50),
   FOUNDATION_OBJECT_ID NUMBER(12)
);

alter table FOUNDATION_SERVICES
   add constraint PK_FOUNDATION_SERVICES primary key (GATEWAY_ID, FOUNDATION_SERVICE_ID);

DROP SEQUENCE FOUNDATION_OBJECT_ID_SEQ
;

CREATE SEQUENCE FOUNDATION_OBJECT_ID_SEQ 
INCREMENT BY 1 
START WITH 3001 
MINVALUE 1 
MAXVALUE 999999999999
CYCLE NOCACHE
;
drop index IDX_MPSTORE_DBM0;

drop index IDX_MPSTORE_KEY0;

drop index IDX_MPSTORE_KEY1;

alter table MEASUREMENT_ALARM_STORE
   drop primary key cascade;

alter table MEASUREMENT_CLUSTER
   drop primary key cascade;

alter table MEASUREMENT_DEFS
   drop primary key cascade;

alter table MEASUREMENT_PERSISTED_STORE
   drop primary key cascade;

alter table MEASUREMENT_RESOURCE_STORE
   drop primary key cascade;

alter table MEASUREMENT_TRANSFORMATIONS
   drop primary key cascade;

alter table PROCESS_RULES
   drop primary key cascade;

drop table MEASUREMENT_ALARM_STORE cascade constraints;

drop table MEASUREMENT_CLUSTER cascade constraints;

drop table MEASUREMENT_DEFS cascade constraints;

drop table MEASUREMENT_PERSISTED_STORE cascade constraints;

drop table MEASUREMENT_RESOURCE_STORE cascade constraints;

drop table MEASUREMENT_TRANSFORMATIONS cascade constraints;

drop table PROCESS_RULES cascade constraints;



create table MEASUREMENT_ALARM_STORE  (
   ID                   VARCHAR2(50)                     not null,
   DEF_ID               VARCHAR2(50),
   CONTEXT_ID           VARCHAR2(255),
   PARENT_CONTEXT_ID    VARCHAR2(255),
   TIME                 NUMBER(16),
   STORETIME            NUMBER(16),
   KEY0                 VARCHAR2(255),
   KEY1                 VARCHAR2(255),
   KEY2                 VARCHAR2(255),
   KEY3                 VARCHAR2(255),
   KEY4                 VARCHAR2(255),
   KEY5                 VARCHAR2(255),
   KEY6                 VARCHAR2(255),
   KEY7                 VARCHAR2(255),
   KEY8                 VARCHAR2(255),
   KEY9                 VARCHAR2(255),
   KEY10                VARCHAR2(255),
   KEY11                VARCHAR2(255),
   KEY12                VARCHAR2(255),
   KEY13                VARCHAR2(255),
   KEY14                VARCHAR2(255),
   KEY15                VARCHAR2(255),
   KEY16                VARCHAR2(255),
   KEY17                VARCHAR2(255),
   KEY18                VARCHAR2(255),
   KEY19                VARCHAR2(255),
   KEY20                VARCHAR2(255),
   KEY21                VARCHAR2(255),
   KEY22                VARCHAR2(255),
   KEY23                VARCHAR2(255),
   KEY24                VARCHAR2(255),
   KEY25                VARCHAR2(255),
   KEY26                VARCHAR2(255),
   KEY27                VARCHAR2(255),
   KEY28                VARCHAR2(255),
   KEY29                VARCHAR2(255),
   KEY30                VARCHAR2(255),
   KEY31                VARCHAR2(255),
   KEY32                VARCHAR2(255),
   KEY33                VARCHAR2(255),
   KEY34                VARCHAR2(255),
   KEY35                VARCHAR2(255),
   KEY36                VARCHAR2(255),
   KEY37                VARCHAR2(255),
   KEY38                VARCHAR2(255),
   KEY39                VARCHAR2(1024),
   DBM0                 CHAR(1),
   DBM1                 VARCHAR2(5),
   DBM2                 VARCHAR2(5),
   MEASUREMENT_STR      CLOB
);

alter table MEASUREMENT_ALARM_STORE
   add constraint PK_MEASUREMENT_ALARM_STORE primary key (ID);



create table MEASUREMENT_CLUSTER  (
   ID                   VARCHAR2(50)                     not null,
   DEF_ID               VARCHAR2(50),
   CONTEXT_ID           VARCHAR2(255),
   PARENT_CONTEXT_ID    VARCHAR2(255),
   TIME                 NUMBER(16),
   STORETIME            NUMBER(16),
   KEY0                 VARCHAR2(255),
   KEY1                 VARCHAR2(255),
   KEY2                 VARCHAR2(255),
   KEY3                 VARCHAR2(255),
   KEY4                 VARCHAR2(255),
   KEY5                 VARCHAR2(255),
   KEY6                 VARCHAR2(255),
   KEY7                 VARCHAR2(255),
   KEY8                 VARCHAR2(255),
   KEY9                 VARCHAR2(255),
   KEY10                VARCHAR2(255),
   KEY11                VARCHAR2(255),
   KEY12                VARCHAR2(255),
   KEY13                VARCHAR2(255),
   KEY14                VARCHAR2(255),
   KEY15                VARCHAR2(255),
   KEY16                VARCHAR2(255),
   KEY17                VARCHAR2(255),
   KEY18                VARCHAR2(255),
   KEY19                VARCHAR2(255),
   KEY20                VARCHAR2(255),
   KEY21                VARCHAR2(255),
   KEY22                VARCHAR2(255),
   KEY23                VARCHAR2(255),
   KEY24                VARCHAR2(255),
   KEY25                VARCHAR2(255),
   KEY26                VARCHAR2(255),
   KEY27                VARCHAR2(255),
   KEY28                VARCHAR2(255),
   KEY29                VARCHAR2(255),
   KEY30                VARCHAR2(255),
   KEY31                VARCHAR2(255),
   KEY32                VARCHAR2(255),
   KEY33                VARCHAR2(255),
   KEY34                VARCHAR2(255),
   KEY35                VARCHAR2(255),
   KEY36                VARCHAR2(255),
   KEY37                VARCHAR2(255),
   KEY38                VARCHAR2(255),
   KEY39                VARCHAR2(1024),
   DBM0                 CHAR(1),
   DBM1                 VARCHAR2(5),
   DBM2                 VARCHAR2(5),
   MEASUREMENT_STR      CLOB
);

alter table MEASUREMENT_CLUSTER
   add constraint PK_MEASUREMENT_CLUSTER primary key (ID);



create table MEASUREMENT_DEFS  (
   STORE_ID             VARCHAR2(20)                     not null,
   DEF_ID               VARCHAR2(50)                     not null,
   CLOB_DEF             CLOB
);

alter table MEASUREMENT_DEFS
   add constraint PK_MEASUREMENT_DEFS primary key (STORE_ID, DEF_ID);



create table MEASUREMENT_PERSISTED_STORE  (
   ID                   VARCHAR2(50)                     not null,
   DEF_ID               VARCHAR2(50),
   CONTEXT_ID           VARCHAR2(255),
   PARENT_CONTEXT_ID    VARCHAR2(255),
   TIME                 NUMBER(16),
   STORETIME            NUMBER(16),
   KEY0                 VARCHAR2(255),
   KEY1                 VARCHAR2(255),
   KEY2                 VARCHAR2(255),
   KEY3                 VARCHAR2(255),
   KEY4                 VARCHAR2(255),
   KEY5                 VARCHAR2(255),
   KEY6                 VARCHAR2(255),
   KEY7                 VARCHAR2(255),
   KEY8                 VARCHAR2(255),
   KEY9                 VARCHAR2(255),
   KEY10                VARCHAR2(255),
   KEY11                VARCHAR2(255),
   KEY12                VARCHAR2(255),
   KEY13                VARCHAR2(255),
   KEY14                VARCHAR2(255),
   KEY15                VARCHAR2(255),
   KEY16                VARCHAR2(255),
   KEY17                VARCHAR2(255),
   KEY18                VARCHAR2(255),
   KEY19                VARCHAR2(255),
   KEY20                VARCHAR2(255),
   KEY21                VARCHAR2(255),
   KEY22                VARCHAR2(255),
   KEY23                VARCHAR2(255),
   KEY24                VARCHAR2(255),
   KEY25                VARCHAR2(255),
   KEY26                VARCHAR2(255),
   KEY27                VARCHAR2(255),
   KEY28                VARCHAR2(255),
   KEY29                VARCHAR2(255),
   KEY30                VARCHAR2(255),
   KEY31                VARCHAR2(255),
   KEY32                VARCHAR2(255),
   KEY33                VARCHAR2(255),
   KEY34                VARCHAR2(255),
   KEY35                VARCHAR2(255),
   KEY36                VARCHAR2(255),
   KEY37                VARCHAR2(255),
   KEY38                VARCHAR2(255),
   KEY39                VARCHAR2(1024),
   DBM0                 CHAR(1),
   DBM1                 VARCHAR2(5),
   DBM2                 VARCHAR2(5),
   MEASUREMENT_STR      CLOB
);

alter table MEASUREMENT_PERSISTED_STORE
   add constraint PK_MEASUREMENT_PERSISTED_STORE primary key (ID);

create index IDX_MPSTORE_KEY0 on MEASUREMENT_PERSISTED_STORE (
   KEY0 ASC
);

create index IDX_MPSTORE_KEY1 on MEASUREMENT_PERSISTED_STORE (
   KEY1 ASC
);

create index IDX_MPSTORE_DBM0 on MEASUREMENT_PERSISTED_STORE (
   DBM0 ASC
);



create table MEASUREMENT_RESOURCE_STORE  (
   ID                   VARCHAR2(50)                     not null,
   DEF_ID               VARCHAR2(50),
   CONTEXT_ID           VARCHAR2(255),
   PARENT_CONTEXT_ID    VARCHAR2(255),
   TIME                 NUMBER(16),
   STORETIME            NUMBER(16),
   KEY0                 VARCHAR2(255),
   KEY1                 VARCHAR2(255),
   KEY2                 VARCHAR2(255),
   KEY3                 VARCHAR2(255),
   KEY4                 VARCHAR2(255),
   KEY5                 VARCHAR2(255),
   KEY6                 VARCHAR2(255),
   KEY7                 VARCHAR2(255),
   KEY8                 VARCHAR2(255),
   KEY9                 VARCHAR2(255),
   KEY10                VARCHAR2(255),
   KEY11                VARCHAR2(255),
   KEY12                VARCHAR2(255),
   KEY13                VARCHAR2(255),
   KEY14                VARCHAR2(255),
   KEY15                VARCHAR2(255),
   KEY16                VARCHAR2(255),
   KEY17                VARCHAR2(255),
   KEY18                VARCHAR2(255),
   KEY19                VARCHAR2(255),
   KEY20                VARCHAR2(255),
   KEY21                VARCHAR2(255),
   KEY22                VARCHAR2(255),
   KEY23                VARCHAR2(255),
   KEY24                VARCHAR2(255),
   KEY25                VARCHAR2(255),
   KEY26                VARCHAR2(255),
   KEY27                VARCHAR2(255),
   KEY28                VARCHAR2(255),
   KEY29                VARCHAR2(255),
   KEY30                VARCHAR2(255),
   KEY31                VARCHAR2(255),
   KEY32                VARCHAR2(255),
   KEY33                VARCHAR2(255),
   KEY34                VARCHAR2(255),
   KEY35                VARCHAR2(255),
   KEY36                VARCHAR2(255),
   KEY37                VARCHAR2(255),
   KEY38                VARCHAR2(255),
   KEY39                VARCHAR2(1024),
   DBM0                 CHAR(1),
   DBM1                 VARCHAR2(5),
   DBM2                 VARCHAR2(5),
   MEASUREMENT_STR      CLOB
);

alter table MEASUREMENT_RESOURCE_STORE
   add constraint PK_MEASUREMENT_RESOURCE_STORE primary key (ID);



create table MEASUREMENT_TRANSFORMATIONS  (
   STORE_ID             VARCHAR2(20)                     not null,
   TRANSFORMATION_ID    VARCHAR2(50)                     not null,
   CLOB_TRANSFORMATION  CLOB
);

alter table MEASUREMENT_TRANSFORMATIONS
   add constraint PK_MEASUREMENT_TRANSFORMATIONS primary key (STORE_ID, TRANSFORMATION_ID);



create table PROCESS_RULES  (
   STORE_ID             VARCHAR2(20)                     not null,
   RULE_ID              VARCHAR2(50)                     not null,
   CLOB_RULE            CLOB
);

alter table PROCESS_RULES
   add constraint PK_PROCESS_RULES primary key (STORE_ID, RULE_ID);

alter table MEASUREMENT_GROUP_MAPPINGS
   drop primary key cascade;

alter table MEASUREMENT_VIEWS
   drop primary key cascade;

drop table MEASUREMENT_GROUP_MAPPINGS cascade constraints;

drop table MEASUREMENT_VIEWS cascade constraints;



create table MEASUREMENT_GROUP_MAPPINGS  (
   VIEW_ID              VARCHAR2(50)                     not null,
   GROUP_ID             VARCHAR2(100)                    not null
);

alter table MEASUREMENT_GROUP_MAPPINGS
   add constraint PK_MEASUREMENT_GROUP_MAPPINGS primary key (VIEW_ID, GROUP_ID);



create table MEASUREMENT_VIEWS  (
   VIEW_ID              VARCHAR2(50)                     not null,
   VIEW_STR             CLOB
);

alter table MEASUREMENT_VIEWS
   add constraint PK_MEASUREMENT_VIEWS primary key (VIEW_ID);

alter table LOG_OBJECTS
   drop primary key cascade;

alter table MESSAGELOGS
   drop primary key cascade;

drop table LOG_OBJECTS cascade constraints;

drop table MESSAGELOGS cascade constraints;



create table LOG_OBJECTS  (
   LOGID                NUMBER(12)                       not null,
   LOG_MESSAGE          BLOB
);

alter table LOG_OBJECTS
   add constraint PK_LOG_OBJECTS primary key (LOGID);



create table MESSAGELOGS  (
   LOGID                NUMBER(12)                       not null,
   SERVICEID            VARCHAR2(100)                    not null,
   INVOKE_TIME          DATE                             not null,
   MESSAGE_ID           VARCHAR2(100),
   CONTEXT_ID           VARCHAR2(100),
   CONTENT_TYPE         VARCHAR2(512),
   MESSAGE_SOURCE       VARCHAR2(100),
   MESSAGE_DESTINATION  VARCHAR2(100),
   CREATED_ON           DATE,
   LOG_STATUS           NUMBER(8,0),
   LOG_MESSAGE_VERSION  NUMBER(8,2),
   LOG_TYPE             VARCHAR2(20),
   LOG_LEVEL            NUMBER(8,0),
   COMPONENT_ID         VARCHAR2(30),
   CLIENTID             VARCHAR2(30),
   PARENT_CONTEXT_ID    VARCHAR2(100),
   OPERATION            VARCHAR2(30),
   HOSTNAME             VARCHAR2(100),
   PROTOCOL             VARCHAR2(10)
);

alter table MESSAGELOGS
   add constraint PK_MESSAGELOGS primary key (LOGID);

DROP SEQUENCE LOG_ID_SEQ
;

DROP SEQUENCE MESSAGE_ID_SEQ
;

CREATE SEQUENCE LOG_ID_SEQ 
INCREMENT BY 1 
START WITH 1 
MINVALUE 1 
MAXVALUE 999999999999
CYCLE NOCACHE
;

CREATE SEQUENCE MESSAGE_ID_SEQ 
INCREMENT BY 1 
START WITH 1 
MINVALUE 1 
MAXVALUE 99999999999999999
CYCLE NOCACHE
;
alter table USER_GROUP_MAPPINGS
   drop constraint FK_USER_GROUP_MAPP_GROUPS;

alter table USER_GROUP_MAPPINGS
   drop constraint FK_USER_GROUP_MAPP_USERS;

alter table GROUPS
   drop primary key cascade;

alter table USERS
   drop primary key cascade;

alter table USER_GROUP_MAPPINGS
   drop primary key cascade;

drop table GROUPS cascade constraints;

drop table USERS cascade constraints;

drop table USER_GROUP_MAPPINGS cascade constraints;



create table GROUPS  (
   GROUP_ID             VARCHAR2(100)                    not null,
   GROUP_DESC           VARCHAR2(100)                    not null,
   ENABLED              CHAR(1)                          not null
);

alter table GROUPS
   add constraint PK_GROUPS primary key (GROUP_ID);



create table USERS  (
   USERID               VARCHAR2(30)                     not null,
   USER_NAME            VARCHAR2(100)                    not null,
   USER_PASSWORD        VARCHAR2(255)                    not null,
   USER_STAT            CHAR(1)                          not null,
   USER_EMAIL           VARCHAR2(100)                    not null,
   ORGANIZATIONID       VARCHAR2(30)                     not null,
   USER_ADDRESS1        VARCHAR2(255),
   USER_ADDRESS2        VARCHAR2(255),
   USER_PHONE           VARCHAR2(30),
   USER_FAX             VARCHAR2(30),
   LAST_LOGIN_DATE      DATE,
   PASSWORD_RETRY       NUMBER(2,0),
   LOGGED_ON            CHAR(1),
   CREATED_BY           VARCHAR2(30),
   CREATED_ON           DATE,
   MODIFIED_BY          VARCHAR2(30),
   MODIFIED_ON          DATE,
   constraint CK_USERS1 check (USER_STAT in ('A','D','S'))
);

alter table USERS
   add constraint PK_USERS primary key (USERID);



create table USER_GROUP_MAPPINGS  (
   USERID               VARCHAR2(30)                     not null,
   GROUP_ID             VARCHAR2(100)                    not null,
   ENABLED              CHAR(1)
);

alter table USER_GROUP_MAPPINGS
   add constraint PK_USER_GROUP_MAPPINGS primary key (USERID, GROUP_ID);

alter table USER_GROUP_MAPPINGS
   add constraint FK_USER_GROUP_MAPP_GROUPS foreign key (GROUP_ID)
      references GROUPS (GROUP_ID);

alter table USER_GROUP_MAPPINGS
   add constraint FK_USER_GROUP_MAPP_USERS foreign key (USERID)
      references USERS (USERID);

alter table SERVICE_VERSION_MAPPING
   drop constraint FK_SERVICE_VERSION_MAPPING_1;

alter table SERVICE_VERSION_MAPPING
   drop constraint FK_SERVICE_VERSION_MAPPING_2;

drop index IDX_COMPONENT_NAME;

drop index IDX_SERVICE_NAME;

alter table COMPONENTS
   drop primary key cascade;

alter table COMPONENT_PARAMS
   drop primary key cascade;

alter table SERVICES
   drop primary key cascade;

alter table SERVICE_VERSION_MAPPING
   drop primary key cascade;

drop table COMPONENTS cascade constraints;

drop table COMPONENT_PARAMS cascade constraints;

drop table SERVICES cascade constraints;

drop table SERVICE_VERSION_MAPPING cascade constraints;



create table COMPONENTS  (
   COMPONENT_ID         VARCHAR2(30)                     not null,
   COMPONENT_NAME       VARCHAR2(255)                    not null,
   COMPONENT_STATUS     CHAR(1)                          not null,
   COMPONENT_TYPE       VARCHAR2(50)                     not null,
   COMPONENT_VERSION    VARCHAR2(20),
   CONTAINER_TYPE       VARCHAR2(50),
   POLICY_SERVER_ID     VARCHAR2(30),
   MANAGABLE            CHAR(1),
   MANAGEMENT_URL       VARCHAR2(1024),
   COMPONENT_URL        VARCHAR2(1024),
   HEARTBEAT_URL        VARCHAR2(1024),
   REFERENCE_ID         VARCHAR2(30),
   OWNED_BY             VARCHAR2(100),
   SUPPORTED_BY         VARCHAR2(100)
);

alter table COMPONENTS
   add constraint PK_COMPONENTS primary key (COMPONENT_ID);

create unique index IDX_COMPONENT_NAME on COMPONENTS (
   COMPONENT_NAME ASC
);



create table COMPONENT_PARAMS  (
   COMPONENT_ID         VARCHAR2(30)                     not null,
   COMPONENT_PARAM_NAME VARCHAR2(150)                    not null,
   COMPONENT_PARAM_VALUE VARCHAR2(150)
);

alter table COMPONENT_PARAMS
   add constraint PK_COMPONENT_PARAMS primary key (COMPONENT_ID, COMPONENT_PARAM_NAME);



create table SERVICES  (
   SERVICEID            VARCHAR2(10)                     not null,
   SERVICE_NAME         VARCHAR2(30)                     not null,
   SERVICE_VERSION      VARCHAR2(30)                     not null,
   SERVICE_STATUS       CHAR(1)                          not null,
   SERVICE_DESC         VARCHAR2(1024),
   SERVICE_WSDL_URL     VARCHAR2(1024),
   SERVERID             VARCHAR2(20),
   OWNED_BY             VARCHAR2(100),
   SUPPORTED_BY         VARCHAR2(100),
   SERVICE_UNIQUE_NAME  VARCHAR2(1024),
   SERVICE_WSDL         CLOB
);

alter table SERVICES
   add constraint PK_SERVICES primary key (SERVICEID);

create unique index IDX_SERVICE_NAME on SERVICES (
   SERVICE_NAME ASC,
   SERVICE_VERSION ASC,
   SERVERID ASC
);



create table SERVICE_VERSION_MAPPING  (
   SERVICEID_OLD        VARCHAR2(10)                     not null,
   SERVICEID_NEW        VARCHAR2(10)                     not null,
   USE_SERVICE          CHAR(1)
);

alter table SERVICE_VERSION_MAPPING
   add constraint PK_SERVICE_VERSION_MAPPING primary key (SERVICEID_OLD, SERVICEID_NEW);

alter table SERVICE_VERSION_MAPPING
   add constraint FK_SERVICE_VERSION_MAPPING_1 foreign key (SERVICEID_OLD)
      references SERVICES (SERVICEID);

alter table SERVICE_VERSION_MAPPING
   add constraint FK_SERVICE_VERSION_MAPPING_2 foreign key (SERVICEID_NEW)
      references SERVICES (SERVICEID);

DROP SEQUENCE SERVICE_ID_SEQ
;

DROP SEQUENCE COMPONENT_ID_SEQ
;

CREATE SEQUENCE SERVICE_ID_SEQ 
INCREMENT BY 1 
START WITH 3001 
MINVALUE 1 
MAXVALUE 9999999
CYCLE NOCACHE
;

CREATE SEQUENCE COMPONENT_ID_SEQ 
INCREMENT BY 1 
START WITH 3001 
MINVALUE 1 
MAXVALUE 999999999999
CYCLE NOCACHE
;
alter table COMPONENT_POLICY_MAPPINGS
   drop primary key cascade;

alter table COMPONENT_PROPERTY_DEFINITIONS
   drop primary key cascade;

alter table PIPELINES
   drop primary key cascade;

alter table POLICIES
   drop primary key cascade;

alter table POLICY_MANAGER_OBJECTS
   drop primary key cascade;

alter table POLICY_SET
   drop primary key cascade;

alter table POLICY_SET_OBJECTS
   drop primary key cascade;

alter table STEP_TEMPLATE
   drop primary key cascade;

drop table COMPONENT_POLICY_MAPPINGS cascade constraints;

drop table COMPONENT_PROPERTY_DEFINITIONS cascade constraints;

drop table PIPELINES cascade constraints;

drop table POLICIES cascade constraints;

drop table POLICY_MANAGER_OBJECTS cascade constraints;

drop table POLICY_SET cascade constraints;

drop table POLICY_SET_OBJECTS cascade constraints;

drop table STEP_TEMPLATE cascade constraints;



create table COMPONENT_POLICY_MAPPINGS  (
   COMPONENT_ID         VARCHAR2(30)                     not null,
   COMPONENT_POLICY_VERSION NUMBER(8,2)                      not null,
   COMPONENT_POLICY_TYPE CHAR(1)                          not null,
   OBJECT_REF_ID        NUMBER(12)                       not null,
   COMPONENT_POLICY_STATUS CHAR(1)
);

alter table COMPONENT_POLICY_MAPPINGS
   add constraint PK_COMPONENT_POLICY_MAPPINGS primary key (COMPONENT_ID, COMPONENT_POLICY_VERSION);



create table COMPONENT_PROPERTY_DEFINITIONS  (
   COMPONENT_TYPE       VARCHAR2(50)                     not null,
   COMPONENT_VERSION    VARCHAR2(20)                     not null,
   CONTAINER_TYPE       VARCHAR2(50)                     not null,
   STATUS               CHAR(1),
   OBJECT_ID            NUMBER(12)
);

alter table COMPONENT_PROPERTY_DEFINITIONS
   add constraint PK_COMPONENT_PROPERTY_DEFINITI primary key (COMPONENT_TYPE, COMPONENT_VERSION, CONTAINER_TYPE);



create table PIPELINES  (
   PIPELINE_ID          NUMBER(12)                       not null,
   PIPELINE_MAJOR_VER   NUMBER(6)                        not null,
   PIPELINE_MINOR_VER   NUMBER(6)                        not null,
   PIPELINE_TYPE        VARCHAR2(20)                     not null,
   PIPELINE_ORDER       NUMBER(6)                        not null,
   PIPELINE_TAG         VARCHAR2(100),
   PIPELINE_DATE        DATE,
   PIPELINE_COMMENT     VARCHAR2(255),
   OBJECT_ID            NUMBER(12),
   COMPONENT_TYPE       VARCHAR2(50),
   COMPONENT_VERSION    VARCHAR2(20),
   CONTAINER_TYPE       VARCHAR2(50),
   REVISED              CHAR(1),
   POLICY_ID            NUMBER(12),
   PIPELINE_STATUS      CHAR(1)
);

alter table PIPELINES
   add constraint PK_PIPELINES primary key (PIPELINE_ID, PIPELINE_MAJOR_VER, PIPELINE_MINOR_VER);



create table POLICIES  (
   POLICY_ID            NUMBER(12)                       not null,
   POLICY_VERSION       NUMBER(8,2)                      not null,
   POLICY_REF_ID        VARCHAR2(50)                     not null,
   POLICY_NAME          VARCHAR2(150),
   REVISED              CHAR(1),
   POLICY_SET_ID        NUMBER(12),
   POLICY_STATUS        CHAR(1)
);

alter table POLICIES
   add constraint PK_POLICIES primary key (POLICY_ID, POLICY_VERSION);



create table POLICY_MANAGER_OBJECTS  (
   OBJECT_ID            NUMBER(12)                       not null,
   OBJECT_DOCUMENT      CLOB
);

alter table POLICY_MANAGER_OBJECTS
   add constraint PK_POLICY_MANAGER_OBJECTS primary key (OBJECT_ID);



create table POLICY_SET  (
   POLICY_SET_ID        NUMBER(12)                       not null,
   POLICY_SET_VERSION   NUMBER(8,2)                      not null,
   POLICY_SET_TYPE      CHAR(1)                          not null,
   POLICY_SET_TAG       VARCHAR2(100),
   POLICY_SET_DATE      DATE,
   POLICY_SET_COMMENT   VARCHAR2(255),
   COMPONENT_TYPE       VARCHAR2(50),
   COMPONENT_VERSION    VARCHAR2(20),
   CONTAINER_TYPE       VARCHAR2(50),
   POLICY_SET_STATUS    CHAR(1)
);

alter table POLICY_SET
   add constraint PK_POLICY_SET primary key (POLICY_SET_ID, POLICY_SET_VERSION);



create table POLICY_SET_OBJECTS  (
   POLICY_SET_OBJECT_ID NUMBER(12)                       not null,
   POLICY_SET_OBJECT_VERSION NUMBER(8,2)                      not null,
   POLICY_SET_OBJECT_TYPE VARCHAR2(20)                     not null,
   POLICY_SET_OBJECT_ORDER NUMBER(6)                        not null,
   COMPONENT_TYPE       VARCHAR2(50),
   COMPONENT_VERSION    VARCHAR2(20),
   CONTAINER_TYPE       VARCHAR2(50),
   OBJECT_ID            NUMBER(12),
   REVISED              CHAR(1),
   POLICY_SET_ID        NUMBER(12),
   POLICY_SET_OBJECT_STATUS CHAR(1)
);

alter table POLICY_SET_OBJECTS
   add constraint PK_POLICY_SET_OBJECTS primary key (POLICY_SET_OBJECT_ID, POLICY_SET_OBJECT_VERSION);



create table STEP_TEMPLATE  (
   STEP_ID              VARCHAR2(50)                     not null,
   STEP_VERSION         NUMBER(6)                        not null,
   COMPONENT_ID         VARCHAR2(30)                     not null,
   STEP_STATUS          CHAR(1)                          not null,
   STEP_NAME            VARCHAR2(150),
   STEP_PACKAGE         VARCHAR2(255),
   COMPONENT_TYPE       VARCHAR2(50),
   COMPONENT_VERSION    VARCHAR(20),
   CONTAINER_TYPE       VARCHAR2(50),
   OBJECT_ID            NUMBER(12),
   STEP_DATE            DATE,
   STEP_TAG             VARCHAR2(100),
   STEP_COMMENT         VARCHAR2(255)
);

alter table STEP_TEMPLATE
   add constraint PK_STEP_TEMPLATE primary key (STEP_ID, STEP_VERSION, COMPONENT_ID);

DROP SEQUENCE OBJECT_ID_SEQ
;
DROP SEQUENCE POLICY_SET_ID_SEQ
;
DROP SEQUENCE POLICY_SET_OBJECT_ID_SEQ
;
DROP SEQUENCE POLICY_ID_SEQ
;
DROP SEQUENCE PIPELINE_ID_SEQ
;

CREATE SEQUENCE OBJECT_ID_SEQ 
INCREMENT BY 1 
START WITH 3001 
MINVALUE 1 
MAXVALUE 999999999999
CYCLE NOCACHE
;
CREATE SEQUENCE POLICY_SET_ID_SEQ 
INCREMENT BY 1 
START WITH 3001 
MINVALUE 1 
MAXVALUE 999999999999
CYCLE NOCACHE
;
CREATE SEQUENCE POLICY_SET_OBJECT_ID_SEQ 
INCREMENT BY 1 
START WITH 3001 
MINVALUE 1 
MAXVALUE 999999999999
CYCLE NOCACHE
;
CREATE SEQUENCE POLICY_ID_SEQ 
INCREMENT BY 1 
START WITH 3001 
MINVALUE 1 
MAXVALUE 999999999999
CYCLE NOCACHE
;
CREATE SEQUENCE PIPELINE_ID_SEQ 
INCREMENT BY 1 
START WITH 3001 
MINVALUE 1 
MAXVALUE 999999999999
CYCLE NOCACHE
;
drop table WSM_TEST cascade constraints;


create table WSM_TEST  (
   WSM_TEST_ID              NUMBER(8)
);
commit;
exit;