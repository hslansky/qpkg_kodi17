#!/bin/sh
/bin/echo "Install QNAP package on TS-NAS ..."
/bin/grep "/mnt/HDA_ROOT" /proc/mounts 1>>/dev/null 2>>/dev/null
[ $? = 0 ] || return 1
[ -d QPKG_SOURCE_TMPDIR ] || /bin/mkdir -p QPKG_SOURCE_TMPDIR
/bin/dd if=${0} bs=SCRIPT_LEN skip=1 | /bin/tar zxv -C QPKG_SOURCE_TMPDIR
[ $? = 0 ] || return 1
cd QPKG_SOURCE_TMPDIR && ( /bin/sh qinstall.sh || echo "Installation Abort." ) && cd .. && /bin/rm -rf QPKG_SOURCE_TMPDIR && exit QPKG_RETVAL
exit 1
