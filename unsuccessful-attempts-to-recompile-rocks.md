# Unsuccessful attempts to recompile Rocks

## Attempt to recompile Rocks on a naked CentOS 4

### 1. Set up a build environment:

> 1. cd /opt
> 2. cvs -d:pserver:anonymous@src.rocksclusters.org:/export/cvs checkout rocks-4.3

### 2. Go to the directory which holds the device driver code:

> 1. cd /opt/rocks-4.3/rocks/src/roll/kernel/src/rocks-boot/enterprise/4/images/drivers

### 3. Create a new directory and populate it with appropriate files

> 1. mkdir igb
> 2. cd igb
> 3. cp ../e1000/modinfo .
> 4. cp ../e1000/Makefile* .
> 5. cp ../e1000/modules.dep .
> 6. cp ../e1000/pcitable .

### 4. Download the latest drivers for 82575 controller from Intel  website:

[Intel Download Center](http://downloadcenter.intel.com/detail_desc.aspx?agr=Y&DwnldID=13663) 

**igb-1.2.22.tar.gz**

### 5. Unpack source code files of drivers and copy them into driver directory:


### 6. Edit files *modinfo*, *modules.dep*, *pcitable* and *Makefile*:

**modinfo**


**modules.dep**

>   Empty

**pcitable** Three lines has been added. Hexadecimal codes have been found in **e1000_hw.h**, lines 37-39

>  0x8086 0x10a7 "e1000" "Intel|82575EB Gigabit Ethernet Controller (Copper)
>  0x8086 0x10a9 "e1000" "Intel|82575EB Gigabit Ethernet Controller (Fiber)
>  0x8086 0x10d6 "e1000" "Intel|82575GB Gigabit Ethernet Controller (Quad Copper)

**Makefile**


### 7. Edit *subdirs* file

> 1. cd ..
> 2. vi subdirs

First section of the file should be like the following lines:

>  #
> 1. put a list of all the driver directories that you'd like to build.
>  #
> 2. for example, to build the 'e1000' driver, uncomment the line below:
>  #e1000
>  igb

### 8. Install packages which are required to compile Rocks Distribution

> 1. yum install syslinux pump pump-devel bogl-bterm bogl-devel elfutils-devel elfutils-libelf-devel beecrypt-devel \
>    gtk+ gtk+-devel gdk-pixbuf-devel gdk2-devel gtk2-devel

### 9. Full stop. Compilation of Rocks should be run on Rocks Frontend node.

>   ../../../../prep-initrd.py
>   Traceback (most recent call last):
>     File "../../../../prep-initrd.py", line 207, in ?
>       import rocks.kickstart
>   ImportError: No module named rocks.kickstart

There is a responce from Rocks mailing list:

>  Q: Can I build x86_64 Rocks under i386 one?
>  A: sorry but no, you can't. you can only build x86_64 rocks on a x86_64 rocks frontend.

## Attempt to install Rocks on a VMWare vitual machine

Started an attempt to build 64 bits VM under VMWare on my desktop.

It seems that 64 bits VM works under VMWare on a 32 bits desktop. Unfortunately Rocks didn't recognize virtual hard drive and rebooted itself. The attempt has been stopped. 

A decision to install Rocks5.0 Beta has been admitted.
