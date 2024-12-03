#!/usr/bin/env sh
SUSFS_BIN=/data/adb/ksu/bin/ksu_susfs
source $MODPATH/utils.sh
PERSISTENT_DIR=/data/adb/bindhosts

# grab own info (version)
versionCode=$(grep versionCode $MODPATH/module.prop | sed 's/versionCode=//g' )

echo "[+] bindhosts v$versionCode "
echo "[%] customize.sh "

# persistence
if [ ! -d $PERSISTENT_DIR ] ; then
	mkdir -p $PERSISTENT_DIR
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
	echo "[+] migrating hosts file "
	cat /data/adb/modules/hosts/system/etc/hosts > $MODPATH/system/etc/hosts
fi

if [ -f /data/adb/modules/systemless-hosts-KernelSU-module/system/etc/hosts ] ; then
	echo "[+] migrating hosts file "
	cat /data/adb/modules/systemless-hosts-KernelSU-module/system/etc/hosts > $MODPATH/system/etc/hosts
fi

# bindhosts-master =< 145
if [ -f /data/adb/modules/bindhosts/hosts ] ; then
	echo "[+] migrating hosts file "
	cat /data/adb/modules/bindhosts/hosts > $MODPATH/system/etc/hosts
fi

# handle upgrades/reinstalls
# pre persist migration
files="system/etc/hosts blacklist.txt custom.txt sources.txt whitelist.txt"
for i in $files ; do
	if [ -f /data/adb/modules/bindhosts/$i ] ; then
		echo "[+] migrating $i "
		cat /data/adb/modules/bindhosts/$i > $MODPATH/$i
	fi	
done

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
