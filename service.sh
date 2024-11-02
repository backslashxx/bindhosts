#!/usr/bin/env sh
MODDIR="/data/adb/modules/bindhosts"


until [ "$(getprop sys.boot_completed)" == "1" ]; do
    sleep 1
done

# placeholder

# EOF
