#!/bin/bash
QPKG_NAME="mykodi17"

[ -f /tmp/${QPKG_CLASS}-${QPKG_NAME}.pid ] && kill $(cat /tmp/${QPKG_CLASS}-${QPKG_NAME}.pid) && sleep 1
if [ -e $QPKG_PATH/before_stop.sh ] ; then
       source $QPKG_PATH/before_stop.sh
fi
if [ -e /tmp/mykodi17_dbus_id ] ; then
        kill -9 $(cat /tmp/mykodi17_dbus_id)
        rm -f /tmp/mykodi17_dbus_id
fi


