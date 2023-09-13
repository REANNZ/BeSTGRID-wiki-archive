# Debian Tips

Here are some tips on setting up a Debian Host.

# Helpful Remote Administration Software

Some extra packages were installed to help as the remote `ssh` session kept on disconnecting.

``` 

# aptitude install vim-nox screen less openssl

```

- `vim-nox` - friendly vi
- `screen` - tty virtual sessions that cope with `ssh` disconnections.  See [http://jmcpherson.org/screen.html](http://jmcpherson.org/screen.html)
- `less` - a better pager than `more`
- `openssl` - shell utilities for manipulating and reading X509 Host certificates.
- `lsof` - displays information about files and FDs in an open state per process.

`Nano` was also removed as the default `/usr/bin/editor`, as it can be quite frustrating for Unix-philes.

``` 

# update-alternatives --set editor /usr/bin/vim.nox

```

# Fixing VM images installed from `debootstrap`

Various things need to be done to make sure the machine image does not start requesting debconf settings latter on, and to set up the system for use withing NZ.  Since we don't have multiple time zones here in NZ on BeSTGRID (unless we get server hosing in the Chatham Islands)  most administrators expect the system to be operating in either NZST or NZDT by default the system level.

## NZ Locale and Timezone

As this was missing, and creating LOTS of `perl` complaints about using the default locale, this was installed.  This is typical of a system image created by using `debootstrap`

``` 

# aptitude install locales
# dpkg-reconfigure locales

```

`en_AU.ISO-8859-1, en_AU.UTF-8, en_CA.ISO-8859-1, en_CA.UTF-8, en_GB.ISO-8859-1, en_GB.ISO-8859-15, en_GB.UTF-8, en_IE.ISO-8859-1, en_IE@euro, en_IE.ISO-UTF-8 en_NZ.ISO-8859-1 en_NZ.UTF-8, en_US.ISO-8859-1, en_US.ISO-8859-15, en_US.UTF-8` locales were selected and generated, with the default system local being set to `en_NZ.UTF-8` as per standard Debian and Ubuntu defaults.  We tend to get a forest of locales used here depending on how people set up their PCs.  All these are ones people here in NZ tend to use as they are either system install defaults, related to where they come from, or close to the NZ English idiom.

The final command above somehow manages to disconnect the `ssh` session.  If and if this happens directly after doing the above do:

``` 

# locale-gen -a
# update-locale

```

To check this, run `perl` and check that you get no output, and that `perl` can be closed with `Ctrl-D`. 

To set the time zone correctly, do the following:

``` 

# dpkg-reconfigure tzdata

```

Choose `Pacific`, then `Auckland` or `Chatham` as appropriate.

## Grub2 debconf

This is specific to Debian Squeeze and later and Ubuntu systems.

This needs to be done, or the machine may become unbootable if grub2 is upgraded.

Do an `fdisk -l` as root to list partitions, and then `dpkg-reconfigure grub-pc`

The `grub-pc` package is responsible for the debconf install settings, which are stored in `/var/cache/debconf/config.dat`, which is machine specific.

## `/etc/fstab`

`Debootstrap` leaves `/etc/fstab` blank:

``` 

# UNCONFIGURED FSTAB FOR BASE SYSTEM

```

A proper system install should leave it looking something like this:

``` 

# /etc/fstab: static file system information.
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
proc            /proc           proc    defaults        0       0
/dev/vda1       /               ext3    errors=remount-ro 0       1
/dev/vda5       none            swap    sw              0       0
/dev/hdc        /media/cdrom0   udf,iso9660 user,noauto     0       0

```

Copy and paste, and edit the above as needed for the system, again noting output from `fdisk -l`, as well as `cat /proc/mounts`.

# Stopping Install of Recommended Software

A lot of software recommends other packages that tend to only be needed on desktop installations.  These packages can consume hundreds of megabytes if not a gigabyte or so of disk.

Edit `/etc/apt/apt.conf` and add the following:

``` 

// No point in installing a lot of fat
APT::Install-Recommends "0";
APT::Install-Suggests "0";

```
