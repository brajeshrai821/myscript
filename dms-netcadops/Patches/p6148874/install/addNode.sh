#!/bin/sh
RM=/usr/bin/rm
LN=/usr/bin/ln
# Local variables
OHOME=%ORACLE_HOME%
FILEMAP=/dev/null
HOME=`/usr/bin/pwd`
if [ -h $OHOME/rdbms/filemap ];then
cd $OHOME/rdbms/filemap
FILEMAP=`/usr/bin/pwd`
$RM $OHOME/rdbms/filemap
fi
cd $HOME
./runInstaller -addNode ORACLE_HOME=$OHOME $*
if [ ${FILEMAP} != /dev/null ];then
$LN -s ${FILEMAP} $OHOME/rdbms/filemap
fi
