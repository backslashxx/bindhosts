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

if [ -f /data/adb/modules/bindhosts/hosts ] ; then
 echo "old hosts file found! copying..."
 cp /data/adb/modules/bindhosts/hosts $MODDIR/hosts
fi

if [ -f /data/adb/modules/hosts/system/etc/hosts ] ; then
 echo "old hosts file found! copying..."
 cp /data/adb/modules/hosts/system/etc/hosts $MODDIR/hosts
fi

if [ -f /data/adb/modules/systemless-hosts-KernelSU-module/system/etc/hosts ] ; then
 echo "old hosts file found! copying..."
 cp /data/adb/modules/systemless-hosts-KernelSU-module/system/etc/hosts $MODDIR/hosts
fi

ls $MODDIR/hosts > /dev/null || cat /system/etc/hosts > $MODDIR/hosts
chcon -r u:object_r:system_file:s0 "$MODDIR/hosts"
chmod 644 $MODDIR/hosts

if [ -f ${SUSFS_BIN} ] ; then
	#susfs >= 110 support
	echo "susfs >= 1.1.0 found! adding to try_umount list...."
	mount --bind "$MODDIR/hosts" /system/etc/hosts
	${SUSFS_BIN} add_try_umount /system/etc/hosts
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
