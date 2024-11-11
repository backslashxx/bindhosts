#!/usr/bin/env sh
MODDIR="/data/adb/modules/bindhosts"

# grab own info (version)
versionCode=$(grep versionCode $MODDIR/module.prop | sed 's/versionCode=//g' )

# test out writables, prefer tmpfs
folder=$MODDIR
[ -w /dev ] && folder=/dev
[ -w /tmp ] && folder=/tmp
[ -w /debug_ramdisk ] && folder=/debug_ramdisk


echo "[+] bindhosts v$versionCode"
echo "[%] action.sh"
echo "[%] standalone hosts-based-adblocking implementation"

# just in case user deletes them
files="custom.txt blacklist.txt sources.txt whitelist.txt"
for i in $files ; do
	if [ ! -f $MODDIR/$i ] ; then
		# dont do anything weird, probably intentional
		echo "[-] $i not found."
		echo "#" > $MODDIR/$i
	fi	
done

if [ -w /system/etc/hosts ] ; then
	# probe for downloaders
     	# low pref, no ssl, b-b-b-b-but that libera/freenode(rip) meme
     	# https doesn't hide the fact that i'm using https so that's why i don't use encryption because everyone is trying to crack encryption so i just don't use encryption because no one is looking at unencrypted data because everyone wants encrypted data to crack
        busybox | grep wget > /dev/null 2>&1 && alias download='busybox wget -T 10 --no-check-certificate -qO -'
        # higher pref, most of the times has ssl on android
        which curl > /dev/null 2>&1 && alias download='curl --connect-timeout 10 -s'
else
	# no fucking way
	echo "[x] unwritable hosts file 😭 needs correction 💢"
	sleep 5
	exit 1
fi

##### functions
illusion () {
	x=$((RANDOM%4 + 6)); while [ $x -gt 1 ] ; do echo '[.]' ; sleep 0.1 ; x=$((x-1)) ; done &
}

adblock() {
	# sources	
	echo "[+] processing sources"
	grep -v "#" $MODDIR/sources.txt | grep http > /dev/null || {
			echo "[x] no sources found 😭" 
			echo "[x] sources.txt needs correction 💢"
			sleep 10
			exit 1
			}
	illusion
	for url in $(grep -v "#" $MODDIR/sources.txt | grep http) ; do 
		echo "[+] grabbing.."
		echo "[>] $url"
		download "$url" >> $folder/temphosts || echo "[x] failed downloading $url"
		 # add a newline incase they dont
		echo "" >> $folder/temphosts
	done
	# localhost
	printf "127.0.0.1 localhost\n::1 localhost\n" > /system/etc/hosts
	# always restore user's custom rules
	grep -v "#" $MODDIR/custom.txt >> /system/etc/hosts
	# blacklist.txt
	for i in $(grep -v "#" $MODDIR/blacklist.txt ); do echo "0.0.0.0 $i" >> $folder/temphosts; done
	# whitelist.txt
	echo "[+] processing whitelist"
	# optimization thanks to Earnestly from #bash on libera, TIL something 
	# sed strip out everything with #, double space to single space, replace all 127.0.0.1 to 0.0.0.0
	# then sort uniq, then grep out whitelist.txt from it
	sed '/#/d; s/  / /g; /^$/d; s/127.0.0.1/0.0.0.0/' $folder/temphosts | sort -u | grep -Fxvf $MODDIR/whitelist.txt >> /system/etc/hosts
	# mark it, will be read by service.sh to deduce
	echo "# bindhosts v$versionCode" >> /system/etc/hosts
}

reset() {
	echo "[+] reset toggled!" 
	# localhost
	printf "127.0.0.1 localhost\n::1 localhost\n" > /system/etc/hosts
	# always restore user's custom rules
	grep -v "#" $MODDIR/custom.txt >> /system/etc/hosts
        string="description=status: active ✅"
        sed -i "s/^description=.*/$string/g" $MODDIR/module.prop
        illusion
        sleep 1
        echo "[+] hosts file reset!"
        # reset state
        rm $MODDIR/bindhosts_state
        sleep 3
}
run() {
	adblock
	illusion
	sleep 1
	echo "[+] blocked: $(grep -c "0.0.0.0" /system/etc/hosts ) | custom: $( grep -vEc "0.0.0.0| localhost|#" /system/etc/hosts )"
	string="description=status: active ✅ | blocked: $(grep -c "0.0.0.0" /system/etc/hosts ) 🚫 | custom: $( grep -vEc "0.0.0.0| localhost|#" /system/etc/hosts ) 🤖 "
	sed -i "s/^description=.*/$string/g" $MODDIR/module.prop
	# ready for reset again
	(cd $MODDIR ; (cat blacklist.txt custom.txt sources.txt whitelist.txt ; date +%F) | md5sum | cut -f1 -d " " > $MODDIR/bindhosts_state )
	# cleanup
	rm $folder/temphosts
	sleep 3
}

# adaway is installed and hosts are modified by adaway, dont overthrow
pm path org.adaway > /dev/null 2>&1 && grep "generated by AdAway" /system/etc/hosts > /dev/null 2>&1 && {
	# adaway coex
	string="description=status: active ✅ | 🛑 AdAway 🕊️"
	sed -i "s/^description=.*/$string/g" $MODDIR/module.prop
	echo "[*] 🚨 hosts modified by Adaway 🛑"
	echo "[*] assuming coexistence operation"
	echo "[*] please reset hosts in Adaway before continuing"
	sleep 10
	exit 1
}

# toggle
if [ -f $MODDIR/bindhosts_state ]; then
	# handle rule changes, add date change detect, I guess a change of 1 day to update is sane.
	newhash=$(cd $MODDIR ; (cat blacklist.txt custom.txt sources.txt whitelist.txt ; date +%F) | md5sum | cut -f1 -d " ")
	oldhash=$(cat $MODDIR/bindhosts_state)
	if [ $newhash == $oldhash ]; then
		# well if theres no rule change, user just wants to disable adblocking
		reset
	else
		echo "[+] rule change detected!"
		echo "[*] new: $newhash"
		echo "[*] old: $oldhash"
		run
	fi
else
	# basically if no bindhosts_state and hosts file is marked just update, its a reinstall
	grep "# bindhosts v" /system/etc/hosts > /dev/null 2>&1 && echo "[+] update triggered!"
	# normal flow
	run
fi

# EOF
