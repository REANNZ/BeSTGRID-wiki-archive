# Updating a grid gateway

This page documents the update of VDT components on a VDT 2.0.x system, based on the [VDT updater instructions](http://vdt.cs.wisc.edu/releases/2.0.0/vdt-updater-instructions.html).

**NOTE**: This will work only as long as **NO GLOBUS COMPONENTS ARE UPDATED**.  Because the ARCS/APACGrid/BeSTGRID gateway setup customizes many configuration files under /opt/vdt/globus, a full VDT reinstall is REQUIRED when any Globus components changed.  For updates to other components, the following instructions may be followed:

To check the components that do have an update available, run: 

``` 
vdt-version
```

To proceed with the update, at the very minimum:

- Log in as root and 

``` 
cd /opt/vdt
```
- Stop all VDT services:

``` 
vdt-control --off
```
- Install the VDT Updater (if not already installed):


>  export VDTMIRROR=[http://vdt.cs.wisc.edu/vdt_200_cache](http://vdt.cs.wisc.edu/vdt_200_cache)
>  pacman -get $VDTMIRROR:VDT-Updater
>  export VDTMIRROR=[http://vdt.cs.wisc.edu/vdt_200_cache](http://vdt.cs.wisc.edu/vdt_200_cache)
>  pacman -get $VDTMIRROR:VDT-Updater

- If the VDT Updater was installed before, update it with:


>  pacman -update VDT-Updater
>  pacman -update VDT-Updater

 ***Make a complete, exact backup of your complete installation**

>  cp -pr $VDT_LOCATION BACKUP-LOCATION

- or


>  rsync -a $VDT_LOCATION/ BACKUP-LOCATION
>  rsync -a $VDT_LOCATION/ BACKUP-LOCATION

- Run the VDT Updater: 

``` 
vdt/update/vdt-updater
```
- If the update goes well, source a setup script again, just in case the updates affected the contents of the setup script.

``` 
. setup.sh
```
- Run the vdt-post-install script to configure some software:

``` 
vdt-post-install
```
- Then, restart VDT services:

``` 
vdt-control --on
```
