#!/bin/sh
PATH=/data/adb/ap/bin:/data/adb/ksu/bin:/data/adb/magisk:/data/data/com.termux/files/usr/bin:$PATH
MODDIR="/data/adb/modules/bindhosts"
PERSISTENT_DIR="/data/adb/bindhosts"
. $MODDIR/utils.sh
. $MODDIR/mode.sh

# bindhosts.sh
# bindhosts' processing backend

# grab own info (version)
versionCode=$(grep versionCode $MODDIR/module.prop | sed 's/versionCode=//g' )

echo "[+] bindhosts v$versionCode"
echo "[%] bindhosts.sh"
echo "[%] standalone hosts-based-adblocking implementation"

find_rwdir
echo "[ ] rwdir: $rwdir"

[ -f $MODDIR/disable ] && {
	echo "[*] not running since module has been disabled"
	string="description=status: disabled ❌ | $(date)"
        sed -i "s/^description=.*/$string/g" $MODDIR/module.prop
	return
}

# just in case user deletes them
# persistence
[ ! -d /data/adb/bindhosts ] && mkdir -p $PERSISTENT_DIR
files="custom.txt blacklist.txt sources.txt whitelist.txt"
for i in $files ; do
	# if file doesnt exist, write dummy
	[ ! -f $PERSISTENT_DIR/$i ] && echo "#" > $PERSISTENT_DIR/$i
done

adaway_warn() {
	pm path org.adaway > /dev/null 2>&1 && echo "[-] 🚨 Current operation mode may not work with AdAway 📛"
}

# impl def for changing variables
target_hostsfile="$MODDIR/system/etc/hosts"
helper_mode=""

# we can just remove the other unmodified modes
# and have them fall to * but im gonna leave it 
# here for clarity
case $operating_mode in
	0) if command -v ksud >/dev/null 2>&1 || command -v apd >/dev/null 2>&1 ; then adaway_warn ; fi ;;
	1) true ;;
	2) true ;;
	3) target_hostsfile="/data/adb/hosts" ; helper_mode="| hosts_file_redirect 💉" ; adaway_warn ;;
	4) target_hostsfile="/data/adb/hostsredirect/hosts" ; helper_mode="| ZN-hostsredirect 💉" ; adaway_warn ;;
	5) true ;;
	6) true ;;
	7) target_hostsfile="/system/etc/hosts" ;;
	8) target_hostsfile="/system/etc/hosts" ;;
	*) true ;; # catch invalid modes
esac

# check hosts file if writable, if not, warn and exit
if [ ! -w $target_hostsfile ] ; then
	# no fucking way
	echo "[x] unwritable hosts file 😭 needs correction 💢"
	string="description=status: unwritable hosts file 😭 needs correction 💢"
        sed -i "s/^description=.*/$string/g" $MODDIR/module.prop
	return
fi

##### functions
illusion () {
	x=$(($$%4 + 4)); while [ $x -gt 1 ] ; do echo '[.]' ; sleep 0.1 ; x=$((x-1)) ; done &
}

run_crond() {
	[ ! -d $PERSISTENT_DIR/crontabs ] && {
		mkdir $PERSISTENT_DIR/crontabs
		echo "[+] running crond"
		busybox crond -bc $PERSISTENT_DIR/crontabs -L /dev/null
	}
}

