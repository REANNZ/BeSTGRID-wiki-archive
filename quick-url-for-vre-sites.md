# Quick URL for VRE sites

# Problem: Complicated / Ugly Sakai site web address

Sometimes a research group might want a simple website address to share with others, so they can easily remember how to access their site.

In Sakai a full link to a site looks like

>  [http://sakai.bestgrid.org/portal/site/bda98ec8-ebbe-4b10-8047-7f7ad4cf4e85](http://sakai.bestgrid.org/portal/site/bda98ec8-ebbe-4b10-8047-7f7ad4cf4e85)

Using this link allows registered users to enter directly into the site Home page after providing their login credentials. But such URL is very complicated to remember. 

# Solution - Simple URL

Our system administrators can create a simple url for your site. Contact us to request one for your site.

## Implementation

To simplify the quick URL there is an approach inside Tomcat structure (Tomcat is a container for Sakai) to create Virtual Hosts. Administrator of Sakai/Tomcat server in that case should do the following:

>  **Add into ****[Engine](http://tomcat.apache.org/tomcat-5.5-doc/config/engine.html)**** section of a file**$CATALINA_HOME/conf/server.xml* [Host](http://tomcat.apache.org/tomcat-5.5-doc/config/host.html) element:

``` 

 <Engine name "Catalina" defaultHost="localhost">
    <Host 
       name="vretest" 
       appBase="webapps/vretest">
    </Host>
 </Engine>

```

- Create a folder for the new virtual host:


>  mkdir $CATALINA_HOME/webapps/vretest
>  mkdir $CATALINA_HOME/webapps/vretest

- Create a file **$CATALINA_HOME/webapps/vretest/index.html** with a content:

``` 

 <html>
   <head>
     <meta http-equiv="refresh" content="0;url=/portal/site/bda98ec8-ebbe-4b10-8047-7f7ad4cf4e85">
   </head>
   <body>
     Redirecting to VRE Test site...
   </body>
 </html>

```
- Create a folder under **$CATALINA_HOME/conf/Catalina** corresponding to the new virtual host:


>  mkdir $CATALINA_HOME/conf/Catalina/vretest
>  mkdir $CATALINA_HOME/conf/Catalina/vretest

- Create a file **$CATALINA_HOME/conf/Catalina/vretest/ROOT.xml** with a content:

``` 

 <Context docBase="${catalina.home}/webapps/vretest"
 </Context>

```

Now it's possible to open VRE Test site using much easier URL like this:

>  [http://sakai.bestgrid.org/vretest](http://sakai.bestgrid.org/vretest)

This approach to create virtual hosts doesn't need Tomcat/Sakai restarting.
