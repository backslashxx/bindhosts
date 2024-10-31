bindhosts

writable /system/etc/hosts via mount --bind

(🟢 Adaway compatible ✅)
  
  1.0.0 - 1.3.9
   - initial
   - various stuff
   - copies old hosts file on update
   - fix magisk support
   - hardcode moddir
   - disable and copy old hosts file from other modules too
   - [susfs](https://gitlab.com/simonpunk/susfs4ksu) try_umount support added
   - [susfs](https://gitlab.com/simonpunk/susfs4ksu) modernized susfs support

  1.4.2 - 1.4.4
   - custom rules, modifiable sources, blacklist and whitelist support
   - optimizations and check for other downloaders
   - fully implemented, self-updating, standalone hosts-based-adblocking

  1.4.5
   - detect user changes, fix localhost bug


Will likely require Cherish Peekabo (APatch) / [SuSFS](https://gitlab.com/simonpunk/susfs4ksu) (KernelSU) to be **well hidden**

[Download](https://raw.githubusercontent.com/backslashxx/bindhosts/master/module.zip)

[report for any issues](https://github.com/backslashxx/bindhosts/issues)

