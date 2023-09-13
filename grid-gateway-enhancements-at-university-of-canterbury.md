# Grid gateway enhancements at University of Canterbury

When setting up grid gateways, I have installed a number of minor enhancements over the default ARCS install.  The enhancements have been documented on different pages on this wiki.  This page is where new enhancements should be documented, and should also link to description of existing enhancements.

# Automatic Certificate Updates

VDT 1.8.1 comes with a tool for automatic updates of the IGTF root certificate bundle.  The tool comes in a separate VDT package, `CA-Certificates-Updater`.  This package does not get installed on a default ARCS gateway.  To install the package on an existing gateway, run the following sequence of commands:

>  cd /opt/vdt/
>  . pacman-3.20/setup.sh 
>  export VDTSETUP_CA_CERT_UPDATER=y
>  pacman -pretend-platform linux-rhel-4 -get [http://projects.arcs.org.au/mirror/vdt/vdt_181_cache:CA-Certificates-Updater](http://projects.arcs.org.au/mirror/vdt/vdt_181_cache:CA-Certificates-Updater)
>  vdt-control --on vdt-update-certs

The updater installs a cron job that runs the updater (`/opt/vdt/vdt/sbin/vdt-update-certs-wrapper`) runs every 11 minutes past, and logs to `/opt/vdt/vdt-install.log` (not to standard output mailed by cron).

# Fixing startup and shutdown of gateway services

See my description of the [problem](/wiki/spaces/BeSTGRID/pages/3816950583#Vladimir&#39;sgridnotes-RFTstagingfails), a fix to [startup order](/wiki/spaces/BeSTGRID/pages/3816950583#Vladimir&#39;sgridnotes-Fixingstartuporder), and a fix for [correct shutdown](/wiki/spaces/BeSTGRID/pages/3816950583#Vladimir&#39;sgridnotes-Fixingshutdown)

# PBS job tagging

See [PBS job tagging](/wiki/spaces/BeSTGRID/pages/3816950918)

# StartUp VO: limit wall clock time

I have decided to support the StartUp VO on ng2.canterbury.ac.nz.

To limit the maximum wall clock time, I am using the pbs.pm snippet courtesy of Sam Morrison:

> 1. Prevent grid-startup job length - Sam Morrison
>     if( ($ENV{'LOGNAME'} eq "grid-startup") &&
>         (($wall_time>30)||($wall_timeh1. 0)) ) {
>         $wall_time = 30;    
>     } Non-canned executables h1. To allow executing files uploaded as a part of the job, add a line into pbs.pm that would try to add *execute* permissions to the executable from within the job script: add the following after the line with `print JOB "$modulestring";`: 
> ``` 
> print JOB "chmod +x ".$description->executable()." 2>/dev/null\n"; #ARCS-Specific perm'n-fix 
> ```
>  PBS job script debugging h1. To enable grid developers to see the PBS job script generated, the following snippet (credits: Graham Jenkins) was added to pbs.pm (right after `close(JOB);`)

``` 

    if ($description->emaildebug() ne '') {          # APAC-Specific 'emaildebug' extension
      my $em=$description->emaildebug();
      `/usr/bin/Mail -s "Job-Script.\$\$" $em < $pbs_job_script_name || :`
    }

```

The way to use it is to include an `emaildebug` extension in the job description, containing the email address where the PBS job script should be sent:

``` 

<!-- Usage: globusrun-ws -submit -s -S -F ng2 -Ft PBS -f gt4-jobname.rsl -->
<job>
  <executable>/usr/bin/env</executable>
  <jobType>single</jobType>
  <extensions>
    <emaildebug>email@address.com</emaildebug>
  </extensions>
</job>

```

This snippet was installed at:

- ng2.canterbury.ac.nz
- ng2hpc.canterbury.ac.nz (LoadLeveler)
- ng2sge.canterbury.ac.nz (SGE)
- ng2maggie.otago.ac.nz

- A different approach to this was requested by Sean Flemming (iVEC) to instead copy the job-script into the job working directory:

Add the following snippet right below the `print JOB "$modulestring";` line in `pbs.pm`.

``` 

    $pbs_debug_file = $description->pbsdebug();
    if ($pbs_debug_file ne "")
    {
        print JOB "\n#pbsdebug\n";
        print JOB "cp \$0 '$pbs_debug_file'\n";
    }

```
- This extension is used with

``` 

<job>
  <executable>/usr/bin/env</executable>
  <jobType>single</jobType>
  <extensions>
    <pbsdebug>true</pbsdebug>
  </extensions>
</job>

```

 Nagios monitoring ==

This is to let a Nagios server (the ARCS Nagios server, `nagios.arcs.org.au`) monitor individual hosts (VMs) on the grid gateway.

Steps to be taken **before** adding the hosts to Nagios:

- Open TCP port 5666 (Nagios NRPE plugin)
- Open the firewall to let incoming ICMP ECHO REQUEST (ping) come through.

Now the host can be monitored with Nagios (PING).

To allow additional monitoring, install the NRPE Nagios plugin.  Steps (based on [https://projects.arcs.org.au/trac/systems/wiki/HowTo/NagiosNRPE):](https://projects.arcs.org.au/trac/systems/wiki/HowTo/NagiosNRPE):)

- Enable EPEL repository:


>  rpm -Uivh [http://download.fedora.redhat.com/pub/epel/5/i386/epel-release-5-3.noarch.rpm](http://download.fedora.redhat.com/pub/epel/5/i386/epel-release-5-3.noarch.rpm)
>  rpm -Uivh [http://download.fedora.redhat.com/pub/epel/5/i386/epel-release-5-3.noarch.rpm](http://download.fedora.redhat.com/pub/epel/5/i386/epel-release-5-3.noarch.rpm)

- Install yum-priorities


>  yum -y install yum-priorities
>  yum -y install yum-priorities


>  allowed_hosts=202.158.218.224
>  allowed_hosts=202.158.218.224

- Enable and start NRPE:


>  chkconfig nrpe on
>  service nrpe start
>  chkconfig nrpe on
>  service nrpe start


Plan for services to be monitored at Canterbury


>  grid.canterbury.ac.nz
>  ngcompute.canterbury.ac.nz
>  ngdata.canterbury.ac.nz
>  grid.canterbury.ac.nz
>  ngcompute.canterbury.ac.nz
>  ngdata.canterbury.ac.nz

- Services: ping, ssh, check_all_disks, check_swap, check_load on ALL
	
- pool_accounts on NGGUMS
- no NRPE for hpcgrid1
- check http(s) on ngportal,nggums
- check http(s):8443 on ng2,ng2hpc,ng2sge,nggums

- Detailed service list:

Hosts to be monitored at Canterbury are:
- ng1.canterbury.ac.nz, check_all_disks, check_swap, check_load
- nggums.canterbury.ac.nz: ping, ssh, check_all_disks, check_swap, check_load + check_https(443), check_pool_accounts
- ng2.canterbury.ac.nz: ping, ssh, check_all_disks, check_swap, check_load, check_https(8443)
- ng2hpc.canterbury.ac.nz: ping, ssh, check_all_disks, check_swap, check_load, check_https(8443)
- ng2sge.canterbury.ac.nz: ping, ssh, check_all_disks, check_swap, check_load, check_https(8443)
- ngportal.canterbury.ac.nz: ping, ssh, check_all_disks, check_swap, check_load, check_https(443)
- ucgridgw.canterbury.ac.nz: ping, ssh, check_all_disks, check_swap, check_load
- hpcgrid1.canterbury.ac.nz: ping, ssh
- ngcompute.canterbury.ac.nz: ping, ssh, check_all_disks, check_swap, check_load
- grid.canterbury.ac.nz: ping, ssh, check_all_disks, check_swap, check_load
- ngdata.canterbury.ac.nz: ping, ssh, check_all_disks, check_swap, check_load, check_https(443)
