# Setting up Ganglia at University of Canterbury

To monitor the gateway virtual machines (and in particular, the GRAM5 gateway ng1.canterbury.ac.nz), I have setup Ganglia - with a monitoring daemon running at each of the virtual machines, and a meta-server and the web application running at ngportal.canterbury.ac.nz.

Ganglia would work out of the box with multicast (and listing all VMs under the "unspecified" cluster).

The changes I have done are thus only to:

- configure the "cluster" information in each of the VMs
- switch the communication from IP multicast to TCP pull from the central server (I didn't want to broadcast to the whole server network).

# Setting up a Ganglia client

- Enable EPEL first (x86_64 or i386)

rpm -Uvh [http://download.fedora.redhat.com/pub/epel/5/x86_64/epel-release-5-3.noarch.rpm](http://download.fedora.redhat.com/pub/epel/5/x86_64/epel-release-5-3.noarch.rpm)

- Install Ganglia monitoring daemon


>  yum install ganglia-gmond
>  yum install ganglia-gmond

- Edit cluster information in /etc/gmond.conf

``` 

cluster {
  name = "UoC grid gateway"
  owner = "BlueFern, University of Canterbury"
  latlong = "S43.52 E172.58"
  url = "http://www.bluefern.canterbury.ac.nz/"
}

```

- Edit  the udp_send_channel and udp_recv_channel to communicate via the local hostname (but not localhost) instead of multicast

``` 

udp_send_channel {
  #mcast_join = 239.2.11.71
  port = 8649
  #ttl = 1
  <b>host = ng1</b>
}

udp_recv_channel { 
  #mcast_join = 239.2.11.71
  port = 8649  
  #bind = 239.2.11.71
  <b>bind = ng1</b>
}   

```

- Enable and start the service


>  chkconfig gmond on
>  service gmond start
>  chkconfig gmond on
>  service gmond start

# Setup the Ganglia meta server and web app

- Install the application (pulls in ganglia-gmetad and php as dependencies)


>  yum install ganglia-web
>  yum install ganglia-web

- Edit /etc/gmetad.conf, comment out the default data_source and list each of the hosts to be monitored as a separate data_source:

``` 

data_source "ng1" 30 ng1
data_source "ng2" 30 ng2
data_source "ng2hpc" 30 ng2hpc
data_source "ng2sge" 30 ng2sge
data_source "nggums" 30 nggums

```

- Enable and start gmetad


>  chkconfig gmetad on
>  service gmetad start
>  chkconfig gmetad on
>  service gmetad start

- Restart Apache (to pick up Ganglia conf and load PHP - a reload is not enough)


>  service httpd restart 
>  service httpd restart 

- Now watch [http://your.ganglia.host/ganglia](http://your.ganglia.host/ganglia)
