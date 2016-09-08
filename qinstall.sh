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
# install.sh 
#
#	Abstract: 
#		A program of QPKG installation on QNAP 
#
#	HISTORY:
# 
#================================================================
##### Util #####
CMD_CHMOD="/bin/chmod"
CMD_CHOWN="/bin/chown"
CMD_CP="/bin/cp"
CMD_CUT="/bin/cut"
CMD_ECHO="/bin/echo"
CMD_GETCFG="/sbin/getcfg"
CMD_GREP="/bin/grep"
CMD_IFCONFIG="/sbin/ifconfig"
CMD_LN="/bin/ln"
CMD_MOUNT="/bin/mount"
CMD_MKDIR="/bin/mkdir"
CMD_MV="/bin/mv"
CMD_READLINK="/usr/bin/readlink"
CMD_RM="/bin/rm"
CMD_SED="/bin/sed"
CMD_SETCFG="/sbin/setcfg"
CMD_SLEEP="/bin/sleep"
CMD_SYNC="/bin/sync"
CMD_TAR="/bin/tar"
CMD_TOUCH="/bin/touch"
CMD_WLOG="/sbin/write_log"
CMD_WGET="/usr/bin/wget"
##### System #####
UPDATE_PROCESS="/tmp/update_process"
UPDATE_PB=0
UPDATE_P1=1
UPDATE_P2=2
UPDATE_PE=3
SYS_HOSTNAME=`/bin/hostname`
SYS_IP=""
ILOG="/tmp/incron_install.log"
IPKG="/opt/bin/ipkg"
SYS_INTERFACE="bond0 eth0 eth1"
SYS_CONFIG_DIR="/etc/config" #put the configuration files here
SYS_INIT_DIR="/etc/init.d"
SYS_rcS_DIR="/etc/rcS.d/"
SYS_rcK_DIR="/etc/rcK.d/"
SYS_QPKG_CONFIG_FILE="/etc/config/qpkg.conf" #qpkg infomation file
SYS_QPKG_CONF_FIELD_QPKGFILE="QPKG_File"
SYS_QPKG_CONF_FIELD_NAME="Name"
SYS_QPKG_CONF_FIELD_VERSION="Version"
SYS_QPKG_CONF_FIELD_ENABLE="Enable"
SYS_QPKG_CONF_FIELD_DATE="Date"
SYS_QPKG_CONF_FIELD_SHELL="Shell"
SYS_QPKG_CONF_FIELD_INSTALL_PATH="Install_Path"
SYS_QPKG_CONF_FIELD_CONFIG_PATH="Config_Path"
SYS_QPKG_CONF_FIELD_WEBUI="WebUI"
SYS_QPKG_CONF_FIELD_WEBPORT="Web_Port"
SYS_QPKG_CONF_FIELD_SERVICEPORT="Service_Port"
SYS_QPKG_CONF_FIELD_SERVICE_PIDFILE="Pid_File"
SYS_QPKG_CONF_FIELD_AUTHOR="Author"

