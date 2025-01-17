# Hiding Guide

## APatch
 Hiding in APatch is a bit challenging due to the following reasons:
  1. it uses OverlayFS but lacks a built-in unmount mechanism
  2. bind mount is NOT widely adopted

 Recommendations: 
   - move to bind mount and use [ZygiskNext](https://github.com/Dr-TSNG/ZygiskNext)'s enforce denylist
   - use hosts_file_redirect kpm
      - [Usage Tutorial](https://github.com/bindhosts/bindhosts/issues/3)
      - [Download here](https://github.com/AndroidPatch/kpm/releases)
   - if hosts_file_redirect fails, install [ZN-hostsredirect](https://github.com/aviraxp/ZN-hostsredirect/releases)

## KernelSU
 Hiding in KernelSU should just work, provided that:
  1. you have path_umount (GKI, backported)
  2. no conflicing modules (e.g. Magical Overlayfs)

 Recommendations:
  - if kernel is non-gki and kernel lacks path_umount, ask kernel dev to [backport this feature](https://github.com/tiann/KernelSU/pull/1464)
  - if you want to keep using Magical OverlayFS, [use this fork](https://github.com/backslashxx/magic_overlayfs), this fork respects skip_mount
  - alternatively, just install [ZN-hostsredirect](https://github.com/aviraxp/ZN-hostsredirect/releases)

## Magisk
 Hiding in Magisk (and clones) should just work as is.
 - Add the apps you want to hide root from to the denylist.
 - optionally you can also use [Shamiko](https://github.com/LSPosed/LSPosed.github.io/releases/)

# FAQ
 - Why is this needed?
   - some root detections now includes and check for modified hosts file.
 - How do I check for detections?
   - Read [how to check for detections](https://github.com/bindhosts/bindhosts/issues/4)
 - How do I move to bind mount on APatch?
   - get ci builds [here](https://github.com/bmax121/APatch/actions)

## Glossary of terms
 - bind mount - APatch's term for magic mount, mounting method primarily used by Magisk.
