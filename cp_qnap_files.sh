#!/bin/sh

PATH_SHARE="mykodi17/opt/kodi17/share/kodi"
echo "copy $PATH_SHARE/system/Lircmap.xml "
mv $PATH_SHARE/system/Lircmap.xml $PATH_SHARE/system/Lircmap.xml.ori
cp qnap/Lircmap.xml $PATH_SHARE/system/Lircmap.xml
echo "copy $PATH_SHARE/addons/skin.estuary/1080i/Home.xml "
mv $PATH_SHARE/addons/skin.estuary/1080i/Home.xml $PATH_SHARE/addons/skin.estuary/1080i/Home.xml.ori
cp qnap/Home.xml $PATH_SHARE/addons/skin.estuary/1080i/Home.xml
echo "copy $PATH_SHARE/system/keymaps/remote.xml "
mv $PATH_SHARE/system/keymaps/remote.xml $PATH_SHARE/system/keymaps/remote.xml.ori
cp qnap/remote.xml $PATH_SHARE/system/keymaps/remote.xml
echo "copy $PATH_SHARE/addons/skin.estuary/1080i/DialogButtonMenu.xml"
mv $PATH_SHARE/addons/skin.estuary/1080i/DialogButtonMenu.xml $PATH_SHARE/addons/skin.estuary/1080i/DialogButtonMenu.xml.ori
cp qnap/DialogButtonMenu.xml $PATH_SHARE/addons/skin.estuary/1080i/DialogButtonMenu.xml


