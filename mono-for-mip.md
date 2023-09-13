# Mono for MIP

# Introduction

This article will describe how a `xml` file ought to be configured to describe [Mono](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Mono&linkCreation=true&fromPageId=3816950574) with [MIP](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=MIP&linkCreation=true&fromPageId=3816950574) so that Mono is available in a standard form for BeSTGRID users.

# Configuration

# Example xml file for Mono

This should be saved as `/usr/local/mip/modules/apac_py/SubCluster/softwareInfoData/mono.xml`.

``` 

<SoftwarePackages xmlns:glue="http://forge.cnaf.infn.it/glueschema/Spec/V12/R2" xmlns:apac="http://grid.apac.edu.au/glueschema/Spec/V12/R2" xmlns="http://www.ivec.org/softwareSubSchema/Spec/V12/R2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.ivec.org/softwareSubSchema/Spec/V12/R2 APACSoftwareSubSchemaR2.xsd">
<SoftwarePackage LocalID="Mono/2.6.7-Linux" xmlns="http://grid.apac.edu.au/glueschema/Spec/V12/R2">
          <Name>Mono</Name>
          <Version>2.6.7</Version>
          <Module>Mono/2.6.7-Linux</Module>
          <SoftwareExecutable LocalID="Mono/2.6.7-Linux-Mono">
                        <Name>mono</Name>
                        <Path>/opt/novell/mono/bin/</Path>
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
uri: file:softwareInfoData/mono.xml
format: APACGLUE1.2

```
