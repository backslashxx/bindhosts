# bindhosts operating modes
- These are currently defined operating modes that are either probed at auto or available as opt-in
- You can change operating mode by accessing to [developer option](https://github.com/bindhosts/bindhosts/issues/10#issue-2703531116).

#### Glossary of terms
 - magic mount - mounting method primarily used by magisk
 - susfs - shorthand for [susfs4ksu](https://gitlab.com/simonpunk/susfs4ksu), advanced root-hiding framework provided as a kernel patchset

---

## mode=0
### default mode
 - **APatch** 
   - OverlayFS / magic mount
   - magic mount is Adaway compatible, OverlayFS is NOT
   - Hiding: [ZygiskNext](https://github.com/Dr-TSNG/ZygiskNext)'s enforce denylist
 - **Magisk** 
   - magic mount  
   - Adaway compatible  
   - Hiding: Denylist / [Shamiko](https://github.com/LSPosed/LSPosed.github.io/releases) / [Zygisk Assistant](https://github.com/snake-4/Zygisk-Assistant)  
 - **KernelSU** 
   - OverlayFS + path_umount, (magic mount? soon?)
   - No Adaway compatibility  
   - Hiding: umount modules (for non-GKI, please backport path_umount)

---

## mode=1
### ksu_susfs_bind
- susfs assisted mount --bind
- KernelSU only  
- Requires susfs-patched kernel and userspace tool  
- Adaway compatible  
- Hiding: **best in its class as SuSFS handles the unmount**

---

## mode=2
### plain bindhosts
- mount --bind
- **Highest compatibility**
- Actually works on all managers, but not really preferable
- leaks a bind mount, leaks a globally modified hosts file  
- selected when APatch is on OverlayFS (default mode) as it offers better compatibility.
- Adaway compatible
- Hiding: essentially no hiding, needs assistance

---

## mode=3
### apatch_hfr, hosts_file_redirect
- in-kernel redirection of /system/etc/hosts for uid 0
- APatch only, requires hosts_file_redirect KPM  
  - [hosts_file_redirect](https://github.com/AndroidPatch/kpm/blob/main/src/hosts_file_redirect/)  
  - [How-to-Guide](https://github.com/bindhosts/bindhosts/issues/3)
- Doesn't seem to work on all setups, hit-and-miss  
- No Adaway compatibility  
- Hiding: **best method for APatch, no mounts at all**

---

## mode=4
### zn_hostsredirect
- zygisk netd injection
- usage is **encouraged** by the author (aviraxp) - ```"Injection is much better than mount in this usecase"```
- should work on all managers  
- Requires:  
  - [ZN-hostsredirect](https://github.com/aviraxp/ZN-hostsredirect)  
  - [ZygiskNext](https://github.com/Dr-TSNG/ZygiskNext)  
- No Adaway compatibility  
- Hiding: good method as there’s no mount at all, but it depends on other modules

---

## mode=5
### ksu_susfs_open_redirect
- in-kernel file redirects for uid below 2000
- KernelSU only 
- **OPT-IN** only 
- Requires susfs-patched kernel and userspace tool  
- usage is **discouraged** by author (simonpunk) - ```"openredirect will take more CPU cycle as well.."```
- Requires SuSFS 1.5.1 or later  
- Adaway compatible
- Hiding: good method but will likely waste more cpu cycles

---

## mode=6
### ksu_source_mod
- KernelSU try_umount assisted mount --bind
- Requires source modification: [reference](https://github.com/tiann/KernelSU/commit/2b2b0733d7c57324b742c017c302fc2c411fe0eb)  
- Supported on KernelSU NEXT 12183+ [reference](https://github.com/rifsxd/KernelSU-Next/commit/9f30b48e559fb5ddfd088c933af147714841d673)
- **WARNING**: Conflicts with SuSFS. You don’t need this if you can implement SuSFS.
- Adaway compatible
- Hiding: good method but you can probably just implement susfs.

---

## mode=7
### generic_overlay
- generic overlayfs rw mount
- should work on all managers  
- **OPT-IN** only due to **awfully high** susceptability to detections
- leaks an overlayfs mount (with /data/adb upperdir), leaks globally modified hosts file
- will NOT likely work on APatch bind_mount / MKSU if user has native f2fs /data casefolding
- Adaway compatible
- Hiding: essentially no hiding, needs assistance

---

## mode=8
### ksu_susfs_overlay
- susfs-assisted overlayfs rw mount
- KernelSU only  
- Requires susfs-patched kernel and userspace tool
- will NOT likely work on APatch bind_mount / MKSU if user has native f2fs /data casefolding
- Adaway compatible
- Hiding: good method but ksu_susfs_bind is easier

---
