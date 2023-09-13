# R mpi SNOW for MIP

# Introduction

This article will describe how a `xml` file ought to be configured to describe [R](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=R&linkCreation=true&fromPageId=3816950699) using [MIP](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=MIP&linkCreation=true&fromPageId=3816950699) with the Rmpi and snow packages so that parallel R is available in a standard form for BeSTGRID users.

This article is intended only to cover the configuration of R in a parallel environment (e.g. [OpenMPI](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=OpenMPI&linkCreation=true&fromPageId=3816950699)). For configuring R for serial environments see the equivalent article on [R](/wiki/spaces/BeSTGRID/pages/3816950631).

# Configuration

# Make RMPISNOW script available on the path

On the head node of a rocks cluster the following command will link `RMPISNOW` to `/usr/bin` which should be in the `PATH` for all Linux systems:

``` 

ln -s /usr/lib64/R/library/snow/RMPISNOW /usr/bin/RMPISNOW

```

Adding this command into the {{}} section of 

``` 
/export/rocks/install/site-profile/<version>/nodes/extend-compute.xml
```

 and rebuild your rocks distribution. This should automatically create the link when the compute nodes are reinstalled.

# Modify RMPISNOW for the Rocks/SGE environment

Some variables passed to `RMPISNOW` from the Sun Grid Engine and OpenMPI don't match. Run the following command on the head node to correct `RMPISNOW`:

``` 

sed -i 's/OMPI_MCA_ns_nds_vpid/OMPI_COMM_WORLD_RANK"/g' /usr/lib64/R/library/snow/RMPISNOW

```

Add this command into the {{}} section of 

``` 
/export/rocks/install/site-profile/<version>/nodes/extend-compute.xml
```

 and rebuild your rocks distribution. This should automatically modify `RMPISNOW` when the compute nodes are reinstalled.

# Example xml file for R_mpi_SNOW

This should be saved as `/usr/local/mip/modules/apac_py/SubCluster/softwareInfoData/R_mpi_SNOW.xml`.

``` 

<SoftwarePackages xmlns:glue="http://forge.cnaf.infn.it/glueschema/Spec/V12/R2" xmlns:apac="http://grid.apac.edu.au/glueschema/Spec/V12/R2" xmlns="http://www.ivec.org/softwareSubSchema/Spec/V12/R2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.ivec.org/softwareSubSchema/Spec/V12/R2 APACSoftwareSubSchemaR2.xsd">
  <SoftwarePackage LocalID="RMPISNOW/2.10.1-Linux" xmlns="http://grid.apac.edu.au/glueschema/Spec/V12/R2">
    <Name>R_mpi_SNOW</Name>
    <Version>2.10.1</Version>
    <Module>RMPISNOW/2.10.1-Linux</Module>
    <SoftwareExecutable LocalID="RMPISNOW/2.10.1-Linux-RMPISNOW">
      <Name>RMPISNOW</Name>
      <Path>/usr/bin</Path>
      <SerialAvail>false</SerialAvail>
      <ParallelAvail>true</ParallelAvail>
    </SoftwareExecutable>
  </SoftwarePackage>
</SoftwarePackages>

```

This file can the be referenced as source in `/usr/local/mip/config/``cluster``_``subcluster``_SIP.ini` with:

``` 

[source1]
uri: file:softwareInfoData/localSoftware.xml
format: APACGLUE1.2

[source2]
uri: file:softwareInfoData/R_mpi_SNOW.xml
format: APACGLUE1.2

```

# Testing RMPISNOW

- Submit this 
!R-test-snow.txt!
 via Grisu, which should list the hostnames of all the nodes in the Rmpi cluster.
- This second test script 
!Rmpisnow-test.txt!
 should perform some actual computation on all the nodes in the Rmpi cluster.
