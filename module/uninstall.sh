rm -rf /data/adb/bindhosts
# cleanup for helper modes
# hfr
[ -f /data/adb/hosts ] && printf "127.0.0.1 localhost\n::1 localhost\n" > /data/adb/hosts
# znhr
[ -f /data/adb/hostsredirect/hosts ] && printf "127.0.0.1 localhost\n::1 localhost\n" > /data/adb/hostsredirect/hosts

# EOF
