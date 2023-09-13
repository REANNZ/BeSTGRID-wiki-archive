# Installing R on a Rocks Cluster

# Introduction

Setting up R on a Rocks cluster is a quick way of deploying R in a MPI environment. Care needs to be taken when setting up R environments in BeSTGRID to ensure that R script behave consistently between computation resources. A first step to a standardised R installation is to make sure that R is installed in a similar manner, and that access to the R package repository, or [CRAN](http://cran.stat.auckland.ac.nz/), is universally accessible.

# R

[R](http://www.r-project.org/) is a language for statistical computation initially written by Robert Gentleman and Ross Ihaka—also known as "R & R" of the [Statistics Department of the University of Auckland](http://www.stat.auckland.ac.nz/). It is gaining traction as the standard language for statistical computation.

R is a [GNU project](http://www.gnu.org/) which is similar to the S language and environment which was developed at Bell Laboratories (formerly AT&T, now Lucent Technologies) by John Chambers and colleagues. R can be considered as a different implementation of S. There are some important differences, but much code written for S runs unaltered under R.

R provides a wide variety of statistical (linear and nonlinear modelling, classical statistical tests, time-series analysis, classification, clustering, ...) and graphical techniques, and is highly extensible. The S language is often the vehicle of choice for research in statistical methodology, and R provides an Open Source route to participation in that activity.

One of R's strengths is the ease with which well-designed publication-quality plots can be produced, including mathematical symbols and formulae where needed. Great care has been taken over the defaults for the minor design choices in graphics, but the user retains full control.

R is available as Free Software under the terms of the Free Software Foundation's GNU General Public License in source code form. It compiles and runs on a wide variety of UNIX platforms and similar systems (including FreeBSD and Linux), Windows and MacOS.

R is supported by BeSTGRID and has been promoted for ubiquitous installation across BeSTGRID computation resources.

## CRAN

R packages are distributed on the [Comprehensive R Archive Network](http://cran.stat.auckland.ac.nz/) (CRAN), there is a local mirror available on the KAREN network at The University of Auckland, so there should be no need for BeSTGRID or KAREN members to set up local mirrors.

# Rocks Cluster

Rocks is based on [CentOS](http://www.centos.org/), which is an open source distribution of [Red Hat Enterprise Linux](http://www.redhat.com/rhel/) (RHEL). As it is derived from CentOS and RHEL the packages in Rocks are quite conservative, but some are upgraded to later versions for better cluster performance, and others are excluded from the Rocks distribution and repositories if they are overly disruptive to cluster operations.

# Prerequisites

A standard installation of Rocks on a dedicated computation cluster should be enough. The head node of the cluster will require internet access, and should ideally be connected to the KAREN network. CRAN needs to be accessible to the compute nodes of the cluster before installation so that the packages can be installed automatically when the cluster. This requires that HTTP traffic can pass through the head node to the compute nodes, and that both the head node and compute nodes are aware of any HTTP proxy between them and the Internet.

# Configuring NAT with iptables to allow access to CRAN

The head node of a Rocks Cluster acts as a firewall isolating the internal cluster network from other networks. This method uses iptables to create a basic NAT allowing the compute nodes to initiate network connections with external sources. This method may need to be refined if limited access is desired (e.g. restricting access to just the CRAN mirror, or just to ports 80,8080, & 443).

On the head node create the following iptable entries:

``` 

sudo /sbin/iptables -t nat --append POSTROUTING --out-interface eth1 -j MASQUERADE
sudo /sbin/iptables --append FORWARD --in-interface eth0 -j ACCEPT

```

...and save them to be restored on restart with:

``` 

sudo /sbin/service iptables save

```

This assumes the standard Rocks configuration where the cluster internal network is attached to `eth0` and the external network is attached to `eth1`.

# Configuring HTTP proxy settings

Most Linux applications use the environment variables `http_proxy`, `https_proxy`, and `ftp_proxy` to discover any proxy servers operating on the network.

## On the head node

Edit `/etc/profile` and add the following lines at the end of the file to set up the environment variables:

``` 

http_proxy=http://<address>:<port>
https_proxy=$http_proxy
ftp_proxy=$http_proxy
no_proxy="*.local,localhost,10.1.1.1"
export http_proxy https_proxy ftp_proxy no_proxy

```

This sets the environment variables when a user logs in or a daemon process starts. To refresh environment variables without relogging use:

``` 

source /etc/profile

```

## For the compute nodes

On the head node, edit `/export/rocks/install/site-profiles/5.2/nodes/extend-compute.xml` and add the following lines in the 

``` 
<post>...</post>
```

 section:

``` 

        <!-- Configure http proxy -->
        echo -e 'http_proxy=http://<address>:<port>\nhttps_proxy=$http_proxy\nftp_proxy=$http_proxy\nno_proxy="localhost,*.local,10.1.1.1"\nexport http_proxy ftp_proxy https_proxy no_proxy' >> /etc/profile

        <!-- Need to refresh environment -->
        source /etc/profile

```

Then rebuild the Rocks distribution:

``` 

cd /export/rocks/install
sudo rocks create distro

```

When the compute nodes are reinstalled, the environment variables will be automatically set up.

**NOTE:** in the examples above 

``` 
<address>:<port>
```

 will need to be replaced with the address and port of the http proxy server. This method assumes that the http proxy also acts as a proxt for https and ftp.

# Upgrading R

Providing that the prerequsite work is already in place, simply uninstall R from the head node

``` 

yum remove R R-devel libRmath libRmath-devel

```

Then continue with the rest of the procedure using the newer R packages.

# Installing R

R is not distributed with Rocks, and if it is they are likely to be outdated due to the conservative nature of Rock's packages. It is recommended that the current version of R is integrated into Rock using the latest RPM packages. R depends on xdg-utils, which will also have to be installed.

# Download packages

## Download R

Download the latest R RPM packages from the [CRAN mirror](http://cran.stat.auckland.ac.nz/bin/linux/redhat/el5/x86_64/) or from [be sure to get the correct version for your Rocks architecture (this article assumes `x86_64` architecture). Only the `R` and `R-core` packages are required, but it is recommended that the `R-devel`, `libRmath`, and `libRmath-devel` are installed. It is good practice to check the packages MD5 hashes.

## Download xdg-utils

Locate the latest RPM package for xdg-utils from [http://rpm.pbone.net/index.php3/stat/4/idpl/14025664/dir/centos_5/com/xdg-utils-1.0.2-2.el5.centos.noarch.rpm.html rpm.pbone.net](http://fedoraproject.org/wiki/EPEL),] and download it to the head node of the Rocks cluster.

# Set up R and standard packages to install on the compute nodes

- Log in to the head node of the Rocks Cluster
- Copy the `R`, `libRmath`, and `xdg-utils` RPM packages to 

``` 
/export/rocks/install/contrib/<ver>/<arch>/RPMS
```

 where 

``` 
<ver>
```

 is the Rocks version and the 

``` 
<arch>
```

 is the architecture.
	
- If performing an R upgrade, delete the previous R packages.
- Edit `/export/rocks/install/site-profiles/5.2/nodes/extend-compute.xml` and add the following lines in the 

``` 
<package>
```

 section to install R on the compute nodes:

``` 
<package>R</package>
<package>R-devel</package>
<package>libRmath</package>
<package>libRmath-devel</package>
```
- Edit `/export/rocks/install/site-profiles/5.2/nodes/extend-compute.xml` and add the following lines in the 

``` 
<post>
```

 section to create the `rconfig.r` script and run it to install some standard R packages on the compute nodes:

``` 

mkdir /install/rocks-dist/scripts
<file name="/install/rocks-dist/scripts/rconfig.r">
Sys.getenv("http_proxy")

options(repos="http://cran.stat.auckland.ac.nz")

#Install Rmpi separately due to configure.args requirement
install.package("Rmpi",configure.args='--with-mpi=/opt/openmpi')

# Create a list of standard packages
packagelist &amp;lt;- c("sp","maptools","lattice","spproj","spgpc","spgrass6","spgdal","gstat","splancs","DCluster","spdep","spPBS","spmaps","spspatstat","spgeoR","spRandomFields","spatstat","geoR","geoRglm","odesolve","snow","coda","akima")
for (pkg in packagelist)
{
        if (!require(pkg))
                {
                print(paste("Attempting to install ",pkg))
                install.packages(pkg)
                }
}
</file>

ls -l /install/rocks-dist/scripts

http_proxy=http://<address>:<port> /usr/bin/R CMD BATCH --vanilla /install/rocks-dist/scripts/rconfig.r /var/log/rconfig.log

```

- Then rebuild the Rocks distribution:

``` 

cd /export/rocks/install
sudo rocks create distro

```

R and the standard package set will be installed automatically when the compute nodes are reinstalled

# Install R and standard packages on the head node

This step requires that the R packages have already been integrated into your Rocks distribution as described in the steps above.

- Log into the head node of the Rocks Cluster
- Install R with the following command:

``` 

sudo yum install R R-devel libRmath libRmath-devel

```
- Create a R script file `rconfig.r` with the contents (note the same list of packages from above):

``` 

Sys.getenv("http_proxy")

options(repos="http://cran.stat.auckland.ac.nz")

#Install Rmpi separately due to configure.args requirement
install.packages("Rmpi",configure.args='--with-mpi=/opt/openmpi')

# Create a list of standard packages
packagelist <- c("sp","maptools","lattice","spproj","spgpc","spgrass6","spgdal","gstat","splancs","DCluster","spdep","spPBS","spmaps","spspatstat","spgeoR","spRandomFields","spatstat","geoR","geoRglm","odesolve","snow","coda","akima")
for (pkg in packagelist)
{
        if (!require(pkg))
                {
                print(paste("Attempting to install ",pkg))
                install.packages(pkg)
                }
}

```
- Run the script with:

``` 

sudo http_proxy=http://<address>:<port> R CMD BATCH rconfig.r rconfig.log

```

R and the standard packages should be installed on the head node.
