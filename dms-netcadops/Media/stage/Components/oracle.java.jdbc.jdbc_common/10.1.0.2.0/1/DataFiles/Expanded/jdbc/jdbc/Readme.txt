
Oracle JDBC Drivers release 10.1.0.2.0 (10g) README
=====================================================


What Is New In This Release ?
-----------------------------

New classes file name for JDK 1.4 and beyond
    Beginning with this release the classes files for JDK 1.4 and
    beyond will be named ojdbc<jdk ver>.jar. So, the classes file for
    JDK 1.4 is named ojdbc14.jar.  The names for the JDK 1.1
    and 1.2 classes files will not be changed. We will not provide
    .zip versions of the classes files beyond JDK 1.2.

Direct support for LOBs in the Thin driver.
    The Thin driver now provides direct support for BFILEs, BLOBs, and
    CLOBs. Prior to this release it supported them via calls to PL/SQL
    routines. 

Statement Caching
    The Oracle statement caching API has been changed. There were
    substantial problems with the previous API and we were able to
    resolve them only by changing the API. The old API is still
    supported, but is deprecated. For details on the new API see the
    JavaDoc. 

Certified with RAC
    The Oracle JDBC drivers are certified to work correctly in an
    Oracle 9i RAC environment.

JDBC 3.0 feature support
    A few critical JDBC 3.0 features are supported.

    JDK 1.4--JDK 1.4 is supported with ojdbc14.jar and
    orai18n.jar. 

    Toggling between global and local transactions--When using an XA
    connection an application can toggle between global and local
    transactions. 

    Savepoints--Savepoints are supported in ojdbc14.jar. They are also
    supported in classes12 and classes11 via Oracle extensions. The
    extensions are forward compatible with ojdbc14.jar. See the
    JavaDoc for more details.

    Reuse of prepared statements--PreparedStatements can be used with
    different pooled connections. This is an important performance
    improvement for middle tier applications.

Connection wrapping
    It is now possible to seamlessly wrap an OracleConnection instance
    with a user defined class that implements
    oracle.jdbc.OracleConnection. Such a wrapper can be used where
    ever a Connection argument is needed (except CustomDatum) and will
    be returned as the value of getConnection. It is recommended that
    users subclass oracle.jdbc.OracleConnectionWrapper if
    possible. If not then base your implementation on the source for
    OracleConnectionWrapper which can be found in the samples
    directory. 

Deprecate RAW(Object) constructor
    The constructor RAW(Object) has been deprecated. It will not be
    removed, but its behavior will be changed in the next major
    release. At present it has a documented, but anomolous behavior
    when passed a String object. It constructs a RAW containing the
    byte representation of the String in the platform encoding. All
    other transformations between Strings and RAWs assume that the
    String is the hex character representation of the bytes in the
    RAW. In the next major release this constructor will be changed to
    conform to that convention. This will also impact ADTs with RAW
    fields constructed from Strings. Two static methods have been
    added to RAW. oldRAW(Object) will always have the current platform
    encoding behavior. newRAW(Object) will always have the hex
    character behavior. See the JavaDoc for more details.

DMS metrics
    The DMS metrics reported by JDBC when using classes12dms.jar have
    been reorganized. Additional metrics on Statements including
    execution and fetch time are reported.

defineColumnType(int, int) of CHAR or VARCHAR column
    Calling defineColumnType as CHAR or VARCHAR and not passing a size
    will now raise a SQLWarining. Beginning in the next major release
    it will throw a SQLException.

OracleLog
    Significant increase in the number of methods that include calls
    to OracleLog. Also, you can enable OracleLog tracing by setting
    system properties. Set oracle.jdbc.Trace to "true" to enable
    tracing. Set oracle.jdbc.LogFile to set the name of the trace
    output file. If this is not set trace output is sent to
    System.out. OracleLog tracing is only available in the debug
    classes files  classes12_g.*, and ojdbc_g.jar and in the
    server side drivers.


