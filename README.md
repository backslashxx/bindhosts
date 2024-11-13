bindhosts

fully standalone, self-updating, hosts-based-adblocking implementation

(🚨 Adaway incompatible ❌)
  
  ...
  
  
  1.4.2 - 1.5.3
   - custom rules, modifiable sources, blacklist and whitelist support
   - optimize and check for other downloaders
   - fully implemented, self-updating, standalone hosts-based-adblocking
   - fork off and kill adaway compatibility (uses ksu mount)
   - detect user changes, fix localhost bug
   - fixup! apatch's environment detection
   - account custom rules, misc housekeeping stuff
   - implement [ZN-hostsredirect](https://github.com/aviraxp/ZN-hostsredirect) helper mode
   - implement [hosts_file_redirect](https://github.com/AndroidPatch/kpm/tree/main/src/hosts_file_redirect) helper mode
   - fixup whitelist processing
      
  1.5.4
   - fixup rare update failures

Hiding: 

  - APatch - hosts_file_redirect ([how-to](https://github.com/backslashxx/bindhosts/issues/3#issue-2640292721)), or ZN-hostsredirect

  - KernelSU - Umount Modules or ZN-hostsredirect

  - Magisk - Denylist, Shamiko


[Download](https://raw.githubusercontent.com/backslashxx/bindhosts/standalone/module.zip)

[report for any issues](https://github.com/backslashxx/bindhosts/issues)
