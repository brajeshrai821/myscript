/****h* APORALOG/http_oralog.h
 *
 * Copyright (c) 2001, 2005, Oracle. All rights reserved.  
 *
 * SYNOPSIS
 * ...
 *
 * DESCRIPTION
 * ...
 *
 *****
 */


#ifndef HTTP_ORALOG_ORACLE
#define HTTP_ORALOG_ORACLE

/* HTTP_ORALOG_ORACLE_EXTERNAL is defined in http_oralog_export.h.
 * Only apache modules who calls ap_oralog and ap_voralog but does not
 * and does not need to know about request_rec and server_rec should 
 * have server_rec and request_rec as void.
 */
#ifdef HTTP_ORALOG_EXPORT_ORACLE
typedef void server_rec;
typedef void request_rec;
typedef void pool;
#endif /* HTTP_ORALOG_EXPORT_ORACLE */

/*
 * Possible values derived from the OraLogMode directive
 */
#define ORALOG_MODE_APACHE	1	/* value: "apache" */
#define ORALOG_MODE_ORACLE	2	/* value: "oracle" */
#define ORALOG_MODE_ECIDONLY	3	/* value: "ecid-only" */
#define ORALOG_MODE_UNKNOWN	4	/* value: not yet specified */

/*
 * Highest logging priority level (1) 
 * Lowest logging priority level (32)
 */
#define ORALOG_MIN_LEVEL     1 
#define ORALOG_MAX_LEVEL    32 

#define ORALOG_UNKNOWN_MODULE_ID "unknown_module"

/****s* http_oralog.h/oralog_msgtype_t
 * SYNOPSIS
 * ...
 *
 * DESCRIPTION
 * ...
 * 
 * SOURCE
 */
typedef enum {
    ORALOG_INTERN,
    ORALOG_ERROR,
    ORALOG_WARN,
    ORALOG_NOTICE,
    ORALOG_TRACE,
    ORALOG_UNKNOWN
} oralog_msgtype_t;
/*******/

#define ORALOG_TYPE_MASK         7
#define ORALOG_WITHERRNO         (ORALOG_TYPE_MASK + 1)

/*
 * =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 * Public Interface Functions
 *
 * The functions in this section are intended for use by all module and
 * core developers at any point after the logging environment of apache
 * has been initialized.  When you need to log a diagnostic message, use
 * one of these functions.
 * =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 */
void ap_oralog(
    char *src_fname,
    int src_line,
    oralog_msgtype_t msg_type,
    int msg_level,
    char *msg_group,
    int msg_id,
    server_rec *s,
    request_rec *r,
    char *fmt, ...);

void ap_voralog(
    const char *src_fname,
    int src_line,
    oralog_msgtype_t msg_type,
    int msg_level,
    char *msg_group,
    int msg_id,
    const server_rec *s,
    const request_rec *r,
    const char *fmt,
    va_list args);


/*
 * =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 * Protected Interface Functions
 *
 * The functions in this section are intended for use only by
 * http_oralog.c maintainers and are for setting up and maintaining the
 * logging environment of apache.
 * =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 */

/*
 * Functions related to initialization
 */
void ap_oralog_ctx_init(); /* call first */
void ap_oralog_child_ctx_init();
void ap_oralog_ctx_destroy();
int ap_oralog_set_ecid(request_rec *r, int adjustval);

/*
 * functions related to config processing
 */
char *ap_oralog_set_mode(pool *p, int mode);
char *ap_oralog_set_severity(pool* p, char *module_name,
                             char *msg_type_str, int level);
void ap_oralog_set_module_severity(char *mod_name, int mod_index);
char *ap_oralog_set_location(const char* location);
void ap_oralog_fixup_config(server_rec *s);
void ap_oralog_redirect_stderr(server_rec *s);

/*
 * functions related to logging messages
 */
void ap_oralog_set_module_id(const char *new_mod_id, int new_mod_index,
                              char **old_mod_id, int *old_mod_index);
void ap_oralog_restore_module_id(char *mod_name, int mod_index);
int ap_oralog_get_mode();
void ap_oralog_map_msg_severity_from_apache(int apache_loglevel, 
                                            int *oracle_msg_type,
                                            int *oracle_msg_level);
char *ap_oralog_get_ecid(request_rec *r);
int ap_oralog_parse_ecid(pool *p, char *ecid, char **iid, char **sno);
int ap_oralog_copy_ecid(char *buf, int maxbytes);

#endif /* HTTP_ORALOG_ORACLE */

