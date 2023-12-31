# Category MIP

# Introduction

The Modular Information Provider (MIP) is the software implementation populating the local [MDS](mds.md) on a sites job submission gateway (a.k.a. NG2 or NG1) and this information gets then pushed to the central MDS index held at the [ARCS MDS directory](http://www.sapac.edu.au/webmds/).

These pages cover advanced configuration of MIP and specific information about how to configure applications for MIP.

# Configuration

The initial configuration of MIP given in the article on [setting up a job submission gateway](setting-up-an-ng2.md) is sufficient for submitting services to MDS, but as more services are added to the cluster, and appending their definitions to `/usr/local/mip/modules/apac_py/SubCluster/softwareInfoData/localSoftware.xml` can become unwieldy.

As more services are added, a more manageable approach may be to define each service or application in a separate `xml` file, and add these files as source in the job submission gateway's MIP configuration file (`/usr/local/mip/config/default_ng2.``yoursite``-sub1_SIP.ini` as described [here](setting-up-an-ng2.md#SettingupanNG2-CreateConfigfile)). Most of the articles in this category should be giving you the xml necessary to describe each application in a standard way for use by BeSTGRID members.

Here is an example of the \[source\] elements of a SIP.ini file using multiple sources:

``` 

[source1]
uri: file:softwareInfoData/localSoftware.xml
format: APACGLUE1.2

[source2]
uri: file:softwareInfoData/R.xml
format: APACGLUE1.2

[source3]
uri: file:softwareInfoData/R_mpi_SNOW.xml
format: APACGLUE1.2

[source4]
uri: file:softwareInfoData/mrbayes.xml
format: APACGLUE1.2

```

The `xml` file describes the application according the ARCS extension of the GLUE schema. A description of the relevant elements can be found [here](https://projects.arcs.org.au/trac/systems/wiki/InfoSystems/GridAustraliaGlueFieldsPolicy).

# Verifying and formatting xml files

The following command will verify `xml` files against the APAC GLUE schema: 

``` 

xmllint --schema /usr/local/mip/modules/default/SubCluster/softwareInfoData/APACSoftwareSubSchemaR2.xsd <yourSoftwareDefinition>

```

The following sequence can be used to tidy up `xml` formatting:

``` 

xmllint --format file.xml -o file.tidy.xml
mv file.tidy.xml file.xml

```

**Note:** be sure that the file has tidied correctly before overwriting the original.

# Checking MIP output

The following command will display and check the validity of a cluster's MIP configuration:

``` 

/usr/local/mip/config/globus/mip-exec.sh -validate 2>&1 | less

```

# References

More information about MIP can be found on the [ARCS Projects Trac site](https://projects.arcs.org.au/trac/systems/wiki/InfoSystems/InstallConfigSteps).

A description of the GLUE schema fields can be found [here](https://projects.arcs.org.au/trac/systems/wiki/InfoSystems/GridAustraliaGlueFieldsPolicy).
