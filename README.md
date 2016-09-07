# qpkg_kodi17
Build QNAP package Kodi17 in HYbridDesk (HD_Station)

This repository help to create a QPKG (QNAP package) based on a Kodi17 compilation done outside ... following the rules describe by Kodi team ... SO NO CHANGE TO SOURCE CODE provide by Kodi Team .
The system use to generate the kodi17 MUST be Ubuntu 14.04 L.T.S. up to date
ex. :
a real Linux Ubuntu Desktop
a Virtual Machine (Vmware or Virtualbox)
in the QNAP a chroot or a chroot in a Linux Containers (forgot not easy docker)

In this system you MUST compile kodi and all addons proposed with parameters of your choice (be sure to have Hardware Video Aceleration
(VAAPI and VDPAU) and keep debug until it's a beta ... then suppress it "--disable-debug and --disable-gtest"
ABSOLUTLY MANDATORY generate and install kodi 17 in /opt/kodi17 (--prefix and Cmake options) to use this creator AS IS
... IF you choice another folder ... you must change the multiple shell script referencing it
THEN
do a tar gzip of kodi17 folder in /opt (ex. cd /opt ; tar czf my_kodi17.tgz kodi17/)
then transfer the result in the QNAP (ex. ftp to Public shared folder)

YOU can exit the Ubuntu (you will return in ... only if a missing library appear in next step) .

HOW-TO on QNAP :
1) install git (best use Entware-ng QPKG then opkg install git) ... please no other ...
2 ) clone this repository locally
cd /share/Public (or where you want)
git clone https://github.com/father-mande/qpkg_kodi17 (T.B.C.)
enter in folder mykodi17 created ...
