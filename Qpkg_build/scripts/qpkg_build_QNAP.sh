#!/bin/sh
#================================================================
# Copyright (C) 2008 QNAP Systems, Inc.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#----------------------------------------------------------------
#
# qpkg_build
#
#	Abstract: 
#		A program of building QPKG(QNAP PacKaGe)/QNAP HotFix for QNAP TS-509
#
#	HISTORY:
#		2008/03/26	-	Created	- KenChen 
# 
#================================================================

##### QNAPQPKG/QNAPQFIX #####
QPKG_SOURCE_DIR="/mnt/HDA_ROOT/update_pkg"
QPKG_SOURCE_TMPDIR="/mnt/HDA_ROOT/update_pkg/tmp"
QPKG_SOURCE_TMPDIR_SED="\/mnt\/HDA_ROOT\/update_pkg\/tmp"
MAX_STR_LEN=10
MAX_NAMESTR_LEN=20
QFIXFLAG="QNAPQFIX"
QPKGFLAG="QNAPQPKG"
QNAPMODEL_STR=""	# length=10
QNAPNAME_STR=""		# length=20
QNAPVER_STR=""		# length=10
QNAPFWVER_STR=""	# length=10
QNAPFLAG_STR=""		# length=10
RESERVED_SPACE="                                        " # length=100-60
SWAP_STR=""
FINAL_STR=""
QNAPMODEL=""

BUILDQNAPFILE=0
BUILDQFIX=0
RET_RM_QPKG_SOURCE=10
RET_NORMAL=0
QPKG_RETVAL=$RET_RM_QPKG_SOURCE

#####	Func ######
usage(){
	echo "A program of building QPKG(QNAP PacKaGe)/QNAP HotFix for QNAP TS-509"
	echo
	echo "Usage: $0 [NAME] [BUILT_IN_FILE] [BUILT_IN_SCRIPT] [OPTION...]"
	echo
	echo "[NAME] : name of the package"
	echo "[BUILT_IN_FILE] : The .tgz file including a qinstall.sh and the package files"
	echo "[BUILT_IN_SCRIPT] : built-in.sh will be embedded in the .qpkg/.qfix file."
	echo "[OPTION] is specified for update via TS-x09 web UI, the max length of each field is $MAX_STR_LEN"
	echo "	-f	add QNAP file flag"
	echo "	$QPKGFLAG : build a QPKG file."
	echo "	$QFIXFLAG x.x.x : build a Hotfix/Patch file."
	echo
	echo "	-v	add version"
	echo "	ex. 1.0.1"
	echo
	echo "	-m	add Model flag"
	echo "	ex. TS-x09"
	echo
	echo "	-w	add Firmware(for Update Image matching) version "
	echo "	ex. 2.0.0"
	echo
	echo "	--keep-source	do not delete source(.qpkg file) after installation."
	echo
	echo "Example"
	echo "	$0 phpMyAdmin phpMyAdmin-x.x.x-all-languages.tar built-in.sh"
	echo "	$0 phpMyAdmin phpMyAdmin-x.x.x-all-languages.tar built-in.sh -f $QPKGFLAG"
	echo "	$0 HotFix0.0.1 HotFix0.0.1.tgz built-in.sh -f $QFIXFLAG -v 0.0.1"	
	echo "	$0 HotFix0.0.1 HotFix0.0.1.tgz built-in.sh -f $QFIXFLAG -v 0.0.1 -m TS-509"	
	echo
	exit 0
}

_fill_up_str(){
	
	local maxlen=$MAX_STR_LEN
	
	if [ x$2 != x ];then
		[ $2 -lt $MAX_STR_LEN ] || maxlen=$2
	fi
	
	local len1=`echo -n $1 | wc -c | cut -c1-8`
	local len2=`expr $maxlen - $len1`
	
		if [ $len2 -lt 0 ];then
			echo "The lengh of $1 must be less then $maxlen!"
			exit 1
		else
			buf=""
			while [ $len2 -gt 0 ]
			do
				buf="$buf "
				len2=`expr $len2 - 1`
			done
			SWAP_STR="${1}${buf}"
		fi
}

#####	Main ######
#Check args
if [ x$1 = x ] || [ x$2 = x ] || [ x$3 = x ];then
	usage
elif [ ! -f $2 ];then
	echo "$2 not found"
	exit 1
elif [ ! -f $3 ];then
	echo "$3 not found"
	exit 1
fi
QPKG_NAME=$1
QPKG_SOURCE_FILE=$2
QPKG_BUILTIN_SCRIPT=$3
QNAPFILE="${QPKG_NAME}"

_fill_up_str "$QPKG_NAME" $MAX_NAMESTR_LEN
QNAPNAME_STR="$SWAP_STR"

