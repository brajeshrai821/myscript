:
# "single_file" - Either run exp once for entire DMS database or once for each DMS schema
#    "y" = Run exp once for entire DMS database (all schemas)
#    "n" = Run exp once for each DMS schema (astatus, astorm, netc, adm)
single_file=y

# "systemConnect" = Oracle system user connect string"
systemConnect=system/Dmssystem11@dmssgrq

# "export_dir" = Directory to write export dumps and logs to
export_dir=${CADOPS_ROOT}/dms_export

# "filename" = Filename to use for dumps and logs
filename=dms

# "own_prefix" = Prefix for Oracle schema user that is to be exported to the dump file
own_prefix=oge

# "export_opts" = Options passed to the exp command
export_opts="consistent=Y statistics=none buffer=10240000"

mkdir -p ${export_dir}

if [ "$single_file" = "y" ]
then

    dmpfile=${export_dir}/full_${filename}.dmp
    logfile=${export_dir}/full_${filename}_exp.log
    owner=${own_prefix},${own_prefix}_a,${own_prefix}_nc,${own_prefix}_adm
    echo exp ${systemConnect} file=${dmpfile} log=${logfile} owner=${owner} ${export_opts}
    exp ${systemConnect} file=${dmpfile} log=${logfile} owner=${owner} ${export_opts}

else
    for schema in astatus astorm netc adm
    do

      dmpfile=${export_dir}/${schema}_${filename}.dmp
      logfile=${export_dir}/${schema}_${filename}_exp.log

      case "$schema" in
        astatus) owner=${own_prefix};;
        astorm) owner=${own_prefix}_a;;
        netc) owner=${own_prefix}_nc;;
        adm) owner=${own_prefix}_adm;;
      esac

      echo exp ${systemConnect} file=${dmpfile} log=${logfile} owner=${owner} ${export_opts}
      exp ${systemConnect} file=${dmpfile} log=${logfile} owner=${owner} ${export_opts}

    done
fi
