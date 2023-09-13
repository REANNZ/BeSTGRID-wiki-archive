# Setup Xen host system at University of Canterbury

All configuration steps are documented in `ucgridgw:/root/inst/instlog.log`

Xen boot configuration is documented at [Vladimir__Booting Xen on HP DL380 G5](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Vladimir__Booting%20Xen%20on%20HP%20DL380%20G5&linkCreation=true&fromPageId=3816951001).

Xendomains configuration changes is described below

# Xendomains

The configuration requirement was simple: use the `xendomains` script (in `/etc/rc.d/init.d`) to automatically start Xen domains when machine starts, and automatically shut down Xen domains when machine shuts down.

The xendomains script however has several issues:

1. Machines were reporting unclean shutdown after being shut down with xendomains.
2. Xendomains was starting and shutting down virtual machines in the same (lexicographical) order - thus, it was not possible to have a machine **A** running all the time when machine **B** is running (**A** starts first and shuts down last).
3. Xendomains script was printing some bogus error messages.

## Unclean shutdown

The problem was triggered by a bug in `xm shutdown`.  When a virtual machine is identified by its numeric id, the "--wait" parameter is ignored and `xm shutdown --wait` returns immediately, without waiting for the machine to shut down.   Xendomains then issues a `xm shutdown --all --halt --wait`, which sends a second shutdown command to virtual machines that have not completed shut down yet.   The linux kernel responds by immediately powering the machine down, without umounting the filesystem.

Workaround: fix xendomains calls to `xm shutdown` to use domain names instead of numeric ids — waiting then works as expected.  Patch is provided below.