HDS_PATH="xxx"
##### QPKG Info #####
##################################
# please fill up the following items
##################################
#
. qpkg.cfg
#
#####	Func ######
##################################
# custum exit
##################################
#
_exit(){
	local ret=0
	
	case $1 in
		0)#normal exit
			ret=0
			if [ "x$QPKG_INSTALL_MSG" != "x" ]; then
				$CMD_WLOG "${QPKG_INSTALL_MSG}" 4
			else
				$CMD_WLOG "${QPKG_NAME} ${QPKG_VER} installation succeeded." 4
			fi
			$CMD_ECHO "$UPDATE_PE" > ${UPDATE_PROCESS}
		;;
		*)
			ret=1
			if [ "x$QPKG_INSTALL_MSG" != "x" ];then
				$CMD_WLOG "${QPKG_INSTALL_MSG}" 1
			else
				$CMD_WLOG "${QPKG_NAME} ${QPKG_VER} installation failed" 1
			fi
			$CMD_ECHO -1 > ${UPDATE_PROCESS}
		;;
	esac	
	exit $ret
}
#
##################################
# Determine BASE installation location 
##################################
#
find_base(){
	PUBLIC_SHARE=`/sbin/getcfg SHARE_DEF defPublic -d Public -f /etc/config/def_share.info`
	QPKG_BASE=""
	publicdir=`/sbin/getcfg ${PUBLIC_SHARE} path -f /etc/config/smb.conf`
	if [ ! -z $publicdir ] && [ -d $publicdir ];then
		publicdirp1=`/bin/echo $publicdir | /bin/cut -d "/" -f 2`
		publicdirp2=`/bin/echo $publicdir | /bin/cut -d "/" -f 3`
		publicdirp3=`/bin/echo $publicdir | /bin/cut -d "/" -f 4`
		if [ ! -z $publicdirp1 ] && [ ! -z $publicdirp2 ] && [ ! -z $publicdirp3 ]; then
			[ -d "/${publicdirp1}/${publicdirp2}/${PUBLIC_SHARE}" ] && QPKG_BASE="/${publicdirp1}/${publicdirp2}"
		fi
	fi
	
	# Determine BASE installation location by checking where the Public folder is.
	if [ -z $QPKG_BASE ]; then
		for datadirtest in /share/HDA_DATA /share/HDB_DATA /share/HDC_DATA /share/HDD_DATA /share/MD0_DATA /share/MD1_DATA; do
		[ -d $datadirtest/${PUBLIC_SHARE} ] && QPKG_BASE="/${publicdirp1}/${publicdirp2}"
		done
	fi
	if [ -z $QPKG_BASE ] ; then
		echo "The Public share not found."
		_exit 1
	fi
	QPKG_INSTALL_PATH="${QPKG_BASE}/.qpkg"
	QPKG_DIR="${QPKG_INSTALL_PATH}/${QPKG_NAME}"
}
#
##################################
# search qpkg order script call QPKG_RC_NUM=`search_qpkg_number`
##################################
#
search_qpkg_number() {
	INT_NAME=`echo "[""${QPKG_NAME}""]"`
	QPKG_POS=0
	for iq in `grep "\[" $SYS_QPKG_CONFIG_FILE`
	do
		if [ "${INT_NAME}" == "$iq" ] ; then
			break
		else
			QPKG_POS=`expr $QPKG_POS + 1`
		fi
	done
	if [ ${QPKG_POS} -gt 9 ] ; then
		QPKG_RC_NUM="1${QPKG_POS}"
	else
		QPKG_RC_NUM="10${QPKG_POS}"
	fi
	echo "POS = " $QPKG_RC_NUM >> $ILOG
}
#
##################################
# Link service start/stop script
##################################
#
link_start_stop_script(){
	if [ "x${QPKG_SERVICE_PROGRAM}" != "x" ]; then
		$CMD_ECHO "Link service start/stop script: ${QPKG_SERVICE_PROGRAM}"
		$CMD_LN -sf "${QPKG_DIR}/${QPKG_SERVICE_PROGRAM}" "${SYS_INIT_DIR}/${QPKG_SERVICE_PROGRAM}"
		$CMD_LN -sf "${SYS_INIT_DIR}/${QPKG_SERVICE_PROGRAM}" "${SYS_rcS_DIR}/QS${QPKG_RC_NUM}${QPKG_NAME}"
		$CMD_LN -sf "${SYS_INIT_DIR}/${QPKG_SERVICE_PROGRAM}" "${SYS_rcK_DIR}/QK${QPKG_RC_NUM}${QPKG_NAME}"
		$CMD_CHMOD 755 "${QPKG_DIR}/${QPKG_SERVICE_PROGRAM}"
	fi
}
#
##################################
# Set QPKG information
##################################
#
register_qpkg(){

	$CMD_ECHO "Set QPKG information to $SYS_QPKG_CONFIG_FILE"
	[ -f ${SYS_QPKG_CONFIG_FILE} ] || $CMD_TOUCH ${SYS_QPKG_CONFIG_FILE}
	$CMD_SETCFG ${QPKG_NAME} ${SYS_QPKG_CONF_FIELD_NAME} "${QPKG_NAME}" -f ${SYS_QPKG_CONFIG_FILE}
	$CMD_SETCFG ${QPKG_NAME} ${SYS_QPKG_CONF_FIELD_VERSION} "${QPKG_VER}" -f ${SYS_QPKG_CONFIG_FILE}
		
	[ "x${QPKG_DISPLAY_NAME}" = "x" ] || $CMD_SETCFG ${QPKG_NAME} ${SYS_QPKG_CONF_FIELD_DISPLAY_NAME} "${QPKG_DISPLAY_NAME}" -f ${SYS_QPKG_CONFIG_FILE}
	
	#default value to activate(or not) your QPKG if it was a service/daemon
	$CMD_SETCFG ${QPKG_NAME} ${SYS_QPKG_CONF_FIELD_ENABLE} "TRUE" -f ${SYS_QPKG_CONFIG_FILE}
	
	#set the  qpkg file name
	[ "x${SYS_QPKG_CONF_FIELD_QPKGFILE}" = "x" ] && $CMD_ECHO "Warning: ${SYS_QPKG_CONF_FIELD_QPKGFILE} is not specified!!"
	[ "x${SYS_QPKG_CONF_FIELD_QPKGFILE}" = "x" ] || $CMD_SETCFG ${QPKG_NAME} ${SYS_QPKG_CONF_FIELD_QPKGFILE} "${QPKG_QPKG_FILE}" -f ${SYS_QPKG_CONFIG_FILE}
	
	#set the date of installation
	$CMD_SETCFG ${QPKG_NAME} ${SYS_QPKG_CONF_FIELD_DATE} `date +%F` -f ${SYS_QPKG_CONFIG_FILE}
	
	#set the path of start/stop shell script
	[ "x${QPKG_SERVICE_PROGRAM}" = "x" ] || $CMD_SETCFG ${QPKG_NAME} ${SYS_QPKG_CONF_FIELD_SHELL} "${QPKG_DIR}/${QPKG_SERVICE_PROGRAM}" -f ${SYS_QPKG_CONFIG_FILE}
	
	#set path where the QPKG installed, should be a directory
	$CMD_SETCFG ${QPKG_NAME} ${SYS_QPKG_CONF_FIELD_INSTALL_PATH} "${QPKG_DIR}" -f ${SYS_QPKG_CONFIG_FILE}

	#set path where the QPKG configure directory/file is
	[ "x${QPKG_CONFIG_PATH}" = "x" ] || $CMD_SETCFG ${QPKG_NAME} ${SYS_QPKG_CONF_FIELD_CONFIG_PATH} "${QPKG_CONFIG_PATH}" -f ${SYS_QPKG_CONFIG_FILE}
	
	#set the port number if your QPKG was a service/daemon and needed a port to run.
	[ "x${QPKG_SERVICE_PORT}" = "x" ] || $CMD_SETCFG ${QPKG_NAME} ${SYS_QPKG_CONF_FIELD_SERVICEPORT} "${QPKG_SERVICE_PORT}" -f ${SYS_QPKG_CONFIG_FILE}

	#set the port number if your QPKG was a service/daemon and needed a port to run.
	[ "x${QPKG_WEB_PORT}" = "x" ] || $CMD_SETCFG ${QPKG_NAME} ${SYS_QPKG_CONF_FIELD_WEBPORT} "${QPKG_WEB_PORT}" -f ${SYS_QPKG_CONFIG_FILE}

	#set the URL of your QPKG Web UI if existed.
	[ "x${QPKG_WEBUI}" = "x" ] || $CMD_SETCFG ${QPKG_NAME} ${SYS_QPKG_CONF_FIELD_WEBUI} "${QPKG_WEBUI}" -f ${SYS_QPKG_CONFIG_FILE}

	#set the pid file path if your QPKG was a service/daemon and automatically created a pidfile while running.
	[ "x${QPKG_SERVICE_PIDFILE}" = "x" ] || $CMD_SETCFG ${QPKG_NAME} ${SYS_QPKG_CONF_FIELD_SERVICE_PIDFILE} "${QPKG_SERVICE_PIDFILE}" -f ${SYS_QPKG_CONFIG_FILE}

	#Sign up
	[ "x${QPKG_AUTHOR}" = "x" ] && $CMD_ECHO "Warning: ${SYS_QPKG_CONF_FIELD_AUTHOR} is not specified!!"
	[ "x${QPKG_AUTHOR}" = "x" ] || $CMD_SETCFG ${QPKG_NAME} ${SYS_QPKG_CONF_FIELD_AUTHOR} "${QPKG_AUTHOR}" -f ${SYS_QPKG_CONFIG_FILE}		
	# SPECIAL HDStation ....
	$CMD_SETCFG ${QPKG_NAME} Class "HD_Station" -f ${SYS_QPKG_CONFIG_FILE}
# 	$CMD_SETCFG ${QPKG_NAME} Attach "HD_Engine" -f ${SYS_QPKG_CONFIG_FILE}
	# special kodi16/17
	[ "x${QPKG_VERSION_NAME}" = "x" ] || $CMD_SETCFG ${QPKG_NAME} QPKG_VERSION_NAME "$QPKG_VERSION_NAME" -f ${SYS_QPKG_CONFIG_FILE}
 
}