Driver Versions
---------------

These are the driver versions in the 10.1.0.2.0 release:

  - JDBC Thin Driver 10.1.0.2.0
    100% Java client-side JDBC driver for use in client applications,
    middle-tier servers and applets.

  - JDBC OCI Driver 10.1.0.2.0
    Client-side JDBC driver for use on a machine where OCI 10.1.0.2.0
    is installed.

  - JDBC Thin Server-side Driver 10.1.0.2.0
    JDBC driver for use in Java program in the database to access
    remote Oracle databases.

  - JDBC Server-side Internal Driver 10.1.0.2.0
    Server-side JDBC driver for use by Java Stored procedures.  This
    driver used to be called the "JDBC Kprb Driver".

For complete documentation, please refer to "JDBC Developer's Guide
and Reference".


Contents Of This Release
------------------------

For all platforms:

  [ORACLE_HOME]/jdbc/lib contains:

  - classes12.jar
    Classes for use with JDK 1.2 and JDK 1.3.  It contains the
    JDBC driver classes, except classes for NLS support in Oracle
    Object and Collection types.

  - classes12_g.jar
    Same as classes12.jar, except that classes were compiled with
    "javac -g" and contain some tracing information.

  - classes12dms.jar
    Same as classes12.jar, except that it contains additional code
    to support Oracle Dynamic Monitoring Service.

  - classes12dms_g.jar
    Same as classes12dms.jar except that classes were compiled with 
    "javac -g" and contain some tracing information.

  - ojdbc14.jar
    Classes for use with JDK 1.4.  It contains the JDBC driver
    classes, except classes for NLS support in Oracle Object and
    Collection types.

  - ojdbc14_g.jar
    Same as ojdbc14.jar, except that classes were compiled with
    "javac -g" and contain some tracing information.

  (ojdbc14dms.jar and ojdbc14dms_g.jar are not provided in 10.1.0.0.
  However, they will be available in the production release.)

  - ocrs12.jar
    Classes that implement the javax.sql.rowset interfaces, like
    CachedRowSet and WebRowSet.  It is to be used with JDK 1.2, 1.3,
    and 1.4.

  - orai18n.jar
    NLS classes for use with JDK 1.2, 1.3 and 1.4.  It contains
    classes for NLS support in Oracle Object and Collection types.
    This jar file replaces the old nls_charset jar/zip files.

  [ORACLE_HOME]/jdbc/doc/javadoc.tar contains the JDBC Javadoc.
  This release contains a beta release of the Javadoc files for the
  public API of the public classes of Oracle JDBC.

  [ORACLE_HOME]/jdbc/demo/demo.tar contains sample JDBC programs.


For the Windows platform:

  [ORACLE_HOME]\bin directory contains ocijdbc10.dll and
  heteroxa10.dll, which are the libraries used by the JDBC OCI
  driver.

For non-Windows platforms:

  [ORACLE_HOME]/lib directory contains libocijdbc10.so,
  libocijdbc10_g.so, libheteroxa10.so and libheteroxa10_g.so, which
  are the shared libraries used by the JDBC OCI driver.


NLS Extension Jar File (for client-side only)
---------------------------------------------

The JDBC Server-side Internal Driver provides complete NLS support.
It does not require any NLS extension jar file.  Discussions in this
section only apply to the Oracle JDBC Thin and JDBC OCI drivers.

The basic jar files (classes12.jar and ojdbc14.jar) contain all the
necessary classes to provide complete NLS support for:

  - Oracle Character sets for CHAR/VARCHAR/LONGVARCHAR/CLOB type data
    that is not retrieved or inserted as a data member of an Oracle
    Object or Collection type.

  - NLS support for CHAR/VARCHAR data members of Objects and
    Collections for a few commonly used character sets.  These
    character sets are:  US7ASCII, WE8DEC, WE8ISO8859P1 and UTF8.

