# Production version 1.0 of EVO released

# Announcement from the EVO/VRVS Team

We are pleased to announce the first production release of the EVO (Enabling Virtual Organizations) System ([http://evo.caltech.edu](http://evo.caltech.edu)). EVO is based on a new distributed architecture, leveraging the 10+ years of experience of developing and operating the large distributed VRVS collaboration system now in production. The primary objective of EVO is to provide an improved system and a service to the LHC and other major High Energy Physics programs that fully meets the requirements for usability, quality, scalability, adaptability to a wide range of working environments, reliability and cost. The EVO infrastructure automatically adapts to the prevailing network configuration and status, so as to ensure that the collaboration service runs without disruption. Because EVO is able to perform end-to-end monitoring, including the end-user’s computer as well as the network infrastructure, we are able to inform the user of any potential or arising problems (e.g. excessive CPU load or packet loss) and, where possible, to fix the problems automatically and transparently on behalf of the user (e.g. by switching to another server node in the network, by reducing the number of video streams received, by adjusting audio volume, etc.). The integration of the MonALISA agent-based system ([http://monalisa.caltech.edu](http://monalisa.caltech.edu)) into the new EVO architecture was an important step in the evolution of the collaboration service towards a globally distributed dynamic system that is largely autonomous.

The EVO Client (called Koala) is based on Java and runs on the 3 main Operating Systems used by the scientific community: Windows, Linux and MacOS.

Some of EVO's features and functions are summarized below.

o Instant messaging functions and presence information (i.e. available, busy, ... ) o Private or group chat during a meeting o Meetings-by-invitation, ad-hoc meetings, booked meetings, and permanent virtual rooms o Playback and recording functions (of the entire session [video, audio, whiteboard, Instant Message, Chat,..](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=video%2C%20audio%2C%20whiteboard%2C%20Instant%20Message%2C%20Chat%2C..&linkCreation=true&fromPageId=3816950519)) o Shared files, high resolution sharing of any screen area, and whiteboard functions o Support for several standard videoconferencing protocols: H.323 (Polycom, Tandberg, ...), Session Initiation Protocol (SIP) for VoIP, and the well-known Real-Time Protocol (RTP) used by most of the collaborative applications.

o Automatic TimeZone adjustment and Multi-Language support (English, French, Slovak, German, Italian, Spanish, Portuguese, Finnish, and Chinese) o Firewall-friendly and support for Network Address Translation (NAT) o End-to-End encryption of all the media (video/audio/chat/IM/ ...) o A new video application based on OpenGL where all the live video windows and other objects are embedded in, and may move in a three dimensional space. (This application, which uses the graphics processor unit (GPU) to offload the main CPU and leave it free for other work, is currently available on Windows only, support for other operating systems will follow soon.)

Complete documentation is available at
[http://evo.caltech.edu/evoGate/help.jsp?EvO_Manual](http://evo.caltech.edu/evoGate/help.jsp?EvO_Manual) .

The next additions to EVO, coming very soon, will be (1) the integration of the POTS (phone system) that will allow users to join an EVO meeting through the normal phone system, and (2) the possibility to integrate all of the booking functions with other existing booking systems, such as Indico for example.

Feedback from the user community is very important to us. It allows us to make the system more robust and reliable, and enhance its functionality. We thank you in advance for your patience in this early deployment of the EVO system. Don't hesitate to send email to evosupport@vrvs.org if you are facing any issues. We'll be glad to help troubleshoot the problem as quickly as possible, and update our documentation or EVO itself where needed, based on this experience.

All the best,

The VRVS/EVO Team

PS: We will continue to operate and support VRVS (in parallel to EVO) until early 2008, to give users sufficient time to move to the new systems. We encourage you to move to EVO, where we will focus our efforts from now on, as soon as possible.

-------------------
