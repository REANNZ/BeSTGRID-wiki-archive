# Compute Nodes Setting

# BMC on compute nodes 

# MACs:

|  IP Address  |  MAC Address        |
| ------------ | ------------------- |
|  Headnode    |  00:30:48:97:f6:33  |
|  10.0.1.1    |  00:30:48:97:fc:c5  |
|  10.0.1.2    |  00:30:48:94:9e:a5  |
|  10.0.1.3    |  00:30:48:97:fb:ed  |
|  10.0.1.4    |  00:30:48:97:fc:bc  |
|  10.0.1.5    |  00:30:48:94:9e:b3  |
|  10.0.1.6    |  00:30:48:97:fb:e5  |
|  10.0.1.7    |  00:30:48:97:fb:8a  |
|  10.0.1.8    |  00:30:48:97:f6:32  |
|  10.0.1.9    |  00:30:48:97:f6:69  |
|  10.0.1.10   |  00:30:48:97:fb:87  |

# Headnode's iptables configuration to access BMC from public network

By default those run DHCP client on a local network. Therefore to make them available inside local network, there have to be DHCP server on the frontnode. Rocks runs dhcp server to configure cluster appliances so it is possible to assign addresses to BMC by running **insert-ethers** and selecting any appliance other then compute node. The Rocks wiki suggests that power appliance does not try to kickstart nodes, so it is most suitable. However the experience shows that **insert-ethers** *does* try to kickstart even for power appliance, so the choice does not matter much. I still selected power appliance, so the names assigned look like **power-x-x**.  After the original setup it is possible to access BMC from web interface just like for the front node,  assign static address, and remove the appliances from Rocks by running **insert-ethers remove power-x-x**. 

To make BMC available on public network, we decided to configure iptables on front node to forward connections to 2001-2010 ports to port 80 on appropriate private addresses i.e.

>  /sbin/iptables -t nat -A PREROUTING -p tcp -i eth1 -d 130.216.189.80  --dport 2001 -j DNAT --to 10.0.1.1:80
>  /sbin/iptables -t nat -A PREROUTING -p tcp -i eth1 -d 130.216.189.80  --dport 2002 -j DNAT --to 10.0.1.2:80
>  /sbin/iptables -t nat -A PREROUTING -p tcp -i eth1 -d 130.216.189.80  --dport 2003 -j DNAT --to 10.0.1.3:80
>  /sbin/iptables -t nat -A PREROUTING -p tcp -i eth1 -d 130.216.189.80  --dport 2004 -j DNAT --to 10.0.1.4:80
>  /sbin/iptables -t nat -A PREROUTING -p tcp -i eth1 -d 130.216.189.80  --dport 2005 -j DNAT --to 10.0.1.5:80

 /sbin/iptables -A FORWARD -p tcp -i eth1 -o eth0 -d 10.0.1.1 --dport 80 -j ACCEPT

>  /sbin/iptables -A FORWARD -p tcp -i eth1 -o eth0 -d 10.0.1.2 --dport 80 -j ACCEPT
>  /sbin/iptables -A FORWARD -p tcp -i eth1 -o eth0 -d 10.0.1.3 --dport 80 -j ACCEPT
>  /sbin/iptables -A FORWARD -p tcp -i eth1 -o eth0 -d 10.0.1.4 --dport 80 -j ACCEPT
>  /sbin/iptables -A FORWARD -p tcp -i eth1 -o eth0 -d 10.0.1.5 --dport 80 -j ACCEPT

Note that this setting does not give access to remote console. Another way to access BMC console is to set up SOCKS proxy on the client machine and configure your browser to use it. For example the following command creates proxy on client machine:

>  ssh -fND localhost:10001 root@hpc-bestgrid.auckland.ac.nz

Port can be any free port, username and domain name are for the front node.

To setup firefox to use this proxy, go to Edit -> Preferences -> Advanced -> Connections  and add SOCKS proxy for localhost and port 10001 (or any other as above). Then local address for BMC can be used (i.e. 10.0.1.x etc.)

# Configuring BMC with ipmitool

to install IPMI on compute nodes the following is needed:

RPMS (I used version 2.0.6-5 but can be any version):

