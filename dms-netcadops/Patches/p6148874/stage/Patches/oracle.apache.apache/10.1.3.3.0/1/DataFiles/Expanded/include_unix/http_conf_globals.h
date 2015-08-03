/* Copyright 1999-2004 The Apache Software Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef APACHE_HTTP_CONF_GLOBALS_H
#define APACHE_HTTP_CONF_GLOBALS_H

#ifdef __cplusplus
extern "C" {
#endif

/* 
 * Process config --- what the process ITSELF is doing
 */

extern API_VAR_EXPORT int ap_standalone;
extern API_VAR_EXPORT int ap_configtestonly;
extern API_VAR_EXPORT int ap_long_linger;
extern int ap_docrootcheck;
extern API_VAR_EXPORT uid_t ap_user_id;
extern API_VAR_EXPORT char *ap_user_name;
extern API_VAR_EXPORT gid_t ap_group_id;
extern API_VAR_EXPORT int ap_use_webcacheip;
#ifdef NETWARE
extern unsigned int ap_thread_stack_size;
#endif
#ifdef MULTIPLE_GROUPS
extern gid_t group_id_list[NGROUPS_MAX];
#endif
extern API_VAR_EXPORT int ap_max_requests_per_child;
extern API_VAR_EXPORT int ap_threads_per_child;
extern API_VAR_EXPORT int ap_excess_requests_per_child;
extern API_VAR_EXPORT struct in_addr ap_bind_address;
extern API_VAR_EXPORT listen_rec *ap_listeners;
extern API_VAR_EXPORT int ap_daemons_to_start;
extern API_VAR_EXPORT int ap_daemons_min_free;
extern API_VAR_EXPORT int ap_daemons_max_free;
extern API_VAR_EXPORT int ap_daemons_limit;
extern API_VAR_EXPORT int ap_suexec_enabled;
extern API_VAR_EXPORT int ap_listenbacklog;
extern API_VAR_EXPORT int ap_server_header;
#ifdef SO_ACCEPTFILTER
extern int ap_acceptfilter;
#endif
extern int ap_dump_settings;
extern API_VAR_EXPORT int ap_extended_status;
#ifdef EAPI
extern API_VAR_EXPORT ap_ctx *ap_global_ctx;
#endif /* EAPI */

extern API_VAR_EXPORT char *ap_pid_fname;
extern API_VAR_EXPORT char *ap_scoreboard_fname;
extern API_VAR_EXPORT char *ap_lock_fname;
extern API_VAR_EXPORT char *ap_server_argv0;
#ifdef AP_ENABLE_EXCEPTION_HOOK
extern int ap_exception_hook_enabled;
#endif

extern enum server_token_type ap_server_tokens;
extern char* ap_custom_server_token;

extern API_VAR_EXPORT int ap_protocol_req_check;
extern API_VAR_EXPORT int ap_change_shmem_uid;

/* Trying to allocate these in the config pool gets us into some *nasty*
 * chicken-and-egg problems in http_main.c --- where do you stick them
 * when pconf gets cleared?  Better to just allocate a little space
 * statically...
 */

extern API_VAR_EXPORT char ap_server_root[MAX_STRING_LEN];
extern API_VAR_EXPORT char ap_server_confname[MAX_STRING_LEN];

/* for -C, -c and -D switches */
extern API_VAR_EXPORT array_header *ap_server_pre_read_config;
extern API_VAR_EXPORT array_header *ap_server_post_read_config;
extern API_VAR_EXPORT array_header *ap_server_config_defines;

/* We want this to have the least chance of being corrupted if there
 * is some memory corruption, so we allocate it statically.
 */
extern API_VAR_EXPORT char ap_coredump_dir[MAX_STRING_LEN];
extern int ap_coredump_dir_configured;

/*
 * Oracle specific addition - host and port that we will report
 * back to OPMN if the user specified one.  If the user does
 * not specify one, we will pick a value from the first non-SSL
 * virtual host we can find.
 */
extern API_VAR_EXPORT char *ap_opmn_hostport;

/* For bug3192127 to add receive buffer size */
extern API_VAR_EXPORT int ap_server_receive_buffer_size;

/* Bug-4944766 optional alternative path for ap_server_root/logs files */
extern API_VAR_EXPORT char *ap_serverlogs_dir;

/* Bug-5568483 optional alternative path for DMS files */
extern API_VAR_EXPORT char *ap_dms_dir;

#ifdef __cplusplus
}
#endif

#endif	/* !APACHE_HTTP_CONF_GLOBALS_H */