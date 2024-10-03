#!/usr/bin/env sh
MODDIR="/data/adb/modules/bindhosts"

#susfs >=110 support
SUSFS_BIN=/data/adb/ksu/bin/ksu_susfs

until [ "$(getprop sys.boot_completed)" == "1" ]; do
    sleep 1
done


ls $MODDIR/hosts > /dev/null || cat /system/etc/hosts > $MODDIR/hosts
chcon -r u:object_r:system_file:s0 "$MODDIR/hosts"
chmod 644 $MODDIR/hosts

if [ -f ${SUSFS_BIN} ] ; then
	${SUSFS_BIN} add_sus_kstat '/system/etc/hosts' > /dev/null 2>&1
	mount --bind "$MODDIR/hosts" /system/etc/hosts
	${SUSFS_BIN} update_sus_kstat '/system/etc/hosts' > /dev/null 2>&1
	${SUSFS_BIN} add_try_umount /system/etc/hosts '1' > /dev/null 2>&1
	
	# for leagcy susfs
	${SUSFS_BIN} add_try_umount /system/etc/hosts > /dev/null 2>&1
else
	mount --bind "$MODDIR/hosts" /system/etc/hosts
fi

sleep 1



if [ -w /system/etc/hosts ] 
then
	echo "bindhosts: service.sh - active ✅" >> /dev/kmsg
	sed -i 's/^description=.*/description=status: active ✅/g' $MODDIR/module.prop
else
	sed -i 's/^description=.*/description=status: failed 😭 needs correction 💢/g' $MODDIR/module.prop
fi
