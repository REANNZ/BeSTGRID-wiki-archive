# Configuring Dekiwiki for multiple tenants

[Dekiwiki](http://www.mindtouch.com/) is a wiki system which among others supports multiple tenants - virtual wiki sites within one system.

I have configured a Dekiwiki instance running at [http://dekiwiki.canterbury.ac.nz/](http://dekiwiki.canterbury.ac.nz/) to support multiple tenants - namely:

- Library wiki: [http://librarywiki.canterbury.ac.nz/](http://librarywiki.canterbury.ac.nz/)
- IT wiki: [http://itwiki.canterbury.ac.nz/](http://itwiki.canterbury.ac.nz/)
- UCTL wiki: [http://uctlwiki.canterbury.ac.nz/](http://uctlwiki.canterbury.ac.nz/)

To configure the multiple tenants, I followed the [Multi-Tenant Setup Guide](http://wiki.opengarden.org/User:PeteE/Multi-Tenant_Setup) at [OpenGarden](http://wiki.opengarden.org/), the self-help site for Dekiwiki.

# Setting up multiple tenants

Setting up the tenant wikis is just a few steps:

- Create a directory for attachements

``` 
mkdir /var/www/deki-hayes/attachments-{librarywiki,uctlwiki,itwiki}
```
- Create the database for each of the wikis:

``` 

/var/www/deki-hayes/maintenance/createdb.sh --dbName librarywikidb \
 --dbAdminUser root --dbAdminPassword DbAdminPassword --dbServer localhost \
 --dbWikiUser wikiuser --wikiAdmin Admin \
 --wikiAdminPassword WikiAdminPassword \
 --wikiAdminEmail robin.harrington@canterbury.ac.nz \
 --storageDir /var/www/deki-hayes/attachments-librarywiki

```
- Create a configuration entry for the wiki in the `wikis` section in `/etc/dekiwiki/mindtouch.deki.startup.xml`:
	
- Copy the default entry, and change `id`, `host`, and `db-catalog` entries:

``` 

        <config id="librarywiki">
          <host>librarywiki</host>
          <host>librarywiki.canterbury.ac.nz</host>

          <db-server>localhost</db-server>
          <db-port>3306</db-port>
          <db-catalog>librarywikidb</db-catalog>
          <db-user>wikiuser</db-user>
          <db-password hidden="true">WikiUserPassword</db-password>
          <db-options>pooling=true; Connection Timeout=5; Connection Lifetime=30; Protocol=socket; Min Pool Size=2; Max Pool Size=50; Connection Reset=false;character set=u
tf8;ProcedureCacheSize=25;Use Procedure Bodies=true;</db-options>
        </config>

        <config id="uctlwiki">
          <host>uctlwiki</host>
          <host>uctlwiki.canterbury.ac.nz</host>

          <db-server>localhost</db-server>
          <db-port>3306</db-port>
          <db-catalog>uctlwikidb</db-catalog>
          <db-user>wikiuser</db-user>
          <db-password hidden="true">WikiUserPassword</db-password>
          <db-options>pooling=true; Connection Timeout=5; Connection Lifetime=30; Protocol=socket; Min Pool Size=2; Max Pool Size=50; Connection Reset=false;character set=u
tf8;ProcedureCacheSize=25;Use Procedure Bodies=true;</db-options>
        </config>

        <config id="itwiki">
          <host>itwiki</host>
          <host>itwiki.canterbury.ac.nz</host>

          <db-server>localhost</db-server>
          <db-port>3306</db-port>
          <db-catalog>itwikidb</db-catalog>
          <db-user>wikiuser</db-user>
          <db-password hidden="true">WikiUserPassword</db-password>
          <db-options>pooling=true; Connection Timeout=5; Connection Lifetime=30; Protocol=socket; Min Pool Size=2; Max Pool Size=50; Connection Reset=false;character set=u
tf8;ProcedureCacheSize=25;Use Procedure Bodies=true;</db-options>
        </config>

```

- Configure wiki databases in `LocalSettings.php` so that the update scripts knows about the databases and can apply database updates to each tenant wiki:

``` 

$wgWikis = array(
         'testtenantwiki.canterbury.ac.nz' => array(
                 'db-server' => 'localhost',
                 'db-port' => '3306',
                 'db-catalog' => 'testtenantwikidb',
                 ),
         'dekiwiki.canterbury.ac.nz' => array(
                 'db-server' => 'localhost',
                 'db-port' => '3306',
                 'db-catalog' => 'wikidb',
                 ),
         'librarywiki.canterbury.ac.nz' => array(
                 'db-server' => 'localhost',
                 'db-port' => '3306',
                 'db-catalog' => 'librarywikidb',
                 ),
         'uctlwiki.canterbury.ac.nz' => array(
                 'db-server' => 'localhost',
                 'db-port' => '3306',
                 'db-catalog' => 'uctlwikidb',
                 ),
         'itwiki.canterbury.ac.nz' => array(
                 'db-server' => 'localhost',
                 'db-port' => '3306',
                 'db-catalog' => 'itwikidb',
                 ),
 );

```

>  invoke-rc.d dekihost restart
>  invoke-rc.d apache2 restart
>  invoke-rc.d dekihost restart
>  invoke-rc.d apache2 restart

# Notes


# Miscellaneous configuration

- Configure timezone:


>  tzconfig
>  tzconfig

Well, that is not enough.  Dekiwiki would display all time information to users in what it considers as a suitable timezone, which is by default GMT - ignoring whatever is set at the OS level.

Following what [OpenGarden forum on timezone](http://forums.opengarden.org/showthread.php?p=8384&mode=linear#post8384) says, one can set the `$wgDefaultTimezone` variable to set the timezone offset.  To use timezone information to automatically adjust for DST, and cater for [PHP timezonedb](http://nz2.php.net/manual/en/timezones.php) not being updated with new NZ rules, I finally put the following to `/var/www/deki-hayes/LocalSettings.php`:

>  $wgDefaultTimezone  = date('P',time()-86400*21); //GMT offset

And, I set `/etc/ntp.conf` to use `cantva.canterbury.ac.nz` and `clock1.canterbury.ac.nz` instead of the default Debian machines (unreachable via the firewall).
