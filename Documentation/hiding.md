# Hiding Guide

## APatch
 Hiding in APatch is a bit problematic due to the following
  1. having overlayfs mount but it does NOT have built-in unmount mechanism
  2. bind-mount mode (magisk mount) is not mature yet

 Recommendations: 
   - use hosts_file_redirect kpm
      - [Usage Tutorial](https://github.com/backslashxx/bindhosts/issues/3)
      - [Download here](https://github.com/AndroidPatch/kpm/releases)
   - if hosts_file_redirect fails, install [ZN-hostsredirect](https://github.com/aviraxp/ZN-hostsredirect/releases)

## KernelSU
 Hiding in KernelSU should work as is as long as
  1. you have path_umount
  2. no conflicing modules (e.g. Magical Overlayfs)

 Recommendations:
  - if non-gki and kernel does not have path_umount, ask kernel dev to [backport](https://github.com/tiann/KernelSU/pull/1464) it
  - uninstall conflicting modules? 
  - alternatively, just install [ZN-hostsredirect](https://github.com/aviraxp/ZN-hostsredirect/releases)

## Magisk
 Hiding in Magisk (and clones) should just work as is.
 - add apps you need to hide root from onto denylist. 
 - optionally you can also use [Shamiko](https://github.com/LSPosed/LSPosed.github.io/releases/)

# FAQ
 - Why is this needed?
   - some root detections now includes and check for modified hosts file.
