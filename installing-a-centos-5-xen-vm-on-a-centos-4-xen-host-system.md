# Installing a CentOS 5 Xen VM on a CentOS 4 Xen host system

While the Xen VM infrastructure for Grid gateways was initially deployed with CentOS 4, CentOS 5 has become available in the meantime.  Some parts of the grid infrastructure, notably SRB, will only install on a CentOS 5 system.  Hence, there is a need to run a CentOS 5 system as a VM within the existing CentOS 4 infrastructure.

# Preparing the bootstrap script

- I have modified the `bootstrapvm` script to accept an additional 3rd parameter, target distribution name - where the value of `CentOS-5` triggers special handling.  If not specified, the argument defaults to `CentOS-4`.  Usage:

``` 
./bootstrapvm /mnt/vmRoot/ gridgwtest CentOS-5
```
- The `bootstrapvm` script now picks a `yum.conf` script depending on the distribution - either `vmstrap/yum.conf` for CentOS-4 or `vmstrap/yum.conf-$DISTRO` for a different distribution specified on the command-line.
- Yum no longer uses local `eceupdates` repository - it was broken for CentOS-5, so we use `monashupdates` for both.
- Note: a CentOS-5 (5.2) DVD must be mounted on `/mnt/CentOS-Media`
- The script imports the correct distribution-specific RPM GPG keys.
- The script uses `/sbin/MAKEDEV` instead of `/dev/MAKEDEV` (does not get created on CentOS-5) and executes `MAKEDEV` inside a `chroot`-ed environment (so that MAKEDEV links against the right libraries).

# Necessary workarounds

- Hack 1: CentOS-5 `/bin/cp` and `/bin/touch` segfault when run in CentOS-4 environment.
	
- Solution: PAUSE (Ctrl-Z) yum right after installing coreutils, replace `/bin/{cp,touch`} with EL4 (keep as `/bin/{cp.EL5,touch.EL5`} )
- Note: does not seem to be necessary anymore with the latest updates.


- Hack 3:  Don't use ECE updates, use monash updates instead (something broken on ECE updates breaks RPM dependencies)

# Running the installation

- Start the installation with


>  ./bootstrapvm /mnt/vmRoot/ gridgwtest CentOS-5
>  ./bootstrapvm /mnt/vmRoot/ gridgwtest CentOS-5

# Installing CentOS-5 XenU kernel on host system

The host system must have the Linux kernel for the host in order to start the virtual machine.  But, the CentOS 5 kernel-xen package clashes with a number of packages installed on the CentOS-4 host system.

Hence, manually copy /boot/vmlinuz and /lib/modules/`uname -r`/ from the CentOS-5 guest to the CentOS-4 host.

Afterwards, create a ramdisk and create a version-independent symlink for both the ramdisk and the vmlinuz image: 

>  mkinitrd --preload xenblk --preload xennet --omit-scsi-modules /boot/initrd-2.6.18-92.el5xen-xendrv.img 2.6.18-92.el5xen initrd-2.6.18-92.el5xen-xendrv.img
>  ln -s initrd-2.6.18-92.el5xen-xendrv.img initrd-2.6.18-el5xen-xendrv.img
>  ln -s vmlinuz-2.6.18-92.el5xen vmlinuz-2.6.18-el5xen

When creating the xen domain configuration file for the virtual machine, use these CentOS-5 kernel and ramdisk symlinks:

>  kernel = "/boot/vmlinuz-2.6.18-el5xen"
>  ramdisk = "/boot/initrd-2.6.18-el5xen-xendrv.img"

That should complete the install - do a `xm create -c ``DomainName` and keep your fingers crossed.
