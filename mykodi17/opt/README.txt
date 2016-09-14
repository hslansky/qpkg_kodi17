### here you put the kodi17 generated from official Kodi source / Git
### please respect :
### licence and rules from Kodi team
### use /opt/kodi17 as PREFIX to generate the binary (MANDATORY)
The system use to generate the kodi17 MUST be Ubuntu 14.04 L.T.S. up to date
ex. :
a real Linux Ubuntu Desktop ;
a Virtual Machine (Vmware or Virtualbox) ;
in the QNAP a chroot or a chroot in a Linux Containers (forgot not easy docker)

In this system you MUST compile kodi and all addons proposed with parameters of your choice (be sure to have Hardware Video Aceleration
(VAAPI and VDPAU)) and keep debug until it's a beta ... then suppress it "--disable-debug and --disable-gtest".

ABSOLUTLY MANDATORY generate and install kodi 17 in /opt/kodi17 (--prefix and Cmake options) to use this creator AS IS
... IF you choice another folder ... you must change the multiple shell script referencing it
THEN : 
do a tar gzip of kodi17 folder in /opt (ex. cd /opt ; tar czf my_kodi17.tgz kodi17/)
then transfer the result in the QNAP (ex. ftp to Public shared folder)

YOU can exit the Ubuntu (you will return in ... only if a missing library appear in next step) .

ATTENTION a pre-configured version of kodi17 (already compiled) is also provide (binary) BUT you, in this case, trust me !!!!

USE THE tar FILE here to add folder kodi_lib in kodi17 folder
... THIS tar contains additionnal libraries from Ubuntu 14.04 not present in HD_Station (chroot Ubuntu 14.04)
cd /opt/kodi17
tar xzf ../kodi_lib.tgz