Users must include the NLS extension jar file (orai18n.jar) in their
CLASSPATH if utilization of other character sets in CHAR/VARCHAR
data members of Objects/Collections is desired.  The new orai18n.jar
replaces the nls_charset*.* files in the older releases.

It is important to note that the NLS extension jar file is large in
size due to the requirement of supporting a large number of character
sets.  Users may choose to include only the necessary classes from
the extension jar file if.  To do so, users need to first un-pack the
NLS Extension jar file, and then put only the necessary files in the
CLASSPATH.  The classes inside the extension jar file are named in
the following format:

  lx20<OracleCharacterSetId>.glb        for charactersets
  lx1<OracleTerritoryId>.glb            for territories
  lx3<OralceLinguisticSortId>.glb       for linguistic sort
  lx4<OracleMapingId>.glb               for mappings.

where <Oracle*> is hexadecimal representation of the corresponding
Oracle NLS id.

In addition, users can also include internationalized Jdbc error
message files selectively.  The message files are included in the
oracle/jdbc/driver/Messages_*.properties files in classes12*.jar
and ojdbc14*.jar.


-----------------------------------------------------------------------


Installation
------------

Please do not try to put multiple versions of the Oracle JDBC drivers
in your CLASSPATH.  The Oracle installer installs the JDBC Drivers in
the [ORACLE_HOME]/jdbc directory.


Setting Up Your Environment
---------------------------

On Windows platforms:
  - Add [ORACLE_HOME]\jdbc\lib\classes12.jar to your CLASSPATH if you
    use JDK 1.2 or 1.3.  Add [ORACLE_HOME]\jdbc\lib\ojdbc14.jar to
    your CLASSPATH if you use JDK 1.4.
  - Add [ORACLE_HOME]\jdbc\lib\orai18n.jar to your CLASSPATH if
    you use any NLS features.
  - Add [ORACLE_HOME]\bin to your PATH if you are using the JDBC OCI
    driver.

On Solaris/Digital Unix:
  - Add [ORACLE_HOME]/jdbc/lib/classes12.jar to your CLASSPATH if you
    use JDK 1.2 or 1.3.  Add [ORACLE_HOME]/jdbc/lib/ojdbc14.jar to
    your CLASSPATH if you use JDK 1.4.
  - Add [ORACLE_HOME]/jdbc/lib/orai18n.jar to your CLASSPATH if
    you use any NLS features.
  - Add [ORACLE_HOME]/jdbc/lib to your LD_LIBRARY_PATH if you use
    the JDBC OCI driver.

On HP/UX:
  - Add [ORACLE_HOME]/jdbc/lib/classes12.jar to your CLASSPATH if you
    use JDK 1.2 or 1.3.  Add [ORACLE_HOME]/jdbc/lib/ojdbc14.jar to
    your CLASSPATH if you use JDK 1.4.
  - Add [ORACLE_HOME]/jdbc/lib/orai18n.jar to your CLASSPATH if
    you use any NLS features.
  - Add [ORACLE_HOME]/jdbc/lib to your SHLIB_PATH and LD_LIBRARY_PATH
    if you use the JDBC OCI driver.

On AIX:
  - Add [ORACLE_HOME]/jdbc/lib/classes12.jar to your CLASSPATH if you
    use JDK 1.2 or 1.3.  Add [ORACLE_HOME]/jdbc/lib/ojdbc14.jar to
    your CLASSPATH if you use JDK 1.4.
  - Add [ORACLE_HOME]/jdbc/lib/orai18n.jar to your CLASSPATH if
    you use any NLS features.
  - Add [ORACLE_HOME]/jdbc/lib to your LIBPATH and LD_LIBRARY_PATH
    if you use the JDBC OCI driver.


Some Useful Hints In Using the JDBC Drivers
-------------------------------------------

