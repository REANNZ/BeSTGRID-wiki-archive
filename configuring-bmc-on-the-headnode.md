# Configuring BMC on the HeadNode

SGI supplied a CD with images to update flash memory with BIOS and BMC and to configure BMC network interface. "Bootable" USB memory stick has been created from an image for Altix XE250 as it was described in manual. But it was impossible to boot from the USB key on any computer. 

To solve the problem a software package to create a bootable CD image with FreeDOS system has been found and downloaded from the Internet. The new CD with BIOS and BMC flash memory update programs and BMC configuration utility have been created. After rebooting from this CD parameters of BMC has been configured: 

IP address: 130.216.189.81

Network Mask: 255.255.255.0

This utility hadn't configured a gateway address thus it was possible to have access to web interface only from a machine in 189 subnet. Then a gateway address has been added and BMC of the Headnode became accessible over the Internet. 

Now there is a full control over the Headnode including PowerOn, PowerOff and Cold Reset function. 

# How to share CD media from *NIX

BMC has access only to Windows shares, so we need to configure Samba server.

