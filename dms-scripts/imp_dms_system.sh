#!/bin/sh

# "single_file" - Either run imp once for entire DMS database or once for each DMS schema
#    "y" = Run imp once for entire DMS database (all schemas)
#    "n" = Run imp once for each DMS schema (astatus, astorm, netc, adm)
single_file=y

# "systemConnect" = Oracle system user connect string"
systemConnect=system/Dmssystem11@dmssgrq

# "import_dir" = Directory to read dumps from and write logs to
import_dir=${CADOPS_ROOT}/dms_export

# "filename" = Filename to use for dumps and logs
filename=dms

# "from_prefix" = Prefix for Oracle schema user that is included in the dump file being imported
from_prefix=oge

# "to_prefix" = Prefix for Oracle schema user to import the dump file into
to_prefix=dms1

# "import_opts" = Options passed to the imp command
import_opts="ignore=y grants=n"

mkdir -p ${import_dir}

if [ "$single_file" = "y" ]
then

    dmpfile=${import_dir}/full_${filename}.dmp
    logfile=${import_dir}/full_${filename}_imp.log
    fromuser=${from_prefix},${from_prefix}_a,${from_prefix}_nc,${from_prefix}_adm
    touser=${to_prefix},${to_prefix}_a,${to_prefix}_nc,${to_prefix}_adm
    echo imp ${systemConnect} file=${dmpfile} log=${logfile} fromuser=${fromuser} touser=${touser} ${import_opts}
    imp ${systemConnect} file=${dmpfile} log=${logfile} fromuser=${fromuser} touser=${touser} ${import_opts}

else
    for schema in astatus astorm netc adm
    do

      dmpfile=${import_dir}/${schema}_${filename}.dmp
      logfile=${import_dir}/${schema}_${filename}_imp.log

      case "$schema" in
        astatus) fromuser=${from_prefix};;
        astorm) fromuser=${from_prefix}_a;;
        netc) fromuser=${from_prefix}_nc;;
        adm) fromuser=${from_prefix}_adm;;
      esac

      case "$schema" in
        astatus) touser=${to_prefix};;
        astorm) touser=${to_prefix}_a;;
        netc) touser=${to_prefix}_nc;;
        adm) touser=${to_prefix}_adm;;
      esac

      echo imp ${systemConnect} file=${dmpfile} log=${logfile} fromuser=${fromuser} touser=${touser} ${import_opts}
      imp ${systemConnect} file=${dmpfile} log=${logfile} fromuser=${fromuser} touser=${touser} ${import_opts}

    done
fi
