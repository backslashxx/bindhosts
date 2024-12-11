#!/bin/sh
PATH=$PATH:/data/adb/ap/bin:/data/adb/magisk:/data/adb/ksu/bin
SUSFS_BIN=/data/adb/ksu/bin/ksu_susfs
. $MODPATH/utils.sh
PERSISTENT_DIR=/data/adb/bindhosts

# grab own info (version)
versionCode=$(grep versionCode $MODPATH/module.prop | sed 's/versionCode=//g' )

echo "[+] bindhosts v$versionCode "
echo "[%] customize.sh "

# persistence
[ ! -d $PERSISTENT_DIR ] && mkdir -p $PERSISTENT_DIR

# check for other systemless hosts modules and disable them
# sorry I had to do this.
modulenames="hosts systemless-hosts-KernelSU-module systemless-hosts Malwack Re-Malwack cubic-adblock"
for i in $modulenames; do
	if [ -d /data/adb/modules/$i ] ; then
		echo "[!] confliciting module found!"
		echo "[-] disabling $i"
		touch /data/adb/modules/$i/disable
	fi
done

# copy our old hosts file
if [ -f /data/adb/modules/bindhosts/system/etc/hosts ] ; then
	echo "[+] migrating hosts file "
	cat /data/adb/modules/bindhosts/system/etc/hosts > $MODPATH/system/etc/hosts
fi

# normal flow for persistence
# move over our files, remove after
files="blacklist.txt custom.txt sources.txt whitelist.txt"
for i in $files ; do
	if [ ! -f /data/adb/bindhosts/$i ] ; then
		cat $MODPATH/$i > $PERSISTENT_DIR/$i
	fi
	rm $MODPATH/$i
done

# standard stuff
grep -q "#" $MODPATH/system/etc/hosts || cat /system/etc/hosts > $MODPATH/system/etc/hosts
susfs_clone_perm "$MODPATH/system/etc/hosts" /system/etc/hosts

# EOF
