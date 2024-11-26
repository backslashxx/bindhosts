bindhosts

writable /system/etc/hosts via mount --bind

(🕊️ AdAway compatible ✅)
  
  1.4.2 - 1.5.5
   - custom rules, modifiable sources, blacklist and whitelist support
   - optimizations and check for other downloaders
   - detect user changes, fix localhost bug
   - leverage skip mount, migrate to compat
   - account custom rules, misc housekeeping stuff
   - Adaway coexistence handling
   - fixups: whitelist processing, rare update failures
  
  1.5.6
   - /data/adb/bindhosts migration
    
Hiding: 

  - APatch - questionable hiding, use [standalone](https://github.com/backslashxx/bindhosts/tree/standalone) instead

  - KernelSU - [SuSFS](https://gitlab.com/simonpunk/susfs4ksu), or [source-modification](https://github.com/tiann/KernelSU/commit/2b2b0733d7c57324b742c017c302fc2c411fe0eb), or use [standalone](https://github.com/backslashxx/bindhosts/tree/standalone)

  - Magisk - Denylist, Shamiko


  
[Download](https://raw.githubusercontent.com/backslashxx/bindhosts/compat/module.zip)

[report for any issues](https://github.com/backslashxx/bindhosts/issues)