- 
- OpenIPMI-2.0.6-5.el5.4.x86_64.rpm
- OpenIPMI-libs-2.0.6-5.el5.4.x86_64.rpm
- ipmitool (downloaded sources and compiled)

Then do /etc/init.d/ipmi start

Useful ipmitool commands:

To print configuration: 

>  ipmitool lan print 1

To set an IP address

>  ipmitool lan set 1 ipaddr x.x.x.x

To set netmask

>  ipmitool lan set 1 netmask x.x.x.x

To set gateway IP

>  ipmitool lan set 1 defgw ipaddr x.x.x.x

# BMC Problem

On unknown reason only 6 nodes from ten send DHCP requests to acquire IPs for IPMI BMC. The internal switch doesn't block DHCP requests on certain ports because DHCP requests of PXE boot from 4 nodes come to the Headnode.

Compute nodes have no CD drives and ISO image for USB flash drives to set IPMI/BMC unusable. The only way to set/check IPMI/BMC configuration is to boot a node from an external USB CDROM drive. We are looking around to find one.

**Update:** The problem was due to some of the nodes set up using static ip with gateway 0.0.0.0. Therefore they do not ask for DHCP address and were not accessible.

# Cluster specification of Compute nodes on 7/05/2008

|  **System**                             |  **Rack**  |  **Position**  |  **Serial Number**  |    **MACs**                                                            |  **IP**                        |  **BMC MAC**                         |  **BMC IP**         |  **Hostname**            |
| --------------------------------------- | ---------- | -------------- | ------------------- | ---------------------------------------------------------------------- | ------------------------------ | ------------------------------------ | ------------------- | ------------------------ |
|  Head Node Altix XE 250                 |  P9        |  28,29         |  X0004868           |  00-30-48-7F-71-8800-30-48-7F-71-89                                    |  130.216.189.8010.1.1.1        |  00-30-48-97-F6-33                   |  130.216.189.81     |  Cluster                 |
|  Node1 Altix XE 320Node2 Altix XE 320   |  P9        |  30            |  X0004872           |  00-30-48-7F-46-D200-30-48-7F-46-D300-30-48-7F-47-7E00-30-48-7F-47-7F  |  10.255.255.25210.255.255.253  |  00-30-48-97-FC-C500-30-48-97-FC-BC  |  10.0.1.110.0.1.4   |  compute-0-1compute-0-0  |
|  Node3 Altix XE 320Node4 Altix XE 320   |  P9        |  31            |  X0004874           |  00-30-48-7F-A8-F600-30-48-7F-A8-F700-30-48-7F-A8-F800-30-48-7F-A8-F9  |  10.255.255.24410.255.255.245  |  00-30-48-94-9E-A500-30-48-94-9E-B3  |  10.0.1.210.0.1.5   |  compute-0-9compute-0-8  |
|  Node5 Altix XE 320Node6 Altix XE 320   |  P12       |  23            |  X0004873           |  00-30-48-7F-42-5200-30-48-7F-42-5300-30-48-7F-47-7A00-30-48-7F-47-7B  |  10.255.255.24710.255.255.246  |  00-30-48-97-FB-ED00-30-48-97-FB-E5  |  10.0.1.310.0.1.6   |  compute-0-6compute-0-7  |
|  Node7 Altix XE 320Node8 Altix XE 320   |  P12       |  24            |  X0004871           |  00-30-48-7F-2F-8800-30-48-7F-2F-8900-30-48-7F-2F-8400-30-48-7F-2F-85  |  10.255.255.24810.255.255.249  |  00-30-48-97-FB-8A00-30-48-97-FB-87  |  10.0.1.710.0.1.10  |  compute-0-5compute-0-4  |
|  Node9 Altix XE 320Node10 Altix XE 320  |  P12       |  25            |  X0004870           |  00-30-48-7F-48-9E00-30-48-7F-48-9F00-30-48-7F-48-B000-30-48-7F-48-B1  |  10.255.255.25010.255.255.251  |  00-30-48-97-F6-6900-30-48-97-F6-32  |  10.0.1.910.0.1.8   |  compute-0-3compute-0-2  |
