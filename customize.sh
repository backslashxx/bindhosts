#!/usr/bin/env sh
MODDIR="${0%/*}"

#susfs >=110 support
SUSFS_BIN=/data/adb/ksu/bin/ksu_susfs

if [ ${KSU} = true ] ; then
	MODDIR=$MODPATH
fi

# check for other systemless hosts modules and disable them

if [ -d /data/adb/modules/hosts ] ; then
	echo "are you even sure you need this on magisk?!"
	touch /data/adb/modules/hosts/disable
fi

if [ -d /data/adb/modules/systemless-hosts-KernelSU-module ] ; then
	echo "disabling systemless-hosts-KernelSU-module"
	touch /data/adb/modules/systemless-hosts-KernelSU-module/disable
fi

# copy old hosts file
# they differ so not worth doing a loop

if [ -f /data/adb/modules/hosts/system/etc/hosts ] ; then
	echo "old hosts file found! copying..."
	cp /data/adb/modules/hosts/system/etc/hosts $MODDIR/hosts
fi

if [ -f /data/adb/modules/systemless-hosts-KernelSU-module/system/etc/hosts ] ; then
	echo "old hosts file found! copying..."
	cp /data/adb/modules/systemless-hosts-KernelSU-module/system/etc/hosts $MODDIR/hosts
fi

# handle upgrades/reinstalls
files="hosts blacklist.txt custom.txt sources.txt whitelist.txt"
for i in $files ; do
	if [ -f /data/adb/modules/bindhosts/$i ] ; then
		echo "old $i found! copying..."
		cp /data/adb/modules/bindhosts/$i $MODDIR/$i
	fi	
done


# standard stuff
ls $MODDIR/hosts > /dev/null || cat /system/etc/hosts > $MODDIR/hosts
chcon -r u:object_r:system_file:s0 "$MODDIR/hosts"
chmod 644 $MODDIR/hosts

if [ -f ${SUSFS_BIN} ] ; then
	echo "susfs found!"
	${SUSFS_BIN} add_sus_kstat '/system/etc/hosts' > /dev/null 2>&1
	mount --bind "$MODDIR/hosts" /system/etc/hosts
	${SUSFS_BIN} update_sus_kstat '/system/etc/hosts' > /dev/null 2>&1
	${SUSFS_BIN} add_try_umount /system/etc/hosts '1' > /dev/null 2>&1
	
	# for legacy susfs
	${SUSFS_BIN} add_try_umount /system/etc/hosts > /dev/null 2>&1
else
	mount --bind "$MODDIR/hosts" /system/etc/hosts
fi

sleep 1
sed -i '/description/d' $MODDIR/module.prop


if [ -w /system/etc/hosts ] ; then
   echo "bindhosts: customize.sh - active ✅" >> /dev/kmsg
   echo "description=status: active ✅" >> $MODDIR/module.prop
   echo "status: active ✅"
   echo ".. no need to reboot"
else
   echo "description=status: failed 😭 needs correction 💢" >> $MODDIR/module.prop
fi
