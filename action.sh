#!/usr/bin/env sh
MODDIR="/data/adb/modules/bindhosts"

#susfs >=110 support
SUSFS_BIN=/data/adb/ksu/bin/ksu_susfs

echo "[+] bindhosts: action.sh DEMO"

if [ -w /system/etc/hosts ] ; then
	# look for downloaders
     	# low pref, no ssl
        busybox | grep wget > /dev/null 2>&1 && alias download='busybox wget --no-check-certificate -qO -'
        # higher pref, most of the times has ssl on android
        which curl > /dev/null 2>&1 && alias download='curl -s'
else
	echo "unwritable hosts file 😭 needs correction 💢" ; exit
fi

# test out writables, prefer tmpfs
folder=$MODDIR
[ -w /storage ] && folder=/storage
[ -w /tmp ] && folder=/tmp 
[ -w /debug_ramdisk ] && folder=/debug_ramdisk

##### functions
illusion () {
	x=$((RANDOM%4 + 6)); while [ $x -gt 1 ] ; do echo '[.]' ; sleep 0.1 ; x=$((x-1)) ; done &
}


adblock() {
	illusion
	#sources	
	ls $MODDIR/sources.txt > /dev/null || (echo "[x] no sources.txt found!" ; sleep 3 ; exit)
	echo "127.0.0.1 localhost" > $folder/temphosts
	echo "::1 localhost" >> $folder/temphosts
	echo "[+] processing blacklists"
	for url in $(grep -v "#" $MODDIR/sources.txt | grep http) ; do 
		echo "[+] grabbing.."
		echo "[*] >$url"
		download "$url" >> $folder/temphosts || echo "[x] failed downloading $url"
		 # add a newline incase they dont
		echo "" >> $folder/temphosts
	done
	# blacklist.txt
	for i in $(grep -v "#" blacklist.txt ); do echo "127.0.0.1 $i" >> $folder/temphosts; done
	# whitelist.txt
	echo "[+] processing whitelist"
	# optimization thanks to Earnestly from #bash on libera, TIL something 
	sed '/#/d; s/0.0.0.0/127.0.0.1/' $folder/temphosts | sort -u | grep -Fxvf $MODDIR/whitelist.txt > /system/etc/hosts
}

reset() {
	echo "[+] reset toggled!" 
	echo "127.0.0.1 localhost" > $folder/temphosts
	echo "::1 localhost" >> $folder/temphosts
        sed -i '/description/d' $MODDIR/module.prop
        echo "description=status: active ✅" >> $MODDIR/module.prop
        illusion
        sleep 1
        echo "[+] hosts file reset!"
        sleep 3
        # reset state
        rm $folder/bindhosts_state
        exit
}
run() {
	adblock
	illusion
	sleep 1
	echo "[+] action.sh loaded $(wc -l /system/etc/hosts | cut -f1 -d " "  ) hosts!"
	sed -i '/description/d' $MODDIR/module.prop
	echo "description=status: active ✅ | action.sh $(wc -l /system/etc/hosts | cut -f1 -d " "  ) loaded hosts" >> $MODDIR/module.prop
	sleep 3
	# ready for reset again
	touch $folder/bindhosts_state
}

# toggle
if [ -f $folder/bindhosts_state ]; then
        reset
else
        run
fi

# EOF
