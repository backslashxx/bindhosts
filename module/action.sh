#!/bin/sh
PATH=$PATH:/data/adb/ap/bin:/data/adb/magisk:/data/adb/ksu/bin
MODDIR="/data/adb/modules/bindhosts"
PERSISTENT_DIR="/data/adb/bindhosts"
. $MODDIR/mode.sh



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

# detect magisk here
# need logic

sh $MODDIR/bindhosts.sh
