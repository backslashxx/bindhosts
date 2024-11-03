#!/usr/bin/env sh
MODDIR="/data/adb/modules/bindhosts"

# grab own info (version)
versionCode=$(grep versionCode $MODDIR/module.prop | sed 's/versionCode=//g' )

# test out writables, prefer tmpfs
folder=$MODDIR
[ -w /debug_ramdisk ] && folder=/debug_ramdisk


echo "[+] bindhosts v$versionCode "
echo "[%] action.sh "
echo "[ ] standalone hosts-based-adblocking implementation "
echo "[.] "

# it still works on magisk, but not on apatch/ksu, warn user
if [ ${KSU} = true ] || [ ${APATCH} = true ] ; then
	pm path org.adaway > /dev/null 2>&1 && echo "[-] 🚨 This version may not work with AdAway 📛"
fi

# just in case user deletes them
files="custom.txt blacklist.txt sources.txt whitelist.txt"
for i in $files ; do
	if [ ! -f $MODDIR/$i ] ; then
		# dont do anything weird, probably intentional
		echo "[-] $i not found."
		echo "#" > $MODDIR/$i
	fi	
done

# impl def for changing variables
target_hostsfile="$MODDIR/system/etc/hosts"
helper_mode=""

# implement znhr helper mode, might as well do a pr on them later, that module can just use this script
# https://github.com/aviraxp/ZN-hostsredirect
# just use if found
if [ -d /data/adb/modules/hostsredirect ] ; then
	# assume its in a working state, just write hosts file in, it doesnt have one on def
	( mkdir -p /data/adb/hostsredirect ; touch /data/adb/hostsredirect/hosts ) > /dev/null 2>&1
	target_hostsfile="/data/adb/hostsredirect/hosts"
	echo "[+] aviraxp's ZN-hostsredirect found!"
	echo "[+] running in helper mode"
	helper_mode=" | ZN-hostsredirect 💉"
else
	[ -f $MODDIR/skip_mount ] && {
		rm $MODDIR/skip_mount
		echo "[-] reboot to restore operation"
		string="description=status: 🚨 reboot required 🛠️"
		sed -i "s/^description=.*/$string/g" $MODDIR/module.prop
		sleep 5
		exit 1
	}
fi	
	
if [ -w $target_hostsfile ] ; then
	# probe for downloaders
     	# low pref, no ssl, b-b-b-b-but that libera/freenode(rip) meme
     	# https doesn't hide the fact that i'm using https so that's why i don't use encryption because everyone is trying to crack encryption so i just don't use encryption because no one is looking at unencrypted data because everyone wants encrypted data to crack
        busybox | grep wget > /dev/null 2>&1 && alias download='busybox wget --no-check-certificate -qO -'
        # higher pref, most of the times has ssl on android
        which curl > /dev/null 2>&1 && alias download='curl -s'
else
	# no fucking way
	echo "[x] unwritable hosts file 😭 needs correction 💢" ; sleep 5 ; exit 1
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
		echo "[*] >$url"
		download "$url" >> $folder/temphosts || echo "[x] failed downloading $url"
		 # add a newline incase they dont
		echo "" >> $folder/temphosts
	done
	# localhost
	printf "127.0.0.1 localhost\n::1 localhost\n" > $target_hostsfile
	# always restore user's custom rules
	grep -v "#" $MODDIR/custom.txt >> $target_hostsfile
	# blacklist.txt
	for i in $(grep -v "#" $MODDIR/blacklist.txt ); do echo "0.0.0.0 $i" >> $folder/temphosts; done
	# whitelist.txt
	echo "[+] processing whitelist"
	# optimization thanks to Earnestly from #bash on libera, TIL something 
	# sed strip out everything with #, double space to single space, replace all 127.0.0.1 with 0.0.0.0
	# then sort uniq, then grep out whitelist.txt from it
	sed '/#/d; s/  / /g; /^$/d; s/127.0.0.1/0.0.0.0/' $folder/temphosts | sort -u | grep -Fxvf $MODDIR/whitelist.txt >> $target_hostsfile
	# mark it, will be read by service.sh to deduce
	echo "# bindhosts v$versionCode" >> $target_hostsfile
}

reset() {
	echo "[+] reset toggled!" 
	# localhost
	printf "127.0.0.1 localhost\n::1 localhost\n" > $target_hostsfile
	# always restore user's custom rules
	grep -v "#" $MODDIR/custom.txt >> $target_hostsfile
        string="description=status: disabled ❌ | $(date)"
        sed -i "s/^description=.*/$string/g" $MODDIR/module.prop
        illusion
        sleep 1
        echo "[+] hosts file reset!"
        # reset state
        rm $folder/bindhosts_state
        sleep 3
}
run() {
	adblock
	illusion
	sleep 1
	echo "[+] blocked: $(grep -c "0.0.0.0" $target_hostsfile ) | custom: $( grep -vEc "0.0.0.0| localhost|#" $target_hostsfile )"
	string="description=status: active ✅ | blocked: $(grep -c "0.0.0.0" $target_hostsfile ) 🛑 | custom: $( grep -vEc "0.0.0.0| localhost|#" $target_hostsfile ) 🤖 $helper_mode"
	sed -i "s/^description=.*/$string/g" $MODDIR/module.prop
	# ready for reset again
	(cd $MODDIR ; (cat blacklist.txt custom.txt sources.txt whitelist.txt ; date +%F) | md5sum | cut -f1 -d " " > $folder/bindhosts_state )
	# cleanup
	rm $folder/temphosts	
	sleep 3
}

# toggle
if [ -f $folder/bindhosts_state ]; then
	# handle rule changes, add date change detect, I guess a change of 1 day to update is sane.
	newhash=$(cd $MODDIR ; (cat blacklist.txt custom.txt sources.txt whitelist.txt ; date +%F) | md5sum | cut -f1 -d " ")
	oldhash=$(cat $folder/bindhosts_state)
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
	# basically if no bindhosts_state and hosts file is marked, it likely device rebooted, assume user is triggering an upgrade.
	grep "# bindhosts v" $target_hostsfile > /dev/null 2>&1 && echo "[+] update triggered!"
	run
fi

# EOF