while [ $# -gt 0 ]; do
	arg="$1"
	case $arg in
	-f)
		if [ "x$2" = "x$QFIXFLAG" ] || [ "x$2" = "x$QPKGFLAG" ]; then
			BUILDQNAPFILE=1
			[ "x$2" = "x$QFIXFLAG" ] && BUILDQFIX=1
  	fi
		_fill_up_str $2
		QNAPFLAG_STR="$SWAP_STR"
		shift
		;;
	-m)
		QNAPMODEL=$2
		_fill_up_str $2
		QNAPMODEL_STR="$SWAP_STR"
		shift
		;;
	-v)
		QNAPFILE=${QNAPFILE}_$2
		_fill_up_str $2
		QNAPVER_STR="$SWAP_STR"
		shift
		;;
	-w)
		_fill_up_str $2
		QNAPFWVER_STR="$SWAP_STR"
		shift
		;;
	--keep-source)
		QPKG_RETVAL=$RET_NORMAL
		shift
		;;
	-*)
		usage
		;;
	*)
		;;
	esac
	shift
done

if [ $BUILDQFIX -eq 0 ];then
	if  [ "x$QNAPMODEL" = "x" ]; then
		QNAPFILE=${QNAPFILE}.qpkg
	else
		QNAPFILE=${QNAPFILE}_${QNAPMODEL}.qpkg
	fi
else
	if  [ "x$QNAPMODEL" = "x" ]; then
		QNAPFILE=${QNAPFILE}.qfix
	else
		QNAPFILE=${QNAPFILE}_${QNAPMODEL}.qfix
	fi
fi

if [ $BUILDQNAPFILE -eq 1 ];then
	[ "x$QNAPMODEL_STR" = "x" ] && _fill_up_str "$QNAPMODEL_STR" && QNAPMODEL_STR="$SWAP_STR"
	[ "x$QNAPNAME_STR" = "x" ] && _fill_up_str "$QNAPNAME_STR" $MAX_NAMESTR_LEN && QNAPNAME_STR="$SWAP_STR"
	[ "x$QNAPVER_STR" = "x" ] && _fill_up_str "$QNAPVER_STR" && QNAPVER_STR="$SWAP_STR"
	[ "x$QNAPFWVER_STR" = "x" ] && _fill_up_str "$QNAPFWVER_STR" && QNAPFWVER_STR="$SWAP_STR"
	[ "x$QNAPFLAG_STR" = "x" ] && _fill_up_str "$QNAPFLAG_STR" && QNAPFLAG_STR="$SWAP_STR"
	FINAL_STR="${QNAPMODEL_STR}${RESERVED_SPACE}${QNAPFWVER_STR}${QNAPNAME_STR}${QNAPVER_STR}${QNAPFLAG_STR}"
fi

QPKG_BUILTIN_SCRIPT_TMP=`/bin/mktemp ${QPKG_BUILTIN_SCRIPT}.XXXXXX`
cp ${QPKG_BUILTIN_SCRIPT} ${QPKG_BUILTIN_SCRIPT_TMP}

#replace strings
sed -i "s/QPKG_RETVAL/$QPKG_RETVAL/" $QPKG_BUILTIN_SCRIPT_TMP
sed -i "s/QPKG_SOURCE_TMPDIR/$QPKG_SOURCE_TMPDIR_SED/g" $QPKG_BUILTIN_SCRIPT_TMP

#count built-in script length
len1=`wc -c $QPKG_BUILTIN_SCRIPT_TMP | cut -c1-8`
len2=`expr $len1 - 10`
if [ $len2 -lt 1 ];then
	echo "$QPKG_BUILTIN_SCRIPT contains nothing inside!"
	rm -f $QPKG_BUILTIN_SCRIPT_TMP
	exit 1
elif [ $len2 -gt 9995 ];then
	echo "The length of $QPKG_BUILTIN_SCRIPT must be less then 9999!"
	rm -f $QPKG_BUILTIN_SCRIPT_TMP
	exit 1	
fi
if [ $len2 -ge 997 ];then
	SCRIPT_LEN=`expr $len2 + 4`
else
	SCRIPT_LEN=`expr $len2 + 3`
fi
echo "The length of $QPKG_BUILTIN_SCRIPT is $SCRIPT_LEN."



#start to build qpkg
echo "Start to build"
sed "s/SCRIPT_LEN/$SCRIPT_LEN/" $QPKG_BUILTIN_SCRIPT_TMP > "${QNAPFILE}"
echo "Built-in script done."
### my test d'entete
cat entete.sh > "${QNAPFILE}"
### end test
echo "Add ${QPKG_SOURCE_FILE}..."
cat ${QPKG_SOURCE_FILE} >> "${QNAPFILE}"
if [ $BUILDQNAPFILE = 1 ]; then
	echo -n "$FINAL_STR" >> "${QNAPFILE}"
	echo "[$FINAL_STR] is added."
fi
rm $QPKG_BUILTIN_SCRIPT_TMP
echo "Set Encryption"
qpkg --encrypt "${QNAPFILE}"
echo "${QNAPFILE} has been created."

