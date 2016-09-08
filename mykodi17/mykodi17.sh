#!/bin/sh
CONF=/etc/config/qpkg.conf
QPKG_NAME="mykodi17"
QPKG_PATH=$(/sbin/getcfg $QPKG_NAME Install_Path -d "xxx" -f $CONF)
load_module_cdc_adm(){
	lsmod | grep cdc_acm
	if [ $? -eq 0 ] ; then
		echo "cdc-acm.ko already laoded"
	else
		insmod /lib/modules/misc/cdc-acm.ko
	fi
}

case "$1" in
  start)
    ENABLED=$(/sbin/getcfg $QPKG_NAME Enable -u -d FALSE -f $CONF)
    if [ "$ENABLED" != "TRUE" ]; then
        echo "$QPKG_NAME is disabled."
        exit 1
    fi
	if [ -e $QPKG_PATH/before_enable.sh ] ; then
		source $QPKG_PATH/before_enable.sh
	fi
    : ADD START ACTIONS HERE
	[ -p /tmp/HD_Station.ServicePipe ] && echo "$QPKG_NAME start" > /tmp/HD_Station.ServicePipe
    ;;

  stop)
    : ADD STOP ACTIONS HERE
	[ -p /tmp/HD_Station.ServicePipe ] && echo "$QPKG_NAME stop" > /tmp/HD_Station.ServicePipe
    ;;

  restart)
    $0 stop
    $0 start
    ;;
  keep_qnap_env)
    /sbin/setcfg global keep_env "TRUE" -f $QPKG_PATH/${QPKG_NAME}.conf
    ;;
  private_env)
   /sbin/setcfg global keep_env "FALSE" -f $QPKG_PATH/${QPKG_NAME}.conf
   ;;
  set_ALSA)
	grep -q "^export AE_SINK" $QPKG_PATH/startup_shell/startup_mykodi17.sh
	if [ $? -eq 0 ] ; then
		echo "AE_SINK is already set to use ALSA"
	else
		sed -i 's/#export AE_SINK=ALSA/export AE_SINK=ALSA/' $QPKG_PATH/startup_shell/startup_mykodi17.sh
		echo "set ALSA as default audio"
	fi
   ;;
  set_PULSE)
	grep -q "^export AE_SINK" $QPKG_PATH/startup_shell/startup_mykodi17.sh
        if [ $? -eq 0 ] ; then
		sed -i 's/export AE_SI/#export AE_SINK=ALSA/' $QPKG_PATH/startup_shell/startup_mykodi17.sh
		echo "reset ALSA ... so PULSEAUDIO is use by default"
	else
		echo "Already configured for PULSE audio"
	fi
   ;;
  save_user_data)
	FILE_NAME="/share/Public/mykodi$(date +"%Y_%m_%d.%H%M%S").tgz"
	tar czf $FILE_NAME -C $QPKG_PATH/homes/newkodi17 .kodi
	echo "saved user environment in $FILE_NAME ... "
   ;;
  *)
    echo "Usage: $0 {start|stop|restart}"
    echo "Usage: $0 {keep_qnap_env|private_env}"
    echo "Usage: $0 {set_ALSA|set_PULSE}"
    echo "Usage: $0 {save_user_data}"
    exit 1
esac

exit 0
