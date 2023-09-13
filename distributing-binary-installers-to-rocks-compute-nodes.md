# Distributing binary installers to Rocks compute nodes

# Introduction

Sometimes the use of proprietary software on the Rocks cluster is unavoidable, and software vendors do not always use the traditional distribution methods for Linux, that is they do not distribute software as source code, or installation packages (.deb or .rpm files). A commonly used method is to distribute binary installers.

These binary installers can be distributed to the compute nodes and automatically be installed via the Avalanche installer.

# Procedures

Using this procedure will result in the files being available on the compute nodes at `/install/contrib/extra/install`. In some circumstances (e.g. if the installer is large) it may be prudent to delete these files once the installation is complete.

# Distributing the binary

- Log into the head node of the cluster as a super user
- Check that the directory `/export/rocks/install/contrib/extra/install` exists, if not, create it with:

``` 

sudo mkdir -p /export/rocks/install/contrib/extra/install

```
- Download and/or uncompress the required binary into `/export/rocks/install/contrib/extra/install`
- Create a torrent for Rocks with:

``` 

cd /export/rocks/install
sudo rocks create torrent \
/export/rocks/install/contrib/extra/install/<installer-name>

```
- With a browser check that the file and torrent is being provided correctly by the head node [http://head.node.domain.name/install/contrib/extra/install/](http://head.node.domain.name/install/contrib/extra/install/)

# Integrating the binary into the compute node post install script

