#!/usr/bin/env sh
MODDIR="/data/adb/modules/bindhosts"

#susfs >=110 support
SUSFS_BIN=/data/adb/ksu/bin/ksu_susfs

echo "bindhosts: action.sh DEMO"
echo "it downloads https://adaway.org/hosts.txt"
echo "to your hosts file"
echo "it will also reset your hosts file if you try again."
echo "think of it as a toggle."

if [ -w /system/etc/hosts ] ; then
	curl --version > /dev/null 2>&1 || (echo "No curl, no go, exiting..." ; exit)
else
	echo "unwritable hosts file 😭 needs correction 💢" ; exit
fi
sleep 3
printf "\n\n\n\n\n\n\n\n"

reset() {
	echo "hosts file reset!"
	echo "127.0.0.1 localhost" > /system/etc/hosts 
	sed -i '/description/d' $MODDIR/module.prop
	echo "description=status: active ✅" >> $MODDIR/module.prop
	echo 1 > $MODDIR/state
	sleep 3
	exit
}
run() {
	curl -s https://adaway.org/hosts.txt | grep "127.0.0.1" | sort -n | uniq > /system/etc/hosts || (echo "failed something something. exiting" ; exit)
	echo "127.0.0.1 localhost" >> /system/etc/hosts 
 	echo 0 > $MODDIR/state
}


enable=$(cat $MODDIR/state)

if [[ $enable -eq 1 ]]; then
	run
else
	reset
fi

# just a simple toggle vreh

sleep 1
echo "action.sh loaded $(wc -l /system/etc/hosts | cut -f1 -d " "  ) hosts!"

sed -i '/description/d' $MODDIR/module.prop
echo "description=status: active ✅ | action.sh $(wc -l /system/etc/hosts | cut -f1 -d " "  ) loaded hosts" >> $MODDIR/module.prop
sleep 3

# EOF
