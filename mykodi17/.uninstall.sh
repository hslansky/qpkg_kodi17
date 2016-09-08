#!/bin/sh
QPKG_NAME="mykodi17"
CONF=/etc/config/qpkg.conf
# Stop the service before we begin the removal.
if [ -x /etc/init.d/${QPKG_NAME}.sh ]; then
/etc/init.d/${QPKG_NAME}.sh stop
/bin/sleep 5
/bin/sync
fi

# Package specific routines as defined in package_routines.
QPKG_PATH=$(/sbin/getcfg ${QPKG_NAME} Install_Path -f /etc/config/qpkg.conf)
QPKG_VERSION_NAME=$(/sbin/getcfg -f $CONF $QPKG_NAME QPKG_VERSION_NAME)
HDS_PATH=$(/sbin/getcfg HD_Station Install_Path -f /etc/config/qpkg.conf)
rm -f $HDS_PATH/opt/$QPKG_VERSION_NAME

# Remove QPKG directory, init-scripts, and icons.
/bin/rm -fr "$QPKG_PATH"
/bin/rm -f "/etc/init.d/${QPKG_NAME}.sh"
/usr/bin/find /etc/rcS.d -type l -name 'QS*${QPKG_NAME}' | /usr/bin/xargs /bin/rm -f 
/usr/bin/find /etc/rcK.d -type l -name 'QK*${QPKG_NAME}' | /usr/bin/xargs /bin/rm -f
/bin/rm -f "/home/httpd/RSS/images/${QPKG_NAME}.gif"
/bin/rm -f "/home/httpd/RSS/images/${QPKG_NAME}_80.gif"
/bin/rm -f "/home/httpd/RSS/images/${QPKG_NAME}_gray.gif"

# Package specific routines as defined in package_routines.

# Package specific routines as defined in package_routines.


