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
	#susfs >= 110 support
	mount --bind "$MODDIR/hosts" /system/etc/hosts
	${SUSFS_BIN} add_try_umount /system/etc/hosts	
else
	mount --bind "$MODDIR/hosts" /system/etc/hosts
fi

sleep 1
sed -i '/description/d' $MODDIR/module.prop


if [ -w /system/etc/hosts ] 
then
   echo "bindhosts: service.sh - active ✅" >> /dev/kmsg
   echo "description=status: active ✅" >> $MODDIR/module.prop
else
   echo "description=status: failed 😭 needs correction 💢" >> $MODDIR/module.prop
fi
