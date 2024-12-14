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
	sh $MODDIR/bindhosts.sh
	[ -z "$MAGISKTMP" ] && sleep 2
	exit 0
}

# read webui setting here
# echo "magisk_webui_redirect=0" > /data/adb/bindhosts/webui_setting.sh
[ -f $PERSISTENT_DIR/webui_setting.sh ] && . $PERSISTENT_DIR/webui_setting.sh

# detect magisk environment here
# use MAGISKTMP env var for now, edit this to "command -v magisk >/dev/null 2>&1" once needed
if [ ! -z "$MAGISKTMP" ] && [ $magisk_webui_redirect = 1 ] ; then
	# courtesy of kow
	pm path com.dergoogler.mmrl > /dev/null 2>&1 && {
		echo "- Launching WebUI in MMRL WebUI..."
		am start -n "com.dergoogler.mmrl/.ui.activity.webui.WebUIActivity" -e MOD_ID "bindhosts"
		exit 0
	}
	pm path io.github.a13e300.ksuwebui > /dev/null 2>&1 && {
		echo "- Launching WebUI in KSUWebUIStandalone..."
		am start -n "io.github.a13e300.ksuwebui/.WebUIActivity" -e id "bindhosts"
		exit 0
	}
	bindhosts_sh
else
	bindhosts_sh
fi

# EOF
