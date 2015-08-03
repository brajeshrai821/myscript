#!/bin/ksh
# File:       auto_conbld.ksh
# Descr:      Build kits as conbld do.
# Parameters: <runcons_name> <product-list name> [all]
# Returns:    0 if ok; otherwise error.
# History:    2007-10-03 NMTA/Bjorn Berglund  Origin.
#             2009-08-31 Anders Risberg       New name and cleaned up.
#             2009-12-13 Anders Risberg       Avoiding aliased ls -> /bin/ls.
#             2010-06-05 Anders Risberg       Release 1.2.19.
#             2010-06-16 Anders Risberg       Re-enabled prodlist-copying.
#             2010-11-26 Anders Risberg       Generalized way to find module directories in spiroot.
#                                             Removed check for previous run (runcons).
#             2010-12-13 Anders Risberg       Enhanced die_msg; added line number; partly moved to auto_common.ksh.
#             2011-04-01 Anders Risberg       Updated way to find module directories in spiroot.
#                                             Cleaned up.
#
#_DEBUG="on"
OS=`uname -s`
default_topdir="spicommon"
prfx="#[$(basename $(readlink -nf $0))]>";

####### Helper functions #######
. ~/autobuild/auto/auto_common.ksh

# Descr: Show help message and die.
# Parameters: [-h] [-e <err_code>] [-l <line no>] [<text>]
# Returns: Error code.
die_msg() {
  die_msg_ex $@
  if [[ $help = true ]];then
    echo
  fi
  
  # Clean-up
  rm -f $conbld_lock_file
  exit $err_code
}

[[ -n $1 ]] && runcons_name=$1
[[ -n $2 ]] && product_list=$2
[[ -n $3 && $3 = "all" ]] && default_topdir="spicommon start spiconf utool config spitop"
[[ -z $runcons_name ]] && die_msg -h -l $LINENO "No runcons name given."
[[ -z $product_list ]] && die_msg -h -l $LINENO "No product list given."

eval projadm=~${PROJ}adm

# Kits-directory
runcons_dir=$PROJHOME/$runcons_name # Path to own runcons-dir;
if [[ ! -d $runcons_dir ]];then
  echo "$prfx Create $runcons_dir"
  mkdir $runcons_dir
fi
# Lock for auto_install
conbld_lock_file=$runcons_dir/kit_bld.lock
echo "Locked for kit_install at `date`" >$conbld_lock_file

curr_ctx="$PROJHOME/${PRIVCTX}root/"
jctools_dir=`find $curr_ctx -maxdepth 3 -type d -name 'jctools'`
num=`echo $jctools_dir|wc -l`
[[ $num -gt 1 ]] && die_msg -l $LINENO "Too many directories found when looking for 'jctools'."
[[ $num -lt 1 ]] && die_msg -l $LINENO "Directory 'jctools' not found."
[[ -n $jctools_dir ]] && config_par_dir=$jctools_dir/source
[[ ! -d $config_par_dir ]] && die_msg -l $LINENO "Directory '$config_par_dir' not found."
intdoc_dir=`find $curr_ctx -maxdepth 3 -type d -name 'intdoc'`
num=`echo $intdoc_dir|wc -l`
[[ $num -gt 1 ]] && die_msg -l $LINENO "Too many directories found when looking for 'intdoc'."
[[ $num -lt 1 ]] && die_msg -l $LINENO "Directory 'intdoc' not found."
[[ -n $intdoc_dir ]] && product_doc_dir=$intdoc_dir/source
conf_dir=`find $curr_ctx -maxdepth 3 -type d -name 'conf'`
num=`echo $conf_dir|wc -l`
[[ $num -gt 1 ]] && die_msg -l $LINENO "Too many directories found when looking for 'conf'."
[[ $num -lt 1 ]] && die_msg -l $LINENO "Directory 'conf' not found."
[[ -n $conf_dir ]] && product_java_dir=$conf_dir/object/java

PROJ_ID=`echo $PROJ|awk '{printf("%s\n",toupper($1))}'`
product_kits="$product_list.prodlist"

# Original product list says what should be installed
[[ ! -e $config_par_dir/$product_kits ]] && die_msg -l $LINENO "Product list '$config_par_dir/$product_kits' not found."
cp -f $config_par_dir/$product_kits $runcons_dir

