# Re-installing ShibAuthPlugin after upgrading AVCC MediaWiki to 1.13

The ShibAuthPlugin used within BeSTGRID (based on 1.1.3) is not compatible with MediaWiki 1.13.  The newest version of ShibAuthPlugin, 1.2.2, is much closer to being compatible - but still, a few issues had to be resolved.  This page documents the struggle and lessons learnt.

# Futile attempt to get old plugin working

After MediaWiki upgrade, the MW was reporting that two of the hook functions in ShibAuthPlugin fail to return a value: KillLogout and SSOLinkAdd.

It was an easy fix (adding a `"return true;"` statement) at the end of each function.

However, afterwards, even though no errors were reported, correctly established Shibboleth sessions were ignored.

# Installing ShibAuthPlugin 1.2.2

There have been too many changes between MediaWiki 1.7 and 1.13, and to get Shibboleth authentication working, I had to move over to ShibAuthPlugin 1.2.2.

- Download from [http://www.mediawiki.org/wiki/Extension:Shibboleth_Authentication](http://www.mediawiki.org/wiki/Extension:Shibboleth_Authentication)

## Fixing ShibAuthPlugin 1.2.2 to work with MediaWiki 1.13

There have been several issues to get ShibAuthPlugin 1.2.2 going with MediaWiki 1.13:

- Breaks if `$shib_RN` not set (displays an empty label)
	
- Fix: set `$shib_RN` to `$shib_UN` if it's empty.
- Breaks on login: 

``` 
Fatal error: Unsupported operand types in /var/www/includes/User.php on line 2113
```
- The problem is caused by `$_SESSION` not being set (should be an Array of session variables.
- Fix: create a PHP session by adding the following line into `LocalSettings.php` *before* calling `SetupShibAuth()`

``` 
session_start();
```
- Breaks on login of new users: reports incorrect parameters being passed to `LoginForm::initUser()`: 

``` 
Warning: Missing argument 2 for LoginForm::initUser(), called in /var/www/extensions/ShibAuthPlugin.php on line 419 and defined in /var/www/includes/specials/SpecialUserlogin.php on line 336
```
- Fix: add `true` as a second parameter to `initUsers` in `ShibUserLoadFromSession`

``` 

-        $lf->initUser($user);
+        $lf->initUser($user,true);

```

## Customizing ShibAuthPlugin to meet BeSTGRID needs

The goal is to make Shibboleth the only way to log in - that includes disabling all other means of login, namely the MediaWiki built-in account database.

The following changes have been made:



- Block access to the `Special:Userlogin` page.
	
- Redirect users already logged in to the home page (`$wgScriptPath`) when the request matches the login page (either directly in the request path name or in the `title` parameter).
		
- Make sure `$wgScriptPath` is defined (actually, use `$myScriptPath` instead)
- Redirect users not logged in yet to the SSO URL.
		
- If `$shib_IdP` is set (i.e., the user has a Shibboleth session but no PrincipalName), redirect the user to the homepage instead (or the target page if the `target` request parameter is specified).

- Redirect users to the SSO when a page edit is requested and the user is not logged in.
	
- This required adding the `getShibSSOLink()` function.

# Pending issues

- The AVCC wiki now displays the Edit link as `View Source` for anonymous users.  Clicking the link still works: the user gets redirected to Shibboleth login, and after a successful login, the Wiki proceeds to opening the requested page in the editor.
	
- It appears that MediaWiki (correctly) thinks that an anonymous user cannot edit the page - but that the BeSTGRID wiki in the same situation displays the Edit link as `Edit`, as desired.

# Diff between the AVCC customized version and original ShibAuthPlugin 1.2.2

``` 

--- ShibAuthPlugin-mw122.php    2008-10-07 14:44:00.000000000 +1300
+++ ShibAuthPlugin.php  2008-10-08 17:18:00.000000000 +1300
@@ -239,6 +239,19 @@
                 return $username;
         }
 }
+
+function ShibUserLogout()
+{
+        if (isset($_SERVER['HTTP_COOKIE'])) {
+            $cookies = explode(';', $_SERVER['HTTP_COOKIE']);
+            foreach($cookies as $cookie) {
+                $parts = explode('=', $cookie);
+                $name = trim($parts[0]);
+                setcookie($name, '', time()-1000);
+                setcookie($name, '', time()-1000, '/');
+            }
+        }
+}
  
 function ShibGetAuthHook() {
         global $wgVersion;
@@ -254,18 +267,50 @@
 function SetupShibAuth()
 {
         global $shib_UN;
+        global $shib_IdP;
         global $wgHooks;
         global $wgAuth;
         global $wgExtensionCredits;
         global $wgCookieExpiration;
+        global $wgScriptPath;
+
+        # How comes it's not set on MW 1.13 (even when imported as global)?
+        $myScriptPath = ($wgScriptPath == "") ? "/wiki/" : $wgScriptPath;
  
         if($shib_UN != null){
                 $wgCookieExpiration = -3600;
                 $wgHooks[ShibGetAuthHook()][] = "Shib".ShibGetAuthHook();
                 $wgHooks['PersonalUrls'][] = 'ShibActive'; /* Disallow logout link */
                 $wgAuth = new ShibAuthPlugin();
+               if (stripos($_SERVER['REQUEST_URI'], '/Special:Userlogin') != false ||
+                   ( isset($_GET['title']) && (strcasecmp($_GET['title'],'Special:Userlogin')==0) ) ) {
+                       header("Location: ".$myScriptPath);
+                       exit;
+               }
         } else {
                 $wgHooks['PersonalUrls'][] = 'ShibLinkAdd';
+                if(isset($_GET['action']))
+                {
+                        if($_GET['action']=='edit' && $shib_IdP==null)
+                        {
+                         header("Location: ".getShibSSOLink());
+                          exit;
+                        }
+                }
+               if (stripos($_SERVER['REQUEST_URI'], '/Special:Userlogin') != false ||
+                   ( isset($_GET['title']) && (strcasecmp($_GET['title'],'Special:Userlogin')==0) ) ) {
+                        if ($shib_IdP == null) {
+                            header("Location: ".getShibSSOLink());
+                        } else {
+                            if (isset($_GET['returnto'])) {
+                                header("Location: " . $myScriptPath."index.php?title=".$_GET['returnto']);
+                            } else {
+                                header("Location: ". $myScriptPath );
+                            };
+                        };
+                        exit;
+                }
+
         }
         $wgExtensionCredits['other'][] = array(
                         'name' => 'Shibboleth Authentication',
@@ -275,11 +320,29 @@
                         'description' => "Allows logging in through Shibboleth",
                         );
 }
+
+/* Construct the link to the Shibboleth SSO service */
+function getShibSSOLink()
+{
+        global $shib_WAYF,$shib_Https,$shib_AssertionConsumerServiceURL;
+        if (! isset($shib_AssertionConsumerServiceURL) || $shib_AssertionConsumerServiceURL == '')
+                $shib_AssertionConsumerServiceURL = "/Shibboleth.sso";
+        if (! isset($shib_Https))
+                $shib_Https = false;
+
+        //$target = (isset($_SERVER['HTTPS']) ? 'https' : 'http').'://' . $_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI'];
+        $target = 'http://' . $_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI'];
+        $target = urlencode($target);
+        $href = ($shib_Https ? 'https' :  'http') .'://' . $_SERVER['HTTP_HOST'] .$shib_AssertionConsumerServiceURL . "/WAYF/" . $shib_WAYF . '?target='.$target;
+        //die($href);
+        return $href;
+}
  
 /* Add login link */
 function ShibLinkAdd(&$personal_urls, $title)
 {
         global $shib_WAYF, $shib_LoginHint, $shib_Https, $shib_AssertionConsumerServiceURL;
+        global $shib_Register_hint, $shib_Register_url;
         if (! isset($shib_AssertionConsumerServiceURL) || $shib_AssertionConsumerServiceURL == '')
                 $shib_AssertionConsumerServiceURL = "/Shibboleth.sso";
         if (! isset($shib_Https))
@@ -288,12 +351,20 @@
         if (! isset($shib_LoginHint))
                 $shib_LoginHint = "Login via Single Sign-on";
  
+        if (isset($personal_urls['anontalk'])) unset($personal_urls['anontalk']);
+        if (isset($personal_urls['anonuserpage'])) unset($personal_urls['anonuserpage']);
+        if (isset($personal_urls['anonlogin'])) unset($personal_urls['anonlogin']);
+
         $personal_urls['SSOlogin'] = array(
                         'text' => $shib_LoginHint,
                         'href' => ($shib_Https ? 'https' :  'http') .'://' . $_SERVER['HTTP_HOST'] . 
                         $shib_AssertionConsumerServiceURL . "/WAYF/" . $shib_WAYF . 
                         '?target=' . (isset($_SERVER['HTTPS']) ? 'https' : 'http') . 
                         '://' . $_SERVER['HTTP_HOST'] . $pageurl, );
+
+        $personal_urls['register'] = array(
+                 'text' => $shib_Register_hint,
+                 'href' => $shib_Register_url, );
         return true;
 } 
  
@@ -403,7 +474,7 @@
         //Now we _do_ the black magic
         $lf->mRemember = false;
         $user->loadDefaults($shib_UN);
-        $lf->initUser($user);
+        $lf->initUser($user,true);
  
         //Stop pretending now
         $shib_pretend = false;

```

# Download

Please download the final version: [ShibAuthPlugin-AVCC-MW122.php](/wiki/download/attachments/3816950834/ShibAuthPlugin-AVCC-MW122-php.txt?version=1&modificationDate=1539354336000&cacheVersion=1&api=v2)
