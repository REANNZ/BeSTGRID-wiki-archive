# Xen___assigning PCI devices to a domain

In Xen, it is possible to assign a PCI device to a user domain.  As there some tricks were necessary on top of the instructions in the Xen User's Manual, I decided to write them down here.

# Basics & System requirements

To assign a PCI device to a domain, Xen uses a PCI frontend and backend driver.  In dom0, the device must be controlled by the PCI backend driver, and when a user domain can be assigned  such devices at the time it is created.  For that, the user domain kernel must have the PCI frontend driver, and of course the PCI driver for the specific device.  The standard Xen dom0 kernel has all the necessary drivers (backend, frontend and device drivers), and I recommend running this kernel in a user domain which needs direct access to PCI devices.  The CentOS distribution xenU kernel does not have the frontend and PCI device drivers.

# Exporting a device

It is generally not necessary to reboot dom0 to export a device.  It is sufficient just to:

1. Determine the PCI Id of the device (short form `00:1d.7` with `lspci`, and long form `0000:00:1d.7` by simply prepending "`0000:`" to the short form)
2. Make sure the device is not controlled by any driver: there should be no `driver` symlink in `/sys/bus/pci/devices/``nnnn:nn:nn.n`
3. Load the `pciback` driver, and pass it the list of devices to control in the `hide` parameter: 

``` 
modprobe pciback 'hide=(0000:00:1d.0)(0000:00:1d.1)(0000:00:1d.2)(0000:00:1d.3)(0000:00:1d.7)'
```

# Assigning the device to a domain

The devices to be assigned are passed with the `pci=``nn:nn.nn` parameter to `xm create` (and the parameter can occur multiple times).  The only requirement is that the kernel has the PCI frontend (which, e.g., the dom0 kernel has).

Thus, a domain should be created with

>  xm create -c NGTest-dom0kernel pci=00:1d.0 pci=00:1d.1 pci=00:1d.2 pci=00:1d.3 pci=00:1d.7

After it boots, the device(s) should be visible with `lspci` and in `/sys/bus/pci/devices/`.

Alternatively, one may achieve the same effect by adding the list of PCI devices to the domain configuration file:

``` 
pci = [ '00:1d.0', '00:1d.1', '00:1d.2', '00:1d.3', '00:1d.7' ]
```

# Setting up permanent assignment

In `/etc/modprobe.conf`:

- Comment out aliases for eth2-eth5 and disable loading the e1000 driver:

``` 

#alias eth2 e1000
#alias eth3 e1000
#alias eth4 e1000
#alias eth5 e1000

alias eth2 off
alias eth3 off
alias eth4 off
alias eth5 off
alias e1000 off

```

- Set options for the pciback module


>  options pciback hide=(0000:13:04.0)(0000:13:04.1)(0000:13:06.0)(0000:13:06.1)
>  options pciback hide=(0000:13:04.0)(0000:13:04.1)(0000:13:06.0)(0000:13:06.1)

- To load the pciback module *before* xendomains service is started, create a pciback service with the following contents and enable it with

``` 
chkconfig --add pciback
```
- Put this into `/etc/rc.d/init.d/pciback`

``` 

#!/bin/bash
#
# pciback        Load the pciback module
#
#
# chkconfig: 35 70 80
# description:  This service controlls the pciback module

# Local Configuration Parameters

RETVAL=0
umask 077
[ -n "$NICELEVEL" ] && nice="nice -n $NICELEVEL"

start() {
       echo -n $"Loading pciback: "
       modprobe pciback
       if [ $RETVAL -eq 0 ]; then
         echo "SUCCESS LOADING pciback"
       else
         echo "FAILED LOADING pciback"
       fi
       return $RETVAL
}
stop() {
       echo -n $"Unloading pciback: "
       rmmod pciback
       RETVAL=$?
       if [ $RETVAL -eq 0 ]; then
         echo "SUCCESS UNLOADING pciback"
       else
         echo "FAILED UNLOADING pciback"
         return $RETVAL
       fi
}
mystatus() {
  lsmod | grep '^pciback' || { echo "pciback not loaded"; exit 1 ; }
}
restart() {
       stop
       start
}

case "$1" in
 start)
       start
       ;;
 stop)
       stop
       ;;
 status)
       mystatus
       ;;
 restart|reload)
       restart
       ;;
 *)
       echo $"Usage: $0 {start|stop|status|restart}"
       exit 1
esac

exit $?

```

- In domU configuration file (`/etc/xen/NGData`):
	
- Comment out virtual interface declaration:

``` 
# vif = [ 'mac=00:16:3e:84:B5:03, bridge=xenbr0', 'mac=00:16:3E:C0:A8:03,bridge=xenbr1' ]
```
- Import pci devices from pciback:

``` 
pci = [ '13:04.0', '13:04.1' ]
```

# Alternative approaches

Graham Jenkins has provided an impressive solution based on a [pcibind script](http://projects.arcs.org.au/trac/systems/wiki/Howto/PciBack) - based on [Xen documentation on reassigning PCI devices](http://wiki.xensource.com/xenwiki/Assign_hardware_to_DomU_with_PCIBack_as_module) from a hardware driver to the pciback pseudo-driver.

My solution works because all of the devices I want to assign are controlled by the same driver and I can simply disable the driver.

Graham's solution is more elegant 🙂

# Hints and troubleshooting


## PCI permissions

**NEW**: Pciback was reporting the following error message:

``` 

pciback 0000:13:04.0: Driver tried to write to a read-only configuration space field at offset 0xe0, size 2. This may be harmless, but if you have problems with your device:
1) see permissive attribute in sysfs
2) report problems to the xen-devel mailing list along with details of your device obtained from lspci.
PCI: Enabling device 0000:13:04.0 (0000 -> 0003)
pciback 0000:13:04.1: Driver tried to write to a read-only configuration space field at offset 0xe0, size 2. This may be harmless, but if you have problems with your device:
1) see permissive attribute in sysfs
2) report problems to the xen-devel mailing list along with details of your device obtained from lspci.
PCI: Enabling device 0000:13:04.1 (0000 -> 0003)

```

After trolling through the documentation, I have done exactly what the documentation and this message asks for and configured the *Xen PCI quirks* settings to allow xen user domains to access the configuration space for this card (vendor/product ID 8086:10b5) at address 0xE0, size 2 bytes.  Add the following to `/etc/xen/xend-pci-quirks.sxp`:

``` 

(HPNC340T
    (pci_ids
        # Entries are formated as follows:  
        #     <vendor>:<device>[:<subvendor>:<subdevice>]
        ('8086:10b5'   # HP NC340T PCI-X 4-port 1000T Gigabit Server Adapter
        )
    )

    (pci_config_space_fields
        # Entries are formated as follows:  
        #     <register>:<size>:<mask>
        # size is measured in bytes (1,2,4 are valid sizes)
        # mask is currently unused; use all zero's
        ('000000E0:2:00000000'   # reported by pciback
        )
    )
)

```

## Further problems

I sometimes see the following message on the host system console when a CentOS 5 user domain is starting up:

``` 

(XEN) mm.c:590:d10 Error getting mfn 9be78 (pfn a4e78) from L1 entry 000000009be78025 for dom10
(XEN) mm.c:3174:d10 ptwr_emulate: fixing up invalid PAE PTE 000000009be78025

```

The domains seems to run fine... so I'm leaving it as it is now....
