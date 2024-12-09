# Hiding Guide

## APatch
 Hiding in APatch is a bit challenging due to the following reasons:
  1. it uses OverlayFS but lacks a built-in unmount mechanism
  2. magic mount is NOT set as default

 Recommendations: 
   - use hosts_file_redirect kpm
      - [Usage Tutorial](https://github.com/backslashxx/bindhosts/issues/3)
      - [Download here](https://github.com/AndroidPatch/kpm/releases)
   - if hosts_file_redirect fails, install [ZN-hostsredirect](https://github.com/aviraxp/ZN-hostsredirect/releases)
   - OR, move to magic mount and install [Zygisk Assistant](https://github.com/snake-4/Zygisk-Assistant)

## KernelSU
 Hiding in KernelSU should just work, provided that:
  1. you have path_umount (GKI, backported)
  2. no conflicing modules (e.g. Magical Overlayfs)

 Recommendations:
  - if kernel is non-gki and kernel lacks path_umount, ask kernel dev to [backport this feature](https://github.com/tiann/KernelSU/pull/1464)
  - uninstall conflicting modules? 
  - alternatively, just install [ZN-hostsredirect](https://github.com/aviraxp/ZN-hostsredirect/releases)

## Magisk
 Hiding in Magisk (and clones) should just work as is.
 - Add the apps you want to hide root from to the denylist.
 - optionally you can also use [Shamiko](https://github.com/LSPosed/LSPosed.github.io/releases/) or [Zygisk Assistant](https://github.com/snake-4/Zygisk-Assistant)

# FAQ
 - Why is this needed?
   - some root detections now includes and check for modified hosts file.
 - How do I check for detections?
   - Read [how to check for detections](https://github.com/backslashxx/bindhosts/issues/4)
 - How do I move to magic mount on APatch?
   - open termux and then ```su -c touch /data/adb/.bind_mount_enable```

## Glossary of terms
 - magic mount - mounting method primarily used by magisk
