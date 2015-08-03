#!/usr/bin/ksh

#
#	dconf_configure
#	
#	who	when		what
#	---	----		----
#	MT/NDD	2000-01-11	SPR-S01990947: Changes made by the SS2-project;
#				- Initial version.
#       SJ/AF   2004-11-23      SPR-S01030902: Set Proj in template.
#      SBL/NMKD 2006-11-29      HP-UX.
#     A Risberg 2009-12-09      Option to omit run devconf if parameter $1 is set.
# ***********
# Description
# ***********

# This script:
#	Perform configuration actions when the Development Configuration
#	tool is installed.
#
#
run_devconf=true
[[ -n $1 && $1 = false ]] && run_devconf=false

[[ $USER = *adm ]] || die "must be project admin"
PROJ=${USER%adm}; export PROJ

prod_anchor=$HOME
if [[ -n ${PROJHOME} ]]
then
   prod_anchor=$PROJHOME
fi

cd $prod_anchor

cp $prod_anchor/config/scripts/devconf $HOME/bin

# Install database template
if [[ ! -r $prod_anchor/config/db/confdb ]]; then
  if [[ -r $prod_anchor/config/db/confdb.template ]]; then
    sed -e "s#<proj>#${PROJ}#g" \
	    $prod_anchor/config/db/confdb.template \
	    > $prod_anchor/config/db/confdb
  fi
fi

if [[ -z ${PROJHOME} ]]
then
   export PROJHOME=$prod_anchor
fi

[[ $run_devconf = true ]] && exec $HOME/bin/devconf
