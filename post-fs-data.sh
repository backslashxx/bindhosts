#!/usr/bin/env sh
MODDIR="/data/adb/modules/bindhosts"
source $MODDIR/utils.sh
SUSFS_BIN=/data/adb/ksu/bin/ksu_susfs

# always prepare hosts file
[ ! -f $MODDIR/system/etc/hosts ] && cat /system/etc/hosts > $MODDIR/system/etc/hosts
susfs_clone_perm "$MODDIR/system/etc/hosts" /system/etc/hosts

# detect operating operating_modes

# normal operating_mode
# all managers? (citation needed) can operate at this operating_mode
# this assures that we have atleast a base operating operating_mode
mode=0
skip_mount=0

# ksu+susfs operating_mode
# susfs exists so we can hide the bind mount
# if its kernelsu with susfs binary available
# and kmsg has 'susfs_init'
if [ ${KSU} = true ] && [ -f ${SUSFS_BIN} ] ; then
	dmesg | grep -q "susfs_init" && {
		mode=1
		skip_mount=1
		}
fi

# normal apatch operating mode, no hides at all
# hightly detectable
if [ $APATCH = true ]; then
	mode=2
	skip_mount=1
fi

# hosts_file_redirect operating_mode
# this method is APatch only
# no other heuristic other than dmesg
if [ $APATCH = true ]; then
	dmesg | grep -q "hosts_file_redirect" && {
	mode=3
	skip_mount=1
	}
fi

# ZN-hostsredirect operating_mode
# this method works for all but requires zygisk-next and separate module installed
# sadly we can only assume that its on a working state
# unconditionally flag an operating_mode for it regardless of state
if [ -d /data/adb/modules/hostsredirect ] && [ ! -f /data/adb/modules/hostsredirect/disable ] ; then
	mode=4
	skip_mount=1
fi

# override operating mode here
[ -f /data/adb/bindhosts/mode_override.sh ] && source /data/adb/bindhosts/mode_override.sh

# write operating mode to mode.sh 
# service.sh will read it
echo "operating_mode=$mode" > $MODDIR/mode.sh
# skip_mount or not
[ $skip_mount = 0 ] && ( [ -f $MODDIR/skip_mount ] && rm $MODDIR/skip_mount )
[ $skip_mount = 1 ] && ( [ ! -f $MODDIR/skip_mount ] && touch $MODDIR/skip_mount )

# debugging
echo "bindhosts: post-fs-data.sh - probing done" >> /dev/kmsg

#EOF
