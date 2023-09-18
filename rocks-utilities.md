# Rocks Utilities

# Locations

rocks utility invokes commands written in python, located at /opt/rocks/lib/python2.4/site-packages/rocks/commands.

Every command has its own directory with source code located at _*init*_.py 

So for example 

>  rocks list host profile

Is located at opt/rocks/lib/python2.4/site-packages/rocks/commands/list/host/profile/_*init*_.py

# Sharing across compute nodes

[Sharing Configuration Files With 411 Service](http://vilkas.vgtu.lt/rocks-documentation/4.3/service-411.html) (the same works with 5.0)

[Sharing Applications](http://www.rocksclusters.org/roll-documentation/base/5.0/customization-adding-packages.html)

# Scripts

**insert-ethers** can be given additional parameters and set to run in batch mode. For example:

>  insert-ethers --hostname="power-0-0" --rack=0 --rank=0 --cpus=1 --appliance="Power Units" --mac="00:30:48:97:fb:e5" --device="None" --module="None" --ipaddr="10.0.1.6" --netmask="255.0.0.0" --norestart --batch --verbose

**cluster-fork** is useful to automate installation of software not available on rolls, and other administration tasks.

Examples: 

> 1. print network configuration of every node
>  cluster-fork ifconfig
> 2. print "hello" on all nodes compute-1-x (query runs against [Rocks Database](rocks-database.md))
>  cluster-fork -query="select name from nodes where name like 'compute-1%'" echo hello
> 3. run job in background
>  cluster-fork --bg echo hello

script to propagate updates from yum to compute nodes.

stolen from rocks mailing list, author Travis Daygale.

[https://lists.sdsc.edu/pipermail/npaci-rocks-discussion/2007-May/025234.html](https://lists.sdsc.edu/pipermail/npaci-rocks-discussion/2007-May/025234.html)

>  #!/bin/bash

> 1. this script copies packages cached by yum so that the rocks distro can be updated too (head node rev levels ! = rocks distro rev levels)
> 2. there might be better ways to do this, but for now...

> 1. Change this as necessary:
>  RocksDistro=/home/install/contrib/4.2.1/x86_64/RPMS/

>  if [\! -d $RocksDistro]
>  then
>  echo "No directory $RocksDistro, are you sure this is a rocks node?"
>  echo "No changes made, aborting"
>  exit
>  fi

>  for yumcache in `find /var/cache/yum/ -name packages -type d -print`
>  do
>  cd $yumcache
>  tar cf - . | (cd $RocksDistro; tar xf -)
>  echo "Copied all packages from $yumcache to $RocksDistro"
>  done

>  echo "Recreating the Rocks distro using rocks-dist"
>  cd /home/install
>  /opt/rocks/bin/rocks-dist dist

To re-install all compute nodes:

>   cluster-fork /boot/kickstart/cluster-kickstart

To synchronize users on compute nodes:

>  rocks-user-sync 

To synchronize all the changes in cluster database:

>  rocks sync config

Script to install new roll on existing cluster (given for bio roll, but others are similar)

>   su - root
>   mount -o loop bio.iso /mnt/cdrom
>   cd /home/install
>   rocks-dist --install copyroll
>   umount /mnt/cdrom
>   rocks-dist dist
>   kroll bio | bash
>   init 6
>   cluster-fork /boot/kickstart/cluster-kickstart

Useful torque commands:

>  qsub
>  qstat

Rocks example script to submit job via Grid engine (from Rocks manual).

``` 

 #!/bin/bash
 #$ -S /bin/bash
 #
 # set the P4_GLOBMEMSIZE
 #$ -v P4_GLOBMEMSIZE=10000000
 #
 # Set the Parallel Environment and number of procs.
 #$ -pe mpi 2 
 # Where we will make our temporary directory.
 BASE="/tmp" 
 #
 # make a temporary key
 #
 export KEYDIR=`mktemp -d $BASE/keys.XXXXXX`
 #
 # Make a temporary password.
 # Makepasswd is quieter, and presumably more efficient.
 # We must use the -s 0 flag to make sure the password contains no quotes.
 #
 if [ -x `which mkpasswd` ]; then
 	export PASSWD=`mkpasswd -l 32 -s 0`
 else
 	export PASSWD=`dd if=/dev/urandom bs=512 count=100 | md5sum | gawk '{print $1}'`
 fi
 /usr/bin/ssh-keygen -t rsa1 -f $KEYDIR/tmpid -N "$PASSWD"
 cat $KEYDIR/tmpid.pub >> $HOME/.ssh/authorized_keys
 #
 # make a script that will run under its own ssh-agent 
 #
 cat > $KEYDIR/launch-script <<"EOF"
 #!/bin/bash
 expect -c 'spawn /usr/bin/ssh-add $env(KEYDIR)/tmpid' -c \
 	'expect "Enter passphrase for $env(LOGNAME)@$env(HOSTNAME)" \
 		{ send "$env(PASSWD)\n" }' -c 'expect "Identity"' 
 echo
 
 #
 # Put your Job commands here.
 #
 #------------------------------------------------ 
 /usr/bin/mpirun -np $NSLOTS -machinefile $TMP/machines \
 	/opt/hpl/openmpi-hpl/bin/xhpl
 
 #/opt/mpich/gnu/bin/mpirun -np $NSLOTS -machinefile $TMP/machines \
 	#/opt/hpl/mpich-hpl/bin/xhpl
 
 #------------------------------------------------
 EOF
 chmod u+x $KEYDIR/launch-script
 # 
 # start a new ssh-agent from scratch -- make it forget previous ssh-agent
 # connections
 #
 unset SSH_AGENT_PID
 unset SSH_AUTH_SOCK 

```

# Compute nodes configuration

The compute nodes are bootstraped with redhat kickstart script that controls how the questions during OS install

are answered, and runs some pre and post install scripts.

To see this script, execute:

``` 

 dbreport kickstart <nodename>

```

# Swaping interfaces on head node during the install

Execute this when booting from CD:

>  frontend ksdevice=eth0

see [http://www.centos.org/docs/4/html/rhel-sag-en-4/s1-kickstart2-startinginstall.html](http://www.centos.org/docs/4/html/rhel-sag-en-4/s1-kickstart2-startinginstall.html)

# Rocks Database

[Rocks Database](rocks-database.md)
