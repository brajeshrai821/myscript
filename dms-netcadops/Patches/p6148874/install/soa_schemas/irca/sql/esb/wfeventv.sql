REM +======================================================================+
REM | Copyright (c) 2000 Oracle Corporation Redwood Shores, California, USA|
REM |                       All rights reserved.                           |
REM +======================================================================+
REM
REM NAME
REM     wfeventv.sql  -  create WorkFlow EVENT Manager Views.
REM
REM	09/2002 VARRAJAR Bug 2558446 - Added new columns CUSTOMIZATION_LEVEL
REM			 and LICENSED_FLAG
REM +======================================================================+
REM Connect to base account
REM (autopatch will run all scripts in apps account)

DEFINE hdr = "$Header: wfeventv.sql 22-mar-2006.11:04:10 gsah Exp $"

WHENEVER SQLERROR EXIT FAILURE ROLLBACK;

/*
** WF_EVENTS_VL
*/
create or replace force view WF_EVENTS_VL (
    row_id,
    guid,
    name,
    type,
    status,
    generate_function,    
    JAVA_GENERATE_FUNC,
    owner_name,
    owner_tag,
    customization_level,
    licensed_flag,
    display_name,
    description
  ) as select /* $Header: wfeventv.sql 22-mar-2006.11:04:10 gsah Exp $ */
    b.rowid row_id,
    b.guid,
    b.name,
    b.type,
    b.status,
    b.generate_function,
    b.java_generate_func, 
    b.owner_name,
    b.owner_tag,
    b.customization_level,
    b.licensed_flag,
    tl.display_name,
    tl.description
  from  wf_events b, 
        wf_events_tl tl
  where tl.language = userenv('LANG')
  and   tl.guid = b.guid;

/*
**WF_ACTIVE_SUBSCRIPTIONS_V
*/
CREATE OR REPLACE FORCE VIEW WF_ACTIVE_SUBSCRIPTIONS_V
(EVENT_NAME, GENERATE_FUNCTION, JAVA_GENERATE_FUNC, SYSTEM_GUID, SUBSCRIPTION_GUID, 
 SUBSCRIPTION_SOURCE_TYPE, SUBSCRIPTION_SOURCE_AGENT_GUID, SUBSCRIPTION_PHASE, SUBSCRIPTION_RULE_DATA, SUBSCRIPTION_OUT_AGENT_GUID, 
 SUBSCRIPTION_TO_AGENT_GUID, SUBSCRIPTION_PRIORITY, SUBSCRIPTION_RULE_FUNCTION, JAVA_SUBSCRIPTION_RULE_FUNC, WF_PROCESS_TYPE, 
 WF_PROCESS_NAME, SUBSCRIPTION_PARAMETERS, SUBSCRIPTION_ON_ERROR_TYPE, TARGET_EVENT_GUID, FILTER_EXPRESSION, EXECUTION_SYSTEM_GUID)
AS 
SELECT 
  evt.name EVENT_NAME,
  evt.generate_function GENERATE_FUNCTION,
  evt.java_generate_func JAVA_GENERATE_FUNC,
  sub.system_guid SYSTEM_GUID,
  sub.guid SUBSCRIPTION_GUID,
  sub.source_type SUBSCRIPTION_SOURCE_TYPE,
  sub.source_agent_guid SUBSCRIPTION_SOURCE_AGENT_GUID,
  NVL(sub.phase,0) SUBSCRIPTION_PHASE,
  sub.rule_data SUBSCRIPTION_RULE_DATA,
  sub.out_agent_guid SUBSCRIPTION_OUT_AGENT_GUID,
  sub.to_agent_guid SUBSCRIPTION_TO_AGENT_GUID,
  sub.priority SUBSCRIPTION_PRIORITY,
  sub.rule_function SUBSCRIPTION_RULE_FUNCTION,
  sub.java_rule_func JAVA_SUBSCRIPTION_RULE_FUNC,
  sub.wf_process_type WF_PROCESS_TYPE,
  sub.wf_process_name WF_PROCESS_NAME,
  sub.parameters SUBSCRIPTION_PARAMETERS,
  sub.on_error_code SUBSCRIPTION_ON_ERROR_TYPE,
  sub.target_event_guid TARGET_EVENT_GUID,
  sub.filter_expression FILTER_EXPRESSION,
  sub.execution_system_guid EXECUTION_SYSTEM_GUID
FROM 
  wf_events evt,
  wf_event_subscriptions sub
WHERE 
  evt.guid = sub.event_filter_guid AND
  evt.system_guid = sub.system_guid AND
  sub.status = 'ENABLED'   AND
  sub.licensed_flag = 'Y'   AND
  evt.type = 'EVENT'   AND
  evt.status = 'ENABLED'   AND
  evt.licensed_flag = 'Y'
UNION ALL (
  SELECT evt.name EVENT_NAME,    	
    evt.generate_function GENERATE_FUNCTION,          
    evt.java_generate_func JAVA_GENERATE_FUNC,
    sub.system_guid SYSTEM_GUID,
    sub.guid SUBSCRIPTION_GUID,
    sub.source_type SUBSCRIPTION_SOURCE_TYPE,
    sub.source_agent_guid SUBSCRIPTION_SOURCE_AGENT_GUID,
    NVL(sub.phase, 0) SUBSCRIPTION_PHASE,
    sub.rule_data SUBSCRIPTION_RULE_DATA,
    sub.out_agent_guid SUBSCRIPTION_OUT_AGENT_GUID,
    sub.to_agent_guid SUBSCRIPTION_TO_AGENT_GUID,
    sub.priority SUBSCRIPTION_PRIORITY,
    sub.rule_function SUBSCRIPTION_RULE_FUNCTION,
    sub.java_rule_func JAVA_SUBSCRIPTION_RULE_FUNC,
    sub.wf_process_type WF_PROCESS_TYPE,
    sub.wf_process_name WF_PROCESS_NAME,
    sub.parameters SUBSCRIPTION_PARAMETERS,
    sub.on_error_code SUBSCRIPTION_ON_ERROR_TYPE,
    sub.target_event_guid TARGET_EVENT_GUID,
    sub.filter_expression FILTER_EXPRESSION,
    sub.execution_system_guid EXECUTION_SYSTEM_GUID
  FROM
    wf_events evt,
    wf_events grp,
    wf_event_groups egrp,
    wf_event_subscriptions sub
  WHERE
    grp.guid = sub.event_filter_guid    AND
    grp.system_guid = sub.system_guid AND
    egrp.group_guid = grp.guid    AND
    egrp.member_guid = evt.guid    AND
    sub.status = 'ENABLED'    AND
    sub.licensed_flag = 'Y'    AND
    grp.type = 'GROUP'    AND
    grp.status = 'ENABLED'    AND
    evt.type = 'EVENT'    AND
    evt.status = 'ENABLED'    AND
    evt.licensed_flag = 'Y'
)
ORDER BY 8;  	
  
rem show errors view esb.WF_ACTIVE_SUBSCRIPTIONS_V;

commit;
Rem exit;
