#!/usr/bin/env sh
MODDIR="${0%/*}"

#susfs >=110 support
SUSFS_BIN=/data/adb/ksu/bin/ksu_susfs

if [ ${KSU} = true ] ; then
	MODDIR=$MODPATH
fi

# check for other systemless hosts modules and disable them

if [ -d /data/adb/modules/hosts ] ; then
	echo "[?] are you even sure you need this on magisk?!"
	touch /data/adb/modules/hosts/disable
fi

if [ -d /data/adb/modules/systemless-hosts-KernelSU-module ] ; then
	echo "[-] disabling systemless-hosts-KernelSU-module"
	touch /data/adb/modules/systemless-hosts-KernelSU-module/disable
fi

# copy old hosts file
# they differ so not worth doing a loop

if [ -f /data/adb/modules/hosts/system/etc/hosts ] ; then
	echo "[+] migrating old hosts file to new install"
	cp /data/adb/modules/hosts/system/etc/hosts $MODDIR/system/etc/hosts
fi

if [ -f /data/adb/modules/systemless-hosts-KernelSU-module/system/etc/hosts ] ; then
	echo "[+] migrating old hosts file to new install"
	cp /data/adb/modules/systemless-hosts-KernelSU-module/system/etc/hosts $MODDIR/system/etc/hosts
fi

# bindhosts-master =< 145
if [ -f /data/adb/modules/bindhosts/hosts ] ; then
	echo "[+] migrating old hosts file to new install"
	cp /data/adb/modules/bindhosts/hosts $MODDIR/system/etc/hosts
fi

# handle upgrades/reinstalls
files="system/etc/hosts blacklist.txt custom.txt sources.txt whitelist.txt"
for i in $files ; do
	if [ -f /data/adb/modules/bindhosts/$i ] ; then
		echo "[+] migrating old $i to new install"
		cp /data/adb/modules/bindhosts/$i $MODDIR/$i
	fi	
done


# standard stuff
grep -v "#" $MODDIR/system/etc/hosts > /dev/null || cat /system/etc/hosts > $MODDIR/system/etc/hosts
chcon -r u:object_r:system_file:s0 "$MODDIR/system/etc/hosts"
chmod 644 $MODDIR/system/etc/hosts

# mount bind on all managers
# this way reboot is optional
mount --bind "$MODDIR/system/etc/hosts" /system/etc/hosts

# if susfs exists, leverage it
[ -f ${SUSFS_BIN} ] && { 
	echo "[+] leveraging susfs's try_umount"
	# ? ${SUSFS_BIN} add_sus_mount /system/etc/hosts 
	${SUSFS_BIN} add_try_umount /system/etc/hosts '1' 
	# legacy susfs
	${SUSFS_BIN} add_try_umount /system/etc/hosts 
} > /dev/null 2>&1

sleep 1

if [ ${KSU} = true ] ; then
	# skip ksu/apatch mount (adaway compat version)
	touch $MODDIR/skip_mount
fi

sed -i '/description/d' $MODDIR/module.prop

# we can check right away if hosts is writable after mount bind
if [ -w /system/etc/hosts ] ; then
   echo "bindhosts: customize.sh - active ✅" >> /dev/kmsg
   echo "description=status: active ✅" >> $MODDIR/module.prop
   echo "status: active ✅"
else
   echo "description=status: failed 😭 needs correction 💢" >> $MODDIR/module.prop
fi

# EOF
