# Administering an NGGUMS

This page follows on from the [Setting_up_a_GUMS_server](setting-up-a-gums-server.md) resource in that it seeks to provide

the information needed to administer your GUMS server once it has been deployed.

Common administrative operations should appear here, along with methodologies for checking

that your GUMS server is functioning as it should.

## Cron Scripts

### Hourly: gumsmanualmap.py

This script will have been installed as part of the Auth Tool deployment

As a job run under the control of the `cron` subsystem, output from it's operation

should appear in `cron logs` or emails from `cron`

Typical output is:

``` 

INFO ----- Parsing /opt/vdt/apache/htdocs/mapfile/mapfile start -----
INFO ----- Parsing /opt/vdt/apache/htdocs/mapfile/mapfile complete -----
INFO ----- Checking GUMS_1_3 database integrity begin ----
INFO ----- Checking for duplicate entries in MAPPING table -----
INFO ----- Checking for duplicate entries in USER table -----
INFO ----- Checking for unmatched entries in MAPPING table -----
INFO ----- Checking for unmatched entries in USER table -----
INFO ----- Checking GUMS_1_3 database integrity complete ----
INFO ----- Remove databases entries for unmapped users start -----
INFO ----- Remove databases entries for unmapped users end -----
INFO ----- Add database entries for mapped users start -----
INFO ----- Add database entries for mapped users end -----

```

The above output is typical because the default debug setting within the script is **2**.

Should you wish to not have any output from the hourly cron script then you can set `debug` to

either *1* or, probably the better option, to **0**, near the end of the script.

At time of writing the last few lines were

``` 

if __name__ == '__main__':

    debug = 2
    log = initLog()
    gridmap = buildGridMapfileDict()
    checkdbIntegrity()
    unmapUsers(gridmap)
    mapUsers(gridmap)

```

### fetch-crl.cron

The script that fetches Certificate Revocation Lists

``` 
/opt/vdt/fetch-crl/share/doc/fetch-crl-2.6.6/fetch-crl.cron
```

runs from the root crontab, four times a day.

The crontab entry is installed by VDT.

You will often see output from this operation where there is an issue with accessing

expected data, eg

``` 

fetch-crl[10258]: 20100802T031308+1200 RetrieveFileByURL: download no data from
http://cygrid.org.cy/CyGridCA/afe55e66.r0

```

## Updating the installation

Running the command `vdt-version` may highlight that the components of your VDT installtion are

earlier than the revisions which you would get, were you to do the installtion at that point in time. 

The updated versions may contain fixes for vulnerabilities within the components and you may thus wish

to bring your installation up to a level that the VDT packagers consider current.

Whilst a full re-install will always bring your NGGUMS up to date with the revisions of VDT packages being distributed at any time, it is possible to do the update using VDT's own updater, which preserves all bar a few local customisations of the deployment.

This document details one such experience [Experiences updating an NGGUMS at VUW](experiences-updating-an-nggums-at-vuw.md)
