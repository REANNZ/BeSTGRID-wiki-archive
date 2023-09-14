# Booting Xen on HP DL380 G5 at University of Canterbury

# Booting Xen on HP DL380 G5

## Problem description

I encountered a weird problem with the gateway node, which has the following configuration:

- Rack-mountable DL380 G5
- No KVM connected.
- HP iLO (Integrated Lights Out 2) is active - standard license: remote VGA access to system boot screen, virtual serial console boot+OS

The system boots fine if any of these conditions holds:

- The system is booting a CentOS kernel (not Xen).
- The serial console is active during the bootloader screen.

In other words, the problem occurs only when:

- The system boots Xen (regardless of console setup - serial/vga).
- Serial console is not active - either iLO is not connected at all, or there is no keyboard interaction at all.

The symptoms of the problem are:

- Any attempt to probe for a parallel port freezes for about 20-30 minutes.Thus, if a service initialized during system boot waits for such a result (such as kudzu or cups), the system boot delays for this period of time.
- The log is filled with spurious messages about USB devices being attached and disconnected.

>  Apr  3 20:04:38 ucgridgw kernel: usb 5-1: new full speed USB device using uhci_hcd and address 60
>  Apr  3 20:04:38 ucgridgw kernel: usb 5-1: configuration #1 chosen from 1 choice
>  Apr  3 20:04:38 ucgridgw kernel: usb 5-2: USB disconnect, address 59
>  Apr  3 20:04:38 ucgridgw kernel: usb 5-2: new full speed USB device using uhci_hcd and address 61
>  Apr  3 20:04:38 ucgridgw kernel: usb 5-2: configuration #1 chosen from 1 choice
>  Apr  3 20:04:38 ucgridgw kernel: hub 5-2:1.0: USB hub found
>  Apr  3 20:04:38 ucgridgw kernel: hub 5-2:1.0: 7 ports detected
>  Apr  3 20:04:38 ucgridgw kernel: usb 5-1: USB disconnect, address 60
>  Apr  3 20:04:39 ucgridgw kernel: usb 5-1: new full speed USB device using uhci_hcd and address 62

Should be (CentOS):

>  uhci_hcd 0000:01:04.4: UHCI Host Controller
>  uhci_hcd 0000:01:04.4: irq 233, io base 00003800
>  uhci_hcd 0000:01:04.4: new USB bus registered, assigned bus number 5
>  uhci_hcd 0000:01:04.4: port count misdetected? forcing to 2 ports
>  hub 5-0:1.0: USB hub found
>  hub 5-0:1.0: 2 ports detected
>  usb 5-1: new full speed USB device using address 2
>  input: USB HID v1.01 Keyboard [HP Virtual Keyboard](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=HP%20Virtual%20Keyboard&linkCreation=true&fromPageId=3818228513) on usb-0000:01:04.4-1
>  input: USB HID v1.01 Mouse [HP Virtual Keyboard](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=HP%20Virtual%20Keyboard&linkCreation=true&fromPageId=3818228513) on usb-0000:01:04.4-1
>  usb 5-2: new full speed USB device using address 3
>  hub 5-2:1.0: USB hub found
>  hub 5-2:1.0: 7 ports detected

## Solution

Is is not known what is the exact cause of the two symptoms, and whether they are related.  They both appear to be an incompatibility between the embedded hardware and the Xen drivers.   The problems can both be avoided by disabling the parallel port and USB controller modules in `modprobe.conf`:

>   alias usb-controller off
>   alias uhci-hcd off
>   alias uhci_hcd off
>   alias char_major_6_* off
>   alias parport_lowlevel off

**BEWARE**: Disabling USB may be a problem if we connect a KVM later - but then, it may be safe to re-enable USB

## Serial console BIOS setup

As one possible solution, I investigated disabling the USB controller in the BIOS setup.

VGA BIOS Setup gives a big warning that this will cut out iLO.  It really does (only keyboard, not VGA), but this setting can also be changed back and forth via the serial console command-line interface to BIOS:


>   set config usb control 2
>   set config usb control 2

- Revert with


>   set config usb control 1 # (or usb enabled)
>   set config usb control 1 # (or usb enabled)

Other commands:

>   help set config
>   show config usb control
>   show config options # lists options

# Xen serial console

The following GRUB configuration works for me to see Xen and Linux console messages on the serial console:

>  title Xen 3.0.4 with vmlinuz-2.6.16.33-xen_3.0.4.1 with serial console
>         kernel /boot/xen.gz console=com1 com1=38400,8n1
>         module /boot/vmlinuz-2.6.16.33-xen_3.0.4.1 ro root=LABEL=/ console=tty0 console=ttyS0
>         module /boot/initrd-2.6.16.33-xen_3.0.4.1.img

Bonus: switch between Linux and Xen console with 3x Ctrl-A

# Network devices

Onboard ethernet devices (eth0 and eth1, controlled by `bnx2`):

``` 

03:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5708 Gigabit Ethernet (rev 12)
05:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5708 Gigabit Ethernet (rev 12)

```

Expansion card NC340T PCI-X 4-port 1000T GigE (eth2,3,4,5, controlled by `e1000`)

``` 

13:04.0 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet Controller (Copper) (rev 03)
13:04.1 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet Controller (Copper) (rev 03)
13:06.0 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet Controller (Copper) (rev 03)
13:06.1 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet Controller (Copper) (rev 03)

```

The pciback magic for the 4 ports on the expansion card is 

``` 
modprobe pciback 'hide=(0000:13:04.0)(0000:13:04.1)(0000:13:06.0)(0000:13:06.1)'
```

Then, NGData can be created with the imported pci devices with

>  xm create -c NGData pci=13:04.0 pci=13:04.1

This works straight out of the box with the CentOS 5 XenU kernel.

# Monitoring disk RAID status

The DL380 is using an Smart Array P400 raid controller.  The controller driver (cciss) is included in the stock CentOS Linux kernel.  Downloading the "ProLiant Support Pack" allows one to query the disk status:

- Download [http://h20000.www2.hp.com/bizsupport/TechSupport/DriverDownload.jsp?lang=en&cc=us&prodNameId=3716247&taskId=135&prodTypeId=18964&prodSeriesId=3716246&lang=en&cc=us HP ProLiant Support Pack (Red Hat Enterprise Linux 5 Server / x86-64)
- Untar the downloaded bundle
- Install the HP Command Line Array Configuration Utility (without running the post-install scripts):


>  rpm -ivh hpacucli-8.60-8.0.noarch.rpm --noscripts
>  rpm -ivh hpacucli-8.60-8.0.noarch.rpm --noscripts

- Load the cpqarray module (part of stock kernel, would be normally loaded by the post-install script)


>  modprobe cpqarray
>  modprobe cpqarray

- Start the command line tool:


>  hpacucli 
>  > HP Array Configuration Utility CLI 8.60-8.0
>  > Detecting Controllers...Done.
>  hpacucli 
>  > HP Array Configuration Utility CLI 8.60-8.0
>  > Detecting Controllers...Done.


- Get even more detailed information stored into a file:

``` 

=> ctrl all diag file=/tmp/diag.txt

   Generating diagnostic report...done

```

- Get overall controller status and write-cache battery status:

``` 

=> ctrl all show status

Smart Array P400 in Slot 1
   Controller Status: OK
   Cache Status: Temporarily Disabled
   Battery/Capacitor Status: Failed (Replace Batteries/Capacitors)

```

# Gridpulse hacks

To make `gridpulse` report this system as OK, we need to make sure scripts in `/etc/rc.d/init.d` exit with `0` when invoked with the `status` argument (assuming the system is actually OK).