# Get all non commented out kits
cd $config_par_dir
installed_kits=`cat $product_kits|grep -v "^\#" |sed -e "s/^-//"|awk '{printf("%s\n",tolower($1))}'`
[[ -z $installed_kits ]] && die_msg -l $LINENO "No enabled kits found."
echo "$prfx Built kits from prod_list:" $installed_kits

# Remove all old kits
rm -rf $runcons_dir/KITS

# Build new kits
for m in $installed_kits;do
  cd $config_par_dir

  # Build all kits that are supported on this platform
  installed=""
  if [[ -e ${m}_config_params ]];then
    not_supported=`grep "not_supported_platforms" ${m}_config_params|grep $OS`
    supported_platform=`grep " supported_platforms" ${m}_config_params|grep -v $OS`
    [[ $not_supported != "" || $supported_platform = "" ]] && installed="Y"
  else
    echo "$prfx Cannot find ${m}_config_params on jctools"
  fi

  [[ $installed = "" ]] && echo "$prfx Option $m will not be built on this platform"

  if [[ $installed != "" ]];then
    topdir=`grep "install_topdir" ${m}_config_params|awk -F= '{printf("%s\n",$2)}'`
    kit_id=`echo $m|awk '{printf("%s\n",toupper($1))}'`
    top_dir_ok=`echo "$default_topdir"|grep $topdir`
    echo "$prfx  kit_id=$kit_id, topdir=$topdir, top_dir_ok=$top_dir_ok"

    # Ignore kits that are not part of spicommon
    if [[ $top_dir_ok  != "" ]];then
      # Remove old kit
      [[ -e  $runcons_dir/KITS/${PROJ_ID}_${kit_id}_LOCAL ]] && rm -rf $runcons_dir/KITS/${PROJ_ID}_${kit_id}_LOCAL
      if [[ -e  $runcons_dir/$m ]];then
        chmod -R 755 $runcons_dir/$m
        rm -rf $runcons_dir/$m
      fi

      topd=$runcons_dir/$m/$topdir
      mkdir -p $topd

      # Execute the copy routine
      $config_par_dir/copy_${m} $runcons_dir

      # Create ctrlinst
      mkdir -p $topd/conbld_comps/doc
      chmod -R 755  $topd
      cp $config_par_dir/${m}_config_params $topd/conbld_comps/
      cp $config_par_dir/${m}_configure $topd/conbld_comps/
      [[ -e  $config_par_dir/${m}_prepare ]] && cp $config_par_dir/${m}_prepare $topd/conbld_comps/
      cp $config_par_dir/${m}_deconfigure $topd/conbld_comps/
      javaproduct_class=`echo $m|awk '{printf("Product%s.class",toupper($1))}'`
      [[ -e  $product_java_dir/$javaproduct_class ]] && cp $product_java_dir/$javaproduct_class $topd/conbld_comps/
      [[ -e  $product_doc_dir/${m}_desc.html ]] && pp $product_doc_dir/${m}_desc.html $topd/conbld_comps/doc/
      [[ -e  $product_doc_dir/${m}_*.gif ]] && cp $product_doc_dir/${m}_*.gif $topd/conbld_comps/doc/
      cd $config_par_dir

      # Remove empty directory
      cd $topd
      rmdir $topd/* >/dev/null 2>&1
      du -sk ./ >$topd/conbld_comps/${m}_size
      find ./  >$topd/conbld_comps/${m}_components
      cd $config_par_dir
      echo spikit_bld -t $topd -a /. -k  $runcons_dir/KITS -i  $kit_id -m $mode -x $curr_ctx -c $topd/conbld_comps
      spikit_bld -t $topd -a /. -k  $runcons_dir/KITS -i  $kit_id -m conbld -x $curr_ctx -c $topd/conbld_comps
    fi

    # Remove spicommon container
    if [[ -e $runcons_dir/$m ]];then
      chmod -R 755 $runcons_dir/$m
      rm -rf $runcons_dir/$m
    fi
  else
    echo "$prfx Option $m will be skipped. Not defined in $product_kits or previously built."
  fi
done

# Remove lock file
rm -f $conbld_lock_file
exit 0