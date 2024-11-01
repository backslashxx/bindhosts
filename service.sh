#!/usr/bin/env sh
MODDIR="/data/adb/modules/bindhosts"

#susfs >=110 support
SUSFS_BIN=/data/adb/ksu/bin/ksu_susfs

until [ "$(getprop sys.boot_completed)" == "1" ]; do
    sleep 1
done


ls $MODDIR/system/etc/hosts > /dev/null || cat /system/etc/hosts > $MODDIR/system/etc/hosts
chcon -r u:object_r:system_file:s0 "$MODDIR/system/etc/hosts"
chmod 644 $MODDIR/system/etc/hosts

if [ ${KSU} = true ] ; then
	# mount --bind only on ksu/apatch, magisk will auto leverage magisk mount
	mount --bind "$MODDIR/system/etc/hosts" /system/etc/hosts
	# if susfs exists, leverage it
	[ -f ${SUSFS_BIN} ] && { 
		# ? ${SUSFS_BIN} add_sus_mount /system/etc/hosts 
		${SUSFS_BIN} add_try_umount /system/etc/hosts '1' 
		# legacy susfs
		${SUSFS_BIN} add_try_umount /system/etc/hosts 
	} > /dev/null 2>&1
fi


sleep 1



if [ -w /system/etc/hosts ] ; then
	echo "bindhosts: service.sh - active ✅" >> /dev/kmsg
	# default string
	string="description=status: active ✅"
	# readout if action.sh did something
	grep "# bindhosts v" /system/etc/hosts > /dev/null 2>&1 && string="description=status: active ✅ | action.sh blocked $(grep -c "0.0.0.0" /system/etc/hosts ) hosts" 
	# write it
	sed -i "s/^description=.*/$string/g" $MODDIR/module.prop
else
	sed -i 's/^description=.*/description=status: failed 😭 needs correction 💢/g' $MODDIR/module.prop
fi



