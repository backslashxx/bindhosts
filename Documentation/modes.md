# bindhosts operating modes
- These are currently defined operating modes that are either probed at auto or available as opt-in
- You can change operating mode by accessing to [developer option](https://github.com/backslashxx/bindhosts/issues/10#issue-2703531116).

---

## mode=0
### default mode
 - **APatch** - OverlayFS / magic mount?
   - magic mount is Adaway compatible ?
   - Hiding: none at all  
 - **Magisk** - magic mount  
   - Adaway compatible  
   - Hiding: [Shamiko](https://github.com/LSPosed/LSPosed.github.io/releases) / Denylist  
 - **KernelSU** OverlayFS + path_umount
   - No Adaway compatibility  
   - Hiding: umount modules (for non-GKI, please backport path_umount)

---

## mode=1
### ksu_susfs_bind mode
- KernelSU only  
- Requires susfs-patched kernel and userspace tool  
- Adaway compatible  
- Hiding: **best in its class as SuSFS handles the unmount**

---

## mode=2
### plain bindhosts
- mount --bind
- Highest compatibility
- Actually works on all managers, but not really preferable
- leaks a bind mount, leaks a globally modified hosts file  
- only useful as a last resort
- Adaway compatible
- Hiding: none at all

---

## mode=3
### apatch_hfr, hosts_file_redirect
- in-kernel redirection of /system/etc/hosts for uid 0
- APatch only, requires hosts_file_redirect KPM  
  - [hosts_file_redirect](https://github.com/AndroidPatch/kpm/blob/main/src/hosts_file_redirect/)  
  - [How-to-Guide](https://github.com/backslashxx/bindhosts/issues/3)
- Doesn't seem to work on all setups, hit-and-miss  
- No Adaway compatibility  
- Hiding: **best method for APatch, no mounts at all**

---

## mode=4
### zn_hostsredirect
- zygisk netd injection
- should work on all managers  
- Requires:  
  - [ZN-hostsredirect](https://github.com/aviraxp/ZN-hostsredirect)  
  - [ZygiskNext](https://github.com/Dr-TSNG/ZygiskNext)  
- No Adaway compatibility  
- Hiding: good method as there’s no mount at all, but it depends on other modules

---

## mode=5
### ksu_susfs_open_redirect
- in-kernel file redirects for uid <2000
- KernelSU only 
- **OPT-IN** only 
- Requires susfs-patched kernel and userspace tool  
- No way to do heuristics (citation needed), and the author discourages its usage  
- Requires SuSFS 1.5.1 or later  
- Adaway compatible
- Hiding: good method but use is discouraged by SuSFS-dev

---

## mode=6: 
### ksu_source_mod
- KernelSU only  
- **OPT-IN** only 
- Requires source modification: [reference](https://github.com/tiann/KernelSU/commit/2b2b0733d7c57324b742c017c302fc2c411fe0eb)  
- **WARNING**: Conflicts with SuSFS. You don’t need this if you can implement SuSFS.  
- Adaway compatible
- Hiding: okay-ish, hidden, but at this point, you're already modding ksu source eh, why not go susfs?

---
