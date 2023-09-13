# Setup Otago GUMS server

The GUMS server improves the services at the Otago grid gateway, allowing users to choose among different VO mappings by using the respective VO attribute in their proxy certificate.  While this functionality on its own is still not that important, it aligns the gateway with the deployment guidelines used within the ARCS grid and BeSTGRID, making it a "good player".

The GUMS server is setup as an additional Xen virtual machine on the Otago grid gateway (gridgw.otago.ac.nz).  It was setup with a build script based on the [ARCS guidelines](http://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallNgGums), but modified to install VDT 1.10.1 instead of VDT 1.8.1.

The installation otherwise follows the [ARCS guidelines](http://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallNgGums) (with some variation as done for the Canterbury gateway).  So far, the Auth Tool has not been installed yet.

The server's hostname is `gums.canterbury.ac.nz`.

# OS installation

On host OS (`gridgw.otago.ac.nz`):

- Create swap ans FS partition and mount the partition

``` 

lvcreate -L 2G -n GUMSSwap VolGroup00
lvcreate -L 32G -n GUMSRoot VolGroup00
mkswap /dev/VolGroup00/GUMSSwap
mkfs -t ext3 /dev/VolGroup00/GUMSRoot
mkdir /mnt/GUMSRoot
mount /dev/VolGroup00/GUMSRoot /mnt/GUMSRoot/

```
- Download and mount and the installation media


>  wget [http://ftp.monash.edu.au/pub/linux/CentOS/4.7/isos/i386/CentOS-4.7-i386-binDVD.iso](http://ftp.monash.edu.au/pub/linux/CentOS/4.7/isos/i386/CentOS-4.7-i386-binDVD.iso)
>  mount -o loop,ro /root/CentOS-4.7-i386-binDVD.iso /mnt/CentOS-Media
>  wget [http://ftp.monash.edu.au/pub/linux/CentOS/4.7/isos/i386/CentOS-4.7-i386-binDVD.iso](http://ftp.monash.edu.au/pub/linux/CentOS/4.7/isos/i386/CentOS-4.7-i386-binDVD.iso)
>  mount -o loop,ro /root/CentOS-4.7-i386-binDVD.iso /mnt/CentOS-Media

- Run the bootstrap script to create the VM


>  cd vmstrap
>  ./bootstrapvm /mnt/GUMSRoot gums
>  cd vmstrap
>  ./bootstrapvm /mnt/GUMSRoot gums

- Configure static IP address: edit `/mnt/GUMSRoot/etc/sysconfig/network-scripts/ifcfg-eth0`

``` 

DEVICE=eth0
HWADDR=00:16:3E:8B:50:03
BOOTPROTO=none
BROADCAST=139.80.237.255
IPADDR=139.80.236.21
NETMASK=255.255.254.0
NETWORK=139.80.236.0
GATEWAY=139.80.236.1
ONBOOT=yes
TYPE=Ethernet
DHCP_HOSTNAME="gums"

```
- Create `/etc/resolv.conf`

``` 

search otago.ac.nz
nameserver 139.80.64.3
nameserver 139.80.64.1

```

- Put host address into `/etc/hosts`:

139.80.236.21   gums.otago.ac.nz gums

- Create `/etc/xen/GUMS` (from based on `Ng2Maggie`)

- Umount the FS root


>  umount /mnt/GUMSRoot
>  umount /mnt/GUMSRoot

# GUMS installation

- Download the build script and modify it for VDT 1.10.1

>  wget -P /usr/local/bin [http://www.vpac.org/~sam/build_nggums_vdt181.sh](http://www.vpac.org/~sam/build_nggums_vdt181.sh)
>  cp build_nggums_vdt181.sh build_nggums_vdt1101.sh
>  chmod +x build_nggums_vdt1*

- Make the following modifications to `build_nggums_vdt1101.sh`:
	
- switch to using PACMAN=3.26
- switch to doing everything in a single pacman command
- configure VDT to use IGTF CA bundle
- switch to invoking fetch-crl-2.6.6

(See attached patch file [Build_nggums_diff-vdt181-vdt1101.patch.txt](/wiki/download/attachments/3816950976/Build_nggums_diff-vdt181-vdt1101.patch.txt?version=1&modificationDate=1539354388000&cacheVersion=1&api=v2) and the original [build_nggums_vdt181.sh](http://www.vpac.org/~sam/build_nggums_vdt181.sh))

- Create `/etc/grid-security` and install host certificate there.


>  mkdir /etc/grid-security
>  mkdir /etc/grid-security

- Copy host certificates into `/etc/grid-security`

- Run the build script


>  /usr/local/bin/build_nggums_vdt1101.sh
>  /usr/local/bin/build_nggums_vdt1101.sh


# Configure GUMS service

Go to [https://gums.otago.ac.nz:8443/gums/](https://gums.otago.ac.nz:8443/gums/)

- Add myself as GUMS admin:


>  cd $VDT_LOCATION/tomcat/v55/webapps/gums/WEB-INF/scripts/
>  ./gums-add-mysql-admin "/C=NZ/O=BeSTGRID/OU=University of Canterbury/CN=Vladimir Mencl"
>  cd $VDT_LOCATION/tomcat/v55/webapps/gums/WEB-INF/scripts/
>  ./gums-add-mysql-admin "/C=NZ/O=BeSTGRID/OU=University of Canterbury/CN=Vladimir Mencl"

- Set MySQL root password


>  SET PASSWORD FOR 'root'@'localhost' = PASSWORD('secret-password');
>  SET PASSWORD FOR 'root'@'gums.otago.ac.nz' = PASSWORD('secret-password');
>  SET PASSWORD FOR 'root'@'localhost' = PASSWORD('secret-password');
>  SET PASSWORD FOR 'root'@'gums.otago.ac.nz' = PASSWORD('secret-password');


>  service tomcat-55 restart
>  service tomcat-55 restart

# Create GUMS Configuration

Same as when [setting up Canterbury GUMS server](/wiki/spaces/BeSTGRID/pages/3816950726):

- Create ARCS and APACGrid VOMRS servers

- Create BeSTGRID and NGAdmin user groups for both ARCS and APACGrid VOMRS servers.

- Create `grid-admin` and `grid-bestgrid` account mappers

- Create group-to-account mappings - BeSTGRID group's to `grid-bestgrid` and NGAdmin to `grid-admin`

>  **Add the two group-to-account to the default host to group mapping, **`"``/?*.otago.ac.nz"`

# Configure grid gateway to use the GUMS server

- Check if PRIMA is already installed


>  vdt-version
>  vdt-version

- If not, Install & Enable PRIMA


>  pacman -pretend-platform linux-rhel-4 -get [http://projects.arcs.org.au/mirror/vdt/vdt_181_cache:PRIMA-GT4](http://projects.arcs.org.au/mirror/vdt/vdt_181_cache:PRIMA-GT4)
>  pacman -pretend-platform linux-rhel-4 -get [http://projects.arcs.org.au/mirror/vdt/vdt_181_cache:PRIMA-GT4](http://projects.arcs.org.au/mirror/vdt/vdt_181_cache:PRIMA-GT4)

- Check that `/etc/sudoers` includes the PRIMA invocation syntax - see `/opt/vdt/post-install/README`
- Enable PRIMA


>  /opt/vdt/vdt/setup/configure_prima_gt4 --enable --gums-server gums.otago.ac.nz
>  /opt/vdt/vdt/setup/configure_prima_gt4 --enable --gums-server gums.otago.ac.nz

## Troubleshooting

If you do shoot yourself in the foot and try to install PRIMA while it's already installed ... and pacman fails, you may have to:

- revert patch done to `/opt/vdt/globus/lib/perl/Globus/GRAM/JobManager/fork.pm` - see [http://projects.arcs.org.au/mirror/vdt/software//globus/4.0.5_VDT-1.8.1-2/fork.patch](http://projects.arcs.org.au/mirror/vdt/software//globus/4.0.5_VDT-1.8.1-2/fork.patch)

- remove symlink created by PRIMA pacman installer with:

``` 
ln -s /usr/lib/libcom_err.so $VDT_LOCATION/globus/lib/libcom_err.so.3
```
- I.e., remove `$VDT_LOCATION/globus/lib/libcom_err.so.3`
- Reported as VDT ticket# 4937

- Resume pacman installation (a number of times)


>  pacman -resume PRIMA-GT4
>  pacman -resume PRIMA-GT4

- If pacman reinstalled Globus, check and re-apply all local modifications
	
- Disabling and enable MIP

More damage to fix:

- missing GRAM AUDIT in `container-log4j.properties`
- `/opt/vdt/globus/libexec/globus-job-manager-script-real.pl` overwritten
- re-apply [mysqld](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=mysqld&linkCreation=true&fromPageId=3816950976) in `/opt/vdt/mysql/var/my.cnf`


>    wait_timeout=2764800
>    wait_timeout=2764800

- re-apply post-install/globus-ws WSC_PORT=8443
- re-apply `/opt/vdt/globus/etc/globus_wsrf_core/server-config.wsdd`

- Accepted difference: RFT and GRAM won't use client certificates and will not register to MDS.

- It looked like MDS would not start - but that was related to the PBS server being down for maintenance.  See [my experience report on that](/wiki/spaces/BeSTGRID/pages/3816950583#Vladimir&#39;sgridnotes-MDSbroken).

# Minor enhancements

- [Configuring correct shutdown](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Setup_NGGums_at_University_of_Canterbury&linkCreation=true&fromPageId=3816950976)

- Configure VDT Apache to use a small CA certificate bundle to work around an Apache / mod_ssl bug - as documented in [ARCS GUMS install guide](https://projects.arcs.org.au/trac/systems/wiki/HowTo/InstallNgGums#MOD_SSLBug)
