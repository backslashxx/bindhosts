bindhosts

writable /system/etc/hosts via mount --bind
  
  1.0.0 - 1.3.4
   - initial
   - you dont even need to reboot now (customize.sh)
   - copies old hosts file on update
   - fix issue where hosts file doesn't exist on reboot after fresh install
   - fix magisk support
   - hardcode moddir
  
  1.3.5 - 1.3.7
   - spoof last modified time
   - 644 -> 600 on hosts file permission (better hide)
   - restore old behavior, cancel 1.3.5 and 1.3.6 changes
   
  1.3.8
   - disable and copy old hosts file from other modules too


[Download](https://raw.githubusercontent.com/backslashxx/bindhosts/master/module.zip)

[report for any issues](https://github.com/backslashxx/bindhosts/issues)

[Building your own kernel? grab this!](https://github.com/tiann/KernelSU/pull/1494)