Please refer to "JDBC Developer's Guide and Reference" for details
regarding usage of Oracle's JDBC Drivers.  This section only offers
useful hints.  These hints are not meant to be exhaustive.

These are a few simple things that you should do in your JDBC program:

 1. Import the necessary JDBC classes in your programs that use JDBC.
    For example:

      import java.sql.*;
      import java.math.*;

    To use OracleDataSource, you need to do:
      import oracle.jdbc.pool.OracleDataSource;

 2. Create an OracleDataSource instance. 

      OracleDataSource ods = new OracleDataSource();

 3. set the desired properties if you don't want to use the
    default properties. Different connection URLs should be
    used for different JDBC drivers.

      ods.setUser("my_user");
      ods.setPassword("my_password");

    For the JDBC OCI Driver:
      To make a bequeath connection, set URL as:
      ods.setURL("jdbc:oracle:oci:@");

      To make a remote connection, set URL as:
      ods.setURL("jdbc:oracle:oci:@<database>");

      where <database> is either a TNSEntryName 
      or a SQL*net name-value pair defined in tnsnames.ora.
 
    For the JDBC Thin Driver, or Server-side Thin Driver:
      ods.setURL("jdbc:oracle:thin:@<database>");

      where <database> is either a string of the form
      //<host>:<port>/<service_name>, or a SQL*net name-value pair.

    For the JDBC Server-side Internal Driver:
      ods.setURL("jdbc:oracle:kprb:");

      Note that the trailing ':' is necessary. When you use the 
      Server-side Internal Driver, you always connect to the
      database you are executing in. You can also do this:

      Connection conn =
        new oracle.jdbc.OracleDriver().defaultConnection();

 4. Open a connection to the database with getConnection()
    methods defined in OracleDataSource class.

      Connection conn = ods.getConnection();


-----------------------------------------------------------------------


The Old oracle.jdbc.driver Package Will Go Away Soon !!!
--------------------------------------------------------

Beginning in Oracle 9i, Oracle extensions to JDBC are captured in
the package oracle.jdbc.  This package contains classes and
interfaces that specify the Oracle extensions in a manner similar
to the way the classes and interfaces in java.sql specify the
public JDBC API.

The use of the package oracle.jdbc.driver has been deprecated
since the initial version of 9i.  Your code should use the package
oracle.jdbc instead.  New features since Oracle 9i are incompatible
with use of the package oracle.jdbc.driver.  Although we continue
to support the old package oracle.jdbc.driver in this release to
provide backwards compatibility, the package will definitely be
removed in the next major release.  If you still have existing
applications that use the old oracle.jdbc.driver package, now is the
time to convert your code.

All that is required to covert your code is to replace
"oracle.jdbc.driver" with "oracle.jdbc" in the source and recompile.
This cannot be done piecewise.  You must convert all classes
and interfaces that are referenced by an application.


Java Stored Procedures
----------------------

Examples for callins and instance methods using Oracle Object Types
can be found in:

  [ORACLE_HOME]/javavm/demo/demo.zip

After you unzip the file, you will find the examples under:

  [ORACLE_HOME]/javavm/demo/examples/jsp


Known Problems/Limitations In This Release
------------------------------------------

