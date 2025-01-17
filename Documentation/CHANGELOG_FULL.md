## bindhosts
Systemless hosts for Apatch, KernelSU and Magisk

---

# Changelog
### 1.8.9
- webui/locales: spanish translation
- scripts/bindhosts: concurrent source downloads
- scripts/service: mode 1 fixups

### 1.8.8
- webui: QS-tile app install 
- scripts/customize: QS-tile app install
- webui/locales: russian + ukranian
- scripts/post-fs-data: AP-litemode/MKSU-nomount support

### 1.8.7
- webui/locales: Czech language
- webui/css: language menu auto sizing
- webui/css: fix word overflow in control panel
- webui/js: initialize dev option
- webui/locales: Add Indonesian translation
- webui/locales: update chinese translation

### 1.8.6
- scripts: restore mode 1 on legacy susfs
- webui: integrated documentation
- scripts: mode 6 support for KSU_NEXT
- webui: add german translation

### 1.8.5
- webui: add chinese translation
- webui: introduce multi-language support
- webui: various ui tweaks

### 1.8.4
- scripts: sync to recent susfs policies
- webui/css: center toggle vertically

### 1.8.3
- scripts/bindhosts: custom-cron input validation
- scripts/action: fixups for recent mmrl
- scripts: lots of small optimizations

### 1.8.2
- scripts/bindhosts: partial custom-cron validation
- scripts/bindhosts: simple tcpdump wrapper
- webui: minor ui adjust
- scripts/bindhosts: bindhosts --action

### 1.8.1
- webui: add cron toggle
- module: add bindhosts onto $PATH (Magisk)
- scripts/bindhosts: proper cron support

### 1.8.0
- scripts/bindhosts: add bindhosts onto $PATH (APatch / KernelSU)
- scripts/action: add exec time stat
- scripts/bindhosts: backend optimizations, lots of it
- webui: change toggle position
- webui: fix element overflow

### 1.7.9
- module: action webui redirect
- module: emoji updates
- scripts/action: wrapperrize
- scripts: toybox/busybox-related fixes
- scripts: lots and lots of small optimizations
- scripts: a few hardening changes
- scripts/customize: better conflict avoidance

### 1.7.8
- webui: add update toggle enable/disable
- scripts/post-fs-data: update apatch mode2 condition
- scripts/action: crc32 instead of md5sum
- scripts/action: single-instance lock
- scripts/service: restore mode1 kstat spoof
- documentation: current events, magic mount for apatch, ksu?
- webui/js: optimized grepping
- webui: enhance UI on MMRL
- relations: mmrl: upload screenshots for that metadata
- relations: mmrl metadata added
- documentation: magisk-nowebui-effff

### 1.7.7
- webui: MMRL support
- documentation/sources: add more lists
- documentation: APatch bind_mount + zygisk-assistant
- webui: enhance developer option behavior
- scripts/action: optimize hosts accounting
- webui: optimize prompt timing
- webui: prevent doubled up entries
- webui: fix tablet view

### 1.7.6
- fix empty whitelist bug

### 1.7.5
- documentation updates
- drop kstat spoofing on mode 1
- fixups for mode 2
- introduce mode 7 and 8 (generic overlay + ksu-assited overlay)

### 1.7.4
- Emergency release for APatch bind_mount_enable
- scripts/customize: drop old version migration
- scripts/action: add enable_cron functionality

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
