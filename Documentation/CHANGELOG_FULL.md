## bindhosts
Systemless hosts for Apatch, KernelSU and Magisk

---

# Changelog
### 1.7.3
- module: fixup module.prop
- module: optional cronjobs
- documentation: sources.md
- documentation: hiding.md
- webui: pressing reboot lets you reboot
- scripts/post-fs-data: re-enable mode2 conditionally
- scripts/service: fixup status printout condition
- tree: delete module.zip

### 1.7.2
- tree: introduce workflows 
- scripts/action: add dos2unix on parsing routine
- webui: display current mode
- webui: material floating button
- some documentation fixes

### 1.7.1
- developer mode implementation
- mode override on webui  
- mode5 fixup

### 1.7.0
- implement operating modes
- unify codebases (scriptbases? on such case)

### 1.6.3s / 1.6.3c
- small fixups 

### 1.6.0s / 1.6.0c
- WebUI on supported managers - c/o KOWX712

### 1.5.6s / 1.5.6c
- /data/adb/bindhosts migration

### 1.5.5s / 1.5.5c
- hosuekeeping stuff / script optimizations / fixups

### 1.5.4s / 1.5.4c
- fixup rare update failures 

### 1.5.3s / 1.5.3c
- fixup! whitelist processing 

### 1.5.2s
- implement [hosts_file_redirect](https://github.com/AndroidPatch/kpm/tree/main/src/hosts_file_redirect) helper mode

### 1.5.0s / 1.5.0c
- misc cleanups, adjust rules a bit

### 1.4.9s
- implement [ZN-hostsredirect](https://github.com/aviraxp/ZN-hostsredirect) helper mode (requires zygisk next)

### 1.4.9c
- Adaway coexistence handling

### 1.4.8s / 1.4.8c
- account custom rules, misc housekeeping stuff

### 1.4.7s / 1.4.7c
- fixup! apatch's environment detection

### 1.4.6
- leverage skip_mount, migrate to compat, migrate to standalone
- codebase split here

### 1.4.5
- detect user changes / state management, fix localhost bug

### 1.4.4
- fully implemented standalone hosts-based-adblocking implementation

### 1.4.2 ~ 1.4.3
- extensive action.sh demo
- sources, blacklist and whitelist support
- optimize and check for other downloaders

### 1.4.1
- simple action.sh demo

### 1.4.0
- [susfs](https://gitlab.com/simonpunk/susfs4ksu) modernize susfs support (tested at 1.3.8)

### 1.3.9
- [susfs >= 1.1.0](https://gitlab.com/simonpunk/susfs4ksu) try_umount support added

### 1.3.8
- disable and copy old hosts file from other modules too

### 1.3.7
- restore old behavior, cancel 1.3.5 and 1.3.6 changes

### 1.3.6
- 644 -> 600 on hosts file permission (better hide)

### 1.3.5
- spoof last modified time

### 1.3.4
- hardcode moddir

### 1.3.3
- fix magisk support

### 1.2.5
- fix issue where hosts file doesnt exist on reboot after fresh install

### 1.2.1
- you dont even need to reboot now (customize.sh)
- copies old hosts file on update

### 1.2.0
- squash everything?
- initial
