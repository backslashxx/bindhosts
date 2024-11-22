#!/usr/bin/env sh
MODDIR="/data/adb/modules/bindhosts"

ls $MODDIR/system/etc/hosts || cat /system/etc/hosts > $MODDIR/system/etc/hosts
chcon -r u:object_r:system_file:s0 "$MODDIR/system/etc/hosts"
chmod 644 $MODDIR/system/etc/hosts

# catch hfr
dmesg | grep -q "hosts_file_redirect" && {
	touch $MODDIR/skip_mount
	touch $MODDIR/.hfr_found
}

# catch znhr
if [ -d /data/adb/modules/hostsredirect ] ; then
	touch $MODDIR/skip_mount
fi

# useless
echo "bindhosts: post-fs-data.sh - active ✅" >> /dev/kmsg

# EOF
