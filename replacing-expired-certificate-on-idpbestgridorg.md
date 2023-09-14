# Replacing expired certificate on idp.bestgrid.org

At attempt to login via BeSTGRID OpenIdP provider users gets a Shibboleth error message in their browser.

Errors in **www.bestgrid.org:/var/log/shibboleth/shibd.log**

>  2008-09-02 10:57:27 ERROR OpenSSL [11148](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=11148&linkCreation=true&fromPageId=3818228627) sessionNew: path validation failure: certificate has expired
>  2008-09-02 10:57:27 ERROR Shibboleth.ShibBrowserProfile [11148](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=11148&linkCreation=true&fromPageId=3818228627) sessionNew: unable to verify signed profile response
>  2008-09-02 10:57:27 ERROR shibd.Listener [11148](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=11148&linkCreation=true&fromPageId=3818228627) sessionNew: caught exception while creating session: unable to verify signed profile response

Errors in **idp.bestgrid.org:/usr/local/shibboleth-idp/logs/shib-error.log**

>  2008-09-02 08:59:24,502 DEBUG [IdP](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=IdP&linkCreation=true&fromPageId=3818228627) -685926013                          - Attempting to match X509 certificate.
>  2008-09-02 08:59:24,502 DEBUG [IdP](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=IdP&linkCreation=true&fromPageId=3818228627) -685926013                          - Inline validation was unsuccessful.  Attmping PKIX...

Host certificate on idp.bestgrid.org is in folder:

>  /usr/local/shibboleth-idp/etc/certs

Host certificate is represented by two files:

>  /usr/local/shibboleth-idp/etc/certs/idp.bestgrid.org.key - private key
>  /usr/local/shibboleth-idp/etc/certs/idp.bestgrid.org.key - certificate

They were backed up in folder

>  /usr/local/shibboleth-idp/etc/certs/old

and fresh files were copied in this folder. To allow new certificate to take an effect the following command should be issued under root account:

>  su shib
>  /usr/local/tomcat/bin/shutdown.sh
>  /usr/local/tomcat/bin/startup.sh
>  service ldap restart

After restarting the following errors were found in **idp.bestgrid.org:/usr/local/shibboleth-idp/logs/shib-error.log**

>  2008-09-02 15:22:17,232 DEBUG [IdP](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=IdP&linkCreation=true&fromPageId=3818228627) Core - Attempting to load private key from file file:/usr/local/shibboleth-idp/etc/certs/idp.bestgrid.org.key
>  2008-09-02 15:22:17,232 ERROR [IdP](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=IdP&linkCreation=true&fromPageId=3818228627) Core - Could not load credential from specified file (file:/usr/local/shibboleth-idp/etc/certs/idp.bestgrid.org.key): java.io.FileNotFoundException: /usr/local/shibboleth-idp/etc/certs/idp.bestgrid.org.key (Permission denied)
>  2008-09-02 15:22:17,233 ERROR [IdP](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=IdP&linkCreation=true&fromPageId=3818228627) Core - Could not load credential, skipping: Unable to load private key.

Permissions for **/usr/local/shibboleth-idp/etc/certs/idp.bestgrid.org.key** have been updated:

>   chmod a+r /usr/local/shibboleth-idp/etc/certs/idp.bestgrid.org.key

After restarting Tomcat and ldap the following errors appeared in **idp.bestgrid.org:/usr/local/shibboleth-idp/logs/shib-error.log**

>  2008-09-02 15:41:42,661 ERROR [IdP](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=IdP&linkCreation=true&fromPageId=3818228627) Core - Could not load credential from specified file (file:/usr/local/shibboleth-idp/etc/certs/idp.bestgrid.org.key): java.io.EOFException: EOF encountered in middle of object
>  2008-09-02 15:41:42,661 ERROR [IdP](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=IdP&linkCreation=true&fromPageId=3818228627) Core - Could not load credential, skipping: Unable to load private key.

Those errors mean that something wrong with a pair key/cert but they were non-informative. Checking modulus of both files shown that they are the same:

>  openssl x509 -in idp.bestgrid.org.crt -noout -modulus
>  openssl rsa -in idp.bestgrid.org.key -noout -modulus

After googling a suggestion that a key file didn't have a passphrase was found. Setting a passphrase to previously defined for OpenIdP server:

>  openssl rsa -in idp.bestgrid.org.key -des3 -out idp.bestgrid.org.key

It helped. After restarting Tomcat and ldap OpenIdP server started to work for Wiki logins.
