# Massey NGPBS Head Node Set Up Notes

# Torque PBS Server 

- Torque PBS already installed on Head Node, seems to be in /opt/torque


>  PBS_HOME=/opt/torque/
>  export PBS_HOME
>  PBS_HOME=/opt/torque/
>  export PBS_HOME

- Made permanent environment variables under /etc/profile.d/pbs-home.sh and .csh as per [my guide](http://antongrid.blogspot.com/2007/08/permanent-environment-variables-red-hat.html).

- Add to /etc/services


>  pbs_server      15000/tcp       # added by Anton
>  pbs_dis         15001/tcp       # added by Anton
>  pbs_dis         15001/udp       # added by Anton
>  pbs_mom         15002/tcp       # added by Anton
>  pbs_mom         15003/udp       # added by Anton
>  pbs_mom         15003/tcp       # added by Anton
>  pbs_sched       15004/tcp       # added by Anton
>  pbs_server      15000/tcp       # added by Anton
>  pbs_dis         15001/tcp       # added by Anton
>  pbs_dis         15001/udp       # added by Anton
>  pbs_mom         15002/tcp       # added by Anton
>  pbs_mom         15003/udp       # added by Anton
>  pbs_mom         15003/tcp       # added by Anton
>  pbs_sched       15004/tcp       # added by Anton

- note - only pbs_server is running on the head node, so maybe don't need to add that other stuff

- $PBS_HOME/server_priv/nodes already has:


>  compute-0-0.local np=8
>  compute-0-1.local np=8
>  compute-0-2.local np=8
>  .
>  .
>  .
>  compute-0-25.local np=8
>  compute-0-0.local np=8
>  compute-0-1.local np=8
>  compute-0-2.local np=8
>  .
>  .
>  .
>  compute-0-25.local np=8

 **Created configuration for pbs_mom in $PBS_HOME/mom_priv/nodes. File did not already exist - do I actually need this?*I doubt it**

>  $pbsserver it040257.massey.ac.nz

- edit /etc/hosts. Changed it040257.massey.ac.nz to ngpbs.massey.ac.nz and added the gateway


>  130.123.244.21  ngpbs.massey.ac.nz      ngpbs
>  130.123.244.20  ng2.massey.ac.nz        ng2
>  130.123.244.21  ngpbs.massey.ac.nz      ngpbs
>  130.123.244.20  ng2.massey.ac.nz        ng2

- database already up

# Remote Submission 

- Assuming queue manager already okay, but added submit permissions for ng2


>  # qmgr
>  Max open servers: 4
>  Qmgr: set server submit_hosts+=ng2.massey.ac.nz
>  # qmgr
>  Max open servers: 4
>  Qmgr: set server submit_hosts+=ng2.massey.ac.nz

- also added this to /opt/torque/pbs.default

- added ng2.massey.ac.nz to /etc/hosts.equiv

- passwordless logins already working

- change /etc/ssh/ssh_config on ngcompute to include


>  EnableSSHKeysign yes
>  HostbasedAuthentication yes
>  EnableSSHKeysign yes
>  HostbasedAuthentication yes

- it now looks a bit weird - like this (maybe it was supposed to go in sshd_config):


>  Host *
>         CheckHostIP             no
>         ForwardX11              yes
>         ForwardAgent            yes
>         StrictHostKeyChecking   no
>         UsePrivilegedPort       no
>         FallBackToRsh           no
>         Protocol                2,1
>         EnableSSHKeysign        yes
>         HostbasedAuthentication yes
>  Host *
>         CheckHostIP             no
>         ForwardX11              yes
>         ForwardAgent            yes
>         StrictHostKeyChecking   no
>         UsePrivilegedPort       no
>         FallBackToRsh           no
>         Protocol                2,1
>         EnableSSHKeysign        yes
>         HostbasedAuthentication yes

- although not specified in vlad's instructions, I changed (just in case) /etc/ssh/sshd_config on ngpbs to include:


>  HostbasedAuthentication yes
>  HostbasedAuthentication yes

- in /etc/mail/sendmail.cf changed the following:


>  O DaemonPortOptions=Port=smtp,Addr=0.0.0.0, Name=MTA
> 1. O DaemonPortOptions=Port=smtp,Addr=127.0.0.1, Name=MTA
>  O DaemonPortOptions=Port=smtp,Addr=0.0.0.0, Name=MTA
> 1. O DaemonPortOptions=Port=smtp,Addr=127.0.0.1, Name=MTA

- looks like pbs might already be starting automatically - didn't want to fiddle with it

- nfs client already working.

# Worker Software 

>  **have not set up /opt/shared with mrbayes yet*TODO**

 **have not arranged for mount points yet as per vlad's guide*TODO**

# MPI 

- looks like mpiexec already working.

- don't want to touch it

>  **note - MPI jobs will not compile on gateway as MPI on the head node is*mvapich-0.9.9**

# Job Accounting/GOC 

- added cron job /etc/cron.d/send_grid_usage.cron and script /usr/local/sbin/send_grid_usage for sending yesterdays accounting to vpac. Should be via email (sendmail)


>  ***TODO** might also need to adjust sendmail to use smtp.massey.ac.nz
>  ***TODO** might also need to adjust sendmail to use smtp.massey.ac.nz

# Fixups 

- Restarting pbs_server produced lots of errors - ACL_HOST 'maui@it040....' etc.

# Static IPs 

- using ngpbs domain name and IP was a mistake - gets mixed up with the hostname it040257
- Rushad will get a static IP for it040257 and then we just need SSH firewall access.

# PBS Telltail 

- Enable Centos-plus repo in /etc/yum.repos.d/CentOS-Base.repo
- install postfix (just in case) and edit /etc/postfix/main.c to add smtp.massey.ac.nz to relayhost
- service postfix start did not work - so maybe dont need postfix
- Import APAC key


>  rpm --import [http://mirror.centos.org/centos/4/os/i386/RPM-GPG-KEY-centos4](http://mirror.centos.org/centos/4/os/i386/RPM-GPG-KEY-centos4) --httpproxy www-cache3.massey.ac.nz
>  rpm --import [http://mirror.centos.org/centos/4/os/i386/RPM-GPG-KEY-centos4](http://mirror.centos.org/centos/4/os/i386/RPM-GPG-KEY-centos4) --httpproxy www-cache3.massey.ac.nz

- Get APAC repository:


>  cd /etc/yum.repos.d
>  wget [http://www.grid.apac.edu.au/repository/dist/APAC-Grid.repo](http://www.grid.apac.edu.au/repository/dist/APAC-Grid.repo)
>  cd /etc/yum.repos.d
>  wget [http://www.grid.apac.edu.au/repository/dist/APAC-Grid.repo](http://www.grid.apac.edu.au/repository/dist/APAC-Grid.repo)

- export proxy
- Install telltail:


>  yum install pbs-telltail
>  yum install pbs-telltail

- edit /usr/local/pbs-telltail/pbs-telltail.RH and change PBS_HOME to /opt/torque
- edit /usr/local/pbs-telltail/pbs-telltail.RH and change REMOTES to submitting machines
- copy file:


>  cp /usr/local/pbs-telltail/pbs-telltail.RH to /etc/rc.d/init.d/pbs-telltail
>  cp /usr/local/pbs-telltail/pbs-telltail.RH to /etc/rc.d/init.d/pbs-telltail

- start services


> 1. on head node
>  chkconfig pbs-logmaker off
>  service pbs-logmaker stop
>  chkconfig pbs-telltail on
>  service pbs-telltail start
> 1. on head node
>  chkconfig pbs-logmaker off
>  service pbs-logmaker stop
>  chkconfig pbs-telltail on
>  service pbs-telltail start
