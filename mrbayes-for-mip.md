# Mrbayes for MIP

# Introduction

This article will describe how a `xml` file ought to be configured to describe [MrBayes](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=MrBayes&linkCreation=true&fromPageId=3818228857) with [MIP](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=MIP&linkCreation=true&fromPageId=3818228857) so that MrBayes is available in a standard form for BeSTGRID users.

This article covers configuration of MrBayes for both serial and parallel environments.

# Configuration

# Example xml file for MrBayes

This should be saved as `/usr/local/mip/modules/apac_py/SubCluster/softwareInfoData/mrbayes.xml`.

``` 

<SoftwarePackages xmlns:glue="http://forge.cnaf.infn.it/glueschema/Spec/V12/R2" xmlns:apac="http://grid.apac.edu.au/glueschema/Spec/V12/R2" xmlns="http://www.ivec.org/softwareSubSchema/Spec/V12/R2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.ivec.org/softwareSubSchema/Spec/V12/R2 APACSoftwareSubSchemaR2.xsd">
  <SoftwarePackage LocalID="MrBayes/3.1.2" xmlns="http://grid.apac.edu.au/glueschema/Spec/V12/R2">
    <Name>MrBayes</Name>
    <Version>3.1.2</Version>
    <Module>mrbayes/3.1.2</Module>
    <SoftwareExecutable LocalID="mrbayes-parallel">
      <Name>mb</Name>
      <Path>/opt/shared/bin</Path>
      <SerialAvail>false</SerialAvail>
      <ParallelAvail>true</ParallelAvail>
    </SoftwareExecutable>
    <SoftwareExecutable LocalID="mrbayes-sequential">
      <Name>mb-serial</Name>
      <Path>/opt/shared/bin/</Path>
      <SerialAvail>true</SerialAvail>
      <ParallelAvail>false</ParallelAvail>
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
uri: file:softwareInfoData/mrbayes.xml
format: APACGLUE1.2

```

# Testing MrBayes

- This test file 
!Primates.nex.txt!
 will test that MrBayes works in parallel, requires a minimum of 25 processors. Modify the Nchains value for different cluster sizes.
