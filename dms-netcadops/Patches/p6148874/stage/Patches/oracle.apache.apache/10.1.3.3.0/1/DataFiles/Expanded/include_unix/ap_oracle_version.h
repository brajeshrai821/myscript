#ifndef AP_ORACLE_VERSION_H
#define AP_ORACLE_VERSION_H

#ifndef SERVER_BASEVERSION
#define SERVER_BASEVERSION "Dummy Server BaseVersion"
#endif

#ifndef PATCH
#define PATCH "DummyNumber"
#endif

#define VERSION_SEARCH_STRING "&!&!Oracle Application Server 10g Version&!&!"

static char *oracle_version_string = VERSION_SEARCH_STRING SERVER_BASEVERSION "/" PATCH;


#endif AP_ORACLE_VERSION_H

