bindhosts

writable /system/etc/hosts via mount --bind
  
  1.0.0 - 1.3.4
   - initial
   - you dont even need to reboot now (customize.sh)
   - copies old hosts file on update
   - fix issue where hosts file doesn't exist on reboot after fresh install
   - fix magisk support
   - hardcode moddir
  
  1.3.5
   - spoof last modified time
   
  1.3.6
   - 644 -> 600 on hosts file permission (better hide)


[Download](https://raw.githubusercontent.com/backslashxx/bindhosts/master/module.zip)

[report for any issues](https://github.com/backslashxx/bindhosts/issues)
