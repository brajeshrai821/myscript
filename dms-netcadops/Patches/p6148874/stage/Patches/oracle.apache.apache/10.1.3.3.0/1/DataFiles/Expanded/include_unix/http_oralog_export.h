#ifndef HTTP_ORALOG_EXPORT_ORACLE
#define HTTP_ORALOG_EXPORT_ORACLE

/*
 * HTTP_ORALOG_ORACLE_EXTERNAL is defined in http_oralog_export.h.
 * Only apache modules who calls ap_oralog and ap_voralog but does not
 * and does not need to know about request_rec and server_rec should 
 * have server_rec and request_rec as void, and include this file 
 * instead of http_oralog.h
 */

#include "http_oralog.h"

#endif /* HTTP_ORALOG_EXPORT_ORACLE */