check_existing_install(){
	CURRENT_QPKG_VER="`/sbin/getcfg ${QPKG_NAME} Version -f /etc/config/qpkg.conf`"
	QPKG_INSTALL_MSG="${QPKG_NAME} ${CURRENT_QPKG_VER} is already installed. Setup will now perform package upgrading."
	$CMD_WLOG "${QPKG_INSTALL_MSG}" 4
	QPKG_INSTALL_MSG=""
	$CMD_ECHO "$QPKG_INSTALL_MSG"
}

#
##################################
# Custom functions
##################################
#

get_ip(){
	for interface in $SYS_INTERFACE
	do
		SYS_IP=`$CMD_IFCONFIG $interface | $CMD_GREP "inet addr" | $CMD_CUT -f 2 -d ':' | $CMD_CUT -f 1 -d ' '`
		if [ "$SYS_IP" != "" ]; then
			break
		fi
	done
}

copy_qpkg_icons()
{
        ${CMD_RM} -rf /home/httpd/RSS/images/${QPKG_NAME}.gif;
        ${CMD_CP} -af ${QPKG_DIR}/.qpkg_icon.gif /home/httpd/RSS/images/${QPKG_NAME}.gif

        ${CMD_RM} -rf /home/httpd/RSS/images/${QPKG_NAME}_80.gif;
        ${CMD_CP} -af ${QPKG_DIR}/.qpkg_icon_80.gif /home/httpd/RSS/images/${QPKG_NAME}_80.gif

        ${CMD_RM} -rf /home/httpd/RSS/images/${QPKG_NAME}_gray.gif;
        ${CMD_CP} -af ${QPKG_DIR}/.qpkg_icon_gray.gif /home/httpd/RSS/images/${QPKG_NAME}_gray.gif

}