_is_valid_cron_arg() { # return value: 0 = true, 1 = false
(
	valid_cron_x="$1"
	valid_cron_arg="$2"
	valid_cron_len=${#valid_cron_arg}
	valid_cron_complex_check=false
	[ "$valid_cron_len" -lt 1 ] && return 1 # End check if arg is empty
	if [ "$valid_cron_len" -eq 1 ]; then
		# End check if 1-char arg is not * or digit
		[ "$(echo "$valid_cron_arg" | tr -d "\*[:digit:]" | wc -w)" -gt 0 ] && return 1
		# Additional check if arg is a number
		if (echo "$valid_cron_arg" | grep -q "[[:digit:]]"); then
			case "$valid_cron_x" in
				3) [ "$valid_cron_arg" -lt 1 ] && return 1 ;;
				4) [ "$valid_cron_arg" -lt 1 ] && return 1 ;;
				5) [ "$valid_cron_arg" -lt 0 ] || [ "$valid_cron_arg" -gt 7 ] && return 1 ;;
			esac
		fi
	elif [ "$valid_cron_len" -eq 2 ]; then
		# End check if 2-char arg is not a number
		[ "$(echo "$valid_cron_arg" | tr -d "[:digit:]" | wc -w)" -gt 0 ] && return 1
		case "$valid_cron_x" in
			1) [ "$valid_cron_arg" -lt 0 ] || [ "$valid_cron_arg" -gt 59 ] && return 1 ;;
			2) [ "$valid_cron_arg" -lt 0 ] || [ "$valid_cron_arg" -gt 23 ] && return 1 ;;
			3) [ "$valid_cron_arg" -lt 1 ] || [ "$valid_cron_arg" -gt 31 ] && return 1 ;;
			4) [ "$valid_cron_arg" -lt 1 ] || [ "$valid_cron_arg" -gt 12 ] && return 1 ;;
		esac
	elif [ "$valid_cron_len" -gt 2 ]; then
		# Because the arg might be "1-6", "0,15,25" or even "1-7,7-21/3"
		# We'll need extra check for these long arg (>= 3 char) if the arg is:
		# - of the MONTH field but is not in JAN-DEC list
		# - of the DAY_OF_WEEK field but is not in SUN-SAT list
		# - of the MIN, HOUR or DAY_OF_MONTH fields
		case "$valid_cron_x" in
			4) (! echo "$valid_cron_arg" | grep -Eiqw "^(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)$") && valid_cron_complex_check=true ;;
			5) (! echo "$valid_cron_arg" | grep -Eiqw "^(SUN|MON|TUE|WED|THU|FRI|SAT)$") && valid_cron_complex_check=true ;;
			*) valid_cron_complex_check=true ;;
		esac
	fi

	if [ "$valid_cron_complex_check" = true ]; then
		# End check if long arg (>= 3 char) is a number
		[ "$(echo "$valid_cron_arg" | tr -d "[:digit:]" | wc -w)" -eq 0 ] && return 1

		valid_cron_delimiter=""
		# To split complex arg in the order from , > / > -
		if (echo "$valid_cron_arg" | grep -q "\,"); then
			valid_cron_delimiter=","
		elif (echo "$valid_cron_arg" | grep -q "\/"); then
			valid_cron_delimiter="/"
		elif (echo "$valid_cron_arg" | grep -q "\-"); then
			valid_cron_delimiter="-"
		else
			return 1
		fi
		valid_cron_substring=""
		while [ "$valid_cron_arg" != "$valid_cron_substring" ] ;do
			# Extract the substring from start of arg up to delimiter
			# Example: substring="JAN" from "JAN,MAR,JUN,SEP,DEC"
			valid_cron_substring=${valid_cron_arg%%"$valid_cron_delimiter"*}
			# Delete this first "substring" AND its delimiter, from arg
			# Example: arg="MAR,JUN,SEP,DEC" from "JAN,MAR,JUN,SEP,DEC"
			valid_cron_arg="${valid_cron_arg#"$valid_cron_substring""$valid_cron_delimiter"}"
			# Validate substring recursively
			valid_cron_valid_arg=false
			_is_valid_cron_arg "$valid_cron_x" "$valid_cron_substring" && valid_cron_valid_arg=true
			if [ "$valid_cron_valid_arg" = true ]; then
				echo "[>] field #$valid_cron_x value [ $valid_cron_substring ] passed"
			else
				echo "[!] field #$valid_cron_x value [ $valid_cron_substring ] failed"
				return 1
			fi
		done
	fi
	return 0
)
}

custom_cron() {
	shift
	echo "[+] validating custom cron expression"
	custom_cron_error=false
	# Has only 1 arg and it starts with @
	if [ "$(echo "$1" | wc -w)" -eq 1 ] && (echo "$1" | grep -q "^@"); then
		# End check if arg is not these accepted @strings (case-sensitive)
		(! echo "$1" | grep -Eqw "^(@reboot|@hourly|@midnight|@daily|@weekly|@monthly|@annually|@yearly)$") && custom_cron_error=true
	# Has 5 args
	elif [ "$(echo "$1" | wc -w)" -eq 5 ]; then
		custom_cron_x=1
		while [ $custom_cron_x -lt 6 ] ; do
			custom_cron_arg=$(echo "$1" | cut -d ' ' -f "$custom_cron_x")
			echo "[>] checking field #$custom_cron_x: [ $custom_cron_arg ]"
			custom_cron_valid_arg=false
			_is_valid_cron_arg "$custom_cron_x" "$custom_cron_arg" && custom_cron_valid_arg=true
			if [ "$custom_cron_valid_arg" = true ]; then
				echo "[+] field #$custom_cron_x passed"
			else
				echo "[!] field #$custom_cron_x failed"
				break
			fi
			custom_cron_x=$((custom_cron_x+1))
		done
		[ "$custom_cron_x" -lt 6 ] && custom_cron_error=true
	else
		custom_cron_error=true
	fi
	# this atleast will catch globbed
	if [ -z "$1" ] || [ ! -z "$2" ] || [ "$custom_cron_error" = true ]; then
		# shoutout to native test and holmes
		echo "[!] futile cronjob" 
		echo "[!] syntax: --custom-cron \"0 2 * * *\" " 
		exit 0
	fi
	# run crond
	run_crond
	# add entry
	echo "$1 sh $MODDIR/bindhosts.sh --force-update > $rwdir/bindhosts_cron.log 2>&1 &" | busybox crontab -c $PERSISTENT_DIR/crontabs -
	echo "[>] $(head -n1 $PERSISTENT_DIR/crontabs/root) " 
	echo "[!] make sure entry is correct!"
	echo "[+] crontab entry added!"
}

