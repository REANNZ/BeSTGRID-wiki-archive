# Bootstrapping a virtual machine at University of Canterbury

There are two existing solutions: generic `Build.sh` script (APAC repo `Gbuild` package), and the `rpmstrap` tool (recommended in the MyProxy and VOMRS instructions).  Both these solutions are based on installing RPMs from a repository; the list of RPMS is a small predefined list.  

I instead wanted to set up the virtual machine with a number of 'comfortable' packages I have on the host system - so I wrote my own script that bootstraps the machine in a similar way, but instead uses the list of packages that exist on the host system.  In addition, the script set's up a number of services in a way they should run on the target host.

# Bootstrapping a Xen virtual machine

The script `vmstrap` should be run with the path to the mounted filesystem, and a hostname for the target virtual machine:

>  /home/vme28/vmstrap/bootstrapvm /mnt/vmRoot/ gridgwtest

# Assumptions

- the target path is an existing directory
- yum is set up (`/mnt/CentOS-Media` exists, `YUM_CONF` exists)

# Setup done

1. Set up a default `/etc/fstab` with sda1 as root, sda2 as swap and /dev/pts, /dev/shm and /proc and /sys
2. Import Centos4 RPM GPG key
3. mknod --mode=0666 "${VMBASE}/dev/null" c 1 3
	
- Some RPM packages have scriptlets redirecting output to `/dev/null` - make sure it exists.
4. Install basesystem
5. Install coreutils
6. Install perl
7. move /lib/tls to /lib/tls.disabled in the target system
8. make device nodes `console zero null random sda sda1 sda2`
9. Install existing RPMs (minus banned)
10. rpm ivh --oldpackage kernel-xenU*
	
- With `-i --oldpackage`, the specific kernel will install in addition to a kernel package installed from the RPM repositories.
11. rpm -e kernel
12. umount "${VMBASE}/proc"
13. create `/etc/hosts` with localhost
14. create `ifcfg-eth0` with `DHCP_HOSTNAME = vmhostname`
15. create `/etc/sysconfig/network` with full hostname (`${VMHOSTNAME}.canterbury.ac.nz`)
16. create `/etc/sysctl.conf` with APAC recommended controls
17. `chkconfig ntpd on`, `chkconfig` unneeded services `off` (installed for dependencies)
18. set up local environment from the host system: `/etc/localtime /etc/sysconfig/clock /etc/sysconfig/i18n`
19. change `ntp.conf`: only talk to `ucgridgw.canterbury.ac.nz`
20. create empty resolv.conf
21. create `dhclient-eth0.conf` to search in `canterbury.ac.nz`
22. install pine (DAG)
23. put `APAC-Grid.repo`, `Ece-updates.repo` into `/etc/yum.repos.d/`
24. put `/etc/mail/mailertable{,.db`} into `"${VMBASE}/etc/mail/"` (set up default email gateway - ucgridgw for local mail, smtphost for outgoing)
25. add TCP send buffer settings to `/etc/sysctl.conf`
26. call `pwconv` and `grpconv` to turn on shadow passwords
27. setup forwading of root's mail to a central account.
28. set up root password
29. `killall minilogd cups-config-daemon`  -  to allow the FS to be unmounted.

# Local yum.conf

Basic considerations:

- must use repos with URLs without parameters (releasever,arch)
	
- - `distrover` package is not available in empty VM FS root

Creating yum.conf from /etc/yum.conf:

1. set reposdir=/dev/null
2. append all repositories /etc/yum.repos.d/* to yum.conf
3. expand releasever to 4 and arch to i386

Command-line:

>  yum -y -c $YUM_CONF --installroot=${VMBASE} --disablerepo=* --enablerepo=eceupdates --enablerepo=c4-iso-media install

# Remaining notes - rationale

Packages not provided in Repos:

- kernel-xenU{,-devel}
- pine
- rpmstrap
- gpg-pubkey-443e1821-421f218f

Optional enhancement:

1. local repo for xenU kernel, pine
2. see if xenU kernel satisfies kernel dependency
3. service stop instead of kill: minilogd(??started) cups-config-daemon(rc.d)
4. add the following line to /etc/sysconfig/network to stop the RedHat network subsystem from creating a route to `169.254.0.0/16` on network interfaces.

``` 
NOZEROCONF=yes
```

Notes:

1. beware - yum creates RPM dirs but not lock dir
2. fstab is not created
3. base system commands not found - install these first - used in scriptlets
	
- basesystems coreutils gawk perl
- basesystem installs fine (+3 packages)
- coreutils installs +70 packages (including kernel, needs /etc/fstab)
