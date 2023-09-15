# A complete EVO setup for cross-institutional small-room teaching and seminars

For an example of this technology being used, see the page on [Remote Teaching using EVO](/wiki/spaces/BeSTGRID/pages/3818228683)

![Bryant-lecture-2.jpg](./attachments/Bryant-lecture-2.jpg)
# Scope of this setup

>  **The setup is designed for conducting remote teaching or seminar presentations where there are small groups of*1 to 10 people** at each of **two** sites.

- The two sites should have very good network conductivity between (for example, two University campuses in New Zealand)
- This is a setup that works well if at one site there is a 'presenter' or 'lecturer', and at the other site there is a small class or group to hear the presentation/lecture.


>  **It is specifically designed to be*portable** at both sites, so that theoretically **any room** (or office for that matter) could be used in the session.
>  **However, it is absolutely critical that in both rooms have a*live network connection**, and that there are suitable network configurations numbers (that is, IP number, Gateway, etc) that provide open and transparent (no proxies!) external network connections (to the KAREN network)
>  **Please talk the local network manager to obtain the configuration required for the rooms that are being used.*This should be done well in advance!**
>  **It is specifically designed to be*portable** at both sites, so that theoretically **any room** (or office for that matter) could be used in the session.
>  **However, it is absolutely critical that in both rooms have a*live network connection**, and that there are suitable network configurations numbers (that is, IP number, Gateway, etc) that provide open and transparent (no proxies!) external network connections (to the KAREN network)
>  **Please talk the local network manager to obtain the configuration required for the rooms that are being used.*This should be done well in advance!**

# Equipment Needed

In a nutshell, what is needed is a generic PC, data projector (at audience end), live network connection and:

- one (or two) quality cameras compatible with EVO
- an audio echo cancellation setup (speaker and microphone) suitable for a group of say up to 10 people (again compatible with EVO)

For larger groups you could use a PA with a (wireless) handhead vocal microphone with small 'cardioid' pattern (which is passed around for question time) – this is a cheaper option. Ensure any sound capture device (i.e. USB audio capture) is compatible with EVO.

The devices we have listed below have been tested with EVO. There are many other devices that could also do the job. 

Basically, you will have had good success with Logitech Cameras and Clearone Audio units. (Avoid Microsoft Cameras, and logitech audio units.)

## At the presenter's/lecturer's site

- A WindowsXP PC, preferably a [tablet laptop](http://h10010.www1.hp.com/wwpc/us/en/sm/WF05a/321957-321957-64295-304455-306995-1847962.html) with Sun's Java 1.6 runtime environment, and configured network connection with open external connectivity
- A [QuickCam Ultra vision WebCam](http://www.logitech.com/index.cfm/webcam_communications/webcams/devices/238&cl=nz,en) (or similar) (can be sourced from [PB technologies](http://www.pbtech.co.nz) in Auckland)
- A [ClearOne Chat 150](http://www.clearone.com/products/product.php?cat=9&prod=98) echo-cancellation audio unit available from [AVW in East Tamaki, Auckland](http://www.avw.co.nz/) (Connected via a USB 2.0 extension cable, and use external powersupply). Read [this section using echo cancellation devices with EVO](known-issues-with-evo.md)
- A second monitor, at least 19 inch, providing an extended screen display area for the tablet laptop
- (The above set up could be used in the comfort of one's own office)

## At the class/audience site

- A desktop Windows XP computer, with Sun's Java 1.6 run-time environment install, and a configured open network connection
- One or two [QuickCam Ultra vision WebCam](http://www.logitech.com/index.cfm/webcam_communications/webcams/devices/238&cl=nz,en) (or similar) (can be sourced from [PB technologies](http://www.pbtech.co.nz) in Auckland)

- A [ClearOne Chat 150](http://www.clearone.com/products/product.php?cat=9&prod=98) echo-cancellation audio unit available from [AVW in East Tamaki, Auckland](http://www.avw.co.nz/) (Connected via a USB 2.0 extension cable, and use external powersupply)
- A data projector, connected to the computer above, projecting on to a screen

# Before the Seminar/Lecture

- Read our [Getting Started with EVO in New_Zealand](getting-started-with-evo.md) page
- If possible, conduct a short five to 10 minute test session a week or a day before the scheduled seminar/lecture
- Be sure to book a time for the Lecture/Seminar in the KAREN community on EVO and not the Universe community
- When making the booking, do not use the 'ad-hoc meeting' option in the booking menu.  It is better to book a meeting using the full booking options.  (If you use the ad-hoc meeting option the room has a tendency to be unreliable.)
- Set the start time option well in advance of the actual start time for the Lecture/Seminar.  Remember, the room will not appear until the start time has been reached.
- Exchange mobile phone numbers, so that if something does go wrong during the Lecture/Seminar, parties can communicate to resolve it.

# During the Lecture/Seminar

- Audio, audio, audio! Make sure Audio is clear for all involved.
- Position the audience close to the ClearOne Chat 150 audio device as possible. If the room has more than 10 people involved, then position those who do not want to ask questions away from the Chat 150. Volume will also be an issue with larger groups. Read [this section using echo cancellation devices with EVO](known-issues-with-evo.md)
- Make sure participants understand how they can control their 'Audio Transmit Gain'.  Please see [Configuring EVO for the first time](/wiki/spaces/BeSTGRID/pages/3818228555).
- In order for the Echo Cancellation to operate correctly, the Chat 150 Device should be selected as the "Audio Transmit Device" (in EVO: AV Controls) and "Audio Receive Device"
- Make sure you can see the chat window (lower right of Koala) during the session – important messages are exchanged this way.
- If you lose video streams, during the meeting, try "Restart Video" in the Video Tab, under the AV controls Tab (in the Koala Window).
