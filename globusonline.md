# GlobusOnline

GlobusOnline is a service that allows you to transfer data between remote sites via a web-interface, ssh or a RESTful API.  

Basically, it works so that one creates endpoints which refer to gridftp servers, activates them via a MyProxy credential and then kicks off a file-transfer between two of them.

[Documentation](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Documentation&linkCreation=true&fromPageId=3816950963)

The website for GlobusOnline can be found at: [http://www.globusonline.org/](http://www.globusonline.org/)

Documentation for the ssh cli access: [http://www.globusonline.org/docs](http://www.globusonline.org/docs)

Documentation for the (still in development) RESTful API: [https://transfer.api.globusonline.org/](https://transfer.api.globusonline.org/)

[gopy](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=gopy&linkCreation=true&fromPageId=3816950963)

*gopy* is a python wrapper for the ssh cli commands that comes with a benchmark suite that can be used to monitor transfer speeds while sweeping transfer options (like no of parallel transfers). 

The project page for *gopy* is: [https://github.com/makkus/gopy](https://github.com/makkus/gopy) , this page also contains usage information.
