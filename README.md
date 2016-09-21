# qpkg_kodi17 BETA 2
**Build QNAP package Kodi17 in HYbridDesk (HD_Station)**

This repository help to create a QPKG (QNAP package) based on a Kodi17 compilation done outside ... following the rules describe by Kodi team ... SO NO CHANGE TO SOURCE CODE provide by Kodi Team .

**HOW-TO on QNAP :**

1) install git (best use Entware-ng QPKG then opkg install git) ... please no other ...

2 ) clone this repository locally : 
cd /share/Public (or where you want)
git clone https://github.com/father-mande/qpkg_kodi17 
enter in folder mykodi17 created ...

3 ) add binary generated or supply by me ( in opt folder).  
A file with link to pre-compiled version is available in opt folder.  
Please README in opt folder.

4 ) add libraries missing in HD_Station (in opt/kodi17 folder)

5 ) customize the userdata and addons to be compliant with QNAP specific (original are saved)
... using cp_qnap_files.sh

6 ) change if need qpkg.cfg (ex. change version to upadte existing)

7 ) generate the qpkg and zip (of the qpkg) ... using create_final_tar.sh

It's all .

