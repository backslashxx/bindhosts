#!/usr/bin/env sh
MODDIR="/data/adb/modules/bindhosts"
# grab own info (version)
versionCode=$(grep versionCode $MODDIR/module.prop | sed 's/versionCode=//g' )

# test out writables, prefer tmpfs
folder=$MODDIR
[ -w /storage ] && folder=/storage
[ -w /tmp ] && folder=/tmp 
[ -w /debug_ramdisk ] && folder=/debug_ramdisk

echo "[+] bindhosts v$versionCode"
echo "[%] action.sh"
echo "[%] standalone hosts-based-adblocking implementation"

if [ -w /system/etc/hosts ] ; then
	# look for downloaders
     	# low pref, no ssl, b-b-b-b-but that libera/freenode(rip) meme
     	# https doesn't hide the fact that i'm using https so that's why i don't use encryption because everyone is trying to crack encryption so i just don't use encryption because no one is looking at unencrypted data because everyone wants encrypted data to crack
        busybox | grep wget > /dev/null 2>&1 && alias download='busybox wget --no-check-certificate -qO -'
        # higher pref, most of the times has ssl on android
        which curl > /dev/null 2>&1 && alias download='curl -s'
else
	echo "unwritable hosts file 😭 needs correction 💢" ; exit
fi

##### functions
illusion () {
	x=$((RANDOM%4 + 6)); while [ $x -gt 1 ] ; do echo '[.]' ; sleep 0.1 ; x=$((x-1)) ; done &
}

adblock() {
	illusion
	# always restore user's custom rules
	grep -v "#" $MODDIR/custom.txt > $folder/temphosts
	# sources	
	ls $MODDIR/sources.txt > /dev/null || (echo "[x] no sources.txt found!" ; sleep 3 ; exit)
	echo "[+] processing sources"
	for url in $(grep -v "#" $MODDIR/sources.txt | grep http) ; do 
		echo "[+] grabbing.."
		echo "[*] >$url"
		download "$url" >> $folder/temphosts || echo "[x] failed downloading $url"
		 # add a newline incase they dont
		echo "" >> $folder/temphosts
	done
	# blacklist.txt
	for i in $(grep -v "#" $MODDIR/blacklist.txt ); do echo "127.0.0.1 $i" >> $folder/temphosts; done
	# whitelist.txt
	echo "[+] processing whitelist"
	# optimization thanks to Earnestly from #bash on libera, TIL something 
	sed '/#/d; s/  / /g; s/0.0.0.0/127.0.0.1/' $folder/temphosts | sort -u | grep -Fxvf $MODDIR/whitelist.txt > /system/etc/hosts
	# mark it, will be read by service.sh to deduce
	echo "# bindhosts v$versionCode" >> /system/etc/hosts
}

reset() {
	echo "[+] reset toggled!" 
	# always restore user's custom rules
	grep -v "#" $MODDIR/custom.txt > /system/etc/hosts
        sed -i '/description/d' $MODDIR/module.prop
        echo "description=status: active ✅" >> $MODDIR/module.prop
        illusion
        sleep 1
        echo "[+] hosts file reset!"
        sleep 3
        # reset state
        rm $folder/bindhosts_state
}
run() {
	adblock
	illusion
	sleep 1
	echo "[+] action.sh blocked $(grep -c "127.0.0.1" /system/etc/hosts ) hosts!"
	sed -i '/description/d' $MODDIR/module.prop
	echo "description=status: active ✅ | action.sh blocked $(grep -c "127.0.0.1" /system/etc/hosts ) hosts" >> $MODDIR/module.prop
	sleep 3
	# ready for reset again
	touch $folder/bindhosts_state
}

# toggle
if [ -f $folder/bindhosts_state ]; then
	reset
else
	# basically if no bindhosts_state and hosts file is marked, it likely device rebooted and user is triggering an upgrade.
	grep "# bindhosts v" /system/etc/hosts > /dev/null 2>&1 && echo "[+] update triggered!"
	run
fi

# EOF
