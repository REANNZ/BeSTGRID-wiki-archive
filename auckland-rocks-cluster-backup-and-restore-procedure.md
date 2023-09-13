# Auckland Rocks Cluster Backup and Restore Procedure

# Installing Applications

Possible options:

- Without RPMS - [http://www.rocksclusters.org/roll-documentation/base/5.0/customization-adding-applications.html](http://www.rocksclusters.org/roll-documentation/base/5.0/customization-adding-applications.html)
	
- Can be used to test application before creating RPM.
- cluster-fork to install RPMS
	
- Problem - when nodes are re-imaged,  all RPMS have to be re-installed.
- Standard process for RPMS - [http://www.rocksclusters.org/roll-documentation/base/5.0/customization-adding-packages.html](http://www.rocksclusters.org/roll-documentation/base/5.0/customization-adding-packages.html)
	
- Solves the problem of previous approach.
- But requires all nodes to be re-imaged (i.e. about half hour outage)
- adding RPMS to "development" roll
	
- helps to restore system in case of crash

Since standard Rocks procedure for installing RPMS ensures persistance in case the nodes are re-imaged, we decided to use it and add the RPM to development roll. When quick install is required we use standard procedure, but do not re-image all the nodes immediately. Instead cluster-fork is used. This way we ensure stability of our system and do not have extra outage.

# Install Process

In case something bad happens or we need to reinstall everything.

- Go through normal Rocks install process [http://www.rocksclusters.org/roll-documentation/base/5.0/](http://www.rocksclusters.org/roll-documentation/base/5.0/)
	
- As a central server select reference cluster (currently bestgrid83.math.auckland.ac.nz)
- select standard rolls, restore roll and development roll
- download install scripts from //data.bestgrid.org/eResearch/scripts/install.tar.gz to /home/install on the cluster and run ./install.sh
- **Currently due to problems with local network setup during installation, there needs to be a CD with restore roll ready**
	
- * if restore roll is installed afterwards, X server has to be running *
- To fix MPI warnings run **cluster-fork 'echo "btl=^openib,udapl" >> /etc/openmpi-mca-params.conf'**

***Possible Issues***
- /home/ directory is missing
	
- check /etc/auto.home
- run *service autofs restart *
- restore roll does not recover user and system files properly
	
- the files can still be recovered from  /export/profile/nodes/restore-user-files.xml. They are stored in base64 format and need to be copied from that xml file and decoded with *base64 -d -i * command.

# Backups

We need to organize backups for

- restore roll
- ganglia database
	
- stored in /var/lib/ganglia in RRD format
- ganglia monitors defined in [http://www.rocksclusters.org/rocks-documentation/reference-guide/4.3/gmetric.html](http://www.rocksclusters.org/rocks-documentation/reference-guide/4.3/gmetric.html) (documentation for Rocks 5.0 is not available yet)
