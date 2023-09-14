# Installing Mono on a Rocks Cluster

# Introduction

[Mono](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Mono&linkCreation=true&fromPageId=3818228990) allows the execution of .NET applications on Linux, and for grid computing this allows the development of .NET 4.0 (with Mono 2.8) console applications to be run on a Rocks cluster. This procedure will allow the execution of .NET console applications written in either C# or Visual Basic via Mono on a Rocks Cluster.

# Installation

Mono can be compiled specifically for your cluster environment, but it is recommended that Mono is installed from the precompiled `rpm` packages available from Novell

- Log into the head node of your Rocks cluster
- Download all the precompiled packages for your architecture from the [Novell ftp site](http://ftp.novell.com/pub/mono/download-stable/RHEL_5/) the `noarch` packages will also be required.


>  **Copy all the **`rpm`** files to **`/export/rocks/install/contrib/5.2/*arch``/RPMS/`, including the `noarch` packages.
>  **Copy all the **`rpm`** files to **`/export/rocks/install/contrib/5.2/*arch``/RPMS/`, including the `noarch` packages.

- Edit `/export/rocks/install/site-profiles/5.2/nodes/extend-compute.xml` and make the following changes
- In the packages section add the following `package` statements:

``` 

<package>mono-addon-core</package>
<package>mono-addon-basic</package>
<package>mono-addon-libgdplus</package>

```
- In the `post` section add the lines to copy and clean up the mono environment:

``` 

cp /opt/novell/mono/bin/mono-addon-environment.sh /etc/profile.d
sed -i '/PS1="\[mono-addon\] $PS1"/d' /etc/profile.d/mono-addon-environment.sh

```
- Rebuild the Rocks distribution and update the `yum` cache

``` 

cd /export/rocks/install
sudo rocks create distro
sudo yum makecache

```

Rocks should now be automatically installed on the compute nodes on reinstallation.

# Manual Installation

Once Mono is included into a Rocks cluster's `yum` repository (as per the method above) Mono can be manually installed on the head node with:

``` 

sudo yum install mono-addon-core mono-addon-basic mono-addon-libgdplus

```

Following manual installation either:

- add the mono environment to `/etc/profile.d`

``` 

sudo cp /opt/novell/mono/bin/mono-addon-environment.sh /etc/profile.d
sudo sed -i '/PS1="\[mono-addon\] $PS1"/d' /etc/profile.d/mono-addon-environment.sh

```
- run the mono environment script prior to using mono

``` 

source /opt/novell/mono/mono-addon-environment.sh

```
