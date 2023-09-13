# GridSphere Tomcat

# GridSphere portal in Tomcat environment 

Here you can find some tips and suggestions to solve problems during installation and running GridSphere portal in Tomcat environment

# Authantication modules priority

The less number in "Configure authentication modules" gridportlet the higher priority.

# Can't connect to X11 window server using ':0' as the value of the DISPLAY variable.


Add a line in the beginning of *$CATALINA_HOME/bin/catalina.sh* startup script: 

>  CATALINA_OPTS="-Djava.awt.headless=true"
