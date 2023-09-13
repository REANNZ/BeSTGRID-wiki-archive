# GLobus PBS Integration

**pbs.pm** is a script that converts globus RSL description into a PBS script.

In VDT it is located in /opt/vdt/globus/lib/perl/Globus/GRAM/JobManager/pbs.pm

( I modified it slightly on test test gateway to save the resulting script into /tmp/PBS directory)

PBS specific extensions are handled with **ExtensionsHandler.pm** script.

In VDT it is /opt/vdt/globus/lib/perl/Globus/GRAM/ExtensionsHandler.pm

To specify that the file system is shared and there is no need to scp files edit /opt/torque/mom_priv/config on compute nodes:

>  $usecp *:/home /home
