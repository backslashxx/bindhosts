#!/usr/bin/env sh
MODDIR="/data/adb/modules/bindhosts"

ls $MODDIR/system/etc/hosts || { 
	cat /system/etc/hosts > $MODDIR/system/etc/hosts
	chcon -r u:object_r:system_file:s0 "$MODDIR/system/etc/hosts"
	chmod 644 $MODDIR/system/etc/hosts
} > /dev/null 2>&1

# useless
echo "bindhosts: post-fs-data.sh - active ✅" >> /dev/kmsg

# EOF
