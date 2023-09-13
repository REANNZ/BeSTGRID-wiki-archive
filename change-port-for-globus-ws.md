# Change port for Globus-ws

On default Globus container uses non-standard port 9443. Standard port 8443 left free to use for Apache/Tomcat. If Globus runs as a standalone container, it's better to change port for it to standard one (8443). 

vdt-control uses scripts in **/opt/vdt/post-install** directory to register and start services on a command

>  vdt-control -on 

and to stop and unregister services on a command 

>  vdt-control -off

Only editing scripts in /opt/vdt/post-install will take effect forever. Otherwise (if edit scripts in /etc/init.d directory) they were overwritten by vdt-control script during startup.
