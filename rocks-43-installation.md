# Rocks 4.3 Installation

# Network Interface Card Drivers problem

Rocks Installation procedure didn't recognize Ethernet device on the Headnode. 

Standard e1000 driver doesn't work with the NIC. Ubuntu 7.04 and CentOS 4.5 also didn't recognize the NIC. 

SGI support advised that Intel® 82575EB controller has been installed into XE250. 

[README file for this controller:](http://downloadmirror.intel.com/13663/ENG/README.txt) The **igb** driver must be installed to support any 82575-based network connections. All other network connections require the e1000 driver.

Rocks 4.3 doesn't consist **igb** network driver. To install Rocks onto the Headnode this driver should be added into **Rocks Cluster Distribution**. 

Rocks Cluster Distribution v4.3 has been downloaded.

CentOS 5.1 consists **igb** driver but Rocks requires CentOS 4.5. 

# Adding new network driver to Rocks Distribution

[There is a manual: how to add device driver into a distribution.](http://www.rocksclusters.org/rocks-documentation/4.3/customization-driver.html) 

There was an attempt to add igb driver to Rocks distribution on naked CentOS 4. 

Next steps performed to compile Rocks Distribution with **igb** network driver.

[Unsuccessful attempts to recompile Rocks](unsuccessful-attempts-to-recompile-rocks.md)

But Rocks gurus in Rocks Mailing list advised to recompile Rocks only on Rocks Frontend with the same version and architecture. However this procedure is going to be long and complex and to reduce time a decision to install Rocks5.0 Beta has been admitted.
