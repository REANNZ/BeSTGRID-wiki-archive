# Customising Sakai

# Configurations and Localisations

- [How to set up a quick URL to VRE sites](quick-url-for-vre-sites.md)
- [How to configure Sakai to store uploaded files on the filesystem](store-files-on-filesystem.md)

# Customising the Sakai skin

The default Sakai skin is:

>  /opt/tomcat/webapps/library/skin/default/
>  access.css
>  images/
>  portal.css
>  tool.css

## Changing the default Sakai Logo

The locations for the files are:

- Logo image file

/opt/tomcat/webapps/library/skin/default/images/logo_inst.gif
- CSS reference to logo

/opt/tomcat/webapps/library/skin/default/tool.css


>  .login td.logo{
>         width: 11em;
>         background:#fff url(images/logo_inst.gif) 1em 1em no-repeat
>  }
>  .login td.logo{
>         width: 11em;
>         background:#fff url(images/logo_inst.gif) 1em 1em no-repeat
>  }

- note

the sakai logo name seems to be hardcoded, so changing the default skin must conform to the naming convention

***Changing the default Sakai CSS skin***

>  portal.css
>  portal.css

Change the below background line to change the strong blue default tab containing projects

>  /**PART 4 - SITE NAVIGATION - children of #siteNavBlock**/
>  /*outer wrapper for the site navigation blocks - it is a class,not an id because
>  it can be overloaded with other values  having to do w
>  so for example div class="tabHolder workspace" so that different site types can 
>  be treated differently via inheritance - children ar
>  .siteNavWrap{
>         width: 100%;
>         background: #09c url(images/sitenavback.jpg) top left repeat-x;
>         padding: 0;
>         margin: 0;
>         float: left;
>         border-top: 1px solid #09c;
>         clear:both;
>  }

and remember to change the link colours too:

>  /**the current sites' link**/
>  #siteLinkList .selectedTab a,
>         #siteLinkList .selectedTab a:link,
>         #siteLinkList .selectedTab a:visited,
>         #siteLinkList .selectedTab a:hover{
>         color: #000;
>         cursor: text;
>         text-decoration: none;
>  }

 /**links to other sites**/

>  #siteLinkList a,#siteLinkList a:link,#siteLinkList a:visited{
>         color: #fff;
>         padding: 2px 6px 2px 4px;
>         text-decoration: underline;
>         border-right: 1px solid #fff;
>  }

 /**hover state for links to other sites**/

>  #siteLinkList a:hover{
>         color: #fff;
>         text-decoration: none;
>  }

## Applying CSS Changes in brief

- Go to /usr/local/tomcat/webapps/library/skin/default
- This is where you'll find:
	
- the images directory
- access.css
- portal.css
- tool.css
- Most of the CSS styles are effected by portal.css - this is the file that needs to be updated.
- Upload the updated portal.css to /usr/local/tomcat/webapps/library/skin/default
- Upload the images to /usr/local/tomcat/webapps/library/skin/default/images
