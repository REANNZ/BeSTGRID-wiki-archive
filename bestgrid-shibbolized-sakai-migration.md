# BeSTGRID Shibbolized Sakai Migration

# Introduction

This article describes the steps of Sakai migration from current [BeSTGRID Sakai 2.3](http://sakai.bestgrid.org) to a Shibboleth authentication supported Sakai 2.4. A test Shibbolized Sakai installed at [http://vre.test.bestgrid.org](http://vre.test.bestgrid.org)

# Sakai Upgrade from 2.3 to 2.4

- [Install Shibbolized Sakai 2.4](bestgrid-shibbolized-sakai-installation.md)
- Copy database dump from production server to test server
- Import database dump into test server database
- Download the [MySQL conversion script](https://source.sakaiproject.org/svn/reference/tags/sakai_2-4-0/docs/conversion/sakai_2_3_1-2_4_0_mysql_conversion.sql) and then implement it.
- Download the JForum conversion script and then implement it.

**NOTE**: There is a script has been created and stored in vre.test.bestgrid.org:/home/sakai/updateSakai/update.sh, and it could be used to run above restore processes as user **sakai**. However, it is strongly recommended to shutdown Tomcat before the restoring process since MySQL may result an insufficient memory error.

# [Sakai user migration](http://support.csi.ac.nz:8080/browse/BG-96)

- There are two main type of users in current Sakai database. University of Auckland (UoA) users and Non UoA users.

- Run the following script, and it will update the UoA users to format upi@auckland.ac.nz, and update Non-UoA users to format username@bestgrid.org. However, this script is not perfect due to the out-of-date information from UoA EC LDAP. For example, user A might registered a new email address in Sakai database, but UoA LDAP still stored the old email address. These exceptions would be highlighted in red background under 'New Sakai Username' column. [JIRA note](http://support.csi.ac.nz:8080/browse/BG-96#action_21523)

- The script will perform username update in SAKAI_USER_ID_MAP table after above steps. However few exceptions maybe exists due to duplicate username.

- Please update the configurations for LDAP and MySQL in the following PHP user migration script

``` 

<?

        //MySQL database configuration
        $db_username = "username";
        $db_password = "password";
        $db = "datbasename";
        $db_hostname = "localhost";

        //LDAP configuration
        $ldapServer = "ldaps://your.ldap.server";
        $ldapPort = "636";
        $ldapUser = "cn=root,ou=your,ou=ldap,o=server";
        $ldapPassword = "ldapPassword";
        $baseDN = "ou=people,ou=your,ou=ldap,o=server";

        //Exceptions
        $adminUsers = array("admin","postmaster"); //some usernames that you don't wish to update
        $uoaMailDomain = "auckland.ac.nz";
        $ecUoADomain = "ec.auckland.ac.nz";

        echo "<h2><center>BeSTGRID Sakai User Migration</center></h2>";

        if(!isset($_POST['option']))
        {
                echo "<center>Please select one of the options below";
?>

                <form action="<?  $_SERVER['PHP_SELF']; ?>" method="post">
                        <input type="hidden" value="reportOnly" name="option"/>
                        <input type="submit" value="Report Only"/>
                </form>
                <form action="<?  $_SERVER['PHP_SELF']; ?>" method="post">
                        <input type="hidden" value="update" name="option"/>
                        <input type="submit" value="Update"/>
                </form>
<?
                echo "</center>";
        }else{
                if($_POST['option']=='reportOnly')
                {
                        echo "Generating user migration report....";
                        $readonly = true;
                        userMigration($readonly);
                }else if($_POST['option']=='update'){
                        echo "Updating user name";
                        $readonly = false;
                        userMigration($readonly);
                }
        }

        function userMigration($readonly)
        {

                global $db_hostname, $db_username,$db_password,$db,$adminUsers,$uoaMailDomain,$ecUoADomain;
                $dbh = mysql_connect($db_hostname,$db_username,$db_password) or die("Unable to connect to MySQL");
                $selected = mysql_select_db($db, $dbh) or die("Could not select $database");

                $result = mysql_query("select SAKAI_USER.USER_ID as user_id, SAKAI_USER_ID_MAP.EID as username,EMAIL as email from SAKAI_USER, SAKAI_USER_ID_MAP where SAKAI_USER.USER_ID = SAKAI_USER_ID_MAP.USER_ID");

                echo "<table border=1>";
                if($readonly)
                {
                        echo "<tr BGCOLOR='#CCCC99'>
                        <td>#</td>
                        <td>Old Username</td><td>New Sakai Username</td><td>Name Status</td><td>Old Email</td><td>New Sakai Email (LDAP)</td><td>Mail Status</td><td>UoA email not in LDAP</td>
                        </tr>";
                }else{
                        echo "<tr BGCOLOR='#CCCC99'>
                        <td>#</td>
                        <td>Old Username</td><td>New Sakai Username</td><td>Name Status</td><td>Old Email</td><td>New Sakai Email (LDAP)</td><td>Mail Status</td><td>Update Status</td><td>UoA email not in LDAP</td>
                        </tr>";
                }
                $counter = 1;
                while ($row = mysql_fetch_array($result,MYSQL_ASSOC)){
                        $odd = $counter%2;
                        $s_username = $row{"username"};
                        $s_id = $row{"user_id"};
                        $s_email = $row{"email"};
                        if(!in_array($s_username,$adminUsers)){
                                $finalUserName = '';
                                $finalEmail = '';
                                $usernameStatus = '';
                                $emailStatus = '';
                                $updateStatus = '';
                                $uoaEmailButNotInLDAP = '';

                                if($odd)
                                        echo "<tr BGCOLOR='#CCCC99'>";
                                else
                                        echo "<tr>";

                                echo "<td>$counter</td>";
                                //echo "<td>$s_username</td>";
                                //echo "<td>$s_email</td>";

                                $lookUpUsername = '';
                                if (!ereg("^[^@]{1,64}@[^@]{1,255}$", $s_username)) {
                                        $lookUpUsername = $s_username;
                                }else{
                                        $splitUsername = explode("@", $s_username);
                                        $lookUpUsername = $splitUsername[0];
                                }

                                if($s_email != ''){
                                        $mail_array = explode("@",$s_email);
                                        $mailDomain = $mail_array[1];
                                        if(strstr($mailDomain,$ecUoADomain))
                                        {
                                                $finalUserName = $lookUpUsername."@auckland.ac.nz";
                                                $finalEmail = $s_email; //Many users don't exist in LDAP
                                                $usernameStatus = 'UoA';
                                                $emailStatus = 'Same';
                                                //echo "<td>$finalUserName</td>";
                                        }else{
                                                if(!strstr($mailDomain,$uoaMailDomain))
                                                {
                                                        $finalUserName = $lookUpUsername."@bestgrid.org";
                                                        $finalEmail = $s_email; //Non UoA user, can't lookup on UoA LDAP
                                                        $usernameStatus = 'BeSTGRID';
                                                        $emailStatus = 'Same';
                                                        //echo "<td bgcolor='yellow'>$finalUserName</td>";
                                                }else{
                                                        $isUoAUser = findCNinLDAP($lookUpUsername);
                                                        if(!$isUoAUser)
                                                        {
                                                                $uoaUPI = findMailinLDAP($s_email);
                                                                if(!$uoaUPI)
                                                                {
                                                                        $finalUserName = $lookUpUsername."@bestgrid.org";
                                                                        $finalEmail = $s_email;
                                                                        $usernameStatus = 'BeSTGRID';
                                                                        $emailStatus = 'Same';
                                                                        $uoaEmailButNotInLDAP = true;                                                                                                                                //echo "<td bgcolor='red'>$finalUserName</td>";                                      
                                                                }else{
                                                                        $tmpName = $uoaUPI[0]['uid'][0];
                                                                        $tmpEmail = $uoaUPI[0]['mail'][0];
                                                                        $finalUserName = $tmpName."@auckland.ac.nz";
                                                                        $finalEmail = $tmpEmail;
                                                                        $usernameStatus = 'UoA';
                                                                        if($tmpEmail == $s_email)
                                                                        {
                                                                                $emailStatus = 'Same';
                                                                        }else{
                                                                                $emailStatus = 'Diff';
                                                                        }
                                                                        //echo "<td>$finalUserName</td>";
                                                                }
                                                        }else{
                                                                $tmpName = $isUoAUser[0]['uid'][0];
                                                                $tmpEmail = $isUoAUser[0]['mail'][0];
                                                                $finalUserName = $tmpName."@auckland.ac.nz";
                                                                $finalEmail = $tmpEmail;
                                                                $usernameStatus = 'UoA';
                                                                if($tmpEmail == $s_email)
                                                                        {
                                                                                $emailStatus = 'Same';
                                                                        }else{
                                                                                $emailStatus = 'Diff';
                                                                 }

                                                                //echo "<td>$finalUserName</td>";
                                                        }
                                                }
                                        }
                                }else{
                                         $isUoAUser = findCNinLDAP($lookUpUsername);
                                         if(!$isUoAUser)
                                         {
                                                $finalUserName = $lookUpUsername."@bestgrid.org";
                                                $finalEmail = '';
                                                $usernameStatus = 'BeSTGRID';
                                                $emailStatus = 'Same';
                                                //echo "<td bgcolor='yellow'>$finalUserName</td>";
                                         }else{
                                                //$finalUserName = $isUoAUser."@auckland.ac.nz";
                                                $tmpName = $isUoAUser[0]['uid'][0];
                                                $tmpEmail = $isUoAUser[0]['mail'][0];
                                                $finalUserName = $tmpName."@auckland.ac.nz";
                                                $finalEmail = $tmpEmail;
                                                $usernameStatus = 'UoA';
                                                $emailStatus = 'Same';
                                                //echo "<td>$finalUserName</td>";
                                        }
                                }

                                echo "<td>$s_username</td>";
                                if($usernameStatus == 'UoA')
                                {
                                        echo "<td>$finalUserName</td>";
                                        echo "<td>$usernameStatus</td>";
                                }else{
                                        if($uoaEmailButNotInLDAP)
                                        {
                                                echo "<td bgcolor='red'>$finalUserName</td>";
                                                echo "<td bgcolor='red'>$usernameStatus</td>";
                                        }else{
                                                echo "<td bgcolor='yellow'>$finalUserName</td>";
                                                echo "<td bgcolor='yellow'>$usernameStatus</td>";
                                        }
                                }
                                echo "<td>$s_email</td>";
                                if($emailStatus == 'Same')
                                {
                                        echo "<td>$finalEmail</td>";
                                        echo "<td>$emailStatus</td>";
                                }else{
                                        echo "<td bgcolor='red'>$finalEmail</td>";
                                        echo "<td bgcolor='red'>$emailStatus</td>";
                                }
                                if(!$readonly)
                                {
                                        if($updateSakaiUserName = mysql_query("update SAKAI_USER_ID_MAP set EID = '$finalUserName' where USER_ID = '$s_id'"))                                           {
                                              echo "<td>Updated</td>";
                                        }else{
                                              echo "<td bgcolor='red'>Duplicated</td>";
                                        }
                                }
                                if($uoaEmailButNotInLDAP)
                                {
                                        echo "<td bgcolor='red'>true</td>";
                                }else{
                                        echo "<td>false</td>";
                                }
                                echo "</tr>";
                                $counter = $counter + 1;


                                //if($counter > 14){
                                //      die("</table>");
                                //}
                        }
                }
                echo "</table>";
        }

        function findCNinLDAP($cn)
        {
                global $ldapServer, $ldapPort, $ldapUser, $ldapPassword, $baseDN;
                $link_id = ldap_connect($ldapServer, $ldapPort);
                if($link_id){
                        if(ldap_bind($link_id,$ldapUser,$ldapPassword)){
                                $filter = "(cn=$cn)";
                                $result = ldap_search($link_id, $baseDN,$filter);
                                $entries = ldap_get_entries($link_id,$result);
                                if($entries['count']>0)
                                {
                                        return $entries;
                                }else{
                                        return false;
                                }
                                ldap_close($link_id);
                        }else{
                                die("failed to bind to LDAP");
                        }
                }else{
                        die("failed to connect");
                }
        }
        function findMailinLDAP($mail)
        {
                global $ldapServer, $ldapPort, $ldapUser, $ldapPassword, $baseDN;
                $link_id = ldap_connect($ldapServer, $ldapPort);
                if($link_id){
                        if(ldap_bind($link_id,$ldapUser,$ldapPassword)){
                                $filter = "(&(cn=*)(mail=$mail))";
                                $result = ldap_search($link_id, $baseDN,$filter);
                                $entries = ldap_get_entries($link_id,$result);
                                if($entries['count']>0)
                                {
                                        //return $entries[0]['uid'][0];
                                        return $entries;
                                }else{
                                        return false;
                                }
                                ldap_close($link_id);
                        }else{
                                die("failed to bind to LDAP");
                        }
                }else{
                        die("failed to connect");
                }
        }
?>


```

**NOTE:** If you would like to establish a SSL connection between your LDAP server and Sakai server, you have to import your sever CA into your openssl CA bundle.

# How to test it

- Go to [http://vre.test.bestgrid.org](http://vre.test.bestgrid.org)
- Click on the "Login" button on top right corner
- Select "Australian Access Federation Level 1" in Federation frame
- Select "The University of Auckland Level 1" in Instituion frmae
- Click on "Select" button
- Enter your username and password
- You should be redirected back to Sakai.
- Test it and report any bug to [system administrators](contacts.md)
