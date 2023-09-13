# Google Calendar Extension

# Introduction

This article describes how to setup a Google Calendar extension in Mediawiki. The original extension was developed and documented on [http://www.mediawiki.org/wiki/Extension:GoogleCalendar](http://www.mediawiki.org/wiki/Extension:GoogleCalendar)

# Installation

>  **Copy the following GoogleCalendar extension and save into*wiki_path**/extensions/googleCalendar.php

``` 

<?php

/**
 *
 * Google Calendars
 *
 * Author: Kasper Souren
 * Contributions: Malcolm Humphreys
 *
 * Simple Tag:
 *   <googlecalendar>docid</googlecalendar>
 *   <googlecalendar>someguy%20getorganised.com</googlecalendar>
 *
 * Multiple Calendars Tag:
 *   <googlecalendar>docid|docid</googlecalendar>
 *   <googlecalendar>someguy%20getorganised.com|someguy_friend%20getorganised.com</googlecalendar>
 *
 * Options:
 *     - showtitle - show title toggle
 *     - shownav - show nav toggle
 *     - showdate - show date toggle
 *     - showtabs - show tabs toggle
 *     - showcalendars - show calendar toggle
 *     - width - width in pixels
 *     - height - height in pixels
 *     - title - title of the calendar
 *     - mode - view of the calendar (WEEK, MONTH, AGENDA)
 *     - wkst - which day to start the calendar on (1:Sun, 2: Mon, 3: Tue, 4: Wed, 5: Thur, 6: Fri, 7: Sat)
 *     - bgcolour - background colour as hex values
 *     - iframestyle - style of the frame (border-width:0 or border:solid 1px #777)
 *
 **/

$wgExtensionFunctions[] = 'wfGoogleCalendar';
$wgExtensionCredits['parserhook'][] = array('name'        => 'Google Calendar',
                                            'description' => 'Display Google Calendar',
                                            'author'      => 'Kasper Souren',
                                            'url'         => 'http://wiki.couchsurfing.com/en/Google_Calendar_MediaWiki_plugin'
);

// Setup the extension
function wfGoogleCalendar() {

    global $wgParser, $wgMessageCache;

    // Setup Hooks
    $wgParser->setHook('googlecalendar', 'renderGoogleCalendar');

}

// Argument toggle helper function
function gc_toggle($input, $default) {

    if ($input=="")
        return $default;

    return (int)$input;

}
// Google Calendar renderer
function renderGoogleCalendar($input, $argv, &$parser) {

        // Setup the defaults
        $input         = htmlspecialchars($input);
        $showtitle     = gc_toggle($argv["showtitle"], 0);
        //$shownav       = gc_toggle($argv["shownav"], 1);
        //$showdate      = gc_toggle($argv["showdate"], 1);
        //$showtabs      = gc_toggle($argv["showtabs"], 1);
        //$showcalendars = gc_toggle($argv["showcalendars"], 1);
        $width         = 700;
        $height        = 550;
        //$title         = "My Calendar";
        //$mode          = "MONTH";
        $wkst          = 1;
        $bgcolour      = "FFFFFF";
        $colour        = "A32929";
        $iframestyle   = "border-width:0";

        // Parse the calendar addresses
        $calendars = explode("|", $input);
        $srcString = "";
        foreach ($calendars as $calendar) {
            $srcString = $srcString .'src='.$calendar.'&amp;';
        }

        // Tag overrides
        if ($argv["width"])
            $width = $argv["width"];
        if ($argv["height"])
            $height = $argv["height"];
        //if ($argv["title"])
        //    $title = $argv["title"];
        //if ($argv["mode"])
        //    $mode = $argv["mode"];
        if ($argv["wkst"])
            $wkst = $argv["wkst"];
        if ($argv["bgcolour"])
            $bgcolour = $argv["bgcolour"];
        if ($argv["colour"])
            $colour = $argv["colour"];
        if ($argv["iframestyle"])
            $iframestyle = $argv["iframestyle"];

        // Build the <iframe> that contains the calendar
        //$output = '<iframe src="http://www.google.com/calendar/embed?showTitle='.$showtitle.'&amp;showNav='.$shownav.'&amp;showDate='.$showdate.'&amp;showTabs='.$showtabs.'&amp;showCalendars='.$showcalendars.'&amp;title='.$title.'&amp;mode='.$mode.'&amp;height='.$height.'&amp;wkst='.$wkst.'&amp;bgcolor=%23'.$bgcolour.'&amp;'.$srcString.'" style="'.$iframestyle.'" width="'.$width.'" height="'.$height.'" frameborder="0" scrolling="no"></iframe>';

        $output = '<iframe src="http://www.google.com/calendar/embed?showTitle='.$showtitle.'&amp;height='.$height.'&amp;wkst='.$wkst.'&amp;bgcolor=%23'.$bgcolour.'&amp;'.$srcString.'&amp;color=%23528800&amp;src=new_zealand__en%40holiday.calendar.google.com&amp;color=%2329527A" style="'.$iframestyle.'" width="'.$width.'" height="'.$height.'" frameborder="0" scrolling="no"></iframe>';


        return $output;
}

?>


```

>  **Insert the following line into*LocalSettings.php**

``` 

 require_once('extensions/googleCalendar.php');

```

# Example

- Create a wiki page with following content

``` 

<googlecalendar>s2bllj311vt9alcmqnajt9i2jk%40group.calendar.google.com</googlecalendar>

```

**NOTE: replace *s2bllj311vt9alcmqnajt9i2jk** with your own account.