enable_cron() {
	# run crond
	run_crond
	# add entry
	echo "0 4 * * * sh $MODDIR/bindhosts.sh --force-update > $rwdir/bindhosts_cron.log 2>&1 &" | busybox crontab -c $PERSISTENT_DIR/crontabs -
	echo "[>] $(head -n1 $PERSISTENT_DIR/crontabs/root) " 
	echo "[+] crontab entry added!"
}

disable_cron() {
	# kill busybox crond that we enabled
	for i in $(busybox pidof busybox); do 
		# super leet gamma knife
		grep -q "bindhosts" /proc/$i/cmdline > /dev/null 2>&1 && {
		echo "[x] killing pid $i"
		busybox kill -9 $i
		}
	done
	# clean entry
	if grep -q "bindhosts.sh" $PERSISTENT_DIR/crontabs/root > /dev/null 2>&1; then
		rm -rf $PERSISTENT_DIR/crontabs
		echo "[x] crontab entry removed!"
	else
		echo "[x] no crontab entry found!"
	fi
}

toggle_updatejson() {
	grep -q "^updateJson" $MODDIR/module.prop && { 
		sed -i 's/updateJson/xpdateJson/g' $MODDIR/module.prop 
		echo "[x] module updates disabled!" 
		} || { sed -i 's/xpdateJson/updateJson/g' $MODDIR/module.prop 
		echo "[+] module updates enabled!" 
		}
}

# probe for downloaders
# wget = low pref, no ssl.
# curl, has ssl on android, we use it if found
# here we chant the https meme.
# https doesn't hide the fact that i'm using https so that's why i don't use encryption 
# because everyone is trying to crack encryption so i just don't use encryption because 
# no one is looking at unencrypted data because everyone wants encrypted data to crack
download() {
	if command -v curl > /dev/null 2>&1; then
		curl --connect-timeout 10 -s "$1"
        else
		busybox wget -T 10 --no-check-certificate -qO - "$1"
        fi
}        

adblock() {
	illusion
	# source processing start!
	echo "[+] processing sources"
	sed '/#/d' $PERSISTENT_DIR/sources.txt | grep http > /dev/null || {
			echo "[x] no sources found 😭" 
			echo "[x] sources.txt needs correction 💢"
			return
			}
        # download routine start!
	for url in $(sed '/#/d' $PERSISTENT_DIR/sources.txt | grep http) ; do 
		echo "[+] grabbing.."
		echo "[>] $url"
		download "$url" >> $rwdir/temphosts || echo "[x] failed downloading $url"
	done
	# if temphosts is empty
	# its either user did something
	# or inaccessible urls / no internet
	[ ! -s $rwdir/temphosts ] && {
		echo "[!] downloaded hosts found to be empty"
		echo "[!] using old hosts file!"
		# strip first two lines since thats just localhost
		tail -n +3 $target_hostsfile > $rwdir/temphosts
		}
	# localhost
	printf "127.0.0.1 localhost\n::1 localhost\n" > $target_hostsfile
	# always restore user's custom rules
	sed '/#/d' $PERSISTENT_DIR/custom.txt >> $target_hostsfile
	# blacklist.txt
	for i in $(sed '/#/d' $PERSISTENT_DIR/blacklist.txt ); do echo "0.0.0.0 $i" >> $rwdir/temphosts; done
	# whitelist.txt
	echo "[+] processing whitelist"
	# make sure tempwhitelist isnt empty
	# or it will grep out nothingness from everything
	# which actually greps out everything.
	echo "256.256.256.256 bindhosts" > $rwdir/tempwhitelist
	for i in $(sed '/#/d' $PERSISTENT_DIR/whitelist.txt); do echo "0.0.0.0 $i" ; done >> $rwdir/tempwhitelist
	# sed strip out everything with #, double space to single space, replace all 127.0.0.1 to 0.0.0.0
	# then sort uniq, then grep out whitelist.txt from it
	sed -i '/#/d; s/  */ /g; /^$/d; s/\r$//; s/127.0.0.1/0.0.0.0/' $rwdir/temphosts
	sort -u "$rwdir/temphosts" | grep -Fxvf $rwdir/tempwhitelist >> $target_hostsfile
	# mark it, will be read by service.sh to deduce
	echo "# bindhosts v$versionCode" >> $target_hostsfile
}

