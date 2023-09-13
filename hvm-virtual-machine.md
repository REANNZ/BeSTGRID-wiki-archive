# HVM virtual machine

For compatibility reason, we may need a virtual machine running an unmodified Linux kernel (RHEL 4.4 compatible).  The specific reason is that we need to access the GPFS filesystem of our IBM [HPC](http://www.ucsc.canterbury.ac.nz/), and the GPFS kernel module won't compile under the Xen kernel.

In summary, installing a Xen HVM machine is fairly simple, and also a quick performance check shows that even an HVM virtual machine operates without a significant impact on performance.

In this test install, I have installed the machine with a filesystem-backed disk image.  I could observe that this is signficantly slower (even a `mkfs.ext3` took considerably more time).  The instructions show a a filesystem-backed HVM would be created - but this can be of course easily changed to an LVM one.

# Xen HVM config 

The configuration file was based on `/etc/xen/xmexample.hvm`, and is the following:

``` 

import os, re
arch = os.uname()[4]
if re.search('64', arch):
    arch_libdir = 'lib64'
else:
    arch_libdir = 'lib'
kernel = "/usr/lib/xen/boot/hvmloader"
builder='hvm'
memory = 512
shadow_memory = 8
name = "NGTest-hvm"
vcpus = 2
vif = [ 'type=ioemu, mac=00:16:3e:84:B5:99, bridge=xenbr0' ]
extra = "ro selinux=0 3" ## single
disk = [ 'file:/var/xen/hvmdisk.img,hda,w', 
'file:/var/xen/hvmswap.img,hdb,w', 
'file:/root/inst/CentOS-4.4-i386-binDVD.iso,hdc:cdrom,r' ]
device_model = '/usr/' + arch_libdir + '/xen/bin/qemu-dm'
boot="cda"
sdl=0
vnc=1
vnclisten="132.181.39.10"
vncconsole=0
vncpasswd='hvmgrid'
stdvga=0
serial='pty'

```

# Disk partitioning

A significant difference from installing an paravirtual VM (as recommended by APACGrid) is that an HVM can only access a complete drive, not a partition slice.  In addition, the hard-drive must come as an IDE drive (`hda`) and not as a SATA/SCSI drive (`sda`).

The fact that the logical volume (or a file) will be imported as a complete drive makes it more complicated to create the filesystem on a partition.  If a file is used, the file can be linked to a loop-back block device (`/dev/loop0`), and configured with fdisk:

>  losetup /dev/loop0 /var/xen/hvmdisk.img

Afterwards, to create the filesystem, one would setup the loop device with the offcet where the partition starts - skipping all the sectors on cylinder 0, head 0 - typically 63 sectors.  63*512= 32256, hence

>  losetup -o 32256 /dev/loop1 /var/xen/hvmdisk.img

However, this block device would appear to be slightly larger then the partition is.  There would be some sectors skipped at the end of the drive, as fdisk can only allocate complete cylinders.

Thus, one must give to mkfs.ext3 the exact number of sectors on the drive.  This is **(sectors * heads * cylinders) - sectors**. (Subtracting the 63 sectors missing from partition 1).  mkfs.ext3 accepts the number of **1K** blocks on the command line.  In my case, (63*255*1305-63)/2 = 10482381, hence

>  mkfs.ext3 /dev/loop1 10482381

# Installation

This is the complete log of the installation.  Please read the section above to see how to calculate the sector and block sizes. The installation is done by cloning an existing paravirtual machine.  Thus, it shows what must be changed in an HVM machine.

``` 

# create disk image files for filesystem and swap
# will appear to Xen HVM as /dev/hda and /dev/hdb
dd if=/dev/zero of=/var/xen/hvmdisk.img bs=1048576 count=10240
dd if=/dev/zero of=/var/xen/hvmswap.img bs=1048576 count=1024

# partition
losetup /dev/loop1 /var/xen/hvmdisk.img
losetup /dev/loop2 /var/xen/hvmswap.img
fdisk /dev/loop1
n p 1 [all space]
a 1
w
fdisk /dev/loop2
n p 1 [all space]
t 1 82
w
losetup -d /dev/loop1
losetup -d /dev/loop2

# create filesystem and swap
losetup -o 32256 /dev/loop1 /var/xen/hvmdisk.img
losetup -o 32256 /dev/loop2 /var/xen/hvmswap.img
mkfs.ext3 /dev/loop1 10482381
mkswap /dev/loop2
mount /dev/loop1 /mnt/otherRoot/
mount /dev/VolumeGroup00/TestRoot /mnt/vmRoot/
cd /mnt/vmRoot/
cp -R -p . /mnt/otherRoot/

yum -y -c /home/vme28/vmstrap/yum.conf --installroot=/mnt/otherRoot/ --disablerepo=* --enablerepo=eceupdates --enablerepo=c4-iso-media install kernel-smp kernel-smp-devel kernel kernel-devel

cp /boot/grub/grub.conf /mnt/otherRoot/boot/grub/grub.conf
vi /mnt/otherRoot/boot/grub/grub.conf
## change root=sda or LABEL to hda
## leave serial console
vi /mnt/otherRoot/etc/fstab
## change sda1 to hda1
## change swap from sda2 to hdb1
echo ttyS0 >> /mnt/otherRoot/etc/securetty
## allow root logins on the serial console (xm console)

cd /
umount /mnt/vmRoot
umount /mnt/otherRoot
losetup -d /dev/loop1
losetup -d /dev/loop2

```

# Grub setup

In order for the system to boot, grub must be installed in the partition table of `/dev/hda`.  The Xen documentation describes how to do that from the host OS via the loopback interface.  I have done that by booting from the CentOS DVD into rescue mode, and running grub in the guest system.

- edit the HVM configuration file and change `boot="cda"` to `boot="dca"`
- boot CentOS CD and enter at the prompt 

``` 
linux rescue
```
- after getting the shell, do the following:

``` 

# mount /dev/hda /mnt/sysimage
# should not be needed if Rescue disk takes are of it
chroot /mnt/sysimage
cp /usr/share/grub/i386-redhat/* /boot/grub
cd /boot/grub
ln -s menu.lst grub.conf
# cd /dev
# ./MAKEDEV hda hda1 hdb hdb1
# should not be needed if Rescue disk takes are of it
grub
grub> device (hd0) /dev/hda
grub> root (hd0,0)
grub> setup (hd0)
grub> quit

```

# Notes

- The system boots fine from a CentOS CD - boot=c
- Remote VNC listen does not work (vnc server is started with vnclisten=127.0.0.1, even though vnclisten is set in the virtual machine config).  Thus, vncviewer must exist on the host system.
- With correct calculation of the filesystem size, the swap partition may coexist on the same drive.
