#!/bin/sh

QPKG=`grep QPKG_NAME qpkg.cfg | cut -f 2 -d "=" | tr -d '"'`
VERSION=`grep QPKG_VER= qpkg.cfg | cut -f 2 -d "=" | tr -d '"'`
echo "QPKG = $QPKG VERSION = $VERSION "
rm -f ${QPKG}.tgz
rm -f ${QPKG}_${VERSION}.zip
rm -f ${QPKG}_${VERSION}.qpkg
cd ${QPKG}
tar czf ../${QPKG}.tgz .
echo " $QPKG tar gz created"
cd ..
tar czf Qpkg_build/${QPKG}.tgz ${QPKG}.tgz qinstall.sh qpkg.cfg
echo " Pre Build $QPKG create "
rm -f ${QPKG}.tgz
cd Qpkg_build/
### rm -f delivery/${QPKG}*
./qpkg_build_QNAP.sh ${QPKG} ${QPKG}.tgz built-in.sh -f QNAPQPKG -v ${VERSION}
mv ${QPKG}_* ../
rm -f ${QPKG}.tgz
cd ..
chmod +x ${QPKG}_*

/usr/local/sbin/zip ${QPKG}_${VERSION}.zip ${QPKG}_${VERSION}.qpkg
# rm -f ${QPKG}_${VERSION}.qpkg
# /opt/bin/zip ${QPKG}_${VERSION}.zip ${QPKG}_${VERSION}.qpkg INSTALL CHANGELOG

