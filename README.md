bindhosts

writable /system/etc/hosts via mount --bind

(🕊️ AdAway compatible ✅)
  
  1.0.0 - 1.4.1
   - initial
   - various stuff
   - copies old hosts file on update
   - fix magisk support
   - hardcode moddir
   - disable and copy old hosts file from other modules too
   - [susfs](https://gitlab.com/simonpunk/susfs4ksu) support

  1.4.2 - 1.4.7
   - custom rules, modifiable sources, blacklist and whitelist support
   - optimizations and check for other downloaders
   - detect user changes, fix localhost bug
   - leverage skip mount, migrate to compat
   - fixup! apatch's environment detection

  1.4.8 - 1.4.9
   - account custom rules, misc housekeeping stuff
   - Adaway coexistence handling

Hiding: 

  - APatch - Cherish Peekabo [?], hosts_file_redirect [?]

  - KernelSU - [SuSFS](https://gitlab.com/simonpunk/susfs4ksu), [source-modification](https://github.com/tiann/KernelSU/commit/2b2b0733d7c57324b742c017c302fc2c411fe0eb)

  - Magisk - Denylist, Shamiko


  
[Download](https://raw.githubusercontent.com/backslashxx/bindhosts/compat/module.zip)

[report for any issues](https://github.com/backslashxx/bindhosts/issues)

