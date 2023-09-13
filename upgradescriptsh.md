# UpgradeScript.sh

``` 

echo "####Remove mysql dump in local directory"
rm bestgridWiki.sql
echo "####SSH TO wiki@www.bestgrid.org: create mysql dump!!!"
ssh wiki@www.bestgrid.org "(echo 'remove previous mysql dump';
                           rm bestgridWiki.sql;
                           echo 'create mysqldump for bestgrid wiki';
                           mysqldump -u root --opt bestgrid >> bestgridWiki.sql;
                           echo 'copy mysqldump from remote server to local directory';
                           scp bestgridWiki.sql wiki@wiki.bestgrid.org:upgradeWiki;
                           echo 'copy images folder';
                           cp -rf /var/www/bestgrid/images/ . ;
                           echo 'compress images';
                           tar cf images.tar images/
                           echo 'copy images.tar to local dir';
                           scp images.tar wiki@wiki.bestgrid.org:upgradeWiki;
                           ls;)"
echo "####extracting images tar ball"
tar xf images.tar
echo "####copy to wiki"
cp -r images /var/www/html/
echo "####Copy AdminSettings.php to wiki directory"
cp AdminSettings.php wiki
echo "####Restore mysql dump"
mysql -ubestgriduser -pbestgridpassword bestgrid < bestgridWiki.sql
echo "####Run wiki/maintenance/update.php script"
php wiki/maintenance/update.php
echo "####Run update username script"
php addScopeToMediaWikiUsers.php

```