reset() {
	echo "[+] reset toggled!" 
	# localhost
	printf "127.0.0.1 localhost\n::1 localhost\n" > $target_hostsfile
	# always restore user's custom rules
	sed '/#/d' $PERSISTENT_DIR/custom.txt >> $target_hostsfile
        string="description=status: reset 🤐 | $(date)"
        sed -i "s/^description=.*/$string/g" $MODDIR/module.prop
        echo "[+] hosts file reset!"
        # reset state
        rm $PERSISTENT_DIR/bindhosts_state > /dev/null 2>&1
}

run() {
	adblock
	# store these as variables
	# this way we dont do the grepping twice
	custom=$( grep -vEc "0.0.0.0| localhost|#" $target_hostsfile)
	blocked=$(grep -c "0.0.0.0" $target_hostsfile )
	# now use them
	echo "[+] blocked: $blocked | custom: $custom "
	string="description=status: active ✅ | blocked: $blocked 🚫 | custom: $custom 🤖 $helper_mode"
	sed -i "s/^description=.*/$string/g" $MODDIR/module.prop
	# ready for reset again
	(cat $PERSISTENT_DIR/*.txt; date +%F) | busybox crc32 > $PERSISTENT_DIR/bindhosts_state
	# cleanup
	rm -f $rwdir/temphosts $rwdir/tempwhitelist
}

# adaway is installed and hosts are modified by adaway, dont overthrow
pm path org.adaway > /dev/null 2>&1 && grep -q "generated by AdAway" /system/etc/hosts && {
	# adaway coex
	string="description=status: active ✅ | 🛑 AdAway 🕊️"
	sed -i "s/^description=.*/$string/g" $MODDIR/module.prop
	echo "[*] 🚨 hosts modified by Adaway 🛑"
	echo "[*] assuming coexistence operation"
	echo "[*] please reset hosts in Adaway before continuing"
	return
}

action () {
	# single instance lock
	# as the script sometimes takes some time processing
	# we implement a simple lockfile logic around here to
	# prevent multiple instances.
	# warn and dont run if lockfile exists
	[ -f $rwdir/bindhosts_lockfile ] && {
		echo "[*] already running!"
		# keep exit 0 here since this is a single instance lock
		exit 0
		}
	# if lockfile isnt there, we create one
	[ ! -f $rwdir/bindhosts_lockfile ] && touch $rwdir/bindhosts_lockfile

	# toggle start!
	if [ -f $PERSISTENT_DIR/bindhosts_state ]; then
		# handle rule changes, add date change detect, I guess a change of 1 day to update is sane.
		newhash=$( (cat $PERSISTENT_DIR/*.txt; date +%F) | busybox crc32 )
		oldhash=$(cat $PERSISTENT_DIR/bindhosts_state)
		if [ $newhash = $oldhash ]; then
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
		grep -q "# bindhosts v" $target_hostsfile && echo "[+] update triggered!"
		# normal flow
		run
	fi

	# cleanup lockfile
	[ -f $rwdir/bindhosts_lockfile ] && rm $rwdir/bindhosts_lockfile > /dev/null 2>&1
}

tcpdump () {
	if command -v tcpdump > /dev/null 2>&1; then
		# reset hosts
		reset
		echo "[+] restore hosts as needed"
		echo "[+] make sure private dns is disabled!"
		echo "[+] spawning tcpdump"
		echo "[!] press ctrl+c to exit"
		su -c "tcpdump -ltni any dst port 53"
	else
		echo "[!] tcpdump not found"
		echo "[x] bailing out"
		exit 0
	fi
}

show_help () {
	echo "usage:"
	printf " --action \t\tsimulate action.sh\n"
	printf " --tcpdump \t\tsniff dns requests via tcpdump (experimental)\n"
	printf " --force-update \tforce an update\n" 
	printf " --force-reset \t\tforce a reset\n" 
	printf " --custom-cron \t\tcustom schedule, syntax: \"0 2 * * *\" \n"
	printf "\t\t\tif you do NOT know this, use --enable-cron\n"
	printf " --enable-cron \t\tenables scheduled updates (4AM daily)\n"
	printf " --disable-cron \tdisables scheduled updates\n"
	printf " --help \t\tdisplays this message\n"
}

# add arguments
case "$1" in 
	--action) action; exit ;;
	--tcpdump) tcpdump; exit ;;
	--force-update) run; exit ;;
	--force-reset) reset; exit ;;
	--custom-cron) custom_cron "$@"; exit ;;
	--enable-cron) enable_cron; exit ;;
	--disable-cron) disable_cron; exit ;;
	--toggle-updatejson) toggle_updatejson; exit ;;
	--help|*) show_help; exit ;;
esac

# EOF
