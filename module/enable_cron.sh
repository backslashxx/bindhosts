#!/usr/bin/env sh
MODDIR="/data/adb/modules/bindhosts"
PERSISTENT_DIR="/data/adb/bindhosts"
PATH=$PATH:/data/adb/ap/bin:/data/adb/magisk:/data/adb/ksu/bin

# This script enables cronjobs for bindhosts
# alternatively you can use tasker? to do this
# just call /data/adb/modules/bindhosts/action.sh
# on a shcedule

# at 4 AM daily
# delete bindhosts state before runnign to force update
# there could be a race condition where date hasnt changed
# between runs
if [ ! -d $PERSISTENT_DIR/crontabs ]; then
	mkdir $PERSISTENT_DIR/crontabs
	busybox crond -bc $PERSISTENT_DIR/crontabs -L /dev/null
	echo "0 4 * * * rm /data/adb/bindhosts/bindhosts_state; sh /data/adb/modules/bindhosts/action.sh > /dev/null 2>&1 &" | busybox crontab -c $PERSISTENT_DIR/crontabs -
else
	echo "seems that it is already active, if you have issues fix it yourself"	
fi
# EOF
