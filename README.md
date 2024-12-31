# bindhosts

Systemless hosts for Apatch, KernelSU and Magisk

Fully standalone, self-updating.

## Features
- WebUI and action button control
- Adaway coexistence 
- Systemless hosts via manager mount, bind mount, and OverlayFS
- Redirect methods: ZN-hostsredirect, hosts_file_redirect, open_redirect

## Supported Root Managers
- [APatch](https://github.com/bmax121/APatch) 
- [KernelSU](https://github.com/tiann/KernelSU)
- [Magisk](https://github.com/topjohnwu/Magisk)  <sup>([no WebUI](https://github.com/topjohnwu/Magisk/issues/8609#event-15568590949)👀)</sup>

### Also Supported on
- [KsuWebUI](https://github.com/5ec1cff/KsuWebUIStandalone)
- [MMRL](https://github.com/DerGoogler/MMRL)   <sup>👍</sup>

## Hiding
- Read [Hiding Guide](https://github.com/backslashxx/bindhosts/blob/master/Documentation/hiding.md)

## Operating Modes
- Read [bindhosts operation modes](https://github.com/backslashxx/bindhosts/blob/master/Documentation/modes.md).

## Links
 - Download [here](https://github.com/backslashxx/bindhosts/releases)
 - Looking for more sources? [here](https://github.com/backslashxx/bindhosts/blob/master/Documentation/sources.md)

## Help and Support
Report [here](https://github.com/backslashxx/bindhosts/issues) if you encounter any issues.

[Pull requests](https://github.com/backslashxx/bindhosts/pulls) are always welcome.

## Usage via Terminal
![bindhosts](https://github.com/user-attachments/assets/bc3e3f2c-9039-417d-8652-77f48755c7bf)

In order to access the various options as shown in the image for bindhosts magisk/KSU/Apatch, you must first have su access via command line either through termux (or other various common terminal apps)
or adb shell and type: bindhosts followed by the option you want.

EXAMPLE: 
         
         bindhosts --action ---> This will simulate bindhosts action to grab ips or reset the hosts file, depending on which state bindhosts is in
         bindhosts --tcpdump ---> Will sniff current active ip addresses on your network mode (wifi or data, make sure no DNS services are being used like cloudflare, etc.)
         bindhosts --force-reset ---> Will force reset bindhosts, which means resets the host file to zero ips
         bindhosts --custom-cron ---> Defines time of day to run a cronjob for bindhosts
         bindhosts --enable-cron ---> Enables cronjob task for bindhosts to update the ips of the lists you are currently using at 10am (default time)
         bindhosts --disable-cron ---> Disables & deletes previously set cronjob task for bindhosts
         bindhosts --help ---> This will show everything as shown above in image and text
         
