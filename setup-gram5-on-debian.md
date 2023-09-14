# Setup GRAM5 on Debian

work in progress.

Things that do work:

- gridftp
- gatekeeper

Problems:

- repository does not work with apt-file command, so cannot figure out package contents
- PRIMA or LCMAPS still need to be compiled
- configuration files are missing and need to be prepared by hand
- SEG LRM-specific parts are missing
- globus environment scripts, such as globus-user-env.sh are missing

Related CentOS install is documented at [Setup GRAM5 on CentOS 5](/wiki/spaces/BeSTGRID/pages/3818228506).

# Prerequisites

Install some packages for ease of administration:

``` 

 apt-get install sudo emacs openssh-server apt-file psmisc strace
 apt-file update

```

For NTP:

``` 

apt-get install ntp  ntpdate
# set servers in /etc/ntp.conf

```

Packages for LDAP Authentication:

``` 

apt-get install ldap-utils libpam-ldap libnss-ldap nscd
# don't worry about GUI setup, just edit /etc/libnss-ldap.conf in the end.

```

list of native packages for globus is maintained at [http://www.grid.tsl.uu.se/repos/](http://www.grid.tsl.uu.se/repos/)

The following needs to be added to /etc/apt/sources.list

``` 

deb http://www.grid.tsl.uu.se/repos/globus/debian lenny main
deb-src http://www.grid.tsl.uu.se/repos/globus/debian lenny main

```

# Install and Configure GridFTP server

out of the box works with grid-mapfile.

``` 

apt-get install xinetd globus-gridftp-server-progs
cat >> /etc/services <<EOF
gsiftp          2811/tcp                        # GSI FTP
EOF

```

xinetd configuration:

``` 

service gsiftp
{
instances               = 100
socket_type             = stream
wait                    = no
user                    = root
env                     += GLOBUS_TCP_PORT_RANGE=40000,41000
server = /usr/sbin/globus-gridftp-server
server_args = -i -aa -l ${prefix}/var/log/globus-gridftp.log
server_args += -d WARN
log_on_success          += DURATION
nice                    = 10
disable                 = no
}

```

# Install And Configure GRAM

``` 

 apt-get install globus-gram-job-manager globus-scheduler-event-generator-progs

```

## Fork Jobs

will start with fork adapter as it is easier to configure

# Install and Configure LCMAPS 

incomplete.

could not find packages for that one, so had to install from source:

``` 

wget 'http://isscvs.cern.ch:8180/cgi-bin/cvsweb.cgi/fabric_mgt/gridification/lcmaps/lcmaps.tar.gz?cvsroot=lcgware;tarball=1'

```
