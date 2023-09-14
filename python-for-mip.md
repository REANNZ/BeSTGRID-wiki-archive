# Python for MIP

# Introduction

This article will describe how a `xml` file ought to be configured to describe [Python](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Python&linkCreation=true&fromPageId=3818228721) with [MIP](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=MIP&linkCreation=true&fromPageId=3818228721) so that Python is available in a standard form for BeSTGRID users.

This article is intended only to cover the configuration of python for multi-threading on a single node. Parallel python should be possible.

# Configuration

# Example xml file for Python

This should be saved as `/usr/local/mip/modules/apac_py/SubCluster/softwareInfoData/python.xml`.

``` 

<SoftwarePackages xmlns:glue="http://forge.cnaf.infn.it/glueschema/Spec/V12/R2" xmlns:apac="http://grid.apac.edu.au/glueschema/Spec/V12/R2" xmlns="http://www.ivec.org/softwareSubSchema/Spec/V12/R2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.ivec.org/softwareSubSchema/Spec/V12/R2 APACSoftwareSubSchemaR2.xsd">
  <SoftwarePackage LocalID="Python" xmlns="http://grid.apac.edu.au/glueschema/Spec/V12/R2">
    <Name>python</Name>
    <Version>2.4.3</Version>
    <Module>python/2.4.3</Module>
    <SoftwareExecutable LocalID="Python/2.4.3">
      <Name>python</Name>
      <Path>/usr/bin</Path>
      <SerialAvail>true</SerialAvail>
      <ParallelAvail>true</ParallelAvail>
      <ParallelMaxCPUs>8</ParallelMaxCPUs>
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
uri: file:softwareInfoData/python.xml
format: APACGLUE1.2

```
