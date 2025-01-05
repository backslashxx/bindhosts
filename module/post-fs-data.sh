#!/bin/sh
PATH=/data/adb/ap/bin:/data/adb/ksu/bin:/data/adb/magisk:$PATH
MODDIR="/data/adb/modules/bindhosts"
. $MODDIR/utils.sh
SUSFS_BIN=/data/adb/ksu/bin/ksu_susfs

# always try to prepare hosts file
if [ ! -f $MODDIR/system/etc/hosts ]; then
	mkdir -p $MODDIR/system/etc
	cat /system/etc/hosts > $MODDIR/system/etc/hosts
	printf "127.0.0.1 localhost\n::1 localhost\n" >> $MODPATH/system/etc/hosts
fi
susfs_clone_perm "$MODDIR/system/etc/hosts" /system/etc/hosts

# detect operating operating_modes

# normal operating_mode
# all managers? (citation needed) can operate at this operating_mode
# this assures that we have atleast a base operating operating_mode
mode=0
skip_mount=0

# ksu next 12183
# ksu next added try_umount /system/etc/hosts recently
# lets try to add it onto the probe
if [ "$KSU_NEXT" = "true" ] && [ "$KSU_KERNEL_VER_CODE" -ge 12183 ]; then
	mode=6
	skip_mount=1
fi

# ksu+susfs operating_mode
# due to susfs4ksu policy change, theres a lot of fuckups that will
# happen if I still try to keep bind mount for them
# with this I'll be forcing ALL legacy susfs users pre 153 onto overlayfs mode.
if [ ${KSU} = true ] && [ -f ${SUSFS_BIN} ] ; then
	if [ $(${SUSFS_BIN} show version | head -n1 | sed 's/v//; s/\.//g') -ge 153 ]; then
		echo "bindhosts: post-fs-data.sh - susfs 153+ found" >> /dev/kmsg
		mode=1
		skip_mount=1
	else
		# theres no other way to probe for legacy susfs
		dmesg | grep -q "susfs" > /dev/null && {
		echo "bindhosts: post-fs-data.sh - legacy susfs found" >> /dev/kmsg
		mode=8
		skip_mount=1
		}
	fi
fi

# plain bindhosts operating mode, no hides at all
# we enable this on apatch if its NOT on magisk mount
# as this allows better compatibility
# on current apatch ci, magic mount is now opt-out
# if apatch and doesnt have override; then check for envvar
# if no envar or false, mode 2.
# this logic we catch old versions that doesnt have the envvar
# so every apatch on overlayfs will fall onto this.
if [ $APATCH = true ] && [ ! -f /data/adb/.bind_mount_enable ]; then 
	if [ -z $APATCH_BIND_MOUNT ] || [ $APATCH_BIND_MOUNT = false ]; then
		mode=2
		skip_mount=1
	fi
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
# method works for all, requires zn-hostsredirect + zygisk-next
# while `znctl dump-zn` gives us an idea if znhr is running, 
# znhr starts at late service when we have to decide what to do NOW.
# we can only assume that it is on a working state
# here we unconditionally flag an operating_mode for it
if [ -d /data/adb/modules/hostsredirect ] && [ ! -f /data/adb/modules/hostsredirect/disable ] && 
	[ -d /data/adb/modules/zygisksu ] && [ ! -f /data/adb/modules/zygisksu/disable ]; then
	mode=4
	skip_mount=1
fi

# override operating mode here
[ -f /data/adb/bindhosts/mode_override.sh ] && {
	echo "bindhosts: post-fs-data.sh - mode_override found!" >> /dev/kmsg
	skip_mount=1 
	. /data/adb/bindhosts/mode_override.sh
	[ $mode = 0 ] && skip_mount=0
	}

# write operating mode to mode.sh 
# service.sh will read it
echo "operating_mode=$mode" > $MODDIR/mode.sh
# skip_mount or not
[ $skip_mount = 0 ] && ( [ -f $MODDIR/skip_mount ] && rm $MODDIR/skip_mount )
[ $skip_mount = 1 ] && ( [ ! -f $MODDIR/skip_mount ] && touch $MODDIR/skip_mount )

# debugging
echo "bindhosts: post-fs-data.sh - probing done" >> /dev/kmsg

# EOF
