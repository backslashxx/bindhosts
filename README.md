bindhosts

writable /system/etc/hosts via mount --bind
  
  1.0.0 - 1.3.9
   - initial
   - you dont even need to reboot now (customize.sh)
   - copies old hosts file on update
   - fix issue where hosts file doesn't exist on reboot after fresh install
   - fix magisk support
   - hardcode moddir
   - disable and copy old hosts file from other modules too
   - [susfs](https://gitlab.com/simonpunk/susfs4ksu) try_umount support added
   - [susfs](https://gitlab.com/simonpunk/susfs4ksu) modernized susfs support
   
  1.4.1
   -  simple action.sh demo

  1.4.2
   - extensive action.sh demo
   - sources, blacklist and whitelist support
   



[Download](https://raw.githubusercontent.com/backslashxx/bindhosts/master/module.zip)

[report for any issues](https://github.com/backslashxx/bindhosts/issues)

[Building your own kernel? grab this!](https://github.com/tiann/KernelSU/pull/1494)

[Pro at building your own kernel? grab this!](https://gitlab.com/simonpunk/susfs4ksu)
