#!/bin/sh
# delete settings
rm -rf /data/adb/bindhosts
# delete symlink
manager_paths="/data/adb/ap/bin /data/adb/ksu/bin"
for i in $manager_paths; do rm -f $i/bindhosts ; done
# cleanup for helper modes
# hfr
[ -f /data/adb/hosts ] && printf "127.0.0.1 localhost\n::1 localhost\n" > /data/adb/hosts
# znhr
[ -f /data/adb/hostsredirect/hosts ] && printf "127.0.0.1 localhost\n::1 localhost\n" > /data/adb/hostsredirect/hosts

# EOF
