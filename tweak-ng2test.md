# Tweak NG2Test

Ng2Test gateway is appeared on the [GOC](http://goc.arcs.org.au/) page.

The following updates have been made:

>  **Updated /etc/ntp.conf: added two ntp ITS servers into*OUR TIMESERVERS** section
>  server truechimer.auckland.ac.nz
>  server truechimer2.auckland.ac.nz

- Started ntpd


>  chkconfig ntpd on
>  service ntpd start
>  chkconfig ntpd on
>  service ntpd start

- Updated /etc/mail/sendmail.mc


>  define('SMART_HOST', 'mailhost.auckland.ac.nz)
>  define('SMART_HOST', 'mailhost.auckland.ac.nz)

- installed make and sendmail-mc packages


>  yum install mail
>  yum install sendmail-mc
>  yum install mail
>  yum install sendmail-mc

- rebuilt sendmail.cf file and restarted sendmail


>  cd /etc/mail 
>  make
>  service sendmail restart
>  cd /etc/mail 
>  make
>  service sendmail restart

- disabled gpm (General Purpose Mouse) service


>  chkconfig gpm off
>  chkconfig gpm off
