#!/usr/bin/env sh
MODDIR="${0%/*}"

##### functions
illusion () {
	x=$((RANDOM%4 + 6)); while [ $x -gt 1 ] ; do echo '[.]' ; sleep 0.1 ; x=$((x-1)) ; done &
}

if [ ${KSU} = true ] || [ ${APATCH} = true ] ; then
	MODDIR=$MODPATH
fi

# grab own info (version)
versionCode=$(grep versionCode $MODDIR/module.prop | sed 's/versionCode=//g' )

echo "[+] bindhosts $versionCode "
echo "[+] customize.sh "

if [ ${KSU} = true ] || [ ${APATCH} = true ] ; then
	# it still works on magisk
	# do some checks later like if user has Adaway installed
	echo "[%] 🚨 not compatible with AdAway ❌"
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
		echo "[+] migrating old hosts file to new install"
		cp /data/adb/modules/$i/system/etc/hosts $MODDIR/system/etc/hosts
	fi	
done

# bindhosts-master =< 145
if [ -f /data/adb/modules/bindhosts/hosts ] ; then
	echo "[+] migrating old hosts file to new install"
	cp /data/adb/modules/bindhosts/hosts $MODDIR/system/etc/hosts
fi


# handle upgrades/reinstalls
files="blacklist.txt custom.txt sources.txt whitelist.txt"
for i in $files ; do
	if [ -f /data/adb/modules/bindhosts/$i ] ; then
		echo "[+] migrating old $i to new install"
		cp /data/adb/modules/bindhosts/$i $MODDIR/$i
	fi	
done

grep -v "#" $MODDIR/system/etc/hosts > /dev/null || cat /system/etc/hosts > $MODDIR/system/etc/hosts
chcon -r u:object_r:system_file:s0 "$MODDIR/system/etc/hosts"
chmod 644 $MODDIR/system/etc/hosts

# EOF
