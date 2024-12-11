#!/bin/sh
PATH=$PATH:/data/adb/ap/bin:/data/adb/magisk:/data/adb/ksu/bin
MODDIR="/data/adb/modules/bindhosts"
PERSISTENT_DIR="/data/adb/bindhosts"
. $MODDIR/mode.sh

magisk_webui_redirect=1

# action.sh
# this is now a shim for bindhosts.sh
force_update() {
	sh $MODDIR/bindhosts.sh --force-update
}

force_reset() {
	sh $MODDIR/bindhosts.sh --force-reset
}

enable_cron() {
	sh $MODDIR/bindhosts.sh --enable_cron
}

toggle_updatejson() {
	sh $MODDIR/bindhosts.sh --toggle-updatejson
}

# add arguments
case "$1" in 
	--force-update) run; exit ;;
	--force-reset) reset; exit ;;
	--enable-cron) enable_cron; exit ;;
	--toggle-updatejson) toggle_updatejson; exit ;;
esac

# read webui setting here
# echo "magisk_webui_redirect=0" > /data/adb/bindhosts/webui_setting.sh
[ -f $PERSISTENT_DIR/webui_setting.sh ] && . $PERSISTENT_DIR/webui_setting.sh

# detect magisk environment here
if [ ! -z "$MAGISKTMP" ] && [ $magisk_webui_redirect = 1 ] ; then
	# courtesy of kow
	if pm list packages | grep -q "com.dergoogler.mmrl"; then
		echo "- Launching WebUI in MMRL WebUI..."
		am start -n "com.dergoogler.mmrl/.ui.activity.webui.WebUIActivity" -e MOD_ID "bindhosts"
		exit 0
	fi
	if pm list packages | grep -q "io.github.a13e300.ksuwebui"; then
		echo "- Launching WebUI in KSUWebUIStandalone..."
		am start -n "io.github.a13e300.ksuwebui/.WebUIActivity" -e id "bindhosts"
		exit 0
	fi
	sh $MODDIR/bindhosts.sh
	exit 0
else
	sh $MODDIR/bindhosts.sh
	exit 0
fi

