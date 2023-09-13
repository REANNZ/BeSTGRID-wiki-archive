# Rocks Database

To simplify editing numerous configuration files, Rocks synchronizes them using mysql database **cluster**. By default it sets mysql root password to linux root password. 

[ Web Interface To The Database|http://www.rocksclusters.org/rocks-documentation/4.3/monitoring-database.html]

[ Database Schema|http://www.rocksclusters.org/rocks-documentation/reference-guide/4.3/database.html]

Despite the fact that relevant configuration options are now stored in central location, there is no referential integrity in the database, so manual editing is not recommended except in simplest cases. After update run

>  rocks sync config

To notify Rocks of changes.

Some information from the database can be obtained using **dbreport** utility.