This problem has been be reported to xensource bugzilla as [Bug#977](http://bugzilla.xensource.com/bugzilla/show_bug.cgi?id=977).

More details: in /usr/lib/python/xen/xm/shutdown.py#wait_shutdown:74, the check whether a domain is still alive is done with

>   if d in alive

As a numeric Id is never in (names of) alive domains, the wait_shutdown function returns immediately.  The fix would involve more python coding, and the workaround in xendomains script works fine.

## Start and shutdown order

There is not much chance to configure xendomains for fine-grained rules on start order or virtual machine interdependencies.  Some processing is done based on the lexicographical order of VM configuration files (or symlinks) in `/etc/xen/auto/`, some is done in lexicographical order of names of running virtual machines.

I have simplified the xendomains situation by an extra requirement that for each virtual machine, the configuration file name will match the virtual machine name.

Then, I assign the machine names so that the lexicographical order is acceptable as the starting order.  I then modified the `xendomains` script to shut the machines down in *reverse* lexicographical order.  This allows me to have a machine (`Grid`) providing services (NFS) to other virtual machines that starts first and shuts down last.

This modification is included in the patch below.

## Bogus error messages

1. Xendomains on CentOS chooses to report success and failure messages with LSB (`/lib/lsb/init-functions`).  LSB however defines its functions as aliases.  Aliases are not expanded in the control block where they are defined - thus, this script has to be sourced separately at the beginning of `xendomains`.  For more details, see the explanation in the patch below.
2. Xendomains sets up watchdogs to guard against `xm shutdown` taking 'too long'.  When the watchdogs are no longer needed, xendomains kills them - and the shell reports an error message for the abnormal termination of the watchdog subshell.  Installing a signal handler (a simple `exit` command) in the watchdog gets rid of the messages (also included in the patch below).

## Patch

This patch addresses all the above three issues:

`xendomains-fixes.patch`

``` 

 --- /etc/rc.d/init.d/xendomains.orig   2007-05-07 14:03:41.000000000 +1200
 +++ /etc/rc.d/init.d/xendomains        2007-05-08 10:24:22.000000000 +1200
 @@ -28,6 +28,25 @@
  #                    boots / shuts down.
  ### END INIT INFO
 
 +#### FIXME: Hack by Vladimir Mencl
 +## To make logging from xendomains script work - i.e., avoid
 +##    log_success_msg: command not found
 +## I had to set "shopt -s expand_aliases"
 +## because LSB defines log_*msg as aliases
 +## (not expanded in non-interactive mode by default)
 +## Unfortunately, it only works if the file with aliases
 +## is sourced at top level --- or since bash reaches top_level --- as a
 +## an "if" command block is first fully parsed, and then executed.
 +## Aliases defined within the if block (or other control statement) thus
 +## can't have any effect within any of their containing control statement.
 +##
 +## Hence, /lib/lsb/init-functions is sourced here
 +
 +if test -e /lib/lsb/init-functions; then
 +    shopt -s expand_aliases
 +    . /lib/lsb/init-functions
 +fi
 +
  # Correct exit code would probably be 5, but it's enough
  # if xend complains if we're not running as privileged domain
  if ! [ -e /proc/xen/privcmd ]; then
 @@ -280,6 +299,8 @@
      if test -z "$XENDOMAINS_STOP_MAXWAIT" -o "$XENDOMAINS_STOP_MAXWAIT" = "0"; then
         exit
      fi
 +    trap "exit" TERM
 +    # avoid printing termination messages when watchdog is killed
      usleep 20000
      for no in `seq 0 $XENDOMAINS_STOP_MAXWAIT`; do
         # exit if xm save/migrate/shutdown is finished
 @@ -370,14 +391,14 @@
             echo -n "(shut)"
             watchdog_xm shutdown &
             WDOG_PID=$!
 -          xm shutdown $id $XENDOMAINS_SHUTDOWN
 +          xm shutdown $name $XENDOMAINS_SHUTDOWN
             if test $? -ne 0; then
                 rc_failed $?
                 echo -n '!'
             fi
             kill $WDOG_PID >/dev/null 2>&1
         fi
 -    done < <(xm list | grep -v '^Name')
 +    done < <(xm list | sort -r | grep -v '^Name')
 
      # NB. this shuts down ALL Xen domains (politely), not just the ones in
      # AUTODIR/*

```

# Xen networking

One of our Xen VMs needs access to a different network, and I've needed to make host's eth1 available to this virtual machine.

The configuration has two major steps: 

1. Setup Xen to create additional bridge
2. Configure the Xen VM to have additional card on the bridge

Step 1 - Bridge:

- by default, xen creates only one bridge, `xenbr0`.
- This is determined by `/etc/xen/xend-config.sxp` saying 

``` 
(network-script network-bridge)
```
- The script `/etc/xen/scripts/network-bridge` takes argument vifnum=n, with default value of 0.
- Change this line to 

``` 
(network-script network-bridge-eth01)
```
- and create `/etc/xen/scripts/network-bridge-eth01` containing

``` 

#!/bin/bash

dir=$(dirname "$0")

/usr/bin/logger -t xend-network "network-bridge-eth01 $* vifnum=0, vifnum=1"
/etc/xen/scripts/network-bridge "$@" vifnum=0
/etc/xen/scripts/network-bridge "$@" vifnum=1

```
- now, either restart your machine or type 

``` 
/etc/xen/scripts/network-bridge start vifnum=1
```

Step 2 - VM configuration

- just specify multiple virtual interfaces in the Xen VM file:


>  vif = [16:3e:84:B5:10,bridge=xenbr0', 'mac=00:16:3E:C0:A8:10,bridge=xenbr1'](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey='mac=00&title=16%3A3e%3A84%3AB5%3A10%2Cbridge%3Dxenbr0%27%2C%20%27mac%3D00%3A16%3A3E%3AC0%3AA8%3A10%2Cbridge%3Dxenbr1%27)
>  vif = [16:3e:84:B5:10,bridge=xenbr0', 'mac=00:16:3E:C0:A8:10,bridge=xenbr1'](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey='mac=00&title=16%3A3e%3A84%3AB5%3A10%2Cbridge%3Dxenbr0%27%2C%20%27mac%3D00%3A16%3A3E%3AC0%3AA8%3A10%2Cbridge%3Dxenbr1%27)

- Note however, that by chance, the two interfaces may appear either as eth0 or eth1 - and this may be different on each startup.  However, if each of the interface configuration files (`/etc/sysconfig/network-scripts/ifcfg-eth{0,1`}) specifies a hardware address (`HWADDR`), the networking startup scripts will swap the interfaces if needed as they are brought up.
- You may use `neat` to create the interface configuration files.

