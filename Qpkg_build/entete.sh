#!/bin/sh
/bin/echo "Install QNAP package on TS-xxx ..."
/bin/grep "/mnt/HDA_ROOT" /proc/mounts 1>>/dev/null 2>>/dev/null
[ $? = 0 ] || return 1
[ -d /mnt/HDA_ROOT/update_pkg/tmp ] || /bin/mkdir -p /mnt/HDA_ROOT/update_pkg/tmp
/bin/dd if=${0} bs=640 skip=1 | /bin/tar zxv -C /mnt/HDA_ROOT/update_pkg/tmp
[ $? = 0 ] || return 1
cd /mnt/HDA_ROOT/update_pkg/tmp && ( /bin/sh qinstall.sh || ( /bin/echo "Installation Abort." && /bin/echo -1 > /tmp/update_process )) && cd .. && /bin/rm -rf /mnt/HDA_ROOT/update_pkg/tmp && exit 10
/bin/echo -1 > /tmp/update_process && exit 1
exit 1
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
