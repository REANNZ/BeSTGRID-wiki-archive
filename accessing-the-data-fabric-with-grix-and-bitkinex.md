# Accessing the Data Fabric with Grix and BitKinex

A client for accessing the Data Fabric from Windows operating systems

# Introduction

The [BitKinex](http://www.bitkinex.com) client can be used to access the BeSTGRID Data Fabric and can handle large files through http proxies, including Microsoft's Internet Security and Acceleration Server. BitKinex doesn't support shibboleth logins or [Grid Certificate](/wiki/spaces/BeSTGRID/pages/3818228570)s directly, but will handle MyProxy logins.

# Prerequisites

In order to set up MyProxy certificates for BitKinex the [Grix](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Grix&linkCreation=true&fromPageId=3818228581) tool will need to be installed, and used to create a MyProxy certificate.

You will need to gather some information, such as your institutes http proxy or web proxy settings before installation.

# Installation

Download the BitKinex client from [here](http://www.bitkinex.com/download) and run the installer.

The installation wizard will prompt you for various settings:

- HTTP Proxy: the host name or IP address of your institutes http proxy e.g. proxy.your.institute.co.nz
- HTTP Port: The port number for the HTTP proxy service e.g. 8080
- Username & Password: If your institute's proxy server requires authentication you will need to put your credentials here.

The installation wizard will go through setting up an initial data connection.

- Select WebDAV or HTTPS connection
- Use the [https://df.bestgrid.org/BeSTGRID/home](https://df.bestgrid.org/BeSTGRID/home) url on port 443
- Use the username and password for the MyProxy certificate that you set up with Grix
