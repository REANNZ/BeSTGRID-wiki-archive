# Updating a virtual machine at University of Canterbury

When updating a CentOS virtual machine, certain special measures have to be taken, especially for the upgrade from CentOS 4.4 to CentOS 4.5.

Relevant parts apply also to updating the Host OS.

# Preserve kernel packages

An update would install a new version of the `kernel-xenU` and `kernel-xenU-devel` packages, removing the old version.  However, the kernel a Xen VM boots is determined in the Host OS.  Thus, after an update, a virtual machine would boot the old kernel stored in the Host OS, but kernel modules for that version would be no longer available in the Virtual Machine.  To avoid this, add these packages to the list of packages where new versions should be installed alongside the old versions, keeping the old ones.  Edit `/etc/yum.conf`, and add `kernel-xenU` and `kernel-xenU-devel` to the `installonlypkgs` line (adding it if it does not exist yet):

>  installonlypkgs=kernel kernel-smp kernel-devel kernel-smp-devel kernel-largesmp kernel-largesmp-devel kernel-hugemem kernel-hugemem-devel kernel-xenU kernel-xenU-devel

# Save bandwidth - use KAREN

In an update, `yum` might possibly choose a repository that would be accessed via commodity Internet, incurring traffic charges.  To be sure the update is downloaded via the KAREN network, I have added two special yum repositories, pointing to a mirror of install base and updates of a current CentOS 4 version (4.6 as of January 2008) at the Monash University, reachable via KAREN.

Create `/etc/yum.repos.d/Monash-base.repo` (a KAREN-reachable centos-base mirror) containg:

``` 

[monashbase]
name=Updated distro at Monash - 4.6
#baseurl=http://132.181.50.89/install/CentOS/$releasever/os/$basearch/
baseurl=http://ftp.monash.edu.au/pub/linux/CentOS/4.6/os/i386/
enabled=0
gpgcheck=1

[monashupdates]
name=Distro updates at Monash - 4.6
baseurl=http://ftp.monash.edu.au/pub/linux/CentOS/4.6/updates/i386/
enabled=0
gpgcheck=1

```

Now, do the major update

>  yum --disablerepo="**" --enablerepo="monash**" update

Followed by 

>  yum update

if the Monash mirror was not completely up to date.

# Clean up after install

- Check kernel versions installed


>  rpm -qa kernel*
>  rpm -qa kernel*

- Keep the *most recent* kernel and the one booted from Host OS, and remove other possibly installed versions if needed


>  rpm -e kernel-xenU-2.6.9-55.EL kernel-xenU-devel-2.6.9-55.EL
>  rpm -e kernel-xenU-2.6.9-55.EL kernel-xenU-devel-2.6.9-55.EL

- Handle RPM conflicts (printed in the output of `yum updated` ran above):


>  /etc/mail/submit.cf created as /etc/mail/submit.cf.rpmnew
>  /usr/share/a2ps/afm/fonts.map created as /usr/share/a2ps/afm/fonts.map.rpmnew
>  /etc/yum.conf created as /etc/yum.conf.rpmnew
>  /etc/mail/submit.cf created as /etc/mail/submit.cf.rpmnew
>  /usr/share/a2ps/afm/fonts.map created as /usr/share/a2ps/afm/fonts.map.rpmnew
>  /etc/yum.conf created as /etc/yum.conf.rpmnew

- Re-disable TLS libraries.  Updated RPMs might have again created `/lib/tls`.  The thread-local-storage libraries *should not* be used in a VM.  If `/lib/tls` exists after the update, move it away - e.g.,


>  mv /lib/tls.disabled /lib/tls.disabled.old
>  mv /lib/tls /lib/tls.disabled
>  mv /lib/tls.disabled /lib/tls.disabled.old
>  mv /lib/tls /lib/tls.disabled

# Updating XenU kernel

I had initially configured all virtual machines to boot the kernel shipped with xen-3.0.4.1 as the domU kernel (`2.6.9-42.0.3.EL.xs0.4.0.263xenU`).  Starting with version 4.5, CentOS also includes a xenU kernel to be used as the domU kernel.  This section describes the steps necessary to start using an updated domU kernel in the xen virtual machines.

There are several issues to address: (1) the CentOS 4.x xenU kernel does not have the xenblk, xennet drivers compiled in (and these must be pre-loaded in the init ramdrive), (2) xenU kernel does not connect the console with tty1 (and the guest VM configuration must be tweaked to get a console login prompt) and (3) haldaemon occasionally dies due to a memory management error in some settings (and to get the system reported as OK, haldaemon should be disabled).

## Creating a custom initrd

Substitute the correct kernel version into the following command - creates an initrd file with the Xen block-device and network drivers preloaded, and omits drivers for scsi modules possibly loaded in the host (dom0) OS.

>  mkinitrd --preload xenblk --preload xennet --omit-scsi-modules /boot/initrd-2.6.9-67.0.1.ELxenU-xendrv.img 2.6.9-67.0.1.ELxenU

To make future updates easier, create symlinks which should be used from Xen guest domain configuration files:

``` 

cd /boot
ln -s initrd-2.6.9-67.0.1.ELxenU-xendrv.img initrd-2.6.9-ELxenU-xendrv.img
ln -s vmlinuz-2.6.9-67.0.1.ELxenU vmlinuz-2.6.9-ELxenU

```

## Console login with xenU kernels

