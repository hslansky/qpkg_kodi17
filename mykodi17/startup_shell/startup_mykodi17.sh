#!/bin/bash
CONF=/etc/config/qpkg.conf
QPKG_NAME="mykodi17"
QPKG_VERSION_NAME=$(/sbin/getcfg -f $CONF $QPKG_NAME QPKG_VERSION_NAME)
QPKG_DIR=/opt/$QPKG_VERSION_NAME
if [ ! -e ${QPKG_DIR} ] ; then
        ln -s $(/sbin/getcfg $QPKG_NAME Install_Path -f /etc/config/qpkg.conf)/opt/$QPKG_VERSION_NAME /opt/$QPKG_VERSION_NAME
fi
QPKG_PATH=$(/sbin/getcfg $QPKG_NAME Install_Path -f /etc/config/qpkg.conf)

export PATH=$QPKG_DIR/bin:$QPKG_DIR/lib/kodi:$PATH
export LD_LIBRARY_PATH=$QPKG_DIR/kodi_lib:$LD_LIBRARY_PATH
export KODI_HOME=$QPKG_DIR/share/kodi
## HERAFTER ALSA FORCED
export AE_SINK=ALSA
##
# export HOME=/share/homes/newkodi17
QPKG_INSTALL_PATH=$(/sbin/getcfg $QPKG_NAME Install_Path -f /etc/config/qpkg.conf)
export HOME=${QPKG_INSTALL_PATH}/homes/newkodi17
if [ -e $QPKG_PATH/before_start.sh ] ; then
	source QPKG_PATH/before_start.sh
fi
dbuslaunch=$(type -p dbus-launch 2>/dev/null)
if test -z "$DBUS_SESSION_BUS_ADDRESS" -a -x "$dbuslaunch"
then
        eval $($dbuslaunch --sh-syntax)
fi
rm -f /tmp/mykodi17_dbus_id
if [ ! -z "$DBUS_SESSION_BUS_PID" ] ; then
	echo $DBUS_SESSION_BUS_PID > /tmp/mykodi17_dbus_id
fi
$QPKG_DIR/bin/kodi &
echo $! > /tmp/${QPKG_CLASS}-${QPKG_NAME}.pid
wait $!
rm /tmp/${QPKG_CLASS}-${QPKG_NAME}.pid
if [ -e $QPKG_PATH/before_stop.sh ] ; then
	source $QPKG_PATH/before_stop.sh
fi
if test -n "$DBUS_SESSION_BUS_PID"
then
        kill $DBUS_SESSION_BUS_PID
	rm -f /tmp/mykodi17_dbus_id
fi
if [ -e /tmp/mykodi17_dbus_id ] ; then
	kill -9 $(cat /tmp/mykodi17_dbus_id)
	rm -f /tmp/mykodi17_dbus_id
fi