The following is a list of known problems/limitations:

 *  If the database character set is AL32UTF8, you may see errors
    under the following circumstances:
    - accessing LONG and VARCHAR2 datatypes.
    - binding data with setString() and setCharacterStream().

 *  Calling getSTRUCT() on ADT data in a ScrollableResultSet may
    result in a NullpointerException.

 *  Binding more than 8000 bytes data to a table containing LONG
    columns in one call of PreparedStatement.executeUpdate() may
    result in an ORA-22295 error.

 *  Some memory Leak when using PreparedStatement with tables 
    containing large char or varchar column.  The problem can be
    worked around by enabling statement caching.

 *  There is a limitation regarding the use of stream input for LOB
    types.  Stream input for LOB types can only be used for 8.1.7 or
    later JDBC OCI driver connecting to an 8.1.7 or later Oracle
    server.  The use of stream input for LOB types in all other
    configurations may result in data corruption.  PreparedStatement
    stream input APIs include: setBinaryStream(), setAsciiStream(),
    setUnicodeStream(), setCharacterStream() and setObject().

 *  Programs can fail to open 16 or more connections using our
    client-side drivers at any one time.  This is not a limitation 
    caused by the JDBC drivers.  It is most likely that the limit of
    per-process file descriptors is exceeded.  The solution is to 
    increase the limit. 

 *  The Server-side Internal Driver has the following limitation:
    - Data access for LONG and LONG RAW types is limited to 32K of
      data.
    - Inserts of Object Types (Oracle Objects, Collections and
      References) will not work when the database compatibility mode
      is set to 8.0.  This limitation does not apply when the
      compatibility mode is set to 8.1.
    - In a chain of SQLExceptions, only the first one in the chain
      will have a getSQLState value.
    - Batch updates with Oracle 8 Object, REF and Collection data
      types are not supported.

 *  The JDBC OCI driver on an SSL connection hangs when the Java
    Virtual Machine is running in green threads mode.  A work-around
    is to run the Java Virtual Machine in native threads mode.

 *  Date-time format, currency symbol and decimal symbols are always
    presented in American convention.

 *  When using OracleStatement.defineColumnType(), it is not necessary
    to define the column type to be the same as the column type
    declared in the database.  If the types are different, the
    retrieved values are converted to the type specified in
    defineColumnType.

    Note:  Most reasonable conversions work, but not all. If you find
    a conversion that you think is reasonable, but that does not work,
    please submit a TAR to Oracle Support.

 *  The utility dbms_java.set_output or dbms_java.set_stream that is
    used for redirecting the System.out.println() in JSPs to stdout
    SHOULD NOT be used when JDBC tracing is turned on.  This is
    because the current implementation of dbms_java.set_output and
    set_stream uses JDBC to write the output to stdout.  The result
    would be an infinite loop.

 *  The JDBC OCI and Thin drivers do not read CHAR data via binary
    streams correctly.  In other word, using getBinaryStream() to
    retrieve CHAR data may yield incorrect results.  A work-around is
    to use either getCHAR() or getAsciiStream() instead.  The other
    alternative is to use getUnicodeStream() although the method is
    deprecated.

 *  There is a limitation for Triggers implemented in Java and Object
    Types.  It only affects the IN argument types of triggers
    implemented using Java on the client-side.  The restriction does
    not apply to JDBC programs running inside the server.  Triggers
    implemented as Java methods cannot have IN arguments of Oracle 8
    Object or Collection type.  This means the Java methods used to
    implement triggers cannot have arguments of the following types:

    - java.sql.Struct
    - java.sql.Array
    - oracle.sql.STRUCT
    - oracle.sql.ARRAY
    - oracle.jdbc2.Struct
    - oracle.jdbc2.Array
    - any class implementing oracle.jdbc2.SQLData or
      oracle.sql.CustomDatum

 *  The scrollable result set implementation has the following
    limitation:

    - setFetchDirection() on ScrollableResultSet does not do anything.
    - refreshRow() on ScrollableResultSet does not support all
      combinations of sensitivity and concurrency.  The following
      table depicts the supported combinations.

        Support     Type                       Concurrency
        -------------------------------------------------------
        no          TYPE_FORWARD_ONLY          CONCUR_READ_ONLY
        no          TYPE_FORWARD_ONLY          CONCUR_UPDATABLE
        no          TYPE_SCROLL_INSENSITIVE    CONCUR_READ_ONLY
        yes         TYPE_SCROLL_INSENSITIVE    CONCUR_UPDATABLE
        yes         TYPE_SCROLL_SENSITIVE      CONCUR_READ_ONLY
        yes         TYPE_SCROLL_SENSITIVE      CONCUR_UPDATABLE