For an unknown reason, xenU kernel does not connect `console` with `tty1`, and will not bring up a login prompt on the console.  While it is possible to add an additional entry for `console` to `/etc/inittab`, this leads to erratic behavior when the system is booted with a kernel without this bug - either the original Xen domU kernel, or possibly a future CentOS xenU kernel with this bug corrected.  Then, two login processes read and write to the same terminal - '"not a pleasant thing to experience"'.  Therefore, I have instead decided to configure Xen to emulate a serial console - this works the same with both kernels.

In the Xen domain configuration file (`/etc/xen/'yourdomain'` on the dom0 host system), change the kernel arguments variable (`extra`) to include

>  xencons=ttyS console=ttyS0

To enable login on the serial console in the guest domain, add the following line to `/etc/inittab`:

>  S0:2345:respawn:/sbin/agetty ttyS0 38400 vt100-nav

and to allow root login, also add a line containing the name of the console, `ttyS0`, to `/etc/securetty`.

## Haldaemon

After updating to CentOS 4.6 and booting the system with a xenU CentOS kernel, haldaemon (process `hald`) crashes on some of the system (`ng2maggie.otago.ac.nz`) - but not all.  This may be due to a memory management bug - an error message caught with `strace`, saying `"1873: assertion failed \"n_blocks..."`, might indicate that `hald` improperly manages memory allocated via dbus (such an assertion exists in dbus source code in `dbus-memory.c`).

When haldaemon is marked as a service to be started, `gridpulse` reports the machine as "Not OK" to GOC.

However, as haldaemon only provides a '"live device list through D-BUS"', it is save to disable the service:

>   chkconfig haldaemon off
>   service haldaemon stop

## Updating xenU kernel: A quick howto

To boot Xen virtual machines with an updated CentOS xenU kernel:


## Massive deploying

- Edit `/etc/securetty` on all hosts


>  for I in gridgwtest nggums grid myproxy ng2 ng2hpc ng2sge ngcompute ngportal ngportaldev vomrs ; do \
>    ssh $I "if ! grep ^ttyS0$ /etc/securetty > /dev/null ; then sed -e '\$a \ttyS0' --in-place /etc/securetty ; fi" ; done
>  for I in gridgwtest nggums grid myproxy ng2 ng2hpc ng2sge ngcompute ngportal ngportaldev vomrs ; do \
>    ssh $I "if ! grep ^ttyS0$ /etc/securetty > /dev/null ; then sed -e '\$a \ttyS0' --in-place /etc/securetty ; fi" ; done

- Edit `/etc/inittab` on all hosts


>  for I in gridgwtest nggums grid myproxy ng2 ng2hpc ng2sge ngcompute ngportal ngportaldev vomrs ; do \
>     ssh $I "if ! grep ^S0: /etc/inittab > /dev/null ; then sed -e '/^1:/i \S0:2345:respawn:/sbin/agetty ttyS0 38400 vt100-nav' --in-place /etc/inittab ; fi" ; done
>  for I in gridgwtest nggums grid myproxy ng2 ng2hpc ng2sge ngcompute ngportal ngportaldev vomrs ; do \
>     ssh $I "if ! grep ^S0: /etc/inittab > /dev/null ; then sed -e '/^1:/i \S0:2345:respawn:/sbin/agetty ttyS0 38400 vt100-nav' --in-place /etc/inittab ; fi" ; done

- Edit domain configuration files and edit kernel, ramdisk and extra kernel parameters


>     vi GUMS Grid MyProxy NG2 NG2HPC NG2SGE NGCompute NGPortal NGPortalDev NGTest VOMRS
>     vi GUMS Grid MyProxy NG2 NG2HPC NG2SGE NGCompute NGPortal NGPortalDev NGTest VOMRS

- Upgrade each VM to contain up to date kernel
	
- Grid: had to re-apply modifications to /etc/rc.d/init.d/nfs (starting order) and reinstall python24 and python24-devel (removed during the update)
- Shutdown and re-create each domain.

>  **Make sure that newly installed services do not cause gridpulse to report the machine as Not OK.  Specifically, **`mdadm`**, **`haldaemon`**, and **`lvm2-monitor`** are services which do not run in a virtual machine, and should be disabled with a **`chkconfig*service`` off`:
>  for I in gridgwtest nggums grid myproxy ng2 ng2hpc ng2sge ngcompute ngportal ngportaldev vomrs ; do \
>     ssh $I 'for I in mdmonitor haldaemon lvm2-monitor ; do chkconfig --list $I ; service $I status ; done' ; done

- disable also `irqbalance` for 1-CPU hosts.
- Uh. Due to some changes in CentOS bootstrap not anticipated by my bootstrap script, the `dbus` package installation failed to add the user `uid 81` (because `/dev/null` did not exist at the installation time yet) and the service `messagebus` would not start.  This can be fixed with manually running the command from the install scriptlet:


>  /usr/sbin/useradd -c 'System message bus' -u 81 -s /sbin/nologin -r -d '/' dbus
>  /usr/sbin/useradd -c 'System message bus' -u 81 -s /sbin/nologin -r -d '/' dbus

# Switch to ARCS yum repository

To switch from the APACGrid yum repository to the new [ARCS Yum repository](http://projects.gridaus.org.au/trac/systems/wiki/YumRepository):

>   wget [http://projects.arcs.org.au/dist/arcs.repo](http://projects.arcs.org.au/dist/arcs.repo) -P /etc/yum.repos.d/
>   sed -i.ORI -e 's/enabled=1/enabled=0/g' /etc/yum.repos.d/APAC-Grid.repo 
>   yum remove Gpulse
>   yum install APAC-gateway-gridpulse

Or, if removing Gpulse would uninstall other packages, do:

>   yum shell
>   yum> remove Gpulse
>   yum> install APAC-gateway-gridpulse
