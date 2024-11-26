#!/usr/bin/env sh
MODDIR="${0%/*}"


if [ ${KSU} = true ] || [ $APATCH = true ] ; then
	MODDIR=$MODPATH
fi

# grab own info (version)
versionCode=$(grep versionCode $MODDIR/module.prop | sed 's/versionCode=//g' )

echo "[+] bindhosts v$versionCode "
echo "[%] customize.sh "

# try to fix update fuckups
if [ -d /data/adb/modules/bindhosts ] ; then
	folder=/data/adb/modules_update/bindhosts
	mkdir -p $folder
	MODDIR=$folder
fi

# it still works on magisk, but not on apatch/ksu, warn user
if [ ${KSU} = true ] || [ $APATCH = true ] ; then
	pm path org.adaway > /dev/null 2>&1 && echo "[-] 🚨 This version may not work with AdAway 📛"
fi

target_hostsfile="$MODDIR/system/etc/hosts"

if [ -d /data/adb/modules/hostsredirect ] ; then
	# assume its in a working state, just write hosts file in, it doesnt have one on def
	target_hostsfile="/data/adb/hostsredirect/hosts"
	echo "[+] aviraxp's ZN-hostsredirect found!"
	echo "[+] installing in helper mode"
	touch $MODDIR/skip_mount
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
modlist="hosts systemless-hosts-KernelSU-module bindhosts"
for i in $modlist ; do
	if [ -f /data/adb/modules/$i/system/etc/hosts ] ; then
		echo "[+] migrating hosts file"
		cat /data/adb/modules/$i/system/etc/hosts > $target_hostsfile
	fi	
done

# bindhosts-master =< 145
if [ -f /data/adb/modules/bindhosts/hosts ] ; then
	echo "[+] migrating hosts file "
	cat /data/adb/modules/bindhosts/hosts > $target_hostsfile
fi


# handle upgrades/reinstalls
files="blacklist.txt custom.txt sources.txt whitelist.txt"
for i in $files ; do
	if [ -f /data/adb/modules/bindhosts/$i ] ; then
		echo "[+] migrating $i "
		cat /data/adb/modules/bindhosts/$i > $MODDIR/$i
	fi	
done

{
grep -qv "#" $MODDIR/system/etc/hosts || cat /system/etc/hosts > $MODDIR/system/etc/hosts
chcon -r u:object_r:system_file:s0 "$MODDIR/system/etc/hosts"
chmod 644 $MODDIR/system/etc/hosts
} > /dev/null 2>&1 


sleep 2 

# EOF
