# RSH on Rocks

We are not using it now, but in case we need it later:

- follow instructions here [http://www.rocksclusters.org/roll-documentation/base/5.0/customization-rsh.html](http://www.rocksclusters.org/roll-documentation/base/5.0/customization-rsh.html)
- install rsh-server rpms
- enable rlogin and rsh in xinetd configuration (/etc/xinetd.d/rlogin, etc/xinetd.d/rsh) set disable=no
- **cluster-fork "sed -i -e 's/disable.**=.*yes/disable                 = no/' /etc/xinetd.d/rlogin "
- to enable passwordless rsh, add .rhosts file to home directory with list of every cluster node AND use IP, not name for frontnode, because it will use internal NIC.
	
- also it may be necessary to edit /etc/hosts.allow, etc/hosts.equiv, etc. to create trusted network
- By default xinetd limits maximum number of connections. to remove this limit edit xinetd.conf
	
- add _instances = UNLIMITED _
- add _ per_source = UNLIMITED _
- restart xinetd (cluster-fork service xinetd restart)
