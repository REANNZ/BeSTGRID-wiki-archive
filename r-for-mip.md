# R for MIP

# Introduction

This article will describe how a `xml` file ought to be configured to describe R with MIP so that R is available in a standard form for BeSTGRID users.

This article is intended only to cover the configuration of R in a batch environment (either single threaded, or multi-threaded within a single node). For configuring R for parallel environments (e.g. OpenMPI) see the equivalent article on [Rmpi and snow](r-mpi-snow-for-mip.md).

# Configuration

# Example xml file for R

This should be saved as `/usr/local/mip/modules/apac_py/SubCluster/softwareInfoData/R.xml`.

``` 

<SoftwarePackages xmlns:glue="http://forge.cnaf.infn.it/glueschema/Spec/V12/R2" xmlns:apac="http://grid.apac.edu.au/glueschema/Spec/V12/R2" xmlns="http://www.ivec.org/softwareSubSchema/Spec/V12/R2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.ivec.org/softwareSubSchema/Spec/V12/R2 APACSoftwareSubSchemaR2.xsd">
<SoftwarePackage LocalID="R/2.10.1-Linux" xmlns="http://grid.apac.edu.au/glueschema/Spec/V12/R2">
          <Name>R</Name>
          <Version>2.10.1</Version>
          <Module>R/2.10.1-Linux</Module>
          <SoftwareExecutable LocalID="R/2.10.1-Linux-R">
                        <Name>R</Name>
                        <Path>/usr/bin</Path>
                        <SerialAvail>true</SerialAvail>
                        <ParallelAvail>false</ParallelAvail>
          </SoftwareExecutable>
          <SoftwareExecutable LocalID="R/2.10.1-Linux-Rscript">
                        <Name>Rscript</Name>
                        <Path>/usr/bin</Path>
                        <SerialAvail>true</SerialAvail>
                        <ParallelAvail>false</ParallelAvail>
          </SoftwareExecutable>
        </SoftwarePackage>
</SoftwarePackages>

```

This file can the be referenced as source in 

``` 
/usr/local/mip/config/<cluster>_<subcluster>_SIP.ini
```

 with:

``` 

[source1]
uri: file:softwareInfoData/localSoftware.xml
format: APACGLUE1.2

[source2]
uri: file:softwareInfoData/R.xml
format: APACGLUE1.2

```
