# Administering an NG2

This page follows on from the [Setting_up_an_NG2](setting-up-an-ng2.md) resource in that it seeks to provide

the information needed to administer your job submission gateway once it has been deployed.

Common administrative operations should appear here, along with methodologies for checking

that your job submission gateway is functioning as it should.

## Adding new software

As you come to add new publically accessible software capability to the computational

resources behind your gateway, you will want to advertise new that capability to the

rest of the grid system.

The steps are:

1. Update your local software map
2. Check that it is valid
3. Ensure the new software is visible

### Updating your local software map

Your local software map is part of the `MIP` package.

The file you will need to edit is 

>    `/path/to/mip/modules/apac_py/SubCluster/softwareInfoData/localSoftware.xml`

### Checking the validity of your local software map

There is a validation methodology built into the `MIP` package.

You can run

>    `/path/to/mip/config/globus/mip-exec.sh -validate` 

This will produce the XML you'll be pushing to the central MDS indexes as

well as telling you whether it or not it validates against the schema.

**Note** that having valid XML does not mean that your information is correct, merely

that it being pushed in a form that will be parseable.

At this time a visual inspection of the information is the only way to check for correctness.

### Ensuring the software you are advertising is visible

**Q** Restart required **???**

You can see what you are pushing to the MDS indexes by following the procedure for testing you had it set up correctly when initially installing

- Login to the NG2 as a non-root user and get initialize a local proxy certificate (either with `grid-proxy-init` or `myproxy-logon`)
- Query the local MDS contents with



## Checking your NG2 is visible in the WebMDS listing

Your NG2 should be visible here:

>  [http://www.sapac.edu.au/webmds/webmds?info=indexinfo&xsl=siteresourcesxsl](http://www.sapac.edu.au/webmds/webmds?info=indexinfo&xsl=siteresourcesxsl)

## Controlling the publishing of MDS informaton

The publishing of your MDS information into the central MDS indexes

is achieved through the definition of *upstream* `URI` entries in the 

>    `$GLOBUS_LOCATION/etc/globus_wsrf_mds_index/hierarchy.xml`

file.

Entries can be commented out or uncommented as desired.

Changes to this file require a restart of the `globus-ws` service to take effect.

``` 

service globus-ws stop
service globus-ws start

```

## Checking your usage information is being sent to the GOC

The default ooeratin of the script that handle this `send_grid_usage` places an entry into 

your system logs, so you should see somthing like this if your script is being run

`Aug  6 04:04:11 ng2 GridAccounting: Grid usage from  /path/to/gridengine/default/common/acct/pbs/20100730 emailed to grid_pulse@`

You can check what's actually being sent by `grep`'ing those daily files for the string "`Grid_`".

You should see somthing like this:

``` 

sample output - mine is not working at the mo! 

```

But this will only work if syslog is configured to accept user.notice messages.

## Updating the installation

Running the command `vdt-version` may highlight that the components of your VDT installtion are

earlier than the revisions which you would get, were you to do the installtion at that point in time. 

The updated versions may contain fixes for vulnerabilities within the components and you may thus wish

to bring your installation up to a level that the VDT packagers consider current.

Whilst a full re-install will always bring your NG2 up to date with the revisions of VDT packages being distributed at any time, it may be possible to do an update using VDT's own updater, preserving all bar a few local customisations of the deployment.

This document details one such experience [Experiences updating an NGGUMS at VUW](/wiki/spaces/BeSTGRID/pages/3818228975) and may provide some useful background

to such an updating exercise.