test_hdstation(){
	HDS_PATH=`${CMD_GETCFG} HD_Station Install_Path -d "xxx" -f /etc/config/qpkg.conf` 
	if [ "$HDS_PATH" = "xxx" ] ; then
		QPKG_INSTALL_MSG="HDStation seems to not be installed ???"
		$CMD_ECHO "$QPKG_INSTALL_MSG"
		_exit 1
	fi
}

#### IS Package yet installed
#
##################################
# Pre-install routine
##################################
#
pre_install(){
	# look for the base dir to install
	find_base
	test_hdstation
	if [ $UPDATE_FLAG -eq 1 ] ; then
		### if old HOME exist save it ...
		if [ -e /share/homes/newkodi17/.kodi ] ; then
			FILE_NAME="/share/Public/OLD_mykodi$(date +"%Y_%m_%d.%H%M%S").tgz"
			tar czf $FILE_NAME -C /share/homes/newkodi17 .kodi
			rm -rf /share/homes/newkodi17
			/sbin/log_tool -t 0 -a "Saved previous mykodi17 user data in $FILE_NAME (to be reuse if needed"
		fi
	fi
	echo "Start log" > $ILOG
	UPDATE_FLAG=0
	
}
#
##################################
# Post-install routine
##################################
#
post_install(){
	## modification to be compliant with previous version
	if [ ! -e $QPKG_DIR/${QPKG_NAME}.conf ] ; then
		cp -p $QPKG_DIR/${QPKG_NAME}.conf.ori $QPKG_DIR/${QPKG_NAME}.conf
	fi
	if [ ! -e $QPKG_DIR/homes/newkodi17/ ] ; then
		mv $QPKG_DIR/homes/newkodi17.base $QPKG_DIR/homes/newkodi17
	else
		if [ ! -e $QPKG_DIR/homes/newkodi17/.kodi/userdata/advancedsettings.xml ] ; then
			cp $QPKG_DIR/homes/newkodi17.base/.kodi/userdata/advancedsettings.xml $QPKG_DIR/homes/newkodi17/.kodi/userdata/advancedsettings.xml
		fi 
	fi
	register_qpkg
	copy_qpkg_icons
	link_start_stop_script
}
#
##################################
# Pre-update routine
##################################
#
#pre_update()
#{
	#
#}
#
##################################
# Post-update routine
##################################
#
#post_update()
#{

#	
#}
#
##################################
# Pre-remove routine
##################################
#pre_remove()
#{
#}

##################################
# Post-remove routine
##################################
#post_remove()
#{
#}

##################################
# Install routines
##################################
#
install()
{
	# pre-install routine
	pre_install
	
if [ -f "${QPKG_SOURCE_DIR}/${QPKG_SOURCE_FILE}" ]; then
		
		# Checking whether we are upgrading or a new install
		
		/sbin/log_tool -t 0 -a " ${QPKG_NAME} New or Update installation"
		# create QPKG_DIR 
		if [ ! -e ${QPKG_DIR} ] ; then
			${CMD_MKDIR} -p ${QPKG_DIR}
		else
			UPDATE_FLAG=1
			## in case stop mykodi 
			/etc/init.d/${QPKG_NAME}.sh stop
			sleep 5
			sync
			## supress previous version
			rm -rf ${QPKG_DIR}/opt/*
		fi
		# complete install or update 
		
		$CMD_TAR xzf "${QPKG_SOURCE_DIR}/${QPKG_SOURCE_FILE}" -C ${QPKG_DIR}
		
else
		QPKG_INSTALL_MSG="${QPKG_NAME} ${QPKG_VER} installation failed. No source file."
		$CMD_ECHO "$QPKG_INSTALL_MSG"
		_exit 1
fi
		
	post_install
		
}

##### Main #####

$CMD_ECHO "$UPDATE_PB" > ${UPDATE_PROCESS}
$CMD_SLEEP 1
$CMD_SYNC
install
$CMD_SYNC
/etc/init.d/${QPKG_NAME}.sh start
_exit 0
