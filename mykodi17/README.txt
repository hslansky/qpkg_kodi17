#### base folder for mykody17
**.qtv**
contains all file need by QTV (Qnap desktop for HD_Station)
... icons (3)
... xml file use when you clik on incon in QTV
**homes**
contains a first customized base fo .kodi user (small file complete by Kodi at start)
... guisettings.xml : to prevents conflict with QNAP default port
... advancedsettings.xml : to add QNAP's specific CPU/GPU temp script
... sources.xml : to force default to QNAP Multuimedia structure
... keymap : to prevent quitting fullscreen mode
ALL can be reconfigured by user ... through standard Kodi menu
**etc**
contains scripts use when activate / deactivate mykodi17 IN HD_Station
**startup_shell**
contains shell executed when you start mykodi17 by clicking on icon (define in .qtv/qtv.xml)
**opt**
contains kodi17 binary and additionnal libraries not provide in HD_Station

### base file for mykodi17
**.qpkg_iconXXXX.gif**
icons use in Q.T.S. Web Admin menu of HybridDesk (HD_Station)
**.uninstall.sh**
executed to clean QNAP after uninstalling the QPKG
mykodi17.conf.ori
rename mykodi17.conf if not exist ... R.F.U.
**mykodi17.sh**
script use when you Enable / Disable mykodi17 in QNAP side in Web Admin HybridDesk menu