# Xen device locked: FAQ excerpt

When I tried to start a virtual machine while its drive was mounted in the host system, I got a message saying that the block device is being used.  Occasionally, even after I unmounted the drive, I would keep getting the same message.  I have recently stumbled upon the following [documentation of this problem in the Xen FAQ](http://wiki.xensource.com/xenwiki/XenFaq#head-a463bc7cf05e154cea048f8a1ef655ce7a077db5):

- 4.11. *Booting a guest complains about trying to use an already-mounted block device, but it isn't mounted?!*

- 
- This is a bug to do with Xen incorrectly freeing guest resources. Take a look at the last line in `/var/log/xen-hotplug.log`, something like: 

``` 
xenstore-read: couldn't read path /local/domain/9/vm
```
- Take a note of that number, and run 

``` 
xenstore-rm backend/vbd/9
```

 replacing `9` with the number you read. The guest machine should then boot happily.
- Be careful when doing this that there are no guests effectively using the device in question, damage will probably be incurred in that case!

# Post-update configuration issues

After updating to CentOS 4.6, gridpulse was reporting the machine as `"Not OK"`.  This was caused by the service `lvm2-monitor` - the init script `/etc/rc.d/init.d/lvm2-monitor` does not have a proper implementation of the `status` command and always returns an exit code 1.

Given that the whole purpose of lvm2-monitor is to configure LVM to monitor failure events for LVM mirrored volume groups, which we do not use (mirroring is done at the hardware RAID controller level), it was safe to modify the unimplemented `status` command of `lvm2-monitor` to always return an exit code of 0.

# Considerations on x86_64

Initially, the whole system was installed as 32-bit (i386), with PAE extensions.  The system has been installed as homogeneous, with Xen hypervisor, dom0 host OS, and guest domains OS all being 32-bit.

I have now been investigating the options in running a hybrid system with some virtual machines running as 32-bit (i386) and some running as 64-bit (x86_64).  

The outcomes look pretty good.  The only condition is that the hypervisor must be 64-bit - it can then run a mixture of 32-bit and 64-bit virtual machines (even when dom0 is 32bit).  However, care must be taken when creating the init-ramdisk for a 64-bit kernel on a 32-bit host: the 64-bit kernel cannot handle 32-bit binaries at that early boot stage, and the init-ramdisk must contain only 64-bit binaries.

The steps I had to take to start a 64-bit virtual machine on a 32-bit system (with 64-bit CPU support!) were:

- Install `/boot/xen-3.1.0-x86_64.gz` 64-bit Xen hypervisor from a 64-bit Xen distribution (`xen-3.1.0-install-x86_64.tgz`).
- Reboot the system with the 64-bit xen hypervisor (a 32-bit dom0 kernel will load fine).
- Install a xenU kernel from a x86_64 distribution into `/boot` (I recommend changing the kernel name to distinguish the architecture: `vmlinuz-2.6.9-67.0.1.ELxenU-x86_64`)
- Install modules for the x86_64 xenU kernel into `/lib/modules` (I've again used the alternative kernel name, installing the modules into `/lib/modules/2.6.9-67.0.1.ELxenU-x86_64`).
- Create an init-ramdisk image for the x86_64 kernel, containing the xenblk and xendrv drivers..
	
- If creating the image on a x86_64 system, it is as easy as 

``` 
mkinitrd --preload xenblk --preload xennet --omit-scsi-modules /boot/initrd-2.6.9-67.0.1.ELxenU-x86_64-xendrv.img 2.6.9-67.0.1.ELxenU-x86_64
```
- If creating the image on a i386 system, create a local copy of `mkinitrd`, and also get x86_64 binaries for startup programs which have to be included in the ramdisk.
		
- put `insmod.static`, `nash`, and `udev.static` into `./bins` (these are found in the module-init-tools, mkinitrd, and udev RPM packages, respectively - get them from the x86_64 distribution).
- modify `./mkinitrd` to use these files from `./bins` and not from `/sbin`, and to avoid using `strip` (it would not be able to handle the 64bit binaries).  The patch to mkinitrd follows below.
- run the local copy of mkinitrd to create the 64-bit ramdisk image on the 32-bit host system:

``` 
./mkinitrd --preload xenblk --preload xennet --omit-scsi-modules /boot/initrd-2.6.9-67.0.1.ELxenU-x86_64-xendrv.img 2.6.9-67.0.1.ELxenU-x86_64
```
- The modifications to the local copy of mkinitrd are:

``` 

--- bins/mkinitrd       2007-11-17 17:45:18.000000000 +1300
+++ mkinitrd    2008-01-18 11:39:50.000000000 +1300
@@ -600,12 +600,12 @@
 mkdir -p $MNTIMAGE/sysroot
 ln -s bin $MNTIMAGE/sbin

-inst /sbin/nash "$MNTIMAGE/bin/nash"
-inst /sbin/insmod.static "$MNTIMAGE/bin/insmod"
+inst ./bins/nash "$MNTIMAGE/bin/nash"
+inst ./bins/insmod.static "$MNTIMAGE/bin/insmod"
 ln -s /sbin/nash $MNTIMAGE/sbin/modprobe

 if [ -n "$USE_UDEV" ]; then
-    inst /sbin/udev.static $MNTIMAGE/sbin/udev
+    inst ./bins/udev.static $MNTIMAGE/sbin/udev
     ln -s udev $MNTIMAGE/sbin/udevstart
     mkdir -p $MNTIMAGE/etc/udev
     inst /etc/udev/udev.conf $MNTIMAGE/etc/udev/udev.conf
@@ -613,11 +613,7 @@
 fi

 for MODULE in $MODULES; do
-    if [ -x /usr/bin/strip ]; then
-       /usr/bin/strip -g $verbose /lib/modules/$kernel/$MODULE -o $MNTIMAGE/lib/$(basename $MODULE)
-    else
        cp $verbose -a /lib/modules/$kernel/$MODULE $MNTIMAGE/lib
-    fi
 done

 # mknod'ing the devices instead of copying them works both with and

```

Finally, create a guest configuration file as usual - just use 

``` 
kernel = "/boot/vmlinuz-2.6.9-67.0.1.ELxenU-x86_64"
ramdisk = "/boot/initrd-2.6.9-67.0.1.ELxenU-x86_64-xendrv.img"

```

# Additional settings

## Disable auto-save

By default, `service xendomains stop` would save (suspend) the virtual machines instead of shutting them down.

Edit `/etc/sysconfig/xendomains` and change `XENDOMAINS_SAVE` to a blank value to disable this behavior:

>  XENDOMAINS_SAVE=""

## Set dom0 memory

Xen has had problems demonstrated by printing a lot of

``` 

xen_net: Memory squeeze in netback driver.
printk: 4 messages suppressed.
xen_net: Memory squeeze in netback driver.
printk: 4 messages suppressed.
xen_net: Memory squeeze in netback driver.
printk: 4 messages suppressed.

```

.

According to Google search results, these can be fixed by setting the dom0 memory both on the boot command line:

>         kernel /boot/xen.gz-2.6.18-164.6.1.el5 console=com1 com1=38400,8n1 **dom0_mem=512M**

and in `/etc/xen/xend-config.sxp` (disable memory balloon driver):

>  (dom0-min-mem 0)
