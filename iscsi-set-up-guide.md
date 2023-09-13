# ISCSI Set Up Guide

This is what you need to do to get iSCSI working:

1. Install Enterprise iSCSI Target[on SAN

Note: We (Massey) had to use CVS trunk version as the stable build did not compile

2. Edit /etc/ietd.conf to export the RAID md devices as *targets*

3. Launch the Target with:

>    /etc/init.d/iscsi-target start

4. Install Open-iSCSI[http://www.open-iscsi.org/](http://iscsitarget.sourceforge.net/)] on Server

5. Start Initiator (on Server) with:

>    service open-iscsi start

6. Discover targets (from Server) using:

>    iscsiadm -m discovery -t sendtargets -p ip:port

Where port is 3260 by default. This command should print out the discovered targets.

7. Log in to targets (from Server) by setting an automatic script, OR manually:

>    ./iscsiadm -m node -T targetname -p ip:port -l

Where the last character is a small 'L' for "login".

When 'logged-in' to a target, the iscsi initiator will create /dev/sdX devices representing each target.

The server can then make an array over the top of all the sdX devices.

# Cautions

The only caution is that you will crash the kernel on the server machine if you stop the iSCSI service on the Server before unmounting all of the iSCSI target devices.
