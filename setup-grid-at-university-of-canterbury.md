# Setup Grid at University of Canterbury

The `Grid` virtual machine is a system with client part of Globus Toolkit installed, which the users can use to submit jobs to the grid.  The system also has PBS client tools installed, which allows users to submit jobs locally to the BeSTGRID prototype cluster.  For general setup, we follow the rules for [Vladimir__Bootstrapping a virtual machine](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Vladimir__Bootstrapping%20a%20virtual%20machine&linkCreation=true&fromPageId=3816950580)

# Setup client PBS

- Get Torque client binaries - follow [Vladimir__Setup NGCompute#Setup PBS](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Vladimir__Setup%20NGCompute&linkCreation=true&fromPageId=3816950580)
- add to `/etc/services`

>   pbs             15000/tcp       # added by Vladimir Mencl
>   pbs_dis         15001/tcp       # added by Vladimir Mencl
>   pbs_dis         15001/udp       # added by Vladimir Mencl
>   pbs_mom         15002/tcp       # added by Vladimir Mencl
>   pbs_mom         15003/udp       # added by Vladimir Mencl
>   pbs_mom         15003/tcp       # added by Vladimir Mencl
>   pbs_sched       15004/tcp       # added by Vladimir Mencl

- compile PBS


>   ./configure --disable-mom --disable-server
>   make
>   make install
>   ./configure --disable-mom --disable-server
>   make
>   make install

- configure server name: `/var/spool/torque/server_name`


>   ngcompute.canterbury.ac.nz
>   ngcompute.canterbury.ac.nz

- allow remote job submission at `ngcompute`

- allow `ngcompute` to scp results back - see [Vladimir__Setup NGCompute#Permit grid and ng2 to submit jobs to ngcompute](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Vladimir__Setup%20NGCompute&linkCreation=true&fromPageId=3816950580)

- allow incoming mail: In `/etc/mail/sendmail.cf` change the following:


>  O DaemonPortOptions=Port=smtp,Addr=0.0.0.0, Name=MTA
> 1. O DaemonPortOptions=Port=smtp,Addr=127.0.0.1, Name=MTA
>  O DaemonPortOptions=Port=smtp,Addr=0.0.0.0, Name=MTA
> 1. O DaemonPortOptions=Port=smtp,Addr=127.0.0.1, Name=MTA

- 
- Reason: PBS occasionally send email back to submitting user.

# Install LAM (to compile)

http_proxy=[http://gridws1:3128](http://gridws1:3128) yum install lam

# Setup NFS shared homes

## Configuration

- `/etc/exports`:


>   /export         grid.canterbury.ac.nz(rw,async,no_root_squash) ngcompute.canterbury.ac.nz(rw,async,no_root_squash) ng2.canterbury.ac.nz(rw,async,no_root_squash)
>   /export         grid.canterbury.ac.nz(rw,async,no_root_squash) ngcompute.canterbury.ac.nz(rw,async,no_root_squash) ng2.canterbury.ac.nz(rw,async,no_root_squash)

- `/etc/fstab` (and same on `ngcompute` and `ng2`):


>   grid.canterbury.ac.nz:/export/home      /home   nfs     fg,retry=20,hard 0       0
>   grid.canterbury.ac.nz:/export/opt/shared        /opt/shared     nfs     fg,retry=20,hard        0       0
>   grid.canterbury.ac.nz:/export/home      /home   nfs     fg,retry=20,hard 0       0
>   grid.canterbury.ac.nz:/export/opt/shared        /opt/shared     nfs     fg,retry=20,hard        0       0

## Services

When bootstrapping a virtual machine, a lot of services was turned of.  The following services must be turned on on an NFS server:

>  chkconfig portmap on
>  chkconfig nfs on
>  chkconfig nfslock on
>  chkconfig rpcidmapd on

>  chkconfig netfs on

>  service portmap start
>  service nfs start
>  service nfslock start
>  service rpcidmapd start

>  service netfs start

As some of the exported directories are mounted locally, the starting order has to be changed to start NFS server before netfs: changing `/etc/rc.d/init.d/nfs` to change the start order from 60 to 20 (must start before netfs @ 25) and kill order from 20 to 80 (must kill after netfs @ 75).

> 1. chkconfig: - 20 80
> 	
> 1. 
> 1. chkOLDconfig: - 60 20

To put these changes into effect, do:

>  chkconfig nfs reset
>  chkconfig nfs on

## Machine startup dependencies

Note that in order for these shares to be available, `grid` must be started before `ng2` and `ngcompute`.  This has been achieved with lexicographical ordering of virtual machine (config file) names, and xendomains was [modified to use reverse shutdown order](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Vladimir__Setup%20XenHost&linkCreation=true&fromPageId=3816950580).

For unknown reason, even 

>   mount -o fg,retry=999,retrans=200 grid.canterbury.ac.nz:/export/home /home/

fails with

>   mount: mount to NFS server 'grid.canterbury.ac.nz' failed: System Error: No route to host.

(instead of waiting indefinitely).
