#!/usr/bin/env sh
MODDIR="/data/adb/modules/bindhosts"


until [ "$(getprop sys.boot_completed)" == "1" ]; do
    sleep 1
done


# readout if action.sh did something
grep "# bindhosts v" /system/etc/hosts > /dev/null 2>&1 && string="description=status: active ✅ | action.sh blocked $(grep -c "0.0.0.0" /system/etc/hosts ) hosts" && sed -i "s/^description=.*/$string/g" $MODDIR/module.prop

# EOF
