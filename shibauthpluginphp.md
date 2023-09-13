# ShibAuthPlugin.php

``` 

<?php

/**
 * Version 1.1.3 (Works out of box with MW 1.7 or above)
 *
 * Authentication Plugin for Shibboleth (http://shibboleth.internet2.edu)
 * Derived from AuthPlugin.php
 * Much of the commenting comes straight from AuthPlugin.php
 * 
 * Portions Copyright 2006, 2007 Regents of the University of California.
 * Portions Copyright 2007 Steven Langenaken
 * Released under the GNU General Public License
 *
 * Documentation at http://meta.wikimedia.org/wiki/Shibboleth_Authentication
 * Project IRC Channel: #sdcolleges on irc.freenode.net
 * 
 * Extension Maintainer:
 *         * D.J. Capelis <d1capelis AT ucsd DOT edu> (Please drop me an e-mail if you'd like to help)
 * Extension Developers:
 *         * Steven Langenaken - Added assertion support, more robust https checking
 *
 * Differences between 1.1.3 and 1.1.2:
 * = Extra error handling plus compatibility fixes for mediawiki version 1.6.8 (hook patches added)
 *
 * Differences between 1.1.2 and 1.1.1:
 * = Compatibilty fixes for 1.9
 *
 * Differences between 1.1.1 and 1.1:
 * = Preserve compatibility with 1.0 configuration files for $shib_LoginHint
 *
 * Differences between 1.1 and 1.0:
 * = Extra configuration options: 
 * == shib_Https (whether the AssertionConsumerService url is at https, default is false)
 * == shib_AssertionConsumerServiceURL (defaults to /Shibboleth.sso)
 * == Sites that are accessed via https are redirected there after logging in using lazy authentication
 */

require_once('AuthPlugin.php');

class ShibAuthPlugin extends AuthPlugin {
                
        /**
         * Check whether there exists a user account with the given name.
         * The name will be normalized to MediaWiki's requirements, so
         * you might need to munge it (for instance, for lowercase initial
         * letters).
         *
         * @param string $username
         * @return bool
         * @access public
         */
        function userExists( $username ) {
                return true;
        }
        /**
         * Check if a username+password pair is a valid login.
         * The name will be normalized to MediaWiki's requirements, so
         * you might need to munge it (for instance, for lowercase initial
         * letters).
         *
         * @param string $username
         * @param string $password
         * @return bool
         * @access public
         */
        function authenticate( $username, $password) {
                global $shib_UN;
                                                                
                if($username == $shib_UN)
                        return true;
                else
                        return false;
        }

        /**
         * Modify options in the login template.
         *
         * @param UserLoginTemplate $template
         * @access public
         */
        function modifyUITemplate( &$template ) {
                $template->set( 'usedomain', false );
        }

        /**
         * Set the domain this plugin is supposed to use when authenticating.
         *
         * @param string $domain
         * @access public
         */
        function setDomain( $domain ) {
                $this->domain = $domain;
        }

        /**
         * Check to see if the specific domain is a valid domain.
         *
         * @param string $domain
         * @return bool
         * @access public
         */
        function validDomain( $domain ) {
                return true;
        }

        /**
         * When a user logs in, optionally fill in preferences and such.
         * For instance, you might pull the email address or real name from the
         * external user database.
         *
         * The User object is passed by reference so it can be modified; don't
         * forget the & on your function declaration.
         *
         * @param User $user
         * @access public
         */
        function updateUser( &$user ) {
                global $shib_map_info;
                global $shib_email;
                global $shib_RN;

                if (! $shib_map_info)
                        return true;
                                                                        
                if($shib_email != null)
                        $user->setEmail($shib_email);
                if($shib_RN != null)
                        $user->setRealName($shib_RN);

                //For security, scramble the password to ensure the user can
                //only login through Shib.  This set the password to a 15 byte
                //random string.
                $pass = null;
                for($i = 0; $i < 15; ++$i)
                        $pass .= chr(mt_rand(0,255));
                $user->setPassword($pass);
                        
                return true;
        }


        /**
         * Return true if the wiki should create a new local account automatically
         * when asked to login a user who doesn't exist locally but does in the
         * external auth database.
         *
         * If you don't automatically create accounts, you must still create
         * accounts in some way. It's not possible to authenticate without
         * a local account.
         *
         * This is just a question, and shouldn't perform any actions.
         *
         * @return bool
         * @access public
         */
        function autoCreate() {
                return true;
        }

        /**
         * Can users change their passwords?
         *
         * @return bool
         */
        function allowPasswordChange() {
                global $shib_pretend;

                if($shib_pretend)
                        return true;
                else
                        return false;
        }

        /**
         * Set the given password in the authentication database.
         * Return true if successful.
         *
         * @param string $password
         * @return bool
         * @access public
         */
        function setPassword( $password ) {
                global $shib_pretend;

                if($shib_pretend)
                        return true;
                else
                        return false;
        }

        /**
         * Update user information in the external authentication database.
         * Return true if successful.
         *
         * @param User $user
         * @return bool
         * @access public
         */
        function updateExternalDB( $user ) {
                //Not really, but wiki thinks we did...
                return true;
        }

        /**
         * Check to see if external accounts can be created.
         * Return true if external accounts can be created.
         * @return bool
         * @access public
         */
        function canCreateAccounts() {
                return false;
        }

        /**
         * Add a user to the external authentication database.
         * Return true if successful.
         *
         * @param User $user
         * @param string $password
         * @return bool
         * @access public
         */
        function addUser( $user, $password ) {
                return false;
        }


        /**
         * Return true to prevent logins that don't authenticate here from being
         * checked against the local database's password fields.
         *
         * This is just a question, and shouldn't perform any actions.
         *
         * @return bool
         * @access public
         */
        function strict() {
                return false;
        }

        /**
         * When creating a user account, optionally fill in preferences and such.
         * For instance, you might pull the email address or real name from the
         * external user database.
         *
         * The User object is passed by reference so it can be modified; don't
         * forget the & on your function declaration.
         *
         * @param User $user
         * @access public
         */
        function initUser( &$user ) {
                $this->updateUser($user);
        }

        /**
         * If you want to munge the case of an account name before the final
         * check, now is your chance.
         */
        function getCanonicalName( $username ) {
                return $username;
        }
}



function ShibUserLogout()
{
	if (isset($_SERVER['HTTP_COOKIE'])) {
	    $cookies = explode(';', $_SERVER['HTTP_COOKIE']);
	    foreach($cookies as $cookie) {
	        $parts = explode('=', $cookie);
	        $name = trim($parts[0]);
	        setcookie($name, '', time()-1000);
	        setcookie($name, '', time()-1000, '/');
	    }
	}
}

/*
 * End of AuthPlugin Code, beginning of hook code and auth functions
 */
function SetupShibAuth()
{
        global $shib_UN;
        global $wgHooks;
        global $wgAuth;
	global $shib_Register_url;
	global $wgScriptPath;
        //global $shib_pretend;

        //$shib_pretend = false;
        if($shib_UN != null)
        {
                $wgHooks['AutoAuthenticate'][] = 'AutoAuth'; /* Hook for magical authN */
                $wgHooks['PersonalUrls'][] = 'KillLogout'; /* Disallow logout link */
                $wgAuth = new ShibAuthPlugin();
               if (strpos($_SERVER['REQUEST_URI'], '/Special:Userlogin') != false) {
                        header("Location: ".$wgScriptPath);
			exit;
		}
        }
        else
	{
                $wgHooks['PersonalUrls'][] = 'SSOLinkAdd';
                if(isset($_GET['action']))
                {
                        if($_GET['action']=='edit')
                        {
                         header("Location: ".getShibSSOLink());
			  exit;
                        }
                }
               if (strpos($_SERVER['REQUEST_URI'], '/Special:Userlogin') != false) {
                        header("Location: ".getShibSSOLink());
			exit;
                }
		ShibUserLogout();
	}

       if(isset($_GET['title']) && isset($_GET['type']))
       {
               if($_GET['title'] == 'Special:Userlogin' && $_GET['type'] == 'signup')
                        header("Location: $shib_Register_url");
       }
}
function getShibSSOLink()
{
        global $shib_WAYF,$shib_Https,$shib_AssertionConsumerServiceURL;
        if (! isset($shib_AssertionConsumerServiceURL) || $shib_AssertionConsumerServiceURL == '')
                $shib_AssertionConsumerServiceURL = "/Shibboleth.sso";
        if (! isset($shib_Https))
                $shib_Https = false;

        //$target = (isset($_SERVER['HTTPS']) ? 'https' : 'http').'://' . $_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI'];
	$target = ($shib_Https ? 'https' :  'http').'://' . $_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI'];
        $target = urlencode($target);
        $href = ($shib_Https ? 'https' :  'http') .'://' . $_SERVER['HTTP_HOST'] .$shib_AssertionConsumerServiceURL . "/WAYF/" . $shib_WAYF . '?target='.$target;
	//die($href);
        return $href;
}

function SSOLinkAdd(&$personal_urls, $title)
{
        global $shib_WAYF, $shib_LoginHint, $shib_Https, $shib_AssertionConsumerServiceURL, $shib_Register_hint,$shib_Register_url;
        if (! isset($shib_AssertionConsumerServiceURL) || $shib_AssertionConsumerServiceURL == '')
                $shib_AssertionConsumerServiceURL = "/Shibboleth.sso";
        if (! isset($shib_Https))
                $shib_Https = false;
        $pageurl = $title->getLocalUrl();

        if (!isset($shib_LoginHint))
                $shib_LoginHint = "Login via Shibboleth Open Identity Provider";
	
	$personal_urls = null;
       /*$personal_urls['login'] = array(
                'text' => $shib_LoginHint,
                'href' => ($shib_Https ? 'https' :  'http') .'://' . $_SERVER['HTTP_HOST'] . $shib_AssertionConsumerServiceURL . "/WAYF/" . $shib_WAYF . '?target=' . (isset($_SERVER['HTTPS']) ? 'https' : 'http') . '://' . $_SERVER['HTTP_HOST'] . $pageurl, );
	//die($personal_urls['login']['href']);
	$personal_urls['register'] = array(
		 'text' => $shib_Register_hint,
		 'href' => $shib_Register_url,

	);*/
	$personal_urls['login'] = array(
                'text' => $shib_LoginHint,
                'href' => ($shib_Https ? 'https' :  'http') .'://' . $_SERVER['HTTP_HOST'] . $shib_AssertionConsumerServiceURL . "/WAYF/" . $shib_WAYF . '?target=' . ($shib_Https ? 'https' :  'http'). '://' . $_SERVER['HTTP_HOST'] . $pageurl, );
        //die($personal_urls['login']['href']);
        $personal_urls['register'] = array(
                 'text' => $shib_Register_hint,
                 'href' => $shib_Register_url,

        );
}       

/* Kill logout link */
function KillLogout(&$personal_urls, $title)
{
        global $shib_logout;

        if($shib_logout == null){
                $personal_urls['logout'] = null;
	}
        else{
                $personal_urls['logout']['href'] = $shib_logout;
	}
}

/* Tries to be magical about when to log in users and when not to. */
function AutoAuth(&$user)
{
        global $wgContLang;
        global $wgAuth;
        global $shib_UN;
        global $wgHooks;
        global $shib_pretend;

	global $wgGroupPermissions;
	
        $wgGroupPermissions['*']['edit'] = true;
        $wgGroupPermissions['*']['createpage'] = true;
        $wgGroupPermissions['*']['createtalk'] = true;

        //For versions of mediawiki which enjoy calling AutoAuth with null users
        if ($user === null) {
                $user = User::loadFromSession();
        }
        //They already with us?  If so, nix this function, we're good.
        if($user->isLoggedIn()){
		if($user->getName() == $shib_UN)
		{
                	return;
		}
	}

        //Is the user already in the database?
        if (User::idFromName($shib_UN) != null)
        {
                 $user = User::newFromName($shib_UN);
                 $user->SetupSession();
                 $user->setCookies();
                 return;
        }

        //Okay, kick this up a notch then...
        $user->setName($wgContLang->ucfirst($shib_UN));

        /* 
         * Since we only get called when someone should be logged in, if they
         * aren't let's make that happen.  Oddly enough the way MW does all
         * this is simply to use a loginForm class that pretty much does
         * most of what you need.  Creating a loginform is a very very small
         * part of this object.
         */
        require_once('SpecialUserlogin.php');

        //This section contains a silly hack for MW
        global $wgLang;
        global $wgContLang;
        global $wgRequest;
        if(!isset($wgLang))
        {
                $wgLang = $wgContLang;
                $wgLangUnset = true;
        }

        //Temporarily kill The AutoAuth Hook to prevent recursion
        foreach ($wgHooks['AutoAuthenticate'] as $key => $value)
        {
                if($value == 'AutoAuth')
                    $wgHooks['AutoAuthenticate'][$key] = 'BringBackAA';
        }
         
        //This creates our form that'll do black magic
        $lf = new LoginForm($wgRequest);

        //Place the hook back (Not strictly necessarily MW Ver >= 1.9)
        BringBackAA($user);

        //And now we clean up our hack
	if(isset($wgLangUnset))
	{
        if($wgLangUnset == true)
        {
                unset($wgLang);
                unset($wgLangUnset);
        }
	}

        //The mediawiki developers entirely broke use of this the 
        //straightforward way in 1.9, so now we just lie...
        $shib_pretend = true;

        //Now we _do_ the black magic
        $lf->mRemember = false;
        $lf->initUser(&$user);

        //Stop pretending now
        $shib_pretend = false;

        //Finish it off
        $user->saveSettings();
        $user->setupSession();
        $user->setCookies();
}

/* Puts the auto-auth hook back into the hooks array */
function BringBackAA(&$user)
{
        global $wgHooks;

        foreach ($wgHooks['AutoAuthenticate'] as $key => $value)
        {
            if($value == 'BringBackAA')
                $wgHooks['AutoAuthenticate'][$key] = 'AutoAuth';
        }
}

?>



```
