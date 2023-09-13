# AddScopeToMediaWikiUsers.php

``` 

<?php

        $username = "bestgriduser";
        $password = "bestgridpassword";
        $database = "bestgrid";
        $hostname = "localhost";
        $dbh = mysql_connect($hostname,$username,$password) or die("Unable to connect to MySQL");

        $selected = mysql_select_db($database, $dbh) or die("Could not select $database");

        /*
                ================ SECTION 1: Append @bestgrid.org to all users ================
        */
        $result = mysql_query("SELECT user_name, user_id FROM user WHERE user_name NOT LIKE '%@%'");


        while ($row = mysql_fetch_array($result,MYSQL_ASSOC)){
                //echo "ID:".$row{'user_id'}." Name:".$row{'user_name'}."<br>";
                $old_username = $row{'user_name'};
                $user_id = $row{'user_id'};
                $new_username = $old_username.@"@bestgrid.org";
                //echo $new_username."<br>";
                //echo $user_id."<br>";
                if($tmp_result = mysql_query("update user set user_name = '$new_username' where user_id = '$user_id'")){
                        //echo "successfully updated user $new_username <br>";
                }else{
                        echo "failed to update user $new_username <br>";
                }
        }

        /*
                =============== End of Section 1 =======================
        */


        /*
                ================ SECTION 1: Update all tables ================
        */
        $newResults = mysql_query("SELECT user_name, user_id FROM user");
        while ($row = mysql_fetch_array($newResults,MYSQL_ASSOC)){
                $new_username = $row{'user_name'};
                $user_id = $row{'user_id'};

                //Update image table
                if($tmp_result = mysql_query("update image set img_user_text = '$new_username' where img_user = '$user_id'")){
                        //echo "successfully image user $new_username <br>";
                }else{
                        echo "failed to image user $new_username <br>";
                }

               //Update oldimage table
                if($oldimage = mysql_query("update oldimage set oi_user_text = '$new_username' where oi_user = '$user_id'")){
                        //echo "successfully  oldimage user $new_username <br>";
                }else{
                        echo "failed to oldimage user $new_username <br>";
                }

                //Update recentchanges table
                if($recentchanges_result = mysql_query("update recentchanges set rc_user_text = '$new_username' where rc_user = '$user_id'")){
                        //echo "successfully recentchanges user $new_username <br>";
                }else{
                        echo "failed to recentchanges user $new_username <br>";
                }

                //Update revision table
                if($recentchanges_result = mysql_query("update revision set rev_user_text = '$new_username' where rev_user = '$user_id'")){
                        //echo "successfully revision user $new_username <br>";
                }else{
                        echo "failed to revision user $new_username <br>";
                }






        }

        //echo "<br><br><br>";
        $new_user_page_Results = mysql_query("SELECT user_name, user_id FROM user");
        while ($row = mysql_fetch_array($new_user_page_Results,MYSQL_ASSOC)){
                $new_username = $row{'user_name'};
                $tok = strtok($new_username, "@");
                $old_username = $tok;
                //echo $new_username."<br>";
                //echo $old_username."<br>";
                //echo "--------<br>";
                $tmp_result = mysql_query("SELECT page_title,page_id FROM page WHERE page_title LIKE '$old_username'");
                while($tmp_row = mysql_fetch_array($tmp_result,MYSQL_ASSOC)){
                        $tmp_page_title = $tmp_row{'page_title'};
                        $page_id = $tmp_row{'page_id'};
                         //Update page title
                        if($updatePage = mysql_query("update page set page_title = '$new_username' where page_id = '$page_id'")){
                              //  echo "successfully  update page $new_username <br>";
                        }else{
                                echo "failed to update page $new_username <br>";
                        }

                        //echo $tmp_page_title."<br>";

                }
                //echo "=======<br><br>";



        }

        //echo "<br><br><br>";
        $update_layout = mysql_query("select * from text where old_text like '%{| style=\"position:absolute; top:0; width:100%; background: white; color:#888;\" valign=\"middle\"%';");
         while ($row = mysql_fetch_array($update_layout,MYSQL_ASSOC)){
                $old_id = $row{'old_id'};
                //$old_text = $row{'old_text'};
                //$new_text = str_replace("{| style=\"position:absolute; top:0; width:100%; background: white; color:#888;\" valign=\"middle\"","{| style=\"position:absolute; top:130px; left:170px; width:100%; background: white; color:#888;\" valign=\"middle\"",$old_text);
                //echo $old_id;
                //echo $old_text;
                //echo "<br><br>*********************************************<br><br>";
                //echo $new_text;
                $old_text = "{| style=\"position:absolute; top:0; width:100%; background: white; color:#888;\" valign=\"middle\"";
                $new_text = "{| style=\"position:absolute; top:130px; left:170px; width:100%; background: white; color:#888;\" valign=\"middle\"";
                if($update_page = mysql_query("update text set old_text = replace(old_text,'$old_text','$new_text') where old_id = '$old_id'")){
                //      echo "successfully update !!!<br>";
                }else{
                         echo "failed to update page <br>";
                }
                //echo "<br><br>*********************************************<br><br>";


        }
        /*if($update_layout = mysql_query("update text set old_text = replace(old_text,'{| style=\"position:absolute; top:0; width:100%; background: white; color:#888;\" valign=\"middle\"','{| style=\"position:absolute; top:0; width:100%; background: white; color:#888;\" valign=\"middle\"","{| style=\"position:absolute; top:130px; left:170px; width:100%; background: white; color:#888;\" valign=\"middle\"');")){
                 echo "successfully update !!!<br>";
        }else{
                 echo "failed to update page <br>";
        }*/


        mysql_close($dbh);

?>

```