BUG-1516862 (since 9.0.0)
    Passing an OPAQUE type as an argument to a Java Stored Procedure
    does not work.

BUG-1542130 (since 9.0.0)
    The use of OciConnectionPool may cause a hang in a multi-threaded
    environment.

BUG-1640110 (since 9.0.0)
    The JDBC OCI driver may hang when executing a query with invalid
    double quotes in the query string.  This problem only occurs when
    the NLS_LANG environment variable is set.

 *  Access to the new Datetime datatype is supported in all the
    three Jdbc drivers with JDK 1.2, 1.3 and 1.4.  These Datetime data
    types inlcude: TIMESTAMP, TIMESTAMPTZ and TIMESTAMPLTZ.  In 
    addition, String APIs like PreparedStatement.setString() and
    Resultset.getString() do not work for these data types.  Users
    must use setTIMESTAMP*() and getTIMESTAMP*().

BUG-2171766 (since 9.2.0)
    When writing JDBC code that contains SQL method invocations,
    the syntax " ?.method(args,...) " results in the SQL error
    message: ORA-01036: illegal variable name/number. This message
    is somewhat misleading. What is required is that the ? must be
    followed by a " " (space) to avoid this issue.

BUG-2165794 (since 9.2.0)
    DBC XA applications needing to use TMSUSPEND & TMRESUME features
    need to use the TMNOMIGRATE FLAG. If this flag is not used, the
    application may @receive Error ORA 1002: fetch out of sequence.

BUG-2158394 (since 9.2.0)
    ORA-6505 when setting null to char column via stored procedure 
    using setNull() method with java.sql.Types.CHAR. Using
    java.sql.Types.VARCHAR, is ok. Only occurs with Thin driver and
    JA16SJIS or JA16EUC character sets. 

BUG-2148328 (since 9.2.0)
    On Linux, SJIS data in table names  are returned as replacement
    characters with JDK1.2 and JDK1.3 with both the Thin and OCI
    drivers. This is due to a bug in the JDKs. The workaround is to
    use JDK 1.1.8, which does not have this bug.

BUG-2144602 (since 8.1.7)
    When running Windows2000 with the locale set to Chinese (Taiwan)
    and the character set set to ZHT16DBT, all Chinese characters
    are displayed as "?".


BUG-2130384 (since 9.0.1)
    Does not raise ORA-22814 as it should when inserting too large
    of an element value into a VARRAY using setARRAY.

BUG-2249191
    In the Server Internal Driver, setting the query timeout does not
    (and likely will never) work. The query execution will not be
    canceled when the timeout expires, even if the query runs forever.
    Further, after the query returns, the execution of your code
    may pause for the length of the timeout.

BUG-2213820
    OracleConnectionCacheImpl cannot be serialized because it has a
    member that is not serializable. This causes some problems with
    JSPs that store the connection cache as a bean in session scope.

BUG-2180673
    When using OracleOCIConnectionPool, the methods getPoolSize and
    getActiveSize return the wrong results. getPoolSize always returns
    minLimit and getActiveSize always returns 0.

BUG-1910217
    TIMESTAMPs are not supported in ADTs.

BUG-2245502
    If you use the Thin driver to connect to an 8.1.7 database, and 
    then attempt to access a 7.3.4 database via DBLinks using bind
    variables, the values of the bind variables may be swapped.

BUG-2183691
    The insertRow method on an updateable result set inserts the row
    into the database, but does not insert it into the result set
    itself. 

BUG-2095829
    In the Server Internal Driver, calling a PL/SQL procedure and 
    passing a NULL value to an argument of a user defined type fails.
    In some cases the session hangs, in others you will get ora-3113, 
    ora-3114, or ora-24323.

BUG-1568923 
    Using the OCI driver, using setBytes to insert more than 50K into
    a LONG RAW truncates the inserted value.
