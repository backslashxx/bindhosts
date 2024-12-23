#!/bin/sh
PATH=/data/adb/ap/bin:/data/adb/ksu/bin:/data/adb/magisk:$PATH
MODDIR="/data/adb/modules/bindhosts"
PERSISTENT_DIR="/data/adb/bindhosts"
. $MODDIR/mode.sh

magisk_webui_redirect=1

# action.sh
# a wrapper for bindhosts.sh

# functions
bindhosts_sh() {
	# grab start time
	start_time=$(date +%s)
	# call bindhosts.sh
	sh $MODDIR/bindhosts.sh --action
	# print exec time
	echo "[+] execution time: $(( $(date +%s) - start_time ))s"
	# no need to sleep on Magisk and MMRL 
	# environment stops exec and lets user read
	[ -z "$MAGISKTMP" ] && [ -z "$MMRL" ] && sleep 2
	# exit clean
	exit 0
}

# read webui setting here
# echo "magisk_webui_redirect=0" > /data/adb/bindhosts/webui_setting.sh
[ -f $PERSISTENT_DIR/webui_setting.sh ] && . $PERSISTENT_DIR/webui_setting.sh

# detect magisk environment here
# no need to redirect if inside mmrl
if [ -z "$MMRL" ] && [ ! -z "$MAGISKTMP" ] && [ $magisk_webui_redirect = 1 ] ; then
	# courtesy of kow
	pm path io.github.a13e300.ksuwebui > /dev/null 2>&1 && {
		echo "- Launching WebUI in KSUWebUIStandalone..."
		am start -n "io.github.a13e300.ksuwebui/.WebUIActivity" -e id "bindhosts"
		exit 0
	}
	pm path com.dergoogler.mmrl > /dev/null 2>&1 && {
		echo "- Launching WebUI in MMRL WebUI..."
		am start -n "com.dergoogler.mmrl/.ui.activity.webui.WebUIActivity" -e MOD_ID "bindhosts"
		exit 0
	}
fi
bindhosts_sh

# EOF
